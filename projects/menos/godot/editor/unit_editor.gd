class_name UnitEditorMain
extends Control

const UNIT_FILE := "res://content/allied_units/allied_units.json"
const BASE_UNIT_TYPES := ["basic", "light", "ranged", "heavy", "support"]
const UNIT_DESCRIPTIONS := {
	"basic": "기본 전투형 유닛. 공격과 생존의 균형을 갖춘 표준형입니다.",
	"light": "경량 기동형 유닛. 빠른 이동과 전개에 특화됩니다.",
	"ranged": "원거리 공격형 유닛. 긴 사거리에서 지속적으로 화력을 투사합니다.",
	"heavy": "헤비 전투형 유닛. 높은 내구도와 강한 화력을 갖습니다.",
	"support": "지원형 유닛. 아군의 전투를 보조하고 회복합니다."
}
const IMAGE_STATE = preload("res://editor/image_editor_state.gd")

var unit_data: Dictionary = {}
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
var projectile_edit: LineEdit
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

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 12)
	add_child(root)
	var title := Label.new()
	title.text = "MENOS // UNIT EDITOR"
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)
	var top := HBoxContainer.new()
	root.add_child(top)
	unit_list = OptionButton.new()
	unit_list.custom_minimum_size.x = 220
	unit_list.item_selected.connect(_on_unit_selected)
	top.add_child(unit_list)
	var reload_btn := Button.new()
	reload_btn.text = "RELOAD"
	reload_btn.pressed.connect(_load_data)
	top.add_child(reload_btn)
	var save_btn := Button.new()
	save_btn.text = "SAVE JSON"
	save_btn.pressed.connect(_save_data)
	top.add_child(save_btn)
	var new_btn := Button.new()
	new_btn.text = "NEW UNIT"
	new_btn.pressed.connect(_create_new_unit)
	top.add_child(new_btn)
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
	title.text = "UNIT PREVIEW"
	title.add_theme_font_size_override("font_size", 16)
	parent.add_child(title)
	unit_preview_name = Label.new()
	unit_preview_name.add_theme_font_size_override("font_size", 22)
	parent.add_child(unit_preview_name)
	unit_preview_description = Label.new()
	unit_preview_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	unit_preview_description.custom_minimum_size.y = 42
	parent.add_child(unit_preview_description)
	sprite_preview = TextureRect.new()
	sprite_preview.custom_minimum_size = Vector2(220, 180)
	sprite_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(sprite_preview)
	var properties_title := Label.new()
	properties_title.text = "UNIT PROPERTIES"
	properties_title.add_theme_font_size_override("font_size", 16)
	parent.add_child(properties_title)
	name_edit = _line_row(parent, "Name")
	hp_spin = _spin_row(parent, "HP", 1, 999999, 1, 100)
	speed_spin = _spin_row(parent, "Speed", 0, 9999, 0.1, 10)
	armor_spin = _spin_row(parent, "Armor", 0, 9999, 0.1, 0)
	damage_spin = _spin_row(parent, "Base Damage", 0, 9999, 0.1, 1)
	reward_spin = _spin_row(parent, "Reward", 0, 999999, 1, 10)
	radius_spin = _spin_row(parent, "Radius", 1, 999, 0.5, 10)
	var attack_type_row := HBoxContainer.new()
	parent.add_child(attack_type_row)
	var attack_type_label := Label.new()
	attack_type_label.text = "Attack Type"
	attack_type_label.custom_minimum_size.x = 130
	attack_type_row.add_child(attack_type_label)
	attack_type_list = OptionButton.new()
	attack_type_list.add_item("None")
	attack_type_list.add_item("Melee")
	attack_type_list.add_item("Ranged")
	attack_type_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attack_type_row.add_child(attack_type_list)
	attack_range_spin = _spin_row(parent, "Attack Range", 0, 9999, 0.5, 10)
	attack_cooldown_spin = _spin_row(parent, "Attack Cooldown", 0.05, 9999, 0.05, 1.0)
	melee_check = CheckButton.new()
	melee_check.text = "Melee Attack (legacy compatibility)"
	melee_check.visible = false
	parent.add_child(melee_check)
	melee_cooldown_spin = _spin_row(parent, "Melee Cooldown", 0.05, 9999, 0.05, 1.0)
	melee_cooldown_spin.visible = false
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
	sprite_label.text = "Sprite Animation"
	sprite_label.custom_minimum_size.x = 130
	sprite_row.add_child(sprite_label)
	sprite_edit = LineEdit.new()
	sprite_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sprite_row.add_child(sprite_edit)
	var browse := Button.new()
	browse.text = "Browse"
	browse.pressed.connect(func(): _open_sprite_dialog("sprite"))
	sprite_row.add_child(browse)
	var sprite_rect_title := Label.new()
	sprite_rect_title.text = "Sprite Region (X, Y, W, H)"
	sprite_rect_title.custom_minimum_size.x = 130
	var sprite_rect_row := HBoxContainer.new()
	parent.add_child(sprite_rect_row)
	sprite_rect_row.add_child(sprite_rect_title)
	sprite_rect_x_spin = _spin_row_inline(sprite_rect_row, "X", 0, 100000, 1, 0)
	sprite_rect_y_spin = _spin_row_inline(sprite_rect_row, "Y", 0, 100000, 1, 0)
	sprite_rect_w_spin = _spin_row_inline(sprite_rect_row, "W", 0, 100000, 1, 0)
	sprite_rect_h_spin = _spin_row_inline(sprite_rect_row, "H", 0, 100000, 1, 0)
	for rect_spin in [sprite_rect_x_spin, sprite_rect_y_spin, sprite_rect_w_spin, sprite_rect_h_spin]:
		rect_spin.value_changed.connect(func(_value): _refresh_sprite_preview(sprite_edit.text.strip_edges()))
	var animation_title := Label.new()
	animation_title.text = "SPRITE ANIMATIONS"
	animation_title.add_theme_font_size_override("font_size", 16)
	parent.add_child(animation_title)
	for animation_name in ["idle", "attack", "hit", "death", "move"]:
		animation_edits[animation_name] = _image_row(parent, animation_name.to_upper() + " Animation", "animation:" + animation_name)
	default_image_edit = _image_row(parent, "Basic Image", "default_image")
	var projectile_row := HBoxContainer.new()
	parent.add_child(projectile_row)
	var projectile_label := Label.new()
	projectile_label.text = "Projectile Animation"
	projectile_label.custom_minimum_size.x = 130
	projectile_row.add_child(projectile_label)
	projectile_edit = LineEdit.new()
	projectile_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	projectile_row.add_child(projectile_edit)
	var projectile_browse := Button.new()
	projectile_browse.text = "Browse"
	projectile_browse.pressed.connect(func(): _open_sprite_dialog("projectile"))
	projectile_row.add_child(projectile_browse)
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.filters = ["*.png,*.jpg,*.jpeg,*.webp,*.bmp,*.svg ; Images"]
	file_dialog.display_mode = FileDialog.DISPLAY_THUMBNAILS
	file_dialog.add_theme_constant_override("thumbnail_size", 112)
	FileDialog.set_get_thumbnail_callback(Callable(self, "_get_file_thumbnail"))
	file_dialog.file_selected.connect(_on_file_selected)
	var edit_image := Button.new()
	edit_image.text = "Edit Image / Browse Image Reference"
	edit_image.pressed.connect(_open_image_editor)
	parent.add_child(edit_image)
	add_child(file_dialog)
	var sep := HSeparator.new()
	parent.add_child(sep)
	var combat_title := Label.new()
	combat_title.text = "Robot Combat"
	combat_title.add_theme_font_size_override("font_size", 16)
	parent.add_child(combat_title)
	robot_damage_spin = _spin_row(parent, "Robot Damage", 0, 9999, 0.1, 0)
	robot_range_spin = _spin_row(parent, "Robot Range", 0, 9999, 0.1, 0)
	robot_cooldown_spin = _spin_row(parent, "Robot Cooldown", 0, 9999, 0.05, 0)

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
	browse.text = "Browse"
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
	var file := FileAccess.open(UNIT_FILE, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			unit_data = parsed
	_refresh_unit_list()
	_set_status("Loaded: " + UNIT_FILE if file else "Failed to load JSON")

func _get_unit_types() -> Array:
	var types: Array = BASE_UNIT_TYPES.duplicate()
	for key in unit_data.keys():
		var unit_type := str(key)
		if not types.has(unit_type):
			types.append(unit_type)
	return types

func _refresh_unit_list() -> void:
	unit_list.clear()
	for unit_type in _get_unit_types():
		var data: Dictionary = unit_data.get(unit_type, {})
		unit_list.add_item(str(data.get("name", unit_type.to_upper())))
		unit_list.set_item_metadata(unit_list.item_count - 1, unit_type)
		# Combo list is text-only. The selected unit thumbnail is shown separately below.
		unit_list.set_item_icon(unit_list.item_count - 1, null)

func _find_unit_index(unit_type: String) -> int:
	for index in unit_list.item_count:
		if str(unit_list.get_item_metadata(index)) == unit_type:
			return index
	return -1

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
	damage_spin.value = float(data.get("damage", 0.0))
	reward_spin.value = 0.0
	radius_spin.value = float(data.get("radius", 10.0))
	color_edit.color = Color(str(data.get("color", "#ffffff")))
	var visuals: Dictionary = data.get("visuals", {})
	sprite_edit.text = str(visuals.get("sprite", ""))
	default_image_edit.text = str(visuals.get("default_image", visuals.get("sprite", "")))
	var animations: Dictionary = visuals.get("animations", {}) if visuals.get("animations", {}) is Dictionary else {}
	for animation_name in animation_edits.keys():
		(animation_edits[animation_name] as LineEdit).text = str(animations.get(animation_name, visuals.get("sprite", "")))
	var sprite_rect: Array = visuals.get("sprite_rect", [])
	_set_sprite_rect_controls(sprite_rect)
	projectile_edit.text = str(data.get("projectile_anim", "res://assets/menos/sprites/bullet_threat.png"))
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
	_refresh_sprite_preview(sprite_edit.text)
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
	data["damage"] = float(damage_spin.value)
	data["cooldown"] = float(attack_cooldown_spin.value)
	data["range"] = float(attack_range_spin.value)
	var visuals: Dictionary = data.get("visuals", {}).duplicate(true)
	visuals["sprite"] = sprite_edit.text.strip_edges()
	visuals["default_image"] = default_image_edit.text.strip_edges()
	var animations: Dictionary = visuals.get("animations", {}).duplicate(true)
	for animation_name in animation_edits.keys():
		animations[animation_name] = (animation_edits[animation_name] as LineEdit).text.strip_edges()
	visuals["animations"] = animations
	var sprite_rect := _get_sprite_rect_from_controls()
	if sprite_rect.is_empty():
		visuals.erase("sprite_rect")
	else:
		visuals["sprite_rect"] = sprite_rect
	data["visuals"] = visuals
	unit_data[selected_type] = data
	var dir := DirAccess.open("res://content")
	if dir == null:
		_set_status("FAILED: content directory unavailable.")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://content/allied_units"))
	var file := FileAccess.open(UNIT_FILE, FileAccess.WRITE)
	if file == null:
		_set_status("FAILED to open JSON for writing.")
		return
	file.store_string(JSON.stringify(unit_data, "  "))
	file.close()
	_refresh_unit_list()
	var selected_index := _find_unit_index(selected_type)
	if selected_index >= 0:
		unit_list.select(selected_index)
		_on_unit_selected(selected_index)
	_set_status("SAVED: " + UNIT_FILE)

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
	if sprite_preview:
		sprite_preview.texture = _texture_from_sprite_data(path, _get_sprite_rect_from_controls())

func _open_image_editor() -> void:
	IMAGE_STATE.open_image(sprite_edit.text.strip_edges())
	get_tree().change_scene_to_file("res://editor/image_editor.tscn")

func _get_file_thumbnail(path: String) -> Texture2D:
	var cached: Texture2D = file_thumbnail_cache.get(path) as Texture2D
	if cached != null:
		return cached
	var loaded := load(path) as Texture2D
	if loaded != null:
		file_thumbnail_cache[path] = loaded
	return loaded

func _open_sprite_dialog(target: String = "sprite") -> void:
	file_dialog_target = target
	file_thumbnail_cache.clear()
	if file_dialog:
		file_dialog.popup_centered_ratio(0.75)

func _on_file_selected(path: String) -> void:
	if file_dialog_target == "projectile":
		projectile_edit.text = path
	elif file_dialog_target == "default_image":
		default_image_edit.text = path
	elif file_dialog_target.begins_with("animation:"):
		var animation_name := file_dialog_target.trim_prefix("animation:")
		if animation_edits.has(animation_name):
			(animation_edits[animation_name] as LineEdit).text = path
	else:
		sprite_edit.text = path
		_refresh_sprite_preview(path)

func _set_status(message: String) -> void:
	if status_label:
		status_label.text = "Status: " + message
