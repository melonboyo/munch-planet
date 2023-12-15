extends Node3D
class_name MunchmeModel


signal step

var is_on_floor = false


func _ready():
	interpolation_change($AnimationPlayer)


func interpolation_change(anim: AnimationPlayer):
	for a in anim.get_animation_list():
		var anim_track = anim.get_animation(a) 
		var count = anim_track.get_track_count() # get number of tracks (bones in your case)
		for i in count:
			anim_track.track_set_interpolation_type(i, 0) # change interpolation mode for every track


func play_animation(anim: String):
	if anim == $AnimationPlayer.current_animation:
		return
	$AnimationPlayer.play(anim)


func set_animation_speed_scale(value: float):
	$AnimationPlayer.speed_scale = value


func has_animation(anim: String) -> bool:
	return $AnimationPlayer.has_animation(anim)


func emit_step():
	step.emit()
