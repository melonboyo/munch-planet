extends GPUParticles3D


func _ready():
	emitting = true


func _on_death_timer_timeout():
	queue_free()


func _on_stop_timer_timeout():
	emitting = false
