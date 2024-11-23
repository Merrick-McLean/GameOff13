class_name LiarsDicePhysical
extends Node

signal interact_pressed

@export var player_camera : PlayerCamera
@onready var cups := get_tree().get_nodes_in_group(&"Cups")


func _ready() -> void:
	assert(player_camera, "Missing player camera!")
	cups.sort_custom(func(a: Cup, b: Cup) -> bool: return a.player < b.player)


func _process(delta: float) -> void:
	if Debug.is_just_pressed(&"test_1"):
		await reveal_dice()


func _input(event: InputEvent):
	if event.is_action_pressed(&"interact"):
		interact_pressed.emit()


func reveal_dice() -> void:
	for cup: Cup in cups:
		cup.target_state = Cup.State.AT_REVEAL
		cup.target_raised = false
	player_camera.transition_state(PlayerCamera.State.AT_REVEAL)
	
	await player_camera.state_transition_completed
	
	for cup: Cup in cups:
		cup.target_raised = true
	
	await interact_pressed
	
	player_camera.transition_state(PlayerCamera.State.IN_GAME)
	
	await player_camera.state_transition_completed
