class_name ObjectPersistence
extends RefCounted

const SQLITE_PATH := "res://content/menos.sqlite"

static func load_catalog(path: String) -> Dictionary:
	return ContentCatalogLoader.load_dictionary_catalog(path)

static func save_content_document(path: String, document: Variant) -> bool:
	if path.is_empty():
		push_error("ObjectPersistence: unsupported content document path: %s" % path)
		return false
	return _sync_document_to_sqlite(path, JSON.stringify(document, "  "))

static func delete_content_document(path: String) -> bool:
	var table := _sqlite_table_for_path(path)
	if table.is_empty():
		push_error("ObjectPersistence: no SQLite table mapping for %s" % path)
		return false
	var db = _open_db(false)
	if db == null: return false
	if not db.query("BEGIN IMMEDIATE TRANSACTION"):
		db.close_db(); return false
	var ok: bool = db.query_with_bindings('DELETE FROM "%s" WHERE rowid = (SELECT rowid FROM "%s" LIMIT 1)' % [table, table], [])
	if not ok:
		db.query("ROLLBACK"); db.close_db(); return false
	if not db.query("COMMIT"):
		db.query("ROLLBACK"); db.close_db(); return false
	db.close_db()
	return true

static func save_catalog(path: String, catalog: Dictionary) -> bool:
	if path.is_empty():
		push_error("ObjectPersistence: unsupported content catalog path: %s" % path)
		return false
	var json_text := JSON.stringify(catalog, "  ")
	return _sync_catalog_to_sqlite(path, catalog, json_text)

static func save_catalog_entry(path: String, entry_id: String, entry: Dictionary) -> bool:
	var catalog := ContentCatalogLoader.load_dictionary_catalog(path)
	if catalog.is_empty() and not entry_id.is_empty():
		push_error("ObjectPersistence: failed to load catalog for entry update: %s" % path)
		return false
	catalog[entry_id] = entry.duplicate(true)
	return save_catalog(path, catalog)

static func sync_catalog_to_sqlite(path: String, catalog: Dictionary) -> bool:
	if path.is_empty():
		push_error("ObjectPersistence: unsupported content catalog path: %s" % path)
		return false
	return _sync_catalog_to_sqlite(path, catalog, JSON.stringify(catalog, "  "))

static func save_catalog_entry_by_odb_pk(path: String, odb_pk: int, entry: Dictionary) -> bool:
	var table := _sqlite_table_for_path(path)
	if table.is_empty() or odb_pk <= 0:
		return false
	var db = _open_db(false)
	if db == null: return false
	if not db.query("BEGIN IMMEDIATE TRANSACTION"):
		db.close_db(); return false
	var json_text := JSON.stringify(entry, "  ")
	if not db.query_with_bindings('UPDATE "%s" SET raw_json = ? WHERE odb_pk = ?' % table, [json_text, odb_pk]):
		db.query("ROLLBACK"); db.close_db(); return false
	if not db.query_with_bindings('SELECT raw_json FROM "%s" WHERE odb_pk = ? LIMIT 1' % table, [odb_pk]):
		db.query("ROLLBACK"); db.close_db(); return false
	if db.query_result.size() != 1 or str(db.query_result[0].get("raw_json", "")) != json_text:
		db.query("ROLLBACK"); db.close_db(); return false
	if not db.query("COMMIT"):
		db.query("ROLLBACK"); db.close_db(); return false
	db.close_db()
	return true

static func delete_catalog_entry_by_odb_pk(path: String, content_type: String, odb_pk: int) -> bool:
	var table := _sqlite_table_for_path(path)
	if table.is_empty() or odb_pk <= 0:
		return false
	var db = _open_db(false)
	if db == null: return false
	if not db.query("BEGIN IMMEDIATE TRANSACTION"):
		db.close_db(); return false
	if not db.query_with_bindings('DELETE FROM "%s" WHERE odb_pk = ?' % table, [odb_pk]):
		db.query("ROLLBACK"); db.close_db(); return false
	if db.get_affected_rows() != 1:
		db.query("ROLLBACK"); db.close_db(); return false
	if not db.query_with_bindings('DELETE FROM odb_registry WHERE content_type = ? AND odb_pk = ?', [content_type, odb_pk]):
		db.query("ROLLBACK"); db.close_db(); return false
	if not db.query("COMMIT"):
		db.query("ROLLBACK"); db.close_db(); return false
	db.close_db()
	return true

static func _sqlite_table_for_path(path: String) -> String:
	var normalized := path.replace("\\", "/")
	if normalized == "res://content/campaign/main_campaign.json":
		return "campaign"
	if normalized.begins_with("res://content/") and normalized.ends_with(".json"):
		return normalized.trim_prefix("res://content/").get_file().get_basename()
	return normalized

static func _open_db(read_only: bool):
	var db = SQLite.new()
	db.path = SQLITE_PATH
	db.read_only = read_only
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		push_error("ObjectPersistence: failed to open SQLite database: %s" % SQLITE_PATH)
		return null
	return db

