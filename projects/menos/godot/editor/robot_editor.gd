class_name RobotEditorMain
extends Control

const ROBOT_FILE := "res://content/robots/robots.json"
const EDITOR_THUMBNAIL_UTIL = preload("res://scripts/editor_thumbnail_util.gd")
const VISUAL_ASSET_FRAME = preload("res://scripts/visual_asset_frame.gd")
const VISUAL_ASSET_PREVIEW = preload("res://editor/visual_asset_preview.gd")
const IMAGE_STATE = preload("res://editor/image_editor_state.gd")
const ROBOT_COLOR_SHADER = preload("res://shaders/robot_profile_color.gdshader")

var robot_data: Dictionary = {}
var selected_type := ""
var robot_list: OptionButton
var name_edit: LineEdit
var id_edit: LineEdit
var hp_spin: SpinBox
var speed_spin: SpinBox
var damage_spin: SpinBox
var cooldown_spin: SpinBox
var range_spin: SpinBox
var color_edit: ColorPickerButton
var color_swatch_texture: ImageTexture
var idle_edit: LineEdit
var attack_edit: LineEdit
var move_edit: LineEdit
var skill_edit: LineEdit
var hit_edit: LineEdit
var death_edit: LineEdit
var skill1_edit: LineEdit
var skill2_edit: LineEdit
var skill3_edit: LineEdit
var special_edit: LineEdit
var finisher_edit: LineEdit
var default_image_edit: LineEdit
var animation_edits: Dictionary = {}
var image_thumbnail_controls: Dictionary = {}
var image_asset_id_labels: Dictionary = {}
var projectile_edit: LineEdit
const BASE_ANIMATIONS := ["idle", "move", "attack", "hit", "death", "projectile"]
const SKILL_ANIMATIONS := ["skill1", "skill2", "skill3", "special", "finisher"]
var file_dialog: FileDialog
var file_dialog_target := "sprite"
var status_label: Label
var robot_preview_name: Label
var robot_preview_description: Label
var robot_preview: TextureRect
var animation_previews: Dictionary = {}
var animation_rects: Dictionary = {}
var animation_timer: Timer
var animation_frame := 0

func _animation_frame_count(animation_name: String) -> int:
	var asset_id := ""
	if animation_name == "profile":
		asset_id = "robot.%s.profile" % selected_type
	else:
		asset_id = "robot.%s.%s" % [selected_type, animation_name]
	var resolved := VisualAssetResolver.resolve(asset_id)
	if resolved != null and not resolved.id.begins_with("legacy:") and resolved.frames > 0:
		return resolved.frames
	return int(ConfigRepository.get_editor_value("animation_preview", "legacy_frame_counts", {}).get(animation_name, 1))

