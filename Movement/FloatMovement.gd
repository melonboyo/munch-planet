extends Node
class_name FloatMovement


@export_node_path("CharacterBody3D") var target_path
@export var float_force := 1.0
@export var character_height := 1.2

@onready var target: Node3D = get_node(target_path)
const water_height = 86.058
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func get_float_velocity(delta) -> Vector3:
	var situation = GameState.situation
	if target is Munchme:
		situation = target.situation
	if situation != Constants.Situation.Overworld:
		return Vector3.ZERO
	var depth = water_height - target.global_position.length() - character_height*0.5
	if depth > 0:
		return target.up_direction * depth * float_force * delta
	else:
		return Vector3.ZERO


func is_floating() -> bool:
	var situation = GameState.situation
	if target is Munchme:
		situation = target.situation
	if situation != Constants.Situation.Overworld:
		return false
	var depth = water_height - target.global_position.length() - character_height*0.5
	return depth > 0