static func _sync_catalog_to_sqlite(path: String, catalog: Dictionary, json_text: String) -> bool:
	var table := _sqlite_table_for_path(path)
	if table.is_empty():
		push_error("ObjectPersistence: no SQLite table mapping for %s" % path)
		return false
	var db = _open_db(false)
	if db == null: return false
	if not db.query("BEGIN IMMEDIATE TRANSACTION"):
		db.close_db(); return false
	if not db.query_with_bindings('SELECT * FROM "%s"' % table, []):
		db.query("ROLLBACK"); db.close_db(); return false
	var rows: Array = db.query_result.duplicate(true)
	var ok := true
	var has_odb_pk: bool = rows.size() > 0 and rows[0].has("odb_pk")
	if rows.size() <= 1 and not has_odb_pk:
		ok = db.query_with_bindings('UPDATE "%s" SET raw_json = ? WHERE rowid = (SELECT rowid FROM "%s" LIMIT 1)' % [table, table], [json_text])
	else:
		var key_column := "id" if rows[0].has("id") else "document_id"
		var existing: Dictionary = {}
		for row in rows: existing[str(row.get(key_column, ""))] = true
		for entry_id in catalog.keys():
			var id := str(entry_id)
			var entry: Dictionary = catalog[entry_id] if catalog[entry_id] is Dictionary else {}
			if existing.has(id):
				ok = db.query_with_bindings('UPDATE "%s" SET raw_json = ? WHERE "%s" = ?' % [table, key_column], [JSON.stringify(entry, "  "), id])
			else:
				var columns: Array[String] = [key_column, "raw_json"]
				var values: Array = [id, JSON.stringify(entry, "  ")]
				if table == "robots":
					if not db.query_with_bindings('SELECT odb_pk FROM odb_registry WHERE content_type = ? AND legacy_id = ?', ["robot", id]):
						ok = false
					else:
						var registry_rows: Array = db.query_result.duplicate(true)
						var robot_pk := 0
						if registry_rows.size() > 0:
							robot_pk = int(registry_rows[0].get("odb_pk", 0))
						else:
							if not db.query('SELECT COALESCE(MAX(odb_pk), 0) + 1 AS next_pk FROM odb_registry'):
								ok = false
							else:
								robot_pk = int(db.query_result[0].get("next_pk", 1))
								ok = db.query_with_bindings('INSERT INTO odb_registry(odb_pk, content_type, legacy_id) VALUES(?, ?, ?)', [robot_pk, "robot", id])
							if ok:
								columns.insert(0, "odb_pk"); values.insert(0, robot_pk)
				if table == "rewards":
					if not db.query_with_bindings('SELECT odb_pk FROM odb_registry WHERE content_type = ? AND legacy_id = ?', ["reward", id]):
						ok = false
					else:
						var registry_rows: Array = db.query_result.duplicate(true)
						var reward_pk := 0
						if registry_rows.size() > 0:
							reward_pk = int(registry_rows[0].get("odb_pk", 0))
						else:
							if not db.query('SELECT COALESCE(MAX(odb_pk), 0) + 1 AS next_pk FROM odb_registry'):
								ok = false
							else:
								reward_pk = int(db.query_result[0].get("next_pk", 1))
								ok = db.query_with_bindings('INSERT INTO odb_registry(odb_pk, content_type, legacy_id) VALUES(?, ?, ?)', [reward_pk, "reward", id])
						if ok:
							columns.insert(0, "odb_pk"); values.insert(0, reward_pk)
				if table == "allied_units":
						columns.append("ai_json"); values.append(JSON.stringify(entry.get("ai", {})))
						columns.append("visuals_json"); values.append(JSON.stringify(entry.get("visuals", {})))
				var placeholders: Array[String] = []
				for _i in columns.size(): placeholders.append("?")
				ok = db.query_with_bindings('INSERT INTO "%s" (%s) VALUES (%s)' % [table, ",".join(columns), ",".join(placeholders)], values)
			if not ok: break
		for row in rows:
			var id := str(row.get(key_column, ""))
			if not catalog.has(id):
				ok = db.query_with_bindings('DELETE FROM "%s" WHERE "%s" = ?' % [table, key_column], [id])
				if not ok: break
	if not ok:
		db.query("ROLLBACK"); db.close_db(); return false
	if not db.query("COMMIT"):
		db.query("ROLLBACK"); db.close_db(); return false
	db.close_db()
	return true

static func _sync_document_to_sqlite(path: String, json_text: String) -> bool:
	var table := _sqlite_table_for_path(path)
	if table.is_empty():
		push_error("ObjectPersistence: no SQLite table mapping for %s" % path)
		return false
	var db = _open_db(false)
	if db == null: return false
	if not db.query("BEGIN IMMEDIATE TRANSACTION"):
		db.close_db(); return false
	if not db.query_with_bindings('SELECT rowid FROM "%s" LIMIT 2' % table, []):
		db.query("ROLLBACK"); db.close_db(); return false
	if db.query_result.size() != 1:
		push_error("ObjectPersistence: expected exactly one SQLite document row in table '%s'" % table)
		db.query("ROLLBACK"); db.close_db(); return false
	var rowid = db.query_result[0]["rowid"]
	if not db.query_with_bindings('UPDATE "%s" SET raw_json = ? WHERE rowid = ?' % table, [json_text, rowid]):
		db.query("ROLLBACK"); db.close_db(); return false
	if not db.query_with_bindings('SELECT raw_json FROM "%s" WHERE rowid = ?' % table, [rowid]):
		db.query("ROLLBACK"); db.close_db(); return false
	if db.query_result.size() != 1 or str(db.query_result[0].get("raw_json", "")) != json_text:
		db.query("ROLLBACK"); db.close_db(); return false
	if not db.query("COMMIT"):
		db.query("ROLLBACK"); db.close_db(); return false
	db.close_db()
	return true
