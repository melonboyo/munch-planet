extends Munchme
class_name Dipshit


func munchme_specific_ready():
	pass


func start_minigame():
	$DipshitMinigame.drop_ball()
	%WinTimer.start()
	$DipshitMinigame.visible = true


func _on_dipshit_minigame_ball_dropped():
	finish_catch.emit(false)


func _on_win_timer_timeout():
	finish_catch.emit(true)
