extends Node

var current_dialogue_id : int = -1
var dialogue_choices : Array = []
var dialogue_progress : Array = []

func set_dialogue(id: int, choices: Array) -> void:
	current_dialogue_id = id
	dialogue_progress.append(id)

func reset() -> void:
	current_dialogue_id = -1
	dialogue_choices.clear()
	dialogue_progress.clear()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
