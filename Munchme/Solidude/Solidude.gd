extends Munchme
class_name Solidude


var walk_sound = preload("res://SFX/Step/stone_scrape.ogg")
var death_sound = preload("res://SFX/owowowow.ogg")
var punch_sounds = [
	preload("res://SFX/Minigames/punch_1.ogg"),
	preload("res://SFX/Minigames/punch_2.ogg"),
	preload("res://SFX/Minigames/punch_3.ogg"),
	preload("res://SFX/Minigames/punch_4.ogg"),
]

const REQUIRED_PUNCHES = 100

var times_punched = 0


func munchme_specific_ready():
	#$Animation.play("RESET")
	if situation == Constants.Situation.Catch:
		times_punched = 0
	
	step_sounds.append(walk_sound)


func start_minigame():
	await get_tree().create_timer(0.8).timeout
	$SolidudeMinigame.play_animation("start")
	$SolidudeMinigame.enable()
	$SolidudeMinigame.visible = true


func _on_solidude_minigame_punched():
	get_parent().rotate_camera_randomly()
	get_parent().shake_camera()
	$Animation.play("punched")
	times_punched += 1
	
	if times_punched >= REQUIRED_PUNCHES:
		player_win()
		$PunchedAudioPlayer.stream = death_sound
		$PunchedAudioPlayer.play()
	else:
		$PunchedAudioPlayer.stream = punch_sounds.pick_random()
		$PunchedAudioPlayer.play()
		
		$PunchedHitAudioPlayer.pitch_scale = min(float(times_punched - 1) / 12 + 1, 2)
		$PunchedHitAudioPlayer.play()


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
