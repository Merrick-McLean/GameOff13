extends Node

const DISK_PATH := "user://settings.json"
const SETTINGS : Array[StringName] = [
	&"is_in_fullscreen",
	&"is_fullscreen_exclusive",
	&"is_window_maximized",
	&"is_music_muted",
	&"are_sfx_muted",
	&"is_debug_enabled",
]

var is_save_to_disk_queued := false

#region Settings

var is_in_fullscreen := false : 
	set(new_value):
		if is_in_fullscreen == new_value: return
		is_in_fullscreen = new_value
		_update_window()

var is_fullscreen_exclusive := true :
	set(new_value):
		if is_fullscreen_exclusive == new_value: return
		is_fullscreen_exclusive = is_fullscreen_exclusive
		_update_window()

var is_window_maximized := false :
	set(new_value):
		if is_window_maximized == new_value: return
		is_window_maximized = new_value
		_update_window()

var is_music_muted := false :
	set(new_value):
		is_music_muted = new_value
		AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Music"), is_music_muted)
		queue_save_to_disk()

var are_sfx_muted := false :
	set(new_value):
		are_sfx_muted = new_value
		AudioServer.set_bus_mute(AudioServer.get_bus_index(&"SFX"), are_sfx_muted)
		queue_save_to_disk()

var is_debug_enabled := false :
	set(new_value):
		Debug.is_enabled = new_value
		queue_save_to_disk()
	get:
		return Debug.is_enabled

#endregion

func _ready() -> void:
	for setting_name in SETTINGS:
		assert(get(setting_name) != null)
	load_from_disk()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"toggle_fullscreen"):
		is_in_fullscreen = !is_in_fullscreen
	if DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_WINDOWED:
		is_window_maximized = false
	if DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_MAXIMIZED:
		is_window_maximized = true
	if DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		is_in_fullscreen = true
		is_fullscreen_exclusive = true
	if DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_FULLSCREEN:
		is_in_fullscreen = true
		is_fullscreen_exclusive = false
	
	
	if is_save_to_disk_queued:
		save_to_disk()

#region Saving to Disk

func load_from_disk() -> void:
	var settings_on_disk := JSONUtils.load_json(DISK_PATH)
	
	for setting_name: StringName in SETTINGS:
		if setting_name in settings_on_disk:
			set(setting_name, settings_on_disk.get(setting_name))
		else:
			push_warning("Setting value not found on disk for " + setting_name + ". Using default value.")


func queue_save_to_disk() -> void:
	is_save_to_disk_queued = true


func save_to_disk() -> void:
	is_save_to_disk_queued = false
	
	var json := {}
	
	for setting_name: StringName in SETTINGS:
		json[setting_name] = get(setting_name)
	
	var was_successful := JSONUtils.save_json(DISK_PATH, json)
	
	if not was_successful:
		push_warning("Failed to save settings to disk!")

#endregion

func _update_window() -> void:
	queue_save_to_disk()
	if is_in_fullscreen:
		if is_fullscreen_exclusive:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		if is_window_maximized:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
