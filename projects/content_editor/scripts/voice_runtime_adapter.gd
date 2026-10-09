class_name VoiceRuntimeAdapter
extends RefCounted
var definition = null
func configure(value) -> void: definition = value
func play(owner: Node) -> bool:
	if definition == null or str(definition.voice_asset).is_empty() or not ResourceLoader.exists(str(definition.voice_asset)): return false
	var stream = load(str(definition.voice_asset)) as AudioStream
	if stream == null: return false
	EditorSettingsManager.get_volume("Voice")
	var player := AudioStreamPlayer.new()
	player.stream = stream; player.bus = "Voice"; player.volume_db = linear_to_db(maxf(float(definition.volume), 0.0001))
	owner.add_child(player); player.play(); player.finished.connect(player.queue_free); return true
