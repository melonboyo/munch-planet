extends Node
class_name TutorialMusic

const BPM := 140
const MEASURES := 4
const BEATS_PER_MEASURE := 4
const END_CUT_INDEX := 6

# Essentially the length of half of the cut. We duplicate
# the cut in the audio file for seamless looping
const cut_length := (60.0 / BPM) * MEASURES * BEATS_PER_MEASURE

var is_playing := false
var current_cut := 0


func _process(delta: float):
	if current_cut >= END_CUT_INDEX:
		queue_free()
		return
	
	# If past the first half of the cut, loop back one half
	if Music.position > get_cut_start_position(current_cut) + cut_length:
		Music.music_player.seek(Music.position - cut_length)


func get_cut_start_position(cut_index: int):
	return cut_length * cut_index * 2


func play(cut_index: int = 0):
	current_cut = cut_index
	Music.play(Music.Track.Tutorial, get_cut_start_position(cut_index))


func progress():
	current_cut += 1
	
	# Switch to the second part of the cut
	Music.music_player.seek(Music.position + cut_length)
