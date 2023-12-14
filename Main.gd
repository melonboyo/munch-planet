extends Node3D
class_name Main


@export var skip_rocket_cutscene := false
@export var tutorial_stage: Constants.TutorialStage = Constants.TutorialStage.NotStarted


var catch_looker_scene := preload("res://Looker/Catch/CatchLooker.tscn")
var manage_looker_scene := preload("res://Looker/Manage/ManageLooker.tscn")
var deploy_looker_scene := preload("res://Looker/Deploy/DeployLooker.tscn")
var settings_looker_scene := preload("res://Looker/Settings/SettingsLooker.tscn")
var guild_interior_looker_scene := preload("res://Looker/Interior/InteriorLooker.tscn")

var mouse_captured = true
var munchme_getting_caught: Munchme
var current_manage_ui = null
var manage_allowed = true:
	set(value):
		manage_allowed = value
		if not manage_allowed and current_manage_ui != null:
			close_manage()

var tutorial_music: TutorialMusic
@onready var dipshit_id: int = %Dipshit.resource.id


func _ready():
	GameState.tutorial_stage = tutorial_stage
	GameState.main_window = $UI
	GameState.attempt_catch_munchme.connect(_on_attempt_catch_munchme)
	planet_specific_ready()


func planet_specific_ready():
	if not GameState.tutorial_cleared:
		GameState.tutorial_active = true
		
		tutorial_music = TutorialMusic.new()
		tutorial_music.finale.connect(_on_finale_music)
		add_child(tutorial_music)
		go_to_tutorial_stage(tutorial_stage)
		ready_tutorial_stage(GameState.tutorial_stage)

	%OverlayAnimation.play("fade_in")
	
	if not skip_rocket_cutscene and tutorial_stage == Constants.TutorialStage.NotStarted:
		%RocketReturnCutscene.play()
		%Muncher.player_controlled = false
	else:
		if GameState.tutorial_cleared:
			play_overworld_music()
	
	GameState.water_height = 100.35
	GameState.during_intro = false
	GameState.exit_guild_looker.connect(_on_exit_guild_looker)
	
	GameState.situation = Constants.Situation.Overworld
	GameState.munchme_deployed.connect(_on_munchme_deployed)
	GameState.munchme_added.connect(_on_munchme_added)


func set_invis_wall_active(munchme: bool, player: bool):
	#var value = pow(2, 2-1) if player else 0
	#if munchme:
		#value += pow(2, 4-1)
	var value = 0
	if munchme or player:
		value = 1
	#if not munchme:
		#$TutorialInvisWall/C4.disabled = true
	#else:
		#$TutorialInvisWall/C4.disabled = false
		
	$TutorialInvisWall.collision_layer = value


func get_point_on_surface(node: Node3D) -> Vector3:
	return Math.position_to_position_on_surface(node.global_position, node.global_position, self)


func ready_tutorial_stage(stage: Constants.TutorialStage):
	%Muncher.visible = true
	%Muncher.player_controlled = true
	%Torpejo.visible = true
	%Dipshit.freeze = false
	%Dipshit.visible = false
	set_invis_wall_active(false, false)
	manage_allowed = true
	if stage == Constants.TutorialStage.NotStarted:
		%Muncher.player_controlled = false
		%Muncher.visible = false
		%Torpejo.visible = false
		%Dipshit.freeze = true
	if stage == Constants.TutorialStage.Landed:
		%Torpejo.visible = false
		%Dipshit.freeze = true
	elif stage == Constants.TutorialStage.GuildEntered:
		%Muncher.global_position = get_point_on_surface(%EnterGuildArea)
		%Torpejo.visible = false
		%Dipshit.freeze = true
	elif stage == Constants.TutorialStage.GuildExited:
		%Muncher.global_position = get_point_on_surface($FollowPoints/GuildFront)
		%Dipshit.freeze = true
		$TutorialArea/TutorialProgressCollision.disabled = true
		%TutorialWalkToMunchmeCutscene.play()
	elif stage == Constants.TutorialStage.Catching:
		%Dipshit.visible = true
		$TutorialArea/TutorialProgressCollision.disabled = true
		%Dipshit.global_position = get_point_on_surface($TutorialTorpejoPoints/DipshitWaitingPoints/Follow2)
		%Muncher.global_position = get_point_on_surface($TutorialTorpejoPoints/AfterCatchMuncherPoint)
		%Torpejo.global_position = get_point_on_surface($TutorialTorpejoPoints/CatchMunchmePoint)
		set_invis_wall_active(true, true)
		manage_allowed = false
	elif stage == Constants.TutorialStage.Caught:
		$TutorialArea/TutorialProgressCollision.disabled = true
		set_invis_wall_active(true, true)
		%Dipshit.queue_free()
		%Muncher.global_position = get_point_on_surface($TutorialTorpejoPoints/DipshitWaitingPoints/Follow2)
		%Torpejo.global_position = get_point_on_surface($TutorialTorpejoPoints/CatchMunchmePoint)
		manage_allowed = false
		%Muncher.player_controlled = false
		%Torpejo.visible = true
		add_munchme_to_inventory(Constants.Munchme.Dipshit)
		%TutorialDeployCutscene.play()
	elif stage == Constants.TutorialStage.Deploying:
		set_invis_wall_active(false, true)
		%Muncher.player_controlled = false
		$TutorialArea/TutorialProgressCollision.disabled = true
	elif stage == Constants.TutorialStage.Kidnapped:
		set_invis_wall_active(false, true)
		$TutorialArea/TutorialProgressCollision.disabled = true
	elif stage == Constants.TutorialStage.Finished:
		set_invis_wall_active(false, false)
		$TutorialArea2.monitoring = false
		$TutorialArea.monitoring = false
	else:
		%Muncher.player_controlled = true
		$TutorialArea2.monitoring = false
		$TutorialArea.monitoring = false


