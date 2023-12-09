extends Control


signal punched

var texture_fist = preload("res://Sprites/punch_minigame/fist.png")
var texture_fist_punch = preload("res://Sprites/punch_minigame/fist_punch.png")

var previous_mouse_mode: Input.MouseMode


func _process(delta):
	$Fist.position = get_global_mouse_position() - $Fist.pivot_offset


func _on_punch_area_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				punched.emit()
				$Fist.texture = texture_fist_punch
			else:
				$Fist.texture = texture_fist


func enable():
	#previous_mouse_mode = Input.mouse_mode
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$Fist.visible = true
	%PunchArea.mouse_filter = MOUSE_FILTER_STOP


func disable():
	#Input.mouse_mode = previous_mouse_mode
	$Fist.visible = false
	%PunchArea.mouse_filter = MOUSE_FILTER_IGNORE


func play_animation(animation_name: String):
	$Animation.play(animation_name)
	
