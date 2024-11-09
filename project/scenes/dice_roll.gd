@tool
extends Node3D

var die = preload("res://models/die.glb")

var face: Dictionary = {1: Vector3(90,0,0), 2: Vector3(180,0,0), 3: Vector3(0,0,90), 4: Vector3(0,0,270), 5: Vector3(0,0,0), 6: Vector3(270,0,0)}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	var value = rng.randi_range(1,6)
	_spawn_die(value)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _spawn_die(value):
	print("creating die")
	var dieInstance = die.instantiate()
	dieInstance.transform.origin = Vector3(0,0,0)
	
	match value:
		1:
			print("1")
			dieInstance.rotation_degrees = face[1]
		2: 
			print("2")
			dieInstance.rotation_degrees = face[2]
		3: 
			print("3")
			dieInstance.rotation_degrees = face[3]
		4: 
			print("4")
			dieInstance.rotation_degrees = face[4]
		5: 
			print("5")
			dieInstance.rotation_degrees = face[5]
		6: 
			print("6")
			dieInstance.rotation_degrees = face[6]

	add_child(dieInstance)
