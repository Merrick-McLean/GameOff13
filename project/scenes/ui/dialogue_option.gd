class_name DialogueOptionUI
extends Control

signal selected

@onready var label : Label = $Label

var hitbox_scale := Vector2.ONE
var hitbox_offset := Vector2.ZERO
var text := "" : 
	set(new_value):
		text = new_value
		label.text = text
var is_hovered := false :
	set(new_value):
		is_hovered = new_value
		label.material.set_shader_parameter(&"text_color", Color.WHITE if is_hovered else Color.GRAY)


func _process(delta: float) -> void:
	var rect := get_global_rect()
	rect.position += hitbox_offset - (hitbox_scale - Vector2.ONE) * rect.size / 2
	rect.size *= hitbox_scale
	
	is_hovered = rect.has_point(get_viewport_rect().get_center() / 2)
	
	if visible and is_hovered and Input.is_action_just_pressed("interact"):
		selected.emit()
