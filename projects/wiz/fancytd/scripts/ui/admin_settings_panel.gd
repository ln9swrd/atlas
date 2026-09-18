class_name AdminSettingsPanel
extends PanelContainer

@export var settings: GameSettings

@onready var _inputs: Dictionary = {
	"initial_gold": get_node_or_null("Margin/VBox/Fields/InitialGold/Input") as LineEdit,
	"initial_life": get_node_or_null("Margin/VBox/Fields/InitialLife/Input") as LineEdit,
	"tower_cost": get_node_or_null("Margin/VBox/Fields/TowerCost/Input") as LineEdit,
	"tower_damage": get_node_or_null("Margin/VBox/Fields/TowerDamage/Input") as LineEdit,
	"tower_range": get_node_or_null("Margin/VBox/Fields/TowerRange/Input") as LineEdit,
	"tower_attack_interval": get_node_or_null("Margin/VBox/Fields/AttackInterval/Input") as LineEdit,
	"enemy_max_hp": get_node_or_null("Margin/VBox/Fields/EnemyMaxHp/Input") as LineEdit,
	"enemy_speed": get_node_or_null("Margin/VBox/Fields/EnemySpeed/Input") as LineEdit,
	"enemy_reward": get_node_or_null("Margin/VBox/Fields/EnemyReward/Input") as LineEdit,
	"wave_spawn_count": get_node_or_null("Margin/VBox/Fields/WaveSpawnCount/Input") as LineEdit,
	"wave_spawn_interval": get_node_or_null("Margin/VBox/Fields/WaveSpawnInterval/Input") as LineEdit,
}

@onready var _apply_button: Button = get_node_or_null("Margin/VBox/ApplyButton") as Button
@onready var _status_label: Label = get_node_or_null("Margin/VBox/StatusLabel") as Label


func _ready() -> void:
	if settings == null and get_parent() != null and get_parent().get_parent() != null:
		settings = get_parent().get_parent().get("settings") as GameSettings

	if _apply_button != null and not _apply_button.pressed.is_connected(_on_apply_pressed):
		_apply_button.pressed.connect(_on_apply_pressed)

	for key in _inputs:
		var input: LineEdit = _inputs[key]
		if input != null:
			input.select_all_on_focus = true
			if not input.text_submitted.is_connected(_on_input_text_submitted):
				input.text_submitted.connect(_on_input_text_submitted)

	_load_settings_into_ui()


func _on_input_text_submitted(_new_text: String) -> void:
	_on_apply_pressed()


func set_settings(next_settings: GameSettings) -> void:
	settings = next_settings
	_load_settings_into_ui()


func _load_settings_into_ui() -> void:
	if settings == null:
		return

	_set_input_text("initial_gold", str(settings.initial_gold))
	_set_input_text("initial_life", str(settings.initial_life))

	if settings.towers.size() > 0 and settings.towers[0] != null:
		var t: TowerData = settings.towers[0]
		_set_input_text("tower_cost", str(t.cost))
		_set_input_text("tower_damage", str(t.damage))
		_set_input_text("tower_range", str(t.range))
		_set_input_text("tower_attack_interval", str(t.attack_interval))

	if settings.enemies.size() > 0 and settings.enemies[0] != null:
		var e: EnemyData = settings.enemies[0]
		_set_input_text("enemy_max_hp", str(e.max_hp))
		_set_input_text("enemy_speed", str(e.speed))
		_set_input_text("enemy_reward", str(e.reward))

	if settings.waves.size() > 0 and settings.waves[0] != null:
		var w: WaveData = settings.waves[0]
		if w.entries.size() > 0:
			var entry: Dictionary = w.entries[0]
			_set_input_text("wave_spawn_count", str(entry.get("spawn_count", 30)))
			_set_input_text("wave_spawn_interval", str(entry.get("spawn_interval", 0.25)))


func _set_input_text(key: String, val_str: String) -> void:
	var input: LineEdit = _inputs.get(key)
	if input != null:
		input.text = val_str


