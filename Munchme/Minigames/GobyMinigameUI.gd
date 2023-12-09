extends Control


signal player_choose_hand(hand: Constants.Hand)


func _on_rock_button_button_down():
	%ScissorsButton.button_pressed = false
	%PaperButton.button_pressed = false
	player_choose_hand.emit(Constants.Hand.Rock)


func _on_paper_button_button_down():
	%ScissorsButton.button_pressed = false
	%RockButton.button_pressed = false
	player_choose_hand.emit(Constants.Hand.Paper)


func _on_scissors_button_button_down():
	%PaperButton.button_pressed = false
	%RockButton.button_pressed = false
	player_choose_hand.emit(Constants.Hand.Scissors)


func enable():
	%RockButton.button_pressed = false
	%RockButton.mouse_filter = MOUSE_FILTER_STOP
	print(%RockButton.mouse_filter)
	%PaperButton.button_pressed = false
	%PaperButton.mouse_filter = MOUSE_FILTER_STOP
	%ScissorsButton.button_pressed = false
	%ScissorsButton.mouse_filter = MOUSE_FILTER_STOP


func disable():
	%RockButton.mouse_filter = MOUSE_FILTER_IGNORE
	%PaperButton.mouse_filter = MOUSE_FILTER_IGNORE
	%ScissorsButton.mouse_filter = MOUSE_FILTER_IGNORE


func play_animation(anim):
	$Animation.play(anim)
