@tool
extends Marker3D

@export_category("General")
@export var spawn := false:
	set(value):
		spawn = false
		spawn_foliage()
@export var use_y_up_as_direction := false:
	set(value):
		use_y_up_as_direction = value
@export_range(0, 500) var amount: int = 15:
	set(value):
		amount = value
@export_range(0.5, 300) var ray_dist = 100.0:
	set(value):
		ray_dist = value
#@export_range(-360, 360) var y_rotation: float = 0.0:
	#set(value):
		#y_rotation = value
@export_range(0, 50) var _scale: float = 1.0:
	set(value):
		_scale = value
@export_category("Models")
@export var models: Array[PackedScene] = []:
	set(value):
		models = value
@export_category("Randomness")
@export_range(0, 200) var spawn_radius: float = 15.0:
	set(value):
		spawn_radius = value
@export_range(0, 1.0) var scale_variation: float = 0.5:
	set(value):
		scale_variation = value


func spawn_foliage():
	if not Engine.is_editor_hint() or models.is_empty():
		return
	
	if get_child_count() > 0:
		for c in get_children():
			c.free()
	
	
	var ray_dir = global_basis.y if use_y_up_as_direction else -global_position.normalized()
	var ray_dir_rotated: Vector3 = Vector3.FORWARD * Math.from_to_rotation(Vector3.UP, ray_dir)
	
	randomize()
	
	var first_loop = true
	var planet_rid = -1
	
	await get_tree().process_frame
	
	for i in range(amount+1):
		var space_state = get_world_3d().direct_space_state
		if first_loop:
			var ray_query = PhysicsRayQueryParameters3D.create(
				global_position, global_position + ray_dir * ray_dist, pow(2, 5-1)
			)
			var result = space_state.intersect_ray(ray_query)
			if !result:
				print("No planet to hit.")
				return
			planet_rid = result.collider_id
			first_loop = false
			continue
		# Fix to make uniformly distributed?
		var spawn_pos = global_position + ray_dir_rotated.rotated(ray_dir, randf_range(-PI, PI)) * pow(randf_range(0, 1), 0.67) * spawn_radius
		var spawn_ray_dir = -spawn_pos.normalized()
		var ray_query = PhysicsRayQueryParameters3D.create(
			spawn_pos, spawn_pos + spawn_ray_dir * ray_dist, (pow(2, 1-1) + pow(2, 8-1))
		)
		ray_query.hit_back_faces = false
		ray_query.hit_from_inside = false
		
		var result = space_state.intersect_ray(ray_query)
		if !result or result.collider_id != planet_rid:
			continue
		
		var up: Vector3 = result.normal.normalized()
		var forward: Vector3 = Vector3.FORWARD * Math.from_to_rotation(Vector3.UP, up)
		forward = forward.rotated(up, randf_range(-PI, PI))
		var right: Vector3 = up.cross(forward).normalized()
		
		var id = randi_range(0, models.size()-1)
		var model: Node3D = models[id].instantiate()
		add_child(model)
		model.name = StringName(str(i))
		model.set_owner(get_tree().get_edited_scene_root())
		
		await get_tree().physics_frame
		
		model.global_position = result.position
		model.global_transform.basis = Basis(right, up, forward)
		model.scale = Vector3.ONE * (_scale + _scale * randf_range(-scale_variation*0.5, scale_variation*0.5))
		
		
