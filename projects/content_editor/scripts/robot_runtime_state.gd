class_name RobotRuntimeState
extends RefCounted

var active: bool = false
var position: Vector2 = Vector2.ZERO
var spot: String = ""
var is_moving: bool = false
var move_direction: Vector2 = Vector2.ZERO
var hp: float = 0.0
var max_hp: float = 0.0
var energy: float = 0.0
var attack: float = 0.0
var area: float = 0.0
var pierce: float = 0.0
var special: float = 0.0
var special_type: String = ""
var finisher: float = 0.0
var flash: float = 0.0
var target_pos: Variant = null

func reset(initial_position: Vector2, initial_max_hp: float, initial_energy: float) -> void:
	active = false
	position = initial_position
	spot = ""
	is_moving = false
	move_direction = Vector2.ZERO
	hp = initial_max_hp
	max_hp = initial_max_hp
	energy = initial_energy
	attack = 0.0
	area = 0.0
	pierce = 0.0
	special = 0.0
	special_type = ""
	finisher = 0.0
	flash = 0.0
	target_pos = null

func has_target_position() -> bool:
	return target_pos != null

func state_get(key: String, default_value: Variant = null) -> Variant:
	match key:
		"active": return active
		"position": return position
		"spot": return spot
		"is_moving": return is_moving
		"move_direction": return move_direction
		"hp": return hp
		"max_hp": return max_hp
		"energy": return energy
		"attack": return attack
		"area": return area
		"pierce": return pierce
		"special": return special
		"special_type": return special_type
		"finisher": return finisher
		"flash": return flash
		"target_pos": return target_pos if target_pos != null else default_value
	return default_value
func has_state(key: String) -> bool:
	return key == "target_pos" and target_pos != null

func erase_state(key: String) -> void:
	if key == "target_pos":
		target_pos = null
