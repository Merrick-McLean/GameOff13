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

@onready var model := $Model
@onready var smoke_particles := $SmokeParticles


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if Debug.is_just_pressed("test_9") and player == LiarsDice.Player.PIRATE_RIGHT:
		_kill()
	if Debug.is_just_pressed("test_8")  and player == LiarsDice.Player.PIRATE_RIGHT:
		_revive()


func _revive():
	model.show()

func _kill():
	GameMaster.shake_camera(0.15)
	smoke_particles.restart()
	model.hide()
