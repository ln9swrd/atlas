class_name SettingsManager
extends RefCounted

const SETTINGS_FILE := "user://menos_settings.cfg"
const DEFAULT_LANGUAGE := "ko"
const DEFAULT_BGM_VOLUME := 1.0
const DEFAULT_SFX_VOLUME := 1.0
const DEFAULT_VOICE_VOLUME := 1.0
const DEFAULT_RESOLUTION := Vector2i(1400, 860)
const RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1400, 860),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

static var language: String = DEFAULT_LANGUAGE
static var bgm_volume: float = DEFAULT_BGM_VOLUME
static var sfx_volume: float = DEFAULT_SFX_VOLUME
static var voice_volume: float = DEFAULT_VOICE_VOLUME
static var resolution: Vector2i = DEFAULT_RESOLUTION
static var loaded := false

static func _ensure_loaded() -> void:
	if loaded:
		return
	loaded = true
	var config := ConfigFile.new()
	if config.load(SETTINGS_FILE) == OK:
		language = str(config.get_value("general", "language", DEFAULT_LANGUAGE))
		bgm_volume = float(config.get_value("audio", "bgm_volume", DEFAULT_BGM_VOLUME))
		sfx_volume = float(config.get_value("audio", "sfx_volume", DEFAULT_SFX_VOLUME))
		voice_volume = float(config.get_value("audio", "voice_volume", DEFAULT_VOICE_VOLUME))
		var resolution_text := str(config.get_value("display", "resolution", "1400x860"))
		resolution = _parse_resolution(resolution_text)
	if language not in ["ko", "en"]:
		language = DEFAULT_LANGUAGE
	bgm_volume = clampf(bgm_volume, 0.0, 1.0)
	sfx_volume = clampf(sfx_volume, 0.0, 1.0)
	voice_volume = clampf(voice_volume, 0.0, 1.0)
	if resolution not in RESOLUTIONS:
		resolution = DEFAULT_RESOLUTION
	TranslationServer.set_locale(language)
	_apply_audio_volumes()
	_apply_resolution()

static func _parse_resolution(value: String) -> Vector2i:
	var parts := value.split("x")
	if parts.size() != 2:
		return DEFAULT_RESOLUTION
	return Vector2i(int(parts[0]), int(parts[1]))

static func _ensure_audio_buses() -> void:
	for bus_name in ["BGM", "SFX", "Voice"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

static func get_language() -> String:
	_ensure_loaded()
	return language

static func set_language(value: String) -> void:
	_ensure_loaded()
	if value not in ["ko", "en"]:
		return
	language = value
	TranslationServer.set_locale(language)
	_save()

static func get_bgm_volume() -> float:
	_ensure_loaded()
	return bgm_volume

static func get_sfx_volume() -> float:
	_ensure_loaded()
	return sfx_volume

static func get_voice_volume() -> float:
	_ensure_loaded()
	return voice_volume

static func set_bgm_volume(value: float) -> void:
	_ensure_loaded()
	bgm_volume = clampf(value, 0.0, 1.0)
	_apply_audio_volumes()
	_save()

static func set_sfx_volume(value: float) -> void:
	_ensure_loaded()
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_audio_volumes()
	_save()

static func set_voice_volume(value: float) -> void:
	_ensure_loaded()
	voice_volume = clampf(value, 0.0, 1.0)
	_apply_audio_volumes()
	_save()

static func get_resolution() -> Vector2i:
	_ensure_loaded()
	return resolution

static func set_resolution(value: Vector2i) -> void:
	_ensure_loaded()
	if value not in RESOLUTIONS:
		return
	resolution = value
	_apply_resolution()
	_save()

static func _apply_resolution() -> void:
	if not Engine.is_editor_hint():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolution)
		var screen := DisplayServer.window_get_current_screen()
		var screen_size := DisplayServer.screen_get_size(screen)
		var position := DisplayServer.screen_get_position(screen) + (screen_size - resolution) / 2
		DisplayServer.window_set_position(position)

static func restore_defaults() -> void:
	language = DEFAULT_LANGUAGE
	bgm_volume = DEFAULT_BGM_VOLUME
	sfx_volume = DEFAULT_SFX_VOLUME
	voice_volume = DEFAULT_VOICE_VOLUME
	resolution = DEFAULT_RESOLUTION
	loaded = true
	TranslationServer.set_locale(language)
	_apply_audio_volumes()
	_apply_resolution()
	_save()

static func _save() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_FILE)
	config.set_value("general", "language", language)
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "voice_volume", voice_volume)
	config.set_value("display", "resolution", "%dx%d" % [resolution.x, resolution.y])
	config.save(SETTINGS_FILE)

static func _apply_audio_volumes() -> void:
	_ensure_audio_buses()
	for pair in [["BGM", bgm_volume], ["SFX", sfx_volume], ["Voice", voice_volume]]:
		var bus_index := AudioServer.get_bus_index(str(pair[0]))
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(float(pair[1]), 0.0001)))
