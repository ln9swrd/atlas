class_name UnitEditorMain
extends Control

const UNIT_FILE := "res://content/allied_units/allied_units.json"
const ENEMY_FILE := "res://content/enemies/enemies.json"
const BASE_UNIT_TYPES := ["basic", "light", "ranged", "heavy", "support"]
const UNIT_DESCRIPTIONS := {
	"basic": "기본 전투형 유닛. 공격과 생존의 균형을 갖춘 표준형입니다.",
	"light": "경량 기동형 유닛. 빠른 이동과 전개에 특화됩니다.",
	"ranged": "원거리 공격형 유닛. 긴 사거리에서 지속적으로 화력을 투사합니다.",
	"heavy": "헤비 전투형 유닛. 높은 내구도와 강한 화력을 갖습니다.",
	"support": "지원형 유닛. 아군의 전투를 보조하고 회복합니다."
}
const IMAGE_STATE = preload("res://editor/image_editor_state.gd")
const UNIT_COLOR_SHADER = preload("res://shaders/allied_unit_color.gdshader")

var unit_data: Dictionary = {}
var unit_sources: Dictionary = {}
var projectile_edit: LineEdit
var selected_type := ""
var unit_list: OptionButton
var name_edit: LineEdit
var hp_spin: SpinBox
var speed_spin: SpinBox
var armor_spin: SpinBox
var damage_spin: SpinBox
var reward_spin: SpinBox
var radius_spin: SpinBox
var attack_type_list: OptionButton
var attack_range_spin: SpinBox
var attack_cooldown_spin: SpinBox
var melee_check: CheckButton
var melee_cooldown_spin: SpinBox
var color_edit: ColorPickerButton
var sprite_edit: LineEdit
var default_image_edit: LineEdit
var animation_edits: Dictionary = {}
var image_thumbnail_controls: Dictionary = {}

var file_dialog: FileDialog
var file_dialog_target := "sprite"
var file_thumbnail_cache: Dictionary = {}
var robot_damage_spin: SpinBox
var robot_range_spin: SpinBox
var robot_cooldown_spin: SpinBox
var status_label: Label
var unit_preview_name: Label
var unit_preview_description: Label
var sprite_preview: TextureRect
var sprite_rect_x_spin: SpinBox
var sprite_rect_y_spin: SpinBox
var sprite_rect_w_spin: SpinBox
var sprite_rect_h_spin: SpinBox

func _ready() -> void:
	_build_ui()
	_load_data()
	if unit_list.item_count > 0:
		unit_list.select(0)
		_on_unit_selected(0)
	_apply_pending_asset_selection()

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
	root.add_theme_constant_override("separation", 6)
	add_child(root)
	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 32
	root.add_child(header)
	var title := Label.new()
	title.text = "MENOS // UNIT EDITOR"
	title.add_theme_font_size_override("font_size", 20)
	header.add_child(title)
	status_label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(status_label)
	var reload_btn := Button.new()
	reload_btn.text = "RELOAD"
	reload_btn.pressed.connect(_load_data)
	header.add_child(reload_btn)
	var save_btn := Button.new()
	save_btn.text = "SAVE JSON"
	save_btn.pressed.connect(_save_data)
	header.add_child(save_btn)
	var new_btn := Button.new()
	new_btn.text = "NEW UNIT"
	new_btn.pressed.connect(_create_new_unit)
	header.add_child(new_btn)
	var delete_btn := Button.new()
	delete_btn.text = "DELETE UNIT"
	delete_btn.pressed.connect(_confirm_delete_unit)
	header.add_child(delete_btn)
	var body := HSplitContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.split_offset = 260
	root.add_child(body)
	var sidebar := VBoxContainer.new()
	sidebar.custom_minimum_size.x = 250
	sidebar.add_theme_constant_override("separation", 5)
	body.add_child(sidebar)
	var unit_title := Label.new()
	unit_title.text = "UNITS"
	unit_title.add_theme_font_size_override("font_size", 14)
	sidebar.add_child(unit_title)
	unit_list = OptionButton.new()
	unit_list.custom_minimum_size.y = 30
	unit_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	unit_list.item_selected.connect(_on_unit_selected)
	sidebar.add_child(unit_list)
	var preview_title := Label.new()
	preview_title.text = "PREVIEW"
	preview_title.add_theme_font_size_override("font_size", 14)
	sidebar.add_child(preview_title)
	unit_preview_name = Label.new()
	unit_preview_name.add_theme_font_size_override("font_size", 20)
	sidebar.add_child(unit_preview_name)
	unit_preview_description = Label.new()
	unit_preview_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	unit_preview_description.custom_minimum_size.y = 48
	sidebar.add_child(unit_preview_description)
	sprite_preview = TextureRect.new()
	sprite_preview.custom_minimum_size = Vector2(230, 180)
	sprite_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sprite_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sidebar.add_child(sprite_preview)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	scroll.add_child(content)
	_build_properties(content)

