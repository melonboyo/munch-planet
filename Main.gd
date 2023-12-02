extends Node3D


var mouse_captured = true


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Music.play(Music.Track.Overworld)


func _process(delta):
	if Input.is_action_just_pressed("cancel"):
		if mouse_captured:
			mouse_captured = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			mouse_captured = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if (event is InputEventMouseButton 
		and event.get_button_index() == MOUSE_BUTTON_LEFT
		and event.is_pressed() 
		and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE
	):
		mouse_captured = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