func add_munchme_to_inventory(type: Constants.Munchme):
	var resource = MunchmeResource.new()
	resource.resource_local_to_scene = true
	resource.munchme_type = type
	resource.id = randi()
	GameState.add_munchme(resource)


func play_tutorial_music():
	tutorial_music.play(GameState.tutorial_stage)


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
		var resource_dip = MunchmeResource.new()
		resource_dip.resource_local_to_scene = true
		resource_dip.munchme_type = Constants.Munchme.Dipshit
		GameState.add_munchme(resource_dip)
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


func _on_attempt_catch_munchme(munchme: Munchme):
	GameState.situation = Constants.Situation.Catch
	manage_allowed = false
	munchme_getting_caught = munchme
	
	var catch_ui: Control = catch_looker_scene.instantiate()
	catch_ui.get_node("%CatchScene").munchme_resource = munchme.resource
	catch_ui.get_node("%CatchScene").add_munchme()
	$UI.add_child(catch_ui)


func _on_munchme_finish_catch(win: bool):
	munchme_getting_caught.in_catch_mode = false
	manage_allowed = true
	munchme_getting_caught.situation = Constants.Situation.Overworld
	if win:
		GameState.add_munchme(munchme_getting_caught.resource)
		munchme_getting_caught.queue_free()
		if GameState.tutorial_stage == Constants.TutorialStage.Catching:
			go_to_tutorial_stage(Constants.TutorialStage.Caught)
			%TutorialDeployCutscene.play()
	else:
		pass


var tut_dep_2_scene_played = false

func open_manage():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var manage_ui: Control = manage_looker_scene.instantiate()
	if GameState.tutorial_stage == Constants.TutorialStage.Caught and not tut_dep_2_scene_played:
		manage_ui.can_close = false
	current_manage_ui = manage_ui
	$UI.add_child(manage_ui)
	
	if GameState.tutorial_stage == Constants.TutorialStage.Caught and not tut_dep_2_scene_played:
		tut_dep_2_scene_played = true
		await get_tree().create_timer(0.6).timeout
		%TutorialDeployCutscene2.play()


func close_manage():
	if current_manage_ui != null:
		current_manage_ui.close()


func retrieve_all_munchmes():
	for m in GameState.deployed_munchmes:
		GameState.retrieve_munchme_from_munchme(m)


func get_ray_position(origin: Vector3, dir: Vector3, length: float = 4.0) -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var ray_end = origin + dir * length
	var ray_query = PhysicsRayQueryParameters3D.create(
		origin, ray_end, pow(2, 1-1)
	)
	ray_query.hit_back_faces = false
	ray_query.hit_from_inside = true
	var result = space_state.intersect_ray(ray_query)
	if !result:
		return ray_end
	return result.position


func _on_munchme_deployed(resource):
	var spawn_pos: Vector3 = get_ray_position(%Muncher.global_position, %Muncher.global_transform.basis.z)
	#spawn_pos = spawn_pos.rotated(Vector3.RIGHT, rotation.x).rotated(Vector3.UP, rotation.y).rotated(Vector3.FORWARD, rotation.z)
	
	if GameState.tutorial_stage == Constants.TutorialStage.Deploying:
		spawn_pos = $TutorialTorpejoPoints/CagePoint.global_position
	
	spawn_pos = Math.position_to_position_on_surface(
		spawn_pos, spawn_pos.normalized(), %Muncher
	) + spawn_pos.normalized() * 1.2
	
	deploy_munchme(resource, spawn_pos)
	if GameState.tutorial_stage == Constants.TutorialStage.Caught:
		go_to_tutorial_stage(Constants.TutorialStage.Deploying)
		%TutorialDeployCutscene3.play()
	elif GameState.tutorial_stage == Constants.TutorialStage.Deploying:
		%TutorialKidnappedCutscene.play()
		%Muncher.player_controlled = false
	
	close_manage()


