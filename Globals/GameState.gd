extends Node


var situation: Constants.Situation = Constants.Situation.Overworld:
	set(new_situation):
		situation = new_situation
		if situation == Constants.Situation.Overworld:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
var munchmes: Array[MunchmeResource] = []


func change_sitation_to(new_situation: Constants.Situation):
	situation = new_situation
