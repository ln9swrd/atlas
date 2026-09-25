class_name MapLoader
extends RefCounted

static func load_map_data(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		push_error("MapLoader: Map data file not found at path: %s" % file_path)
		return {}

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("MapLoader: Failed to open map data file at path: %s" % file_path)
		return {}

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result != OK:
		push_error("MapLoader: JSON parse error '%s' at line %d" % [json.get_error_message(), json.get_error_line()])
		return {}

	var raw_data: Dictionary = json.get_data()
	return parse_raw_data(raw_data)

static func parse_raw_data(raw_data: Dictionary) -> Dictionary:
	var parsed := {}

	if raw_data.has("map_size"):
		var ms: Array = raw_data["map_size"]
		parsed["map_tiles"] = Vector2i(int(ms[0]), int(ms[1]))

	if raw_data.has("map_origin"):
		var mo: Array = raw_data["map_origin"]
		parsed["map_origin"] = Vector2(float(mo[0]), float(mo[1]))

	if raw_data.has("map_pixel_size"):
		var mps: Array = raw_data["map_pixel_size"]
		parsed["map_pixel_size"] = Vector2(float(mps[0]), float(mps[1]))

	if raw_data.has("goal") and raw_data["goal"].has("position"):
		var gpos: Array = raw_data["goal"]["position"]
		parsed["base"] = Vector2(float(gpos[0]), float(gpos[1]))

	if raw_data.has("spawns"):
		var lanes := {}
		for k in raw_data["spawns"]:
			var pos_arr: Array = raw_data["spawns"][k]
			lanes[str(k)] = Vector2(float(pos_arr[0]), float(pos_arr[1]))
		parsed["lanes"] = lanes

	if raw_data.has("robot_spots"):
		var spots := {}
		for k in raw_data["robot_spots"]:
			var pos_arr: Array = raw_data["robot_spots"][k]
			spots[str(k)] = Vector2(float(pos_arr[0]), float(pos_arr[1]))
		parsed["robot_spots"] = spots

	if raw_data.has("tower_slots"):
		var slots := {}
		for k in raw_data["tower_slots"]:
			var pos_arr: Array = raw_data["tower_slots"][k]
			slots[str(k)] = Vector2(float(pos_arr[0]), float(pos_arr[1]))
		parsed["slots"] = slots

	return parsed
