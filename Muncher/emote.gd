@tool
extends Node3D
class_name Emote

var emote_resources = {
	Constants.Emote.Question: load("res://Sprites/emote_bubble_question.png"),
	Constants.Emote.Exclamation: load("res://Sprites/emote_bubble_exclamation.png"),
	Constants.Emote.Happy: load("res://Sprites/emote_bubble_happy.png"),
	Constants.Emote.Mad: load("res://Sprites/emote_bubble_mad.png"),
}

@export var play: bool:
	set(value):
		play_animation()

@export var emote: Constants.Emote = Constants.Emote.Question:
	set(value):
		var emote_instance = get_node("Path1/Follower/Emote")
		if emote_instance == null:
			return
		
		emote_instance.texture = emote_resources[value]
		emote = value


func play_animation():
	var path = $Path1
	var follower = path.get_node("Follower") as PathFollow3D
	var animation_player = path.get_node("AnimationPlayer") as AnimationPlayer
	
	rotate_y(randf_range(0, PI * 2))
	animation_player.play("emote")
	
	animation_player.animation_finished.connect(func (animation_name): queue_free())
