extends Control


signal shot(win: bool)

var is_waiting: bool = true
var can_shoot: bool = false


func start_game():
	var ready_time = randf_range(6.0, 8.0)
	$ReadyTimer.wait_time = ready_time
	$ReadyTimer.start()
	$Animation.play("enter_ready")
	can_shoot = true
	is_waiting = true


func _input(event):
	if (
		event is InputEventMouseButton 
		and event.get_button_index() == MOUSE_BUTTON_LEFT
		and event.is_pressed() 
		and GameState.situation == Constants.Situation.Catch
	):
		shoot()


func shoot():
	if not can_shoot:
		return
	
	if is_waiting:
		shot.emit(false)
	else:
		shot.emit(true)


func _on_ready_timer_timeout():
	is_waiting = false
	$ShootTimer.wait_time = randf_range(0.16, 0.3)
	$ShootTimer.start()
	$ReadyText.play("shoot")


func _on_shoot_timer_timeout():
	shot.emit(false)
