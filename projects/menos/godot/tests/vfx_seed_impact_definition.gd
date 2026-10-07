extends SceneTree

const DefinitionScript = preload("res://scripts/vfx_definition.gd")
const RepositoryScript = preload("res://scripts/vfx_definition_repository.gd")

func _init() -> void:
	var definition = DefinitionScript.from_dict({
		"id": "impact_explosion",
		"name": "Impact Explosion",
		"category": "combat",
		"schema_version": 1,
		"revision": 1,
		"status": "Validated",
		"description": "Generic combat impact ring used as the first Runtime Adapter pilot.",
		"components": [{"type": "ring", "resource": ""}],
		"timeline": {
			"duration": 0.35,
			"loop": false,
			"playback": "once",
			"tracks": [{
				"property": "opacity",
				"start": 0.0,
				"end": 0.35,
				"keys": [
					{"time": 0.0, "value": "1.0", "interpolation": "linear"},
					{"time": 0.35, "value": "0.0", "interpolation": "linear"}
				]
			}, {
				"property": "scale",
				"start": 0.0,
				"end": 0.35,
				"keys": [
					{"time": 0.0, "value": "0.5", "interpolation": "ease_out"},
					{"time": 0.35, "value": "1.0", "interpolation": "ease_out"}
				]
			}]
		},
		"transform": {
			"space": "world",
			"anchor": "impact",
			"offset": {"x": 0.0, "y": 0.0},
			"rotation": 0.0,
			"scale": 1.0
		},
		"parameters": {},
		"visual_resource_refs": [],
		"priority": 10,
		"concurrency": "allow_multiple",
		"max_instances": 32
	})
	if not RepositoryScript.save_definition(definition):
		print("VFX_IMPACT_SEED_FAIL")
		quit(1)
		return
	print("VFX_IMPACT_SEED_PASS")
	quit(0)