func _ready() -> void:
	_build_ui()
	animation_timer = Timer.new()
	animation_timer.wait_time = 0.12
	animation_timer.autostart = true
	animation_timer.timeout.connect(_on_animation_tick)
	add_child(animation_timer)
	_load_data()
	var pending_robot := IMAGE_STATE.selection_owner_key if IMAGE_STATE.selection_pending and IMAGE_STATE.selection_owner_kind == "robot" else ""
	var initial_index := 0
	if not pending_robot.is_empty():
		for i in range(robot_list.item_count):
			if str(robot_list.get_item_metadata(i)) == pending_robot:
				initial_index = i
				break
	if robot_list.item_count > 0:
		robot_list.select(initial_index)
		_on_robot_selected(initial_index)
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
	title.text = "MENOS // ROBOT EDITOR"
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
	var delete_btn := Button.new()
	delete_btn.text = "DELETE ROBOT"
	delete_btn.pressed.connect(_confirm_delete_robot)
	header.add_child(delete_btn)

	var body := HSplitContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.split_offset = 260
	root.add_child(body)

	var sidebar := VBoxContainer.new()
	sidebar.custom_minimum_size.x = 250
	sidebar.add_theme_constant_override("separation", 5)
	body.add_child(sidebar)
	var robot_header := HBoxContainer.new()
	robot_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar.add_child(robot_header)
	var robot_title := Label.new()
	robot_title.text = "ROBOTS"
	robot_title.add_theme_font_size_override("font_size", 14)
	robot_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	robot_header.add_child(robot_title)
	var add_btn := Button.new()
	add_btn.text = "ADD ROBOT"
	add_btn.pressed.connect(_open_add_robot_dialog)
	robot_header.add_child(add_btn)
	robot_list = OptionButton.new()
	robot_list.custom_minimum_size.y = 30
	robot_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	robot_list.item_selected.connect(_on_robot_selected)
	sidebar.add_child(robot_list)
	var preview_title := Label.new()
	preview_title.text = "PREVIEW"
	preview_title.add_theme_font_size_override("font_size", 14)
	sidebar.add_child(preview_title)
	robot_preview_name = Label.new()
	robot_preview_name.add_theme_font_size_override("font_size", 20)
	sidebar.add_child(robot_preview_name)
	robot_preview_description = Label.new()
	robot_preview_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	robot_preview_description.custom_minimum_size.y = 48
	sidebar.add_child(robot_preview_description)
	robot_preview = TextureRect.new()
	robot_preview.custom_minimum_size = Vector2(230, 240)
	robot_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	robot_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	robot_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	robot_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sidebar.add_child(robot_preview)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	scroll.add_child(content)

	var base_title := Label.new()
	base_title.text = "ROBOT PROPERTIES"
	base_title.add_theme_font_size_override("font_size", 16)
	content.add_child(base_title)
	var properties_grid := GridContainer.new()
	properties_grid.columns = 2
	properties_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	properties_grid.add_theme_constant_override("h_separation", 12)
	properties_grid.add_theme_constant_override("v_separation", 4)
	content.add_child(properties_grid)
	id_edit = _line_grid_row(properties_grid, "ID")
	name_edit = _line_grid_row(properties_grid, "Name")
	hp_spin = _spin_grid_row(properties_grid, "HP", 1, 999999, 1, 220)
	speed_spin = _spin_grid_row(properties_grid, "Speed", 0, 9999, 0.1, 125)
	damage_spin = _spin_grid_row(properties_grid, "Damage", 0, 99999, 0.1, 28)
	cooldown_spin = _spin_grid_row(properties_grid, "Cooldown", 0.01, 9999, 0.01, 0.65)
	range_spin = _spin_grid_row(properties_grid, "Range", 0, 99999, 1, 180)
	var color_row := HBoxContainer.new()
	color_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var color_label := Label.new()
	color_label.text = "Color"
	color_label.custom_minimum_size.x = 105
	color_row.add_child(color_label)
	color_edit = ColorPickerButton.new()
	color_edit.edit_alpha = false
	color_edit.custom_minimum_size = Vector2(120, 30)
	color_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_update_color_button_swatch()
	color_edit.color_changed.connect(_on_preview_color_changed)
	color_row.add_child(color_edit)
	properties_grid.add_child(color_row)

	var visual_title := Label.new()
	visual_title.text = "VISUAL SOURCE"
	visual_title.add_theme_font_size_override("font_size", 16)
	content.add_child(visual_title)
	var visual_grid := GridContainer.new()
	visual_grid.columns = 2
	visual_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_grid.add_theme_constant_override("h_separation", 12)
	visual_grid.add_theme_constant_override("v_separation", 4)
	content.add_child(visual_grid)
	default_image_edit = _image_grid_row(visual_grid, "PROFILE IMAGE", "default_image")
	var mask_row := HBoxContainer.new()
	mask_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var mask_label := Label.new()
	mask_label.text = "TEAM COLOR MASK"
	mask_label.custom_minimum_size.x = 105
	mask_row.add_child(mask_label)
	var generate_mask_btn := Button.new()
	generate_mask_btn.text = "GENERATE MASK"
	generate_mask_btn.tooltip_text = "프로파일 이미지의 전신 불투명 영역을 원본 알파 경계 그대로 팀 색상 마스크로 생성합니다."
	generate_mask_btn.pressed.connect(_generate_profile_team_mask)
	mask_row.add_child(generate_mask_btn)
	visual_grid.add_child(mask_row)

	var animation_title := Label.new()
	animation_title.text = "SPRITE ANIMATIONS"
	animation_title.add_theme_font_size_override("font_size", 16)
	content.add_child(animation_title)
	var base_animation_title := Label.new()
	base_animation_title.text = "BASE"
	base_animation_title.add_theme_font_size_override("font_size", 13)
	content.add_child(base_animation_title)
	var animation_grid := GridContainer.new()
	animation_grid.columns = 2
	animation_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	animation_grid.add_theme_constant_override("h_separation", 12)
	animation_grid.add_theme_constant_override("v_separation", 4)
	content.add_child(animation_grid)
	for animation_name in BASE_ANIMATIONS:
		var edit := _image_grid_row(animation_grid, animation_name.to_upper(), "animation:" + animation_name)
		animation_edits[animation_name] = edit
		if animation_name == "idle": idle_edit = edit
		elif animation_name == "move": move_edit = edit
		elif animation_name == "attack": attack_edit = edit
		elif animation_name == "projectile": projectile_edit = edit

	var skill_animation_title := Label.new()
	skill_animation_title.text = "SKILLS"
	skill_animation_title.add_theme_font_size_override("font_size", 13)
	content.add_child(skill_animation_title)
	var skill_animation_grid := GridContainer.new()
	skill_animation_grid.columns = 2
	skill_animation_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_animation_grid.add_theme_constant_override("h_separation", 12)
	skill_animation_grid.add_theme_constant_override("v_separation", 4)
	content.add_child(skill_animation_grid)
	for animation_name in SKILL_ANIMATIONS:
		var skill_edit_control := _image_grid_row(skill_animation_grid, _animation_display_name(animation_name), "animation:" + animation_name)
		animation_edits[animation_name] = skill_edit_control

	var animation_preview_title := Label.new()
	animation_preview_title.text = "ANIMATION PREVIEW"
	animation_preview_title.add_theme_font_size_override("font_size", 14)
	content.add_child(animation_preview_title)
	var base_preview_row := HBoxContainer.new()
	base_preview_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(base_preview_row)
	for animation_name in BASE_ANIMATIONS:
		animation_previews[animation_name] = _create_animation_preview(base_preview_row, animation_name.capitalize(), Vector2(90, 120))
	var skill_preview_row := HBoxContainer.new()
	skill_preview_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(skill_preview_row)
	for animation_name in SKILL_ANIMATIONS:
		animation_previews[animation_name] = _create_animation_preview(skill_preview_row, _animation_display_name(animation_name), Vector2(90, 120))
