extends Node3D


func _looker_ready():
	GameState.munchme_added.connect(_on_munchme_added)
	for m in GameState.munchmes:
		send_in_munchme(m, get_random_position())


func send_in_munchme(munchme_resource: MunchmeResource, pos: Vector3):
	var munchme: Munchme = Scenes.munchmes[munchme_resource.munchme_type].instantiate()
	munchme.resource = munchme_resource
	munchme.situation = Constants.Situation.Manage
	munchme.position = pos
	add_child(munchme)


func get_random_position():
	return Vector3(randf_range(-3.8,3.8), 0, randf_range(-2.5,4.1))


func _on_munchme_added(resource: MunchmeResource):
	send_in_munchme(resource, get_random_position() + Vector3.UP * 6.0)
