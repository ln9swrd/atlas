extends Node2D

signal attack_triggered(target: Node2D)

const PROJECTILE_SCENE = preload("res://fancytd/scenes/combat/projectile.tscn")

@export var data: TowerData
@export var enemies_container: Node

@onready var attack_timer: Timer = $AttackTimer
@onready var visual: Polygon2D = get_node_or_null("Visual") as Polygon2D


func _ready() -> void:
	attack_triggered.connect(_on_attack_triggered)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	start_attack_timer()

	var run_state: RunState = get_tree().current_scene.get_node_or_null("RunState") as RunState if get_tree() != null and get_tree().current_scene != null else null
	if run_state != null and not run_state.build_changed.is_connected(update_visual):
		run_state.build_changed.connect(update_visual)

	update_visual()


func update_visual() -> void:
	if visual == null or data == null:
		return

	var base_color: Color
	match data.id:
		"fire":
			base_color = Color(0.95, 0.35, 0.15)
		"ice":
			base_color = Color(0.2, 0.75, 0.95)
		"lightning":
			base_color = Color(0.95, 0.85, 0.2)
		_:
			base_color = Color(0.16, 0.48, 0.82)

	visual.color = base_color

	var run_state: RunState = get_tree().current_scene.get_node_or_null("RunState") as RunState if get_tree() != null and get_tree().current_scene != null else null
	if run_state == null:
		return

	var bonus_dmg := run_state.get_tower_damage_bonus(data.id)
	if bonus_dmg > 0.0:
		visual.color = base_color.lightened(0.25)
		scale = Vector2(1.15, 1.15)
	else:
		scale = Vector2(1.0, 1.0)

	var active_synergies := SynergyResolver.active_synergies(run_state)
	var has_synergy := false
	if data.id == "fire" and active_synergies.has(SynergyResolver.THERMAL_SHOCK):
		has_synergy = true
	elif data.id == "lightning" and active_synergies.has(SynergyResolver.CONDUCTIVE):
		has_synergy = true
	elif data.id == "ice" and not active_synergies.is_empty():
		has_synergy = true

	if has_synergy:
		modulate = Color(1.3, 1.3, 1.3, 1.0)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)


func start_attack_timer() -> void:
	if enemies_container == null and get_tree() != null and get_tree().current_scene != null:
		enemies_container = get_tree().current_scene.get_node_or_null("Enemies")
	if data == null or enemies_container == null or data.attack_interval <= 0.0:
		return

	attack_timer.wait_time = data.attack_interval
	if attack_timer.is_stopped():
		attack_timer.start()


func detect_enemies(enemies_container: Node) -> Array[Node2D]:
	var detected_enemies: Array[Node2D] = []
	if data == null:
		return detected_enemies

	for child in enemies_container.get_children():
		if child is Node2D and global_position.distance_to(child.global_position) <= data.range:
			detected_enemies.append(child)

	return detected_enemies


func select_target(enemies: Array[Node2D]) -> Node2D:
	var selected_enemy: Node2D
	var furthest_point_index := -1

	for enemy in enemies:
		var point_index = enemy.get("next_point_index")
		if point_index is int and point_index > furthest_point_index:
			furthest_point_index = point_index
			selected_enemy = enemy

	return selected_enemy


func _on_attack_timer_timeout() -> void:
	if enemies_container == null:
		if get_tree() != null and get_tree().current_scene != null:
			enemies_container = get_tree().current_scene.get_node_or_null("Enemies")
		if enemies_container == null:
			return

	var detected_enemies := detect_enemies(enemies_container)
	var target := select_target(detected_enemies)
	if target == null or not is_instance_valid(target) or target.get("is_dead") == true:
		return

	attack_triggered.emit(target)


func _on_attack_triggered(target: Node2D) -> void:
	if data == null:
		return

	var projectile := PROJECTILE_SCENE.instantiate()
	var spawn_parent: Node = get_tree().current_scene if get_tree() != null else null
	if spawn_parent == null:
		spawn_parent = get_parent()
	if spawn_parent == null:
		spawn_parent = self

	spawn_parent.add_child(projectile)
	projectile.global_position = global_position
	projectile.set_target(target)
	var run_state: RunState = get_tree().current_scene.get_node_or_null("RunState") as RunState
	var damage := data.damage
	if run_state != null:
		damage += run_state.get_tower_damage_bonus(data.id)
	projectile.set_damage(damage)
	projectile.set_effect(
		data.id,
		maxf(0.2, data.slow_factor - (run_state.ice_slow_bonus if run_state != null and data.id == "ice" else 0.0)),
		data.slow_duration,
		data.chain_range,
		data.chain_damage_ratio + (run_state.lightning_chain_bonus if run_state != null and data.id == "lightning" else 0.0),
		enemies_container,
		run_state,
	)