func _animation_display_name(animation_name: String) -> String:
	match animation_name:
		"skill1":
			return "스킬1"
		"skill2":
			return "스킬2"
		"skill3":
			return "스킬3"
		"special":
			return "스킬(스페셜)"
		"finisher":
			return "스킬(피니셔)"
		_:
			return animation_name.to_upper()

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
	var asset_id_label := Label.new()
	asset_id_label.text = "ID: -"
	asset_id_label.custom_minimum_size.x = 150
	asset_id_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	asset_id_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(asset_id_label)
	image_asset_id_labels[target] = asset_id_label
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
	label.custom_minimum_size.x = 150
	row.add_child(label)
	var thumbnail := TextureRect.new()
	thumbnail.custom_minimum_size = Vector2(64, 64)
	thumbnail.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumbnail.mouse_filter = Control.MOUSE_FILTER_STOP
	var asset_id_label := Label.new()
	asset_id_label.text = "ID: -"
	asset_id_label.custom_minimum_size.x = 150
	asset_id_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	asset_id_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(asset_id_label)
	image_asset_id_labels[target] = asset_id_label
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
	return edit

func _line_row(parent: VBoxContainer, label_text: String) -> LineEdit:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 150
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
	label.custom_minimum_size.x = 150
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
	robot_data.clear()
	robot_data = ObjectRepository.load_catalog(ROBOT_FILE)
	_refresh_robot_list()
	_set_status("Loaded: " + ROBOT_FILE if not robot_data.is_empty() else "Failed to load JSON")

func _refresh_robot_list() -> void:
	robot_list.clear()
	for robot_type in ObjectRepository.list_robots():
		var data: Dictionary = robot_data.get(robot_type, {})
		if not (data is Dictionary):
			continue
		robot_list.add_item(str(data.get("name", robot_type.to_upper())))
		robot_list.set_item_metadata(robot_list.item_count - 1, robot_type)

func _on_robot_selected(index: int) -> void:
	if index < 0 or index >= robot_list.item_count:
		return
	selected_type = str(robot_list.get_item_metadata(index))
	id_edit.editable = true
	var data: Dictionary = robot_data.get(selected_type, {})
	var robot_name := str(data.get("name", selected_type.to_upper()))
	id_edit.text = str(data.get("id", selected_type))
	name_edit.text = robot_name
	robot_preview_name.text = robot_name
	robot_preview_description.text = str(data.get("description", "MENOS 전투 로봇. 이동, 공격, 스킬 애니메이션을 사용하는 전투 유닛입니다."))
	hp_spin.value = float(data.get("hp", 220.0))
	speed_spin.value = float(data.get("speed", 125.0))
	damage_spin.value = float(data.get("damage", 28.0))
	cooldown_spin.value = float(data.get("cooldown", 0.65))
	range_spin.value = float(data.get("range", 180.0))
	var stored_color := Color(str(data.get("color", "ffffffff")))
	stored_color.a = 1.0
	color_edit.color = stored_color
	_update_color_button_swatch()
	var animations: Dictionary = data.get("animations", {}) if data.get("animations", {}) is Dictionary else {}
	animation_rects = data.get("animation_rects", {}) if data.get("animation_rects", {}) is Dictionary else {}
	var legacy_defaults := {
		"idle": str(data.get("sprite_idle", "")),
		"move": str(data.get("sprite_move", "")),
		"attack": str(data.get("sprite_attack", "")),
		"projectile": str(data.get("projectile_anim", "")),
	}
	for animation_name in animation_edits.keys():
		var animation_path := str(animations.get(animation_name, legacy_defaults.get(animation_name, "")))
		(animation_edits[animation_name] as LineEdit).text = animation_path
	default_image_edit.text = str(data.get("default_image", ""))
	_refresh_all_image_thumbnails()
	_refresh_animation_previews()
	_refresh_robot_preview()

