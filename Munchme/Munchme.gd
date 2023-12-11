extends CharacterBody3D
class_name Munchme

@export var resource: MunchmeResource
@export var situation: Constants.Situation = Constants.Situation.Overworld
@export var freeze := false
@export var player_controlled := false
@export_range(0.0, 1.0) var move_input_deadzone: float = 0.15
@export_range(0.0, 10.0) var height: float = 0.75


var is_in_area = false
var can_catch = false
var in_catch_mode = false
var player: Node3D = null
var move_input

var camera: Node3D

signal catch_munchme(munchme: Munchme)
signal finish_catch(win: bool)


func _ready():
	if situation == Constants.Situation.Overworld:
		$OverworldMovement.spherical_gravity = true
		var root = get_parent().get_parent()
		if root != null:
			catch_munchme.connect(root._on_catch_munchme)
	elif situation == Constants.Situation.Catch:
		get_parent().start_minigame.connect(_on_start_minigame)
		if not finish_catch.is_connected(get_parent()._on_munchme_finish_catch):
			finish_catch.connect(get_parent()._on_munchme_finish_catch)
	elif situation == Constants.Situation.Interact:
		$OverworldMovement.spherical_gravity = true
		player_controlled = true
	
	munchme_specific_ready()


func get_move_input() -> Vector3:
	if camera == null:
		return Vector3.ZERO
	var raw_move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Vector2.ZERO.distance_to(raw_move_input) > 1.0:
		raw_move_input = raw_move_input.normalized()
	if Vector2.ZERO.distance_to(raw_move_input) < ProjectSettings.get_setting("global/leftstick_deadzone") * sqrt(2.0):
		raw_move_input = Vector2.ZERO
	var right_axis = Math.project_direction_on_plane(camera.global_transform.basis.x.normalized(), up_direction)
	var forward_axis = Math.project_direction_on_plane(camera.global_transform.basis.z.normalized(), up_direction)
	var x_axis = Math.project_direction_on_plane(right_axis, $OverworldMovement.floor_normal)
	var z_axis = Math.project_direction_on_plane(forward_axis, $OverworldMovement.floor_normal)
	return x_axis * raw_move_input.x + z_axis * raw_move_input.y


func munchme_specific_ready():
	pass


func _process(delta):
	if situation == Constants.Situation.Overworld:
		_overworld_process(delta)


func _physics_process(delta):
	if freeze:
		return
	if GameState.is_munchme_active(self) and situation == Constants.Situation.Interact:
		$OverworldMovement.move_input = get_move_input()
	else:
		$OverworldMovement.move_input = Vector3.ZERO
	if not player_controlled:
		$OverworldMovement.move_input = $AiMovement.get_move_direction()
	$OverworldMovement._overworld_physics_process(delta)


func _overworld_process(delta):
	if in_catch_mode:
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
	
	if Input.is_action_just_pressed("interact") and can_catch:
		attempt_catch()


func _on_catch_area_body_entered(body):
	is_in_area = true
	player = body


func _on_catch_area_body_exited(body):
	is_in_area = false
	can_catch = false
	$CatchText.visible = false


func attempt_catch():
	in_catch_mode = true
	emit_signal("catch_munchme", self)


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
	$Model.change_animation(anim)


func set_follow_points(_points: Array[Vector3]):
	$AiMovement.set_follow_points(_points)
