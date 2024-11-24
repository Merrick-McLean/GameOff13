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
	if Debug.is_just_pressed(&"test_0"):
		var instance : DialogueInstance
		instance = play(DialogueInstance.Id.TEST_1)
		await instance.finished
		instance = play(DialogueInstance.Id.TEST_2)
		await instance.finished


func play(dialogue_id: DialogueInstance.Id, args := {}) -> DialogueInstance:
	var instance := DialogueInstance.new(dialogue_id, display, args)
	instance.play()
	return instance


func get_actor_name(actor : Actor) -> String:
	assert(actor < Actor.COUNT)
	return [
		"Captain",
		"Pirate 1",
		"Pirate 2"
	][actor]


func get_die_face_string(face: int, plural := false) -> String:
	assert(face >= 1 and face <= 6)
	match face:
		1:	return "ones" if plural else "one"
		2:	return "twos" if plural else "two"
		3:	return "threes" if plural else "three"
		4:	return "fours" if plural else "four"
		5:	return "fives" if plural else "five"
		6:	return "sixes" if plural else "six"
	return ""


func get_actor(player: LiarsDice.Player) -> Actor:
	match player:
		LiarsDice.Player.CAPTAIN: return Actor.CAPTAIN
		LiarsDice.Player.PIRATE_RIGHT: return Actor.PIRATE_RIGHT
		LiarsDice.Player.PIRATE_LEFT: return Actor.PIRATE_LEFT
	assert(false)
	return Actor.CAPTAIN
