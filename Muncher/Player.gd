extends CharacterBody3D


@onready var emoter = $Emoter as Emoter


func _process(delta):
	if Input.is_action_just_pressed("emote_1"):
		emoter.play_emote(Constants.Emote.Exclamation)
	if Input.is_action_just_pressed("emote_2"):
		emoter.play_emote(Constants.Emote.Happy)
	if Input.is_action_just_pressed("emote_3"):
		emoter.play_emote(Constants.Emote.Question)
	if Input.is_action_just_pressed("emote_4"):
		emoter.play_emote(Constants.Emote.Mad)


func _physics_process(delta):
	$Model.is_on_floor = is_on_floor()
	$OverworldMovement._overworld_physics_process(delta)
