@tool
extends Control

func _enter_tree():
	reparent_guy()

func reparent_guy():
	for child in get_children():
		if child.name == "Guy":
			if Engine.is_editor_hint():
				$MoveTo.add_child(child.duplicate())
			else:
				child.reparent($MoveTo)
				child.set_owner($MoveTo)
			
			return true
	
	return false

func _get_configuration_warnings():
	if not reparent_guy():
		return ["No Guy"]