func _build_properties(parent: VBoxContainer) -> void:
	var properties_title := Label.new()
	properties_title.text = "UNIT PROPERTIES"
	properties_title.add_theme_font_size_override("font_size", 16)
	parent.add_child(properties_title)
	var properties_grid := GridContainer.new()
	properties_grid.columns = 2
	properties_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	properties_grid.add_theme_constant_override("h_separation", 12)
	properties_grid.add_theme_constant_override("v_separation", 4)
	parent.add_child(properties_grid)
	name_edit = _line_grid_row(properties_grid, "Name")
	hp_spin = _spin_grid_row(properties_grid, "HP", 1, 999999, 1, 100)
	speed_spin = _spin_grid_row(properties_grid, "Speed", 0, 9999, 0.1, 10)
	armor_spin = _spin_grid_row(properties_grid, "Armor", 0, 9999, 0.1, 0)
	damage_spin = _spin_grid_row(properties_grid, "Base Damage", 0, 9999, 0.1, 1)
	reward_spin = _spin_grid_row(properties_grid, "Reward", 0, 999999, 1, 10)
	radius_spin = _spin_grid_row(properties_grid, "Radius", 1, 999, 0.5, 10)
	var attack_row := HBoxContainer.new()
	attack_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var attack_label := Label.new()
	attack_label.text = "Attack Type"
	attack_label.custom_minimum_size.x = 105
	attack_row.add_child(attack_label)
	attack_type_list = OptionButton.new()
	attack_type_list.add_item("None")
	attack_type_list.add_item("Melee")
	attack_type_list.add_item("Ranged")
	attack_type_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attack_row.add_child(attack_type_list)
	properties_grid.add_child(attack_row)
	attack_range_spin = _spin_grid_row(properties_grid, "Attack Range", 0, 9999, 0.5, 10)
	attack_cooldown_spin = _spin_grid_row(properties_grid, "Attack Cooldown", 0.05, 9999, 0.05, 1.0)
	var color_row := HBoxContainer.new()
	color_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var color_label := Label.new()
	color_label.text = "Color"
	color_label.custom_minimum_size.x = 105
	color_row.add_child(color_label)
	color_edit = ColorPickerButton.new()
	color_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	color_edit.color_changed.connect(_on_preview_color_changed)
	color_row.add_child(color_edit)
	properties_grid.add_child(color_row)
	melee_check = CheckButton.new()
	melee_check.text = "Melee Attack (legacy compatibility)"
	melee_check.visible = false
	parent.add_child(melee_check)
	melee_cooldown_spin = _spin_row(parent, "Melee Cooldown", 0.05, 9999, 0.05, 1.0)
	melee_cooldown_spin.visible = false
	var visuals_title := Label.new()
	visuals_title.text = "VISUAL SOURCE"
	visuals_title.add_theme_font_size_override("font_size", 16)
	parent.add_child(visuals_title)
	var visuals_grid := GridContainer.new()
	visuals_grid.columns = 2
	visuals_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visuals_grid.add_theme_constant_override("h_separation", 12)
	visuals_grid.add_theme_constant_override("v_separation", 4)
	parent.add_child(visuals_grid)
	sprite_edit = _image_grid_row(visuals_grid, "Sprite Animation", "sprite")
	default_image_edit = _image_grid_row(visuals_grid, "Profile Image", "default_image")
	var sprite_rect_row := HBoxContainer.new()
	sprite_rect_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sprite_rect_title := Label.new()
	sprite_rect_title.text = "Region X/Y/W/H"
	sprite_rect_title.custom_minimum_size.x = 105
	sprite_rect_row.add_child(sprite_rect_title)
	sprite_rect_x_spin = _spin_row_inline(sprite_rect_row, "X", 0, 100000, 1, 0)
	sprite_rect_y_spin = _spin_row_inline(sprite_rect_row, "Y", 0, 100000, 1, 0)
	sprite_rect_w_spin = _spin_row_inline(sprite_rect_row, "W", 0, 100000, 1, 0)
	sprite_rect_h_spin = _spin_row_inline(sprite_rect_row, "H", 0, 100000, 1, 0)
	visuals_grid.add_child(sprite_rect_row)
	for rect_spin in [sprite_rect_x_spin, sprite_rect_y_spin, sprite_rect_w_spin, sprite_rect_h_spin]:
		rect_spin.value_changed.connect(func(_value): _refresh_sprite_preview(default_image_edit.text.strip_edges()))
	var animation_title := Label.new()
	animation_title.text = "SPRITE ANIMATIONS"
	animation_title.add_theme_font_size_override("font_size", 16)
	parent.add_child(animation_title)
	var animation_grid := GridContainer.new()
	animation_grid.columns = 2
	animation_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	animation_grid.add_theme_constant_override("h_separation", 12)
	animation_grid.add_theme_constant_override("v_separation", 4)
	parent.add_child(animation_grid)
	projectile_edit = _image_grid_row(animation_grid, "Projectile Animation", "projectile")
	for animation_name in ["idle", "move", "attack", "hit", "death"]:
		animation_edits[animation_name] = _image_grid_row(animation_grid, animation_name.to_upper(), "animation:" + animation_name)
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.filters = ["*.png,*.jpg,*.jpeg,*.webp,*.bmp,*.svg ; Images"]
	file_dialog.display_mode = FileDialog.DISPLAY_THUMBNAILS
	file_dialog.add_theme_constant_override("thumbnail_size", int(ConfigRepository.get_editor_value("ui", "file_dialog_thumbnail_size", 112)))
	FileDialog.set_get_thumbnail_callback(Callable(self, "_get_file_thumbnail"))
	file_dialog.file_selected.connect(_on_file_selected)
	add_child(file_dialog)
	var combat_title := Label.new()
	combat_title.text = "ROBOT COMBAT"
	combat_title.add_theme_font_size_override("font_size", 16)
	parent.add_child(combat_title)
	var combat_grid := GridContainer.new()
	combat_grid.columns = 2
	combat_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	combat_grid.add_theme_constant_override("h_separation", 12)
	combat_grid.add_theme_constant_override("v_separation", 4)
	parent.add_child(combat_grid)
	robot_damage_spin = _spin_grid_row(combat_grid, "Robot Damage", 0, 9999, 0.1, 0)
	robot_range_spin = _spin_grid_row(combat_grid, "Robot Range", 0, 9999, 0.1, 0)
	robot_cooldown_spin = _spin_grid_row(combat_grid, "Robot Cooldown", 0, 9999, 0.05, 0)

