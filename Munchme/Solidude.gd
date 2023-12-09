extends Munchme
class_name Solidude


const REQUIRED_PUNCHES = 10

var times_punched = 0


func munchme_specific_ready():
	$Animation.play("RESET")
	if situation == Constants.Situation.Catch:
		times_punched = 0


func start_minigame():
	await get_tree().create_timer(0.8).timeout
	$GobyMinigameUi.play_animation("start")
	$GobyMinigameUi.enable()
	$GobyMinigameUi.visible = true


func _on_punch():
	times_punched += 1
	if times_punched >= REQUIRED_PUNCHES:
		player_win()


func goby_win():
	$GobyMinigameUi.disable()
	$GobyMinigameUi.visible = false
	await get_tree().create_timer(0.7).timeout
	lose_catch()


func player_win():
	$GobyMinigameUi.disable()
	$GobyMinigameUi.visible = false
	await get_tree().create_timer(0.7).timeout
	win_catch()
