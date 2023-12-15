extends Munchme
class_name Solidude


@export_range(1, 1000) var required_punches := 100
@export_range(1, 50) var smash_acceleration := 200.0


var walk_sound = preload("res://SFX/Step/stone_scrape.ogg")
var death_sound = preload("res://SFX/owowowow.ogg")
var punch_sounds = [
	preload("res://SFX/Minigames/punch_1.ogg"),
	preload("res://SFX/Minigames/punch_2.ogg"),
	preload("res://SFX/Minigames/punch_3.ogg"),
	preload("res://SFX/Minigames/punch_4.ogg"),
]

var times_punched := 0

var smashing := false


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
	
	if times_punched >= required_punches:
		player_win()
		$PunchedAudioPlayer.stream = death_sound
		$PunchedAudioPlayer.play()
	else:
		$PunchedAudioPlayer.stream = punch_sounds.pick_random()
		$PunchedAudioPlayer.play()
		
		$PunchedHitAudioPlayer.pitch_scale = min(float(times_punched - 1) / 12 + 1, 2)
		$PunchedHitAudioPlayer.play()


func _munchme_specific_process(delta: float):
	if player_controlled:
		_player_controlled_process(delta) 


func _player_controlled_process(delta: float):
	if not smashing and $OverworldMovement.steps_since_grounded > 10 and Input.is_action_just_pressed("use_power"):
		smashing = true
	
	if smashing:
		var smash_acceleration = $OverworldMovement.get_up_direction() * -smash_acceleration * delta
		$OverworldMovement.gravity_velocity += smash_acceleration
	
	if smashing and is_on_floor():
		perform_smash()


func perform_smash():
	smashing = false
	
	# Try to find a smashable node from a static body 
	# NOTE: The parent needs a smash() method that returns int (times smashed)
	var smashable_body = get_smashable_node()
	if smashable_body == null:
		$PunchedHitAudioPlayer.pitch_scale = 1
	else:
		var times_smashed = smashable_body.smash()
		$PunchedHitAudioPlayer.pitch_scale = min(float(times_smashed - 1) / 12 + 1, 2)
		
	$PunchedHitAudioPlayer.play()


func get_smashable_node():
	for body in $SmashArea.get_overlapping_bodies():
		var parent = body.get_parent()
		if parent != null and parent.has_method("smash"):
			return parent
	
	return null


func player_win():
	$SolidudeMinigame.disable()
	$SolidudeMinigame.visible = false
	$Animation.play("death")
	await get_tree().create_timer(3).timeout
	win_catch()
