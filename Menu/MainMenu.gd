extends Control


var intro_scene = preload("res://Intro/Intro.tscn")
var main_scene = preload("res://Main.tscn")


func _on_start_button_button_up():
	get_tree().change_scene_to_packed(intro_scene)
