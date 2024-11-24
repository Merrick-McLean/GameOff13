extends Node


const DIE_MAX = 6 # 6 sided dice
const PLAYER_DIE_COUNT = 5 # how many dice each player rolls each time
const UNDETERMINED = 0

enum Player {
	SELF,		# this is the actual "player" player
	PIRATE_1,
	CAPTAIN,
	PIRATE_2,
	COUNT,
	NOONE
}

var round : Round
var physical : LiarsDicePhysical


func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	if Debug.is_just_pressed("test_7"):
		var round := Round.new([Player.SELF, Player.PIRATE_1, Player.CAPTAIN, Player.PIRATE_2], {
			Player.SELF: 5,
			Player.PIRATE_1: 4,
			Player.CAPTAIN: 4,
			Player.PIRATE_2: 4
		})
		await round.start()



class Round: # should I jsut merge round and bet? - Simpler to just have one big fat class I guess
	# based on bets and player dice, used for npc bets and liar calls
	var current_bet : Bet
	var highest_bid_table: DieTable
	var turn_order: Array[Player]
	var player_index : int # holds the INDEX of turn_order, whose players turn it is. NOT the player id itself
	var player_rolls : Dictionary # maps player ids to dice tables
	
	var global_die_table : DieTable # all the dice in the game
	
	var ideal_probability := 0.2
	var determined_target : Bet # the highest bet, that is guranteed to be valid
	var ideal_target : Bet # the ideal maximum bet, that has a certain probability >= ideal_probability of being valid
	var absolute_target : Bet # the maximum valid bet if all undetermined dice are the same number
	
	var dialogue_instance : DialogueInstance
	var maximum_bet : Bet
	
	## SETUP
	# determined_dice_count maps player ids to how many determined dice they should have
	# TODO: add parameter for weighted dice for each player
	func _init(p_turn_order: Array[Player], determined_dice_count: Dictionary) -> void:
		# INIT VARIABLES
		current_bet = Bet.create_empty()
		turn_order = p_turn_order
		highest_bid_table = DieTable.create_empty()
		global_die_table = DieTable.create_empty()
		maximum_bet = Bet.new(get_player_count() * PLAYER_DIE_COUNT, DIE_MAX)
		
		# ROLL DICE
		for player: Player in turn_order:
			var player_die_table := roll(determined_dice_count[player])
			player_rolls[player] = player_die_table
			global_die_table.add(player_die_table)
		
		# FIND TARGETS
		var max_face : int = global_die_table.get_max_faces().back()
		determined_target = Bet.new(global_die_table.get_face_count(max_face), max_face)
		absolute_target = determined_target.duplicate()
		absolute_target.amount += global_die_table.undetermined_count
		ideal_target = get_last_bet_with_probability(global_die_table, ideal_probability)
		
	
	func start() -> void:
		await LiarsDice.physical.start_game()
		var protagonist_dice : Array[int] = player_rolls[Player.SELF].get_dice_array()
		protagonist_dice.shuffle()
		LiarsDice.physical.cups[Player.SELF].set_dice(protagonist_dice)
		dialogue_instance = Dialogue.play(DialogueInstance.Id.ROUND_START_1)
		await dialogue_instance.finished
		var minimum_bet
		if current_bet.amount == 0:
			minimum_bet = Bet.create_minimum()
		else:
			minimum_bet = current_bet.duplicate()
			minimum_bet.add(1)
		var bet := await LiarsDice.physical.get_player_bet(minimum_bet, maximum_bet)
	
	
	func roll(determined_dice_count : int) -> DieTable:
		assert(determined_dice_count >= 0 and determined_dice_count <= PLAYER_DIE_COUNT)
		var result := DieTable.create_empty()
		
		for i:int in range(determined_dice_count):
			result.face_counts[randi() % DIE_MAX] += 1
		
		result.undetermined_count = PLAYER_DIE_COUNT - determined_dice_count
		
		return result
	
	
	# returns a die table with the known and unknown dice for a certain player
	func get_known_dice(player: Player) -> DieTable:
		if player == Player.CAPTAIN: # captain knows all the dice
			return global_die_table.duplicate()
		
		var result : DieTable = player_rolls[player].duplicate()
		result.undetermined_dice += (get_player_count() - 1) * PLAYER_DIE_COUNT
		return result
	
		
	func pass_turn() -> void: # HANDLE WHEN SOMEONE IS OUT
		player_index += 1
		player_index = player_index % turn_order.size()
	
	# sets the players current bet
	func make_bet(bet: Bet) -> void:
		assert(bet.get_abs() > current_bet.get_abs())
		current_bet = bet
		highest_bid_table.set_face_count(current_bet.value, current_bet.amount) # update highest bid table
	
	
	# returns the player id of the given player_index
	func get_current_player(index := player_index) -> Player:
		return turn_order[index]
	
	
	func get_next_player(index := player_index) -> Player:
		return turn_order[(index + 1) % turn_order.size()]
	
	
	# gets the number of turns between 2 characters, inclusive of the ending player, exclusive of starting player
	func get_player_distance(starting_player: Player, ending_player: Player) -> int:
		return (turn_order.find(ending_player) - turn_order.find(starting_player)) % turn_order.size()
	
	
	func get_player_count() -> int:
		return turn_order.size()
	
	## NPC LOGIC - Possibly different behaviour for each npc? - maybe just captain calls 50% of lies, crew 25/25
	
	
	# TODO: Test this
	func get_bet_valid_probability(current_count: int, determined_count: int, undetermined_count: int) -> float:
		
		if current_count > determined_count + undetermined_count:
			return 0.0
		if current_count <= determined_count:
			return 1.0
		
		var required_undetermined_count := current_count - determined_count
		assert(required_undetermined_count > 0)
		
		var probability := 0.0
		
		for i: int in range(required_undetermined_count, undetermined_count + 1):
			probability += MathUtils.binomial_probability(i, undetermined_count, 1.0 / DIE_MAX)
		
		return probability
	
	
	#  TODO: Test this pls
	func get_last_bet_with_probability(all_dice: DieTable, min_probability: float) -> Bet:
		var total_unknown := all_dice.undetermined_count
		var last_face : int = all_dice.get_max_faces().back()
		var known_amount := all_dice.get_face_count(last_face)
		var extra_dice := 1
		
		# brute force find
		while get_bet_valid_probability(known_amount + extra_dice, known_amount, total_unknown) >= min_probability:
			extra_dice += 1
		
		return Bet.new(last_face, known_amount + extra_dice - 1)
	
	
	# logic for npc making a bet
	# since we dont roll before playing, the npcs may play completely different to the final results
	func get_npc_bet(npc: Player, last_bet: Bet, min_distance: int, max_distance: int) -> Bet:
		assert(min_distance <= max_distance)
		assert(min_distance >= 1)
		
		var roll : DieTable = player_rolls[npc]
		var known_dice := get_known_dice(npc)
		
		
		
		# adjust max distance to try to stay within current range
		if last_bet.distance_to(absolute_target) > max_distance:
			max_distance = last_bet.distance_to(absolute_target) - 1
		elif last_bet.distance_to(ideal_target) > max_distance:
			max_distance = last_bet.distance_to(ideal_target) - 1
		elif last_bet.distance_to(determined_target) > max_distance:
			pass # it's okay to go into ideal range
		else:
			pass
		min_distance = min(min_distance, max_distance)
		
		if max_distance <= 0:
			var new_bet := last_bet.duplicate()
			new_bet.add(1)
			return new_bet
		
		
		# calculate probabilities for all bets in the range
		var abs_bet_probabilities := {} # maps abs bet values, to probabilities
		for offset: int in range(min_distance, max_distance + 1):
			var bet_abs := last_bet.get_abs() + offset
			var bet := Bet.from_abs(bet_abs)
			abs_bet_probabilities[bet_abs] = get_bet_valid_probability(bet.amount, known_dice.get_face_count(bet.value), known_dice.undetermined_count)
		
		# TODO: apply some weighting here
		# right now we are just taking the best probability. Tie breaker, choose the lower bet
		var best_bet_abs = abs_bet_probabilities[last_bet.get_abs() + 1]
		for bet_abs: int in abs_bet_probabilities:
			if abs_bet_probabilities[bet_abs] > abs_bet_probabilities[best_bet_abs]:
				best_bet_abs = bet_abs
		
		return Bet.from_abs(best_bet_abs)
		
		#var weights: Array = [0, 0, 0, 0, 0, 0] # weighted array values
		#var sum: float = 0 # sum of weight  used for deciding to raise
		#for i in range (prev_value, 6): # for each remaining dice roll
			## calculate base probability
			#var base: float = 1.0/i 
			## calculate favouritism to value
			#var fav: float = 0 
			##if(i+1 == pref[cur_player][0] || i+1 == pref[cur_player][1]):
			##	fav += 1.5 # if the face is the players favoured roll, increase weight
			#var weight: float = base + highest_bid_table[i] + fav # weight for pick is base + prev appearances + favour to value
			#sum += weight # add weight to sum weights
			#weights[i] = weight # set weight in weighted array values
		#weights[0] = 6 * (1 + prev_amount) - sum # the chance of raising the amount still - REVISE THIS
		#var value: int = rng.rand_weighted(PackedFloat32Array(weights)) + 1
		#
		#if value == 1:
			#_npc_raise()
		#else:
			#_bet(prev_amount, value)
		#pass
	
	#func _npc_raise() -> void:
		## determine amount to bet
		#var prev_amount: int = current_bet._get_cur_amount()
		#var amount_weights: Array = PackedFloat32Array([85, 9, 5.75, 0.25])
		#var amount_mod: int = rng.rand_weighted(amount_weights) + 1
		#var amount: int = prev_amount + amount_mod
		#
		## determine value to bet
		#var prev_value: int = current_bet._get_cur_value()
		#var prev_player: int = current_bet._get_cur_pid()
		#var cur_player: int = prev_player + 1
		#var weights: Array = [0, 0, 0, 0, 0, 0, 0] # weighted array values
		#for i in 6: # for each remaining dice roll
			## calculate base probability
			#var base: float = (6.0-i)/6.0
			## calculate favouritism to value
			#var fav: float = 0.0
			#if(i == prev_value):
				#fav += 1.0
			##if(i == pref[cur_player] || i == pref[cur_player % 3]):
			##	fav += 1 # if the face is the players favoured roll, increase weight
			#
			#var weight: float = base + highest_bid_table[i] + fav # weight for pick is base + prev appearances + favour to value
			#weights[i] = weight # set weight in weighted array values
		#var value: int = rng.rand_weighted(PackedFloat32Array(weights)) + 1
		#
		#_bet(amount, value)
		#pass
	
	
	# logic for npc considering other players bet. 
	# It is decided by the blind probability of a bet modified based on bet aggressivness and npc recklessness which results in a "percieved success rate"
	# if true, they call a lie
	func get_npc_call_probability(npc: Player, bet: Bet, recklessness: float) -> float:
		
		var known_dice := get_known_dice(npc)
		var call_probability := 1.0 - get_bet_valid_probability(bet.amount, known_dice.get_face_count(bet.value), known_dice.undetermined_amount)
		call_probability += recklessness
		
		call_probability = clamp(call_probability, 0.0, 1.0)
		
		const MAX_CUTOFF = 0.8
		const MIN_CUTOFF = 0.4
		
		# see https://www.desmos.com/calculator/fusev4nrki
		return clamp(1.0 / (MAX_CUTOFF - MIN_CUTOFF) * (call_probability - MIN_CUTOFF), 0.0, 1.0)
	
	# meant to be called after the player bids
	# returns Player.NOONE if noone calls, or returns the caller
	func get_caller(player_bet: Bet) -> Player:
		assert(get_current_player() == Player.SELF)
		
		# FORCE CALL IF CAPTAIN CAN'T MAKE REASONABLE BET
		var distance_to_captain := get_player_distance(Player.SELF, Player.CAPTAIN)
		var bet_distance := player_bet.distance_to(ideal_target)
		
		if distance_to_captain > bet_distance:
			# Favour that the NPC makes a call so we don't to force kill the player
			var crew_mates := turn_order.filter(is_crewmate)
			if crew_mates.size() > 0:
				return crew_mates.pick_random()
			return Player.CAPTAIN
		
		# DO PROBABILITY THING
		for npc: Player in turn_order.filter(is_npc):
			var probability = get_npc_call_probability(npc, player_bet, 0.0) #TODO: modify the recklessness
			if randf() < probability:
				return npc
		
		
		# NO CALL
		return Player.NOONE
		
	
	# TODO: Implement
	func npcs_react(last_better: Player, last_bet: Bet) -> void:
		pass
	
	
	func kill_player(player: Player) -> void:
		assert(player != Player.CAPTAIN)
		pass
	
	
	# Prompt the player to call the current bet. if returns true the player calls the bet
	# TODO: Implement
	func prompt_player_call(last_better: Player) -> bool:
		assert(last_better != Player.SELF)
		return false
	
	
	# Prompts dialogue options to show up
	func prompt_dialogue_options() -> void:
		pass
	
	# get the players bet
	func get_self_bet(last_bet: Bet) -> Bet:
		return Bet.create_empty()
	
	# TODO: Implement
	# returns the loser
	func call_bet(caller: Player, callee: Player) -> Player:
		return caller
	
	
	func is_npc(player: Player) -> bool:
		return player != Player.SELF
	
	func is_crewmate(player: Player) -> bool:
		return player != Player.SELF and player != Player.CAPTAIN
	
	
	
	func main_loop() -> void:
		
		var loser := Player.NOONE
		while true:
			if is_npc(get_current_player()):
				var bet := get_npc_bet(get_current_player(), current_bet, 4, 8) # TODO: get this range finding properly
				make_bet(bet)
				await npcs_react(get_current_player(), bet)
				var call := await prompt_player_call(get_current_player())
				if call:
					loser = await call_bet(Player.SELF, get_current_player())
					break
			else:
				assert(get_current_player() == Player.SELF)
				prompt_dialogue_options() 
				var bet := await get_self_bet(current_bet)
				make_bet(bet)
				var caller := get_caller(bet)
				if caller != Player.NOONE:
					loser = call_bet(caller, get_current_player())
					break
				await npcs_react(get_current_player(), bet)
			await pass_turn()
		
		await kill_player(loser)
		
	
		#var rem_dice: int = (turn_order.size()) * 5
		#var req_dice: int = bet_amount
		
		#var amount_jump: int = bet_amount - prev_amount
		#var expec_value_amount: int = highest_bid_table[bet_value]
		#var expec_value_amount_jump: int = expec_value_amount - bet_amount
		
		#if(amount_jump >= 8 || expec_value_amount_jump >= 8): 
			## instantly call if the bet is too agressive
			#return true
		#else:
			## calculate the base, blind probability of the bet being true (without even knowing your own values - we could subtract one die from this, as if the noc plays like they always have exactly 1 die matching the bet
			#var prob: float = (float(Math.factorial(rem_dice))/(float(Math.factorial(req_dice)) * Math.factorial(rem_dice - req_dice))) * (pow((1.0/6.0), req_dice) * pow((5.0/6.0), (rem_dice - req_dice)))
			#var perc_succ: float = prob - ((amount_jump/200.0) + ((expec_value_amount_jump - 1)/200.0 + bet_amount/500.0) * recklessness) - expec_value_amount/500.0
			#
			#if perc_succ > 0.8:
				#perc_succ = 0.999
			#elif perc_succ < 0.3:
				#perc_succ = 0.001
			#
			#if perc_succ > 1:
				#perc_succ = 1
			#elif perc_succ < 0:
				#perc_succ = 0
			## do we want a threshhold for them to call more often - i.e. if the textbook probability > 50, an additonal x percent, or if less an reduced x percent
			#var lie: int = rng.rand_weighted(PackedFloat32Array([perc_succ, 1 - perc_succ]))
			#return bool(lie) 
	
	
	class DieTable:
		var face_counts := ArrayUtils.filled(DIE_MAX, 0) # number of dice of each face
		var undetermined_count := 0 # number of undetermined_count dice
		
		func _init(p_face_counts: Array, p_undetermined_count: int) -> void:
			assert(face_counts.size() == DIE_MAX)
			face_counts = p_face_counts
			p_undetermined_count = p_undetermined_count
		
		
		static func create_empty() -> DieTable:
			return DieTable.new(ArrayUtils.filled(DIE_MAX, 0), 0)
		
		func get_face_count(i: int) -> int:
			return face_counts[i - 1]
		
		func set_face_count(i: int, count: int) -> void:
			face_counts[i - 1] = count
		
		func add(other: DieTable) -> void:
			for i: int in range(DIE_MAX):
				face_counts[i] += other.face_counts[i]
			
			undetermined_count += other.undetermined_count
		
		func subtract(other: DieTable) -> void:
			for i: int in range(DIE_MAX):
				face_counts[i] -= other.face_counts[i]
			
			undetermined_count -= other.undetermined_count
		
		
		# returns the faces that are used the most. result is ordered from smallest face to largest
		func get_max_faces() -> Array[int]:
			var result : Array[int] = []
			var max_face := 0
			for i: int in range(DIE_MAX):
				if get_face_count(max_face) < get_face_count(i):
					result.clear()
					max_face = i
				if get_face_count(max_face) <= get_face_count(i):
					result.append(i + 1)
			
			return result
		
		func duplicate() -> DieTable:
			return DieTable.new(face_counts.duplicate(), undetermined_count)
		
		
		func get_dice_array() -> Array[int]:
			var result : Array[int] = []
			for face: int in face_counts.size():
				for i: int in face_counts[face]:
					result.append(face + 1)
			
			return result
		
		
	
	class Bet:
		var amount: int
		var value: int
		
		func _init(p_amount: int, p_value: int) -> void:
			assert(p_amount >= 0)
			assert(p_value >= 1 and p_value <= DIE_MAX)
			amount = p_amount
			value = p_value
		
		
		static func create_empty() -> Bet:
			return Bet.new(0, 1)
		
		
		static func from_abs(abs_value: int) -> Bet:
			return Bet.new(abs_value / DIE_MAX, abs_value % DIE_MAX + 1)
		
		
		static func create_minimum() -> Bet:
			return Bet.new(1, 1)
		
		func duplicate() -> Bet:
			return Bet.new(amount, value)
		
		func is_less_than(other_bet: Bet) -> bool:
			return amount < other_bet.amount or value < other_bet.value
		
		func get_abs() -> int:
			return DIE_MAX * amount + (value - 1)
		
		
		func set_abs(abs_value: int) -> void:
			amount = abs_value / DIE_MAX
			value = abs_value % DIE_MAX + 1
		
		func add(abs_value: int) -> void:
			set_abs(get_abs() + abs_value)
		
		# gets the maximum number of bets that can be made between 2 bets,
		# excluding the starting bet (this bet), and including the ending bet
		func distance_to(ending_bet: Bet) -> int:
			return ending_bet.get_abs() - get_abs()
