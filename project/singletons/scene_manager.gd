extends Node

var is_initialized := false :
	set(new_value):
		assert(new_value)
		is_initialized = new_value
		
		if is_initialized:
			goto_current_scene()

var scene_id : int = MOVEMENT_TEST :
	set(new_value):
		scene_id = new_value % SCENE_COUNT



enum { # Define level enum here
	DITHER_TEST,
	MOVEMENT_TEST,
	SCENE_COUNT, # not an actual scene
}

const SCENES = { # Add scene paths here
	DITHER_TEST: "res://scenes/test/dither_test.tscn",
	MOVEMENT_TEST: "res://scenes/test/movement_test.tscn",
}

func _ready() -> void:
	for id: int in SCENE_COUNT:
		assert(SCENES.has(id), "Missing scene path for " + str(id))
		var scene_path : String = SCENES[id]
		assert(ResourceLoader.exists(scene_path), "Scene does not exist at path " + scene_path)


func goto_current_scene() -> void:
	goto_scene(scene_id)


func goto_next_scene() -> void:
	goto_scene(scene_id + 1)

func goto_previous_scene() -> void:
	goto_scene(scene_id - 1)


func goto_scene(new_scene_id: int) -> void:
	scene_id = new_scene_id
	execute_scene_change()


func execute_scene_change() -> void:
	var scene_path : String = SCENES[(scene_id + SCENE_COUNT) % SCENE_COUNT]
	var error := get_tree().change_scene_to_packed(load(scene_path))
	assert(not error, "Failed to load scene: " + str(error))


func initialize() -> void:
	is_initialized = true
