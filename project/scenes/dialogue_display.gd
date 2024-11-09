extends Control


const DialogueOptionsScene = preload("res://scenes/ui/dialogue_options.tscn")

@export var viewport : Viewport

var dialogue_options := []




func _ready() -> void:
	assert(viewport, "No viewport!")
	
	for i in range(Dialogue.Actor.COUNT):
		var dialogue_options : DialogueOptions = DialogueOptionsScene.instantiate()
		dialogue_options.hide()
		dialogue_options.append(dialogue_options)
	


func _process(delta: float) -> void:
	
	var camera : Camera3D = viewport.get_camera_3d()
	
	if camera:
	
		var dialogue_points := get_tree().get_nodes_in_group(&"DialoguePoints")
		var encountered_actors := ArrayUtils.filled(Dialogue.Actor.COUNT, false)
		
		for dialogue_point: DialoguePoint in dialogue_points:
			var unprojected_position := camera.unproject_position(dialogue_point.global_position)
			var displacement := Vector2(viewport.size) / 2 - unprojected_position
			var actor := dialogue_point.actor
			
			assert(not encountered_actors[actor], "Two DialoguePoints exist for the same actor")
			encountered_actors[actor] = true
