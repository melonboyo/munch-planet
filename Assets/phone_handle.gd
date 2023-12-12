extends Node3D


var first_sound := true
var play_sound_1 := load("res://SFX/Intro/ring_1.ogg")
var play_sound_2 := load("res://SFX/Intro/ring_2.ogg")


func ring():
	$AnimationPlayer.play("ring")
	$PhoneHandle/AnimatedSprite3D.play("awake")
	if first_sound:
		$AudioPlayer.stream = play_sound_1
	else:
		$AudioPlayer.stream = play_sound_2
	first_sound = not first_sound
	$AudioPlayer.play()


func pick_up():
	$AnimationPlayer.play("RESET")
	$PhoneHandle/AnimatedSprite3D.play("yapping")
	$AudioPlayer.stop()


func put_down():
	$AnimationPlayer.play("RESET")
	$PhoneHandle/AnimatedSprite3D.play("sleep")
