extends Resource
class_name Cutscene

@export_node_path("AnimationPlayer") var animation_player: NodePath
@export var scenes: Array[CutsceneScene] = []
