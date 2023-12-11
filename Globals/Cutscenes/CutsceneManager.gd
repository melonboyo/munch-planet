extends Control

@export_range(1, 50) var text_cps = 30
var character_wait_time: float:
	get: return 1.0 / text_cps

signal cutscene_playing
signal cutscene_finished
signal scene_playing
signal scene_finished

var cutscene: Cutscene
var current_scene = 0
var total_scenes: int:
	get: return cutscene.scenes.size() if cutscene != null else 0

var is_cutscene_playing := false
var is_scene_playing := false

# Animations
signal animation_finished
var is_animation_playing := false

var animation_player: AnimationPlayer
var animation_looping := false

# Dialogue
signal dialogue_finished
var is_dialogue_playing := false

var dialogue_text_length := 0
var time_since_character := 0.0


func play_cutscene(gimme_a_cutscene: Cutscene, from_scene: int = 0, from_seconds: float = 0.0):
	cutscene = gimme_a_cutscene
	current_scene = from_scene
	
	_set_animation_player()

	_play_scene(cutscene.scenes[current_scene], from_seconds)
	is_cutscene_playing = true
	cutscene_playing.emit()


func play_next_scene():
	if current_scene < total_scenes - 1:
		current_scene += 1
		_play_scene(cutscene.scenes[current_scene])
	else:
		_end_cutscene()


func skip_waiting():
	if is_dialogue_playing:
		%Label.visible_characters = dialogue_text_length
		_end_dialogue()
	elif is_animation_playing:
		animation_player.seek(animation_player.current_animation_length)
		_end_animation()
	
	if is_scene_playing:
		_handle_scene_finished()


func _process(delta: float):
	if not is_cutscene_playing:
		return
	
	# Handle dialogue
	if is_dialogue_playing:
		_update_dialogue(delta)

	# Let the player skip waiting or go to the next scene
	if Input.is_action_just_pressed("interact"):
		if is_scene_playing:
			skip_waiting()
		else:
			play_next_scene()


func _play_scene(scene: CutsceneScene, from_seconds: float = 0.0):
	if animation_player != null and scene.animation_name.length() > 0:
		_play_animation(animation_player, scene.animation_name, from_seconds)
		
	if scene.dialogue_translation_key.length() > 0:
		_play_dialogue(scene.dialogue_translation_key)
	
	is_scene_playing = true
	scene_playing.emit()


func _get_animation_player() -> AnimationPlayer:
	for child in cutscene.get_children():
		if child is AnimationPlayer:
			return child
	
	return null


func _set_animation_player():
	var resolved_player = _get_animation_player()
	if resolved_player != null:
		_remove_animation_player()
		animation_player = resolved_player
		animation_player.animation_finished.connect(_on_animation_player_animation_finished)


func _remove_animation_player():
	if animation_player != null:
		animation_player.animation_finished.disconnect(_on_animation_player_animation_finished)


func _play_animation(animation_player: AnimationPlayer, animation_name: String = "", from_seconds: float = 0.0):
	is_animation_playing = true
	animation_looping = animation_player.get_animation(animation_name).loop_mode != 0
	animation_player.play(animation_name)
	if from_seconds > 0.0:
		animation_player.seek(from_seconds)


func _play_dialogue(dialogue_translation_key: String):
	var text = tr(dialogue_translation_key)
	dialogue_text_length = Text.get_clean_bb_text(text).length()
	
	is_dialogue_playing = true
	time_since_character = 0.0
	
	%Label.text = "[center]" + text + "[/center]"
	%Label.visible_characters = 0


func _handle_scene_finished():
	if is_scene_playing and not is_animation_playing and not is_dialogue_playing:
		if cutscene.scenes[current_scene].dialogue_translation_key.length() == 0:
			play_next_scene()
		is_scene_playing = false
		scene_finished.emit()


func _end_animation():
	is_animation_playing = false
	animation_finished.emit()
	_handle_scene_finished()


func _end_dialogue():
	is_dialogue_playing = false
	dialogue_finished.emit()
	_handle_scene_finished()


func _end_cutscene():
	is_cutscene_playing = false
	cutscene_finished.emit()
	%Label.text = ""
	
	_remove_animation_player()
	if cutscene.end_animation_name.length() > 0:
		_play_animation(animation_player, cutscene.end_animation_name)


func _on_animation_player_animation_finished(animation_name: String):
	_end_animation()


func _update_dialogue(delta: float):
	time_since_character += delta
	
	# Draw new characters
	if time_since_character > character_wait_time:
		# Support drawing multiple characters if the game is LAGGING like a SILLY SLOW GAME
		var num_characters = min(
			floor(time_since_character / character_wait_time), 
			dialogue_text_length - %Label.visible_characters
		)
		
		# Subtract the time it would've taken to draw these characters
		time_since_character -= num_characters * character_wait_time
		
		%Label.visible_characters += num_characters
		
		# Stop adding characters we've FINISHED!!
		if %Label.visible_characters >= dialogue_text_length:
			_end_dialogue()
