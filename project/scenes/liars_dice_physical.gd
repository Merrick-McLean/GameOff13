class_name LiarsDicePhysical
extends Node

signal interact_pressed
signal player_shot
signal navy_shot
signal cups_raised
signal ready_for_credits

@export var player_camera : PlayerCamera
@export var gui_panel : GuiPanel
@export var pirate_gun : Gun
@export var captain_gun : Gun
@export var final_captain_point : Node3D
@onready var cups := get_tree().get_nodes_in_group(&"Cups")
@onready var player_models := get_tree().get_nodes_in_group(&"PlayerModels")
@onready var better : Better = gui_panel.better
@onready var animation_player : AnimationPlayer = $AnimationPlayer



var cups_and_dice_visible : bool = false :
	set(new_value):
		cups_and_dice_visible = new_value
		for cup: Cup in cups:
			cup.visible = cups_and_dice_visible and cup.player in LiarsDice.alive_players

var is_captain_gun_drawn : bool = false :
	set(new_value):
		is_captain_gun_drawn = new_value
		captain_gun.state = Gun.State.DRAWN if is_captain_gun_drawn else Gun.State.UNDRAWN

func _ready() -> void:
	assert(pirate_gun, "Missing gun!")
	assert(player_camera, "Missing player camera!")
	assert(better, "Missing better!")
	assert(captain_gun, "Missing captain's gun!")
	assert(final_captain_point, "Missing final captain point")
	cups.sort_custom(func(a: Cup, b: Cup) -> bool: return a.player < b.player)
	player_models.sort_custom(func(a: PlayerModel, b: PlayerModel) -> bool: return a.player < b.player)
	player_models.insert(0, null)
	LiarsDice.physical = self
	update_alive_players()
	better.hide()
	update_betting_lock()
	reset()


func _process(delta: float) -> void:
	if Debug.is_just_pressed("test_2"):
		is_captain_gun_drawn = !is_captain_gun_drawn


func update_betting_lock() -> void:
	better.is_locked = (Dialogue.display and Dialogue.display.is_someone_speaking) or Dialogue.is_betting_locked


func reset() -> void:
	cups_and_dice_visible = false
	is_captain_gun_drawn = false


func _input(event: InputEvent):
	if event.is_action_pressed(&"interact") and GameMaster.player_in_world:
		interact_pressed.emit()


func start_game() -> void:
	Dialogue.is_betting_locked = false
	pirate_gun.can_pickup = false
	cups_and_dice_visible = true
	better.visible = false
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


func pirate_shoot() -> void:
	navy_shot.emit()


func pan_camera_to_pirate_gun() -> void:
	pirate_gun.can_pickup = true
	player_camera.pan_to_point(pirate_gun.global_position)

func pan_camera_to_captain() -> void:
	player_camera.pan_to_point(final_captain_point.global_position)


func play_credits() -> void:
	ready_for_credits.emit()
