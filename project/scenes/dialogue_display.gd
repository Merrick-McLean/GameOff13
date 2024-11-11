class_name DialogueDisplay
extends Control

signal option_chosen(result: Dialogue.OptionResult)

const DialogueOptionsUIScene = preload("res://scenes/ui/dialogue_options.tscn")

@export var viewport : Viewport

var dialogue_options_uis := []
var last_result : Dialogue.OptionResult

@onready var subtitles : Subtitles = $Subtitles


func _ready() -> void:
	assert(viewport, "No viewport!")
	
	for actor: int in range(Dialogue.Actor.COUNT):
		var dialogue_options_ui : DialogueOptionsUI = DialogueOptionsUIScene.instantiate()
		add_child(dialogue_options_ui)
		dialogue_options_uis.append(dialogue_options_ui)
		var error := dialogue_options_ui.option_chosen.connect(
			func(index: int) -> void: 
				last_result = Dialogue.OptionResult.new(actor, index)
				option_chosen.emit(last_result)
		)
		assert(not error)
	
	dialogue_options_uis[Dialogue.Actor.CAPTAIN].load_options(["TEST"])
	dialogue_options_uis[Dialogue.Actor.PIRATE_RIGHT].load_options(["TEST", "other one"])
	
	Dialogue.display = self


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
			
			if subtitles.current_speaker == actor:
				subtitles.target_x = unprojected_position.x / 2
			
			var weighted_displacement := (displacement * Vector2(1.2, 2.2)).length()
			dialogue_options_ui.visible_percentage = clamp(remap(weighted_displacement, 170, 220, 1.0, 0.0), 0.0, 1.0)


func say(new_speaker: Dialogue.Actor, unparsed_line: String, wait_for_continue := true) -> void:
	subtitles.init_new_line(new_speaker, unparsed_line)
	
	if wait_for_continue:
		await subtitles.line_continued
	else:
		await subtitles.line_finished

func push_options(option_sets: Array[Dialogue.OptionSet]) -> Dialogue.OptionResult:
	var seen_actors := ArrayUtils.filled(Dialogue.Actor.COUNT, false)
	for option_set: Dialogue.OptionSet in option_sets:
		var actor := option_set.actor
		assert(not seen_actors[option_set.actor], "Submitted 2 DialogueOptionSets with the same actor!")
		dialogue_options_uis[actor].load_options(option_set.options)
		seen_actors[actor] = true
	
	for actor: int in range(seen_actors.size()):
		if not seen_actors[actor]:
			dialogue_options_uis[actor].load_options([])
	
	await option_chosen
	
	for dialogue_options_ui: DialogueOptionsUI in dialogue_options_uis:
		dialogue_options_ui.load_options([])
	
	return last_result
