extends Node2D

signal goal_reached

@export var speed: float = 120.0
@export var max_hp: float = 20.0
@export var data: EnemyData

var current_hp: float
var is_dead: bool = false
var has_reached_goal: bool = false

var path_node: Line2D
var path_points: PackedVector2Array
var next_point_index: int = 1


func set_data(next_data: EnemyData) -> void:
	data = next_data
	if data != null:
		if data.max_hp > 0.0:
			max_hp = data.max_hp
		if data.speed > 0.0:
			speed = data.speed
	current_hp = max_hp


func _ready() -> void:
	if current_hp <= 0.0:
		current_hp = max_hp


func apply_damage(amount: float) -> void:
	if is_dead:
		return

	current_hp = maxf(0.0, current_hp - amount)
	if current_hp <= 0.0:
		_die()


func _die() -> void:
	if is_dead:
		return

	is_dead = true
	if data != null:
		GameManager.add_gold(data.reward)
	queue_free()


func _reach_goal() -> void:
	if has_reached_goal:
		return

	has_reached_goal = true
	GameManager.lose_life()
	goal_reached.emit()
	queue_free()


func set_path(path: Line2D) -> void:
	path_node = path
	path_points = path.points
	next_point_index = 1


func _physics_process(delta: float) -> void:
	if is_dead or has_reached_goal or path_node == null or next_point_index >= path_points.size():
		return

	var target_position := path_node.to_global(path_points[next_point_index])
	global_position = global_position.move_toward(target_position, speed * delta)
	if global_position.distance_to(target_position) <= 0.01:
		global_position = target_position
		next_point_index += 1
		if next_point_index >= path_points.size():
			_reach_goal()
