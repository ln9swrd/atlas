class_name ContentCatalogLoader
extends RefCounted

const SQLITE_PATH := "res://content/menos.sqlite"

static var _db

static func _table_from_path(path: String) -> String:
	var normalized := path.replace("\\", "/")
	if not normalized.begins_with("res://content/"):
		return normalized
	if normalized.begins_with("res://content/") and normalized.ends_with(".json"):
		var relative := normalized.trim_prefix("res://content/")
		var parts := relative.split("/")
		if parts.size() >= 2:
			return parts[parts.size() - 1].get_basename()
	return normalized

static func _get_db():
	if _db != null:
		return _db
	var db = SQLite.new()
	db.path = SQLITE_PATH
	db.read_only = true
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		push_error("ContentCatalogLoader: failed to open SQLite database: %s" % SQLITE_PATH)
		return null
	_db = db
	return _db

static func load_dictionary_catalog(path: String) -> Dictionary:
	var table := _table_from_path(path)
	if table.is_empty():
		push_error("ContentCatalogLoader: unsupported content path: %s" % path)
		return {}

	var db = _get_db()
	if db == null:
		return {}

	var safe_table := table.replace(char(34), char(34) + char(34))
	if not db.query('SELECT * FROM "%s"' % safe_table):
		push_error("ContentCatalogLoader: SQLite query failed for table: %s" % table)
		return {}

	var rows: Array = db.query_result.duplicate(true)
	if rows.is_empty():
		push_error("ContentCatalogLoader: no rows for table: %s" % table)
		return {}

	if rows.size() == 1 and rows[0].has("raw_json"):
		var payload = JSON.parse_string(str(rows[0]["raw_json"]))
		if payload is Dictionary:
			var catalog: Dictionary = {}
			for key in payload.keys():
				if payload[key] is Dictionary:
					catalog[str(key)] = payload[key].duplicate(true)
			if not catalog.is_empty() or payload.is_empty():
				return catalog

	var result: Dictionary = {}
	for row in rows:
		var entry_id := ""
		if row.has("id"):
			entry_id = str(row["id"])
		elif row.has("document_id"):
			entry_id = str(row["document_id"])
		if entry_id.is_empty():
			continue

		var entry: Dictionary = {}
		if row.has("raw_json"):
			var parsed = JSON.parse_string(str(row["raw_json"]))
			if parsed is Dictionary:
				entry = parsed.duplicate(true)
		if entry.is_empty():
			for key in row.keys():
				if key in ["id", "document_id", "raw_json"]:
					continue
				entry[str(key)] = row[key]
		result[entry_id] = entry

	if result.is_empty():
		push_error("ContentCatalogLoader: no catalog entries for table: %s" % table)
	return result

static func load_document(path: String) -> Dictionary:
	var table := _table_from_path(path)
	if path == "res://content/campaign/main_campaign.json":
		table = "campaign"
	if table.is_empty():
		push_error("ContentCatalogLoader: unsupported content path: %s" % path)
		return {}

	var db = _get_db()
	if db == null:
		return {}

	var safe_table := table.replace(char(34), char(34) + char(34))
	if not db.query('SELECT raw_json FROM "%s" LIMIT 1' % safe_table):
		push_error("ContentCatalogLoader: SQLite document query failed for table: %s" % table)
		return {}
	if db.query_result.is_empty():
		push_error("ContentCatalogLoader: no document row for table: %s" % table)
		return {}

	var payload = JSON.parse_string(str(db.query_result[0].get("raw_json", "")))
	if not (payload is Dictionary):
		push_error("ContentCatalogLoader: invalid JSON document in table: %s" % table)
		return {}
	return payload.duplicate(true)

static func load_content(path: String) -> Variant:
	if _table_from_path(path) != "":
		return load_document(path)
	var catalog := load_dictionary_catalog(path)
	return catalog
static func load_single_entry(path: String, entry_id: String) -> Dictionary:
	var catalog := load_dictionary_catalog(path)
	if not catalog.has(entry_id):
		push_error("ContentCatalogLoader: entry '%s' not found in %s" % [entry_id, path])
		return {}
	return catalog[entry_id].duplicate(true)