func _line_grid_row(parent: GridContainer, label_text: String) -> LineEdit:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 105
	row.add_child(label)
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(edit)
	parent.add_child(row)
	return edit

func _spin_grid_row(parent: GridContainer, label_text: String, minimum: float, maximum: float, step: float, value: float) -> SpinBox:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 105
	row.add_child(label)
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step
	spin.value = value
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spin)
	parent.add_child(row)
	return spin

func _image_grid_row(parent: GridContainer, label_text: String, target: String) -> LineEdit:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 105
	row.add_child(label)
	var thumbnail := TextureRect.new()
	thumbnail.custom_minimum_size = Vector2(64, 64)
	thumbnail.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumbnail.mouse_filter = Control.MOUSE_FILTER_STOP
	thumbnail.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_open_image_editor_for_target(target)
	)
	thumbnail.tooltip_text = "클릭하여 이미지 에디터에서 열기"
	row.add_child(thumbnail)
	image_thumbnail_controls[target] = thumbnail
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(edit)
	edit.text_changed.connect(func(_text: String): _refresh_image_thumbnail(target))
	var browse := Button.new()
	browse.text = "Select Asset"
	browse.pressed.connect(func(): _open_sprite_dialog(target))
	row.add_child(browse)
	parent.add_child(row)
	return edit

func _image_row(parent: VBoxContainer, label_text: String, target: String) -> LineEdit:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 130
	row.add_child(label)
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(edit)
	var browse := Button.new()
	browse.text = "Select Asset"
	browse.pressed.connect(func(): _open_sprite_dialog(target))
	row.add_child(browse)
	return edit

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

