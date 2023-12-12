extends Munchme
class_name Solidude


const REQUIRED_PUNCHES = 20

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
	get_parent().rotate_camera_randomly()
	get_parent().shake_camera()
	$Animation.play("punched")
	$PunchedAudioPlayer.play()
	times_punched += 1
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
	$Animation.play("death")
	await get_tree().create_timer(3).timeout
	win_catch()
