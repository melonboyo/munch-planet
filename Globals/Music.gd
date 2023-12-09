extends Node

const DISABLED_VOLUME_DB = -80
const FADE_IN_START_VOLUME_DB = -40

signal playing(track: Track)
signal stopping(track: Track, at_position: float)

enum Track {
	Overworld,
	ThoughtfulMuncher,
	Battle,
	Catch,
}

var streams = {
	Track.Overworld: preload("res://Music/brog.ogg"),
	Track.ThoughtfulMuncher: preload("res://Music/thoughtful_muncher.ogg"),
	Track.Battle: preload("res://Music/battle.ogg"),
	Track.Catch: preload("res://Music/catchy_music.ogg"),
}

var volume = 0
var volumes = {
	Track.Overworld: 0,
	Track.ThoughtfulMuncher: 0,
	Track.Battle: 0,
	Track.Catch: 0,
}

var selected_track = null
var music_player: AudioStreamPlayer
var position: float:
	get:
		return music_player.get_playback_position()
var is_playing:
	get:
		return music_player.playing


func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = DISABLED_VOLUME_DB
	music_player.bus = "Music"
	add_child(music_player)


func play(track: Track, from_position: float = 0.0, fade_in = null):
	return _play(track, from_position, fade_in or (fade_in == null && from_position > 0))


func stop(fade_out: bool = true):
	var previous_track = get_playing_track()
	_stop(fade_out, false)
	return previous_track


func switch_to(
	track: Track, 
	from_position: float = 0.0, 
	fade_out: bool = true, 
	fade_in = null):
	var previous_track = get_playing_track()
	_stop(fade_out, track, from_position)
	return previous_track


func get_playing_track() -> PlayingTrack:
	if selected_track != null:
		var playing_track = PlayingTrack.new()
		playing_track.track = selected_track
		playing_track.position = position
		
		return playing_track
	
	return null


func _play(track: Track, from_position: float = 0.0, fade_in: bool = false):
	if streams[track] == null:
		return
	
	var previous_track = get_playing_track()
	
	selected_track = track
	music_player.stream = streams[track]
	
	var track_volume = volumes[track] + volume
	
	if fade_in:
		music_player.volume_db = FADE_IN_START_VOLUME_DB
		var fade_in_tween = create_tween()
		fade_in_tween.tween_property(music_player, "volume_db", track_volume, 1.2).from_current()
	else:
		music_player.volume_db = track_volume
	
	music_player.play(from_position)
	playing.emit(track)
	
	return previous_track


func _stop(
	fade_out: bool = true, 
	switch_to = null, 
	switch_to_position: float = 0.0, 
	switch_to_fade_in = null):
	if fade_out:
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(music_player, "volume_db", DISABLED_VOLUME_DB, 1.2).from_current()
		
		if switch_to != null:
			fade_out_tween.finished.connect(_on_switch_to_track.bind(switch_to, switch_to_position, switch_to_fade_in))
		else:
			fade_out_tween.finished.connect(_on_stop_music_player)
	else:
		music_player.volume_db = DISABLED_VOLUME_DB
		if switch_to != null:
			_on_switch_to_track(switch_to, switch_to_position, switch_to_fade_in)
		else:
			stopping.emit(selected_track, position)
			music_player.stop()


func _on_switch_to_track(track: Track, from_position: float, fade_in):
	stopping.emit(selected_track, position)
	_play(track, from_position, fade_in or (fade_in == null && from_position > 0))


func _on_stop_music_player():
	stopping.emit(selected_track, position)
	music_player.stop()
