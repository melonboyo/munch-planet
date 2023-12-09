extends WorldEnvironment


func _process(delta):
	environment.sky_rotation.y += delta * PI*0.005  
