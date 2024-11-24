class_name LiarsDicePhysical
extends Node

signal interact_pressed

@export var player_camera : PlayerCamera
@export var gui_panel : GuiPanel
@onready var cups := get_tree().get_nodes_in_group(&"Cups")
@onready var better : Better = gui_panel.better

func _ready() -> void:
	assert(player_camera, "Missing player camera!")
	assert(better, "Missing better!")
	cups.sort_custom(func(a: Cup, b: Cup) -> bool: return a.player < b.player)
	LiarsDice.physical = self
	better.hide()




func _process(delta: float) -> void:
	if Debug.is_just_pressed(&"test_1"):
		await reveal_dice()


func _input(event: InputEvent):
	if event.is_action_pressed(&"interact"):
		interact_pressed.emit()


func start_game() -> void:
	for cup: Cup in cups:
		cup.target_state = Cup.State.AT_PLAYER
		cup.target_raised = false
	player_camera.transition_state(PlayerCamera.State.IN_GAME)


func get_player_bet(minimum_bet: LiarsDice.Round.Bet, maximum_bet: LiarsDice.Round.Bet) -> LiarsDice.Round.Bet:
	better.show()
	better.minimum_bet = minimum_bet
	better.maximum_bet = maximum_bet
	better.override_current_bet(minimum_bet)
	await better.bet_made
	var bet = better.current_bet.duplicate()
	better.hide()
	return bet


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
