extends Main


@export var play_from_scene := 0
@export var play_from_seconds := 0.0


func planet_specific_ready():
	GameState.water_height = 0.0
	if GameState.during_intro:
		%Muncher.player_controlled = false
	GameState.situation = Constants.Situation.Overworld
	
	$Cutscene.play(play_from_scene, play_from_seconds)
