extends CharacterBody3D
class_name Munchme

@export var resource: MunchmeResource
@export var situation: Constants.Situation = Constants.Situation.Overworld
@export_node_path("MunchmeModel") var model_path: NodePath = "Model"
@export var freeze := false
@export var player_controlled := false
@export var can_be_caught := true
@export_range(0.0, 1.0) var move_input_deadzone: float = 0.15
@export_range(0.0, 10.0) var height: float = 0.75
@export var is_inside := false

@export_group("Step Sounds", "step_sounds_")
@export var step_sounds_default := true
@export var step_sounds_type := Constants.StepType.Step



var is_in_area = false
var can_catch = false
var in_catch_mode = false
var player: Node3D = null
var move_input

var step_sounds := []
var is_stepping := false

var camera: Node3D

signal catch_munchme(munchme: Munchme)
signal finish_catch(win: bool)

@onready var model: MunchmeModel = get_node_or_null(model_path)


func _ready():
	if situation == Constants.Situation.Overworld:
		$OverworldMovement.spherical_gravity = not is_inside
	elif situation == Constants.Situation.Catch:
		get_parent().start_minigame.connect(_on_start_minigame)
		if not finish_catch.is_connected(get_parent()._on_munchme_finish_catch):
			finish_catch.connect(get_parent()._on_munchme_finish_catch)
	elif situation == Constants.Situation.Interact:
		$OverworldMovement.spherical_gravity = true
		player_controlled = true
	
	model.step.connect(play_step_sound)
	if step_sounds_default:
		step_sounds.append_array([
			load("res://SFX/Step/step_soft1.ogg"),
			load("res://SFX/Step/step_soft2.ogg"),
			load("res://SFX/Step/step_soft3.ogg"),
			load("res://SFX/Step/step_soft4.ogg"),
		])
	
	munchme_specific_ready()


func get_move_input() -> Vector3:
	if camera == null:
		return Vector3.ZERO
	var raw_move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Vector2.ZERO.distance_to(raw_move_input) > 1.0:
		raw_move_input = raw_move_input.normalized()
	if Vector2.ZERO.distance_to(raw_move_input) < ProjectSettings.get_setting("global/control_stick_deadzone") * sqrt(2.0):
		raw_move_input = Vector2.ZERO
	var right_axis = Math.project_direction_on_plane(camera.global_transform.basis.x.normalized(), up_direction)
	var forward_axis = Math.project_direction_on_plane(camera.global_transform.basis.z.normalized(), up_direction)
	var x_axis = Math.project_direction_on_plane(right_axis, $OverworldMovement.floor_normal)
	var z_axis = Math.project_direction_on_plane(forward_axis, $OverworldMovement.floor_normal)
	return x_axis * raw_move_input.x + z_axis * raw_move_input.y


func munchme_specific_ready():
	pass


func play_step_sound():
	if not is_on_floor() or step_sounds.size() == 0:
		return

	$StepPlayer.stream = step_sounds.pick_random()
	$StepPlayer.play()


func _process(delta):
	_munchme_specific_process(delta)
	if situation == Constants.Situation.Overworld:
		_overworld_process(delta)


func _physics_process(delta):
	if freeze:
		$OverworldMovement.move_input = Vector3.ZERO
		#$Model.play_animation("Idle")
		#$Model.set_animation_speed_scale(1.0)
		return
	if GameState.is_munchme_active(self) and situation == Constants.Situation.Interact:
		$OverworldMovement.move_input = get_move_input()
	else:
		$OverworldMovement.move_input = Vector3.ZERO
	if not player_controlled:
		$OverworldMovement.move_input = $AiMovement.get_move_direction()
	
	if step_sounds_type == Constants.StepType.Slide:
		var should_step = $OverworldMovement.move_velocity.length() > 0.05 and is_on_floor()
		if not is_stepping and should_step:
			is_stepping = true
			play_step_sound()
		elif is_stepping and not should_step:
			$StepPlayer.stop()
			is_stepping = false
	
	$OverworldMovement._overworld_physics_process(delta)


func _overworld_process(delta):
	if in_catch_mode or not can_be_caught:
		$CatchArea.monitoring = false
		return
	$CatchArea.monitoring = true
	if is_in_area and player != null:
		var direction = player.global_transform.basis.z
		var direction_towards_me = (global_position - player.global_position).normalized()
		if direction.angle_to(direction_towards_me) < 0.45*PI:
			can_catch = true
		else:
			can_catch = false
	else:
		can_catch = false
	
	$CatchText.visible = can_catch
	
	if (
		Input.is_action_just_pressed("interact") and 
		can_catch and 
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and
		GameState.focus_main
	):
		attempt_catch()


func _munchme_specific_process(delta):
	pass


func _on_catch_area_body_entered(body):
	is_in_area = true
	player = body


func _on_catch_area_body_exited(body):
	is_in_area = false
	can_catch = false
	$CatchText.visible = false


func attempt_catch():
	in_catch_mode = true
	GameState.attempt_catch_munchme.emit(self)


func _on_start_minigame():
	start_minigame()


func start_minigame():
	pass


func win_catch():
	finish_catch.emit(true)


func lose_catch():
	finish_catch.emit(false)


func play_animation(anim: String):
	if $Model == null:
		return
	$Model.play_animation(anim)


func set_follow_points(_points: Variant, spherical: bool = true):
	$AiMovement.set_follow_points(_points)


func set_follow_point(_point: Node3D, spherical: bool = true):
	$AiMovement.set_follow_point(_point)


func set_vector_follow_point(_point: Vector3, spherical: bool = true):
	$AiMovement.set_vector_follow_point(_point, spherical)


func rotate_towards(pos: Vector3):
	$OverworldMovement.last_strong_direction = (pos - global_position).normalized()
