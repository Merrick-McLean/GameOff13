extends Control


const DialogueOptionsUIScene = preload("res://scenes/ui/dialogue_options.tscn")

@export var viewport : Viewport

var dialogue_options_uis := []




func _ready() -> void:
	assert(viewport, "No viewport!")
	
	for i in range(Dialogue.Actor.COUNT):
		var dialogue_options_ui : DialogueOptionsUI = DialogueOptionsUIScene.instantiate()
		add_child(dialogue_options_ui)
		dialogue_options_uis.append(dialogue_options_ui)
	
	dialogue_options_uis[Dialogue.Actor.CAPTAIN].load_options(["TEST"])
	dialogue_options_uis[Dialogue.Actor.PIRATE_RIGHT].load_options(["TEST", "other one"])


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
			
			var dialogue_options_ui : DialogueOptionsUI = dialogue_options_uis[actor]
			dialogue_options_ui.position = unprojected_position / 2 - dialogue_options_ui.size / 2
			var weighted_displacement := (displacement * Vector2(1.2, 2.2)).length()
			dialogue_options_ui.visible_percentage = clamp(remap(weighted_displacement, 170, 220, 1.0, 0.0), 0.0, 1.0)
