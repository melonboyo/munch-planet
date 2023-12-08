extends CharacterBody3D
class_name Muncher


@export_node_path("Node3D") var camera_path: NodePath
@export_range(0.0, 1.0) var move_input_deadzone: float = 0.15
@export_range(0.0, 10.0) var height: float = 1.8

@onready var camera: Node3D = get_node_or_null(camera_path)
@onready var emoter = $Emoter as Emoter

var move_input = Vector3.ZERO
@onready var cutscene = preload("res://Globals/Cutscenes/TestCutscene/TestCutscene.tres")


func _ready():
	var deadzone = ProjectSettings.get_setting("global/leftstick_deadzone")
	InputMap.action_set_deadzone("move_right", deadzone)
	InputMap.action_set_deadzone("move_left", deadzone)
	InputMap.action_set_deadzone("move_up", deadzone)
	InputMap.action_set_deadzone("move_right", deadzone)


func _process(delta):
	if Input.is_action_just_pressed("emote_1"):
		emoter.play_emote(Constants.Emote.Exclamation)
		CutsceneManager.play_cutscene(cutscene)
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
	$Model.is_on_floor = is_on_floor()
	if GameState.focus_main and GameState.situation == Constants.Situation.Overworld:
		$OverworldMovement.move_input = move_input
	else:
		$OverworldMovement.move_input = Vector3.ZERO
	$OverworldMovement._overworld_physics_process(delta)