func _create_animation_preview(parent: Container, label_text: String, size: Vector2) -> VisualAssetPreview:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(size.x + 8.0, size.y + 24.0)
	parent.add_child(box)
	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)
	var preview: VisualAssetPreview = VISUAL_ASSET_PREVIEW.new()
	preview.custom_minimum_size = size
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	box.add_child(preview)
	return preview

func _animated_texture(path: String, frame: int, total_frames: int, rect_values: Variant = []) -> Texture2D:
	var source_path := path
	var asset_frames := 0
	var columns := maxi(1, total_frames)
	var rows := 1
	var resolved := VisualAssetResolver.resolve(path)
	if resolved != null:
		source_path = resolved.source
		asset_frames = resolved.frames
		columns = maxi(1, resolved.columns)
		rows = maxi(1, resolved.rows)
		if resolved.region.size.x > 0 and resolved.region.size.y > 0:
			rect_values = [resolved.region.position.x, resolved.region.position.y, resolved.region.size.x, resolved.region.size.y]
	var texture := load(source_path) as Texture2D
	if texture == null:
		return null
	var source_rect := Rect2(0.0, 0.0, texture.get_width(), texture.get_height())
	if rect_values is Array and rect_values.size() >= 4:
		source_rect = Rect2(float(rect_values[0]), float(rect_values[1]), float(rect_values[2]), float(rect_values[3]))
	if asset_frames > 0:
		total_frames = asset_frames
	if total_frames <= 1:
		var single := AtlasTexture.new()
		single.atlas = texture
		single.region = source_rect
		return single
	if rows <= 1:
		columns = maxi(columns, total_frames)
	else:
		columns = maxi(1, columns)
		rows = maxi(1, rows)
	if total_frames > columns * rows:
		return null
	if source_rect.size.x <= 0.0 or source_rect.size.y <= 0.0:
		return texture
	var frame_index := frame % total_frames
	var frame_rect := VISUAL_ASSET_FRAME.region_for(resolved, frame_index, source_rect)
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = frame_rect
	return atlas

func _refresh_animation_previews() -> void:
	for key in animation_previews.keys():
		var preview: VisualAssetPreview = animation_previews[key]
		var edit: LineEdit = animation_edits.get(key)
		var path := edit.text.strip_edges() if edit != null else ""
		var frames := _animation_frame_count(key)
		var rect_values: Variant = animation_rects.get(key, [])
		preview.texture = _animated_texture(path, animation_frame, frames, rect_values)
		var resolved := VisualAssetResolver.resolve(path)
		preview.anchor = VISUAL_ASSET_FRAME.anchor_normalized(resolved)

func _on_animation_tick() -> void:
	var max_frames := 1
	for animation_name in animation_previews.keys():
		max_frames = maxi(max_frames, _animation_frame_count(animation_name))
	animation_frame = (animation_frame + 1) % max_frames
	_refresh_animation_previews()

func _open_add_robot_dialog() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Add Robot"
	dialog.ok_button_text = "ADD"
	var form := VBoxContainer.new()
	form.custom_minimum_size = Vector2(360, 0)
	form.add_theme_constant_override("separation", 8)
	dialog.add_child(form)
	var id_row := HBoxContainer.new()
	form.add_child(id_row)
	var id_label := Label.new()
	id_label.text = "ID"
	id_label.custom_minimum_size.x = 80
	id_row.add_child(id_label)
	var new_id_edit := LineEdit.new()
	new_id_edit.placeholder_text = "robot_id"
	new_id_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	id_row.add_child(new_id_edit)
	var name_row := HBoxContainer.new()
	form.add_child(name_row)
	var name_label := Label.new()
	name_label.text = "Name"
	name_label.custom_minimum_size.x = 80
	name_row.add_child(name_label)
	var new_name_edit := LineEdit.new()
	new_name_edit.placeholder_text = "ROBOT NAME"
	new_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(new_name_edit)
	add_child(dialog)
	dialog.confirmed.connect(func():
		_add_robot(dialog, new_id_edit.text, new_name_edit.text)
	)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(440, 220))
	new_id_edit.grab_focus()

