class_name SettingsManager
extends RefCounted

static var language: String = "ko"
static var bgm_volume: float = 1.0
static var sfx_volume: float = 1.0
static var loaded := false

static func _ensure_loaded() -> void:
	if loaded:
		return
	loaded = true
	var config := ConfigFile.new()
	if config.load("user://menos_settings.cfg") == OK:
		language = str(config.get_value("general", "language", "ko"))
		bgm_volume = float(config.get_value("audio", "bgm_volume", 1.0))
		sfx_volume = float(config.get_value("audio", "sfx_volume", 1.0))
	if language not in ["ko", "en"]:
		language = "ko"
	bgm_volume = clampf(bgm_volume, 0.0, 1.0)
	sfx_volume = clampf(sfx_volume, 0.0, 1.0)
	TranslationServer.set_locale(language)
	_apply_audio_volumes()

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
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save("user://menos_settings.cfg")

static func get_bgm_volume() -> float:
	_ensure_loaded()
	return bgm_volume

static func get_sfx_volume() -> float:
	_ensure_loaded()
	return sfx_volume

static func set_bgm_volume(value: float) -> void:
	_ensure_loaded()
	bgm_volume = clampf(value, 0.0, 1.0)
	_apply_audio_volumes()
	_save_audio()

static func set_sfx_volume(value: float) -> void:
	_ensure_loaded()
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_audio_volumes()
	_save_audio()

static func restore_defaults() -> void:
	language = "ko"
	bgm_volume = 1.0
	sfx_volume = 1.0
	loaded = true
	TranslationServer.set_locale(language)
	_apply_audio_volumes()
	_save_audio()

static func _save_audio() -> void:
	var config := ConfigFile.new()
	config.load("user://menos_settings.cfg")
	config.set_value("general", "language", language)
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save("user://menos_settings.cfg")

static func _apply_audio_volumes() -> void:
	for bus_name in ["BGM", "SFX"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	var bgm_bus := AudioServer.get_bus_index("BGM")
	var sfx_bus := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bgm_bus, linear_to_db(maxf(bgm_volume, 0.0001)))
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(maxf(sfx_volume, 0.0001)))
