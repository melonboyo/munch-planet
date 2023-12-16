extends Node3D

signal snake_entered(snake: Snake)

func _on_area_3d_body_entered(body):
	if body is Snake:
		snake_entered.emit(body)
