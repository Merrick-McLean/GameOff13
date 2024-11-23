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


func play(dialogue_id: DialogueInstance.Id) -> DialogueInstance:
	var instance := DialogueInstance.new(dialogue_id, display)
	instance.play()
	return instance


func get_actor_name(actor : Actor) -> String:
	assert(actor < Actor.COUNT)
	return [
		"Captain",
		"Pirate 1",
		"Pirate 2"
	][actor]
