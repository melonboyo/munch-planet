extends SubViewportContainer


var munchme: MunchmeResource


func add_munchme(resource: MunchmeResource):
	var munchme_scene: Munchme = Scenes.munchmes[resource.munchme_type].instantiate()
	munchme_scene.resource = resource
	munchme = resource
	$SubViewport/DeployableMunchmeScene.add_child(munchme_scene)
