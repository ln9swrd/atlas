extends Node2D

signal wave_completed

const ENEMY_SCENE = preload("res://fancytd/scenes/enemy/enemy.tscn")
const ENEMY_SCENES := {"default": ENEMY_SCENE, "basic": ENEMY_SCENE, "fast": ENEMY_SCENE, "heavy": ENEMY_SCENE, "boss": ENEMY_SCENE}
const DEFAULT_SPAWN_INTERVAL: float = 0.25

@export var settings: GameSettings
@export var wave_data: WaveData
@export var enemy_data_by_id: Dictionary[String, EnemyData] = {}
@export var purchase_tower_data: TowerData

var _entries: Array[Dictionary] = []
var _entry_completed: Array[bool] = []
var _entry_index: int = 0
var _spawned_count: int = 0
var _spawn_timer: Timer
var _wave_completed: bool = false
var _has_started_wave: bool = false
var _can_start_next_wave: bool = false
var _gold_label: Label
var _life_label: Label
var _game_over_label: Label
var _victory_label: Label
var _buy_tower_button: Button
var _tower_data: TowerData
var _purchase_status_label: Label
var _build_label: Label
var _synergy_label: Label
var _tower_cycle_button: Button
var _reward_panel: RewardChoicePanel
var _run_state: RunState
var _wave_index: int = 0
var _awaiting_reward: bool = false
var _tower_selection_index: int = 0


var _is_placing_tower: bool = false


func _ready() -> void:
	if settings != null:
		GameManager.set_settings(settings)
		if settings.waves.size() > 0:
			wave_data = settings.waves[0]
		if settings.towers.size() > 0:
			purchase_tower_data = settings.towers[0]
			_tower_data = settings.towers[0]
		for enemy_item in settings.enemies:
			if enemy_item != null and not enemy_item.id.is_empty():
				enemy_data_by_id[enemy_item.id] = enemy_item

	_gold_label = get_node_or_null("UI/GoldLabel") as Label
	_life_label = get_node_or_null("UI/LifeLabel") as Label
	_game_over_label = get_node_or_null("UI/GameOverLabel") as Label
	_victory_label = get_node_or_null("UI/VictoryLabel") as Label
	_buy_tower_button = get_node_or_null("UI/BuyTowerButton") as Button
	_purchase_status_label = get_node_or_null("UI/PurchaseStatusLabel") as Label
	_build_label = get_node_or_null("UI/BuildLabel") as Label
	_synergy_label = get_node_or_null("UI/SynergyLabel") as Label
	_tower_cycle_button = get_node_or_null("UI/TowerCycleButton") as Button
	_reward_panel = get_node_or_null("UI/RewardChoicePanel") as RewardChoicePanel
	_run_state = get_node_or_null("RunState") as RunState
	if _run_state == null:
		_run_state = RunState.new()
		_run_state.name = "RunState"
		add_child(_run_state)
	if _run_state.unlocked_tower_ids.is_empty():
		_run_state.reset(["fire", "ice"])
	if _buy_tower_button != null and not _buy_tower_button.pressed.is_connected(_on_buy_tower_pressed):
		_buy_tower_button.pressed.connect(_on_buy_tower_pressed)
	if _tower_cycle_button != null and not _tower_cycle_button.pressed.is_connected(_on_tower_cycle_pressed):
		_tower_cycle_button.pressed.connect(_on_tower_cycle_pressed)
	if _reward_panel != null and not _reward_panel.reward_selected.is_connected(_on_reward_selected):
		_reward_panel.reward_selected.connect(_on_reward_selected)
	var new_run_button := get_node_or_null("UI/NewRunButton") as Button
	if new_run_button != null and not new_run_button.pressed.is_connected(_on_new_run_pressed):
		new_run_button.pressed.connect(_on_new_run_pressed)
	if purchase_tower_data != null:
		_tower_data = purchase_tower_data
	var existing_tower := get_node_or_null("Map/Tower") as Node2D
	if existing_tower != null:
		if _tower_data == null:
			_tower_data = existing_tower.get("data") as TowerData
		else:
			existing_tower.set("data", _tower_data)

	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	wave_completed.connect(_on_wave_completed)
	add_child(_spawn_timer)

	if wave_data == null:
		_spawn_enemy("default")
		_spawn_timer.wait_time = DEFAULT_SPAWN_INTERVAL
		_spawn_timer.start()
		return

	_wave_index = 0
	GameManager.set_state(GameManager.GameState.PLAYING)
	start_wave(wave_data)