func _spin_row_inline(parent: HBoxContainer, label_text: String, minimum: float, maximum: float, step: float, value: float) -> SpinBox:
	var label := Label.new()
	label.text = label_text
	parent.add_child(label)
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step
	spin.value = value
	spin.custom_minimum_size.x = 90
	parent.add_child(spin)
	return spin

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
	unit_data.clear()
	unit_sources.clear()
	_load_unit_catalog_file(UNIT_FILE, "unit")
	_load_unit_catalog_file(ENEMY_FILE, "enemy")
	_refresh_unit_list()
	_set_status("Loaded: Unit + Enemy catalogs")

func _load_unit_catalog_file(path: String, source: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return
	for key in parsed.keys():
		var id := str(key)
		var data: Dictionary = parsed[key].duplicate(true)
		if source == "enemy":
			var visuals: Dictionary = data.get("visuals", {}).duplicate(true)
			var sprite_path := str(data.get("sprite_anim", ""))
			if not sprite_path.is_empty():
				visuals["sprite"] = sprite_path
				visuals["default_image"] = str(visuals.get("default_image", sprite_path))
			data["visuals"] = visuals
		unit_data[id] = data
		unit_sources[id] = source

func _get_unit_types() -> Array:
	var types: Array = []
	for key in unit_data.keys():
		var unit_type := str(key)
		if not types.has(unit_type):
			types.append(unit_type)
	types.sort()
	return types

func _refresh_unit_list() -> void:
	unit_list.clear()
	for unit_type in _get_unit_types():
		var data: Dictionary = unit_data.get(unit_type, {})
		var source_label := "ENEMY / " if unit_sources.get(unit_type, "unit") == "enemy" else ""
		unit_list.add_item(source_label + str(data.get("name", unit_type.to_upper())))
		unit_list.set_item_metadata(unit_list.item_count - 1, unit_type)
		# Combo list is text-only. The selected unit thumbnail is shown separately below.
		unit_list.set_item_icon(unit_list.item_count - 1, null)

func _find_unit_index(unit_type: String) -> int:
	for index in unit_list.item_count:
		if str(unit_list.get_item_metadata(index)) == unit_type:
			return index
	return -1

func _confirm_delete_unit() -> void:
	if selected_type.is_empty() or not unit_data.has(selected_type):
		_set_status("No unit selected.")
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "Delete Unit"
	dialog.dialog_text = "Delete unit \"%s\" from its source JSON?" % str(unit_data[selected_type].get("name", selected_type))
	add_child(dialog)
	dialog.confirmed.connect(func(): _delete_unit(dialog))
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(480, 180))

func _delete_unit(dialog: ConfirmationDialog) -> void:
	var source := str(unit_sources.get(selected_type, "unit"))
	var target_file := ENEMY_FILE if source == "enemy" else UNIT_FILE
	var catalog: Dictionary = {}
	var file := FileAccess.open(target_file, FileAccess.READ)
	if file != null:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			catalog = parsed
	if not catalog.has(selected_type):
		_set_status("FAILED: selected unit was not found in source JSON.")
		dialog.queue_free()
		return
	catalog.erase(selected_type)
	var out := FileAccess.open(target_file, FileAccess.WRITE)
	if out == null:
		_set_status("FAILED to write JSON.")
		dialog.queue_free()
		return
	out.store_string(JSON.stringify(catalog, "  "))
	out.close()
	unit_data.erase(selected_type)
	unit_sources.erase(selected_type)
	selected_type = ""
	_refresh_unit_list()
	if unit_list.item_count > 0:
		unit_list.select(0)
		_on_unit_selected(0)
	_set_status("DELETED unit from: " + target_file)
	dialog.queue_free()

func _create_new_unit() -> void:
	var sequence := 1
	var new_id := "unit_%02d" % sequence
	while unit_data.has(new_id):
		sequence += 1
		new_id = "unit_%02d" % sequence
	unit_data[new_id] = {
		"name": "새 유닛",
		"description": "새로 등록한 사용자 유닛입니다.",
		"hp": 100.0,
		"speed": 80.0,
		"damage": 10.0,
		"cooldown": 1.0,
		"range": 120.0,
		"radius": 18.0,
		"ai": {},
		"visuals": {}
	}
	_refresh_unit_list()
	var new_index := _find_unit_index(new_id)
	if new_index >= 0:
		unit_list.select(new_index)
		_on_unit_selected(new_index)
	_set_status("New unit created: %s. Edit and SAVE JSON." % new_id)