func _add_robot(dialog: ConfirmationDialog, requested_id: String, requested_name: String) -> void:
	var new_id := requested_id.strip_edges().to_lower().validate_filename()
	var new_name := requested_name.strip_edges()
	if new_id.is_empty() or new_name.is_empty():
		_set_status("Robot ID and name are required.")
		dialog.queue_free()
		return
	if robot_data.has(new_id):
		_set_status("Robot ID already exists: " + new_id)
		dialog.queue_free()
		return
	var new_robot: Dictionary = {
		"color": "ffffffff",
		"cooldown": 0.65,
		"damage": 28.0,
		"energy": {"max": 100.0, "regen": 12.0},
		"hp": 220.0,
		"id": new_id,
		"name": new_name,
		"progression": {
			"damage_growth": 0.05,
			"hp_growth": 0.05,
			"range_growth": 0.02,
			"speed_growth": 0.02,
			"xp_per_level": 100.0
		},
		"range": 180.0,
		"speed": 125.0,
		"default_image": "",
		"animations": {},
		"animation_rects": {}
	}
	robot_data[new_id] = new_robot
	if not _write_robot_data():
		robot_data.erase(new_id)
		_set_status("FAILED to save new robot.")
		dialog.queue_free()
		return
	_refresh_robot_list()
	for i in range(robot_list.item_count):
		if str(robot_list.get_item_metadata(i)) == new_id:
			robot_list.select(i)
			_on_robot_selected(i)
			break
	_set_status("ADDED robot: " + new_id)
	dialog.queue_free()

func _write_robot_data() -> bool:
	return ObjectPersistence.save_catalog(ROBOT_FILE, robot_data)

func _confirm_delete_robot() -> void:
	if selected_type.is_empty() or not robot_data.has(selected_type):
		_set_status("No robot selected.")
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "Delete Robot"
	dialog.dialog_text = "Delete robot \"%s\" from robots.json?" % str(robot_data[selected_type].get("name", selected_type))
	add_child(dialog)
	dialog.confirmed.connect(func():
		_delete_robot(dialog)
	)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(480, 180))

func _delete_robot(dialog: ConfirmationDialog) -> void:
	robot_data.erase(selected_type)
	if not ObjectPersistence.save_catalog(ROBOT_FILE, robot_data):
		_set_status("FAILED to write JSON.")
		dialog.queue_free()
		return
	ObjectRepository.reload()
	selected_type = ""
	_refresh_robot_list()
	if robot_list.item_count > 0:
		robot_list.select(0)
		_on_robot_selected(0)
	_set_status("DELETED robot from: " + ROBOT_FILE)
	dialog.queue_free()

func _save_data() -> void:
	if selected_type.is_empty():
		_set_status("No robot selected.")
		return
	if name_edit.text.strip_edges().is_empty() or id_edit.text.strip_edges().is_empty():
		_set_status("ID and name are required.")
		return
	var data: Dictionary = robot_data.get(selected_type, {}).duplicate(true)
	data["id"] = id_edit.text.strip_edges()
	data["name"] = name_edit.text.strip_edges()
	data["hp"] = float(hp_spin.value)
	data["speed"] = float(speed_spin.value)
	data["damage"] = float(damage_spin.value)
	data["cooldown"] = float(cooldown_spin.value)
	data["range"] = float(range_spin.value)
	var team_color := color_edit.color
	team_color.a = 1.0
	data["color"] = team_color.to_html(true)
	data["default_image"] = default_image_edit.text.strip_edges()
	var animations: Dictionary = data.get("animations", {}).duplicate(true)
	for animation_name in animation_edits.keys():
		animations[animation_name] = (animation_edits[animation_name] as LineEdit).text.strip_edges()
	data["animations"] = animations
	data["animation_rects"] = animation_rects.duplicate(true)
	data["default_image_rect"] = data.get("default_image_rect", [])
	# Legacy runtime fields remain synchronized during the migration.
	data["sprite_idle"] = animations.get("idle", "")
	data["sprite_move"] = animations.get("move", "")
	data["sprite_attack"] = animations.get("attack", "")
	data["sprite_skill"] = animations.get("skill1", "")
	data["projectile_anim"] = animations.get("projectile", "")
	robot_data[selected_type] = data
	if not ObjectPersistence.save_catalog(ROBOT_FILE, robot_data):
		_set_status("FAILED to save JSON.")
		return
	ObjectRepository.reload()
	_refresh_robot_list()
	for i in range(robot_list.item_count):
		if str(robot_list.get_item_metadata(i)) == selected_type:
			robot_list.select(i)
			break
	_set_status("SAVED: " + ROBOT_FILE)


