extends DirectionalLight3D


@export_node_path("CharacterBody3D") var player_path: NodePath
@onready var player: CharacterBody3D = get_node(player_path)


func _physics_process(delta):
	global_position = player.global_position + player.up_direction * 10.0
#	.rotated(Vector3.LEFT, 0.1*PI)
	global_transform.basis = Basis(from_to_rotation(Vector3.FORWARD.rotated(Vector3.LEFT, 0.18*PI), -player.up_direction))


func from_to_rotation(from, to) -> Quaternion:
	var angle_to = from.angle_to(to)
	var axis = from.cross(to)
	return Quaternion(axis.normalized(), angle_to)
