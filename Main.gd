extends Node3D
class_name Main


var catch_looker_scene := preload("res://Looker/Catch/CatchLooker.tscn")
var manage_looker_scene := preload("res://Looker/Manage/ManageLooker.tscn")
var deploy_looker_scene := preload("res://Looker/Deploy/DeployLooker.tscn")

var mouse_captured = true
var munchme_getting_caught: Munchme
var current_manage_ui = null


func _ready():
	GameState.main_window = $UI
	planet_specific_ready()


func planet_specific_ready():
	$RocketReturnCutscene.play()
	$Overlay/OverlayAnimation.play("RESET")
	
	GameState.water_height = 100.35
	GameState.during_intro = false
	
	GameState.situation = Constants.Situation.Overworld
	#Music.play(Music.Track.Overworld)
	GameState.munchme_deployed.connect(_on_munchme_deployed)
	
	var points: Array[Vector3] = []
	for p in $FollowPoints.get_children():
		points.append(p.global_position)
	%Goby.set_follow_points(points)


func _unhandled_input(event):
	if (event is InputEventMouseButton 
		and event.get_button_index() == MOUSE_BUTTON_LEFT
		and event.is_pressed() 
		and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED
		and GameState.situation != Constants.Situation.Catch
		#and not GameState.during_intro
	):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	if Input.is_action_just_pressed("cheat"):
		var resource = MunchmeResource.new()
		resource.resource_local_to_scene = true
		GameState.add_munchme(resource)
		$Cutscene.play()
	if GameState.situation != Constants.Situation.Overworld:
		pass
	
	if (
		Input.is_action_just_pressed("open_manage") and 
		#GameState.situation == Constants.Situation.Overworld and 
		current_manage_ui == null
	):
		open_manage()
	elif (
		Input.is_action_just_pressed("open_manage") and 
		current_manage_ui != null
	):
		close_manage()


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
		GameState.add_munchme(munchme_getting_caught.resource)
		munchme_getting_caught.queue_free()
	else:
		pass


func open_manage():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var manage_ui: Control = manage_looker_scene.instantiate()
	current_manage_ui = manage_ui
	$UI.add_child(manage_ui)


func close_manage():
	current_manage_ui.close()


#func deploy_munchme():
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#var deploy_ui: Control = choose_deploy_looker_scene.instantiate()
	#current_manage_ui = manage_ui.get_node("Looker")
	#$UI.add_child(manage_ui)


func retrieve_munchme():
	pass


func _on_munchme_deployed(resource):
	var spawn_pos = %Muncher.global_position + %Muncher.global_basis.z * 4.0
	spawn_pos = Math.position_to_position_on_surface(spawn_pos, spawn_pos.normalized(), self)
	deploy_munchme(resource, spawn_pos)
	close_manage()


func deploy_munchme(munchme_resource: MunchmeResource, pos: Vector3):
	var deploy_ui: Looker = deploy_looker_scene.instantiate()
	deploy_ui.music_track = munchme_resource.roam_track
	
	var munchme: Munchme = Scenes.munchmes[munchme_resource.munchme_type].instantiate()
	munchme.resource = munchme_resource
	munchme.situation = Constants.Situation.Interact
	munchme.position = pos
	munchme.camera = deploy_ui.get_node("%DeployScene").get_camera()
	#GameState.deployed_munchme = munchme
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameState.deploy_munchme(deploy_ui, munchme)
	$Player.add_child(munchme)
	$UI.add_child(deploy_ui)


func _on_ui_focus_entered():
	GameState.change_focus_to($UI)


func _on_ui_focus_exited():
	pass
