extends Control

enum State {
	Title,
	Menu,
}
var state: State = State.Title

var intro_scene = preload("res://Intro/Intro.tscn")
var main_scene = preload("res://Main.tscn")
var settings_looker_scene = preload("res://Looker/Settings/SettingsLooker.tscn")

const INTRO_FADE_IN_DURATION = 1  # seconds
const EARTH_COLLISION_LAYER = 1
const PLANET_NORMAL_SCALE := 1
const PLANET_NOT_HOVER_SCALE := 0.8

var hovering_earth: bool
@export var earth_scale: float = 0.8

var time_since_hovered_earth := 0.0
const SHOW_EARTH_HINT_TIME := 9.0
var show_earth_hint := false


func _ready():
	GameState.has_game_started = false


func _on_start_button_pressed():
	%StartButton.disabled = true
	$AnimationPlayer.play("fade_to_game")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_settings_button_pressed():
	open_settings()


func _on_exit_button_pressed():
	get_tree().quit()


func _process(delta):
	%Planet.scale = %Planet.scale.lerp(Vector3.ONE * earth_scale, 8.0 * delta)
	if $AnimationPlayer.is_playing():
		# Skip to the fade_in part of the intro cutscene on interact
		if (Input.is_action_just_pressed("interact") and
			$AnimationPlayer.current_animation == "intro" and 
		 	$AnimationPlayer.current_animation_position < $AnimationPlayer.current_animation_length - INTRO_FADE_IN_DURATION):
			$AnimationPlayer.seek($AnimationPlayer.current_animation_length - INTRO_FADE_IN_DURATION)
		
		return
	
	show_earth_hint = false
	$MenuHints.visible = state == State.Title
	if state == State.Title:
		hovering_earth = is_mouse_hovering(EARTH_COLLISION_LAYER)
		earth_scale = PLANET_NORMAL_SCALE if hovering_earth else PLANET_NOT_HOVER_SCALE
		
		time_since_hovered_earth = time_since_hovered_earth + delta if not hovering_earth else 0.0
		show_earth_hint = time_since_hovered_earth > SHOW_EARTH_HINT_TIME
	
	%MainMenuCircle.modulate = %MainMenuCircle.modulate.lerp(Color.WHITE if show_earth_hint else Color.TRANSPARENT, 4.0 * delta if show_earth_hint else 10.0 * delta)
	
	if hovering_earth and Input.is_action_just_pressed("interact"):
		set_state(State.Menu)
	
	if (Input.is_action_just_pressed("cancel") or 
		Input.is_action_just_pressed("settings") or 
		Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		state_back()


func set_state(new_state: State):
	if state == State.Title and new_state == State.Menu:
		$AnimationPlayer.play("fade_to_menu")
	if state == State.Menu and new_state == State.Title:
		$AnimationPlayer.play("fade_to_title")
	
	state = new_state


func state_back():
	if state == State.Menu:
		set_state(State.Title)


func is_mouse_hovering(collision_layer: int):
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = %Camera3D.project_ray_origin(mouse_position)
	var ray_end = ray_origin + %Camera3D.project_ray_normal(mouse_position) * 10000.0
	var space_state := %MainMenu3D.get_world_3d().direct_space_state as PhysicsDirectSpaceState3D
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, pow(2, 1-1))
	var result := space_state.intersect_ray(ray_query)
	if !result:
		return false

	return result.collider.collision_layer | collision_layer


func open_settings():
	for child in get_children():
		if child.name == "SettingsLooker":
			child.close()
			return
	
	var settings_looker = settings_looker_scene.instantiate()
	settings_looker.is_in_main_menu = true
	add_child(settings_looker)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_to_game":
		GameState.has_game_started = true
		get_tree().change_scene_to_packed(intro_scene)
