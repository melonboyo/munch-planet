extends Node
class_name Cutscene

signal cutscene_finished

@export var scenes: Array[CutsceneScene] = []
@export var end_animation_name: String = "" 


func play(from_scene: int = 0, from_seconds: float = 0.0):
	CutsceneManager.play_cutscene(self, from_scene, from_seconds)
	CutsceneManager.cutscene_finished.connect(_on_cutscene_finished)


func _on_cutscene_finished():
	cutscene_finished.emit()
	CutsceneManager.cutscene_finished.disconnect(_on_cutscene_finished)
