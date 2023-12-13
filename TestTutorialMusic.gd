extends Node2D

var stage = Constants.TutorialStage.Landed

func _process(delta):
	if Input.is_action_just_pressed("emote_1"):
		$TutorialMusic.play(stage)
	if Input.is_action_just_pressed("emote_2"):
		stage += 1 
		$TutorialMusic.go_to(stage)


func _on_tutorial_music_finale():
	print("started finale!")
