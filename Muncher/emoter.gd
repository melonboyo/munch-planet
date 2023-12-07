extends Node3D
class_name Emoter

@onready var emote_scene = preload("res://Muncher/emote.tscn")


func play_emote(emote: Constants.Emote):
	var emote_instance = emote_scene.instantiate() as Emote
	emote_instance.emote = emote
	add_child(emote_instance)
	emote_instance.play_animation()
