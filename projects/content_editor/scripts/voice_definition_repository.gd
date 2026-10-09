class_name VoiceDefinitionRepository
extends RefCounted
const CATALOG_PATH := "voice_definitions"
const LOADER_SCRIPT = preload("res://scripts/voice_definition_loader.gd")
static var _catalog := {}
static var _loaded := false
static func _ensure_loaded() -> void:
	if _loaded: return
	_loaded = true
	var loaded: Dictionary = LOADER_SCRIPT.load_catalog()
	for key in loaded.keys(): _catalog[str(key)] = loaded[key]
static func reload() -> void:
	_catalog.clear(); _loaded = false; _ensure_loaded()
static func get_definition(id: String):
	_ensure_loaded(); return _catalog.get(id, null)
static func list() -> Array[String]:
	_ensure_loaded()
	var result: Array[String] = []
	for key in _catalog.keys(): result.append(str(key))
	result.sort(); return result
static func exists(id: String) -> bool: return get_definition(id) != null
static func save_definition(definition) -> bool:
	if definition == null or str(definition.id).is_empty() or str(definition.dialogue_id).is_empty(): return false
	var catalog := ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	catalog[str(definition.id)] = definition.to_dict()
	if not ObjectPersistence.save_catalog(CATALOG_PATH, catalog): return false
	reload(); return exists(str(definition.id))
static func delete_definition(id: String) -> bool:
	var catalog := ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	if not catalog.has(id): return false
	catalog.erase(id)
	if not ObjectPersistence.save_catalog(CATALOG_PATH, catalog): return false
	reload(); return not exists(id)
