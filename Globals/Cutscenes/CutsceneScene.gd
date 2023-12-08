extends Resource
class_name CutsceneScene

@export_group("Animation", "animation_")
@export_node_path("AnimationPlayer") var animation_player: NodePath
@export var animation_name := ""
@export var animation_loop := false

@export_group("Dialogue", "dialogue_")
@export var dialogue_translation_key := ""