func _refresh_image_thumbnail(target: String) -> void:
	if not image_thumbnail_controls.has(target):
		return
	VisualAssetResolver.reload()
	var thumbnail := image_thumbnail_controls[target] as TextureRect
	var path := ""
	var fallback_region := Rect2()
	var fallback_frames := 1
	if target == "default_image":
		path = default_image_edit.text.strip_edges()
		fallback_region = _rect_from_values(robot_data.get(selected_type, {}).get("default_image_rect", []))
	elif target == "projectile":
		path = projectile_edit.text.strip_edges()
		fallback_region = _rect_from_values(animation_rects.get("projectile", []))
		fallback_frames = _animation_frame_count("projectile")
	elif target.begins_with("animation:"):
		var animation_name := target.trim_prefix("animation:")
		if animation_edits.has(animation_name):
			path = (animation_edits[animation_name] as LineEdit).text.strip_edges()
		fallback_region = _rect_from_values(animation_rects.get(animation_name, []))
		fallback_frames = _animation_frame_count(animation_name)
	var texture := EDITOR_THUMBNAIL_UTIL.create(path, fallback_region, fallback_frames) if not path.is_empty() else null
	thumbnail.texture = texture
	thumbnail.scale = Vector2.ONE
	if image_asset_id_labels.has(target):
		var asset_id := ""
		if not selected_type.is_empty():
			if target == "default_image":
				asset_id = "robot.%s.profile" % selected_type
			elif target == "projectile":
				asset_id = "robot.%s.projectile" % selected_type
			elif target.begins_with("animation:"):
				asset_id = "robot.%s.%s" % [selected_type, target.trim_prefix("animation:")]
		(image_asset_id_labels[target] as Label).text = "ID: " + (asset_id if not asset_id.is_empty() else "-")
	if target == "default_image" or target == "animation:idle":
		_refresh_robot_preview()

func _rect_from_values(values: Variant) -> Rect2:
	if values is Array and values.size() >= 4:
		return Rect2(
			float(values[0]),
			float(values[1]),
			float(values[2]),
			float(values[3])
		)
	return Rect2()

func _update_color_button_swatch() -> void:
	if color_edit == null:
		return
	var swatch_image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	swatch_image.fill(color_edit.color)
	color_swatch_texture = ImageTexture.create_from_image(swatch_image)
	color_edit.add_theme_icon_override("bg", color_swatch_texture)

func _on_preview_color_changed(_color: Color) -> void:
	var team_color := color_edit.color
	team_color.a = 1.0
	color_edit.color = team_color
	_update_color_button_swatch()
	_set_status("COLOR EVENT: %s | BUTTON: %s" % [team_color.to_html(true), color_edit.color.to_html(true)])
	if not selected_type.is_empty() and robot_data.has(selected_type):
		robot_data[selected_type]["color"] = team_color.to_html(true)
		_write_robot_data()
	_apply_preview_color()

func _apply_preview_color() -> void:
	if not robot_preview:
		return
	var material := robot_preview.material as ShaderMaterial
	if material == null:
		material = ShaderMaterial.new()
		robot_preview.material = material
	material.shader = ROBOT_COLOR_SHADER
	material.set_shader_parameter("team_color", color_edit.color)
	var mask_texture: Texture2D = null
	# Team-mask ownership comes from the registered Profile Visual Asset.
	# Do not hard-code a robot or mask path here; the Catalog is the source of truth.
	var profile_asset_id := "robot.%s.profile" % selected_type if not selected_type.is_empty() else ""
	var profile_asset = VisualAssetResolver.get_asset(profile_asset_id) if not profile_asset_id.is_empty() else null
	if profile_asset != null:
		var mask_source: String = str(profile_asset.team_mask_source)
		var mask_path := ProjectSettings.globalize_path(mask_source) if mask_source.begins_with("res://") else mask_source
		var mask_image: Image = Image.load_from_file(mask_path) if not mask_path.is_empty() else null
		# Generated masks are already cropped to the exact Profile Visual Asset
		# region. Do not crop them again with default_image_rect.
		if mask_image != null and mask_image.get_width() > 0 and mask_image.get_height() > 0:
			mask_texture = ImageTexture.create_from_image(mask_image)
	var mask_valid := mask_texture != null and robot_preview.texture != null
	material.set_shader_parameter("use_team_mask", mask_valid)
	if mask_valid:
		material.set_shader_parameter("team_mask", mask_texture)

func _refresh_robot_preview() -> void:
	if not robot_preview:
		return
	var path := default_image_edit.text.strip_edges()
	if path.is_empty():
		path = idle_edit.text.strip_edges()
	if path.is_empty():
		robot_preview.texture = null
		return
	var data: Dictionary = robot_data.get(selected_type, {})
	var rect_values: Variant = data.get("default_image_rect", [])
	robot_preview.texture = _animated_texture(path, 0, 1, rect_values)
	_apply_preview_color()

func _refresh_all_image_thumbnails() -> void:
	_refresh_robot_preview()
	_refresh_image_thumbnail("default_image")
	_refresh_image_thumbnail("projectile")
	for animation_name in animation_edits.keys():
		_refresh_image_thumbnail("animation:" + str(animation_name))

