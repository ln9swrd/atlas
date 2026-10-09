class_name TowerRuntimeState
extends RefCounted

var id: String = ""
var type: String = ""
var position: Vector2 = Vector2.ZERO
var level: int = 1
var cooldown: float = 0.0
var definition: TowerDefinition
var effective_combat: Dictionary = {}

static func create(tower_id: String, tower_type: String, tower_position: Vector2, tower_definition: TowerDefinition) -> TowerRuntimeState:
	var state := TowerRuntimeState.new()
	state.id = tower_id
	state.type = tower_type
	state.position = tower_position
	state.definition = tower_definition
	state.effective_combat = tower_definition.combat.duplicate(true)
	return state

func get_combat_value(key: String, default_value: Variant = null) -> Variant:
	return effective_combat.get(key, default_value)

func get_upgrade_value(key: String, default_value: Variant = null) -> Variant:
	if definition == null:
		return default_value
	return definition.get_upgrade_value(key, default_value)

func get_weapon_definition() -> WeaponDefinition:
	var weapon := WeaponDefinition.new()
	weapon.id = "%s.weapon" % id
	weapon.source_type = "tower_runtime"
	weapon.source_id = type
	weapon.damage = float(effective_combat.get("damage", 0.0))
	weapon.cooldown = float(effective_combat.get("cooldown", 0.0))
	weapon.range = float(effective_combat.get("range", 0.0))
	weapon.preference = str(effective_combat.get("preference", ""))
	if definition != null:
		weapon.projectile_anim = str(definition.visuals.get("projectile_anim", ""))
	return weapon

func upgrade_to_level2() -> void:
	if definition == null or level >= 2:
		return
	level = 2
	effective_combat["damage"] = get_upgrade_value("damage", effective_combat.get("damage", 0.0))
	effective_combat["cooldown"] = get_upgrade_value("cooldown", effective_combat.get("cooldown", 0.0))
	effective_combat["range"] = get_upgrade_value("range", effective_combat.get("range", 0.0))
