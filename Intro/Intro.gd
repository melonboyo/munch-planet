extends Main


@export var play_from_scene := 0
@export var play_from_seconds := 0.0


func planet_specific_ready():
	GameState.water_height = 0.0
	if GameState.during_intro:
		%Muncher.player_controlled = false
	GameState.situation = Constants.Situation.Overworld
	
	$Cutscene.play(play_from_scene, play_from_seconds)


func play_intro_music():
	Music.play(Music.Track.Intro)


func stop_intro_music():
	Music.stop(false)


func play_postlude():
	Music.play(Music.Track.Postlude)


func _on_cutscene_animation_animation_finished(anim_name):
	if anim_name == "Intro_2":
		GameState.during_intro = false
