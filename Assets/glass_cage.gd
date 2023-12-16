extends Node3D

var destroy_particles_scene = preload("res://Particles/DestroyParticlesGlassCage.tscn")

func destroy():
	var particles = destroy_particles_scene.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position + global_transform.basis.y * 5.0
	particles.global_rotation = global_rotation
	queue_free()
