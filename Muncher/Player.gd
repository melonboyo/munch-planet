extends CharacterBody3D
class_name Muncher


@export_node_path("Node3D") var camera_path: NodePath
@export_range(0.0, 1.0) var move_input_deadzone: float = 0.15
@export_range(0.0, 10.0) var height: float = 1.8
@export var player_controlled: bool = true

@onready var camera: Node3D = get_node_or_null(camera_path)
@onready var emoter = $Emoter as Emoter
var sitting = false

var move_input = Vector3.ZERO


func _ready():
	var deadzone = ProjectSettings.get_setting("global/leftstick_deadzone")
	InputMap.action_set_deadzone("move_right", deadzone)
	InputMap.action_set_deadzone("move_left", deadzone)
	InputMap.action_set_deadzone("move_up", deadzone)
	InputMap.action_set_deadzone("move_right", deadzone)


func _process(delta):
	if Input.is_action_just_pressed("emote_1"):
		emoter.play_emote(Constants.Emote.Exclamation)
	if Input.is_action_just_pressed("emote_2"):
		emoter.play_emote(Constants.Emote.Happy)
	if Input.is_action_just_pressed("emote_3"):
		emoter.play_emote(Constants.Emote.Question)
	if Input.is_action_just_pressed("emote_4"):
		emoter.play_emote(Constants.Emote.Mad)
	move_input = get_move_input()


func get_move_input() -> Vector3:
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


func _physics_process(delta):
	#print($AiMovement.has_reached_end)
	$Model.is_on_floor = is_on_floor()
	if GameState.focus_main and GameState.situation == Constants.Situation.Overworld and not GameState.during_intro:
		$OverworldMovement.move_input = move_input
	else:
		$OverworldMovement.move_input = Vector3.ZERO
	if not player_controlled:
		$OverworldMovement.move_input = $AiMovement.get_move_direction()
		#print($OverworldMovement.move_input)
	$OverworldMovement._overworld_physics_process(delta)
	#print(velocity, ", ", is_on_floor(), ", ")


func set_follow_points(_points: Array[Vector3]):
	$AiMovement.set_follow_points(_points)


func walk_to_phone():
	set_follow_points([Vector3(-2.05, 9.98, 1.67)])


func walk_outside():
	set_follow_points([Vector3(3.964, 9.984, 1.665)])


func sit(yes = true):
	sitting = yes


func grab_phone(yes: bool = true):
	if yes:
		$Model.play_animation("PickUpPhone")
	else:
		$Model.play_animation_backwards("PickUpPhone")
	$Model.set_animation_speed_scale(1.0)
	await get_tree().create_timer(0.05).timeout
	$Model.grab_phone(yes)


func set_is_movement_animating(yes: bool):
	$OverworldMovement.is_animating = yes
