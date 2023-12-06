extends Node3D
class_name Emoter

@onready var emote_scene = preload("res://Muncher/emote.tscn")


func play_emote(emote: Constants.Emote):
	var emote_instance = emote_scene.instantiate() as Emote
	emote_instance.emote = emote
	add_child(emote_instance)
	emote_instance.play_animation()


func from_to_rotation(from, to) -> Quaternion:
	var angle_to = from.angle_to(to)
	var axis = from.cross(to)
	return Quaternion(axis.normalized(), angle_to)
