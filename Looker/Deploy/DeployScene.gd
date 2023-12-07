extends Node3D


func _looker_ready():
	$Camera.for_munchme = true
	$Ccamera.focus = GameState.deployed_munchme
