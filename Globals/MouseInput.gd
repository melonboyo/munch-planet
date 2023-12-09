extends Node


var invert_look_x = false
var invert_look_y = false

var input = Vector2.ZERO


func _input(event):
	if event is InputEventMouseMotion:
		input = Vector2.ZERO
		if not invert_look_x:
			input.x += event.relative.y * 0.2
		else:
			input.x += -event.relative.y * 0.2
		if not invert_look_y:
			input.y += event.relative.x * 0.2
		else:
			input.y += -event.relative.x * 0.2
		input *= ProjectSettings.get_setting("global/mouse_sensitivity")


func _process(delta):
	#if Input.get_vector("look_right", "look_left", "look_down", "look_up").length() < 0.001:
		#return
	input = Vector2.ZERO
	if not invert_look_x:
		input.y += (Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * 3.0
	else:
		input.y += -(Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * 3.0
	if not invert_look_y:
		input.x += (Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * 3.0
	else:
		input.x += -(Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * 3.0
	input *= ProjectSettings.get_setting("global/mouse_sensitivity")
