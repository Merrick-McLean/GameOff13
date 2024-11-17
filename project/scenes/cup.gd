@tool
class_name Cup
extends Node3D


@export var player : LiarsDice.Player :
	set(new_value):
		player = new_value
		if not is_node_ready(): await ready
		if player != LiarsDice.Player.SELF:
			zoom_in_region.collision_layer = CollisionLayer.NONE
		else:
			zoom_in_region.collision_layer = CollisionLayer.ZOOM

@onready var body : Node3D = $Body
@onready var zoom_in_region : Area3D = $ZoomInRegion
@onready var rest_point : Node3D = $Points/RestPoint
@onready var raise_point : Node3D = $Points/RaisePoint
@onready var origin_point : Node3D = $Points/OriginPoint

@export var amount_raised := 0.0 :
	set(new_value):
		amount_raised = clamp(new_value, 0.0, 1.0)
		var to_rest := rest_point.global_position - origin_point.global_position
		var to_raise := raise_point.global_position - origin_point.global_position
		var quaternion_rest := Quaternion.from_euler(rest_point.global_rotation)
		var quaternion_raise := Quaternion.from_euler(raise_point.global_rotation)
		var from_origin := to_rest.slerp(to_raise, amount_raised)
		body.global_position = origin_point.global_position + from_origin
		body.global_rotation = quaternion_rest.slerp(quaternion_raise, amount_raised).get_euler()

var target_raised := false


func _process(delta: float) -> void:
	amount_raised = lerp(amount_raised, float(target_raised), delta * 10)
