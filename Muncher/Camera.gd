@tool
extends Node3D
class_name Camera

@export var for_munchme := false
@export var enable := true
@export_node_path("Node3D") var focus_path
@export_range(1.0, 360.0) var rotation_speed: float = 90.0
@export_range(-89.0, 89.0) var min_vertical_angle: float = -45.0
@export_range(-89.0, 89.0) var max_vertical_angle: float = 45.0
@export_range(1.0, 360.0) var up_alignment_speed: float = 25.0
@export_range(1.0, 100) var mouse_sensitivity: float = 20.0
@export var invert_look_y: bool = false
@export var invert_look_x: bool = false
@export var stay: bool = false
@export_range(0.0, 1.0) var look_input_deadzone: float = 0.0
@export_range(1.0, 50.0) var distance_to_focus: float = 6.0:
	set(value):
		distance_to_focus = value
		if $SpringArm3D == null:
			return
		$SpringArm3D.spring_length = value

var focus_point: Vector3
@export var orbit_angles: Vector2 = Vector2(0.0, 0.0):
	set(value):
		orbit_angles = value
		orbit_angles.x = clamp(orbit_angles.x, -max_vertical_angle, -min_vertical_angle)
		if orbit_angles.y < 0:
			orbit_angles.y += 360
		elif orbit_angles.y >= 360:
			orbit_angles.y -= 360

var orbit_rotation: Quaternion = Quaternion.IDENTITY
var gravity_alignment: Quaternion = Quaternion.IDENTITY
var input: Vector2 = Vector2.ZERO
var up_axis: Vector3 = Vector3.UP

var player: Node3D
@onready var camera: Camera3D = %Camera3D
@onready var listener = $AudioListener3D

var focus: Node3D


func _ready():
	if Engine.is_editor_hint():
		return
	#if for_munchme and GameState.deployed_munchme_camera == null:
		#GameState.deployed_munchme_camera = self
	if focus_path != null:
		player = get_node_or_null(focus_path)
	
	if not for_munchme:
		focus = player
	else:
		focus = GameState.deployed_munchmes[GameState.deployed_munchmes.size()-1]
	
	#if for_munchme:
		#enable = GameState.is_window_active(get_parent().looker)
	#else:
		#enable = GameState.focus_main
	
	InputMap.action_set_deadzone("look_right", look_input_deadzone)
	InputMap.action_set_deadzone("look_left", look_input_deadzone)
	InputMap.action_set_deadzone("look_up", look_input_deadzone)
	InputMap.action_set_deadzone("look_down", look_input_deadzone)
	
	if focus == null:
		return
	
	# Set initial rotation
	up_axis = focus.global_position.normalized()
	rotation_degrees = Vector3(orbit_angles.x, orbit_angles.y, 0.0)
	orbit_rotation = Quaternion.from_euler(Vector3(deg_to_rad(orbit_angles.x), deg_to_rad(orbit_angles.y), 0.0))
	focus_point = focus.global_position + up_axis * focus.height
	
	gravity_alignment = Math.from_to_rotation(Vector3.UP, up_axis) * gravity_alignment
	var look_rotation: Quaternion = gravity_alignment * orbit_rotation
	global_transform.basis = Basis(look_rotation)
	global_position = focus_point
	
	listener.global_transform.basis = Basis(look_rotation)
	listener.global_position = focus.global_position


func _process(delta):
	if Engine.is_editor_hint():
		return
	
	if not for_munchme:
		enable = GameState.focus_main


func _physics_process(delta):
	if for_munchme and not Engine.is_editor_hint():
		pass
	if Engine.is_editor_hint() or focus == null:
		return
	focus_point = focus.global_position + up_axis * focus.height
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
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		input = Vector2.ZERO
		return false
	
	if not enable or not camera.current:
		input = Vector2.ZERO
		return false
	
	# Get look input right analogue stick
	input = MouseInput.input
	
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


func _on_area_3d_area_entered(area):
	#$UnderwaterShader.material_override.set_shader_parameter("effect", 0.5)
	#$UnderwaterShader.visible = true
	pass


func _on_area_3d_area_exited(area):
	#$UnderwaterShader.material_override.set_shader_parameter("effect", 0.0)
	#$UnderwaterShader.visible = false
	pass


func set_current(value: bool):
	camera.current = value
