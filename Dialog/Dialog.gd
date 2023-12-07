extends Node3D

@export var dialog_key: String
@export var number_of_lines: int
@export var offset: Vector2 = Vector2.ZERO

signal speaking
signal nothing_else_to_say

var line = 1


func _ready():
	_update_label()


func _process(delta):
	$Label.set_position(_get_centered_control_position_on_node(self, $Label) + offset)
	
	if Input.is_action_just_pressed("emote_1"):
		say_next_line()


func say_next_line():
	if line >= number_of_lines:
		nothing_else_to_say.emit()
		return
	
	line = line + 1 if line > 0 else 1
	_update_label()
	speaking.emit()


func _get_centered_control_position_on_node(node: Node3D, control: Control):
	var camera = get_viewport().get_camera_3d()
	var position = camera.unproject_position(node.global_transform.origin)
	return position - control.get_rect().size / 2


func _update_label():
	var full_key = dialog_key + "_" + str(line)
	if $Label.text != full_key:
		$Label.text = full_key
