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

var cups_and_dice_visible : bool = false :
	set(new_value):
		cups_and_dice_visible = new_value
		for cup: Cup in cups:
			cup.visible = cups_and_dice_visible

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
	cups_and_dice_visible = false
	gun.visible = false
	Dialogue.display_changed.connect(_on_dialogue_display_changed)


func _on_dialogue_display_changed(old_display: DialogueDisplay, new_display: DialogueDisplay) -> void:
	if old_display:
		old_display.is_someone_speaking_changed.disconnect(update_betting_lock)
	if new_display:
		new_display.is_someone_speaking_changed.connect(update_betting_lock)
		update_betting_lock(false, new_display.is_someone_speaking)

func update_betting_lock(_u: bool, is_someone_speaking: bool) -> void:
	better.is_locked = is_someone_speaking



func _input(event: InputEvent):
	if event.is_action_pressed(&"interact") and GameMaster.player_in_world:
		interact_pressed.emit()


func start_game() -> void:
	gun.visible = false
	gun.can_pickup = false
	cups_and_dice_visible = true
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
	await get_tree().create_timer(0.2)
	animation_player.stop()
	animation_player.play("drum_roll")
	await cups_raised
	await interact_pressed
	
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
				Progress.player_death_count += 1
		else:
			if player in LiarsDice.alive_players:
				player_models[player].alive = true
				cups[player].visible = true and cups_and_dice_visible
			else:
				player_models[player].alive = false
				cups[player].visible = false


func spawn_gun() -> void:
	gun.visible = true


func enable_gun_pickup() -> void:
	gun.can_pickup = true
