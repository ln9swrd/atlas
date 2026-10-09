class_name MapLoader
extends RefCounted

const MAPS_DIRECTORY := "res://data/maps"
static var _maps_directory_override := ""

const LEGACY_MAP_ID_ALIASES := {
	"map_01": "northbridge_sector_01",
	"map_02": "map_02",
	"map_03": "map_03"
}
const LEGACY_MAP_PATHS := {
	"res://content/maps/map_01.json": "northbridge_sector_01",
	"res://content/maps/map_02.json": "map_02",
	"res://content/maps/map_03.json": "map_03"
}
const PROTECTED_MAP_IDS := ["northbridge_sector_01", "map_02", "map_03"]

static func set_maps_directory_for_tests(path: String) -> void:
	_maps_directory_override = path

static func clear_maps_directory_override() -> void:
	_maps_directory_override = ""

static func _maps_directory() -> String:
	return _maps_directory_override if not _maps_directory_override.is_empty() else MAPS_DIRECTORY

static func resolve_map_id(reference: String) -> String:
	var normalized := reference.replace("\\", "/").strip_edges()
	if LEGACY_MAP_PATHS.has(normalized):
		normalized = str(LEGACY_MAP_PATHS[normalized])
	elif normalized.begins_with(MAPS_DIRECTORY + "/"):
		normalized = normalized.get_file().get_basename()
	elif normalized.ends_with(".json"):
		normalized = normalized.get_file().get_basename()
	return str(LEGACY_MAP_ID_ALIASES.get(normalized, normalized))

static func map_file_path(reference: String) -> String:
	return _maps_directory().path_join(resolve_map_id(reference) + ".json")

static func is_valid_map_id(map_id: String) -> bool:
	if map_id.is_empty() or map_id != map_id.strip_edges() or not map_id.is_valid_filename():
		return false
	if map_id in [".", ".."] or map_id.contains(".") or map_id.contains("/") or map_id.contains("\\"):
		return false
	return true

static func list_map_paths() -> Array[String]:
	var paths: Array[String] = []
	var directory := DirAccess.open(_maps_directory())
	if directory == null:
		return paths
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		if not directory.current_is_dir() and file_name.to_lower().ends_with(".json"):
			paths.append(file_name.get_basename())
		file_name = directory.get_next()
	directory.list_dir_end()
	paths.sort()
	return paths

static func load_map_data(file_path: String) -> Dictionary:
	var map_id := resolve_map_id(file_path)
	if not is_valid_map_id(map_id):
		return {}
	var path := map_file_path(map_id)
	if not FileAccess.file_exists(path):
		return {}
	var raw_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not raw_data is Dictionary:
		push_error("MapLoader: Invalid JSON map document: %s" % path)
		return {}
	if str(raw_data.get("map_id", "")) != map_id:
		push_error("MapLoader: map_id must match filename stem: %s" % path)
		return {}
	return parse_raw_data(raw_data)

static func parse_raw_data(raw_data: Dictionary) -> Dictionary:
	var parsed := {}
	parsed["_source_map_data"] = raw_data.duplicate(true)
	parsed["version"] = raw_data.get("version", 1)
	parsed["map_id"] = raw_data.get("map_id", "northbridge_sector_01")
	parsed["name"] = raw_data.get("name", "Northbridge Sector 01")
	var play_modes: Variant = raw_data.get("play_modes", ["campaign", "single"])
	parsed["play_modes"] = play_modes.duplicate(true) if play_modes is Array else ["campaign", "single"]
	var multiplayer: Variant = raw_data.get("multiplayer", {})
	parsed["multiplayer"] = multiplayer.duplicate(true) if multiplayer is Dictionary else {}

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
			var slot_data: Variant = tower_slot_data[k]
			if slot_data is Array:
				if not _is_vector_array(slot_data):
					push_error("MapLoader: tower_slots[%s] must be an array with 2 values" % k)
					return {}
				slots[str(k)] = Vector2(float(slot_data[0]), float(slot_data[1]))
			elif slot_data is Dictionary:
				var position: Variant = slot_data.get("position", null)
				if not _is_vector_array(position):
					push_error("MapLoader: tower_slots[%s].position must be an array with 2 values" % k)
					return {}
				var normalized: Dictionary = slot_data.duplicate(true)
				normalized["position"] = Vector2(float(position[0]), float(position[1]))
				slots[str(k)] = normalized
			else:
				push_error("MapLoader: tower_slots[%s] must be an array or object" % k)
				return {}
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

