extends Node

signal texture_changed

var texture : ImageTexture :
	set(new_value):
		var old_texture := texture
		texture = new_value
		texture_changed.emit(old_texture, texture)

var color_0 := Color.RED :
	set(new_value):
		color_0 = new_value
		is_texture_update_queued = true
var color_1 := Color.RED :
	set(new_value):
		color_1 = new_value
		is_texture_update_queued = true
var color_2 := Color.RED :
	set(new_value):
		color_2 = new_value
		is_texture_update_queued = true
var color_3 := Color.RED :
	set(new_value):
		color_3 = new_value
		is_texture_update_queued = true


var is_texture_update_queued := false

func _ready() -> void:
	_update_texture()

func _process(delta: float) -> void:
	if is_texture_update_queued:
		_update_texture()


func _update_texture() -> void:
	is_texture_update_queued = false
	var image := Image.create_empty(4, 1, false, Image.FORMAT_RGB8)
	image.set_pixel(0, 0, color_0)
	image.set_pixel(1, 0, color_1)
	image.set_pixel(2, 0, color_2)
	image.set_pixel(3, 0, color_3)
	texture = ImageTexture.create_from_image(image)
