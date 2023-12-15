@tool
extends CanvasGroup


const SCALE_LOOP_DURATION_MSEC := 1500


func _process(delta):
	$Circle.rotation += 0.12 * PI * delta
	
	var timestamp = Time.get_ticks_msec() % SCALE_LOOP_DURATION_MSEC
	var offset = sin(remap(timestamp, 0, SCALE_LOOP_DURATION_MSEC, -PI, PI))
	
	var scale = remap(offset, -1.0, 1.0, 0.9, 0.95)
	$Circle.scale = Vector2.ONE * scale
	
	var opacity = remap(offset, -1.0, 1.0, 0.6, 1)
	$Circle.modulate = Color(Color.WHITE, opacity)
