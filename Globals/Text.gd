extends Node
class_name Text

static var bb_text_pattern = create_bb_text_pattern()

static func get_clean_bb_text(bb_text: String) -> String:
	var clean_text: String = bb_text

	var match_start: int = 0
	while true:
		var text_match = bb_text_pattern.search(clean_text, match_start)
		if not text_match:
			break

		var start_index: int = text_match.get_start()
		var end_index: int = text_match.get_end()

		clean_text = clean_text.substr(0, start_index) + clean_text.substr(end_index)
		
		match_start = start_index  # Start searching again from the beginning

	return clean_text

static func create_bb_text_pattern():
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	return regex
