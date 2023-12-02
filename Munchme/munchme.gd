extends CharacterBody3D
class_name Munchme

@export var resource: MunchmeResource
@export var situation: Constants.Situation = Constants.Situation.Overworld

var is_in_area = false
var can_catch = false
var player: Node3D = null

signal catch_munchme(munchme: MunchmeResource)


func _ready():
	if situation == Constants.Situation.Overworld:
		var root = get_parent().get_parent()
		catch_munchme.connect(root._on_catch_munchme)


func _process(delta):
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
	emit_signal("catch_munchme", resource)
