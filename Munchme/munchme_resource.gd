extends Resource
class_name MunchmeResource


@export var id = 0
@export var name: String = "JIMBLO"
@export var munchme_type: Constants.Munchme = Constants.Munchme.Goby
@export var max_health: int = 100
@export var mood: Constants.Mood = Constants.Mood.Happy
@export var catch_track: Music.Track = Music.Track.Catch
@export var roam_track: Music.Track = Music.Track.Battle

var health = max_health
