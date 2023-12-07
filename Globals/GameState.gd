extends Node


signal munchme_added(resource: MunchmeResource)
signal situation_changed(new_situation: Constants.Situation)
signal munchme_deployed(resource: MunchmeResource)

var situation: Constants.Situation = Constants.Situation.Overworld:
	set(new_situation):
		situation = new_situation
		situation_changed.emit(new_situation)
		if situation == Constants.Situation.Overworld:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
var munchmes: Array[MunchmeResource] = []
var control_player = true
var deployed_munchme: Munchme:
	set(value):
		deployed_munchme = value
		control_player = false
var deployed_munchme_camera: Node3D


func change_sitation_to(new_situation: Constants.Situation):
	situation = new_situation


func add_munchme(resource: MunchmeResource):
	munchme_added.emit(resource)
	munchmes.append(resource)


func _process(delta):
	if deployed_munchme == null:
		return
	
	if Input.is_action_just_pressed("switch"):
		control_player = not control_player
