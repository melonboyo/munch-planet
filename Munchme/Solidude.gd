extends Munchme
class_name Solidude


const REQUIRED_PUNCHES = 100

var times_punched = 0


func munchme_specific_ready():
	#$Animation.play("RESET")
	if situation == Constants.Situation.Catch:
		times_punched = 0


func start_minigame():
	await get_tree().create_timer(0.8).timeout
	$SolidudeMinigame.play_animation("start")
	$SolidudeMinigame.enable()
	$SolidudeMinigame.visible = true


func _on_solidude_minigame_punched():
	times_punched += 1
	print(times_punched)
	if times_punched >= REQUIRED_PUNCHES:
		player_win()


func goby_win():
	$SolidudeMinigame.disable()
	$SolidudeMinigame.visible = false
	await get_tree().create_timer(0.7).timeout
	lose_catch()


func player_win():
	$SolidudeMinigame.disable()
	$SolidudeMinigame.visible = false
	await get_tree().create_timer(0.7).timeout
	win_catch()
