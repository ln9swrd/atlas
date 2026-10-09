class_name ConfigRepository
extends RefCounted

const EDITOR_SETTINGS_PATH := "editor"
const GAMEPLAY_SETTINGS_PATH := "gameplay"

static var _cache: Dictionary = {}

static func load_dictionary(path: String, use_cache: bool = true) -> Dictionary:
	if use_cache and _cache.has(path):
		return _cache[path].duplicate(true)
	var data := ContentCatalogLoader.load_dictionary_catalog(path)
	if data.is_empty():
		return {}
	_cache[path] = data.duplicate(true)
	return data

static func get_value(path: String, section: String, key: String, default_value: Variant = null) -> Variant:
	var data := load_dictionary(path)
	if not data.has(section) or not (data[section] is Dictionary):
		return default_value
	return data[section].get(key, default_value)

static func get_section(path: String, section: String) -> Dictionary:
	var data := load_dictionary(path)
	if not data.has(section) or not (data[section] is Dictionary):
		return {}
	return data[section].duplicate(true)

static func get_editor_value(section: String, key: String, default_value: Variant = null) -> Variant:
	return get_value(EDITOR_SETTINGS_PATH, section, key, default_value)

static func get_gameplay_value(section: String, key: String, default_value: Variant = null) -> Variant:
	return get_value(GAMEPLAY_SETTINGS_PATH, section, key, default_value)

static func reload(path: String = "") -> void:
	if path.is_empty():
		_cache.clear()
	else:
		_cache.erase(path)

static func validate_dictionary(path: String, required_sections: Array[String] = []) -> bool:
	var data := ContentCatalogLoader.load_dictionary_catalog(path)
	if data.is_empty():
		return false
	for section in required_sections:
		if not data.has(section) or not (data[section] is Dictionary):
			return false
	return true
