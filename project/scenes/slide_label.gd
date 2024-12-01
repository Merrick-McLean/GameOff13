@tool
extends GradientLabel

signal game_started

var is_disabled := false

func _process(delta: float) -> void:
	
	
	if not Engine.is_editor_hint() and is_visible_in_tree() and GameMaster.is_interact_pressed() and charge_percentage < 1.0:
		visible = true
		charge_percentage += delta
		if charge_percentage >= 1.0:
			game_started.emit()
			visible = false
			is_disabled = true
	elif not is_disabled:
		visible = bool((Time.get_ticks_msec() / 1000) % 2)
