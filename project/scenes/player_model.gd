@tool
class_name PlayerModel
extends Node3D


@export var alive := true :
	set(new_value):
		if alive == new_value: return
		alive = new_value
		if alive:
			_revive()
		else:
			_kill()

@export var player : LiarsDice.Player


func _revive():
	show()

func _kill():
	hide()
