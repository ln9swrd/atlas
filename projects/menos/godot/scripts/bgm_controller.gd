class_name BGMController
extends Node

var _player: AudioStreamPlayer = null
var _current_id := ""

func play_context(faction: String, context: String) -> bool:
	var ids := BGMDefinitionRepository.list(faction, context)
	if ids.is_empty():
		return false
	return play_definition(ids[0])

func play_definition(bgm_id: String) -> bool:
	# Ensure BGM/SFX buses and persisted volume settings exist even when gameplay starts without opening Settings.
	SettingsManager.get_bgm_volume()
	var definition = BGMDefinitionRepository.get_definition(bgm_id)
	if definition == null:
		return false
	var adapter := BGMRuntimeAdapter.new()
	adapter.configure(definition)
	var stream := adapter.resolve_stream()
	if stream == null:
		return false
	stop()
	_player = AudioStreamPlayer.new()
	_player.stream = stream
	_player.bus = "BGM"
	_player.volume_db = linear_to_db(maxf(float(definition.volume), 0.0001))
	_player.finished.connect(_on_finished)
	add_child(_player)
	_current_id = str(definition.id)
	_player.play()
	return true

func stop() -> void:
	if _player != null:
		_player.stop()
		_player.queue_free()
		_player = null
	_current_id = ""

func current_id() -> String:
	return _current_id

func _on_finished() -> void:
	if _player == null:
		return
	var definition = BGMDefinitionRepository.get_definition(_current_id)
	if definition != null and bool(definition.loop):
		_player.play()
