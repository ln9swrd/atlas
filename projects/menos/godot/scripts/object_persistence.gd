class_name ObjectPersistence
extends RefCounted

const SQLITE_PATH := "res://content/menos.sqlite"
const ROBOT_CATALOG_PATH := "res://content/robots/robots.json"

static func load_catalog(path: String) -> Dictionary:
	return ContentCatalogLoader.load_dictionary_catalog(path)

static func save_catalog(path: String, catalog: Dictionary) -> bool:
	var absolute_path := ProjectSettings.globalize_path(path)
	var parent_dir := absolute_path.get_base_dir()
	var dir_error := DirAccess.make_dir_recursive_absolute(parent_dir)
	if dir_error != OK:
		push_error("ObjectPersistence: failed to create directory: %s" % error_string(dir_error))
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("ObjectPersistence: failed to open for writing: %s" % path)
		return false
	var json_text := JSON.stringify(catalog, "  ")
	file.store_string(json_text)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_error("ObjectPersistence: failed to write %s" % path)
		return false
	return _verify_text(path, json_text)

static func sync_catalog_to_sqlite(path: String, catalog: Dictionary) -> bool:
	if path != ROBOT_CATALOG_PATH:
		push_error("ObjectPersistence: SQLite sync currently supports robots catalog only: %s" % path)
		return false

	var json_text := JSON.stringify(catalog, "  ")
	var db = SQLite.new()
	db.path = SQLITE_PATH
	db.read_only = false
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		push_error("ObjectPersistence: failed to open SQLite database for writing: %s" % SQLITE_PATH)
		return false

	if not db.query("BEGIN IMMEDIATE TRANSACTION"):
		push_error("ObjectPersistence: failed to begin SQLite sync transaction")
		db.close_db()
		return false

	var rows_ok: bool = db.query_with_bindings('SELECT document_id FROM "robots" WHERE document_id = ?', ["robots"])
	if not rows_ok or db.query_result.size() != 1:
		push_error("ObjectPersistence: expected exactly one robots SQLite document")
		db.query("ROLLBACK")
		db.close_db()
		return false

	var update_ok: bool = db.query_with_bindings('UPDATE "robots" SET raw_json = ? WHERE document_id = ?', [json_text, "robots"])
	if not update_ok:
		push_error("ObjectPersistence: robots SQLite update failed")
		db.query("ROLLBACK")
		db.close_db()
		return false

	var changes_ok: bool = db.query("SELECT changes() AS rows_changed")
	if not changes_ok or db.query_result.size() != 1 or int(db.query_result[0].get("rows_changed", 0)) != 1:
		push_error("ObjectPersistence: robots SQLite sync did not update exactly one row")
		db.query("ROLLBACK")
		db.close_db()
		return false

	var verify_ok: bool = db.query_with_bindings('SELECT raw_json FROM "robots" WHERE document_id = ?', ["robots"])
	if not verify_ok or db.query_result.size() != 1 or str(db.query_result[0].get("raw_json", "")) != json_text:
		push_error("ObjectPersistence: robots SQLite sync verification failed")
		db.query("ROLLBACK")
		db.close_db()
		return false

	if not db.query("COMMIT"):
		push_error("ObjectPersistence: failed to commit robots SQLite sync")
		db.query("ROLLBACK")
		db.close_db()
		return false
	db.close_db()
	return true

static func _verify_text(path: String, expected_text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ObjectPersistence: failed to reopen for verification: %s" % path)
		return false
	var actual_text := file.get_as_text()
	file.close()
	return actual_text.strip_edges() == expected_text.strip_edges()
