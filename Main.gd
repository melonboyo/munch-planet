extends Node3D
class_name Main


@export var skip_rocket_cutscene := false


var catch_looker_scene := preload("res://Looker/Catch/CatchLooker.tscn")
var manage_looker_scene := preload("res://Looker/Manage/ManageLooker.tscn")
var deploy_looker_scene := preload("res://Looker/Deploy/DeployLooker.tscn")
var settings_looker_scene := preload("res://Looker/Settings/SettingsLooker.tscn")
var guild_interior_looker_scene := preload("res://Looker/Interior/InteriorLooker.tscn")

var mouse_captured = true
var munchme_getting_caught: Munchme
var current_manage_ui = null
var manage_allowed = true

var tutorial_music: TutorialMusic


func _ready():
	GameState.main_window = $UI
	planet_specific_ready()


func planet_specific_ready():
	if not GameState.tutorial_cleared:
		GameState.tutorial_stage = Constants.TutorialStage.Landed
		
		tutorial_music = TutorialMusic.new()
		add_child(tutorial_music)
		tutorial_music.play(GameState.tutorial_stage)

	%OverlayAnimation.play("fade_in")
	if not skip_rocket_cutscene:
		$RocketReturnCutscene.play()
		%Muncher.player_controlled = false
	else:
		play_overworld_music()
		%Muncher.player_controlled = true
	
	GameState.water_height = 100.35
	GameState.during_intro = false
	GameState.exit_guild_looker.connect(_on_exit_guild_looker)
	
	GameState.situation = Constants.Situation.Overworld
	GameState.munchme_deployed.connect(_on_munchme_deployed)


func play_overworld_music():
	Music.play(Music.Track.Overworld)


func go_to_tutorial_stage(stage: Constants.TutorialStage):
	if GameState.tutorial_active:
		GameState.tutorial_stage = stage
		if tutorial_music != null:
			tutorial_music.go_to(GameState.tutorial_stage)


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
		go_to_tutorial_stage(GameState.tutorial_stage + 1)
	
	if not CutsceneManager.is_cutscene_playing and Input.is_action_just_pressed("settings"):
		open_settings()
	
	if GameState.situation != Constants.Situation.Overworld:
		pass
	
	if (
		Input.is_action_just_pressed("open_manage") and 
		not CutsceneManager.is_cutscene_playing and
		manage_allowed and
		current_manage_ui == null
	):
		open_manage()
	elif (
		Input.is_action_just_pressed("open_manage") and 
		current_manage_ui != null
	):
		close_manage()


func open_settings():
	for child in $UI.get_children():
		if child.name == "SettingsLooker":
			child.close()
			return
	
	var settings_looker = settings_looker_scene.instantiate()
	$UI.add_child(settings_looker)


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


func retrieve_munchme():
	pass


func _on_munchme_deployed(resource):
	var spawn_pos = %Muncher.global_position + %Muncher.global_basis.z * 2.5
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
	munchme.player_controlled = true
	munchme.is_inside = false
	#GameState.deployed_munchme = munchme
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameState.deploy_munchme(deploy_ui, munchme)
	$Player.add_child(munchme)
	$UI.add_child(deploy_ui)


func _on_ui_focus_entered():
	GameState.change_focus_to($UI)


func _on_ui_focus_exited():
	pass


func remove_black_bars():
	%OverlayAnimation.play("remove_bars")


func add_black_bars():
	%OverlayAnimation.play("add_bars")


func _on_cutscene_animation_finished(anim_name):
	if anim_name == "Rocket_Return_1":
		#if not GameState.tutorial_cleared:
			#$TutorialStartCutscene.play()
		pass


func _on_tutorial_area_body_entered(body):
	$ReturnToTutorialCutscene.play()


func force_player_to_center():
	var point = %Muncher.global_position + ($FollowPoints/Center.global_position \
		- %Muncher.global_position).normalized() * 10.0
	%Muncher.set_follow_points([point] as Array[Vector3])


func _on_enter_guild_area_entered(body):
	%OverlayAnimation.play("fade_out")
	%Muncher.player_controlled = false
	$MainCamera.enable = false
	manage_allowed = false
	open_guild_interior_looker()


func open_guild_interior_looker():
	go_to_tutorial_stage(Constants.TutorialStage.GuildEntered)
	var interior_ui: Looker = guild_interior_looker_scene.instantiate()
	$UI.add_child(interior_ui)


func _on_exit_guild_looker():
	walk_out_after_guild_exit()
	
	await get_tree().create_timer(0.16).timeout
	%OverlayAnimation.play("fade_in")
	await get_tree().create_timer(0.6).timeout
	%Muncher.player_controlled = true
	$MainCamera.enable = true
	manage_allowed = true
	
	if GameState.tutorial_active:
		go_to_tutorial_stage(Constants.TutorialStage.GuildExited)
		$TutorialArea/TutorialProgressCollision.disabled = true
		$TutorialWalkToMunchmeCutscene.play()


func walk_out_after_guild_exit():
	%Muncher.set_follow_point($FollowPoints/GuildFront)


func torpejo_walk_to_first_munchme():
	var points: Array[Node] = $TutorialTorpejoPoints/FollowPoints.get_children()
	%Torpejo.set_follow_points(points)


func _on_torpejo_area_body_entered(body):
	if GameState.tutorial_stage == Constants.TutorialStage.GuildExited:
		%Torpejo.is_talkable = true


func _on_torpejo_torpejo_talked_to():
	if GameState.tutorial_stage == Constants.TutorialStage.GuildExited:
		%Muncher.player_controlled = false
		$TutorialMeetDipshitCutscene.play()
