extends Node
class_name OverworldMovement


@export var spherical_gravity := true
@export var is_animating := true
@export_node_path("CharacterBody3D") var target_path: NodePath
@export_node_path("Node3D") var model_path: NodePath = "../Model"
@export_node_path("Node") var float_node_path: NodePath
@export_range(0.5, 50.0) var walking_speed: float = 10.68
@export_range(0.5, 50.0) var sneak_speed: float = 5.0
@export_range(0.5, 50.0) var air_speed: float = 6.5
@export_range(0.5, 50.0) var walking_acceleration: float = 17.0
@export_range(0.5, 50.0) var air_acceleration: float = 14.0
@export_range(0.5, 50.0) var alignment_speed: float = 8.0
@export_range(0.01, 15.0) var probe_dist = 1.5
@export_range(0.01, 180.0) var max_fall_speed = 40.0
@export var can_jump := false
@export_range(0.0, 100.0) var jump_velocity := 9.0


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var right_axis: Vector3 = Vector3.RIGHT
var forward_axis: Vector3 = Vector3.FORWARD
var planet_center: Vector3 = Vector3.ZERO

var move_input: Vector3 = Vector3.ZERO
var move_velocity: Vector3 = Vector3.ZERO
var speed: float
var acceleration: float
var gravity_velocity: Vector3 = Vector3.ZERO
var last_strong_direction: Vector3 = Vector3.FORWARD
var moving: bool = false
var floor_normal: Vector3 = Vector3.UP
var last_floor_normal: Vector3 = Vector3.UP

var snapped = false
var steps_since_grounded = 0
var height = 1.0

@onready var target: CharacterBody3D = get_node_or_null(target_path)
@onready var min_floor_dot = cos(deg_to_rad(target.floor_max_angle))
@onready var model = get_node_or_null(model_path)
@onready var float_node: FloatMovement = get_node_or_null(float_node_path)
@onready var last_position: Vector3 = target.global_position


func _ready():
	last_strong_direction = target.global_basis.z
	target.up_direction = get_up_direction()
	if target.is_on_floor():
		floor_normal = target.get_floor_normal()
		speed = walking_speed
	else:
		floor_normal = target.up_direction
		speed = air_speed


func get_up_direction():
	if spherical_gravity:
		return (target.global_transform.origin - planet_center).normalized()
	else:
		return Vector3.UP


func set_move_input(value):
	move_input = value


func is_stuck() -> bool:
	var space_state = target.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(
		target.global_transform.origin, target.global_transform.origin - target.up_direction * (0.5 * height + probe_dist), 1
	)
	var result = space_state.intersect_ray(ray_query)
	if !result:
		return false
	if gravity_velocity.length() > 8.0 and last_position.distance_to(target.global_position) < 0.002:
		target.global_position = result.position
		return true
	return false


