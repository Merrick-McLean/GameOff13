extends Node


const MAX_OPTIONS = 3

var display : DialogueDisplay

enum Actor {
	CAPTAIN,
	PIRATE_LEFT,
	PIRATE_RIGHT,
	COUNT,
}

func _process(delta: float) -> void:
	if Debug.is_just_pressed(&"test_1"):
		var result := await display.push_options([OptionSet.new(Actor.PIRATE_LEFT, ["Option 1", "Option 2", "Option 3"])])
		print(result.actor)
		print(result.index)
	if Debug.is_just_pressed(&"test_2"):
		display.push_options([])
		await display.say(Actor.PIRATE_LEFT, "Pirate 1: I can talk normally,[set speed=5] I can talk slow,[set speed=200] and I can talk fast")
		await display.say(Actor.PIRATE_LEFT, "Pirate 1: I can also pause,[set pause_time=0.9] dramatically[set pause_time=2][set speed=5]...")
		await display.say(Actor.PIRATE_LEFT, "Pirate 1: Anyway what do you think lad? Is that cool or what?", false)
		var result := await display.push_options([OptionSet.new(Actor.PIRATE_LEFT, ["Yes. Super Cool", "No..."])])
		match result.index:
			0: await display.say(Actor.PIRATE_LEFT, "That's the [wave amp=20.0 freq=5.0 connected=1]spirit[/wave]")
			1: await display.say(Actor.PIRATE_LEFT, "Fuck you.")

func dialogue() -> void:
	assert(display)
	await display.say(Actor.PIRATE_LEFT, "Hello there sir, how are you?")

class OptionSet:
	var actor : Actor
	var options : Array
	
	func _init(p_actor: Actor, p_options: Array) -> void:
		actor = p_actor
		assert(options.size() <= MAX_OPTIONS)
		options = p_options

class OptionResult:
	var actor : Actor
	var index : int
	
	func _init(p_actor: Actor, p_index: int) -> void:
		actor = p_actor
		index = p_index
