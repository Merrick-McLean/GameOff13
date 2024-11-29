extends Node2D

@onready var timer = $Timer

var sprites
var cur_sprite = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprites = [$slide1, $slide2, $slide3, $slide4]
	for i in range(sprites.size()):
		sprites[i].visible = i == 0
	timer.start()
	
	pass 

func _on_timer_timeout() -> void:
	print("yes")
	sprites[cur_sprite].visible = false
	cur_sprite = (cur_sprite + 1) % sprites.size()
	sprites[cur_sprite].visible = true
	# end scene somewhere
	pass 
