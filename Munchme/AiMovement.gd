extends Node
class_name AiMovement

signal reached_end

@export_node_path("CharacterBody3D") var target_path: NodePath
@export_range(0.001, 2.0) var ok_distance = 0.3
var follow_point: Node3D
var points: Array[Node3D] = []
var has_reached_end = true
@onready var target: CharacterBody3D = get_node_or_null(target_path)


func _process(delta):
	if has_reached_end:
		return
	
	var dist_to_point = target.global_position.distance_to(follow_point.global_position)
	
	if dist_to_point > ok_distance:
		return
	
	if points.size() > 0:
		follow_point = points.pop_front()
	else:
		if not has_reached_end:
			reached_end.emit()
		has_reached_end = true


func set_follow_point(point: Node3D):
	set_follow_points([point])


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
	else:
		push_error("follow_points must be Array[Node3D] or FollowPoints")


func get_move_direction():
	if has_reached_end:
		return Vector3.ZERO
	var direction_to_point = (follow_point.global_position - target.global_position).normalized()
	direction_to_point = Math.project_direction_on_plane(direction_to_point, target.up_direction)
	return direction_to_point
