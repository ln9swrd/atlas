class_name LocalizationRepository
extends RefCounted

const LOCALE_PATH := "res://content/localization"
const DEFAULT_LOCALE := "en"
const SUPPORTED_LOCALES := ["ko", "en"]

static var _cache: Dictionary = {}

static func get_locale() -> String:
	return SettingsManager.get_language()

static func set_locale(locale: String) -> void:
	if locale not in SUPPORTED_LOCALES:
		return
	SettingsManager.set_language(locale)

static func message(key: String, params: Dictionary = {}, fallback_key: String = "") -> String:
	var locale := get_locale()
	var value := _get_value(locale, key)
	if value.is_empty() and locale != DEFAULT_LOCALE:
		value = _get_value(DEFAULT_LOCALE, key)
	if value.is_empty() and not fallback_key.is_empty():
		value = _get_value(locale, fallback_key)
		if value.is_empty() and locale != DEFAULT_LOCALE:
			value = _get_value(DEFAULT_LOCALE, fallback_key)
	if value.is_empty():
		push_warning("Missing localization key: %s" % key)
		return key
	return _format(value, params)

static func reload(locale: String = "") -> void:
	if locale.is_empty():
		_cache.clear()
	else:
		_cache.erase(locale)

static func validate_locale(locale: String) -> bool:
	if locale not in SUPPORTED_LOCALES:
		return false
	var data := _load_locale(locale)
	return not data.is_empty()

static func validate_key_sets() -> bool:
	var base := _load_locale(DEFAULT_LOCALE)
	if base.is_empty():
		return false
	for locale in SUPPORTED_LOCALES:
		var data := _load_locale(locale)
		if data.is_empty() or data.keys().size() != base.keys().size():
			return false
		for key in base.keys():
			if not data.has(key):
				return false
	return true

static func _get_value(locale: String, key: String) -> String:
	var data := _load_locale(locale)
	if not data.has(key):
		return ""
	return str(data[key])

static func _load_locale(locale: String) -> Dictionary:
	if locale not in SUPPORTED_LOCALES:
		return {}
	if _cache.has(locale):
		return _cache[locale].duplicate(true)
	var path := "%s/%s.json" % [LOCALE_PATH, locale]
	if not FileAccess.file_exists(path):
		push_error("LocalizationRepository: file not found: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("LocalizationRepository: failed to open: %s" % path)
		return {}
	var json := JSON.new()
	var result: Error = json.parse(file.get_as_text())
	file.close()
	if result != OK or not (json.get_data() is Dictionary):
		push_error("LocalizationRepository: invalid JSON object: %s" % path)
		return {}
	var data: Dictionary = json.get_data()
	_cache[locale] = data.duplicate(true)
	return data

static func _format(value: String, params: Dictionary) -> String:
	var result := value
	for key in params:
		result = result.replace("{%s}" % str(key), str(params[key]))
	return result
