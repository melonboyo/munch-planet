extends Node
class_name Math


static func project_direction_on_plane(direction, normal):
	return (direction - normal * direction.dot(normal)).normalized()


static func from_to_rotation(from, to) -> Quaternion:
	var angle_to = from.angle_to(to)
	var axis = from.cross(to)
	if axis.is_equal_approx(Vector3.ZERO):
		return Quaternion.IDENTITY;
	else:
		return Quaternion(axis.normalized(), angle_to)


static func position_to_position_on_surface(pos: Vector3, up: Vector3, node: Node3D, spherical: bool = true) -> Vector3:
	var space_state = node.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(
		pos + up*10.0, pos - up*200.0, 1
	)
	ray_query.hit_back_faces = false
	ray_query.hit_from_inside = true
	var result = space_state.intersect_ray(ray_query)
	if !result:
		return pos
	
	return result.position
