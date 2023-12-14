@tool
extends NinePatchRect
class_name Looker

signal close_looker

var is_dragging_window = false
var internal_viewport = null
var prev_mouse_mode = null

@export var title: String = "New Window":
	get:
		return %Title.text if %Title != null else "New Window"
	set(value):
		if %Title != null:
			%Title.text = value

@export_range(30, 1600) var window_width: int = 300:
	get:
		return size.x
	set(value):
		size.x = value
		%ScreenTransition.material.set_shader_parameter("screen_width", value)
		pivot_offset.x = value*0.5
		pivot_offset.y = window_height*0.5

@export_range(20, 900) var window_height: int = 200:
	get:
		return size.y
	set(value):
		size.y = value
		%ScreenTransition.material.set_shader_parameter("screen_height", value)
		pivot_offset.y = value*0.5
		pivot_offset.x = window_width*0.5

@export var can_close: bool = true:
	set(value):
		if %CloseButton != null:
			%CloseButton.visible = value
			can_close = value

@export var spawn_centered: bool = true
@export var is_in_main_menu: bool = false
@export var is_deploy_looker = false
@export var is_interior_looker = false
@export var looker_z_index := 0
@export var music_track: Music.Track


func _ready():
	if %SubViewportContainer.get_child_count() > 0:
		%PlaceholderBackground.visible = false
		
	if Engine.is_editor_hint():
		return
	
	scale = Vector2.ZERO
	$Animation.play("open_1")
	if spawn_centered:
		center_to_screen()
	
	_setup_sub_viewport()
	
	if not is_in_main_menu:
		GameState.add_looker(self)
	
	if is_deploy_looker or is_interior_looker:
		grab_focus()


func _setup_sub_viewport():
	%SubViewportContainer.set_process_unhandled_key_input(true)
	%SubViewportContainer.set_process_input(true)
	%SubViewportContainer.set_process_unhandled_input(true)
	
	for child in %SubViewportContainer.get_children():
		if child is SubViewport:
			child.handle_input_locally = true


func center_to_screen():
	var window_size = get_viewport().get_visible_rect().size
	position = Vector2(
		0.5*window_size.x - 0.5*size.x, 0.5*window_size.y - 0.5*size.y
	)


func _on_close_button_pressed():
	close()


func close():
	%CloseButton.disabled = true
	if not is_in_main_menu:
		GameState.situation = Constants.Situation.Overworld
	$Animation.play("close_1")


func _on_top_margin_container_gui_input(event):
	if event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		is_dragging_window = (event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
		if is_dragging_window:
			prev_mouse_mode = Input.mouse_mode
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		elif prev_mouse_mode != null:
			Input.mouse_mode = prev_mouse_mode
		
	if is_dragging_window and event is InputEventMouseMotion:
		position += event.relative
		
		var window_size = get_viewport().get_visible_rect().size
		position = Vector2(
			clamp(position.x, 0, window_size.x - size.x),
			clamp(position.y, 0, window_size.y - size.y)
		)


func _on_animation_finished(anim_name):
	if anim_name == "close_1":
		close_looker.emit()
		queue_free()
		if not is_in_main_menu:
			GameState.remove_looker(self)


func _on_sub_viewport_container_gui_input(event):
	if is_in_main_menu:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if is_deploy_looker:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if focus_mode != FOCUS_NONE:
			grab_focus()
