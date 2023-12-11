@tool
extends Node3D


@export_node_path("Node3D") var focus_path
@onready var focus: Node3D = get_node(focus_path)


func _process(delta):
	var direction = (global_position - (focus.global_position + focus.global_position.normalized() * 1.5)).normalized()
	var up_perp = Vector3.UP - direction * ((Vector3.UP.dot(direction))/(direction.dot(direction)))
	var up_perp_scaled = up_perp * (direction.length()/up_perp.length())
	var up = cos(0.5*PI) * direction + sin(0.5*PI) * up_perp_scaled
	var left = up.cross(direction)
	global_basis = Basis(left, up, direction)
