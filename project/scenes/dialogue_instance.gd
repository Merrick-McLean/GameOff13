class_name DialogueInstance
extends Object

signal finished(index: Dictionary)

enum Id {
	TEST_1,
	TEST_2,
	ROUND_START_1,
	PIRATE_BET_1,
	PIRATE_CALL_1,
	PIRATE_LOSE_1,
	PIRATE_WIN_1,
	PIRATE_DEATH_1,
	QUERY_LIAR,
	CAPTAIN_SHOOTS,
}

var display : DialogueDisplay
var id : Id
var args : Dictionary
var is_playing := false

var dialogues : Dictionary = {
	Id.TEST_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I can talk normally,[set speed=5] I can talk slow,[set speed=200] and I can talk fast")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I can also pause,[set pause_time=0.9] dramatically[set pause_time=2][set speed=5]...")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anyway what do you think lad? Is that cool or what?", false)
		var result := await display.push_options([OptionSet.new(Dialogue.Actor.PIRATE_LEFT, ["Yes. Super Cool", "No..."])])
		match result.index:
			0: await display.say(Dialogue.Actor.PIRATE_LEFT, "That's the [wave amp=20.0 freq=5.0 connected=1]spirit[/wave]")
			1: await display.say(Dialogue.Actor.PIRATE_LEFT, "Fuck you.")
		return {},
	
	Id.TEST_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I'm talking over here on the left.")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "I talk over here on the right.")
		await display.say(Dialogue.Actor.CAPTAIN, "And I talk in[set pause_time=0.2] the[set pause_time=0.2] middle.")
		return {},
	
	Id.ROUND_START_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "Alright lad, now make your bet.")
		display.clear_speach()
		return {},
	
	Id.PIRATE_BET_1: func(args: Dictionary) -> Dictionary:
		var actor : Dialogue.Actor = args.actor
		var bet : LiarsDice.Round.Bet = args.bet
		
		display.clear_options()
		await display.say(actor, "I bet " + str(bet.amount) + " " + Dialogue.get_die_face_string(bet.value, bet.amount != 1))
		return {},
	
	Id.PIRATE_CALL_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, str(args.bet.amount) + " " + Dialogue.get_die_face_string(args.bet.value, args.bet.amount != 1) + "? You're a liar!")
		display.clear_speach()
		return {},
	
	Id.PIRATE_LOSE_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, "Well played lad.")
		display.clear_speach()
		return {},
	
	Id.PIRATE_WIN_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, "I knew it. Goodbye lad.")
		display.clear_speach()
		return {},
	
	Id.QUERY_LIAR: func(args: Dictionary) -> Dictionary:
		var result := await display.push_options([OptionSet.new(args.actor, ["LIAR!", "Pass"])])
		display.clear_speach()
		return {"called": result.index == 0},
	
	Id.PIRATE_DEATH_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, "It's time for me to go.")
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_SHOOTS: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "I shoot you now.")
		display.clear_speach()
		return {},
}


func _init(p_id: Id, p_display: DialogueDisplay, p_args := {}) -> void:
	display = p_display
	id = p_id
	args = p_args


func play() -> void:
	assert(not is_playing)
	is_playing = true
	var result : Dictionary = await dialogues[id].call(args)
	finished.emit(result)
	free()


func end() -> void:
	finished.emit({})
	free()


class OptionSet:
	var actor : Dialogue.Actor
	var options : Array
	
	func _init(p_actor: Dialogue.Actor, p_options: Array) -> void:
		actor = p_actor
		assert(options.size() <= Dialogue.MAX_OPTIONS)
		options = p_options

class OptionResult:
	var actor : Dialogue.Actor
	var index : int
	
	func _init(p_actor: Dialogue.Actor, p_index: int) -> void:
		actor = p_actor
		index = p_index
