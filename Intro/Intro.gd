extends Main


func planet_specific_ready():
	GameState.water_height = 0.0
	if GameState.during_intro:
		pass
	GameState.situation = Constants.Situation.Overworld