func _open_image_editor_for_target(target: String) -> void:
	var path := ""
	if target == "default_image":
		path = default_image_edit.text.strip_edges()
	elif target == "projectile":
		path = projectile_edit.text.strip_edges()
	elif target.begins_with("animation:"):
		var animation_name := target.trim_prefix("animation:")
		if animation_edits.has(animation_name):
			path = (animation_edits[animation_name] as LineEdit).text.strip_edges()
	var source_path := path
	var asset_id := ""
	if not path.is_empty():
		var resolved := VisualAssetResolver.resolve(path)
		if resolved != null and not resolved.source.is_empty():
			source_path = resolved.source
			asset_id = resolved.id

	# Select Asset always opens the Catalog Editor, even when the slot is empty.
	# When an existing Visual Asset is assigned, pass its ID so the Catalog Editor
	# can select that exact catalog entry.
	var owner_usage := ""
	var owner_frames := 1
	if target.begins_with("animation:"):
		owner_usage = target.trim_prefix("animation:")
		owner_frames = _animation_frame_count(owner_usage)
	elif target == "default_image":
		# PROFILE IMAGE has a stable Visual Asset identity independent of the
		# Robot Editor's legacy storage field name (default_image).
		owner_usage = "profile"
	# The Robot Editor owns the semantic Visual Asset ID for each slot.
	# Never infer the slot ID from the source image: one image may be shared by
	# several slots and may already resolve to an unrelated Visual Asset ID.
	# The slot identity is always robot.<robot>.<usage>.
	if not selected_type.is_empty() and not owner_usage.is_empty():
		asset_id = "robot.%s.%s" % [selected_type, owner_usage]
	else:
		asset_id = ""
	IMAGE_STATE.open_image(source_path, target, asset_id, "robot", selected_type, owner_usage, owner_frames, "res://editor/robot_editor.tscn")
	request_image_editor.emit()

func _apply_pending_asset_selection() -> void:
	var target := IMAGE_STATE.selection_target
	if target.is_empty() or not IMAGE_STATE.selection_pending:
		return
	var asset_id := IMAGE_STATE.consume_selection(target)
	if asset_id.is_empty():
		return
	VisualAssetResolver.reload()
	var resolved := VisualAssetResolver.get_asset(asset_id)
	var rect_values: Array = []
	if resolved != null and resolved.region.size.x > 0.0 and resolved.region.size.y > 0.0:
		rect_values = [
			resolved.region.position.x,
			resolved.region.position.y,
			resolved.region.size.x,
			resolved.region.size.y
		]
	if target == "default_image":
		default_image_edit.text = asset_id
		if not rect_values.is_empty():
			robot_data[selected_type]["default_image_rect"] = rect_values.duplicate()
	elif target == "projectile":
		projectile_edit.text = asset_id
		if not rect_values.is_empty():
			animation_rects["projectile"] = rect_values.duplicate()
	elif target.begins_with("animation:"):
		var animation_name := target.trim_prefix("animation:")
		if animation_edits.has(animation_name):
			(animation_edits[animation_name] as LineEdit).text = asset_id
		if not rect_values.is_empty():
			animation_rects[animation_name] = rect_values.duplicate()
	elif target == "sprite":
		idle_edit.text = asset_id
		if not rect_values.is_empty():
			animation_rects["idle"] = rect_values.duplicate()
	# Applying a Catalog selection is the assignment operation itself.
	# Persist it immediately so the originating Robot slot no longer needs a
	# second click/use action after returning from the Catalog Editor.
	if target == "default_image":
		robot_data[selected_type]["default_image"] = asset_id
	elif target == "projectile":
		robot_data[selected_type]["projectile_anim"] = asset_id
	elif target.begins_with("animation:"):
		var animation_name := target.trim_prefix("animation:")
		var animations: Dictionary = robot_data[selected_type].get("animations", {}).duplicate(true)
		animations[animation_name] = asset_id
		robot_data[selected_type]["animations"] = animations
		# Keep legacy runtime fields synchronized with the canonical animation map.
		if animation_name == "idle":
			robot_data[selected_type]["sprite_idle"] = asset_id
		elif animation_name == "move":
			robot_data[selected_type]["sprite_move"] = asset_id
		elif animation_name == "attack":
			robot_data[selected_type]["sprite_attack"] = asset_id
		elif animation_name == "skill1":
			robot_data[selected_type]["sprite_skill"] = asset_id
		elif animation_name == "projectile":
			robot_data[selected_type]["projectile_anim"] = asset_id
	if not _write_robot_data():
		_set_status("Asset selected in editor, but failed to persist: %s" % asset_id)
		return
	_refresh_all_image_thumbnails()
	_refresh_animation_previews()
	_refresh_robot_preview()
	_set_status("Asset assigned: %s | region: %s" % [asset_id, str(rect_values)])

signal request_image_editor
func _open_sprite_dialog(target: String = "sprite") -> void:
	_open_image_editor_for_target(target)

