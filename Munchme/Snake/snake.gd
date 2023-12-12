extends Munchme
class_name Snake


func munchme_specific_ready():
	if situation == Constants.Situation.Catch:
		pass # SMILE :)


func start_minigame():
	await get_tree().create_timer(0.8).timeout
	#$SnakeMinigame.play_animation("start")
	$SnakeMinigame.enable()
	$SnakeMinigame.visible = true


func _on_snake_minigame_grabbed(hand: Constants.SnakeHand):
	get_parent().shake_camera()
	# BE HAPPY :)


func _on_snake_minigame_win():
	player_win()


func _on_snake_minigame_failed():
	snake_win()


func snake_win():
	$SnakeMinigame.disable()
	$SnakeMinigame.visible = false
	await get_tree().create_timer(0.7).timeout
	lose_catch()


func player_win():
	$SnakeMinigame.disable()
	await get_tree().create_timer(1.5).timeout
	$SnakeMinigame.visible = false
	#$Animation.play("death")
	await get_tree().create_timer(0.8).timeout
	win_catch()
