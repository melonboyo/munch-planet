extends Control


func _process(delta):
	queue_redraw()


var draw_position = Vector2.ZERO


func _draw():
	draw_circle(draw_position, 3.0, Color.DARK_RED)
