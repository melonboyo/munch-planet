extends Control


var tutorial_scene = preload("res://Main.tscn")
var main_scene = preload("res://Main.tscn")


func _on_start_button_button_up():
	get_tree().change_scene_to_packed(main_scene)
