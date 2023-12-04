extends Node3D

@export var is_ai := false
@export var spherical_gravity := true
@export_node_path("CharacterBody3D") var target_path
#@export_node_path("Node3D") var camera_path: NodePath
@export_node_path("Node3D") var model_path: NodePath
@export_range(0.5, 50.0) var walking_speed: float = 10.68
@export_range(0.5, 50.0) var acceleration: float = 17.0
@export_range(0.5, 50.0) var alignment_speed: float = 8.0
@export_range(0.0, 1.0) var move_input_deadzone: float = 0.15
@export_range(0.01, 15.0) var probe_dist = 1.5
@export_range(0.01, 180.0) var max_floor_angle = 50.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var right_axis: Vector3 = Vector3.RIGHT
var forward_axis: Vector3 = Vector3.FORWARD
var planet_center: Vector3 = Vector3.ZERO

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

var snapped = false
var steps_since_grounded = 0
var height = 1.0

@onready var min_floor_dot = cos(deg_to_rad(max_floor_angle))
@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var target = get_node(target_path)
@onready var model = get_node(model_path)

var is_active = true


func _ready():
	InputMap.action_set_deadzone("move_right", move_input_deadzone)
	InputMap.action_set_deadzone("move_left", move_input_deadzone)
	InputMap.action_set_deadzone("move_up", move_input_deadzone)
	InputMap.action_set_deadzone("move_right", move_input_deadzone)
	
	target.up_direction = get_up_direction()
	if target.is_on_floor():
		floor_normal = target.get_floor_normal()
	else:
		floor_normal = target.up_direction
	
	if get_parent() is Munchme:
		if get_parent().situation == Constants.Situation.Interact:
			is_active = true
		else:
			is_active = false


func get_up_direction():
	if spherical_gravity:
		return (target.global_transform.origin - planet_center).normalized()
	else:
		return Vector3.UP


func _process(delta):
	if is_ai:
		return
	if not is_active:
		return
	right_axis = project_direction_on_plane(camera.global_transform.basis.x.normalized(), target.up_direction)
	forward_axis = project_direction_on_plane(camera.global_transform.basis.z.normalized(), target.up_direction)
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _overworld_physics_process(delta):
	target.up_direction = get_up_direction()
	
	if target.is_on_floor():
		floor_normal = target.get_floor_normal()
		steps_since_grounded = 0
		# Stick to floor
		gravity_velocity = -floor_normal * 2.8
	else:
		floor_normal = target.up_direction
		steps_since_grounded += 1
		gravity_velocity += -target.up_direction * gravity * delta
	
	if GameState.situation == Constants.Situation.Catch or not is_active:
		move_input = Vector2.ZERO
	
	var x_axis = project_direction_on_plane(right_axis, floor_normal)
	var z_axis = project_direction_on_plane(forward_axis, floor_normal)
	var move_input_speed_scaled = move_input * walking_speed
	var move_input_rotated = x_axis * move_input_speed_scaled.x + z_axis * move_input_speed_scaled.y
	move_velocity = move_velocity.lerp(move_input_rotated, delta * acceleration)
	
	snap_to_floor()
	animate()
	orient_to_direction(last_strong_direction, delta)

	target.velocity = move_velocity + gravity_velocity
	target.move_and_slide()


func animate():
	if move_velocity.length() > 0.05:
		model.change_animation("Run")
		model.set_animation_speed_scale(move_velocity.length() * 0.12)
		last_strong_direction = move_velocity.normalized()
	else:
		var idle = "Idle"
		if get_parent() is Munchme:
			idle += Lookup.moods[get_parent().resource.mood]
		model.change_animation(idle)
		model.set_animation_speed_scale(1.0)


func orient_to_direction(direction: Vector3, delta: float):
	var left_axis = floor_normal.cross(direction)
	var rotation_basis = Basis(left_axis, floor_normal, direction).orthonormalized()
	target.global_transform.basis = target.global_transform.basis.slerp(
		rotation_basis, delta * alignment_speed
	)


func snap_to_floor() -> bool:
	if steps_since_grounded < 1 or steps_since_grounded > 3:
		return false
	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(
		target.global_transform.origin, target.global_transform.origin - target.up_direction * (0.5 * height + probe_dist), 1
	)
	var result = space_state.intersect_ray(ray_query)
	if !result:
		return false
	var up_dot = target.up_direction.dot(result.normal)
	# Make sure it's not too steep
	if up_dot < min_floor_dot:
		return false
	floor_normal = result.normal
	steps_since_grounded = 0
	var dot = move_velocity.dot(floor_normal)
	if dot > 0.0:
		move_velocity = (move_velocity - floor_normal * dot).normalized() * walking_speed
	return true


func project_direction_on_plane(direction, normal):
	return (direction - normal * direction.dot(normal)).normalized()
