extends Control


signal shot(win: bool)

var is_waiting: bool = true
var can_shoot: bool = false


func start_game():
	var ready_time = randf_range(2.0, 10.0)
	$ReadyTimer.wait_time = ready_time
	$ReadyTimer.start()
	$Animation.play("enter_ready")
	$Control.mouse_filter = MOUSE_FILTER_STOP
	can_shoot = true
	is_waiting = true


func shoot():
	if not can_shoot:
		return
	
	print("shoot, ", is_waiting)
	
	if is_waiting:
		end(false)
	else:
		end(true)


func _on_ready_timer_timeout():
	is_waiting = false
	$ShootTimer.wait_time = randf_range(0.27, 0.6)
	$ShootTimer.start()
	$ReadyText.play("shoot")


func _on_shoot_timer_timeout():
	$ReadyText.visible = false
	end(false)


func end(win: bool):
	can_shoot = false
	await get_tree().create_timer(0.8).timeout
	visible = false
	shot.emit(win)


func _on_control_gui_input(event):
	if (
		event is InputEventMouseButton 
		and event.get_button_index() == MOUSE_BUTTON_LEFT
		and event.is_pressed() 
		and GameState.situation == Constants.Situation.Catch
		and can_shoot
	):
		shoot()
