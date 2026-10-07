extends SceneTree

const DefinitionScript = preload("res://scripts/vfx_definition.gd")
const RepositoryScript = preload("res://scripts/vfx_definition_repository.gd")

func _definition(id: String, name: String, color_tag: String) -> RefCounted:
	return DefinitionScript.from_dict({
		"id": id,
		"name": name,
		"category": "projectile",
		"schema_version": 1,
		"revision": 1,
		"status": "Validated",
		"description": "Generic projectile visual pilot.",
		"components": [{"type": "trail", "resource": color_tag}],
		"timeline": {
			"duration": 999.0,
			"loop": true,
			"playback": "loop",
			"tracks": [{
				"property": "opacity",
				"start": 0.0,
				"end": 999.0,
				"keys": [
					{"time": 0.0, "value": "1.0", "interpolation": "step"},
					{"time": 999.0, "value": "1.0", "interpolation": "step"}
				]
			}]
		},
		"transform": {
			"space": "world",
			"anchor": "projectile",
			"offset": {"x": 0.0, "y": 0.0},
			"rotation": 0.0,
			"scale": 1.0
		},
		"parameters": {},
		"visual_resource_refs": [],
		"priority": 20,
		"concurrency": "allow_multiple",
		"max_instances": 128
	})

func _init() -> void:
	if not RepositoryScript.save_definition(_definition("projectile_defender", "Defender Projectile", "defender")):
		print("VFX_PROJECTILE_SEED_FAIL defender")
		quit(1)
		return
	if not RepositoryScript.save_definition(_definition("projectile_threat", "Threat Projectile", "threat")):
		print("VFX_PROJECTILE_SEED_FAIL threat")
		quit(1)
		return
	print("VFX_PROJECTILE_SEED_PASS")
	quit(0)
