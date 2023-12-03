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
	%RockButton.mouse_filter = MOUSE_FILTER_STOP
	%PaperButton.mouse_filter = MOUSE_FILTER_STOP
	%ScissorsButton.mouse_filter = MOUSE_FILTER_STOP


func disable():
	%RockButton.mouse_filter = MOUSE_FILTER_IGNORE
	%RockButton.button_pressed = false
	%PaperButton.mouse_filter = MOUSE_FILTER_IGNORE
	%PaperButton.button_pressed = false
	%ScissorsButton.mouse_filter = MOUSE_FILTER_IGNORE
	%ScissorsButton.button_pressed = false


func play_animation(anim):
	$Animation.play(anim)
