class_name DialogueOptionUI
extends Control

signal selected

@export var time_to_accept := 0.0
@export var text := "" : 
	set(new_value):
		text = new_value
		label.fancy_text = text
@export var hitbox_scale := Vector2.ONE
@export var hitbox_offset := Vector2.ZERO

var hold_time := 0.0 :
	set(new_value):
		var old_value := hold_time
		hold_time = clamp(new_value, 0, time_to_accept)
		if old_value == hold_time: return
		label.charge_percentage = get_hold_percentage()
		if old_value < time_to_accept and hold_time >= time_to_accept:
			selected.emit()
var is_hovered := false :
	set(new_value):
		is_hovered = new_value
		label.material.set_shader_parameter(&"text_color", Color.WHITE if is_hovered else Color.GRAY)

@onready var label : Label = $Label

func _process(delta: float) -> void:
	var rect := get_global_rect()
	rect.position += hitbox_offset - (hitbox_scale - Vector2.ONE) * rect.size / 2
	rect.size *= hitbox_scale
	
	is_hovered = rect.has_point(get_viewport_rect().get_center() / 2)
	
	if visible and is_hovered:
		if time_to_accept == 0.0 and Input.is_action_just_pressed("interact"):
			selected.emit()
		elif get_hold_percentage() < 1.0 and Input.is_action_pressed("interact"):
			hold_time += delta
		else:
			hold_time = 0.0
	else:
		hold_time = 0.0


func get_hold_percentage() -> float:
	if time_to_accept == 0.0:
		return 0.0
	return hold_time / time_to_accept