func _process(_delta: float) -> void:
	if _gold_label != null:
		_gold_label.text = "Gold: %d" % GameManager.get_gold()
	if _life_label != null:
		_life_label.text = "Life: %d" % GameManager.get_life()
	if _game_over_label != null:
		_game_over_label.visible = GameManager.get_state() == GameManager.GameState.GAME_OVER
	if _victory_label != null:
		_victory_label.visible = GameManager.get_state() == GameManager.GameState.VICTORY
	if _build_label != null and _run_state != null:
		_build_label.text = "BUILD\n" + ", ".join(_run_state.unlocked_tower_ids)
	if _synergy_label != null and _run_state != null:
		var synergies := SynergyResolver.active_synergies(_run_state)
		_synergy_label.text = "SYNERGY\n" + (", ".join(synergies) if not synergies.is_empty() else "None")
	if _tower_cycle_button != null:
		var selected_data := _resolve_purchase_tower_data()
		_tower_cycle_button.text = "Tower: %s" % selected_data.name if selected_data != null else "Tower: None"
	if _has_started_wave and not _wave_completed:
		_complete_wave_if_ready()
	if _buy_tower_button != null:
		var current_tower_data := _resolve_purchase_tower_data()
		if current_tower_data != null:
			_buy_tower_button.text = "Buy Tower (%d)" % current_tower_data.cost
			_buy_tower_button.disabled = GameManager.get_gold() < current_tower_data.cost
		else:
			_buy_tower_button.disabled = true


func _on_buy_tower_pressed() -> void:
	if _awaiting_reward:
		return
	if _is_placing_tower:
		_is_placing_tower = false
		_set_purchase_status("Placement cancelled")
		return

	var current_tower_data := _resolve_purchase_tower_data()
	if current_tower_data == null:
		_set_purchase_status("Purchase failed: no TowerData")
		return

	var towers_container := get_node_or_null("Towers") as Node
	if towers_container == null:
		_set_purchase_status("Purchase failed: no Towers container")
		return
	if GameManager.get_gold() < current_tower_data.cost:
		_set_purchase_status("Purchase failed: not enough Gold (%d needed)" % current_tower_data.cost)
		return

	_is_placing_tower = true
	_set_purchase_status("Placement mode: click map to place tower")


func _on_tower_cycle_pressed() -> void:
	if settings == null or _run_state == null:
		return
	var available: Array[TowerData] = []
	for tower_data in settings.towers:
		if tower_data != null and _run_state.has_tower(tower_data.id):
			available.append(tower_data)
	if available.is_empty():
		return
	_tower_selection_index = (_tower_selection_index + 1) % available.size()
	purchase_tower_data = available[_tower_selection_index]
	_tower_data = purchase_tower_data
	_set_purchase_status("Selected %s" % purchase_tower_data.name)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_placing_tower:
		return

	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT) or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		_is_placing_tower = false
		_set_purchase_status("Placement cancelled")
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var current_tower_data := _resolve_purchase_tower_data()
		var towers_container := get_node_or_null("Towers") as Node
		if current_tower_data == null or towers_container == null or GameManager.get_gold() < current_tower_data.cost:
			_is_placing_tower = false
			_set_purchase_status("Purchase failed: not enough Gold")
			return

		var spawn_position := get_global_mouse_position()
		var purchased_tower := GameManager.purchase_tower(current_tower_data, towers_container, spawn_position)
		if purchased_tower != null:
			purchased_tower.global_position = spawn_position
			purchased_tower.z_index = 5
			_set_purchase_status("Tower purchased at (%d, %d)" % [int(spawn_position.x), int(spawn_position.y)])
		else:
			_set_purchase_status("Purchase failed")

		_is_placing_tower = false
		get_viewport().set_input_as_handled()


func _set_purchase_status(message: String) -> void:
	if _purchase_status_label != null:
		_purchase_status_label.text = message


func _resolve_purchase_tower_data() -> TowerData:
	if purchase_tower_data != null:
		return purchase_tower_data

	var existing_tower := get_node_or_null("Map/Tower") as Node2D
	if existing_tower != null:
		return existing_tower.get("data") as TowerData

	return _tower_data


