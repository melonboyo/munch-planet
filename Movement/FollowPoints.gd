extends Node3D
class_name FollowPoints

@onready var points := _get_points()
@export_node_path("Goby") var target: NodePath
@export var spherical := true
@export var loop := false

var ai_movement: AiMovement

func _ready():
	if not target.is_empty():
		ai_movement = _get_ai_movement(get_node(target))
		if ai_movement == null:
			push_error("target missing AiMovement child")
			return

	if spherical:
		for node in points:
			var new_global_position = Math.position_to_position_on_surface(node.global_position, node.global_position.normalized(), node)
			node.global_position = new_global_position
	
	if ai_movement != null:
		ai_movement.set_follow_points(self)
		ai_movement.reached_end.connect(_on_reached_end)


func _on_reached_end():
	if loop:
		ai_movement.set_follow_points(self)


func _get_points() -> Array[Node3D]:
	var _points: Array[Node3D] = []
	for child in get_children():
		if child is Node3D:
			_points.append(child)
	
	return _points


func _get_ai_movement(node: Node) -> AiMovement:
	for child in node.get_children():
		if child is AiMovement:
			return child
	
	return null
