extends SceneTree

const DefinitionScript = preload("res://scripts/vfx_definition.gd")
const InstanceScript = preload("res://scripts/vfx_runtime_instance.gd")

func _init() -> void:
	var definition = DefinitionScript.from_dict({
		"id": "projectile_smoke",
		"name": "Projectile Smoke",
		"category": "projectile",
		"components": [{"type": "trail", "resource": "defender"}],
		"timeline": {"duration": 999.0, "loop": true, "playback": "loop", "tracks": []},
		"transform": {"space": "world", "anchor": "projectile", "offset": {"x": 0.0, "y": 0.0}, "rotation": 0.0, "scale": 1.0}
	})
	var effect := {"start": Vector2(0, 0), "target": Vector2(100, 0), "progress": 0.5}
	var instance = InstanceScript.new()
	instance.configure(definition, {"instance_id": "projectile_1"})
	instance.bind_effect(effect)
	instance.play()
	instance.tick(0.01)
	var command = instance.render_commands()[0]
	if command.get("position", Vector2.ZERO) != Vector2(50, 0):
		print("VFX_PROJECTILE_INSTANCE_FAIL position")
		quit(1)
		return
	effect["progress"] = 1.0
	instance.tick(0.01)
	if not instance.is_complete():
		print("VFX_PROJECTILE_INSTANCE_FAIL completion")
		quit(1)
		return
	print("VFX_PROJECTILE_INSTANCE_PASS")
	quit(0)
