extends Node3D


func _ready():
	for m in GameState.munchmes:
		var munchme: Munchme = Scenes.munchmes[m.munchme_type].instantiate()
		munchme.resource = m
		munchme.situation = Constants.Situation.Manage
		add_child(munchme)
