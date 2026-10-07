extends SceneTree

const VFXDefinitionScript = preload("res://scripts/vfx_definition.gd")
const AdapterScript = preload("res://scripts/vfx_runtime_adapter.gd")

func _init() -> void:
	var definition = VFXDefinitionScript.from_dict({
		"id": "adapter_smoke",
		"name": "Adapter Smoke",
		"category": "generic",
		"components": [{"type": "ring", "resource": ""}],
		"timeline": {
			"duration": 1.0,
			"loop": false,
			"playback": "once",
			"tracks": [{
				"property": "opacity",
				"start": 0.0,
				"end": 1.0,
				"keys": [
					{"time": 0.0, "value": "0.0", "interpolation": "linear"},
					{"time": 1.0, "value": "1.0", "interpolation": "linear"}
				]
			}]
		},
		"transform": {
			"space": "world",
			"anchor": "origin",
			"offset": {"x": 10.0, "y": 20.0},
			"rotation": 0.0,
			"scale": 1.0
		}
	})
	var adapter = AdapterScript.new()
	adapter.configure(definition)
	adapter.play()
	adapter.tick(0.5)
	var commands = adapter.render_commands()
	if commands.size() != 1:
		print("VFX_ADAPTER_FAIL command count")
		quit(1)
		return
	var command = commands[0]
	if str(command.get("type", "")) != "ring":
		print("VFX_ADAPTER_FAIL type")
		quit(1)
		return
	if not is_equal_approx(float(command.get("opacity", -1.0)), 0.5):
		print("VFX_ADAPTER_FAIL opacity")
		quit(1)
		return
	if command.get("position", Vector2.ZERO) != Vector2(10.0, 20.0):
		print("VFX_ADAPTER_FAIL position")
		quit(1)
		return
	adapter.seek(0.5)
	adapter.playing = true
	adapter.tick(0.6)
	if not adapter.is_complete():
		print("VFX_ADAPTER_FAIL completion")
		quit(1)
		return
	print("VFX_RUNTIME_ADAPTER_SMOKE_PASS")
	quit(0)
