class_name PlayerProfileRepository
extends RefCounted

const SQLITE_PATH := "res://content/menos.sqlite"
const TABLE := "player_profile"
const DOCUMENT_ID := "campaign_robot_profile"

static func load_profile() -> Dictionary:
	var db = SQLite.new()
	db.path = SQLITE_PATH
	db.read_only = false
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		push_error("PlayerProfileRepository: failed to open SQLite database")
		return {}
	if not _ensure_table(db):
		db.close_db()
		return {}
	if not db.query_with_bindings('SELECT raw_json FROM "%s" WHERE document_id = ?' % TABLE, [DOCUMENT_ID]):
		db.close_db()
		return {}
	var rows: Array = db.query_result.duplicate(true)
	db.close_db()
	if rows.is_empty():
		return {}
	var parsed: Variant = JSON.parse_string(str(rows[0].get("raw_json", "")))
	return parsed if parsed is Dictionary else {}

static func save_profile(profile: Dictionary) -> bool:
	var db = SQLite.new()
	db.path = SQLITE_PATH
	db.read_only = false
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		return false
	if not _ensure_table(db):
		db.close_db()
		return false
	var payload := JSON.stringify(profile, "  ")
	if not db.query_with_bindings('INSERT INTO "%s" (document_id, raw_json) VALUES (?, ?) ON CONFLICT(document_id) DO UPDATE SET raw_json = excluded.raw_json' % TABLE, [DOCUMENT_ID, payload]):
		db.close_db()
		return false
	db.close_db()
	return true

static func _ensure_table(db) -> bool:
	return db.query('CREATE TABLE IF NOT EXISTS "%s" (document_id TEXT PRIMARY KEY, raw_json TEXT NOT NULL)' % TABLE)
