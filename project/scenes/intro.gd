extends Node2D

#@onready var timer = $Timer
@onready var start_texture = preload("res://shaders/noise/start.tres")
@onready var slide1_texture = preload("res://shaders/noise/slide1.tres")
@onready var slide2_texture = preload("res://shaders/noise/slide2.tres")
@onready var slide3_texture = preload("res://shaders/noise/slide3.tres")
@onready var slide4_texture = preload("res://shaders/noise/slide4.tres")

#@onready var waves := $Waves1
@onready var squeek := $ShipWood 	# emerges on slide 3
@onready var waves := $BeachWaves1 # muffle by on slide 4 and in game
@onready var night := $JungleNight 	# kill on slide 4 and into game
@onready var storm := $Storm1
@onready var hum := $hum



var texture_arr = [start_texture, slide1_texture, slide2_texture, slide3_texture, slide4_texture]

var is_dissolving = false
var sprites
var cur_sprite = 0
var dissolve_value = 1.0
var dissolve_speed = 0.6

func _ready() -> void:
	sprites = [$start, $slide1, $slide2, $slide3, $slide4]
	for sprite in sprites:
		sprite.visible = true	
	
	waves.play() 
	storm.play()
	night.play()
	
	pass 
	
func dissolve() -> void:  
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://shaders/dissolve.gdshader")
	dissolve_value = 1.0
	match cur_sprite: # array doesnt work for pointing to these on ready textures
		0:
			shader_material.set_shader_parameter("dissolve_texture", start_texture)
		1:
			shader_material.set_shader_parameter("dissolve_texture", slide1_texture)
		2:
			shader_material.set_shader_parameter("dissolve_texture", slide2_texture)
			squeek.play()
		3:
			shader_material.set_shader_parameter("dissolve_texture", slide3_texture)
			night.stop()
		4:
			shader_material.set_shader_parameter("dissolve_texture", slide4_texture)
		
	sprites[cur_sprite].material.set_shader_parameter("dissolve_value", dissolve_value)
	sprites[cur_sprite].material = shader_material
	
	is_dissolving = true
	
func _input(event: InputEvent) -> void:
	if not is_dissolving and (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		print("dissolve")
		dissolve()
	
func _process(delta: float) -> void:
	if is_dissolving:
		dissolve_value -= dissolve_speed * delta
		if sprites[cur_sprite].material is ShaderMaterial:
			sprites[cur_sprite].material.set_shader_parameter("dissolve_value", dissolve_value)
			
		if dissolve_value <= -0.5:
			dissolve_value = 0.0
			sprites[cur_sprite].visible = false
			#await get_tree().create_timer(1.0).timeout no need, not good for input - extend time to dissolve, post 0
			sprites[cur_sprite].set_material(null)
			is_dissolving = false
			if cur_sprite < 4:
				cur_sprite += 1 # not handling end of index right now - add text, sound, and proper handling once I get shader working
			#else:
				# Configure this stuff into game scene so that the final dissolve opens into the 3d game
		pass


func _on_waves_1_ready() -> void:
	#$Waves1.play()
	# muffle starting slide 4
	pass # Replace with function body.


func _on_jungle_night_ready() -> void:
	$JungleNight.play()
	pass # Replace with function body.

# while loop repeating infite drone which randomly changes pitch - easy function if I get audio implimentation


func _on_storm_1_ready() -> void:
	$Storm1.play()
	pass # Replace with function body.
