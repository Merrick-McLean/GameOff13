@tool
extends RichTextLabel



func _process(delta: float) -> void:
	visible = bool((Time.get_ticks_msec() / 500) % 2)
