extends Node3D

var destroy_particles_scene = preload("res://Particles/DestroyParticlesBigRock.tscn")
@export var num_smashes_required := 15

var times_smashed := 0


func destroy():
	var particles = destroy_particles_scene.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position + global_transform.basis.y * 5.0
	particles.global_rotation = global_rotation
	queue_free()


func smash():
	times_smashed += 1
	
	if times_smashed > num_smashes_required:
		destroy()
	
	return times_smashed
