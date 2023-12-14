extends Node3D


@export_node_path("Looker") var looker_path
@onready var looker = get_node(looker_path)


func _ready():
	if GameState.tutorial_stage == Constants.TutorialStage.GuildEntered:
		$TutorialCutscene.play()
		return
	$Torpejo.queue_free()
	$EnterCutscene.play()


func _on_deploy_looker_focus_entered():
	#GameState.focus_main = false
	$Camera.enable = true


func _on_deploy_looker_focus_exited():
	$Camera.enable = false


func walk_in():
	$Muncher.set_vector_follow_point($WalkHere.global_position, false)


func torpejo_walk_out():
	$Torpejo.set_vector_follow_point($ExitPoint.global_position, false)


func player_walk_out():
	$Muncher.set_vector_follow_point($ExitPoint.global_position, false)


func step_aside():
	$Muncher.set_vector_follow_point($WalkHere2.global_position, false)


func turn_to_torpejo():
	$Muncher.rotate_towards($Torpejo.global_position)


func _on_enter_guild_area_body_entered(body):
	exit()


func exit():
	%OverlayAnimation.play("fade_out")
	$Muncher.player_controlled = false
	await get_tree().process_frame
	player_walk_out()
	await get_tree().create_timer(0.7).timeout
	GameState.exit_guild_looker.emit()
	looker.close()
