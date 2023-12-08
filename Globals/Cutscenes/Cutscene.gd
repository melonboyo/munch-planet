extends Node
class_name Cutscene

@export var scenes: Array[CutsceneScene] = []
@export var end_animation_name: String = "" 


func play():
	CutsceneManager.play_cutscene(self)
