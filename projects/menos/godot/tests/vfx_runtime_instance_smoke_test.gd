extends SceneTree

const DefinitionScript = preload("res://scripts/vfx_definition.gd")
const InstanceScript = preload("res://scripts/vfx_runtime_instance.gd")

func _init() -> void:
	var definition = DefinitionScript.from_dict({
		"id": "instance_smoke",
		"name": "Instance Smoke",
		"category": "combat",
		"components": [{"type": "ring"}],
		"timeline": {
			"duration": 0.35,
			"playback": "once",
			"loop": false,
			"tracks": []
		},
		"transform": {
			"space": "world",
			"anchor": "impact",
			"offset": {"x": 0.0, "y": 0.0},
			"scale": 1.0
		}
	})
	var instance = InstanceScript.new()
	instance.configure(definition, {"instance_id": "smoke_1", "position": Vector2(40, 50)})
	instance.play()
	instance.tick(0.1)
	var commands = instance.render_commands()
	if commands.size() != 1 or commands[0].get("position", Vector2.ZERO) != Vector2(40, 50):
		print("VFX_INSTANCE_FAIL command")
		quit(1)
		return
	instance.tick(0.3)
	if not instance.is_complete():
		print("VFX_INSTANCE_FAIL completion")
		quit(1)
		return
	print("VFX_RUNTIME_INSTANCE_SMOKE_PASS")
	quit(0)
