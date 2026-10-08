class_name BGMDefinitionRepository
extends RefCounted

const SQLITE_PATH := "res://content/menos.sqlite"
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
