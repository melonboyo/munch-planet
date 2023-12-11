extends Node
class_name Cutscene

@export var scenes: Array[CutsceneScene] = []
@export var end_animation_name: String = "" 


func play(from_scene: int = 0, from_seconds: float = 0.0):
	CutsceneManager.play_cutscene(self, from_scene, from_seconds)
