extends VBoxContainer

var is_loading := true

func _ready():
	%TextSpeedSlider.value = Settings.text_speed
	%GraphicsSlider.value = Settings.graphics_detail
	%FullscreenCheckBox.button_pressed = Settings.fullscreen
	
	is_loading = false


func _on_text_speed_slider_value_changed(value: float):
	if is_loading:
		return
	
	Settings.text_speed = floor(value)
	Settings.save_settings()


func _on_graphics_slider_value_changed(value: float):
	if is_loading:
		return
	
	Settings.graphics_detail = floor(value)
	Settings.save_settings()


func _on_fullscreen_check_box_toggled(toggled_on: bool):
	Settings.fullscreen = toggled_on
	Settings.save_settings()
