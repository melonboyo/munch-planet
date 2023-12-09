extends Node3D


var ui_scenes := {
	Constants.Munchme.Goby : load("res://Munchme/Minigames/GobyMinigameUI.tscn"),
}

@export var munchme_resource: MunchmeResource = null

@export_node_path("Looker") var looker_path
@onready var looker: Looker = get_node(looker_path)

var munchme_added = false
var munchme: Munchme

signal start_minigame
signal finish_catch(win: bool)


func _ready():
	var main_node = find_parent("Main")
	finish_catch.connect(main_node._on_munchme_finish_catch)
	Music.switch_to(munchme.resource.catch_track)
	
	$Animation.play("enter")


func add_munchme():
	var munchme_scene: Munchme = Scenes.munchmes[munchme_resource.munchme_type].instantiate()
	munchme_scene.resource = munchme_resource
	munchme_scene.situation = Constants.Situation.Catch
	munchme_scene.finish_catch.connect(_on_munchme_finish_catch)
	munchme = munchme_scene
	add_child(munchme_scene)
	munchme_added = true


func _on_animation_animation_finished(anim_name):
	if anim_name == "enter":
		start_minigame.emit()


func _on_munchme_finish_catch(win: bool):
	finish_catch.emit(win)
	looker.close()
	Music.switch_to(Music.Track.Overworld)


func close():
	pass
