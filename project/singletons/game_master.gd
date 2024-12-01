extends Node

signal interact_pressed

var camera_shaker : CameraShakeManager
var player_in_world := true
var straight_camera : Camera3D
var lightning_overlay : LightningOverlay
var ambience : Ambience


func shake_camera(shake_amount: float) -> void:
	if camera_shaker:
		camera_shaker.shake(shake_amount)


func shake_camera_relative(shake_amount: float) -> void:
	if camera_shaker:
		camera_shaker.shake_relative(shake_amount)


func flash_lightning() -> void:
	if lightning_overlay:
		lightning_overlay.flash()


func kill_lightning() -> void:
	if lightning_overlay:
		lightning_overlay.stop()
