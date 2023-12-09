extends DirectionalLight3D


@export_node_path("CharacterBody3D") var player_path: NodePath
@onready var player: CharacterBody3D = get_node(player_path)
@export var follow_player = true


func _physics_process(delta):
	if not follow_player:
		return
	global_position = player.global_position + player.up_direction * 10.0
#	.rotated(Vector3.LEFT, 0.1*PI)
	global_transform.basis = Basis(Math.from_to_rotation(Vector3.FORWARD.rotated(Vector3.LEFT, 0.18*PI), -player.up_direction))
