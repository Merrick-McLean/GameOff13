extends Camera3D


const MAX_ROTATION_UP = 0.2
const MAX_ROTATION_DOWN = 0.6
const MAX_ROTATION_SIDEWAYS = 0.5

var is_active := false :
	set(new_value):
		is_active = new_value
		current = is_active
		
		if is_active:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:
	is_active = true

func _process(delta: float) -> void:
	var percent_from_center := get_viewport().get_mouse_position() / Vector2(get_viewport().size)
	percent_from_center = percent_from_center.clamp(Vector2.ZERO, Vector2.ONE)
	
	
	
	#rotation.y = lerp(MAX_ROTATION_SIDEWAYS, -MAX_ROTATION_SIDEWAYS, percent_from_center.x)
	rotation.y = ease_camera(percent_from_center.x, MAX_ROTATION_SIDEWAYS, -MAX_ROTATION_SIDEWAYS, 1.0)
	
	#rotation.x = lerp(MAX_ROTATION_UP, -MAX_ROTATION_DOWN, percent_from_center.y)
	rotation.x = ease_camera(percent_from_center.y, MAX_ROTATION_UP, -MAX_ROTATION_DOWN, 0.2)



func ease_camera(x: float, min_value: float, max_value: float, intensity: float) -> float:
	assert(x >= 0.0 and x <= 1.0)
	# see https://www.desmos.com/calculator/fpg0lbelf2
	return 1/atan(intensity) * (max_value - min_value) / 2 * atan(2 * intensity * (x-0.5)) + (max_value + min_value) / 2
	
