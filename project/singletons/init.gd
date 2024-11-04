extends Node

func _ready() -> void:
	SceneManager.call_deferred(&"initialize")
