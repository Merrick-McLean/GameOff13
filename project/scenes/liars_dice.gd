extends Node3D

const Math = preload("res://utils/math.gd")

class Round: # should I jsut merge round and bet? - Simpler to just have one big fat class I guess
	# based on bets and player dice, used for npc bets and liar calls
	var cur_bet: Object
	var prev_bet: Object
	var table: Dictionary
	var player: Dictionary
	var turn_order: Array
	
	var rng: Object = RandomNumberGenerator.new()
	
	## SETUP
	func _init(players_in_order: Array) -> void:		
		cur_bet = Bet.new()
		prev_bet = Bet.new()
		# reset table values
		table = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0} # whenever a bet is made, if no lie is called, update the expected table values
		player = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0} # updated when players dice are rolled
		#pref = {'Crewmate1': [randi_range(0,8), randi_range(0,8)], 'Captain': [randi_range(0,8), randi_range(0,8)], 'Crewmate2': [randi_range(0,8), randi_range(0,8)]}
		turn_order = players_in_order
		pass
	
	func _start_round() -> void:
		table = _get_table()
		#values = dice_roll._create_player_dice()
		for i: int in player:
			player[i] += 1
		_set_table(table)
		
	func _pass_turn() -> void: # HANDLE WHEN SOMEONE IS OUT
		var prev: int = cur_bet._get_pid()
		if(cur_bet.pid == (turn_order.size() - 1)):
			cur_bet._set_pid(0)
			prev_bet._set_pid(prev)
		else:
			cur_bet._set_pid(prev + 1)
			prev_bet._set_pid(prev)
		pass
	
	# sets the players current bet
	func _bet(amount: int, value: int) -> void:
		var prev_amount: int = cur_bet._get_cur_amount()
		var prev_value: int = cur_bet._get_cur_value()
		prev_bet._set_bet(prev_amount, prev_value)
		
		cur_bet._set_bet(amount, value)
		# signal that bet has been made for game here?
		pass
	
	## NPC LOGIC - Possibly different behaviour for each npc? - maybe just captain calls 50% of lies, crew 25/25
	
	# logic for npc making a bet
	# since we dont roll before playing, the npcs may play completely different to the final results
	func _npc_bet() -> void:
		var prev_amount: int = cur_bet._get_cur_amount()
		var prev_value: int = cur_bet._get_cur_value()
		prev_bet._set_bet(prev_amount, prev_value)
		
		var prev_player: int = cur_bet._get_cur_pid()
		var cur_player: int = prev_player + 1
		
		var weights: Array = [0, 0, 0, 0, 0, 0] # weighted array values
		var sum: float = 0 # sum of weight  used for deciding to raise
		for i in range (prev_value, 6): # for each remaining dice roll
			# calculate base probability
			var base: float = 1.0/i 
			# calculate favouritism to value
			var fav: float = 0 
			#if(i+1 == pref[cur_player][0] || i+1 == pref[cur_player][1]):
			#	fav += 1.5 # if the face is the players favoured roll, increase weight
			var weight: float = base + table[i] + fav # weight for pick is base + prev appearances + favour to value
			sum += weight # add weight to sum weights
			weights[i] = weight # set weight in weighted array values
		weights[0] = 6 * (1 + prev_amount) - sum # the chance of raising the amount still - REVISE THIS
		var value: int = rng.rand_weighted(PackedFloat32Array(weights)) + 1
		
		if value == 1:
			_npc_raise()
		else:
			_bet(prev_amount, value)
		pass
	
	func _npc_raise() -> void:
		# determine amount to bet
		var prev_amount: int = cur_bet._get_cur_amount()
		var amount_weights: Array = PackedFloat32Array([85, 9, 5.75, 0.25])
		var amount_mod: int = rng.rand_weighted(amount_weights) + 1
		var amount: int = prev_amount + amount_mod
		
		# determine value to bet
		var prev_value: int = cur_bet._get_cur_value()
		var prev_player: int = cur_bet._get_cur_pid()
		var cur_player: int = prev_player + 1
		var weights: Array = [0, 0, 0, 0, 0, 0, 0] # weighted array values
		for i in 6: # for each remaining dice roll
			# calculate base probability
			var base: float = (6.0-i)/6.0
			# calculate favouritism to value
			var fav: float = 0.0
			if(i == prev_value):
				fav += 1.0
			#if(i == pref[cur_player] || i == pref[cur_player % 3]):
			#	fav += 1 # if the face is the players favoured roll, increase weight
			
			var weight: float = base + table[i] + fav # weight for pick is base + prev appearances + favour to value
			weights[i] = weight # set weight in weighted array values
		var value: int = rng.rand_weighted(PackedFloat32Array(weights)) + 1
		
		_bet(amount, value)
		pass
	
	## LIE LOGIC
	# concern if a npc calls you out and they have enough for it to be unreasoanble to call
	# i.e. function to strategically set the npc dice upon reveal
	
	# _det_lie calculates the probability of suceeding a bet and runs the weighted rng 
	# Parameter: Override to override to make the result a lie
	# Returns bool (true if bet was correct, false if bet was incorrect)
	func _validate_call(override: bool) -> bool: 
		var bet_amount: int = cur_bet._get_cur_amount()
		var bet_value: int = cur_bet._get_cur_value()
		var rem_dice: int = (turn_order.size() - 1) * 5
		var req_dice: int = bet_amount - player[bet_value]
		
		if(req_dice <= 0):
			return false
		elif rem_dice < req_dice:
			return true
		elif override:
			return override
		
		var prob: float = (float(Math.factorial(rem_dice))/float((Math.factorial(req_dice)) * Math.factorial(rem_dice - req_dice))) * (pow((1.0/6.0), req_dice) * pow((5.0/6.0), (rem_dice - req_dice)))
		var lie: int = rng.rand_weighted(PackedFloat32Array([prob, 1 - prob]))
		return bool(lie)
	
	# logic for npc considering other players bet. 
	# It is decided by the blind probability of a bet modified based on bet aggressivness and npc recklessness which results in a "percieved success rate"
	# if true, they call a lie
	func _npc_call(reck: float, override: bool) -> bool:
		if override:
			return override # we want this to  trigger det_lie here? we want det_lie to be overriden as well
		
		var prev_amount: int = prev_bet._get_cur_amount()
		var prev_value: int = prev_bet._get_cur_value()
		
		var bet_amount: int = cur_bet._get_cur_amount()
		var bet_value: int = cur_bet._get_cur_value()
		var rem_dice: int = (turn_order.size()) * 5
		var req_dice: int = bet_amount
		
		var amount_jump: int = bet_amount - prev_amount
		var expec_value_amount: int = table[bet_value]
		var expec_value_amount_jump: int = expec_value_amount - bet_amount
		
		if(amount_jump >= 8 || expec_value_amount_jump >= 8): 
			# instantly call if the bet is too agressive
			return true
		else:
			# calculate the base, blind probability of the bet being true (without even knowing your own values - we could subtract one die from this, as if the noc plays like they always have exactly 1 die matching the bet
			var prob: float = (float(Math.factorial(rem_dice))/(float(Math.factorial(req_dice)) * Math.factorial(rem_dice - req_dice))) * (pow((1.0/6.0), req_dice) * pow((5.0/6.0), (rem_dice - req_dice)))
			var perc_succ: float = prob - ((amount_jump/200.0) + ((expec_value_amount_jump - 1)/200.0 + bet_amount/500.0) * reck) - expec_value_amount/500.0
			
			if perc_succ > 0.8:
				perc_succ = 0.999
			elif perc_succ < 0.3:
				perc_succ = 0.001
			
			if perc_succ > 1:
				perc_succ = 1
			elif perc_succ < 0:
				perc_succ = 0
			# do we want a threshhold for them to call more often - i.e. if the textbook probability > 50, an additonal x percent, or if less an reduced x percent
			var lie: int = rng.rand_weighted(PackedFloat32Array([perc_succ, 1 - perc_succ]))
			return bool(lie) 
	
	# updates the table with a new bet
	func _update_table() -> void:
		var amount: int = cur_bet._get_cur_amount()
		var value: int = cur_bet._get_cur_value()
		if self.table[value] < amount:
			self.table[value] = amount
		pass
	
	### SETTERS AND GETTERS ###
	
	# returns the player
	func _get_player() -> Dictionary:
		return self.player
	
	# returns the current prospective
	func _get_table() -> Dictionary:
		return self.table
	
	# updates the players dice values
	func _set_player(nplayer: Dictionary) -> void:
		self.player = nplayer
		pass
	
	# updates the expected values based on bets made by the npcs
	# ONLY UPDATE TABLE AFTER BET HAS SUCCEEDED
	func _set_table(ntable: Dictionary) -> void:
		self.table = ntable
		pass

class Bet:
	var pid: int
	var amount: int
	var value: int
	
	func _init() -> void:
		self.pid = 0
		self.amount = 0
		self.value = 6
		pass

	# also use this function for button/values to be entered in the game - hence why it is a stand alone function
	func _check_bet(namount: int, nvalue: int) -> bool: 
		if (self.amount < namount) || (self.value < nvalue && nvalue <= 6 && self.amount <= namount): # do we want more restrictive rules?
			return true
		else:
			return false
	
	func _set_bet(namount: int, nvalue: int) -> void: 
		if _check_bet(namount, nvalue):
			self.amount = namount
			self.value = nvalue
		pass
		
	### SETTER AND GETTERS ###
	func _get_pid() -> int:
		return self.pid
	
	func _get_value() -> int:
		return self.value
	
	func _get_amount() -> int:
		return self.amount
	
	func _set_pid(npid: int) -> void: # could be += 1 on current or back to 0 to loop through
		self.pid = npid
		pass

### DEFAULT ###
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
