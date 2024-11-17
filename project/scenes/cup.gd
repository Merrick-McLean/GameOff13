@tool
class_name Cup
extends Node3D


#const DIE_SCENE := preload("res://models/dice.glb")

enum State {
	AT_PLAYER,
	AT_REVEAL,
	COUNT
}


@export var player : LiarsDice.Player :
	set(new_value):
		player = new_value
		if not is_node_ready(): await ready
		_update_zoom_in_region_enabled()

var zoom_in_region_enabled := false :
	set(new_value):
		zoom_in_region_enabled = new_value
		if not is_node_ready(): await ready
		zoom_in_region.collision_layer = CollisionLayer.ZOOM if zoom_in_region_enabled else CollisionLayer.NONE
var STATE_POINTS : Array

@onready var body : Node3D = $Body
@onready var zoom_in_region : Area3D = $ZoomInRegion
@onready var rest_point : Node3D = $Points/RestPoint
@onready var raise_point : Node3D = $Points/RaisePoint
@onready var origin_point : Node3D = $Points/OriginPoint
@onready var dice : Node3D = $Dice

@export var amount_raised := 0.0 :
	set(new_value):
		amount_raised = clamp(new_value, 0.0, 1.0)
		if not is_node_ready(): await ready
		var to_rest := rest_point.global_position - origin_point.global_position
		var to_raise := raise_point.global_position - origin_point.global_position
		var quaternion_rest := Quaternion.from_euler(rest_point.global_rotation)
		var quaternion_raise := Quaternion.from_euler(raise_point.global_rotation)
		var from_origin := to_rest.slerp(to_raise, amount_raised)
		body.global_position = origin_point.global_position + from_origin
		body.global_rotation = quaternion_rest.slerp(quaternion_raise, amount_raised).get_euler()

@export var target_raised := false
@export var target_state := State.AT_PLAYER :
	set(new_value):
		target_state = new_value
		_update_zoom_in_region_enabled()

func _ready() -> void:
	assert(dice.get_child_count() == LiarsDice.PLAYER_DIE_COUNT)
	
	# find state points
	STATE_POINTS = ArrayUtils.filled(State.COUNT, null)
	for cup_point: CupPoint in get_tree().get_nodes_in_group(&"CupPoints"):
		if cup_point.player == player:
			assert(STATE_POINTS[cup_point.type] == null)
			STATE_POINTS[cup_point.type] = cup_point
	STATE_POINTS = STATE_POINTS.map(func(x: Node3D) -> Node3D: return x if is_instance_valid(x) else self)
	STATE_POINTS.make_read_only()
	
	set_dice([_r(), _r(), _r(), _r(), _r()])
	_update_zoom_in_region_enabled()


func _process(delta: float) -> void:
	amount_raised = lerp(amount_raised, float(target_raised), delta * 10)
	global_position = global_position.lerp(STATE_POINTS[target_state].global_position, delta * 5)


func set_dice(faces: Array[int], y_rotation := randf() * TAU) -> void:
	assert(faces.size() == LiarsDice.PLAYER_DIE_COUNT)
	dice.rotation.y = y_rotation
	for i: int in LiarsDice.PLAYER_DIE_COUNT:
		var die : Die = dice.get_child(i)
		die.face = faces[i]

# TEMPORARY FUNCTION, REAL ROLLING WILL BE DONE IN LAIRS DICE
func _r() -> int:
	return randf_range(1, LiarsDice.DIE_MAX)


func _update_zoom_in_region_enabled() -> void:
	zoom_in_region_enabled = player == LiarsDice.Player.SELF and target_state == State.AT_PLAYER


#func spawn_dice(values: Array) -> void:
	#for i in LiarsDice.PLAYER_DIE_COUNT:
		#spawn_die(values[i], Vector3.ZERO) # use the i to vary the locations of the dice (or physics)


#func spawn_die(value: int, offset: Vector3) -> void:
	#var die_instance := DIE_SCENE.instantiate()
	#die_instance.position = offset
	#die_instance.rotation_degrees = face[value]
	#die_instance.rotation_degrees.y = randi_range(0,360)
	#add_child(die_instance)
