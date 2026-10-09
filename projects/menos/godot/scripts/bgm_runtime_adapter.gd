class_name BGMRuntimeAdapter
extends RefCounted

var definition = null

func configure(bgm_definition) -> void:
	definition = bgm_definition

func is_valid() -> bool:
	return definition != null and not str(definition.audio_asset).is_empty()

func resolve_stream() -> AudioStream:
	if not is_valid():
		return null
	return RuntimeContentPackage.load_resource(str(definition.audio_asset)) as AudioStream
