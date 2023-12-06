extends Node3D


var held_munchme: Munchme = null
var held_position: Vector3 = Vector3.ZERO


func _looker_ready():
	GameState.munchme_added.connect(_on_munchme_added)
	for m in GameState.munchmes:
		send_in_munchme(m, get_random_position())


func _physics_process(delta):
	if held_munchme == null:
		return
	var new_held_position = mouse_to_world_position()
	if not new_held_position == Vector3.ZERO:
		held_position = new_held_position + Vector3.DOWN * 0.5
	
	if held_position.y < 0.9:
		held_position.y = 0.9
	held_munchme.global_position = held_munchme.global_position.lerp(held_position, delta * 12.0)
	held_munchme.rotation.y = PI
	held_munchme.rotation.x = (held_munchme.global_position.z - held_position.z) * 1.8
	held_munchme.rotation.z = (held_position.x - held_munchme.global_position.x) * 1.8


func _input(event):
	if (event is InputEventMouseButton
		and event.get_button_index() == MOUSE_BUTTON_LEFT
		and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED
	):
		if event.is_pressed() and held_munchme == null:
			held_munchme = get_munchme_or_null()
			if held_munchme != null:
				held_munchme.freeze = true
				held_munchme.play_animation("Dangle")
		elif event.is_released() and held_munchme != null:
			held_munchme.freeze = false
			held_munchme.play_animation("Idle")
			held_munchme = null


func send_in_munchme(munchme_resource: MunchmeResource, pos: Vector3):
	var munchme: Munchme = Scenes.munchmes[munchme_resource.munchme_type].instantiate()
	munchme.resource = munchme_resource
	munchme.situation = Constants.Situation.Manage
	munchme.position = pos
	add_child(munchme)


func get_random_position():
	return Vector3(randf_range(-3.8,3.8), 0, randf_range(-2.5,4.1))


func _on_munchme_added(resource: MunchmeResource):
	send_in_munchme(resource, get_random_position() + Vector3.UP * 6.0)


func mouse_to_world_position() -> Vector3:
	var mouse_position = get_viewport().get_mouse_position() * (get_viewport().size as Vector2 / get_viewport().get_visible_rect().size as Vector2)
	var ray_origin = %Camera3D.project_ray_origin(mouse_position)
	var ray_end = ray_origin + %Camera3D.project_ray_normal(mouse_position) * 2000.0
	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, pow(2, 17-1))
	var result = space_state.intersect_ray(ray_query)
	if !result:
		return Vector3.ZERO
	return result.position


func get_munchme_or_null() -> Munchme:
	var mouse_position = get_viewport().get_mouse_position() * (get_viewport().size as Vector2 / get_viewport().get_visible_rect().size as Vector2)
	var ray_origin = %Camera3D.project_ray_origin(mouse_position)
	var ray_end = ray_origin + %Camera3D.project_ray_normal(mouse_position) * 2000.0
	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, pow(2, 4-1))
	var result = space_state.intersect_ray(ray_query)
	if !result:
		return null
	if not result.collider is Munchme:
		return null
	return result.collider
