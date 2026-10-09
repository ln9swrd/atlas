class_name WeaponDefinition
extends RefCounted

var id: String = ""
var source_type: String = ""
var source_id: String = ""
var damage: float = 0.0
var cooldown: float = 0.0
var range: float = 0.0
var attack_type: String = ""
var preference: String = ""
var projectile_anim: String = ""

static func from_actor(source_type_value: String, source_id_value: String, data: Dictionary) -> WeaponDefinition:
	var weapon := WeaponDefinition.new()
	weapon.id = "%s.%s" % [source_type_value, source_id_value]
	weapon.source_type = source_type_value
	weapon.source_id = source_id_value
	weapon.damage = float(data.get("damage", data.get("base_damage", 0.0)))
	weapon.cooldown = float(data.get("cooldown", data.get("attack_cooldown", 0.0)))
	weapon.range = float(data.get("range", data.get("attack_range", 0.0)))
	weapon.attack_type = str(data.get("attack_type", ""))
	weapon.preference = str(data.get("preference", ""))
	weapon.projectile_anim = str(data.get("projectile_anim", ""))
	return weapon

static func from_enemy_robot_attack(source_id_value: String, data: Dictionary) -> WeaponDefinition:
	var weapon := WeaponDefinition.new()
	weapon.id = "enemy.%s.robot_attack" % source_id_value
	weapon.source_type = "enemy_robot_attack"
	weapon.source_id = source_id_value
	weapon.damage = float(data.get("robot_damage", 0.0))
	weapon.cooldown = float(data.get("robot_cooldown", 0.0))
	weapon.range = float(data.get("robot_range", 0.0))
	weapon.attack_type = "ranged"
	weapon.projectile_anim = str(data.get("projectile_anim", ""))
	return weapon
