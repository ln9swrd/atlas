class_name RobotDefinition
extends ObjectDefinition


var base_stats: Dictionary = {}
var progression: Dictionary = {}
var energy: Dictionary = {}
var visuals: Dictionary = {}
var faction_id: String = ""
var color: Color = Color.WHITE

func get_visual_asset(value: String) -> VisualAssetDefinition:
	return VisualAssetResolver.resolve(value)

static func from_catalog(data: Dictionary) -> RobotDefinition:
	var definition := RobotDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.name = str(data.get("name", ""))
	definition.apply_geometry_from_catalog(data)
	definition.faction_id = str(data.get("faction_id", ""))
	definition.base_stats = {
		"hp": float(data.get("hp", 0.0)),
		"speed": float(data.get("speed", 0.0)),
		"damage": float(data.get("damage", 0.0)),
		"cooldown": float(data.get("cooldown", 0.0)),
		"range": float(data.get("range", 0.0))
	}
	definition.progression = data.get("progression", {}).duplicate(true)
	definition.energy = data.get("energy", {}).duplicate(true)
	definition.color = Color(str(data.get("color", "ffffffff")))
	var animations: Dictionary = data.get("animations", {}) if data.get("animations", {}) is Dictionary else {}
	definition.visuals = {
		"profile": str(data.get("default_image", "")),
		"animations": animations.duplicate(true),
		# Legacy aliases remain available to older runtime consumers.
		"sprite_idle": str(animations.get("idle", data.get("sprite_idle", ""))),
		"sprite_attack": str(animations.get("attack", data.get("sprite_attack", ""))),
		"sprite_move": str(animations.get("move", data.get("sprite_move", ""))),
		"sprite_skill": str(animations.get("skill1", data.get("sprite_skill", ""))),
		"projectile_anim": str(animations.get("projectile", data.get("projectile_anim", "")))
	}
	return definition

func get_base_stat(key: String) -> Variant:
	return base_stats.get(key)

func get_progression_value(key: String, default_value: Variant = null) -> Variant:
	return progression.get(key, default_value)

func get_energy_value(key: String, default_value: Variant = null) -> Variant:
	return energy.get(key, default_value)
