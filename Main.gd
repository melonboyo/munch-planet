extends Node3D


@export_range(0.0, 1.0) var look_input_deadzone: float = 0.0
@export_range(0.0, 1.0) var cursor_sensitivty: float = 0.5

var catch_looker_scene := preload("res://Looker/Catch/CatchLooker.tscn")
var manage_looker_scene := preload("res://Looker/Manage/ManageLooker.tscn")
var deploy_looker_scene := preload("res://Looker/Deploy/DeployLooker.tscn")
#var choose_deploy_looker_scene := preload("res://Looker/Deploy/ChooseDeployLooker.tscn")

var mouse_captured = true
var munchme_getting_caught: Munchme
var current_manage_ui = null


func _ready():
	GameState.main_window = $UI
	
	InputMap.action_set_deadzone("look_right", look_input_deadzone)
	InputMap.action_set_deadzone("look_left", look_input_deadzone)
	InputMap.action_set_deadzone("look_up", look_input_deadzone)
	InputMap.action_set_deadzone("look_right", look_input_deadzone)
	
	GameState.situation = Constants.Situation.Overworld
	Music.play(Music.Track.Overworld)
	GameState.munchme_deployed.connect(_on_munchme_deployed)
	
	var points: Array[Vector3] = []
	for p in $FollowPoints.get_children():
		points.append(p.global_position)
	%Goby.set_follow_points(points)


func _process(delta):
	if Input.is_action_just_pressed("cheat"):
		var resource = MunchmeResource.new()
		resource.resource_local_to_scene = true
		GameState.add_munchme(resource)
		$Cutscene.play()
	if GameState.situation != Constants.Situation.Overworld:
		pass
	
	if (
		Input.is_action_just_pressed("cancel") and 
		GameState.situation != Constants.Situation.Catch
	):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
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
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		var stick_input = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		
		var pow_length = pow(stick_input.length(), 5.0) * 0.95 + 0.05
		var speed_mult = 1.0
		var speed_up_strength = Input.get_action_strength("speed_up_cursor")
		if speed_up_strength > 0.9:
			speed_mult = 2.3
		elif speed_up_strength > 0.1:
			speed_mult = 1.4
		speed_mult *= ProjectSettings.get_setting("global/mouse_sensitivity") * 13.0
		stick_input = (pow_length / stick_input.length()) * stick_input * cursor_sensitivty * speed_mult
		if stick_input.length() > 0.0:
			#call_deferred("move_mouse", stick_input)
			move_mouse(stick_input)
		
	if Input.is_action_just_pressed("click"):
		call_deferred("click")
	elif Input.is_action_just_released("click"):
		call_deferred("click_released")


func _unhandled_input(event):
	if (event is InputEventMouseButton 
		and event.get_button_index() == MOUSE_BUTTON_LEFT
		and event.is_pressed() 
		and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED
		and GameState.situation != Constants.Situation.Catch
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


func move_mouse(relative: Vector2):
	get_viewport().warp_mouse(get_viewport().get_mouse_position() + relative - Vector2(-1,-1))
	#var a = InputEventMouseMotion.new()
	#a.relative = relative
	#Input.parse_input_event(a)


func click():
	var a = InputEventMouseButton.new()
	a.position = get_viewport().get_mouse_position() * (get_viewport().size as Vector2 / get_viewport().get_visible_rect().size as Vector2)
	a.button_index = MOUSE_BUTTON_LEFT
	a.pressed = true
	a.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(a)


func click_released():
	var a = InputEventMouseButton.new()
	a.position = get_viewport().get_mouse_position() * (get_viewport().size as Vector2 / get_viewport().get_visible_rect().size as Vector2)
	a.button_index = MOUSE_BUTTON_LEFT
	a.pressed = false
	Input.parse_input_event(a)


func _on_munchme_deployed(resource):
	var spawn_pos = %Muncher.global_position + %Muncher.global_basis.z * 4.0
	deploy_munchme(resource, spawn_pos)
	close_manage()


func deploy_munchme(munchme_resource: MunchmeResource, pos: Vector3):
	var deploy_ui: Control = deploy_looker_scene.instantiate()
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
