class_name EnemyRuntimeState
extends RefCounted

var type: String = ""
var lane: String = ""
var position: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
var hp: float = 0.0
var max_hp: float = 0.0
var flash: float = 0.0
var robot_attack_timer: float = 0.0
var melee_attack_timer: float = 0.0
var attack_timer: float = 0.0
var boss_pattern_timer: float = 0.0
var boss_pattern_index: int = 0
var boss_windup_timer: float = 0.0
var boss_charge_timer: float = 0.0
var boss_charge_target: Vector2 = Vector2.ZERO
var boss_pattern_active: bool = false

static func create(enemy_type: String, enemy_lane: String, spawn_position: Vector2, initial_hp: float) -> EnemyRuntimeState:
	var state := EnemyRuntimeState.new()
	state.type = enemy_type
	state.lane = enemy_lane
	state.position = spawn_position
	state.start_position = spawn_position
	state.hp = initial_hp
	state.max_hp = initial_hp
	return state

func state_get(key: String, default_value: Variant = null) -> Variant:
	match key:
		"type": return type
		"lane": return lane
		"position": return position
		"start_position": return start_position
		"hp": return hp
		"max_hp": return max_hp
		"flash": return flash
		"robot_attack_timer": return robot_attack_timer
		"melee_attack_timer": return melee_attack_timer
		"attack_timer": return attack_timer
		_: return default_value

func has_state(key: String) -> bool:
	return key in ["type", "lane", "position", "start_position", "hp", "max_hp", "flash", "robot_attack_timer", "melee_attack_timer", "attack_timer"]
