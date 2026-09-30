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
	var parse_result: Error = json.parse(json_text)
	if parse_result != OK:
		push_error("MapLoader: JSON parse error '%s' at line %d" % [json.get_error_message(), json.get_error_line()])
		return {}

	var data: Variant = json.get_data()
	if not (data is Dictionary):
		push_error("MapLoader: Expected JSON object in map file: %s" % file_path)
		return {}
	return parse_raw_data(data)

static func parse_raw_data(raw_data: Dictionary) -> Dictionary:
	var parsed := {}
	parsed["_source_map_data"] = raw_data.duplicate(true)
	parsed["version"] = raw_data.get("version", 1)
	parsed["map_id"] = raw_data.get("map_id", "northbridge_sector_01")
	parsed["name"] = raw_data.get("name", "Northbridge Sector 01")

	if raw_data.has("map_size"):
		var ms: Variant = raw_data["map_size"]
		if not _is_vector_array(ms):
			push_error("MapLoader: map_size must be an array with 2 values")
			return {}
		parsed["map_tiles"] = Vector2i(int(ms[0]), int(ms[1]))

	if raw_data.has("map_origin"):
		var mo: Variant = raw_data["map_origin"]
		if not _is_vector_array(mo):
			push_error("MapLoader: map_origin must be an array with 2 values")
			return {}
		parsed["map_origin"] = Vector2(float(mo[0]), float(mo[1]))

	if raw_data.has("map_pixel_size"):
		var mps: Variant = raw_data["map_pixel_size"]
		if not _is_vector_array(mps):
			push_error("MapLoader: map_pixel_size must be an array with 2 values")
			return {}
		parsed["map_pixel_size"] = Vector2(float(mps[0]), float(mps[1]))

	if raw_data.has("goal"):
		var goal_data: Variant = raw_data["goal"]
		if not (goal_data is Dictionary):
			push_error("MapLoader: goal must be an object")
			return {}
		if goal_data.has("position"):
			var gpos: Variant = goal_data["position"]
			if not _is_vector_array(gpos):
				push_error("MapLoader: goal.position must be an array with 2 values")
				return {}
			parsed["base"] = Vector2(float(gpos[0]), float(gpos[1]))

	if raw_data.has("spawns"):
		var spawn_data: Variant = raw_data["spawns"]
		if not (spawn_data is Dictionary):
			push_error("MapLoader: spawns must be an object")
			return {}
		var lanes := {}
		for k in spawn_data:
			var pos_arr: Variant = spawn_data[k]
			if not _is_vector_array(pos_arr):
				push_error("MapLoader: spawns[%s] must be an array with 2 values" % k)
				return {}
			lanes[str(k)] = Vector2(float(pos_arr[0]), float(pos_arr[1]))
		parsed["lanes"] = lanes

	if raw_data.has("robot_spots"):
		var robot_spot_data: Variant = raw_data["robot_spots"]
		if not (robot_spot_data is Dictionary):
			push_error("MapLoader: robot_spots must be an object")
			return {}
		var spots := {}
		for k in robot_spot_data:
			var pos_arr: Variant = robot_spot_data[k]
			if not _is_vector_array(pos_arr):
				push_error("MapLoader: robot_spots[%s] must be an array with 2 values" % k)
				return {}
			spots[str(k)] = Vector2(float(pos_arr[0]), float(pos_arr[1]))
		parsed["robot_spots"] = spots

	if raw_data.has("tower_slots"):
		var tower_slot_data: Variant = raw_data["tower_slots"]
		if not (tower_slot_data is Dictionary):
			push_error("MapLoader: tower_slots must be an object")
			return {}
		var slots := {}
		for k in tower_slot_data:
			var pos_arr: Variant = tower_slot_data[k]
			if not _is_vector_array(pos_arr):
				push_error("MapLoader: tower_slots[%s] must be an array with 2 values" % k)
				return {}
			slots[str(k)] = Vector2(float(pos_arr[0]), float(pos_arr[1]))
		parsed["slots"] = slots

	if raw_data.has("tiles"):
		parsed["tiles"] = raw_data["tiles"]
	else:
		parsed["tiles"] = {}
	parsed["objects"] = raw_data.get("objects", [])
	var footprint_defaults: Variant = raw_data.get("asset_footprint_defaults", {})
	parsed["asset_footprint_defaults"] = footprint_defaults if footprint_defaults is Dictionary else {}
	var gameplay_areas: Variant = raw_data.get("gameplay_areas", [])
	parsed["gameplay_areas"] = gameplay_areas.duplicate(true) if gameplay_areas is Array else []
	var gameplay_points: Variant = raw_data.get("gameplay_points", [])
	parsed["gameplay_points"] = gameplay_points.duplicate(true) if gameplay_points is Array else []

	return parsed

static func _is_vector_array(value: Variant) -> bool:
	return value is Array and value.size() >= 2

static func save_map_data(file_path: String, map_data: Dictionary) -> bool:
	var map_tiles_vec: Vector2i = map_data.get("map_tiles", Vector2i(36, 24))
	var map_origin_vec: Vector2 = map_data.get("map_origin", Vector2(0, 58))
	var map_pixel_vec: Vector2 = map_data.get("map_pixel_size", Vector2(1152, 768))
	var base_vec: Vector2 = map_data.get("base", Vector2(1080, 122))
	var source_data: Variant = map_data.get("_source_map_data", {})
	var raw_data: Dictionary = source_data.duplicate(true) if source_data is Dictionary else {}
	raw_data.merge({
		"version": map_data.get("version", 1),
		"map_id": map_data.get("map_id", "northbridge_sector_01"),
		"name": map_data.get("name", "Northbridge Sector 01"),
		"map_size": [map_tiles_vec.x, map_tiles_vec.y],
		"tile_size": [32, 32],
		"map_origin": [map_origin_vec.x, map_origin_vec.y],
		"map_pixel_size": [map_pixel_vec.x, map_pixel_vec.y],
		"spawns": {},
		"robot_spots": {},
		"tower_slots": {},
		"tiles": map_data.get("tiles", {}),
		"objects": map_data.get("objects", []),
		"asset_footprint_defaults": map_data.get("asset_footprint_defaults", {}),
		"gameplay_areas": map_data.get("gameplay_areas", []),
		"gameplay_points": map_data.get("gameplay_points", [])
	}, true)
	var goal_data: Variant = raw_data.get("goal", {})
	var goal: Dictionary = goal_data.duplicate(true) if goal_data is Dictionary else {}
	goal["id"] = str(goal.get("id", "base_hq"))
	goal["position"] = [base_vec.x, base_vec.y]
	raw_data["goal"] = goal

	if map_data.has("lanes"):
		for k in map_data["lanes"]:
			var v: Vector2 = map_data["lanes"][k]
			raw_data["spawns"][k] = [v.x, v.y]

	if map_data.has("robot_spots"):
		for k in map_data["robot_spots"]:
			var v: Vector2 = map_data["robot_spots"][k]
			raw_data["robot_spots"][k] = [v.x, v.y]

	if map_data.has("slots"):
		for k in map_data["slots"]:
			var v: Vector2 = map_data["slots"][k]
			raw_data["tower_slots"][k] = [v.x, v.y]

	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("MapLoader: Failed to open file for writing at: %s" % file_path)
		return false

	var json_string := JSON.stringify(raw_data, "  ")
	file.store_string(json_string)
	file.close()
	return true
