@tool
class_name Gun
extends Node3D


enum State {
	ON_TABLE,
	WITH_PLAYER
}

@export var can_pickup := false :
	set(new_value):
		can_pickup = new_value and state == State.ON_TABLE
		if not is_node_ready(): await ready
		hurtbox.collision_layer = CollisionLayer.GUN if can_pickup else CollisionLayer.NONE
@export var state : State :
	set(new_value):
		if state == new_value: return
		state = new_value
		is_clamped = false
		can_pickup = can_pickup

@onready var hurtbox := $Hurtbox
@onready var state_points := get_tree().get_nodes_in_group(&"GunPoints")

var is_clamped := false
var is_hovered := false



func _ready() -> void:
	state_points.sort_custom(func(a: GunPoint, b: GunPoint) -> bool: return a.state < b.state)
	assert(state_points.size() == State.size(), "State count mismatch.")
	for i: int in State.size():
		assert(state_points[i].state == i, "Missing/Duplicate gun point" + str(state_points[i].state))

func _process(delta: float) -> void:
	var target_scale : Vector3 = Vector3.ONE  * (1.1 if is_hovered and can_pickup else 1)
	scale = scale.lerp(target_scale, delta * 6)
	
	if state < state_points.size():
		var gun_point : GunPoint = state_points[state]
		if is_clamped:
			global_position = gun_point.global_position
			global_rotation = gun_point.global_rotation
		else:
			global_position = global_position.lerp(gun_point.global_position, 6 * delta)
			global_rotation = Quaternion.from_euler(global_rotation).slerp(Quaternion.from_euler(gun_point.global_rotation), 6 * delta).get_euler()
			if global_position.distance_to(gun_point.global_position) < 0.001:
				is_clamped = true
	
