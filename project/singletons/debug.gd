extends Node

var can_be_enabled := OS.is_debug_build()
var is_enabled := can_be_enabled :
	set(new_value):
		is_enabled = new_value and can_be_enabled
		print("Debug Mode: " + ("Enabled" if is_enabled else "Disabled"))


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_enable"):
		Settings.is_debug_enabled = !Settings.is_debug_enabled
	if Input.is_action_just_pressed("debug_quit_game"):
		get_tree().quit()
