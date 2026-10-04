class_name ObjectRepository
extends RefCounted

const ROBOT_CATALOG_PATH := "res://content/robots/robots.json"
const UNIT_CATALOG_PATH := "res://content/allied_units/allied_units.json"
const ENEMY_CATALOG_PATH := "res://content/enemies/enemies.json"
const TOWER_CATALOG_PATH := "res://content/towers/towers.json"

static var _robot_catalog: Dictionary = {}
static var _unit_catalog: Dictionary = {}
static var _enemy_catalog: Dictionary = {}
static var _tower_catalog: Dictionary = {}
static var _loaded := false

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_robot_catalog = ContentCatalogLoader.load_dictionary_catalog(ROBOT_CATALOG_PATH)
	_unit_catalog = ContentCatalogLoader.load_dictionary_catalog(UNIT_CATALOG_PATH)
	_enemy_catalog = ContentCatalogLoader.load_dictionary_catalog(ENEMY_CATALOG_PATH)
	_tower_catalog = ContentCatalogLoader.load_dictionary_catalog(TOWER_CATALOG_PATH)

static func reload() -> void:
	_robot_catalog.clear()
	_unit_catalog.clear()
	_enemy_catalog.clear()
	_tower_catalog.clear()
	_loaded = false
	_ensure_loaded()

static func get_robot(robot_id: String) -> RobotDefinition:
	_ensure_loaded()
	var data = _robot_catalog.get(robot_id)
	if not (data is Dictionary):
		return null
	return RobotDefinition.from_catalog(data)

static func list_robots() -> Array[String]:
	return _list_ids(_robot_catalog)

static func get_unit(unit_id: String) -> AlliedUnitDefinition:
	_ensure_loaded()
	var data = _unit_catalog.get(unit_id)
	if not (data is Dictionary):
		return null
	return AlliedUnitDefinition.from_catalog(unit_id, data)

static func list_units() -> Array[String]:
	return _list_ids(_unit_catalog)

static func get_enemy(enemy_id: String) -> EnemyDefinition:
	_ensure_loaded()
	var data = _enemy_catalog.get(enemy_id)
	if not (data is Dictionary):
		return null
	return EnemyDefinition.from_catalog(enemy_id, data)

static func list_enemies() -> Array[String]:
	return _list_ids(_enemy_catalog)

static func get_tower(tower_id: String) -> TowerDefinition:
	_ensure_loaded()
	var data = _tower_catalog.get(tower_id)
	if not (data is Dictionary):
		return null
	return TowerDefinition.from_catalog(tower_id, data)

static func list_towers() -> Array[String]:
	return _list_ids(_tower_catalog)

static func _list_ids(catalog: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for key in catalog.keys():
		result.append(str(key))
	result.sort()
	return result
