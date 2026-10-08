extends SceneTree

const SFXDefinitionScript = preload("res://scripts/sfx_definition.gd")
const SFXRuntimeAdapterScript = preload("res://scripts/sfx_runtime_adapter.gd")

func _init() -> void:
	var definition = SFXDefinitionScript.from_dict({
		"id": "TEST_SFX",
		"name": "Test SFX",
		"category": "ui",
		"audio_asset": "res://sound/sfx_ui_click_1.mp3",
		"volume": 0.8,
		"pitch": 1.05,
		"bus": "SFX",
		"playback": "one_shot",
		"spatial_mode": "screen"
	})
	if definition == null or definition.id != "TEST_SFX":
		print("SFX_DEFINITION_FAIL")
		quit(1)
		return
	var adapter := SFXRuntimeAdapterScript.new()
	adapter.configure(definition)
	if not adapter.is_valid():
		print("SFX_ADAPTER_FAIL invalid")
		quit(1)
		return
	var stream := adapter.resolve_stream()
	if stream == null:
		print("SFX_ADAPTER_FAIL stream")
		quit(1)
		return
	var round_trip = SFXDefinitionScript.from_dict(definition.to_dict())
	if round_trip.audio_asset != definition.audio_asset or not is_equal_approx(round_trip.volume, 0.8):
		print("SFX_ROUNDTRIP_FAIL")
		quit(1)
		return
	print("SFX_DEFINITION_ADAPTER_PASS")
	quit(0)
