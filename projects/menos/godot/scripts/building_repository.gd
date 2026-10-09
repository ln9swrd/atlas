class_name BuildingRepository
extends RefCounted

const SQLITE_PATH := "res://content/menos.sqlite"
const TABLE := "buildings"

static func _open_db(read_only: bool = false):
	if not read_only and not OS.has_feature("editor"):
		push_error("BuildingRepository: content database writes are disabled outside the editor.")
		return null
	var db = SQLite.new()
	db.path = SQLITE_PATH
	db.read_only = read_only
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		push_error("BuildingRepository: failed to open SQLite database")
		return null
	return db

static func ensure_schema() -> bool:
	if not OS.has_feature("editor"):
		var read_db = _open_db(true)
		if read_db == null:
			return false
		var exists: bool = read_db.query_with_bindings("SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?", [TABLE])
		var schema_exists: bool = exists and not read_db.query_result.is_empty()
		read_db.close_db()
		return schema_exists
	var db = _open_db(false)
	if db == null:
		return false
	var ok := db.query('CREATE TABLE IF NOT EXISTS "buildings" (odb_pk INTEGER PRIMARY KEY, id TEXT NOT NULL UNIQUE, raw_json TEXT NOT NULL)')
	db.close_db()
	return ok

static func list_buildings() -> Array[Dictionary]:
	if not ensure_schema():
		return []
	var db = _open_db(true)
	if db == null:
		return []
	var result: Array[Dictionary] = []
	if db.query('SELECT odb_pk, id, raw_json FROM "buildings" ORDER BY odb_pk'):
		for row in db.query_result:
			var data = JSON.parse_string(str(row.get("raw_json", "")))
			if data is Dictionary:
				data["odb_pk"] = int(row.get("odb_pk", 0))
				data["id"] = str(row.get("id", ""))
				result.append(data)
	db.close_db()
	return result

static func get_building(odb_pk: int) -> Dictionary:
	for data in list_buildings():
		if int(data.get("odb_pk", 0)) == odb_pk:
			return data
	return {}

static func create_building(name_value: String) -> int:
	if not ensure_schema():
		return 0
	var db = _open_db(false)
	if db == null:
		return 0
	var payload := JSON.stringify({
		"name": name_value,
		"category": "structure",
		"hp": 100.0,
		"armor": 0.0,
		"blocks_movement": true,
		"destructible": true,
		"sprite": ""
	})
	if not db.query('SELECT COALESCE(MAX(odb_pk), 0) + 1 AS next_pk FROM odb_registry') or db.query_result.is_empty():
		db.close_db()
		return 0
	var new_pk := int(db.query_result[0].get("next_pk", 1))
	var legacy_id := "building_%d" % new_pk
	if not db.query_with_bindings('INSERT INTO "buildings" (odb_pk, id, raw_json) VALUES (?, ?, ?)', [new_pk, legacy_id, payload]):
		db.close_db()
		return 0
	if not db.query_with_bindings('INSERT INTO odb_registry(odb_pk, content_type, legacy_id) VALUES (?, ?, ?)', [new_pk, "building", legacy_id]):
		db.query_with_bindings('DELETE FROM "buildings" WHERE odb_pk = ?', [new_pk])
		db.close_db()
		return 0
	db.close_db()
	return new_pk

static func create_building_with_data(data: Dictionary) -> int:
	if not ensure_schema():
		return 0
	var db = _open_db(false)
	if db == null:
		return 0
	if not db.query("BEGIN IMMEDIATE TRANSACTION"):
		db.close_db()
		return 0
	if not db.query('SELECT COALESCE(MAX(odb_pk), 0) + 1 AS next_pk FROM odb_registry') or db.query_result.is_empty():
		db.query("ROLLBACK")
		db.close_db()
		return 0
	var new_pk := int(db.query_result[0].get("next_pk", 1))
	var legacy_id := "building_%d" % new_pk
	var payload := data.duplicate(true)
	payload.erase("id")
	payload.erase("odb_pk")
	if not db.query_with_bindings('INSERT INTO "buildings" (odb_pk, id, raw_json) VALUES (?, ?, ?)', [new_pk, legacy_id, JSON.stringify(payload, "  ")]):
		db.query("ROLLBACK")
		db.close_db()
		return 0
	if not db.query_with_bindings('INSERT INTO odb_registry(odb_pk, content_type, legacy_id) VALUES (?, ?, ?)', [new_pk, "building", legacy_id]):
		db.query("ROLLBACK")
		db.close_db()
		return 0
	if not db.query("COMMIT"):
		db.query("ROLLBACK")
		db.close_db()
		return 0
	db.close_db()
	return new_pk

static func save_building(odb_pk: int, data: Dictionary) -> bool:
	if odb_pk <= 0 or not ensure_schema():
		return false
	var db = _open_db(false)
	if db == null:
		return false
	var payload := data.duplicate(true)
	payload.erase("id")
	payload.erase("odb_pk")
	var ok := db.query_with_bindings('UPDATE "buildings" SET raw_json = ? WHERE odb_pk = ?', [JSON.stringify(payload, "  "), odb_pk])
	db.close_db()
	return ok

static func delete_building(odb_pk: int) -> bool:
	if odb_pk <= 0 or not ensure_schema():
		return false
	var db = _open_db(false)
	if db == null:
		return false
	if not db.query("BEGIN IMMEDIATE TRANSACTION"):
		db.close_db()
		return false
	if not db.query_with_bindings('DELETE FROM "buildings" WHERE odb_pk = ?', [odb_pk]):
		db.query("ROLLBACK")
		db.close_db()
		return false
	if not db.query_with_bindings('DELETE FROM odb_registry WHERE content_type = ? AND odb_pk = ?', ["building", odb_pk]):
		db.query("ROLLBACK")
		db.close_db()
		return false
	if not db.query("COMMIT"):
		db.query("ROLLBACK")
		db.close_db()
		return false
	db.close_db()
	return true
