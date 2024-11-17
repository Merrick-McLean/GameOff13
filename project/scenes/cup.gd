@tool
class_name Cup
extends Node3D


#const DIE_SCENE := preload("res://models/dice.glb")



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
@onready var dice : Node3D = $Dice

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

@export var target_raised := false


func _ready() -> void:
	assert(dice.get_child_count() == LiarsDice.PLAYER_DIE_COUNT)
	
	set_dice([_r(), _r(), _r(), _r(), _r()])


func _process(delta: float) -> void:
	amount_raised = lerp(amount_raised, float(target_raised), delta * 10)


func set_dice(faces: Array[int], y_rotation := randf() * TAU) -> void:
	assert(faces.size() == LiarsDice.PLAYER_DIE_COUNT)
	dice.rotation.y = y_rotation
	for i: int in LiarsDice.PLAYER_DIE_COUNT:
		var die : Die = dice.get_child(i)
		die.face = faces[i]

# TEMPORARY FUNCTION, REAL ROLLING WILL BE DONE IN LAIRS DICE
func _r() -> int:
	return randf_range(1, LiarsDice.DIE_MAX)


#func spawn_dice(values: Array) -> void:
	#for i in LiarsDice.PLAYER_DIE_COUNT:
		#spawn_die(values[i], Vector3.ZERO) # use the i to vary the locations of the dice (or physics)


#func spawn_die(value: int, offset: Vector3) -> void:
	#var die_instance := DIE_SCENE.instantiate()
	#die_instance.position = offset
	#die_instance.rotation_degrees = face[value]
	#die_instance.rotation_degrees.y = randi_range(0,360)
	#add_child(die_instance)
