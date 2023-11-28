extends CharacterBody3D


@export_range(0.5, 50.0) var walking_speed: float = 5.0
@export_range(0.5, 50.0) var alignment_speed: float = 18.0
@export_node_path("Node3D") var camera_path: NodePath
@export_range(0.0, 1.0) var move_input_deadzone: float = 0.3


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var right_axis: Vector3 = Vector3.RIGHT
var forward_axis: Vector3 = Vector3.FORWARD

var move_input: Vector2 = Vector2.ZERO:
	set(value):
		move_input = value
		if Vector2.ZERO.distance_to(move_input) > 1.0:
			move_input = move_input.normalized()
		if Vector2.ZERO.distance_to(move_input) < move_input_deadzone * sqrt(2.0):
			move_input = Vector2.ZERO
var move_velocity: Vector3 = Vector3.ZERO
var gravity_velocity: Vector3 = Vector3.ZERO
var last_strong_direction: Vector3 = Vector3.FORWARD
var moving: bool = false
var floor_normal: Vector3 = Vector3.UP

@onready var camera: Camera3D = get_node(camera_path)


func _ready():
	InputMap.action_set_deadzone("move_right", move_input_deadzone)
	InputMap.action_set_deadzone("move_left", move_input_deadzone)
	InputMap.action_set_deadzone("move_up", move_input_deadzone)
	InputMap.action_set_deadzone("move_right", move_input_deadzone)
	
	up_direction = global_transform.origin.normalized()
	if is_on_floor():
		floor_normal = get_floor_normal()
	else:
		floor_normal = up_direction


func _process(delta):
	right_axis = project_direction_on_plane(camera.global_transform.basis.x.normalized(), up_direction)
	forward_axis = project_direction_on_plane(camera.global_transform.basis.z.normalized(), up_direction)
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _physics_process(delta):
	up_direction = global_transform.origin.normalized()
	
	if is_on_floor():
		floor_normal = get_floor_normal()
#		gravity_velocity = -floor_normal * 0.5
		gravity_velocity = Vector3.ZERO
	else:
		floor_normal = up_direction
		gravity_velocity += -up_direction * gravity * delta
	
	var x_axis = project_direction_on_plane(right_axis, floor_normal)
	var z_axis = project_direction_on_plane(forward_axis, floor_normal)
	var move_input_speed_scaled = move_input * walking_speed
	move_velocity = x_axis * move_input_speed_scaled.x + z_axis * move_input_speed_scaled.y
	
	if move_velocity.length() > 0.2:
		last_strong_direction = move_velocity.normalized()
	orient_to_direction(last_strong_direction, delta)

	velocity = move_velocity + gravity_velocity
	move_and_slide()


func orient_to_direction(direction: Vector3, delta: float):
	var left_axis = floor_normal.cross(direction)
	var rotation_basis = Basis(left_axis, floor_normal, direction).orthonormalized()
	global_transform.basis = global_transform.basis.slerp(
		rotation_basis, delta * alignment_speed
	)


func project_direction_on_plane(direction, normal):
	return (direction - normal * direction.dot(normal)).normalized()
