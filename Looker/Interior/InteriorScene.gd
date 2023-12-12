extends Node3D


@export_node_path("Looker") var looker_path
@onready var looker = get_node(looker_path)


func _ready():
	#$Camera.for_munchme = false
	GameState.focus_main = false


func _on_deploy_looker_focus_entered():
	GameState.focus_main = false
	GameState.change_focus_to(looker)
	$Camera.enable = true


func _on_deploy_looker_focus_exited():
	$Camera.enable = false


#func _on_close_looker():
	#GameState.retrieve_munchme_from_looker(looker)


func walk_in():
	$Muncher.set_follow_points([$WalkHere.global_position] as Array[Vector3])