func _on_apply_pressed() -> void:
	if settings == null:
		_set_status("Apply Failed: No GameSettings attached", true)
		return

	var gold_val := _parse_int("initial_gold", -1)
	if gold_val < 0:
		_set_status("Validation Failed: Initial Gold must be >= 0", true)
		return

	var life_val := _parse_int("initial_life", 0)
	if life_val <= 0:
		_set_status("Validation Failed: Initial Life must be > 0", true)
		return

	var cost_val := _parse_int("tower_cost", -1)
	if cost_val < 0:
		_set_status("Validation Failed: Tower Cost must be >= 0", true)
		return

	var damage_val := _parse_float("tower_damage", -1.0)
	if damage_val < 0.0:
		_set_status("Validation Failed: Tower Damage must be >= 0", true)
		return

	var range_val := _parse_float("tower_range", 0.0)
	if range_val <= 0.0:
		_set_status("Validation Failed: Tower Range must be > 0", true)
		return

	var interval_val := _parse_float("tower_attack_interval", 0.0)
	if interval_val <= 0.0:
		_set_status("Validation Failed: Attack Interval must be > 0", true)
		return

	var max_hp_val := _parse_float("enemy_max_hp", 0.0)
	if max_hp_val <= 0.0:
		_set_status("Validation Failed: Enemy Max HP must be > 0", true)
		return

	var speed_val := _parse_float("enemy_speed", 0.0)
	if speed_val <= 0.0:
		_set_status("Validation Failed: Enemy Speed must be > 0", true)
		return

	var reward_val := _parse_int("enemy_reward", -1)
	if reward_val < 0:
		_set_status("Validation Failed: Enemy Reward must be >= 0", true)
		return

	var spawn_count_val := _parse_int("wave_spawn_count", 0)
	if spawn_count_val <= 0:
		_set_status("Validation Failed: Spawn Count must be > 0", true)
		return

	var spawn_interval_val := _parse_float("wave_spawn_interval", 0.0)
	if spawn_interval_val <= 0.0:
		_set_status("Validation Failed: Spawn Interval must be > 0", true)
		return

	settings.initial_gold = gold_val
	settings.initial_life = life_val

	if settings.towers.size() > 0 and settings.towers[0] != null:
		var t: TowerData = settings.towers[0]
		t.cost = cost_val
		t.damage = damage_val
		t.range = range_val
		t.attack_interval = interval_val

	if settings.enemies.size() > 0 and settings.enemies[0] != null:
		var e: EnemyData = settings.enemies[0]
		e.max_hp = max_hp_val
		e.speed = speed_val
		e.reward = reward_val

	if settings.waves.size() > 0 and settings.waves[0] != null:
		var w: WaveData = settings.waves[0]
		if w.entries.size() > 0:
			w.entries[0]["spawn_count"] = spawn_count_val
			w.entries[0]["spawn_interval"] = spawn_interval_val

	GameManager.set_settings(settings)

	if not settings.resource_path.is_empty():
		ResourceSaver.save(settings, settings.resource_path)
	else:
		ResourceSaver.save(settings, "res://fancytd/data/game_settings.tres")

	var main_scene: Node = get_tree().current_scene if get_tree() != null else null
	if main_scene != null:
		if main_scene.get("settings") != null:
			if settings.waves.size() > 0:
				main_scene.set("wave_data", settings.waves[0])
			if settings.towers.size() > 0:
				main_scene.set("purchase_tower_data", settings.towers[0])
				main_scene.set("_tower_data", settings.towers[0])
			if settings.enemies.size() > 0 and settings.enemies[0] != null:
				var dict = main_scene.get("enemy_data_by_id")
				if dict is Dictionary:
					dict["default"] = settings.enemies[0]

		var towers_container := main_scene.get_node_or_null("Towers")
		if towers_container != null and settings.towers.size() > 0 and settings.towers[0] != null:
			for tower in towers_container.get_children():
				tower.set("data", settings.towers[0])
				if tower.has_method("start_attack_timer"):
					tower.call("start_attack_timer")

		var map_tower := main_scene.get_node_or_null("Map/Tower")
		if map_tower != null and settings.towers.size() > 0 and settings.towers[0] != null:
			map_tower.set("data", settings.towers[0])
			if map_tower.has_method("start_attack_timer"):
				map_tower.call("start_attack_timer")

		var enemies_container := main_scene.get_node_or_null("Enemies")
		if enemies_container != null and settings.enemies.size() > 0 and settings.enemies[0] != null:
			for enemy in enemies_container.get_children():
				if enemy.has_method("set_data"):
					enemy.call("set_data", settings.enemies[0])

	_set_status("Apply Success: Live PIE & Resource Updated", false)


func _parse_int(key: String, default_error: int) -> int:
	var input: LineEdit = _inputs.get(key)
	if input == null or not input.text.is_valid_int():
		return default_error
	return input.text.to_int()


func _parse_float(key: String, default_error: float) -> float:
	var input: LineEdit = _inputs.get(key)
	if input == null or not input.text.is_valid_float():
		return default_error
	return input.text.to_float()


func _set_status(msg: String, is_error: bool) -> void:
	if _status_label != null:
		_status_label.text = "Status: " + msg
		if is_error:
			_status_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
		else:
			_status_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45))
