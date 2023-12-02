extends Node3D


@export var munchme: MunchmeResource


func _ready():
	$Animation.play("enter")
	if munchme != null:
		add_munchme()


func add_munchme():
	var munchme_scene: Munchme = Scenes.munchmes[munchme.munchme_type].instantiate()
	munchme_scene.resource = munchme
	munchme_scene.situation = Constants.Situation.Catch
	add_child(munchme_scene)
