extends TextureButton

@export var has_snake: bool:
	get: return disabled
	set(value): disabled = value


func is_grabbing_snake(snake: Node):
	return $CatchArea.overlaps_area(snake.get_node("CatchArea"))
