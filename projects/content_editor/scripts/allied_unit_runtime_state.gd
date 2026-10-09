class_name AlliedUnitRuntimeState
extends RefCounted

var id: String = ""
var type: String = ""
var position: Vector2 = Vector2.ZERO
var hp: float = 0.0
var max_hp: float = 0.0
var attack_timer: float = 0.0
var support_timer: float = 0.0
var target: EnemyRuntimeState = null
var flash: float = 0.0
var definition: AlliedUnitDefinition
var weapon: WeaponDefinition

static func create(unit_id: String, unit_type: String, unit_position: Vector2, unit_definition: AlliedUnitDefinition) -> AlliedUnitRuntimeState:
	var state := AlliedUnitRuntimeState.new()
	state.id = unit_id
	state.type = unit_type
	state.position = unit_position
	state.definition = unit_definition
	state.weapon = unit_definition.weapon
	state.hp = float(unit_definition.get_combat_value("hp", 0.0))
	state.max_hp = state.hp
	return state

func get_combat_value(key: String, default_value: Variant = null) -> Variant:
	if definition == null:
		return default_value
	return definition.get_combat_value(key, default_value)

func get_ai_value(key: String, default_value: Variant = null) -> Variant:
	if definition == null:
		return default_value
	return definition.get_ai_value(key, default_value)
