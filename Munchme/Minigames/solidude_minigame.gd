extends Control


signal punched


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			punched.emit()


func play_animation(animation_name: String):
	$Animation.play(animation_name)
