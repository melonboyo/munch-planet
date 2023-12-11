extends Node3D


func ring():
	$AnimationPlayer.play("ring")
	$PhoneHandle/AnimatedSprite3D.play("awake")


func pick_up():
	$AnimationPlayer.play("RESET")
	$PhoneHandle/AnimatedSprite3D.play("yapping")


func put_down():
	$AnimationPlayer.play("RESET")
	$PhoneHandle/AnimatedSprite3D.play("sleep")
