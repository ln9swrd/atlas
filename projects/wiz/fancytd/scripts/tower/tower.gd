extends Node2D

signal attack_triggered(target: Node2D)

const PROJECTILE_SCENE = preload("res://fancytd/scenes/combat/projectile.tscn")

@export var data: TowerData
@export var enemies_container: Node

@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
	attack_triggered.connect(_on_attack_triggered)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	start_attack_timer()


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
	projectile.set_damage(data.damage)
