extends CharacterBody3D
class_name Munchme

@export var resource: MunchmeResource
@export var situation: Constants.Situation = Constants.Situation.Overworld

var is_in_area = false
var can_catch = false
var in_catch_mode = false
var player: Node3D = null

signal catch_munchme(munchme: Munchme)
signal finish_catch(win: bool)


func _ready():
	if situation == Constants.Situation.Overworld:
		var root = get_parent().get_parent()
		if root != null:
			catch_munchme.connect(root._on_catch_munchme)
	elif situation == Constants.Situation.Catch:
		get_parent().start_minigame.connect(_on_start_minigame)
		finish_catch.connect(get_parent()._on_munchme_finish_catch)
	
	munchme_specific_ready()


func munchme_specific_ready():
	pass


func _process(delta):
	if situation == Constants.Situation.Overworld:
		_overworld_process(delta)


func _overworld_process(delta):
	if in_catch_mode:
		$CatchArea.monitoring = false
		return
	$CatchArea.monitoring = true
	if is_in_area and player != null:
		var direction = player.global_transform.basis.z
		var direction_towards_me = (global_position - player.global_position).normalized()
		if direction.angle_to(direction_towards_me) < 0.45*PI:
			can_catch = true
		else:
			can_catch = false
	else:
		can_catch = false
	
	$CatchText.visible = can_catch
	
	if Input.is_action_just_pressed("interact") and can_catch:
		attempt_catch()


func _on_catch_area_body_entered(body):
	is_in_area = true
	player = body


func _on_catch_area_body_exited(body):
	is_in_area = false
	can_catch = false
	$CatchText.visible = false


func attempt_catch():
	in_catch_mode = true
	emit_signal("catch_munchme", self)


func _on_start_minigame():
	start_minigame()


func start_minigame():
	pass


func win_catch():
	finish_catch.emit(true)


func lose_catch():
	finish_catch.emit(false)