func start_wave(wave: WaveData) -> bool:
	if wave == null or _awaiting_reward or (_has_started_wave and not _can_start_next_wave):
		return false

	wave_data = wave
	_entries = wave.entries
	_entry_completed.clear()
	for _entry in _entries:
		_entry_completed.append(false)
	_entry_index = 0
	_spawned_count = 0
	_wave_completed = false
	_has_started_wave = true
	_can_start_next_wave = false
	_start_current_entry()
	return true


func start_next_wave(next_wave: WaveData) -> bool:
	if not _can_start_next_wave:
		return false

	return start_wave(next_wave)


func _on_wave_completed() -> void:
	_can_start_next_wave = true
	if settings == null or _wave_index >= settings.waves.size() - 1:
		return
	_awaiting_reward = true
	if _spawn_timer != null:
		_spawn_timer.stop()
	_show_reward_choices()


func _start_current_entry() -> void:
	while _entry_index < _entries.size():
		var entry := _entries[_entry_index]
		var spawn_count := int(entry.get("spawn_count", 0))
		if spawn_count > 0 and ENEMY_SCENES.has(entry.get("enemy_id", "")):
			_spawn_timer.wait_time = float(entry.get("spawn_interval", 0.0))
			_spawn_timer.start()
			return

		_entry_completed[_entry_index] = true
		_entry_index += 1
		_spawned_count = 0

	_complete_wave_if_ready()


func _on_spawn_timer_timeout() -> void:
	if wave_data == null:
		var enemies_container := get_node("Enemies") as Node
		if enemies_container.get_child_count() == 0:
			_spawn_enemy("default")
		_spawn_timer.start()
		return

	if _entry_index >= _entries.size():
		return

	var entry := _entries[_entry_index]
	var enemy := _spawn_enemy(entry.get("enemy_id", ""))
	if enemy == null:
		return

	_spawned_count += 1

	if _spawned_count >= int(entry.get("spawn_count", 0)):
		_entry_completed[_entry_index] = true
		_entry_index += 1
		_spawned_count = 0
		_start_current_entry()
		return

	_spawn_timer.start()


func _complete_wave_if_ready() -> void:
	if _wave_completed:
		return

	for entry_completed in _entry_completed:
		if not entry_completed:
			return

	var enemies_container := get_node_or_null("Enemies") as Node
	if enemies_container != null:
		for child in enemies_container.get_children():
			if is_instance_valid(child) and not child.is_queued_for_deletion() and child.get("is_dead") != true and child.get("has_reached_goal") != true:
				return

	_wave_completed = true
	wave_completed.emit()
	if settings == null or _wave_index >= settings.waves.size() - 1:
		if GameManager.get_life() > 0 and GameManager.get_state() != GameManager.GameState.GAME_OVER:
			GameManager.set_state(GameManager.GameState.VICTORY)


func _show_reward_choices() -> void:
	if _reward_panel == null or settings == null or settings.rewards.is_empty():
		return
	var choices: Array[RewardData] = []
	var start_index := (_wave_index * 2) % settings.rewards.size()
	for offset in 3:
		choices.append(settings.rewards[(start_index + offset) % settings.rewards.size()])
	_reward_panel.show_rewards(choices)


func _on_reward_selected(reward: RewardData) -> void:
	if _run_state == null or reward == null or settings == null:
		return
	_run_state.apply_reward(reward)
	_awaiting_reward = false
	_wave_index += 1
	_has_started_wave = false
	_can_start_next_wave = false
	_set_purchase_status("Reward selected: %s" % reward.title)
	start_wave(settings.waves[_wave_index])


func _on_new_run_pressed() -> void:
	get_tree().reload_current_scene()


func _spawn_enemy(enemy_id: String) -> Node2D:
	var enemy_scene: PackedScene = ENEMY_SCENES.get(enemy_id)
	if enemy_scene == null:
		return null

	var spawn_marker := get_node("Map/Spawn") as Marker2D
	var path := get_node("Map/Path") as Line2D
	var enemies_container := get_node("Enemies") as Node
	var enemy := enemy_scene.instantiate() as Node2D
	enemies_container.add_child(enemy)
	enemy.global_position = spawn_marker.global_position
	var enemy_data: EnemyData = enemy_data_by_id.get(enemy_id)
	if enemy_data != null:
		enemy.call("set_data", enemy_data)
	enemy.call("set_path", path)
	return enemy
