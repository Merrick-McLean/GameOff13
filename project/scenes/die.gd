@tool
class_name Die
extends Node3D


const FACE_ANGLES: Array[Vector3] = [
	Vector3(3 * TAU / 4,0,0),
	Vector3(0,0,0), 
	Vector3(0,0, TAU / 4),
	Vector3(0, 0, 3 * TAU / 4),
	Vector3(TAU / 4, 0,0),
	Vector3(2 * TAU / 4, 0 ,0),
]



@export var face := 1 :
	set(new_value):
		face = clamp(new_value, 1, LiarsDice.DIE_MAX)
		var angle := FACE_ANGLES[face - 1]
		if not is_node_ready(): await ready
		model.rotation.x = angle.x
		model.rotation.z = angle.z

@export var is_alive := true :
	set(new_value):
		if is_alive == new_value: return
		is_alive = new_value

@onready var model := $Model
