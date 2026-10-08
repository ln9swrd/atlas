class_name MapLoader
extends RefCounted

const SQLITE_PATH := "res://content/menos.sqlite"
static var _sqlite_path_override := ""

static func set_sqlite_path_for_tests(path: String) -> void:
	_sqlite_path_override = path

static func clear_sqlite_path_override() -> void:
	_sqlite_path_override = ""

static func _database_path() -> String:
	return _sqlite_path_override if not _sqlite_path_override.is_empty() else SQLITE_PATH

const SQLITE_MAP_TABLES := {
	"map_01": "map_01",
	"map_01_src": "map_01_src",
	"map_02": "map_02",
	"map_03": "map_03"
}
const LEGACY_MAP_PATHS := {
	"res://content/maps/map_01.json": "map_01",
	"res://content/maps/map_01_src.json": "map_01_src",
	"res://content/maps/map_02.json": "map_02",
	"res://content/maps/map_03.json": "map_03"
}

static func list_map_paths() -> Array[String]:
	var paths: Array[String] = []
	for path in SQLITE_MAP_TABLES.keys():
		if str(path).ends_with("_src"):
			continue
		paths.append(str(path))
	var db = _open_db(true)
	if db != null:
		if db.query("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'map_documents'") and db.query_result.size() == 1:
			if db.query("SELECT map_id FROM map_documents ORDER BY map_id"):
				for row in db.query_result:
					var id := str(row.get("map_id", ""))
					if not id.is_empty() and not paths.has(id):
						paths.append(id)
		db.close_db()
	paths.sort()
	return paths

static func load_map_data(file_path: String) -> Dictionary:
	var table := _sqlite_map_table(file_path)
	if not table.is_empty():
		return _load_sqlite_map_data(table)
	return _load_dynamic_map_data(file_path)

static func parse_raw_data(raw_data: Dictionary) -> Dictionary:
	var parsed := {}
	parsed["_source_map_data"] = raw_data.duplicate(true)
	parsed["version"] = raw_data.get("version", 1)
	parsed["map_id"] = raw_data.get("map_id", "northbridge_sector_01")
	parsed["name"] = raw_data.get("name", "Northbridge Sector 01")
	var play_modes: Variant = raw_data.get("play_modes", ["campaign", "single", "multiplayer"])
	parsed["play_modes"] = play_modes.duplicate(true) if play_modes is Array else ["campaign", "single", "multiplayer"]
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
	raw["play_modes"] = map_data.get("play_modes", ["campaign", "single", "multiplayer"])
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
	if _sqlite_map_table(file_path).is_empty():
		var db = _open_db(false)
		if db == null:
			return false
		if not _ensure_dynamic_store(db):
			db.close_db()
			return false
		var json_string := JSON.stringify(_map_data_to_raw(map_data), "  ")
		var ok: bool = db.query_with_bindings("UPDATE map_documents SET raw_json = ? WHERE map_id = ?", [json_string, file_path])
		db.close_db()
		return ok
	return _save_fixed_map_data(file_path, map_data)

