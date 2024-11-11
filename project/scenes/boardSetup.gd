### SETUP ###
@tool
extends Node3D

class_name boardSetup

# set die model
var die = preload("res://models/die.glb")
# set cup model
var cup = preload("res://models/die.glb")

# we also want to randomize the y value to give a sense opf randomness
var face: Dictionary = {1: Vector3(90,randi_range(0,360),0), 2: Vector3(180,randi_range(0,360),0), 3: Vector3(0,randi_range(0,360),90), 4: Vector3(0,randi_range(0,360),270), 5: Vector3(0,randi_range(0,360),0), 6: Vector3(270,randi_range(0,360),0)}
const anchors: Dictionary = {'Player': Vector3(0,0,0), 'Crewmate1': Vector3(0,0,0), 'Captain': Vector3(0,0,0), 'Crewmate2': Vector3(0,0,0)}
const dice_per = 5

### CAPABILTIES ###
# Function to create 5 non-overlapping dice based upon the given values and the anchor location of cup for the NPC
# TODO: once we have environment and cup, add dice distribution
# TODO: linkt to decision making algorithm which will provide the dice values
func _create_dice(values: Array, target: String) -> void:
	for i in dice_per:
		_spawn_die(values[i], anchors[target]) # use the i to vary the locations of the dice (or physics)
	pass

func _create_player_dice() -> Array:
	var rng = RandomNumberGenerator.new()
	var values = Array()
	for i in dice_per:
		var value = rng.randi_range(1,6)
		values[i] = value
	_create_dice(values, 'Player')
	return values

# Function to spawn a single die at a given location in 3d space with a certain value
func _spawn_die(value: int, loc: Vector3) -> void:
	print("creating die")
	var dieInstance = die.instantiate()
	dieInstance.transform.origin = loc
	dieInstance.rotation_degrees = face[value]
	add_child(dieInstance)
	pass

func _spawn_cup(loc: Vector3) -> void:
	var cupInstance = cup.instantiate()
	cupInstance.transform.origin = loc
	add_child(cupInstance)
	pass

# related animation scripts for cup and dice

### DEFAULT ###
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	_spawn_die(rng.randi_range(1,6), Vector3(0,0,0))
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
