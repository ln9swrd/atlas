extends Node

enum GameState {
	NEW,
	PLAYING,
	GAME_OVER,
	VICTORY,
}

var current_state: GameState = GameState.NEW
const INITIAL_GOLD: int = 100
const INITIAL_LIFE: int = 20
const TOWER_SCENE = preload("res://fancytd/scenes/tower/tower.tscn")

var settings: GameSettings
var gold: int
var life: int


func set_settings(next_settings: GameSettings) -> void:
	settings = next_settings
	if settings != null:
		gold = settings.initial_gold if settings.initial_gold > 0 else INITIAL_GOLD
		life = settings.initial_life if settings.initial_life > 0 else INITIAL_LIFE


func _ready() -> void:
	if settings != null:
		gold = settings.initial_gold if settings.initial_gold > 0 else INITIAL_GOLD
		life = settings.initial_life if settings.initial_life > 0 else INITIAL_LIFE
	else:
		gold = INITIAL_GOLD
		life = INITIAL_LIFE



func set_state(next_state: GameState) -> void:
	current_state = next_state


func get_state() -> GameState:
	return current_state


func get_gold() -> int:
	return gold


func add_gold(amount: int) -> void:
	gold += amount


func get_life() -> int:
	return life


func lose_life() -> void:
	life = maxi(0, life - 1)
	if life <= 0:
		current_state = GameState.GAME_OVER


func purchase_tower(data: TowerData, parent: Node, position: Vector2 = Vector2.ZERO) -> Node2D:
	if data == null or parent == null or gold < data.cost:
		return null

	var tower := TOWER_SCENE.instantiate() as Node2D
	tower.set("data", data)
	tower.position = position

	var enemies_container: Node = parent.get_node_or_null("Enemies")
	if enemies_container == null and parent.get_parent() != null:
		enemies_container = parent.get_parent().get_node_or_null("Enemies")

	if enemies_container != null:
		tower.set("enemies_container", enemies_container)

	gold -= data.cost
	parent.add_child(tower)
	if tower.has_method("start_attack_timer"):
		tower.call("start_attack_timer")
	return tower
