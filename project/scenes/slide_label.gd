@tool
extends RichTextLabel



func _process(delta: float) -> void:
	visible = bool((Time.get_ticks_msec() / 1000) % 2)
	# stop blink once is_dissolve happens?
