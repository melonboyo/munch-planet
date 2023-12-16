extends Munchme
class_name Gungun


func munchme_specific_ready():
	if situation == Constants.Situation.Catch:
		$GungunMinigame.visible = true
	else:
		$GungunMinigame.visible = false


func _on_gungun_minigame_shot(win):
	if win:
		win_catch()
	else:
		lose_catch()


func start_minigame():
	await get_tree().create_timer(0.8).timeout
	$GungunMinigame.start_game()
