extends Node2D


signal deploy_munchme(munchme: MunchmeResource)


func _ready():
	for i in range(5):
		if GameState.munchmes[i] != null:
			var slot = get_node("%Slot" + str(i+1))
			slot.add_munchme(GameState.munchmes[i])
			get_node("%Button" + str(i+1)).text = GameState.munchmes[i].name
		else:
			get_node("%Button" + str(i+1)).disabled = true


func _on_button_up(button: int):
	if GameState.munchmes[button-1] == null:
		printerr("Deployable Munchme not found!!!")
		return
	
	deploy_munchme.emit(GameState.munchmes[button-1])
