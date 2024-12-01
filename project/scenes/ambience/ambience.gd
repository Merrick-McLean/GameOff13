@tool

class_name Ambience
extends Node




@export var is_creaking_wood_playing := false :
	set(new_value):
		is_creaking_wood_playing = new_value
		if not is_node_ready(): await ready
		$ShipWood.playing = is_creaking_wood_playing

@export var is_hum_playing := false :
	set(new_value):
		is_hum_playing = new_value

@export var hum_loudness : float = 1.0

@export var is_inside := false :
	set(new_value):
		is_inside = new_value
		if not is_node_ready(): await ready
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Outside"), 0, is_inside)
		$JungleNight.playing = not is_inside

@export var is_enabled := false :
	set(new_value):
		is_enabled = new_value
		if not is_node_ready(): await ready
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Ambience"), not is_enabled)


func _ready() -> void:
	if not Engine.is_editor_hint(): GameMaster.ambience = self
	is_enabled = false
	is_inside = false
	$Waves.playing = true
	$Storm.playing = true
	$Hum.playing = true
	$Hum.volume_db = linear_to_db(0.0)


func _process(delta: float) -> void:
	$Hum.volume_db = linear_to_db(lerp(db_to_linear($Hum.volume_db), float(is_hum_playing) * hum_loudness, delta * 1))
