extends Node3D


func _overworld_physics_process(delta):
	target.up_direction = target.global_transform.origin.normalized()
	
	if target.is_on_floor():
		floor_normal = target.get_floor_normal()
		steps_since_grounded = 0
		# Stick to floor
		gravity_velocity = -floor_normal * 2.8
	else:
		floor_normal = target.up_direction
		steps_since_grounded += 1
		gravity_velocity += -target.up_direction * gravity * delta
	
	if GameState.situation == Constants.Situation.Catch or not is_active:
		move_input = Vector2.ZERO
	
	var x_axis = project_direction_on_plane(right_axis, floor_normal)
	var z_axis = project_direction_on_plane(forward_axis, floor_normal)
	var move_input_speed_scaled = move_input * walking_speed
	var move_input_rotated = x_axis * move_input_speed_scaled.x + z_axis * move_input_speed_scaled.y
	move_velocity = move_velocity.lerp(move_input_rotated, delta * acceleration)
	
	snap_to_floor()
	
	if move_input_speed_scaled.length() > 0.2:
		model.change_animation("Run")
		model.set_animation_speed_scale(move_velocity.length() * 0.12)
		last_strong_direction = move_velocity.normalized()
	else:
		model.change_animation("Idle")
		model.set_animation_speed_scale(1.0)

	target.velocity = move_velocity + gravity_velocity
	target.move_and_slide()