func _refresh_image_thumbnail(target: String) -> void:
	if not image_thumbnail_controls.has(target):
		return
	var thumbnail := image_thumbnail_controls[target] as TextureRect
	var path := ""
	if target == "sprite":
		path = sprite_edit.text.strip_edges()
	elif target == "default_image":
		path = default_image_edit.text.strip_edges()
	elif target == "projectile":
		path = projectile_edit.text.strip_edges()
	elif target.begins_with("animation:"):
		var animation_name := target.trim_prefix("animation:")
		if animation_edits.has(animation_name):
			path = (animation_edits[animation_name] as LineEdit).text.strip_edges()
	thumbnail.texture = _texture_from_sprite_data(path, [])

func _refresh_all_image_thumbnails() -> void:
	_refresh_image_thumbnail("sprite")
	_refresh_image_thumbnail("default_image")
	_refresh_image_thumbnail("projectile")
	for animation_name in animation_edits.keys():
		_refresh_image_thumbnail("animation:" + str(animation_name))

func _on_unit_selected(index: int) -> void:
	if index < 0 or index >= unit_list.item_count:
		return
	selected_type = str(unit_list.get_item_metadata(index))
	var data: Dictionary = unit_data.get(selected_type, {})
	if selected_type.is_empty():
		return
	var unit_name := str(data.get("name", selected_type.to_upper()))
	unit_preview_name.text = unit_name
	unit_preview_description.text = str(data.get("description", UNIT_DESCRIPTIONS.get(selected_type, "사용자 등록 유닛입니다.")))
	name_edit.text = unit_name
	hp_spin.value = float(data.get("hp", 1.0))
	speed_spin.value = float(data.get("speed", 0.0))
	armor_spin.value = float(data.get("armor", 0.0))
	damage_spin.value = float(data.get("damage", 0.0))
	reward_spin.value = float(data.get("reward", 0.0))
	radius_spin.value = float(data.get("radius", 10.0))
	color_edit.color = Color(str(data.get("color", "#ffffff")))
	var visuals: Dictionary = data.get("visuals", {})
	sprite_edit.text = str(visuals.get("sprite", ""))
	default_image_edit.text = str(visuals.get("default_image", ""))
	projectile_edit.text = str(data.get("projectile_anim", ""))

	var animations: Dictionary = visuals.get("animations", {}) if visuals.get("animations", {}) is Dictionary else {}
	for animation_name in animation_edits.keys():
		(animation_edits[animation_name] as LineEdit).text = str(animations.get(animation_name, ""))
	var sprite_rect: Array = visuals.get("sprite_rect", [])
	_set_sprite_rect_controls(sprite_rect)
	var attack_type := str(data.get("attack_type", ""))
	if attack_type == "melee":
		attack_type_list.select(1)
	elif attack_type == "ranged":
		attack_type_list.select(2)
	else:
		attack_type_list.select(0)
	attack_range_spin.value = float(data.get("range", data.get("radius", 10.0)))
	attack_cooldown_spin.value = float(data.get("cooldown", 1.0))
	melee_check.button_pressed = bool(data.get("melee", false))
	melee_cooldown_spin.value = float(data.get("melee_cooldown", 1.0))
	melee_cooldown_spin.editable = melee_check.button_pressed
	_refresh_sprite_preview(default_image_edit.text)
	_refresh_all_image_thumbnails()
	robot_damage_spin.value = float(data.get("robot_damage", 0.0))
	robot_range_spin.value = float(data.get("robot_range", 0.0))
	robot_cooldown_spin.value = float(data.get("robot_cooldown", 0.0))
	robot_damage_spin.editable = false
	robot_range_spin.editable = false
	robot_cooldown_spin.editable = false

