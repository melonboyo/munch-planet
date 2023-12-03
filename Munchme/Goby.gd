extends Munchme
class_name Goby


var goby_hand: Constants.Hand = Constants.Hand.None
var player_hand: Constants.Hand = Constants.Hand.None


func munchme_specific_ready():
	$Animation.play("RESET")
	if situation == Constants.Situation.Catch:
		%RPS.visible = true
	else:
		%RPS.visible = false


func start_minigame():
	await get_tree().create_timer(0.8).timeout
	$Animation.play("RPS")
	$GobyMinigameUi.play_animation("slide_in")
	$GobyMinigameUi.enable()


func _on_player_choose_hand(choice: Constants.Hand):
	player_hand = choice


func choose_hand():
	var i = randi_range(0, 2)
	goby_hand = i as Constants.Hand
	var hand_string = "rock"
	if i == 1:
		hand_string = "paper"
	elif i == 2:
		hand_string = "scissors"
	%RPS.play(hand_string)
	$GobyMinigameUi.disable()
	await get_tree().create_timer(0.8).timeout
	
	if goby_hand == player_hand:
		$Animation.play("RPS")
		%RPS.play("default")
		$GobyMinigameUi.enable()
		return
	
	if (
		(goby_hand == Constants.Hand.Rock and player_hand == Constants.Hand.Scissors) or
		(goby_hand == Constants.Hand.Paper and player_hand == Constants.Hand.Rock) or
		(goby_hand == Constants.Hand.Scissors and player_hand == Constants.Hand.Paper) or
		(player_hand == Constants.Hand.None)
	):
		goby_win()
		return
	
	if (
		(player_hand == Constants.Hand.Rock and goby_hand == Constants.Hand.Scissors) or
		(player_hand == Constants.Hand.Paper and goby_hand == Constants.Hand.Rock) or
		(player_hand == Constants.Hand.Scissors and goby_hand == Constants.Hand.Paper)
	):
		player_win()


func goby_win():
	%RPS.play("gun")
	$GobyMinigameUi.disable()
	$GobyMinigameUi.visible = false
	await get_tree().create_timer(0.7).timeout
	lose_catch()


func player_win():
	%RPS.visible = false
	$GobyMinigameUi.disable()
	$GobyMinigameUi.visible = false
	await get_tree().create_timer(0.7).timeout
	win_catch()