func deploy_munchme(munchme_resource: MunchmeResource, pos: Vector3):
	var deploy_ui: Looker = deploy_looker_scene.instantiate()
	deploy_ui.music_track = munchme_resource.roam_track
	
	var munchme: Munchme = Scenes.munchmes[munchme_resource.munchme_type].instantiate()
	munchme.resource = munchme_resource
	munchme.name = StringName(munchme_resource.name)
	munchme.situation = Constants.Situation.Interact
	munchme.global_position = pos
	munchme.camera = deploy_ui.get_node("%DeployScene").get_camera()
	munchme.player_controlled = true
	munchme.is_inside = false
	munchme.unique_name_in_owner = true
	#GameState.deployed_munchme = munchme
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if GameState.tutorial_stage == Constants.TutorialStage.Caught:
		deploy_ui.can_close = false
	elif GameState.tutorial_stage == Constants.TutorialStage.Deploying:
		deploy_ui.can_close = false
		deploy_ui.spawn_centered = false
		munchme.player_controlled = false
	
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
			#%TutorialStartCutscene.play()
		pass


func _on_tutorial_area_body_entered(body):
	$TutorialPlayer.play("ForcePlayerToCenter")


func force_player_to_center():
	var point = %Muncher.global_position + ($FollowPoints/Center.global_position \
		- %Muncher.global_position).normalized() * 10.0
	%Muncher.set_vector_follow_point(point)


func force_player_to_catch_center():
	var point = %Muncher.global_position + (%CatchCenter.global_position \
		- %Muncher.global_position).normalized() * 10.0
	%Muncher.set_vector_follow_point(point)


func force_dipshit_to_catch_center():
	var point = %Dipshit.global_position + (%CatchCenter.global_position \
		- %Dipshit.global_position).normalized() * 10.0
	%Dipshit.set_vector_follow_point(point)


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
		%TutorialWalkToMunchmeCutscene.play()


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
		$MainCamera.enable = false
		set_invis_wall_active(true, true)
		%TutorialMeetDipshitCutscene.play()
		#$TutorialArea2.monitoring = true


func rotate_torpejo_towards_camera():
	%Torpejo.rotate_towards($TutorialTorpejoPoints/CatchMunchmePoint/DipshitCamera1.global_position)


func rotate_torpejo_towards_dipshit():
	%Torpejo.rotate_towards(%Dipshit.global_position)


func rotate_player_towards_dipshit():
	%Muncher.rotate_towards(%Dipshit.global_position)


func dipshit_walk_downhill():
	%Dipshit.set_follow_points($TutorialTorpejoPoints/DipshitWaitingPoints.get_children())


func torpejo_turn_to_player():
	%Torpejo.rotate_towards(%Muncher.global_position)


func move_dipshit_camera_down():
	%DipshitCameraAnimation.play("pan_down")


func _on_cutscene_animation_animation_finished(anim_name):
	if anim_name == "End_Catch_Tut":
		%Muncher.player_controlled = true
		$MainCamera.enable = true
		go_to_tutorial_stage(Constants.TutorialStage.Catching)
	if anim_name == "End_Deploy_Tut":
		%TutorialCageCutscene.play()
	if anim_name == "Test_Dipshit_3":
		manage_allowed = true
		set_invis_wall_active(false, true)
	if anim_name == "Open_Manage":
		manage_allowed = true
	if anim_name == "Teach_Deploy":
		#$TutorialArea2.monitoring = true
		pass
	if anim_name == "Capture_Dipshit":
		%Muncher.player_controlled = true
		if not GameState.deployed_munchmes.is_empty():
			GameState.deployed_munchmes[0]
		manage_allowed = false
	if anim_name == "Begin_Escape":
		go_to_tutorial_stage(Constants.TutorialStage.Kidnapped)
	if anim_name == "End_Tutorial":
		set_invis_wall_active(false, false)


func return_to_torpejo():
	%Muncher.set_follow_point($TutorialTorpejoPoints/AfterCatchMuncherPoint)


func set_deploy_looker_can_close():
	GameState.munchme_windows[0].can_close = true


func _on_munchme_added(resource: MunchmeResource):
	if GameState.tutorial_stage == Constants.TutorialStage.Deploying:
		manage_allowed = false
		%TutorialCageCutscene.play()


func _on_tutorial_area_2_body_entered(body):
	if body is Dipshit:
		$TutorialPlayer.play("ForceDipshitToCatchCenter")
	else:
		$TutorialPlayer.play("ForcePlayerToCatchCenter")


func _on_finale_music():
	$FinaleTimer.start()


func _on_finale_timer_timeout():
	%TutorialFinaleCutscene.play()