func _overworld_physics_process(delta):
	target.up_direction = get_up_direction()
	
	#if float_node.is_floating():
		#target.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	#else:
		#target.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	
	#floor_normal = target.get_floor_normal()
	var new_floor_normal := target.up_direction
	if (target.is_on_floor() and not float_node.is_floating()) or (target.is_on_floor() and target.is_inside):
		if target.is_on_floor():
			new_floor_normal = target.get_floor_normal()
		steps_since_grounded = 0
		# Stick to floor
		gravity_velocity = -new_floor_normal * 2.0
		#gravity_velocity = Vector3()
		speed = walking_speed
		acceleration = walking_acceleration
	else:
		steps_since_grounded += 1
		gravity_velocity += -target.up_direction * gravity * delta
		speed = air_speed
		acceleration = air_acceleration
	
	floor_normal = last_floor_normal.move_toward(new_floor_normal, 8.0 * delta).normalized()
	if not target.is_inside:
		gravity_velocity += float_node.get_float_velocity(delta, target.velocity)
	
	if (
		can_jump and 
		Input.is_action_just_pressed("use_power") and 
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and 
		target.player_controlled and
		target.is_on_floor() and 
		not float_node.is_floating()
	):
		if target is Munchme and not GameState.is_munchme_active(target):
			pass
		else:
			gravity_velocity += jump_velocity * target.up_direction
	
	if gravity_velocity.length() > max_fall_speed:
		gravity_velocity = gravity_velocity.normalized() * max_fall_speed
	
	if (
		target is Gungun and 
		Input.is_action_pressed("use_power") and 
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and 
		target.player_controlled and
		not float_node.is_floating()
	):
		# TODO: Raycast down and do a height above hit result
		if target.global_position.length() < 176.0:
			gravity_velocity = target.up_direction * 400.0 * delta
		else:
			gravity_velocity = Vector3.ZERO
			
	
	move_velocity = move_velocity.lerp(move_input * speed, delta * acceleration)
	if target is Muncher and target.sitting:
		move_velocity = Vector3.ZERO
	gravity_velocity = gravity_velocity.project(target.up_direction)
	
	if move_velocity.length() > 0.05:
		last_strong_direction = move_velocity.normalized()
	
	if not float_node.is_floating() or target.is_inside: snap_to_floor()
	animate()
	orient_to_direction(last_strong_direction, delta)
	
	target.velocity = move_velocity + gravity_velocity
	target.move_and_slide()
	last_position = target.global_position
	last_floor_normal = floor_normal


func animate():
	if not is_animating:
		#model.play_animation("Idle")
		#model.set_animation_speed_scale(1.0)
		return
	
	if target is Muncher and target.sitting:
		model.play_animation("Sit")
		return
	
	if not target.is_on_floor() and not float_node.is_floating():
		if model.has_animation("Jump"):
			model.play_animation("Jump")
			model.set_animation_speed_scale(1.0)
			return
	
	if move_velocity.length() > 0.05:
		model.play_animation("Run")
		model.set_animation_speed_scale(move_velocity.length() * 0.12)
	else:
		var idle = "Idle"
		if get_parent() is Munchme:
			idle += Lookup.moods[get_parent().resource.mood]
			if not model.has_animation(idle):
				idle = "Idle"
		model.play_animation(idle)
		model.set_animation_speed_scale(1.0)


func orient_to_direction(direction: Vector3, delta: float):
	var left_axis = floor_normal.cross(direction)
	var rotation_basis = Basis(left_axis, floor_normal, direction).orthonormalized()
	target.global_transform.basis = target.global_transform.basis.slerp(
		rotation_basis, delta * alignment_speed
	)


func snap_to_floor() -> bool:
	if steps_since_grounded < 3 or steps_since_grounded > 5:
		return false
	var space_state = get_parent().get_world_3d().direct_space_state
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
	#$target.global_position = result.position
	if dot > 0.0:
		move_velocity = move_velocity.length() * Math.project_direction_on_plane(move_velocity, floor_normal)
	return true


#region Unused
func _is_on_floor() -> bool:
	var col_count = target.get_slide_collision_count()
	
	if col_count == 0:
		return false
	
	var floor_normal = Vector3.ZERO
	
	for i in range(col_count):
		var col: KinematicCollision3D = target.get_slide_collision(i)
		if col.get_normal().angle_to(target.up_direction) > target.floor_max_angle:
			continue
		floor_normal += col.get_normal()
		floor_normal = floor_normal.normalized()
	
	if floor_normal.is_equal_approx(Vector3.ZERO):
		return false
	else:
		return true
	

func _get_floor_normal() -> Vector3:
	var col_count = target.get_slide_collision_count()
	
	if col_count == 0:
		return target.up_direction
	
	var floor_normal = Vector3.ZERO
	
	for i in range(col_count):
		var col: KinematicCollision3D = target.get_slide_collision(i)
		if col.get_normal().angle_to(target.up_direction) > target.floor_max_angle:
			continue
		floor_normal += col.get_normal()
		floor_normal = floor_normal.normalized()
	
	if floor_normal.is_equal_approx(Vector3.ZERO):
		return target.up_direction
	
	return floor_normal
#endregion
