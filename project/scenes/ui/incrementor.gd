class_name IncrementorUI
extends VBoxContainer

signal value_changed(old_value: int, new_value: int)

@export var min_value := 0 : 
	set(new_value):
		min_value = new_value
		_clamp_value()
@export var max_value := 0 :
	set(new_value):
		max_value = new_value
		_clamp_value()
@export var value := min_value :
	set(new_value):
		var old_value := value
		value = clamp(new_value, min_value, max_value)
		decrease_button.disabled = value <= min_value
		increase_button.disabled = value >= max_value
		if old_value == value: return
		value_changed.emit(old_value, value)
		


@onready var increase_button : Button = $IncreaseButton
@onready var decrease_button : Button = $DecreaseButton


func _on_increase_button_pressed() -> void:
	value += 1


func _on_decrease_button_pressed() -> void:
	value -= 1


func _clamp_value() -> void:
	value = value
