extends Control

enum State {
	Title,
	Menu,
}
var state: State = State.Title

var intro_scene = preload("res://Intro/Intro.tscn")
var main_scene = preload("res://Main.tscn")
var settings_looker_scene = preload("res://Looker/Settings/SettingsLooker.tscn")

const EARTH_COLLISION_LAYER = 1
const PLANET_NORMAL_SCALE := 1
const PLANET_NOT_HOVER_SCALE := 0.8

var hovering_earth: bool
@export var earth_scale: float = 0.8


func _on_start_button_pressed():
	$AnimationPlayer.play("fade_to_game")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_settings_button_pressed():
	open_settings()


func _on_exit_button_pressed():
	get_tree().quit()


func _process(delta):
	%Planet.scale = %Planet.scale.lerp(Vector3.ONE * earth_scale, 0.2)
	if $AnimationPlayer.is_playing():
		return
	
	if state == State.Title:
		hovering_earth = is_mouse_hovering(EARTH_COLLISION_LAYER)
		earth_scale = PLANET_NORMAL_SCALE if hovering_earth else PLANET_NOT_HOVER_SCALE
	
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
		get_tree().change_scene_to_packed(intro_scene)
