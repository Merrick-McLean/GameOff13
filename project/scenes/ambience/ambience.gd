@tool

class_name Ambience
extends Node




@export var is_creaking_wood_playing := false :
	set(new_value):
		is_creaking_wood_playing = new_value
		$ShipWood.playing = is_creaking_wood_playing

@export var is_hum_playing := false :
	set(new_value):
		is_hum_playing = new_value
		$Hum.playing = is_creaking_wood_playing

@export var is_inside := false :
	set(new_value):
		is_inside = new_value
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Outside"), 0, is_inside)
		$JungleNight.is_playing = not is_inside

@export var is_enabled := false :
	set(new_value):
		is_enabled = new_value
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Ambience"), not is_enabled)


func _ready() -> void:
	GameMaster.ambience = self
	is_inside = false
	$Waves.play()
	$Storm.play()
