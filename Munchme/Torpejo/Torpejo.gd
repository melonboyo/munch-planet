extends Munchme
class_name Torpejo


signal torpejo_talked_to

var is_talkable := false # can be talked to at all
var can_talk := false # player is in the talk area and is pointing towards him
var is_talking := false # is during a dialogue
var in_talk_area := false # player is in the talk area
var talk_player: CharacterBody3D


func _munchme_specific_process(delta):
	is_talking = CutsceneManager.is_scene_playing
	#print(is_talkable, ", ", is_talking)
	if is_talking or not is_talkable:
		$TalkArea.monitoring = false
		return
	$TalkArea.monitoring = true
	if in_talk_area and talk_player != null:
		var direction = talk_player.global_transform.basis.z
		var direction_towards_me = (global_position - talk_player.global_position).normalized()
		if direction.angle_to(direction_towards_me) < 0.45*PI:
			can_talk = true
		else:
			can_talk = false
	else:
		can_talk = false
	
	if Input.is_action_just_pressed("interact") and can_talk and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		talk()


func _on_talk_area_body_entered(body):
	in_talk_area = true
	talk_player = body
	$TalkText.visible = true


func _on_talk_area_body_exited(body):
	in_talk_area = false
	can_talk = false
	$TalkText.visible = false


func talk():
	is_talkable = false
	torpejo_talked_to.emit()
