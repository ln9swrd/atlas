class_name BGMRuntimeAdapter
extends RefCounted

var definition = null

func configure(bgm_definition) -> void:
	definition = bgm_definition

func is_valid() -> bool:
	return definition != null and not str(definition.audio_asset).is_empty()

func resolve_stream() -> AudioStream:
	if not is_valid() or not ResourceLoader.exists(str(definition.audio_asset)):
		return null
	return load(str(definition.audio_asset)) as AudioStream
