extends Node3D


func _process(delta):
	rotate_y(delta * 0.06*PI)
