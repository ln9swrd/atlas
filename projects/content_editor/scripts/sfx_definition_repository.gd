class_name SFXDefinitionRepository
extends RefCounted

const SQLITE_PATH := "res://data/menos.sqlite"
const CATALOG_PATH := "sfx_definitions"
const TABLE := "sfx_definitions"
const DEFINITION_SCRIPT = preload("res://scripts/sfx_definition.gd")
const LOADER_SCRIPT = preload("res://scripts/sfx_definition_loader.gd")

static var _catalog := {}
static var _loaded := false

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var db = SQLite.new()
	db.path = SQLITE_PATH
	db.read_only = true
	db.verbosity_level = 0
	if not db.open_db():
		return
	var table_exists: bool = db.query_with_bindings("SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?", [TABLE]) and not db.query_result.is_empty()
	db.close_db()
	if not table_exists:
		return
	var loaded: Dictionary = LOADER_SCRIPT.load_catalog()
	for key in loaded.keys():
		_catalog[str(key)] = loaded[key]

static func reload() -> void:
	_catalog.clear()
	_loaded = false
	_ensure_loaded()

static func get_definition(sfx_id: String):
	_ensure_loaded()
	return _catalog.get(sfx_id, null)

static func get_runtime_definition(sfx_id: String, legacy_asset_path: String):
	var definition = get_definition(sfx_id)
	if definition != null:
		return definition
	if legacy_asset_path.is_empty():
		return null
	return DEFINITION_SCRIPT.from_dict({
		"id": sfx_id,
		"name": sfx_id,
		"category": "legacy",
		"status": "LegacyFallback",
		"audio_asset": legacy_asset_path,
		"bus": "SFX",
		"playback": "one_shot",
		"spatial_mode": "screen"
	})

static func exists(sfx_id: String) -> bool:
	return get_definition(sfx_id) != null

static func list(category: String = "") -> Array[String]:
	_ensure_loaded()
	var result: Array[String] = []
	for key in _catalog.keys():
		var d = _catalog[key]
		if category.is_empty() or str(d.category) == category:
			result.append(str(key))
	result.sort()
	return result

static func save_definition(definition) -> bool:
	if definition == null or str(definition.id).is_empty() or str(definition.audio_asset).is_empty():
		return false
	var catalog := ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	catalog[str(definition.id)] = definition.to_dict()
	if not ObjectPersistence.save_catalog(CATALOG_PATH, catalog):
		return false
	reload()
	return exists(str(definition.id))

static func delete_definition(sfx_id: String) -> bool:
	var catalog := ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	if not catalog.has(sfx_id):
		return false
	catalog.erase(sfx_id)
	if not ObjectPersistence.save_catalog(CATALOG_PATH, catalog):
		return false
	reload()
	return not exists(sfx_id)
