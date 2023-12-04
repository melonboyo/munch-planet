extends Camera


func _looker_ready():
	pass


func set_focus(node: Node3D):
	$Camera.focus = node
