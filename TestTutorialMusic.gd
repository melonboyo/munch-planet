extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("emote_1"):
		$TutorialMusic.play()
	if Input.is_action_just_pressed("emote_2"):
		$TutorialMusic.progress()
