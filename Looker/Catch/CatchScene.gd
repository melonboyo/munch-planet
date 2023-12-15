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
	setup_graphics_detail()
	Settings.changed.connect(setup_graphics_detail)
	var main_node = find_parent("Main")
	finish_catch.connect(main_node._on_munchme_finish_catch)
	looker.music_track = munchme.resource.catch_track
	looker.window_width = munchme.resource.catch_looker_size.x
	looker.window_height = munchme.resource.catch_looker_size.y
	
	$Animation.play("enter")


func setup_graphics_detail():
	var level = Settings.graphics_detail
	$WorldEnvironment.environment.ssao_enabled = level > Constants.Graphics.Low
	$WorldEnvironment.environment.ssil_enabled = level > Constants.Graphics.Medium
	$WorldEnvironment.environment.sdfgi_enabled = level > Constants.Graphics.Low
	$WorldEnvironment.environment.volumetric_fog_enabled = level > Constants.Graphics.Low


func add_munchme():
	var munchme_scene: Munchme = Scenes.munchmes[munchme_resource.munchme_type].instantiate()
	munchme_scene.resource = munchme_resource
	munchme_scene.situation = Constants.Situation.Catch
	munchme_scene.finish_catch.connect(_on_munchme_finish_catch)
	munchme = munchme_scene
	add_child(munchme_scene)
	munchme_added = true


func rotate_camera_randomly():
	var sign = 1 if %Camera3D.rotation.z > 0 else -1
	%Camera3D.rotation.z = deg_to_rad(randi_range(1, 5)) / 2 * -sign


func shake_camera():
	if $Animation.is_playing():
		$Animation.seek(0)
	else:
		$Animation.play("shake")


func _on_animation_animation_finished(anim_name):
	if anim_name == "enter":
		start_minigame.emit()


func _on_munchme_finish_catch(win: bool):
	finish_catch.emit(win)
	looker.close()


func close():
	pass
