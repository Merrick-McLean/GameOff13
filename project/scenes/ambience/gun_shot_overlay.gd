@tool
extends Control

signal transition_requested

@onready var ear_ringing_sound := $EarRingingSound
@onready var label := $ColorRect/Label
@onready var animation_player := $AnimationPlayer
@onready var flash_white := $ColorRect

@export var ringing_loudness : float :
	set(new_value):
		ringing_loudness = clamp(new_value, 0.0, 1.0)
		ear_ringing_sound.volume_db = linear_to_db(ringing_loudness * 0.8)


@export var show_text := false
var in_transition := false
var is_active := false :
	set(new_value):
		if is_active == new_value: return
		is_active = new_value
		
		if is_active:
			GameMaster.player_in_world = false
			in_transition = false
			if animation_player:
				animation_player.stop()
				animation_player.play("shoot")
		else:
			GameMaster.player_in_world = true
			in_transition = false
			flash_white.visible = false
			if animation_player:
				animation_player.stop()
				animation_player.play("RESET")




func _process(delta: float) -> void:
	if not is_active: return
	
	if show_text:
		label.visible_ratio += Subtitles.DEFAULT_SPEED * delta / label.text.length() * 0.5
	else:
		label.visible_ratio = 0.0
	
	if Input.is_action_just_pressed("interact"):
		if label.visible_ratio >= 1.0:
			animation_player.play("fade")
		elif show_text:
			label.visible_ratio = 1.0
	
	if animation_player.current_animation == "fade":
		ringing_loudness -= delta * 0.2


func _on_lightning_overlay_flashed() -> void:
	is_active = false


func _on_liars_dice_physical_player_shot() -> void:
	is_active = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade":
		transition_requested.emit()