func _save_data() -> void:
	if selected_type.is_empty():
		_set_status("No unit selected.")
		return
	if name_edit.text.strip_edges().is_empty():
		_set_status("Name is required.")
		return
	var data: Dictionary = unit_data.get(selected_type, {}).duplicate(true)
	data["name"] = name_edit.text.strip_edges()
	data["hp"] = float(hp_spin.value)
	data["speed"] = float(speed_spin.value)
	data["armor"] = float(armor_spin.value)
	data["damage"] = float(damage_spin.value)
	data["reward"] = float(reward_spin.value)
	data["radius"] = float(radius_spin.value)
	data["cooldown"] = float(attack_cooldown_spin.value)
	data["range"] = float(attack_range_spin.value)
	var selected_attack_index := attack_type_list.selected
	if selected_attack_index == 1:
		data["attack_type"] = "melee"
	elif selected_attack_index == 2:
		data["attack_type"] = "ranged"
	else:
		data.erase("attack_type")
	data["color"] = color_edit.color.to_html(true)
	data["melee"] = melee_check.button_pressed
	data["melee_cooldown"] = float(melee_cooldown_spin.value)
	data["robot_damage"] = float(robot_damage_spin.value)
	data["robot_range"] = float(robot_range_spin.value)
	data["robot_cooldown"] = float(robot_cooldown_spin.value)
	data["projectile_anim"] = projectile_edit.text.strip_edges()
	var visuals: Dictionary = data.get("visuals", {}).duplicate(true)
	visuals["sprite"] = sprite_edit.text.strip_edges()
	visuals["default_image"] = default_image_edit.text.strip_edges()
	var animations: Dictionary = {}
	for animation_name in animation_edits.keys():
		var image_path := (animation_edits[animation_name] as LineEdit).text.strip_edges()
		if not image_path.is_empty():
			animations[animation_name] = image_path
	visuals["animations"] = animations
	var sprite_rect := _get_sprite_rect_from_controls()
	if sprite_rect.is_empty():
		visuals.erase("sprite_rect")
	else:
		visuals["sprite_rect"] = sprite_rect
	data["visuals"] = visuals
	unit_data[selected_type] = data
	var source := str(unit_sources.get(selected_type, "unit"))
	var target_file := ENEMY_FILE if source == "enemy" else UNIT_FILE
	var catalog: Dictionary = {}
	var target_read := FileAccess.open(target_file, FileAccess.READ)
	if target_read:
		var parsed_target = JSON.parse_string(target_read.get_as_text())
		target_read.close()
		if parsed_target is Dictionary:
			catalog = parsed_target
	if source == "enemy":
		var enemy_data: Dictionary = data.duplicate(true)
		var enemy_visuals: Dictionary = enemy_data.get("visuals", {}).duplicate(true)
		enemy_data["base_damage"] = float(data.get("damage", 0.0))
		enemy_data["attack_cooldown"] = float(data.get("cooldown", 1.0))
		enemy_data["attack_range"] = float(data.get("range", 0.0))
		enemy_data["sprite_anim"] = str(enemy_visuals.get("sprite", ""))
		enemy_data.erase("visuals")
		enemy_data.erase("damage")
		enemy_data.erase("cooldown")
		enemy_data.erase("range")
		catalog[selected_type] = enemy_data
	else:
		catalog[selected_type] = data
	var absolute_path := ProjectSettings.globalize_path(target_file)
	var parent_dir := absolute_path.get_base_dir()
	var dir_error := DirAccess.make_dir_recursive_absolute(parent_dir)
	if dir_error != OK:
		_set_status("FAILED: cannot create JSON directory (%s)." % error_string(dir_error))
		return
	var file := FileAccess.open(target_file, FileAccess.WRITE)
	if file == null:
		_set_status("FAILED to open JSON for writing: %s." % error_string(FileAccess.get_open_error()))
		return
	var json_text := JSON.stringify(catalog, "  ")
	file.store_string(json_text)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		_set_status("FAILED to write JSON: %s." % error_string(write_error))
		return
	var verify_file := FileAccess.open(target_file, FileAccess.READ)
	if verify_file == null:
		_set_status("FAILED to verify saved JSON: %s." % error_string(FileAccess.get_open_error()))
		return
	var verify_text := verify_file.get_as_text()
	verify_file.close()
	if verify_text.strip_edges() != json_text.strip_edges():
		_set_status("FAILED: saved JSON verification mismatch.")
		return
	unit_data[selected_type] = data
	var selected_index := _find_unit_index(selected_type)
	if selected_index >= 0:
		unit_list.select(selected_index)
		_on_unit_selected(selected_index)
	_set_status("SAVED + VERIFIED: " + target_file)
func _set_sprite_rect_controls(rect_values: Array) -> void:
	var values := rect_values if rect_values.size() >= 4 else [0, 0, 0, 0]
	sprite_rect_x_spin.value = float(values[0])
	sprite_rect_y_spin.value = float(values[1])
	sprite_rect_w_spin.value = float(values[2])
	sprite_rect_h_spin.value = float(values[3])

