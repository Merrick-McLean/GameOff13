extends Node


const MAX_OPTIONS = 3


enum Actor {
	CAPTAIN,
	PIRATE_LEFT,
	PIRATE_RIGHT,
	COUNT,
}



func get_dialogue_options(actor: Actor) -> Array[String]:
	var result : Array[String] = []
	
	
	match actor:
		Actor.PIRATE_LEFT:
			result = ["Test 1", "How are ya?", "Test 2"]
	
	assert(result.size() <= MAX_OPTIONS)
	return result
	
	
	
