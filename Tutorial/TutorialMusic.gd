extends Node
class_name TutorialMusic

const BPM := 140
const MEASURES := 4
const BEATS_PER_MEASURE := 4
const FIRST_CUT_INDEX := 2
const END_CUT_INDEX := 7

const cut_length := (60.0 / BPM) * MEASURES * BEATS_PER_MEASURE

var is_playing := false
var current_cut := 0
var next_cut := 0


func _process(delta: float):
	if current_cut >= END_CUT_INDEX:
		queue_free()
		return
	
	if get_current_playing_cut() != current_cut:
		current_cut = next_cut
		Music.music_player.seek(get_cut_start_position(current_cut))


func get_current_playing_cut():
	return floor(Music.position / cut_length)


func get_cut_start_position(cut_index: int):
	return cut_length * cut_index


func play(cut_index: int = 0):
	current_cut = cut_index
	Music.play(Music.Track.Tutorial, get_cut_start_position(cut_index))


func progress():
	next_cut += 1
	if current_cut == 0:
		# Seek to the same point in cut 1
		Music.music_player.seek(Music.position + cut_length)
		current_cut += 1
		next_cut += 1


func queue_cut(cut_index: int = 0):
	next_cut = cut_index
