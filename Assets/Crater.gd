extends Node3D


var snake: Snake


var previous_track: PlayingTrack


func _on_pipe_snake_entered(snake):
	self.snake = snake
	snake.visible = false
	previous_track = Music.stop()
	for looker in GameState.open_lookers:
		looker.visible = false
	$CatchSolidudeCutscene.play()


func _on_catch_solidude_cutscene_cutscene_finished():
	Music.play(previous_track.track, previous_track.position)
	snake.global_position = %SolidudeCutsceneSnake.global_position
	for looker in GameState.open_lookers:
		looker.visible = true
		looker.grab_focus()
	snake.visible = true
