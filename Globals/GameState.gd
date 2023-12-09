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
var deployed_munchmes: Array[Munchme]
var munchme_windows: Array[Control] = []
var active_window: int = -1
var main_window: Control
var focus_main = true
var last_used_id = 10
var open_lookers: Array[Looker] = []
var looker_music_map := {}


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


func add_looker(looker: Looker):
	if looker.looker_z_index > 0:
		# Start a new song if the looker is prioritised
		var highest_looker_z_index = get_highest_looker_z_index()
		if looker.looker_z_index > highest_looker_z_index:
			var previous_track = Music.play(looker.music_track)
			looker_music_map[looker.looker_z_index] = previous_track
	
	open_lookers.push_back(looker)


func remove_looker(looker: Looker):
	open_lookers.erase(looker)
	
	# Return to the previous song if this looker was prioritised
	var highest_looker_z_index = get_highest_looker_z_index()
	if looker.looker_z_index > 0:
		if looker.looker_z_index > highest_looker_z_index:
			var previous_track = looker_music_map[looker.looker_z_index]
			looker_music_map.erase(looker.looker_z_index)
			if previous_track == null:
				Music.stop()
			else:
				Music.play(previous_track.track, previous_track.position)


func get_highest_looker_z_index():
	var highest_z_index := 0
	for looker in open_lookers:
		highest_z_index = max(looker.looker_z_index, highest_z_index)
	return highest_z_index
