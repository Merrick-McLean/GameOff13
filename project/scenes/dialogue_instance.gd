class_name DialogueInstance
extends Object

signal finished(index: int)

enum Id {
	TEST_1,
	TEST_2,
	ROUND_START_1,
}

var display : DialogueDisplay
var id : Id
var is_playing := false

var dialogues : Dictionary = {
	Id.TEST_1: func() -> int:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I can talk normally,[set speed=5] I can talk slow,[set speed=200] and I can talk fast")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I can also pause,[set pause_time=0.9] dramatically[set pause_time=2][set speed=5]...")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anyway what do you think lad? Is that cool or what?", false)
		var result := await display.push_options([OptionSet.new(Dialogue.Actor.PIRATE_LEFT, ["Yes. Super Cool", "No..."])])
		match result.index:
			0: await display.say(Dialogue.Actor.PIRATE_LEFT, "That's the [wave amp=20.0 freq=5.0 connected=1]spirit[/wave]")
			1: await display.say(Dialogue.Actor.PIRATE_LEFT, "Fuck you.")
		return 0,
	
	Id.TEST_2: func() -> int:
		display.push_options([])
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I'm talking over here on the left.")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "I talk over here on the right.")
		await display.say(Dialogue.Actor.CAPTAIN, "And I talk in[set pause_time=0.2] the[set pause_time=0.2] middle.")
		return 0,
	
	Id.ROUND_START_1: func() -> int:
		display.push_options([])
		await display.say(Dialogue.Actor.CAPTAIN, "Alright lad, now make your bet.")
		display.clear_speach()
		return 0,
}


func _init(p_id: Id, p_display: DialogueDisplay) -> void:
	display = p_display
	id = p_id


func play() -> void:
	assert(not is_playing)
	is_playing = true
	var result : int = await dialogues[id].call()
	finished.emit(result)
	free()


func end() -> void:
	finished.emit(-1)
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
