extends AnimatedSprite3D


func _process(delta):
	if CutsceneManager.is_dialogue_playing:
		if animation == "yap":
			return
		play("yap")
	else:
		if animation == "shut":
			return
		play("shut")
