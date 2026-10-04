class_name SettingsManager
extends RefCounted

static var language: String = "ko"
static var loaded := false

static func _ensure_loaded() -> void:
	if loaded:
		return
	loaded = true
	var config := ConfigFile.new()
	if config.load("user://menos_settings.cfg") == OK:
		language = str(config.get_value("general", "language", "ko"))
	if language not in ["ko", "en"]:
		language = "ko"
	TranslationServer.set_locale(language)

static func get_language() -> String:
	_ensure_loaded()
	return language

static func set_language(value: String) -> void:
	if value not in ["ko", "en"]:
		return
	language = value
	loaded = true
	TranslationServer.set_locale(language)
	var config := ConfigFile.new()
	config.set_value("general", "language", language)
	config.save("user://menos_settings.cfg")
