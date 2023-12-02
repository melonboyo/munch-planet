@tool
extends NinePatchRect

var is_dragging_window = false
var internal_viewport = null
var prev_mouse_mode = null

@export var title: String = "New Window":
	get:
		return %Title.text if %Title != null else "New Window"
	set(value):
		if %Title != null:
			%Title.text = value

@export_range(300, 1200) var window_width: int = 300:
	get:
		return size.x
	set(value):
		size.x = value
		%ScreenTransition.material.set_shader_parameter("screen_width", value)

@export_range(200, 900) var window_height: int = 200:
	get:
		return size.y
	set(value):
		size.y = value
		%ScreenTransition.material.set_shader_parameter("screen_height", value)

@export var can_close: bool = true:
	set(value):
		if %CloseButton != null:
			%CloseButton.visible = value
			can_close = value

@export var spawn_centered: bool = true


func _ready():
	_setup_viewport_from_child()
	if spawn_centered:
		center_to_screen()
	if not Engine.is_editor_hint():
		var looker_viewport = get_looker_viewport()
		if looker_viewport != null:
			looker_viewport.queue_free()


func center_to_screen():
	var window_size = get_viewport().get_visible_rect().size
	position = Vector2(
		0.5*window_size.x - 0.5*size.x, 0.5*window_size.y - 0.5*size.y
	)


func _setup_viewport_from_child():
	var looker_viewport = get_looker_viewport()
	
	if looker_viewport == null and internal_viewport != null:
		internal_viewport.queue_free()
		%PlaceholderBackground.visible = true
	elif looker_viewport != null and internal_viewport == null:
		internal_viewport = looker_viewport.duplicate()
		%SubViewportContainer.add_child(internal_viewport)
		%PlaceholderBackground.visible = false


func get_looker_viewport():
	for child in get_children():
		if child is SubViewport:
			return child
	
	return null


func _on_close_button_pressed():
	print("i tried to close i tried it!!")
	queue_free()


func _on_top_margin_container_gui_input(event):
	if event is InputEventMouseButton:
		is_dragging_window = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
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


func _get_configuration_warnings():
	#print("get configuration warnings")
	_setup_viewport_from_child()
	
	if internal_viewport == null:
		return ["This node needs a SubViewport as a child"]
