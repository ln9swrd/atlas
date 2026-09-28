class_name EnemyEditorMain
extends Control

const ENEMY_FILE := "res://content/enemies/enemies.json"
const ENEMY_TYPES := ["normal", "rusher", "heavy", "giant"]
const DEFAULT_DATA = preload("res://data.gd")

var enemy_data: Dictionary = {}
var selected_type := ""
var enemy_list: OptionButton
var name_edit: LineEdit
var hp_spin: SpinBox
var speed_spin: SpinBox
var armor_spin: SpinBox
var damage_spin: SpinBox
var reward_spin: SpinBox
var radius_spin: SpinBox
var color_edit: ColorPickerButton
var sprite_edit: LineEdit
var file_dialog: FileDialog
var robot_damage_spin: SpinBox
var robot_range_spin: SpinBox
var robot_cooldown_spin: SpinBox
var status_label: Label

func _ready() -> void:
	_build_ui()
	_load_data()
	if enemy_list.item_count > 0:
		enemy_list.select(0)
		_on_enemy_selected(0)

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 12)
	add_child(root)
	var title := Label.new()
	title.text = "MENOS // ENEMY EDITOR"
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)
	var top := HBoxContainer.new()
	root.add_child(top)
	enemy_list = OptionButton.new()
	enemy_list.custom_minimum_size.x = 220
	enemy_list.item_selected.connect(_on_enemy_selected)
	top.add_child(enemy_list)
	var reload_btn := Button.new()
	reload_btn.text = "Reload"
	reload_btn.pressed.connect(_load_data)
	top.add_child(reload_btn)
	var save_btn := Button.new()
	save_btn.text = "Save JSON"
	save_btn.pressed.connect(_save_data)
	top.add_child(save_btn)
	status_label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(status_label)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	_build_properties(content)

func _build_properties(parent: VBoxContainer) -> void:
	var title := Label.new()
	title.text = "ENEMY PROPERTIES"
	title.add_theme_font_size_override("font_size", 16)
	parent.add_child(title)
	name_edit = _line_row(parent, "Name")
	hp_spin = _spin_row(parent, "HP", 1, 999999, 1, 100)
	speed_spin = _spin_row(parent, "Speed", 0, 9999, 0.1, 10)
	armor_spin = _spin_row(parent, "Armor", 0, 9999, 0.1, 0)
	damage_spin = _spin_row(parent, "Base Damage", 0, 9999, 0.1, 1)
	reward_spin = _spin_row(parent, "Reward", 0, 999999, 1, 10)
	radius_spin = _spin_row(parent, "Radius", 1, 999, 0.5, 10)
	var color_row := HBoxContainer.new()
	parent.add_child(color_row)
	var color_label := Label.new()
	color_label.text = "Color"
	color_label.custom_minimum_size.x = 130
	color_row.add_child(color_label)
	color_edit = ColorPickerButton.new()
	color_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	color_row.add_child(color_edit)
	var sprite_row := HBoxContainer.new()
	parent.add_child(sprite_row)
	var sprite_label := Label.new()
	sprite_label.text = "Animation Sprite"
	sprite_label.custom_minimum_size.x = 130
	sprite_row.add_child(sprite_label)
	sprite_edit = LineEdit.new()
	sprite_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sprite_row.add_child(sprite_edit)
	var browse := Button.new()
	browse.text = "Browse"
	browse.pressed.connect(_open_sprite_dialog)
	sprite_row.add_child(browse)
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.filters = ["*.png ; PNG"]
	file_dialog.file_selected.connect(func(path): sprite_edit.text = path)
	add_child(file_dialog)
	var sep := HSeparator.new()
	parent.add_child(sep)
	var combat_title := Label.new()
	combat_title.text = "GIANT SPECIAL COMBAT"
	combat_title.add_theme_font_size_override("font_size", 16)
	parent.add_child(combat_title)
	robot_damage_spin = _spin_row(parent, "Robot Damage", 0, 9999, 0.1, 0)
	robot_range_spin = _spin_row(parent, "Robot Range", 0, 9999, 0.1, 0)
	robot_cooldown_spin = _spin_row(parent, "Robot Cooldown", 0, 9999, 0.05, 0)

func _line_row(parent: VBoxContainer, label_text: String) -> LineEdit:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 130
	row.add_child(label)
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(edit)
	return edit

