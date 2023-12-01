extends Node3D

@export_node_path("Node3D") var focus_path
@export_range(1.0, 360.0) var rotation_speed: float = 90.0
@export_range(-89.0, 89.0) var min_vertical_angle: float = -45.0
@export_range(-89.0, 89.0) var max_vertical_angle: float = 45.0
@export_range(1.0, 360.0) var up_alignment_speed: float = 25.0
@export_range(1.0, 100) var mouse_sensitivity: float = 20.0
@export var invert_look_y: bool = false
@export var invert_look_x: bool = false
@export_range(0.0, 1.0) var look_input_deadzone: float = 0.1

var focus_point: Vector3
var orbit_angles: Vector2 = Vector2(0.0, 0.0):
	set(value):
		orbit_angles = value
		orbit_angles.x = clamp(orbit_angles.x, max_vertical_angle, min_vertical_angle)
		if orbit_angles.y < 0:
			orbit_angles.y += 360
		elif orbit_angles.y >= 360:
			orbit_angles.y -= 360

var orbit_rotation: Quaternion = Quaternion.IDENTITY
var gravity_alignment: Quaternion = Quaternion.IDENTITY
var input: Vector2 = Vector2.ZERO
var up_axis: Vector3 = Vector3.UP

@onready var focus: Node3D = get_node(focus_path)
@onready var camera: Camera3D = %Camera3D
@onready var listener = $AudioListener3D


func _ready():
	InputMap.action_set_deadzone("look_right", look_input_deadzone)
	InputMap.action_set_deadzone("look_left", look_input_deadzone)
	InputMap.action_set_deadzone("look_up", look_input_deadzone)
	InputMap.action_set_deadzone("look_down", look_input_deadzone)
	
	# Assert that the max angle isn't smaller than the min angle
	min_vertical_angle = -min_vertical_angle
	max_vertical_angle = -max_vertical_angle
	if max_vertical_angle > min_vertical_angle:
		max_vertical_angle = min_vertical_angle
	
	# Set initial rotation
	up_axis = focus.global_position.normalized()
	rotation_degrees = Vector3(orbit_angles.x, orbit_angles.y, 0.0)
	orbit_rotation = Quaternion.from_euler(Vector3(deg_to_rad(orbit_angles.x), deg_to_rad(orbit_angles.y), 0.0))
	focus_point = focus.global_position + up_axis * 1.8
	
	gravity_alignment = from_to_rotation(Vector3.UP, up_axis) * gravity_alignment
	var look_rotation: Quaternion = gravity_alignment * orbit_rotation
	global_transform.basis = Basis(look_rotation)
	global_position = focus_point
	
	listener.global_transform.basis = Basis(look_rotation)
	listener.global_position = focus.global_position


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if not invert_look_x:
			input.x += event.relative.y * 0.2
		else:
			input.x += -event.relative.y * 0.2
		if not invert_look_y:
			input.y += event.relative.x * 0.2
		else:
			input.y += -event.relative.x * 0.2


func _physics_process(delta):
	focus_point = focus.global_position + up_axis * 1.8
	up_axis = focus_point.normalized()
	
	# Update gravity alignment
	update_gravity_alignment(delta)
	
	# Do look rotation
	if look_rotation(delta):
		# Make rotation quaternion for orbit rotation
		orbit_rotation = Quaternion.from_euler(
			Vector3(deg_to_rad(orbit_angles.x), deg_to_rad(orbit_angles.y), 0.0)
		)
	
	# Make combined rotation from gravity alignment and orbit
	var look_rotation: Quaternion = gravity_alignment * orbit_rotation
	global_transform.basis = Basis(look_rotation)
	global_position = global_position.slerp(focus_point, delta * 20.0)
	
	listener.global_transform.basis = Basis(look_rotation)
	listener.global_position = focus.global_position


func look_rotation(delta) -> bool:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		input = Vector2.ZERO
		return false
	
	# Get look input right analogue stick
	if not invert_look_x:
		input.y += (Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * 5.0
	else:
		input.y += -(Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * 5.0
	if not invert_look_y:
		input.x += (Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * 5.0
	else:
		input.x += -(Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * 5.0
	
	# Add the input to the orbit angles if larger than e
	var e = 0.001
	if input.x < -e or input.x > e or input.y < -e or input.y > e:
		orbit_angles -= 2.0 * mouse_sensitivity * input * delta
		input = Vector2.ZERO
		return true
	input = Vector2.ZERO
	return false


func update_gravity_alignment(delta : float):
	var from_up = gravity_alignment * Vector3.UP
	var to_up = up_axis
	if from_up.is_equal_approx(to_up):
		return
	
	var angle_to = from_up.angle_to(to_up)
	var axis = from_up.cross(to_up).normalized()
	
	var new_rotation = Quaternion(axis, angle_to)
	var max_angle = up_alignment_speed * delta
	
	var new_alignment = new_rotation * gravity_alignment
	gravity_alignment = gravity_alignment.slerp(new_alignment, up_alignment_speed * delta)


func from_to_rotation(from, to) -> Quaternion:
	var angle_to = from.angle_to(to)
	var axis = from.cross(to)
	if axis.is_equal_approx(Vector3.ZERO):
		return Quaternion.IDENTITY;
	else:
		return Quaternion(axis.normalized(), angle_to)
