extends Node

const SETTINGS_FILE_PATH := "user://settings.cfg"

signal changed

@export_group("General")
@export_range(0, 2) var text_speed := Constants.TextSpeed.Normal:
	set(value): text_speed = clampi(value, 0, Constants.TextSpeed.size())
@export_range(0, 2) var graphics_detail := Constants.Graphics.High:
	set(value): graphics_detail = clampi(value, 0, Constants.Graphics.size())

@export_group("Audio")
@export_range(0, 9) var master_volume: float = 5:
	set(value): master_volume = clampi(value, 0, 9)
@export_range(0, 9) var music_volume: float = 7:
	set(value): music_volume = clampi(value, 0, 9)
@export_range(0, 9) var effects_volume: float = 8:
	set(value): effects_volume = clampi(value, 0, 9)


func _ready():
	changed.connect(update_audio_buses)
	load_settings()


func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE_PATH)
	if err != OK:
		return
	
	text_speed = config.get_value("General", "text_speed", text_speed)
	graphics_detail = config.get_value("General", "graphics_detail", graphics_detail)

	master_volume = config.get_value("Audio", "master_volume", master_volume)
	music_volume = config.get_value("Audio", "music_volume", music_volume)
	effects_volume = config.get_value("Audio", "effects_volume", effects_volume)
	
	changed.emit()


func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("General", "text_speed", text_speed)
	config.set_value("General", "graphics_detail", graphics_detail)
	
	config.set_value("Audio", "master_volume", master_volume)
	config.set_value("Audio", "music_volume", music_volume)
	config.set_value("Audio", "effects_volume", effects_volume)

	config.save(SETTINGS_FILE_PATH)
	changed.emit()


func update_audio_buses():
	_set_bus_level("Master", master_volume)
	_set_bus_level("Music", music_volume)
	_set_bus_level("Effects", effects_volume)


func _set_bus_level(bus: String, level: int):
	var bus_index = AudioServer.get_bus_index(bus)
	
	# Mute the bus if the audio level is 0
	AudioServer.set_bus_mute(bus_index, level == 0)
	
	# Set the dB based on cool algorithm (pow 2 lol)
	var base_level = (9.0 - float(level))
	var multiplier = base_level * 0.8
	AudioServer.set_bus_volume_db(bus_index, base_level * -multiplier)
