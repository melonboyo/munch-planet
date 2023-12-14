extends Node
class_name AiMovement

signal reached_end

@export_node_path("CharacterBody3D") var target_path: NodePath
@export_range(0.001, 2.0) var ok_distance = 0.3
var follow_point: Variant
var points: Array[Node3D] = []
var has_reached_end = true
@onready var target: CharacterBody3D = get_node_or_null(target_path)


func _process(delta):
	if not points.is_empty() and target.player_controlled:
		has_reached_end = true
	if has_reached_end:
		return
	
	var dist_to_point: float
	if follow_point is Node3D:
		var surface_position = Math.position_to_position_on_surface(
			follow_point.global_position, follow_point.global_position.normalized(), follow_point
		)
		dist_to_point = target.global_position.distance_to(surface_position)
	elif follow_point is Vector3:
		dist_to_point = target.global_position.distance_to(follow_point)
	
	if follow_point is Vector3:
		pass
	
	if dist_to_point > ok_distance:
		#print(follow_point.position)
		return
	
	if follow_point is Node3D:
		if points.size() > 0:
			follow_point = points.pop_front()
		else:
			if not has_reached_end:
				reached_end.emit()
			has_reached_end = true
	else:
		has_reached_end = true


func set_vector_follow_point(point: Vector3, spherical: bool = true):
	var up = point.normalized() if spherical else Vector3.UP
	var new_global_position = Math.position_to_position_on_surface(
		point, up, get_parent(), spherical
	)
	follow_point = new_global_position
	has_reached_end = false


func set_follow_point(point: Node3D):
	points.clear()
	set_follow_points([point] as Array[Node3D])


func set_follow_points(_points: Variant):
	points.clear()
	_add_follow_points(_points)
	
	follow_point = points[0]
	has_reached_end = false


func add_follow_points(_points: Variant):
	if has_reached_end:
		set_follow_points(_points)
		return

	_add_follow_points(_points)
	has_reached_end = false


func _add_follow_points(_points: Variant):
	if _points is FollowPoints:
		points.append_array(_points.points)
	elif _points is Array[Node3D]:
		points.append_array(_points)
	elif _points is Array[Node]:
		points.append_array(_get_points(_points))
	else:
		push_error("follow_points must be Array[Node3D] or FollowPoints")


func _get_points(nodes: Array[Node]) -> Array[Node3D]:
	var _points: Array[Node3D] = []
	for child in nodes:
		if child is Node3D:
			print(child)
			_points.append(child)
	
	return _points


func get_move_direction():
	if has_reached_end:
		return Vector3.ZERO
	var move_to: Vector3
	if follow_point is Node3D:
		var surface_position = Math.position_to_position_on_surface(
			follow_point.global_position, follow_point.global_position.normalized(), follow_point
		)
		move_to = surface_position
	elif follow_point is Vector3:
		move_to = follow_point
	var direction_to_point = (move_to - target.global_position).normalized()
	direction_to_point = Math.project_direction_on_plane(direction_to_point, target.up_direction)
	return direction_to_point
