extends Resource
class_name MunchmeResource


enum Mood {
	Sad,
	Happy,
	Angry,
	Bored,
}


@export var max_health: int = 100
@export var mood = Mood.Happy

var health = max_health
