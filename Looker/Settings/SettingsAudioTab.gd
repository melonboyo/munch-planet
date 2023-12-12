extends VBoxContainer

var effect_demo_agaga = preload("res://SFX/obviously_another_agagaga_sample.ogg")
var effect_demo_agaga_finisher = preload("res://SFX/the_end_of_an_obvious_agaga.ogg")

var is_loading := true
var is_dragging_effects := false

func _ready():
	%MasterVolumeSlider.value = Settings.master_volume
	%MusicVolumeSlider.value = Settings.music_volume
	%EffectsVolumeSlider.value = Settings.effects_volume
	
	is_loading = false


func _on_master_volume_slider_value_changed(value: float):
	if is_loading:
		return
	
	Settings.master_volume = floor(value)
	Settings.save_settings()


func _on_music_volume_slider_value_changed(value: float):
	if is_loading:
		return
	
	Settings.music_volume = floor(value)
	Settings.save_settings()


func _on_effects_volume_slider_value_changed(value: float):
	if is_loading:
		return
	
	Settings.effects_volume = floor(value)
	Settings.save_settings()
	print("changed settings")
	
	if is_dragging_effects and (not %EffectsPlayer.playing or %EffectsPlayer.stream != effect_demo_agaga):
		%EffectsPlayer.stream = effect_demo_agaga
		%EffectsPlayer.play()


func _on_effects_volume_slider_drag_ended(value_changed: bool):
	%EffectsPlayer.stream = effect_demo_agaga_finisher
	%EffectsPlayer.play()
	is_dragging_effects = false


func _on_effects_volume_slider_drag_started():
	is_dragging_effects = true