static func _save_fixed_map_data(file_path: String, map_data: Dictionary) -> bool:
	var map_tiles_vec: Vector2i = _vector2i_from_value(map_data.get("map_tiles", [36, 24]), Vector2i(36, 24))
	var map_origin_vec: Vector2 = _vector2_from_value(map_data.get("map_origin", [0, 58]), Vector2(0, 58))
	var map_pixel_vec: Vector2 = _vector2_from_value(map_data.get("map_pixel_size", [1152, 768]), Vector2(1152, 768))
	var base_vec: Vector2 = _vector2_from_value(map_data.get("base", [1080, 122]), Vector2(1080, 122))
	var source_data: Variant = map_data.get("_source_map_data", {})
	var raw_data: Dictionary = source_data.duplicate(true) if source_data is Dictionary else {}
	raw_data.merge({
		"version": map_data.get("version", 1),
		"map_id": map_data.get("map_id", "northbridge_sector_01"),
		"name": map_data.get("name", "Northbridge Sector 01"),
		"play_modes": map_data.get("play_modes", ["campaign", "single", "multiplayer"]),
		"multiplayer": map_data.get("multiplayer", {}).duplicate(true) if map_data.get("multiplayer", {}) is Dictionary else {},
		"map_size": [map_tiles_vec.x, map_tiles_vec.y],
		"tile_size": [32, 32],
		"map_origin": [map_origin_vec.x, map_origin_vec.y],
		"map_pixel_size": [map_pixel_vec.x, map_pixel_vec.y],
		"spawns": {},
		"robot_spots": {},
		"tower_slots": raw_data.get("tower_slots", {}).duplicate(true) if raw_data.get("tower_slots", {}) is Dictionary else {},
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
			var slot_data: Variant = map_data["slots"][k]
			if slot_data is Dictionary:
				raw_data["tower_slots"][k] = slot_data.duplicate(true)
				var position: Variant = slot_data.get("position", null)
				if position is Vector2:
					raw_data["tower_slots"][k]["position"] = [position.x, position.y]
			elif slot_data is Vector2:
				raw_data["tower_slots"][k] = [slot_data.x, slot_data.y]

	var json_string := JSON.stringify(raw_data, "  ")
	var sqlite_table := _sqlite_map_table(file_path)
	if not sqlite_table.is_empty():
		return _save_sqlite_map_data(sqlite_table, json_string)

	push_error("MapLoader: No SQLite map table mapping for path: %s" % file_path)
	return false

static func _open_db(read_only: bool):
	var db = SQLite.new()
	db.path = _database_path()
	db.read_only = read_only
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		return null
	return db

static func _ensure_dynamic_store(db) -> bool:
	return db.query("CREATE TABLE IF NOT EXISTS map_documents (map_id TEXT PRIMARY KEY, raw_json TEXT NOT NULL)")

static func _load_dynamic_map_data(map_id: String) -> Dictionary:
	var db = _open_db(true)
	if db == null:
		return {}
	if not db.query("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'map_documents'") or db.query_result.is_empty():
		db.close_db()
		return {}
	if not db.query_with_bindings("SELECT raw_json FROM map_documents WHERE map_id = ?", [map_id]):
		db.close_db()
		return {}
	var rows: Array = db.query_result.duplicate(true)
	db.close_db()
	if rows.size() != 1:
		return {}
	var raw_data: Variant = JSON.parse_string(str(rows[0].get("raw_json", "")))
	return parse_raw_data(raw_data) if raw_data is Dictionary else {}

static func create_map(map_id: String, map_data: Dictionary) -> bool:
	var id := map_id.strip_edges()
	if id.is_empty() or not id.is_valid_filename() or id in SQLITE_MAP_TABLES:
		return false
	if not load_map_data(id).is_empty():
		return false
	var data: Dictionary = _map_data_to_raw(map_data)
	data["map_id"] = id
	data["name"] = map_data.get("name", data.get("name", id))
	var db = _open_db(false)
	if db == null:
		return false
	if not _ensure_dynamic_store(db):
		db.close_db()
		return false
	var ok: bool = db.query_with_bindings("INSERT INTO map_documents(map_id, raw_json) VALUES(?, ?)", [id, JSON.stringify(data, "  ")])
	db.close_db()
	return ok

static func duplicate_map(source_id: String, new_id: String, new_name: String = "") -> bool:
	var data := load_map_data(source_id)
	if data.is_empty():
		return false
	data["map_id"] = new_id
	if not new_name.strip_edges().is_empty():
		data["name"] = new_name.strip_edges()
	return create_map(new_id, data)

static func delete_map(map_id: String) -> bool:
	if SQLITE_MAP_TABLES.has(map_id):
		return false
	var db = _open_db(false)
	if db == null:
		return false
	if not _ensure_dynamic_store(db):
		db.close_db()
		return false
	var ok := db.query_with_bindings("DELETE FROM map_documents WHERE map_id = ?", [map_id])
	db.close_db()
	return ok

static func _sqlite_map_table(file_path: String) -> String:
	var normalized := file_path.replace("\\", "/")
	if SQLITE_MAP_TABLES.has(normalized):
		return str(SQLITE_MAP_TABLES[normalized])
	if LEGACY_MAP_PATHS.has(normalized):
		return str(LEGACY_MAP_PATHS[normalized])
	return ""

static func _load_sqlite_map_data(table: String) -> Dictionary:
	var db = SQLite.new()
	db.path = _database_path()
	db.read_only = true
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		push_error("MapLoader: Failed to open SQLite database for reading: %s" % SQLITE_PATH)
		return {}

	var query_ok: bool = db.query_with_bindings('SELECT raw_json FROM "%s" WHERE document_id = ?' % table, [table])
	if not query_ok:
		push_error("MapLoader: SQLite map query failed for table: %s" % table)
		db.close_db()
		return {}
	var rows: Array = db.query_result.duplicate(true)
	db.close_db()
	if rows.size() != 1:
		push_error("MapLoader: Expected exactly one SQLite map document in table: %s" % table)
		return {}

	var raw_data: Variant = JSON.parse_string(str(rows[0].get("raw_json", "")))
	if not (raw_data is Dictionary):
		push_error("MapLoader: Invalid JSON map document in table: %s" % table)
		return {}
	return parse_raw_data(raw_data)

static func _save_sqlite_map_data(table: String, json_string: String) -> bool:
	var db = SQLite.new()
	db.path = _database_path()
	db.read_only = false
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		push_error("MapLoader: Failed to open SQLite database for writing: %s" % SQLITE_PATH)
		return false

	if not db.query("BEGIN IMMEDIATE TRANSACTION"):
		push_error("MapLoader: Failed to begin SQLite map save transaction")
		db.close_db()
		return false

	var rows_ok: bool = db.query_with_bindings('SELECT document_id FROM "%s" WHERE document_id = ?' % table, [table])
	if not rows_ok or db.query_result.size() != 1:
		push_error("MapLoader: Expected exactly one matching SQLite map document in table: %s" % table)
		db.query("ROLLBACK")
		db.close_db()
		return false

	var update_ok: bool = db.query_with_bindings('UPDATE "%s" SET raw_json = ? WHERE document_id = ?' % table, [json_string, table])
	if not update_ok:
		push_error("MapLoader: SQLite map update failed for table: %s" % table)
		db.query("ROLLBACK")
		db.close_db()
		return false

	var changes_ok: bool = db.query("SELECT changes() AS rows_changed")
	if not changes_ok or db.query_result.size() != 1 or int(db.query_result[0].get("rows_changed", 0)) != 1:
		push_error("MapLoader: SQLite map save did not update exactly one row in table: %s" % table)
		db.query("ROLLBACK")
		db.close_db()
		return false

	var verify_ok: bool = db.query_with_bindings('SELECT raw_json FROM "%s" WHERE document_id = ?' % table, [table])
	if not verify_ok or db.query_result.size() != 1 or str(db.query_result[0].get("raw_json", "")) != json_string:
		push_error("MapLoader: SQLite map save verification failed for table: %s" % table)
		db.query("ROLLBACK")
		db.close_db()
		return false

	if not db.query("COMMIT"):
		push_error("MapLoader: Failed to commit SQLite map save transaction")
		db.query("ROLLBACK")
		db.close_db()
		return false
	db.close_db()
	return true
