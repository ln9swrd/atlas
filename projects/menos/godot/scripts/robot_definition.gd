class_name RobotDefinition
extends RefCounted

var id: String = ""
var name: String = ""
var base_stats: Dictionary = {}
var progression: Dictionary = {}
var energy: Dictionary = {}
var visuals: Dictionary = {}

static func from_catalog(data: Dictionary) -> RobotDefinition:
	var definition := RobotDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.name = str(data.get("name", ""))
	definition.base_stats = {
		"hp": float(data.get("hp", 0.0)),
		"speed": float(data.get("speed", 0.0)),
		"damage": float(data.get("damage", 0.0)),
		"cooldown": float(data.get("cooldown", 0.0)),
		"range": float(data.get("range", 0.0)),
		"max_moves": int(data.get("max_moves", 0))
	}
	definition.progression = data.get("progression", {}).duplicate(true)
	definition.energy = data.get("energy", {}).duplicate(true)
	definition.visuals = {
		"sprite_idle": str(data.get("sprite_idle", "")),
		"sprite_attack": str(data.get("sprite_attack", "")),
		"sprite_move": str(data.get("sprite_move", "")),
		"sprite_skill": str(data.get("sprite_skill", "")),
		"projectile_anim": str(data.get("projectile_anim", ""))
	}
	return definition

func get_base_stat(key: String) -> Variant:
	return base_stats.get(key)

func get_progression_value(key: String, default_value: Variant = null) -> Variant:
	return progression.get(key, default_value)

func get_energy_value(key: String, default_value: Variant = null) -> Variant:
	return energy.get(key, default_value)
