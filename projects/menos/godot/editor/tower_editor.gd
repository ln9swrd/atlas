class_name TowerEditorMain
extends Control

const TOWER_FILE := "res://content/towers/towers.json"
const TOWER_TYPES := ["cannon", "gatling"]
const IMAGE_STATE = preload("res://editor/image_editor_state.gd")

var tower_data: Dictionary = {}
var selected_type := ""
var tower_list: OptionButton
var name_edit: LineEdit
var cost_spin: SpinBox
var damage_spin: SpinBox
var cooldown_spin: SpinBox
var range_spin: SpinBox
var preference_edit: LineEdit
var sprite_edit: LineEdit
var projectile_edit: LineEdit
var file_dialog_target := "sprite"
var level2_cost_spin: SpinBox
var level2_damage_spin: SpinBox
var level2_cooldown_spin: SpinBox
var level2_range_spin: SpinBox
var file_dialog: FileDialog
var file_thumbnail_cache: Dictionary = {}
var status_label: Label
var sprite_preview: TextureRect
var projectile_preview: TextureRect
var animation_timer: Timer
var animation_frame := 0
const TOWER_ANIMATION_FRAMES := 4
const PROJECTILE_ANIMATION_FRAMES := 8

func _ready() -> void:
	_build_ui()
	animation_timer = Timer.new()
	animation_timer.wait_time = 0.12
	animation_timer.autostart = true
	animation_timer.timeout.connect(_on_animation_tick)
	add_child(animation_timer)
	_load_data()
	if tower_list.item_count > 0:
		tower_list.select(0)
		_on_tower_selected(0)

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 12)
	add_child(root)
	var title := Label.new()
	title.text = "MENOS // TOWER EDITOR"
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)
	var top := HBoxContainer.new()
	root.add_child(top)
	tower_list = OptionButton.new()
	tower_list.custom_minimum_size.x = 220
	tower_list.item_selected.connect(_on_tower_selected)
	top.add_child(tower_list)
	var reload_btn := Button.new()
	reload_btn.text = "RELOAD"
	reload_btn.pressed.connect(_load_data)
	top.add_child(reload_btn)
	var save_btn := Button.new()
	save_btn.text = "SAVE JSON"
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
	title.text = "TOWER PROPERTIES"
	title.add_theme_font_size_override("font_size", 16)
	parent.add_child(title)
	name_edit = _line_row(parent, "Name")
	cost_spin = _spin_row(parent, "Build Cost", 0, 999999, 1, 50)
	damage_spin = _spin_row(parent, "Damage", 0, 99999, 0.1, 10)
	cooldown_spin = _spin_row(parent, "Cooldown", 0.01, 9999, 0.01, 1)
	range_spin = _spin_row(parent, "Range", 0, 99999, 1, 150)
	preference_edit = _line_row(parent, "Target Preference")
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
	browse.text = "筌≪뼚釉섋퉪?용┛"
	browse.pressed.connect(func(): _open_sprite_dialog("sprite"))
	sprite_row.add_child(browse)
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
	projectile_browse.text = "筌≪뼚釉섋퉪?용┛"
	projectile_browse.pressed.connect(func(): _open_sprite_dialog("projectile"))
	projectile_row.add_child(projectile_browse)
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.filters = ["*.png,*.jpg,*.jpeg,*.webp,*.bmp,*.svg ; ???筌왖"]
	file_dialog.display_mode = FileDialog.DISPLAY_THUMBNAILS
	file_dialog.add_theme_constant_override("thumbnail_size", 112)
	FileDialog.set_get_thumbnail_callback(Callable(self, "_get_file_thumbnail"))
	file_dialog.file_selected.connect(_on_file_selected)
	var animation_preview_title := Label.new()
	animation_preview_title.text = "ANIMATION PREVIEW"
	animation_preview_title.add_theme_font_size_override("font_size", 14)
	parent.add_child(animation_preview_title)
	var animation_preview_row := HBoxContainer.new()
	parent.add_child(animation_preview_row)
	sprite_preview = _create_animation_preview(animation_preview_row, "Tower", Vector2(128, 128))
	projectile_preview = _create_animation_preview(animation_preview_row, "Projectile", Vector2(96, 96))
	var edit_image := Button.new()
	edit_image.text = "Edit Image / Browse Image Reference"
	edit_image.pressed.connect(_open_image_editor)
	parent.add_child(edit_image)
	add_child(file_dialog)
	var sep := HSeparator.new()
	parent.add_child(sep)
	var upgrade_title := Label.new()
	upgrade_title.text = "LV2 UPGRADE"
	upgrade_title.add_theme_font_size_override("font_size", 16)
	parent.add_child(upgrade_title)
	level2_cost_spin = _spin_row(parent, "Upgrade Cost", 0, 999999, 1, 50)
	level2_damage_spin = _spin_row(parent, "LV2 Damage", 0, 99999, 0.1, 10)
	level2_cooldown_spin = _spin_row(parent, "Level 2 Cooldown", 0.01, 9999, 0.01, 1)
	level2_range_spin = _spin_row(parent, "LV2 Range", 0, 99999, 1, 150)

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
	tower_data.clear()
	var file := FileAccess.open(TOWER_FILE, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			tower_data = parsed
	_refresh_tower_list()
	_set_status("Loaded: " + TOWER_FILE if file else "Failed to load JSON")

func _refresh_tower_list() -> void:
	tower_list.clear()
	for tower_type in TOWER_TYPES:
		if tower_data.has(tower_type):
			tower_list.add_item(str(tower_data[tower_type].get("name", tower_type.to_upper())))
			tower_list.set_item_icon(tower_list.item_count - 1, load(str(tower_data[tower_type].get("sprite_anim", ""))) as Texture2D)
		else:
			tower_list.add_item(tower_type.to_upper())
		tower_list.set_item_metadata(tower_list.item_count - 1, tower_type)

func _on_tower_selected(index: int) -> void:
	if index < 0 or index >= tower_list.item_count:
		return
	selected_type = str(tower_list.get_item_metadata(index))
	var data: Dictionary = tower_data.get(selected_type, {})
	var level2: Dictionary = data.get("level2", {})
	name_edit.text = str(data.get("name", selected_type.to_upper()))
	cost_spin.value = float(data.get("cost", 0.0))
	damage_spin.value = float(data.get("damage", 0.0))
	cooldown_spin.value = float(data.get("cooldown", 1.0))
	range_spin.value = float(data.get("range", 0.0))
	preference_edit.text = str(data.get("preference", ""))
	sprite_edit.text = str(data.get("sprite_anim", "res://assets/menos/sprites/tower_%s_anim.png" % selected_type))
	projectile_edit.text = str(data.get("projectile_anim", "res://assets/menos/sprites/bullet_defender.png"))
	_refresh_animation_previews()
	level2_cost_spin.value = float(level2.get("upgrade_cost", 0.0))
	level2_damage_spin.value = float(level2.get("damage", data.get("damage", 0.0)))
	level2_cooldown_spin.value = float(level2.get("cooldown", data.get("cooldown", 1.0)))
	level2_range_spin.value = float(level2.get("range", data.get("range", 0.0)))

func _save_data() -> void:
	if selected_type.is_empty():
		_set_status("No tower selected.")
		return
	if name_edit.text.strip_edges().is_empty():
		_set_status("??已?is required.")
		return
	var data: Dictionary = tower_data.get(selected_type, {}).duplicate(true)
	data["name"] = name_edit.text.strip_edges()
	data["cost"] = int(cost_spin.value)
	data["damage"] = float(damage_spin.value)
	data["cooldown"] = float(cooldown_spin.value)
	data["range"] = float(range_spin.value)
	data["preference"] = preference_edit.text.strip_edges()
	data["sprite_anim"] = sprite_edit.text.strip_edges()
	data["projectile_anim"] = projectile_edit.text.strip_edges()
	data["level2"] = {
		"upgrade_cost": int(level2_cost_spin.value),
		"damage": float(level2_damage_spin.value),
		"cooldown": float(level2_cooldown_spin.value),
		"range": float(level2_range_spin.value)
	}
	tower_data[selected_type] = data
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://content/towers"))
	var file := FileAccess.open(TOWER_FILE, FileAccess.WRITE)
	if file == null:
		_set_status("FAILED to open JSON for writing.")
		return
	file.store_string(JSON.stringify(tower_data, "  "))
	file.close()
	_refresh_tower_list()
	tower_list.select(TOWER_TYPES.find(selected_type))
	_set_status("SAVED: " + TOWER_FILE)

func _create_animation_preview(parent: Container, label_text: String, size: Vector2) -> TextureRect:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(size.x + 12.0, size.y + 24.0)
	parent.add_child(box)
	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)
	var preview := TextureRect.new()
	preview.custom_minimum_size = size
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	box.add_child(preview)
	return preview

func _animated_texture(path: String, frame: int, total_frames: int) -> Texture2D:
	var texture := load(path) as Texture2D
	if texture == null or total_frames <= 1:
		return texture
	var frame_width := texture.get_width() / float(total_frames)
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(frame_width * (frame % total_frames), 0.0, frame_width, texture.get_height())
	return atlas

func _refresh_animation_previews() -> void:
	if sprite_preview:
		sprite_preview.texture = _animated_texture(sprite_edit.text.strip_edges(), animation_frame, TOWER_ANIMATION_FRAMES)
	if projectile_preview:
		projectile_preview.texture = _animated_texture(projectile_edit.text.strip_edges(), animation_frame, PROJECTILE_ANIMATION_FRAMES)

func _on_animation_tick() -> void:
	animation_frame = (animation_frame + 1) % 8
	_refresh_animation_previews()

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
	else:
		sprite_edit.text = path
	_refresh_animation_previews()

func _set_status(message: String) -> void:
	if status_label:
		status_label.text = "Status: " + message
