@tool
extends NinePatchRect

var is_dragging_window = false

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

@export_range(200, 900) var window_height: int = 200:
	get:
		return size.y
	set(value):
		size.y = value

func _on_close_button_pressed():
	print("i tried to close i tried it!!")
	queue_free()


func _on_top_margin_container_gui_input(event):
	if event is InputEventMouseButton:
		is_dragging_window = event.button_index == 1 and event.pressed
		
	if is_dragging_window and event is InputEventMouseMotion:
		position += event.relative
