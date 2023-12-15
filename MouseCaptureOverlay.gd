extends Control


func _process(delta):
	if (not GameState.focus_main and not GameState.deployed_munchmes.is_empty()) and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
