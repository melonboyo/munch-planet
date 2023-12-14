extends Node
class_name TutorialMusic

signal finale

const BPM := 140
const MEASURES := 4
const BEATS_PER_MEASURE := 4
const START_TUTORIAL_STAGE = Constants.TutorialStage.Landed
const END_TUTORIAL_STAGE := Constants.TutorialStage.Kidnapped


# Essentially the length of half of the cut. We duplicate
# the cut in the audio file for seamless looping
const cut_length := (60.0 / BPM) * MEASURES * BEATS_PER_MEASURE

var current_cut := 0
var has_emitted_final_cut := false


func _process(delta: float):
	if current_cut >= END_TUTORIAL_STAGE - START_TUTORIAL_STAGE:
		if not has_emitted_final_cut and Music.position > get_cut_start_position(current_cut):
			finale.emit()
			has_emitted_final_cut = true
		return
	
	# If past the first half of the cut, loop back one half
	if Music.position > get_cut_start_position(current_cut) + cut_length:
		Music.music_player.seek(Music.position - cut_length)


func get_cut_start_position(cut_index: int):
	return cut_length * cut_index * 2


func play(tutorial_stage: Constants.TutorialStage = Constants.TutorialStage.Landed):
	if tutorial_stage == Constants.TutorialStage.NotStarted:
		return
	
	current_cut = tutorial_stage - START_TUTORIAL_STAGE
	Music.play(Music.Track.Tutorial, get_cut_start_position(current_cut))


func go_to(tutorial_stage: Constants.TutorialStage):
	if tutorial_stage == Constants.TutorialStage.NotStarted:
		return
	
	if tutorial_stage == Constants.TutorialStage.Finished:
		queue_free()
	
	var cut = tutorial_stage - START_TUTORIAL_STAGE
	if cut <= current_cut:
		return
	
	current_cut = cut

	# Switch to the second part of the cut
	Music.music_player.seek(Music.position + cut_length)
