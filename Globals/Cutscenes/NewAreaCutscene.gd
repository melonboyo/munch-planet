extends Node3D

signal cutscene_started
signal cutscene_finished

@export var has_visited := false


var previous_track: PlayingTrack


func _on_enter_area_body_entered(body):
	# Muncher entered
	if has_visited:
		return
	
	previous_track = Music.stop()
	
	has_visited = true
	$Cutscene.play()
	$Camera3D.current = true
	CutsceneManager.cutscene_finished.connect(_on_cutscene_finished)
	$JinglePlayer.play()
	cutscene_started.emit()


func _on_cutscene_finished():
	Music.play(previous_track.track, previous_track.position)
	cutscene_finished.emit()
