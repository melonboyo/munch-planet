@tool
extends Control


signal ball_dropped

@export_range(0.0, 1920.0, 1.0) var playfield_width := 720.0:
	set(value):
		var viewport_size = 900.0
		playfield_width = value
		if %Left == null or %Right == null:
			return
		var wall_thickness: float = %Left.shape.size.x
		%Left.position.x = -playfield_width * 0.5 - wall_thickness * 0.5
		%Right.position.x = playfield_width * 0.5 + wall_thickness * 0.5

@onready var ball: RigidBody2D = %Ball
@onready var paddle: StaticBody2D = %Paddle

var paddle_position := 0.0:
	set(value):
		var paddle_width = 512.0 * 0.66
		paddle_position = clampf(
			value, -playfield_width*0.5 + paddle_width*0.5, playfield_width*0.5 - paddle_width*0.5
		)
		if paddle == null:
			return
		var viewport_size := get_viewport().get_visible_rect().size
		paddle.position.x = 0.5 * viewport_size.x + paddle_position


func _ready():
	if Engine.is_editor_hint():
		return


func _input(event):
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseMotion:
		paddle_position += event.relative.x * ProjectSettings.get_setting("global/mouse_sensitivity")


func drop_ball():
	ball.freeze = false


func _on_ball_body_entered(body):
	%Ball/Animation.play("bounce")
	if not body is Paddle:
		return
	var angle = Vector2.UP.angle_to((ball.global_position - paddle.global_position).normalized())
	if angle > PI*0.35:
		return
	var y_component = -max(1700.0 - abs(ball.linear_velocity.y), 0.0) * 0.6
	var x_component = 0.0
	if abs(ball.linear_velocity.x) < 300.0:
		x_component = randf_range(300.0, 700.0) * (randi_range(0, 1) * 2.0 - 1.0)
	else:
		x_component = randf_range(100.0, 200.0) * (ball.linear_velocity.x / abs(ball.linear_velocity.x))
	ball.apply_central_impulse(Vector2(x_component, y_component))


func _on_lose_area_body_entered(body):
	ball_dropped.emit()


func _draw():
	if not Engine.is_editor_hint():
		return
	#draw_rect(Rect2())
	
