extends Node


var camera_shaker : CameraShakeManager
var player_in_world := true



func shake_camera(shake_amount: float) -> void:
	if camera_shaker:
		camera_shaker.shake(shake_amount)


func shake_camera_relative(shake_amount: float) -> void:
	if camera_shaker:
		camera_shaker.shake_relative(shake_amount)
