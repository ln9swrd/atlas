class_name TowerDefinition
extends ObjectDefinition


var upgrade: Dictionary = {}
var visuals: Dictionary = {}

static func from_catalog(entry_id: String, data: Dictionary) -> TowerDefinition:
	var definition := TowerDefinition.new()
	definition.id = entry_id
	definition.name = str(data.get("name", entry_id))
	definition.apply_geometry_from_catalog(data)
	definition.combat = {
		"cooldown": float(data.get("cooldown", 0.0)),
		"cost": float(data.get("cost", 0.0)),
		"damage": float(data.get("damage", 0.0)),
		"range": float(data.get("range", 0.0)),
		"preference": str(data.get("preference", ""))
	}
	definition.upgrade = data.get("level2", {}).duplicate(true)
	definition.visuals = {
		"sprite_anim": str(data.get("sprite_anim", "")),
		"projectile_anim": str(data.get("projectile_anim", ""))
	}
	return definition

func get_combat_value(key: String, default_value: Variant = null) -> Variant:
	return combat.get(key, default_value)

func get_upgrade_value(key: String, default_value: Variant = null) -> Variant:
	return upgrade.get(key, default_value)
