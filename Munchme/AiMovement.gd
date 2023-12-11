extends Node

@export_node_path("CharacterBody3D") var target_path: NodePath
@export_range(0.001, 2.0) var ok_distance = 0.3
var follow_point: Vector3
var points: Array[Vector3] = []
var has_reached_end = true
@onready var target: CharacterBody3D = get_node_or_null(target_path)


func _process(delta):
	if has_reached_end:
		return
	
	var dist_to_point = target.global_position.distance_to(follow_point)
	
	if dist_to_point > ok_distance:
		return
	
	if points.size() > 0:
		follow_point = points.pop_front()
	else:
		has_reached_end = true


func set_follow_point(point: Vector3):
	set_follow_points([point])


func set_follow_points(_points: Array[Vector3]):
	points.clear()
	points = _points
	for i in points.size():
		points[i] = Math.position_to_position_on_surface(points[i], points[i].normalized(), target)
	follow_point = points[0]
	has_reached_end = false


func add_points(_points: Array[Vector3]):
	if has_reached_end:
		set_follow_points(_points)
		return
	for i in _points.size():
		_points[i] = Math.position_to_position_on_surface(_points[i], _points[i].normalized(), target)
	points.append_array(_points)
	has_reached_end = false


func get_move_direction():
	if has_reached_end:
		return Vector3.ZERO
	var direction_to_point = (follow_point - target.global_position).normalized()
	direction_to_point = Math.project_direction_on_plane(direction_to_point, target.up_direction)
	return direction_to_point
