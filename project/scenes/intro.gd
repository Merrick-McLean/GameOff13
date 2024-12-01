extends Node2D

signal finished

var is_dissolving := false
var dissolve_speed := 0.6
var slide_index := 0 :
	set(new_value):
		slide_index = clamp(new_value, 0, slides.size() - 1)
@export var is_active := true :
	set(new_value):
		is_active = new_value
		if is_active:
			visible = true
			camera.enabled = is_active
		if not is_node_ready(): await ready
		GameMaster.player_in_world = not is_active
		

@onready var storm := $Storm1
@onready var hum := $hum
@onready var dissolve_sound := $DissolveSound
@onready var camera := $Camera2D

@onready var slides : Array[IntroSlide] = [$Start, $Slide1, $Slide2, $Slide3, $Slide4]



func _ready() -> void:
	is_active = is_active
	for slide: IntroSlide in slides:
		slide.visible = true
		slides[slide_index].dissolve_percent = 1.0
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	pass 
	
func dissolve() -> void:  
	if slide_index == slides.size() - 1:
		is_active = false
	dissolve_sound.play()
	is_dissolving = true
	
	
func _process(delta: float) -> void:
	
	if ready_for_next_dissolve():
		if Input.is_action_just_pressed("interact") and is_active:
			dissolve()
	
	if is_dissolving:
		get_current_slide().dissolve_percent  -= dissolve_speed * delta
		
		if get_current_slide().dissolve_percent <= 0.0:
			slides[slide_index].visible = false
			is_dissolving = false
			slide_index += 1
			if not is_active:
				visible = false
				camera.enabled = false
				Dialogue.play(DialogueInstance.Id.INTRO_DIALOGUE)
				finished.emit()


func get_current_slide() -> IntroSlide:
	return slides[slide_index]



func ready_for_next_dissolve() -> bool:
	return not is_dissolving and not dissolve_sound.playing
