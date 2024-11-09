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



func _process(delta: float) -> void:
	var rect := get_global_rect()
	rect.position += hitbox_offset - (hitbox_scale - Vector2.ONE) * rect.size / 2
	rect.size *= hitbox_scale
	
	if rect.has_point(get_viewport_rect().get_center() / 2):
		modulate.r = 1.0
	else:
		modulate.r = 0.4
