@tool
extends Node3D

@export_range(0.5, 100) var ray_dist = 20.0:
	set(value):
		ray_dist = value
@export var align := false:
	set(value):
		align = false
		align_to_normal()
@export_range(-360, 360) var y_rotation: float = 0.0:
	set(value):
		y_rotation = value
@export_range(0, 10) var _scale: float = 1.0:
	set(value):
		_scale = value


func _process(delta):
	pass
	#align_to_normal()


func align_to_normal():
	if not Engine.is_editor_hint():
		return
	
	for c in get_children():
		var ray_dir = -global_position.normalized()
		var space_state = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.create(
			global_position, -ray_dir * ray_dist * 0.2 + global_position + ray_dir * ray_dist * 1.2, 1
		)
		ray_query.hit_back_faces = false
		ray_query.hit_from_inside = false
		
		var result = space_state.intersect_ray(ray_query)
		if !result:
			return
		
		var up: Vector3 = result.normal.normalized()
		var forward: Vector3 = Vector3.FORWARD * from_to_rotation(Vector3.UP, up)
		forward = forward.rotated(up, deg_to_rad(y_rotation))
		var right: Vector3 = up.cross(forward).normalized()
		print(up * from_to_rotation(up, Vector3.UP), forward * from_to_rotation(up, Vector3.UP), right * from_to_rotation(up, Vector3.UP))
		
		c.global_position = result.position
		c.global_transform.basis = Basis(right, up, forward).scaled(Vector3.ONE * _scale)


func from_to_rotation(from, to) -> Quaternion:
	var angle_to = from.angle_to(to)
	var axis = from.cross(to)
	return Quaternion(axis.normalized(), angle_to)
