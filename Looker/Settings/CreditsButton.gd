extends Button


func _on_pressed():
	var all_content = load_credits_file()
	var sections = {}
	var current_section := "Fix yer code"
	for line in all_content.split("\n"):
		if line.begins_with("---"):
			current_section = line.replace("---", "")
			sections[current_section] = ""
		else:
			sections[current_section] += line + "\n"
	
	for section in sections.keys():
		OS.alert(sections[section], section)


func load_credits_file():
	var file = FileAccess.open("res://CREDITS.txt", FileAccess.READ)
	var content = file.get_as_text()
	return content
