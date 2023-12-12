extends Node3D

var is_in_area = false
var can_enter = false
var is_entering = false
var player: Node3D = null
var move_input

signal rocket_go


func _process(delta):
	if is_entering:
		%GoText.visible = false
		return
	%EnterRocketArea.monitoring = true
	if is_in_area and player != null:
		var direction = player.global_transform.basis.z
		var direction_towards_me = (global_position - player.global_position).normalized()
		if direction.angle_to(direction_towards_me) < 0.45*PI:
			can_enter = true
		else:
			can_enter = false
	else:
		can_enter = false
	
	%GoText.visible = can_enter
	
	if Input.is_action_just_pressed("interact") and can_enter and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rocket_go.emit()
		is_entering = true
		%EnterRocketArea.monitoring = false


func _on_enter_rocket_area_body_entered(body):
	is_in_area = true
	player = body


func _on_enter_rocket_area_body_exited(body):
	is_in_area = false
	can_enter = false
	%GoText.visible = false


func open_window():
	$Animation.play("OpenWindow")


func close_window():
	$Animation.play("RESET")
