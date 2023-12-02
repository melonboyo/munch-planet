extends Node

const SAVE_FILE_PATH = "user://save.json"

var player = {
	position = [0.0, 0.0, 0.0],
	rotation = [0.0, 0.0, 0.0],
	velocity = [0.0, 0.0, 0.0],
}


func sync_player(
	position: Vector3,
	rotation: Vector3,
	velocity: Vector3,
):
	player.position = serialize_vector3(position)
	player.rotation = serialize_vector3(rotation)
	player.velocity = serialize_vector3(velocity)


func load_player():
	return {
		position = deserialize_vector3(player.position),
		rotation = deserialize_vector3(player.rotation),
		velocity = deserialize_vector3(player.velocity),
	}


func save():
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	
	var state = JSON.stringify({
		player = player,
	})
	
	save_file.store_line(state)


func load():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return

	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	var state = JSON.parse_string(save_file.get_line())
	
	player = state.player


func serialize_vector3(vec: Vector3):
	return [vec.x, vec.y, vec.z]
func deserialize_vector3(vec: Array):
	return Vector3(vec[0], vec[1], vec[2])
