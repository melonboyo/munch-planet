extends Node3D


var catch_looker_scene := preload("res://Looker/Catch/CatchLooker.tscn")
var manage_looker_scene := preload("res://Looker/Manage/ManageLooker.tscn")

var mouse_captured = true
var munchme_getting_caught: Munchme
var current_manage_ui


func _ready():
	GameState.situation = Constants.Situation.Overworld
	Music.play(Music.Track.Overworld)


func _process(delta):
	if GameState.situation != Constants.Situation.Overworld:
		pass

	if (
		Input.is_action_just_pressed("cancel") and 
		GameState.situation == Constants.Situation.Overworld
	):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if (
		Input.is_action_just_pressed("open_manage") and 
		GameState.situation == Constants.Situation.Overworld
	):
		open_manage()
	elif (
		Input.is_action_just_pressed("open_manage") and 
		GameState.situation == Constants.Situation.Manage
	):
		close_manage()


func _unhandled_input(event):
	if (event is InputEventMouseButton 
		and event.get_button_index() == MOUSE_BUTTON_LEFT
		and event.is_pressed() 
		and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED
		and GameState.situation != Constants.Situation.Overworld
	):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_catch_munchme(munchme: Munchme):
	GameState.situation = Constants.Situation.Catch
	munchme_getting_caught = munchme
	
	var catch_ui: Control = catch_looker_scene.instantiate()
	catch_ui.get_node("%CatchScene").munchme_resource = munchme.resource
	catch_ui.get_node("%CatchScene").add_munchme()
	$UI.add_child(catch_ui)


func _on_munchme_finish_catch(win: bool):
	munchme_getting_caught.in_catch_mode = false
	munchme_getting_caught.situation = Constants.Situation.Overworld
	if win:
		GameState.munchmes.append(munchme_getting_caught.resource)
		munchme_getting_caught.queue_free()
	else:
		pass


func open_manage():
	GameState.situation = Constants.Situation.Manage
	var manage_ui: Control = manage_looker_scene.instantiate()
	current_manage_ui = manage_ui.get_node("Looker")
	$UI.add_child(manage_ui)


func close_manage():
	current_manage_ui.close()