static func _vector2_from_value(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return fallback

static func _vector2i_from_value(value: Variant, fallback: Vector2i) -> Vector2i:
	if value is Vector2i:
		return value
	if value is Array and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return fallback

static func _map_data_to_raw(map_data: Dictionary) -> Dictionary:
	var source: Variant = map_data.get("_source_map_data", {})
	var raw: Dictionary = source.duplicate(true) if source is Dictionary else {}
	raw["version"] = map_data.get("version", 1)
	raw["map_id"] = map_data.get("map_id", "")
	raw["name"] = map_data.get("name", "")
	raw["play_modes"] = map_data.get("play_modes", ["campaign", "single"])
	raw["multiplayer"] = map_data.get("multiplayer", {})
	var tiles_value: Variant = map_data.get("map_tiles", map_data.get("map_size", [36, 24]))
	if tiles_value is Vector2i:
		raw["map_size"] = [tiles_value.x, tiles_value.y]
	elif tiles_value is Array and tiles_value.size() >= 2:
		raw["map_size"] = [int(tiles_value[0]), int(tiles_value[1])]
	var origin_value: Variant = map_data.get("map_origin", [0, 58])
	if origin_value is Vector2:
		raw["map_origin"] = [origin_value.x, origin_value.y]
	var pixel_value: Variant = map_data.get("map_pixel_size", [1152, 768])
	if pixel_value is Vector2:
		raw["map_pixel_size"] = [pixel_value.x, pixel_value.y]
	var goal: Dictionary = raw.get("goal", {}).duplicate(true) if raw.get("goal", {}) is Dictionary else {}
	var base_value: Variant = map_data.get("base", null)
	if base_value is Vector2:
		goal["id"] = str(goal.get("id", "base_hq"))
		goal["position"] = [base_value.x, base_value.y]
	raw["goal"] = goal
	raw["spawns"] = {}
	for key in map_data.get("lanes", {}):
		var pos: Variant = map_data["lanes"][key]
		if pos is Vector2:
			raw["spawns"][key] = [pos.x, pos.y]
	raw["robot_spots"] = {}
	for key in map_data.get("robot_spots", {}):
		var pos: Variant = map_data["robot_spots"][key]
		if pos is Vector2:
			raw["robot_spots"][key] = [pos.x, pos.y]
	raw["tower_slots"] = {}
	for key in map_data.get("slots", {}):
		var slot: Variant = map_data["slots"][key]
		if slot is Dictionary:
			var slot_raw: Dictionary = slot.duplicate(true)
			var pos: Variant = slot_raw.get("position", null)
			if pos is Vector2:
				slot_raw["position"] = [pos.x, pos.y]
			raw["tower_slots"][key] = slot_raw
		elif slot is Vector2:
			raw["tower_slots"][key] = [slot.x, slot.y]
	raw["tiles"] = map_data.get("tiles", {})
	raw["objects"] = map_data.get("objects", [])
	raw["asset_footprint_defaults"] = map_data.get("asset_footprint_defaults", {})
	raw["gameplay_areas"] = map_data.get("gameplay_areas", [])
	raw["gameplay_points"] = map_data.get("gameplay_points", [])
	return raw

static func save_map_data(file_path: String, map_data: Dictionary) -> bool:
	var map_id := resolve_map_id(file_path)
	if not is_valid_map_id(map_id) or map_data.is_empty():
		return false
	if str(map_data.get("map_id", "")) != map_id:
		push_error("MapLoader: Refusing to save because map_id does not match target filename: %s" % map_id)
		return false
	var target_path := map_file_path(map_id)
	if not FileAccess.file_exists(target_path):
		push_error("MapLoader: Refusing to create a map during save; use create_map: %s" % target_path)
		return false
	var raw_data := _map_data_to_raw(map_data)
	raw_data["map_id"] = map_id
	return _write_map_json(target_path, raw_data, true)

static func create_map(map_id: String, map_data: Dictionary) -> bool:
	var id := map_id.strip_edges()
	if not is_valid_map_id(id) or id in LEGACY_MAP_ID_ALIASES:
		return false
	if FileAccess.file_exists(map_file_path(id)) or list_map_paths().has(id):
		return false
	var data := _map_data_to_raw(map_data)
	data["map_id"] = id
	data["name"] = str(map_data.get("name", data.get("name", id))).strip_edges()
	if str(data["name"]).is_empty():
		data["name"] = id
	return _write_map_json(map_file_path(id), data, false)

static func duplicate_map(source_id: String, new_id: String, new_name: String = "") -> bool:
	var data := load_map_data(source_id)
	if data.is_empty():
		return false
	data["map_id"] = new_id.strip_edges()
	if not new_name.strip_edges().is_empty():
		data["name"] = new_name.strip_edges()
	return create_map(new_id, data)

static func delete_map(map_id: String) -> bool:
	var id := resolve_map_id(map_id)
	if not is_valid_map_id(id) or id in PROTECTED_MAP_IDS:
		return false
	var path := map_file_path(id)
	if not FileAccess.file_exists(path):
		return false
	var absolute_path := ProjectSettings.globalize_path(path)
	return DirAccess.remove_absolute(absolute_path) == OK

static func _write_map_json(path: String, data: Dictionary, replace_existing: bool) -> bool:
	var map_id := path.get_file().get_basename()
	if not is_valid_map_id(map_id) or str(data.get("map_id", "")) != map_id:
		push_error("MapLoader: JSON map_id must match the target filename stem")
		return false
	var json_text := JSON.stringify(data, "  ") + "\n"
	var parsed: Variant = JSON.parse_string(json_text)
	if not parsed is Dictionary or str(parsed.get("map_id", "")) != map_id:
		return false
	var absolute_path := ProjectSettings.globalize_path(path)
	var parent_path := absolute_path.get_base_dir()
	if DirAccess.make_dir_recursive_absolute(parent_path) != OK and not DirAccess.dir_exists_absolute(parent_path):
		push_error("MapLoader: Cannot create authoring directory: %s" % parent_path)
		return false
	var temp_path := absolute_path + ".tmp"
	var backup_path := absolute_path + ".bak"
	if FileAccess.file_exists(temp_path) or FileAccess.file_exists(backup_path):
		push_error("MapLoader: Temporary or backup file already exists; refusing to overwrite: %s" % absolute_path)
		return false
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(json_text)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		DirAccess.remove_absolute(temp_path)
		return false
	var verify: Variant = JSON.parse_string(FileAccess.get_file_as_string(temp_path))
	if not verify is Dictionary or str(verify.get("map_id", "")) != map_id:
		DirAccess.remove_absolute(temp_path)
		return false
	var had_target := FileAccess.file_exists(absolute_path)
	if had_target and not replace_existing:
		DirAccess.remove_absolute(temp_path)
		return false
	if had_target and DirAccess.rename_absolute(absolute_path, backup_path) != OK:
		DirAccess.remove_absolute(temp_path)
		return false
	if DirAccess.rename_absolute(temp_path, absolute_path) != OK:
		if had_target:
			DirAccess.rename_absolute(backup_path, absolute_path)
		DirAccess.remove_absolute(temp_path)
		return false
	if had_target:
		DirAccess.remove_absolute(backup_path)
	return true
