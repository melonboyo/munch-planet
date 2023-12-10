extends Node3D


@export_node_path("Looker") var looker_path
@onready var looker = get_node(looker_path)


func _ready():
	$Camera.for_munchme = true
	GameState.focus_main = false
	# GET MUNCHME


func get_camera() -> Node3D:
	return $Camera


func _on_deploy_looker_focus_entered():
	GameState.focus_main = false
	GameState.change_focus_to(looker)
	$Camera.enable = true


func _on_deploy_looker_focus_exited():
	$Camera.enable = false


func _on_close_looker():
	GameState.retrieve_munchme_from_looker(looker)