func _get_sprite_rect_from_controls() -> Array:
	var width := int(sprite_rect_w_spin.value)
	var height := int(sprite_rect_h_spin.value)
	if width <= 0 or height <= 0:
		return []
	return [int(sprite_rect_x_spin.value), int(sprite_rect_y_spin.value), width, height]

func _texture_from_sprite_data(path: String, rect_values: Array) -> Texture2D:
	if path.is_empty():
		return null
	var base_texture := load(path) as Texture2D
	if base_texture == null:
		return null
	if rect_values.size() < 4:
		return base_texture
	var rect := Rect2i(int(rect_values[0]), int(rect_values[1]), int(rect_values[2]), int(rect_values[3]))
	var image_size := Vector2i(base_texture.get_width(), base_texture.get_height())
	if rect.size.x <= 0 or rect.size.y <= 0 or rect.position.x < 0 or rect.position.y < 0 or rect.end.x > image_size.x or rect.end.y > image_size.y:
		return base_texture
	var atlas := AtlasTexture.new()
	atlas.atlas = base_texture
	atlas.region = Rect2(rect.position, rect.size)
	return atlas

func _refresh_sprite_preview(path: String) -> void:
	if not sprite_preview:
		return
	sprite_preview.texture = _texture_from_sprite_data(path, _get_sprite_rect_from_controls())
	_apply_preview_color()

func _on_preview_color_changed(_color: Color) -> void:
	_apply_preview_color()

func _apply_preview_color() -> void:
	if not sprite_preview:
		return
	var material := sprite_preview.material as ShaderMaterial
	if material == null:
		material = ShaderMaterial.new()
		material.shader = UNIT_COLOR_SHADER
		sprite_preview.material = material
	material.set_shader_parameter("team_color", color_edit.color)

signal request_image_editor

func _apply_pending_asset_selection() -> void:
	var target := IMAGE_STATE.selection_target
	if target.is_empty() or not IMAGE_STATE.selection_pending:
		return
	var asset_id := IMAGE_STATE.consume_selection(target)
	if asset_id.is_empty():
		return
	if target == "sprite":
		sprite_edit.text = asset_id
	elif target == "default_image":
		default_image_edit.text = asset_id
	elif target == "projectile":
		projectile_edit.text = asset_id
	elif target.begins_with("animation:"):
		var animation_name := target.trim_prefix("animation:")
		if animation_edits.has(animation_name):
			(animation_edits[animation_name] as LineEdit).text = asset_id
	_refresh_all_image_thumbnails()
	_set_status("Asset selected: " + asset_id)

func _open_image_editor_for_target(target: String) -> void:
	var path := ""
	if target == "sprite":
		path = sprite_edit.text.strip_edges()
	elif target == "default_image":
		path = default_image_edit.text.strip_edges()
	elif target == "projectile":
		path = projectile_edit.text.strip_edges()
	elif target.begins_with("animation:"):
		var animation_name := target.trim_prefix("animation:")
		if animation_edits.has(animation_name):
			path = (animation_edits[animation_name] as LineEdit).text.strip_edges()
	if path.is_empty():
		_set_status("No image assigned for %s." % target)
		return
	IMAGE_STATE.open_image(path, target)
	request_image_editor.emit()

func _get_file_thumbnail(path: String) -> Texture2D:
	var cached: Texture2D = file_thumbnail_cache.get(path) as Texture2D
	if cached != null:
		return cached
	var loaded := load(path) as Texture2D
	if loaded != null:
		file_thumbnail_cache[path] = loaded
	return loaded

func _open_sprite_dialog(target: String = "sprite") -> void:
	_open_image_editor_for_target(target)

func _on_file_selected(path: String) -> void:
	if file_dialog_target == "default_image":
		default_image_edit.text = path
	elif file_dialog_target == "projectile":
		projectile_edit.text = path
	elif file_dialog_target.begins_with("animation:"):
		var animation_name := file_dialog_target.trim_prefix("animation:")
		if animation_edits.has(animation_name):
			(animation_edits[animation_name] as LineEdit).text = path
	else:
		sprite_edit.text = path
	_refresh_image_thumbnail(file_dialog_target)
	if file_dialog_target == "default_image":
		_refresh_sprite_preview(path)

func _set_status(message: String) -> void:
	if status_label:
		status_label.text = "Status: " + message
