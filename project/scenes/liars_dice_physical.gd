class_name LiarsDicePhysical
extends Node

signal interact_pressed
signal player_shot
signal cups_raised

@export var player_camera : PlayerCamera
@export var gui_panel : GuiPanel
@export var gun : Gun
@onready var cups := get_tree().get_nodes_in_group(&"Cups")
@onready var player_models := get_tree().get_nodes_in_group(&"PlayerModels")
@onready var better : Better = gui_panel.better
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	assert(gun, "Missing gun!")
	assert(player_camera, "Missing player camera!")
	assert(better, "Missing better!")
	cups.sort_custom(func(a: Cup, b: Cup) -> bool: return a.player < b.player)
	player_models.sort_custom(func(a: PlayerModel, b: PlayerModel) -> bool: return a.player < b.player)
	player_models.insert(0, null)
	LiarsDice.physical = self
	update_alive_players()
	better.hide()




func _process(delta: float) -> void:
	if Debug.is_just_pressed(&"test_1"):
		await reveal_dice()


func _input(event: InputEvent):
	if event.is_action_pressed(&"interact") and GameMaster.player_in_world:
		interact_pressed.emit()


func start_game() -> void:
	gun.visible = false
	gun.can_pickup = false
	for cup: Cup in cups:
		cup.target_state = Cup.State.AT_PLAYER
		cup.target_raised = false
		for die: Die in cup.dice.get_children():
			die.is_alive = true
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
	
	#await player_camera.state_transition_completed
	animation_player.stop()
	animation_player.play("drum_roll")
	await cups_raised
	
	
	await get_tree().create_timer(1.0).timeout
	
	await kill_unwanted_dice()
	
	await interact_pressed
	
	player_camera.transition_state(PlayerCamera.State.IN_GAME)
	
	await player_camera.state_transition_completed


func kill_unwanted_dice() -> void:
	for cup: Cup in cups:
		for die: Die in cup.dice.get_children():
			if die.face != LiarsDice.round.current_bet.value:
				die.is_alive = false
				await get_tree().create_timer(0.05).timeout


func _lift_cups() -> void:
	for cup: Cup in cups:
		cup.target_raised = true
	cups_raised.emit()


func update_alive_players() -> void:
	for player: LiarsDice.Player in LiarsDice.Player.COUNT:
		if player == LiarsDice.Player.SELF:
			if not player in LiarsDice.alive_players:
				player_shot.emit()
		else:
			if player in LiarsDice.alive_players:
				player_models[player].alive = true
				cups[player].visible = true
			else:
				player_models[player].alive = false
				cups[player].visible = false


func spawn_gun() -> void:
	gun.visible = true


func enable_gun_pickup() -> void:
	gun.can_pickup = true
