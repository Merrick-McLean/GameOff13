extends Node


const MAX_OPTIONS = 3

var display : DialogueDisplay

enum Actor {
	CAPTAIN,
	PIRATE_LEFT,
	PIRATE_RIGHT,
	COUNT,
}




func dialogue() -> void:
	assert(display)
	await display.say(Dialogue.Actor.PIRATE_LEFT, "Hello there sir, how are you?")

class OptionSet:
	var actor : Dialogue.Actor
	var options : Array
	
	func _init(p_actor: Dialogue.Actor, p_options: Array) -> void:
		actor = p_actor
		assert(options.size() <= MAX_OPTIONS)
		options = p_options

class OptionResult:
	var actor : Actor
	var index : int
	
	func _init(p_actor: Actor, p_index: int) -> void:
		actor = p_actor
		index = p_index
