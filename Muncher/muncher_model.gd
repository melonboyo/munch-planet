extends Node3D


var step_sounds := [
	load("res://SFX/Step/step_mid1.ogg"),
	load("res://SFX/Step/step_mid2.ogg"),
	load("res://SFX/Step/step_mid3.ogg"),
	load("res://SFX/Step/step_mid4.ogg"),
]

var is_on_floor = false


func _ready():
	interpolation_change($AnimationPlayer)


func interpolation_change(anim: AnimationPlayer):
	for a in anim.get_animation_list():
		var anim_track = anim.get_animation(a) 
		var count = anim_track.get_track_count() # get number of tracks (bones in your case)
		for i in count:
			anim_track.track_set_interpolation_type(i, 0) # change interpolation mode for every track
#			print(anim_track.track_get_interpolation_type(i))
#	var anim_track_1 = anim.get_animation("Run") # get the Animation that you are interested in (change "default" to your Animation's name)
	
#		print(anim_track_1.track_get_interpolation_type(i))


func change_animation(anim: String):
	if anim == $AnimationPlayer.current_animation:
		return
	$AnimationPlayer.play(anim)


func set_animation_speed_scale(value: float):
	$AnimationPlayer.speed_scale = value


func play_step_sound():
	if not is_on_floor:
		return
	var i = randi_range(0, step_sounds.size()-1)
	$StepPlayer.stream = step_sounds[i]
	$StepPlayer.play()


func grab(item: Node3D, left: bool = true):
	if left:
		%HandAttachment.bone_name = "WingEnd.L"
		%HandAttachment.bone_idx = 14
	else:
		%HandAttachment.bone_name = "WingEnd.R"
		%HandAttachment.bone_idx = 17
	
	item.reparent(%HandAttachment)
	item.position = Vector3.ZERO
