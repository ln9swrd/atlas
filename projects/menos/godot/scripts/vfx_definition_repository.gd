class_name VFXDefinitionRepository
extends RefCounted

const SQLITE_PATH := "res://content/menos.sqlite"
const CATALOG_PATH := "vfx_definitions"
const TABLE := "vfx_definitions"
const DOCUMENT_ID := "vfx_definitions"
const LOADER_SCRIPT = preload("res://scripts/vfx_definition_loader.gd")

static var _catalog: Dictionary = {}
static var _loaded := false

static func _open_db(read_only: bool = false):
	var db = SQLite.new()
	db.path = SQLITE_PATH
	db.read_only = read_only
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		push_error("VFXDefinitionRepository: failed to open SQLite database")
		return null
	return db

static func ensure_schema() -> bool:
	var db = _open_db(false)
	if db == null:
		return false
	var ok := db.query('CREATE TABLE IF NOT EXISTS "vfx_definitions" (document_id TEXT PRIMARY KEY, raw_json TEXT NOT NULL)')
	if ok:
		ok = db.query_with_bindings('INSERT OR IGNORE INTO "vfx_definitions" (document_id, raw_json) VALUES (?, ?)', [DOCUMENT_ID, "{}"])
	db.close_db()
	return ok

static func _ensure_loaded() -> void:
	if _loaded:
		return
	if not ensure_schema():
		return
	_loaded = true
	var parsed: Dictionary = LOADER_SCRIPT.load_catalog()
	for key in parsed.keys():
		_catalog[str(key)] = parsed[key]

static func reload() -> void:
	_catalog.clear()
	_loaded = false
	_ensure_loaded()

static func get_definition(vfx_id: String):
	_ensure_loaded()
	return _catalog.get(vfx_id, null)

static func exists(vfx_id: String) -> bool:
	return get_definition(vfx_id) != null

static func list(category: String = "") -> Array[String]:
	_ensure_loaded()
	var result: Array[String] = []
	for key in _catalog.keys():
		var definition = _catalog[key]
		if category.is_empty() or str(definition.category) == category:
			result.append(str(key))
	result.sort()
	return result

static func save_definition(definition) -> bool:
	if definition == null or str(definition.id).is_empty():
		return false
	if not ensure_schema():
		return false
	var catalog: Dictionary = ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	catalog[str(definition.id)] = definition.to_dict()
	if not ObjectPersistence.save_catalog(CATALOG_PATH, catalog):
		return false
	reload()
	return exists(str(definition.id))

static func delete_definition(vfx_id: String) -> bool:
	if vfx_id.is_empty() or not ensure_schema():
		return false
	var catalog: Dictionary = ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	if not catalog.has(vfx_id):
		return false
	catalog.erase(vfx_id)
	if not ObjectPersistence.save_catalog(CATALOG_PATH, catalog):
		return false
	reload()
	return not exists(vfx_id)
