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
