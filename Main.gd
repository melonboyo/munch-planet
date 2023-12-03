extends Node3D


var catch_looker_scene := preload("res://Looker/Catch/CatchLooker.tscn")
var manage_looker_scene := preload("res://Looker/Manage/ManageLooker.tscn")

var mouse_captured = true
var munchme_getting_caught: Munchme


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Music.play(Music.Track.Overworld)


func _process(delta):
	if GameState.situation != Constants.Situation.Overworld:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	
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
		and GameState.situation != Constants.Situation.Overworld
	):
		mouse_captured = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_catch_munchme(munchme: Munchme):
	GameState.situation = Constants.Situation.Catch
	munchme_getting_caught = munchme
	
	var catch_ui: Control = catch_looker_scene.instantiate()
	catch_ui.get_node("%CatchScene").munchme_resource = munchme.resource
	catch_ui.get_node("%CatchScene").add_munchme()
	$UI.add_child(catch_ui)


func _on_munchme_finish_catch(win: bool):
	GameState.situation = Constants.Situation.Overworld
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	munchme_getting_caught.in_catch_mode = false
	munchme_getting_caught.situation = Constants.Situation.Overworld
	if win:
		munchme_getting_caught.queue_free()
