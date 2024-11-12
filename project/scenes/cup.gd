extends Node3D


@export var player : LiarsDice.Player

@onready var body := $Body

var target_raised := false : 
	set(new_value):
		target_raised = new_value
		body.position.y = int(target_raised) * 0.2



func _process(delta: float) -> void:
	if player == LiarsDice.Player.SELF:
		var camera := get_viewport().get_camera_3d()
		var center := get_viewport().get_visible_rect().get_center()
		target_raised = center.distance_to(camera.unproject_position(global_position)) < 100 / sin(deg_to_rad(camera.fov))
		camera.fov = lerp(camera.fov, 25.0 if target_raised else 55.0, 10.0 * delta)
		#camera.fov = 30
		print(center.distance_to(camera.unproject_position(global_position)))
