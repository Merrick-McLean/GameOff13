extends Camera3D


const MAX_ROTATION_UP = 0.2
const MAX_ROTATION_DOWN = 0.85
const MAX_ROTATION_SIDEWAYS = 0.6
const NORMAL_FOV = 55.0
const ZOOMED_FOV = 25.0
const SENSITIVITY = Vector2(0.0015, 0.0015)

@onready var detector : RayCast3D = $Detector

var is_active := false :
	set(new_value):
		is_active = new_value
		current = is_active
		
		if is_active:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

var current_cup : Cup :
	set(new_value):
		if current_cup == new_value: return
		if current_cup:	current_cup.target_raised = false
		current_cup = new_value
		if current_cup:	current_cup.target_raised = true

var mouse_position := Vector2.ONE / 2 :
	set(new_value):
		mouse_position = new_value
		mouse_position = mouse_position.clamp(Vector2.ZERO, Vector2.ONE)


func _ready() -> void:
	is_active = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position += event.relative * SENSITIVITY

func _process(delta: float) -> void:
	var is_colliding := detector.is_colliding()
	var new_cup : Cup = null
	if is_colliding:
		var mask : int = detector.get_collider().collision_layer
		if mask & CollisionLayer.ZOOM:
			var collider := detector.get_collider()
			new_cup = collider.cup if collider else null
		if mask & CollisionLayer.UI:
			var collider := detector.get_collider()
			collider.gui_panel.update_mouse_position(detector.get_collision_point())
	
	# update zoom
	current_cup = new_cup
	fov = lerp(fov, ZOOMED_FOV if current_cup else NORMAL_FOV, 10.0 * delta)
	
	#rotation.y = lerp(MAX_ROTATION_SIDEWAYS, -MAX_ROTATION_SIDEWAYS, mouse_position.x)
	rotation.y = ease_camera(mouse_position.x, MAX_ROTATION_SIDEWAYS, -MAX_ROTATION_SIDEWAYS, 1.0)
	
	#rotation.x = lerp(MAX_ROTATION_UP, -MAX_ROTATION_DOWN, mouse_position.y)
	rotation.x = ease_camera(mouse_position.y, MAX_ROTATION_UP, -MAX_ROTATION_DOWN, 0.2)
	
	



func ease_camera(x: float, min_value: float, max_value: float, intensity: float) -> float:
	assert(x >= 0.0 and x <= 1.0)
	# see https://www.desmos.com/calculator/fpg0lbelf2
	return 1/atan(intensity) * (max_value - min_value) / 2 * atan(2 * intensity * (x-0.5)) + (max_value + min_value) / 2
	
