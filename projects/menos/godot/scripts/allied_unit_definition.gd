class_name AlliedUnitDefinition
extends RefCounted

var id: String = ""
var name: String = ""
var combat: Dictionary = {}
var ai: Dictionary = {}
var visuals: Dictionary = {}
var color: Color = Color.WHITE
var weapon: WeaponDefinition

static func from_catalog(entry_id: String, data: Dictionary) -> AlliedUnitDefinition:
	var definition := AlliedUnitDefinition.new()
	definition.id = entry_id
	definition.name = str(data.get("name", entry_id))
	definition.combat = {
		"hp": float(data.get("hp", 0.0)),
		"speed": float(data.get("speed", 0.0)),
		"damage": float(data.get("damage", 0.0)),
		"cooldown": float(data.get("cooldown", 0.0)),
		"range": float(data.get("range", 0.0)),
		"radius": float(data.get("radius", 24.0))
	}
	definition.ai = data.get("ai", {}).duplicate(true)
	definition.visuals = data.get("visuals", {}).duplicate(true)
	definition.color = Color(str(data.get("color", "ffffffff")))
	definition.weapon = WeaponDefinition.from_actor("allied_unit", entry_id, definition.combat)
	return definition

func get_combat_value(key: String, default_value: Variant = null) -> Variant:
	return combat.get(key, default_value)

func get_ai_value(key: String, default_value: Variant = null) -> Variant:
	return ai.get(key, default_value)