func _on_file_selected(path: String) -> void:
	if selected_type.is_empty():
		_set_status("Select a robot before importing an image.")
		return
	var source_path := ProjectSettings.globalize_path(path) if path.begins_with("res://") else path
	if not FileAccess.file_exists(source_path):
		_set_status("Image file does not exist: " + source_path)
		return
	var extension := source_path.get_extension().to_lower()
	if extension not in ["png", "jpg", "jpeg", "webp", "bmp", "svg"]:
		_set_status("Unsupported image format: " + extension)
		return
	var safe_id := selected_type.to_lower().validate_filename()
	if safe_id.is_empty():
		safe_id = "robot"
	var target_name := file_dialog_target.replace(":", "_").to_lower().validate_filename()
	var relative_dir := "res://assets/menos/robots/" + safe_id
	var absolute_dir := ProjectSettings.globalize_path(relative_dir)
	var dir_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if dir_error != OK:
		_set_status("Failed to create image directory: " + error_string(dir_error))
		return
	var base_name := target_name + "." + extension
	var destination := absolute_dir.path_join(base_name)
	var suffix := 1
	while FileAccess.file_exists(destination):
		base_name = target_name + "_" + str(suffix) + "." + extension
		destination = absolute_dir.path_join(base_name)
		suffix += 1
	var copy_error := DirAccess.copy_absolute(source_path, destination)
	if copy_error != OK:
		_set_status("Image import failed: " + error_string(copy_error))
		return
	var resource_path := relative_dir.path_join(base_name)
	if file_dialog_target == "projectile":
		projectile_edit.text = resource_path
	elif file_dialog_target == "default_image":
		default_image_edit.text = resource_path
	elif file_dialog_target.begins_with("animation:"):
		var animation_name := file_dialog_target.trim_prefix("animation:")
		if animation_edits.has(animation_name):
			(animation_edits[animation_name] as LineEdit).text = resource_path
	_refresh_animation_previews()
	_set_status("Imported image: " + resource_path)

func _generate_profile_team_mask() -> void:
	if selected_type.is_empty():
		_set_status("Select a robot before generating a mask.")
		return
	var profile_asset_id := "robot.%s.profile" % selected_type
	VisualAssetResolver.reload()
	var profile_asset := VisualAssetResolver.get_asset(profile_asset_id)
	if profile_asset == null or profile_asset.source.is_empty():
		_set_status("Profile Visual Asset not found: " + profile_asset_id)
		return
	var absolute_source := ProjectSettings.globalize_path(profile_asset.source)
	var source_image := Image.load_from_file(absolute_source)
	if source_image == null:
		_set_status("Failed to load profile image: " + profile_asset.source)
		return
	var region := Rect2i(
		int(profile_asset.region.position.x),
		int(profile_asset.region.position.y),
		int(profile_asset.region.size.x),
		int(profile_asset.region.size.y)
	)
	if region.size.x <= 0 or region.size.y <= 0 or region.position.x < 0 or region.position.y < 0 or region.end.x > source_image.get_width() or region.end.y > source_image.get_height():
		_set_status("Invalid profile region for mask generation.")
		return
	var profile := source_image.get_region(region)
	var mask := Image.create(profile.get_width(), profile.get_height(), false, Image.FORMAT_L8)
	# The team-color region is the entire visible robot. Use the source alpha
	# directly so every visible body part is covered while antialiased edges
	# retain their original coverage. Transparent background stays unmasked.
	for y in range(profile.get_height()):
		for x in range(profile.get_width()):
			var alpha := profile.get_pixel(x, y).a
			mask.set_pixel(x, y, Color(alpha, alpha, alpha, 1.0))
	var relative_dir := "res://images/robot/%s" % selected_type
	var absolute_dir := ProjectSettings.globalize_path(relative_dir)
	var dir_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if dir_error != OK:
		_set_status("Failed to create mask directory: " + error_string(dir_error))
		return
	var mask_resource := relative_dir + "/profile_team_mask.png"
	var save_error := mask.save_png(ProjectSettings.globalize_path(mask_resource))
	if save_error != OK:
		_set_status("Failed to save team mask: " + error_string(save_error))
		return
	if not _set_profile_team_mask_source(profile_asset_id, mask_resource):
		_set_status("Mask created, but Catalog update failed.")
		return
	VisualAssetResolver.reload()
	_apply_preview_color()
	_set_status("Generated team mask: %s" % mask_resource)

func _set_profile_team_mask_source(asset_id: String, mask_source: String) -> bool:
	const catalog_path := "res://content/editor/visual_assets.json"
	var file := FileAccess.open(catalog_path, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary) or not (parsed.get(asset_id, null) is Dictionary):
		return false
	var entry: Dictionary = parsed[asset_id]
	entry["team_mask"] = {"source": mask_source}
	parsed[asset_id] = entry
	file = FileAccess.open(catalog_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(parsed, "\t"))
	file.close()
	return true

func _set_status(message: String) -> void:
	if status_label:
		status_label.text = "Status: " + message
