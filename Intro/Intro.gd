extends Main


@export var play_from_scene := 0
@export var play_from_seconds := 0.0
@export var play_intro := true

var main_scene = preload("res://Main.tscn")


func planet_specific_ready():
	GameState.during_intro = play_intro
	if not play_intro:
		$Overlay/CircleTransition.material.set_shader_parameter("circle_size", 1.05)
		play_postlude()
	
	GameState.water_height = 0.0
	if GameState.during_intro:
		%Muncher.player_controlled = false
		manage_allowed = false
		$Cutscene.play(play_from_scene, play_from_seconds)
	
	GameState.situation = Constants.Situation.Overworld


func play_intro_music():
	Music.play(Music.Track.Intro)


func stop_intro_music():
	Music.stop(false)


func play_postlude():
	Music.play(Music.Track.Postlude)


func stop_postlude():
	Music.stop()


func _on_cutscene_animation_animation_finished(anim_name):
	if anim_name == "Intro_2":
		#GameState.during_intro = false
		manage_allowed = true
		pass
	
	if anim_name == "Enter_Rocket_1":
		get_tree().change_scene_to_packed(main_scene)


func walk_to_phone():
	%Muncher.set_follow_point(%Phone)


func walk_outside():
	%Muncher.set_follow_point(%Outside)


func _on_rocket_go():
	%Muncher.player_controlled = false
	manage_allowed = false
	$RocketCutscene.play()


func ready_for_rocket():
	%Muncher.global_position = $FollowPoints/Rocket.global_position
	await get_tree().physics_frame
	%Muncher.rotate_towards($FollowPoints/Rocket2.global_position)


func walk_to_rocket():
	%Muncher.set_follow_point($FollowPoints/Rocket2)


func set_focus_to_rocket():
	%RocketCamera.focus = %Rocket
