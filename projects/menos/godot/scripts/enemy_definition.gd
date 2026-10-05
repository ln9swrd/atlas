class_name EnemyDefinition
extends ObjectDefinition


var visuals: Dictionary = {}
var robot_attack: Dictionary = {}

static func from_catalog(entry_id: String, data: Dictionary) -> EnemyDefinition:
	var definition := EnemyDefinition.new()
	definition.id = entry_id
	definition.name = str(data.get("name", entry_id))
	definition.combat = {
		"hp": float(data.get("hp", 0.0)),
		"speed": float(data.get("speed", 0.0)),
		"armor": float(data.get("armor", 0.0)),
		"radius": float(data.get("radius", 0.0)),
		"base_damage": float(data.get("base_damage", 0.0)),
		"reward": float(data.get("reward", 0.0)),
		"attack_type": str(data.get("attack_type", "")),
		"attack_range": float(data.get("attack_range", 0.0)),
		"attack_cooldown": float(data.get("attack_cooldown", 0.0))
	}
	definition.visuals = {
		"color": str(data.get("color", "")),
		"sprite_anim": str(data.get("sprite_anim", "")),
		"render_size": Vector2(float(data.get("render_width", 48.0)), float(data.get("render_height", 56.0)))
	}
	definition.robot_attack = {
		"damage": float(data.get("robot_damage", 0.0)),
		"range": float(data.get("robot_range", 0.0)),
		"cooldown": float(data.get("robot_cooldown", 0.0))
	}
	return definition

func get_visual_value(key: String, default_value: Variant = null) -> Variant:
	return visuals.get(key, default_value)

func get_combat_value(key: String, default_value: Variant = null) -> Variant:
	return combat.get(key, default_value)

func get_robot_attack_value(key: String, default_value: Variant = null) -> Variant:
	return robot_attack.get(key, default_value)
