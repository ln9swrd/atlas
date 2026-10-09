class_name SFXRuntimeAdapter
extends RefCounted

var definition = null

func configure(sfx_definition) -> void:
	definition = sfx_definition

func is_valid() -> bool:
	return definition != null and not str(definition.audio_asset).is_empty()

func resolve_stream() -> AudioStream:
	if not is_valid():
		return null
	if not ResourceLoader.exists(str(definition.audio_asset)):
		return null
	var resource = load(str(definition.audio_asset))
	return resource as AudioStream

func play(parent: Node) -> bool:
	var stream := resolve_stream()
	if stream == null or parent == null:
		return false
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = str(definition.bus)
	player.volume_db = linear_to_db(maxf(float(definition.volume), 0.0001))
	player.pitch_scale = maxf(float(definition.pitch), 0.01)
	player.finished.connect(player.queue_free)
	parent.add_child(player)
	player.play()
	return true
