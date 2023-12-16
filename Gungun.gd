extends Munchme
class_name Gungun


func _on_gungun_minigame_shot(win):
	if win:
		win_catch()
	else:
		lose_catch()


func start_minigame():
	$GungunMinigame.visible = true
	$GungunMinigame.start_game()
