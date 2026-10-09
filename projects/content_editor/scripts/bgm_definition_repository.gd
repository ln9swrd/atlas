class_name BGMDefinitionRepository
extends RefCounted

const SQLITE_PATH := "res://data/content_editor.sqlite"
const TABLE := "bgm_definitions"
const CATALOG_PATH := "bgm_definitions"
const DEFINITION_SCRIPT = preload("res://scripts/bgm_definition.gd")
const LOADER_SCRIPT = preload("res://scripts/bgm_definition_loader.gd")
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

static func get_definition(bgm_id: String):
	_ensure_loaded()
	return _catalog.get(bgm_id, null)

static func get_runtime_definition(bgm_id: String):
	return get_definition(bgm_id)

static func exists(bgm_id: String) -> bool:
	return get_definition(bgm_id) != null

static func list(faction: String = "", context: String = "") -> Array[String]:
	_ensure_loaded()
	var result: Array[String] = []
	for key in _catalog.keys():
		var d = _catalog[key]
		if (faction.is_empty() or str(d.faction) == faction) and (context.is_empty() or str(d.context) == context):
			result.append(str(key))
	result.sort()
	return result

static func save_definition(definition) -> bool:
	if definition == null or str(definition.id).strip_edges().is_empty():
		return false
	var catalog := ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	catalog[str(definition.id)] = definition.to_dict()
	if not ObjectPersistence.save_catalog(CATALOG_PATH, catalog):
		return false
	reload()
	return exists(str(definition.id))

static func delete_definition(bgm_id: String) -> bool:
	var catalog := ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	if not catalog.has(bgm_id):
		return false
	var definition = get_definition(bgm_id)
	if definition != null and _is_runtime_required(definition, catalog):
		return false
	catalog.erase(bgm_id)
	if not ObjectPersistence.save_catalog(CATALOG_PATH, catalog):
		return false
	reload()
	return not exists(bgm_id)

static func _is_runtime_required(definition, catalog: Dictionary) -> bool:
	var faction := str(definition.faction)
	var context := str(definition.context)
	if faction.is_empty() or context.is_empty():
		return false
	var required_contexts := ["NORMAL", "COMBAT", "VICTORY", "DEFEAT"]
	if context not in required_contexts:
		return false
	var matches := 0
	for key in catalog.keys():
		var other = catalog[key]
		if str(other.faction) == faction and str(other.context) == context:
			matches += 1
	return matches <= 1
