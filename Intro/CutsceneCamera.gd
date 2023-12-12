@tool
extends Node3D


@export_node_path("Node3D") var focus_path
@onready var focus: Node3D = get_node(focus_path)
@export var in_editor := false
@export var follow := true


func _process(delta):
	if (not in_editor and Engine.is_editor_hint()) or not follow:
		return
	var direction = (global_position - (focus.global_position + focus.global_position.normalized() * 1.5)).normalized()
	var up_perp = Vector3.UP - direction * ((Vector3.UP.dot(direction))/(direction.dot(direction)))
	var up_perp_scaled = up_perp * (direction.length()/up_perp.length())
	var up = cos(0.5*PI) * direction + sin(0.5*PI) * up_perp_scaled
	var left = up.cross(direction)
	global_basis = Basis(left, up, direction)


func set_follow(value: bool):
	follow = value
