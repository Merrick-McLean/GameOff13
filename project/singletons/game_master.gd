extends Node

signal interact_pressed

var camera_shaker : CameraShakeManager
var player_in_world := true
var straight_camera : Camera3D


func shake_camera(shake_amount: float) -> void:
	if camera_shaker:
		camera_shaker.shake(shake_amount)


func shake_camera_relative(shake_amount: float) -> void:
	if camera_shaker:
		camera_shaker.shake_relative(shake_amount)
