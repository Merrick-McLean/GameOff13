extends Node2D

@onready var timer = $Timer
@onready var dissolve_texture = preload("res://shaders/dissolve_texture.png")

var is_dissolving = false
var sprites
var cur_sprite = 0
var dissolve_value = 1.0
var dissolve_speed = 0.5

func _ready() -> void:
	sprites = [$slide1, $slide2, $slide3, $slide4]
	for sprite in sprites:
		sprite.visible = true
		
	timer.start()
	
	pass 
	
func _on_timer_timeout() -> void:  
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://shaders/dissolve.gdshader")
	dissolve_value = 1.0
	shader_material.set_shader_parameter("dissolve_texture", dissolve_texture) 
	sprites[cur_sprite].material.set_shader_parameter("dissolve_value", dissolve_value)
	sprites[cur_sprite].material = shader_material
	
	is_dissolving = true


func _process(delta: float) -> void:
	if is_dissolving:
		dissolve_value -= dissolve_speed * delta
		print(dissolve_value)
		if sprites[cur_sprite].material is ShaderMaterial:
			sprites[cur_sprite].material.set_shader_parameter("dissolve_value", dissolve_value)
			
		if dissolve_value <= 0:
			dissolve_value = 0.0
			sprites[cur_sprite].visible = false  
			is_dissolving = false
			cur_sprite += 1 # not handling end of index right now - add text, sound, and proper handling once I get shader working
	pass
