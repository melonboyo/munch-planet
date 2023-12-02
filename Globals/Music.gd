extends Node

enum Track {
	Overworld,
	ThoughtfulMuncher
}

var streams = {
	Track.Overworld: preload("res://Music/brog.ogg"),
	Track.ThoughtfulMuncher: preload("res://Music/thoughtful_muncher.ogg"),
}

var volume = 0
var volumes = {
	Track.Overworld: -9,
	Track.ThoughtfulMuncher: 0,
}

var selected_track = null
var music_player: AudioStreamPlayer
var position:
	get:
		return floori(music_player.get_playback_position() * 1000)


func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -80.0
	music_player.bus = "Music"
	add_child(music_player)


func play(track: Track):
	if streams[track] == null:
		return
	
	selected_track = track
	music_player.stream = streams[track]
	music_player.volume_db = volumes[track] + volume
	music_player.play()


func stop():
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(music_player, "volume_db", -80, 1.2).from_current()
