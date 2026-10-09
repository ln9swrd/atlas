class_name EditorSettingsManager
extends RefCounted

const SETTINGS_FILE := "user://menos_settings.cfg"
const RESOLUTIONS := [Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1400, 860), Vector2i(1600, 900), Vector2i(1920, 1080)]
static var language := "en"
static var bgm_volume := 1.0
static var sfx_volume := 1.0
static var voice_volume := 1.0
static var resolution := Vector2i(1400, 860)
static var loaded := false

static func initialize() -> void:
	_ensure_loaded()

static func _ensure_loaded() -> void:
	if loaded:
		return
	loaded = true
	var config := ConfigFile.new()
	if config.load(SETTINGS_FILE) == OK:
		language = str(config.get_value("localization", "language", "en"))
		bgm_volume = float(config.get_value("editor_audio", "bgm_volume", 1.0))
		sfx_volume = float(config.get_value("editor_audio", "sfx_volume", 1.0))
		voice_volume = float(config.get_value("editor_audio", "voice_volume", 1.0))
		var raw_resolution := str(config.get_value("editor_display", "resolution", "1400x860")).split("x")
		if raw_resolution.size() == 2:
			resolution = Vector2i(int(raw_resolution[0]), int(raw_resolution[1]))
	if language not in ["ko", "en"]:
		language = "en"
	bgm_volume = clampf(bgm_volume, 0.0, 1.0)
	sfx_volume = clampf(sfx_volume, 0.0, 1.0)
	voice_volume = clampf(voice_volume, 0.0, 1.0)
	if resolution not in RESOLUTIONS:
		resolution = Vector2i(1400, 860)
	TranslationServer.set_locale(language)
	_apply_audio()
	_apply_resolution()

static func set_language(value: String) -> void:
	_ensure_loaded()
	if value not in ["ko", "en"]:
		return
	language = value
	TranslationServer.set_locale(language)
	_save()

static func set_volume(category: String, value: float) -> void:
	_ensure_loaded()
	var volume := clampf(value, 0.0, 1.0)
	match category:
		"BGM": bgm_volume = volume
		"SFX": sfx_volume = volume
		"Voice": voice_volume = volume
		_: return
	_apply_audio()
	_save()

static func get_volume(category: String) -> float:
	_ensure_loaded()
	match category:
		"BGM": return bgm_volume
		"SFX": return sfx_volume
		"Voice": return voice_volume
	return 1.0

static func set_resolution(value: Vector2i) -> void:
	_ensure_loaded()
	if value not in RESOLUTIONS:
		return
	resolution = value
	_apply_resolution()
	_save()

static func _ensure_buses() -> void:
	for bus_name in ["BGM", "SFX", "Voice"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

static func _apply_audio() -> void:
	_ensure_buses()
	for entry in [["BGM", bgm_volume], ["SFX", sfx_volume], ["Voice", voice_volume]]:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(str(entry[0])), linear_to_db(maxf(float(entry[1]), 0.0001)))

static func _apply_resolution() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(resolution)

static func restore_defaults() -> void:
	_ensure_loaded()
	language = "en"
	bgm_volume = 1.0
	sfx_volume = 1.0
	voice_volume = 1.0
	resolution = Vector2i(1400, 860)
	TranslationServer.set_locale(language)
	_apply_audio()
	_apply_resolution()
	_save()

static func _save() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_FILE)
	config.set_value("localization", "language", language)
	config.set_value("editor_audio", "bgm_volume", bgm_volume)
	config.set_value("editor_audio", "sfx_volume", sfx_volume)
	config.set_value("editor_audio", "voice_volume", voice_volume)
	config.set_value("editor_display", "resolution", "%dx%d" % [resolution.x, resolution.y])
	config.save(SETTINGS_FILE)
