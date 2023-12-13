extends Node


signal munchme_added(resource: MunchmeResource)
signal situation_changed(new_situation: Constants.Situation)
signal munchme_deployed(resource: MunchmeResource)
signal exit_guild_looker

var situation: Constants.Situation = Constants.Situation.Overworld:
	set(new_situation):
		situation = new_situation
		situation_changed.emit(new_situation)
		if situation == Constants.Situation.Overworld:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
var during_intro = true
var munchmes: Array[MunchmeResource] = []
var deployed_munchmes: Array[Munchme]
var munchme_windows: Array[Control] = []
var active_window: int = -1
var main_window: Control
var focus_main = true
var last_used_id = 10
var open_lookers: Array[Looker] = []
var looker_music_map := {}
var water_height = 0.0
var cursor_sensitivty: float = 0.5
var tutorial_cleared = false
var tutorial_stage := Constants.TutorialStage.NotStarted:
	set(value):
		if value <= tutorial_stage:
			return
		
		tutorial_stage = value
var tutorial_active: bool:
	get:
		return tutorial_stage > Constants.TutorialStage.NotStarted and tutorial_stage < Constants.TutorialStage.Finished
	set(value):
		if tutorial_stage == Constants.TutorialStage.NotStarted:
			tutorial_stage = Constants.TutorialStage.Landed

func _ready():
	var deadzone = ProjectSettings.get_setting("global/control_stick_deadzone")
	InputMap.action_set_deadzone("look_right", deadzone)
	InputMap.action_set_deadzone("look_left", deadzone)
	InputMap.action_set_deadzone("look_up", deadzone)
	InputMap.action_set_deadzone("look_right", deadzone)


func _process(delta):
	if (
		(Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("settings")) and 
		GameState.situation != Constants.Situation.Catch
	):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		var stick_input = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		if Vector2.ZERO.distance_to(stick_input) > 1.0:
			stick_input = stick_input.normalized()
		if Vector2.ZERO.distance_to(stick_input) < ProjectSettings.get_setting("global/control_stick_deadzone") * sqrt(2.0):
			stick_input = Vector2.ZERO
		
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


func change_sitation_to(new_situation: Constants.Situation):
	situation = new_situation


func add_munchme(resource: MunchmeResource):
	resource.id = last_used_id + 1
	last_used_id += 1
	munchme_added.emit(resource)
	munchmes.append(resource)


func deploy_munchme(ui: Looker, munchme: Munchme):
	munchme_windows.append(ui)
	deployed_munchmes.append(munchme)
	active_window = munchme_windows.size() - 1
	
	if munchme_windows.size() > 1:
		munchme_windows[munchme_windows.size() - 2].focus_next = ui.get_path()
	else:
		ui.focus_next = main_window.get_path()
		main_window.focus_next = ui.get_path()


func retrieve_munchme_from_looker(ui: Looker):
	var id = munchme_windows.find(ui)
	retrieve_munchme(id)


func retrieve_munchme_from_munchme(munchme: Munchme):
	var id = deployed_munchmes.find(munchme)
	retrieve_munchme(id)


func retrieve_munchme(id: int):
	if id == -1:
		return
	#munchme_windows.remove_at(id)
	var size = munchme_windows.size()
	if size == 1:
		munchme_added.emit(deployed_munchmes[id].resource)
		deployed_munchmes[id].free()
		munchme_windows.clear()
		deployed_munchmes.clear()
		focus_main = true
		active_window = -1
		return
	if id == 0:
		main_window.focus_next = munchme_windows[id].focus_next
	elif id == size-1:
		munchme_windows[id-1].focus_next = main_window.get_path()
	else:
		munchme_windows[id-1].focus_next = munchme_windows[id].focus_next
	munchme_added.emit(deployed_munchmes[id].resource)
	deployed_munchmes[id].free()
	munchme_windows.remove_at(id)
	deployed_munchmes.remove_at(id)
	focus_main = true
	active_window = -1


func change_focus_to(new_focus: Control):
	var id = munchme_windows.find(new_focus)
	active_window = id
	focus_main = id == -1
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func is_munchme_active(munchme: Munchme) -> bool:
	if active_window == -1:
		return false
	return deployed_munchmes[active_window] == munchme


func is_window_active(window: Control) -> bool:
	if active_window == -1:
		return false
	return munchme_windows[active_window] == window


func is_munchme_deployed(resource: MunchmeResource) -> bool:
	var res = false
	for m in deployed_munchmes:
		if m.resource.id == resource.id:
			res = true
	return res


func play_looker_music(looker: Looker):
	var previous_track = Music.play(looker.music_track)
	looker_music_map[looker.looker_z_index] = previous_track


func add_looker(looker: Looker):
	if looker.looker_z_index > 0:
		var highest_looker_z_index = get_highest_looker_z_index()
		if looker.looker_z_index > highest_looker_z_index:
			# Start a new song if the looker is prioritised
			play_looker_music(looker)
		elif looker.looker_z_index != highest_looker_z_index:
			# Otherwise, steal the higher looker's song
			var closest_looker_z_index = get_looker_z_index_above(looker.looker_z_index)
			var their_previous_track = looker_music_map[closest_looker_z_index]
			looker_music_map[looker.looker_z_index] = their_previous_track
			
			var our_track = PlayingTrack.new()
			our_track.track = looker.music_track
			looker_music_map[closest_looker_z_index] = our_track
	
	open_lookers.push_back(looker)


func remove_looker(looker: Looker):
	open_lookers.erase(looker)
	
	var highest_looker_z_index = get_highest_looker_z_index()
	if looker.looker_z_index > 0:
		if looker.looker_z_index > highest_looker_z_index and looker.looker_z_index in looker_music_map:
			# Return to the previous song if this looker was prioritised
			var previous_track = looker_music_map[looker.looker_z_index]
			looker_music_map.erase(looker.looker_z_index)
			if previous_track == null:
				Music.stop()
			else:
				Music.play(previous_track.track, previous_track.position, false)
		elif looker.looker_z_index != highest_looker_z_index:
			# Otherwise, give them back their song
			var closest_looker_z_index = get_looker_z_index_above(looker.looker_z_index)
			looker_music_map[closest_looker_z_index] = looker_music_map[looker.looker_z_index]
			looker_music_map.erase(looker.looker_z_index)


func get_highest_looker_z_index():
	var highest_z_index := 0
	for looker in open_lookers:
		highest_z_index = max(looker.looker_z_index, highest_z_index)
	return highest_z_index


func get_looker_z_index_above(looker_index: int = 0):
	var closest_looker_z_index := 999999
	for looker in open_lookers:
		if looker.looker_z_index < looker_index:
			continue
		
		if looker.looker_z_index < closest_looker_z_index:
			closest_looker_z_index = looker.looker_z_index

	return closest_looker_z_index

func get_open_looker_with_highest_z_index():
	var highest_looker = null
	for looker in open_lookers:
		if highest_looker == null or looker.looker_z_index > highest_looker.looker_z_index:
			highest_looker = looker
	
	return highest_looker


func move_mouse(relative: Vector2):
	get_viewport().warp_mouse(get_viewport().get_mouse_position() + relative)
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