func _spin_row(parent: VBoxContainer, label_text: String, minimum: float, maximum: float, step: float, value: float) -> SpinBox:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 130
	row.add_child(label)
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step
	spin.value = value
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spin)
	return spin

func _load_data() -> void:
	enemy_data.clear()
	var file := FileAccess.open(ENEMY_FILE, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			enemy_data = parsed
	if enemy_data.is_empty():
		enemy_data = DEFAULT_DATA.ENEMIES.duplicate(true)
	_refresh_enemy_list()
	_set_status("Loaded: " + ENEMY_FILE if file else "Loaded defaults (JSON not found)")

func _refresh_enemy_list() -> void:
	enemy_list.clear()
	for enemy_type in ENEMY_TYPES:
		if enemy_data.has(enemy_type):
			enemy_list.add_item(str(enemy_data[enemy_type].get("name", enemy_type.to_upper())))
		else:
			enemy_list.add_item(enemy_type.to_upper())
		enemy_list.set_item_metadata(enemy_list.item_count - 1, enemy_type)

func _on_enemy_selected(index: int) -> void:
	if index < 0 or index >= enemy_list.item_count:
		return
	selected_type = str(enemy_list.get_item_metadata(index))
	var data: Dictionary = enemy_data.get(selected_type, {})
	name_edit.text = str(data.get("name", selected_type.to_upper()))
	hp_spin.value = float(data.get("hp", 1.0))
	speed_spin.value = float(data.get("speed", 0.0))
	armor_spin.value = float(data.get("armor", 0.0))
	damage_spin.value = float(data.get("base_damage", 0.0))
	reward_spin.value = float(data.get("reward", 0.0))
	radius_spin.value = float(data.get("radius", 10.0))
	color_edit.color = Color(str(data.get("color", "#ffffff")))
	sprite_edit.text = str(data.get("sprite_anim", "res://assets/menos/sprites/enemy_%s_anim.png" % selected_type))
	robot_damage_spin.value = float(data.get("robot_damage", 0.0))
	robot_range_spin.value = float(data.get("robot_range", 0.0))
	robot_cooldown_spin.value = float(data.get("robot_cooldown", 0.0))
	var giant := selected_type == "giant"
	robot_damage_spin.editable = giant
	robot_range_spin.editable = giant
	robot_cooldown_spin.editable = giant

func _save_data() -> void:
	if selected_type.is_empty():
		_set_status("No enemy selected.")
		return
	if name_edit.text.strip_edges().is_empty():
		_set_status("Name is required.")
		return
	var data: Dictionary = enemy_data.get(selected_type, {}).duplicate(true)
	data["name"] = name_edit.text.strip_edges()
	data["hp"] = float(hp_spin.value)
	data["speed"] = float(speed_spin.value)
	data["armor"] = float(armor_spin.value)
	data["base_damage"] = float(damage_spin.value)
	data["reward"] = int(reward_spin.value)
	data["radius"] = float(radius_spin.value)
	data["color"] = color_edit.color.to_html(false)
	data["sprite_anim"] = sprite_edit.text.strip_edges()
	if selected_type == "giant":
		data["robot_damage"] = float(robot_damage_spin.value)
		data["robot_range"] = float(robot_range_spin.value)
		data["robot_cooldown"] = float(robot_cooldown_spin.value)
	else:
		data.erase("robot_damage")
		data.erase("robot_range")
		data.erase("robot_cooldown")
	enemy_data[selected_type] = data
	var dir := DirAccess.open("res://content")
	if dir == null:
		_set_status("FAILED: content directory unavailable.")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://content/enemies"))
	var file := FileAccess.open(ENEMY_FILE, FileAccess.WRITE)
	if file == null:
		_set_status("FAILED to open JSON for writing.")
		return
	file.store_string(JSON.stringify(enemy_data, "  "))
	file.close()
	_refresh_enemy_list()
	enemy_list.select(ENEMY_TYPES.find(selected_type))
	_set_status("SAVED: " + ENEMY_FILE)

func _open_sprite_dialog() -> void:
	if file_dialog:
		file_dialog.popup_centered_ratio(0.75)

func _set_status(message: String) -> void:
	if status_label:
		status_label.text = "Status: " + message
