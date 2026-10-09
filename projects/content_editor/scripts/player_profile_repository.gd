class_name PlayerProfileRepository
extends RefCounted

const SQLITE_PATH := "res://data/content_editor.sqlite"
const TABLE := "player_profile"
const DOCUMENT_ID := "campaign_robot_profile"
const USER_PROFILE_PATH := "user://menos_campaign_robot_profile.json"

static func load_profile() -> Dictionary:
	if FileAccess.file_exists(USER_PROFILE_PATH):
		var profile_file := FileAccess.open(USER_PROFILE_PATH, FileAccess.READ)
		if profile_file == null:
			push_error("PlayerProfileRepository: failed to read user profile")
			return {}
		var user_payload := profile_file.get_as_text()
		profile_file.close()
		var user_profile: Variant = JSON.parse_string(user_payload)
		if not user_profile is Dictionary:
			push_error("PlayerProfileRepository: user profile is not a valid JSON object")
			return {}
		return user_profile

	var legacy_profile: Variant = _load_legacy_profile()
	if not legacy_profile is Dictionary:
		return {}
	if not save_profile(legacy_profile):
		push_error("PlayerProfileRepository: legacy profile import could not be saved to user storage")
	return legacy_profile

static func _load_legacy_profile() -> Variant:
	var db = SQLite.new()
	db.path = SQLITE_PATH
	db.read_only = true
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		push_error("PlayerProfileRepository: failed to open Content SQLite for legacy profile import")
		return null
	var table_exists: bool = db.query_with_bindings(
		"SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
		[TABLE]
	) and not db.query_result.is_empty()
	if not table_exists:
		db.close_db()
		return null
	if not db.query_with_bindings('SELECT raw_json FROM "%s" WHERE document_id = ?' % TABLE, [DOCUMENT_ID]):
		push_error("PlayerProfileRepository: legacy profile query failed")
		db.close_db()
		return null
	var rows: Array = db.query_result.duplicate(true)
	db.close_db()
	if rows.is_empty():
		return null
	var parsed: Variant = JSON.parse_string(str(rows[0].get("raw_json", "")))
	if not parsed is Dictionary:
		push_error("PlayerProfileRepository: legacy profile is not a valid JSON object")
		return null
	return parsed

static func save_profile(profile: Dictionary) -> bool:
	var profile_file := FileAccess.open(USER_PROFILE_PATH, FileAccess.WRITE)
	if profile_file == null:
		push_error("PlayerProfileRepository: failed to open user profile for writing")
		return false
	profile_file.store_string(JSON.stringify(profile, "  "))
	profile_file.flush()
	var file_error := profile_file.get_error()
	profile_file.close()
	if file_error != OK:
		push_error("PlayerProfileRepository: failed to write user profile (error %d)" % file_error)
		return false
	return true
