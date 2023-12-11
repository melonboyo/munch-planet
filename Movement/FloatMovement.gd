extends Node
class_name FloatMovement


@export_node_path("CharacterBody3D") var target_path
@export var float_force := 1.0

@onready var target: CharacterBody3D = get_node(target_path)
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func get_float_velocity(delta: float, velocity: Vector3) -> Vector3:
	var situation = GameState.situation
	if target is Munchme:
		situation = target.situation
	if situation == Constants.Situation.Catch or situation == Constants.Situation.Manage:
		return Vector3.ZERO
	var depth = GameState.water_height - target.global_position.length() - target.height*0.5
	if depth > 0:
		var res = target.up_direction * depth * float_force * delta
		var velocity_up_project = velocity.project(target.up_direction)
		if (
			velocity.normalized().angle_to(target.up_direction) >= 0.5*PI and 
			velocity_up_project.length() > 6.0
		):
			res += target.up_direction * depth * float_force * delta * 0.25 * velocity_up_project.length()
		elif (
			velocity.normalized().angle_to(target.up_direction) < 0.5*PI and 
			velocity_up_project.length() > 1.3
		):
			res -= target.up_direction * depth * float_force * delta * 0.18
		return res
	else:
		return Vector3.ZERO


func is_floating() -> bool:
	var situation = GameState.situation
	if target is Munchme:
		situation = target.situation
	if situation != Constants.Situation.Overworld:
		return false
	var depth = GameState.water_height - target.global_position.length() - target.height*0.5
	return depth > 0
