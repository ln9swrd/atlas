class_name RobotEditorMain
extends Control

const ROBOT_FILE := "res://content/robots/robots.json"
const IMAGE_STATE = preload("res://editor/image_editor_state.gd")
const ROBOT_COLOR_SHADER = preload("res://shaders/allied_unit_color.gdshader")

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
var projectile_edit: LineEdit
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
const ROBOT_ANIMATION_FRAMES := {"idle": 6, "attack": 8, "move": 8, "skill": 8, "projectile": 6}

func _ready() -> void:
	_build_ui()
	animation_timer = Timer.new()
	animation_timer.wait_time = 0.12
	animation_timer.autostart = true
	animation_timer.timeout.connect(_on_animation_tick)
	add_child(animation_timer)
	_load_data()
	if robot_list.item_count > 0:
		robot_list.select(0)
		_on_robot_selected(0)
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

	var body := HSplitContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.split_offset = 260
	root.add_child(body)

	var sidebar := VBoxContainer.new()
	sidebar.custom_minimum_size.x = 250
	sidebar.add_theme_constant_override("separation", 5)
	body.add_child(sidebar)
	var robot_title := Label.new()
	robot_title.text = "ROBOTS"
	robot_title.add_theme_font_size_override("font_size", 14)
	sidebar.add_child(robot_title)
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
	color_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	idle_edit = _image_grid_row(visual_grid, "IDLE", "animation:idle")
	attack_edit = _image_grid_row(visual_grid, "ATTACK", "animation:attack")
	move_edit = _image_grid_row(visual_grid, "MOVE", "animation:move")
	skill_edit = _image_grid_row(visual_grid, "SKILL", "animation:skill")
	default_image_edit = _image_grid_row(visual_grid, "PROFILE IMAGE", "default_image")
	projectile_edit = _image_grid_row(visual_grid, "PROJECTILE", "projectile")

	var animation_title := Label.new()
	animation_title.text = "SPRITE ANIMATIONS"
	animation_title.add_theme_font_size_override("font_size", 16)
	content.add_child(animation_title)
	var animation_grid := GridContainer.new()
	animation_grid.columns = 2
	animation_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	animation_grid.add_theme_constant_override("h_separation", 12)
	animation_grid.add_theme_constant_override("v_separation", 4)
	content.add_child(animation_grid)
	for animation_name in ["hit", "death", "skill1", "skill2", "skill3", "special", "finisher"]:
		animation_edits[animation_name] = _image_grid_row(animation_grid, animation_name.to_upper(), "animation:" + animation_name)

	var animation_preview_title := Label.new()
	animation_preview_title.text = "ANIMATION PREVIEW"
	animation_preview_title.add_theme_font_size_override("font_size", 14)
	content.add_child(animation_preview_title)
	var animation_preview_row := HBoxContainer.new()
	animation_preview_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(animation_preview_row)
	animation_previews["idle"] = _create_animation_preview(animation_preview_row, "Idle", Vector2(110, 150))
	animation_previews["attack"] = _create_animation_preview(animation_preview_row, "Attack", Vector2(110, 150))
	animation_previews["move"] = _create_animation_preview(animation_preview_row, "Move", Vector2(110, 150))
	animation_previews["skill"] = _create_animation_preview(animation_preview_row, "Skill", Vector2(110, 150))
	animation_previews["projectile"] = _create_animation_preview(animation_preview_row, "Projectile", Vector2(90, 110))
	var ability_note := Label.new()
	ability_note.text = "SPECIAL ABILITIES: managed by content/skills/skills.json"
	ability_note.add_theme_font_size_override("font_size", 13)
	content.add_child(ability_note)

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
	label.custom_minimum_size.x = 150
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
	var file := FileAccess.open(ROBOT_FILE, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			robot_data = parsed
		_refresh_robot_list()
	_set_status("Loaded: " + ROBOT_FILE if file else "Failed to load JSON")

func _refresh_robot_list() -> void:
	robot_list.clear()
	for robot_type in robot_data.keys():
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
	color_edit.color = Color(str(data.get("color", "ffffffff")))
	idle_edit.text = str(data.get("sprite_idle", "res://assets/menos/sprites/atlas_idle.png"))
	attack_edit.text = str(data.get("sprite_attack", "res://assets/menos/sprites/atlas_attack.png"))
	move_edit.text = str(data.get("sprite_move", "res://assets/menos/sprites/atlas_move.png"))
	skill_edit.text = str(data.get("sprite_skill", "res://assets/menos/sprites/atlas_skill.png"))
	projectile_edit.text = str(data.get("projectile_anim", "res://assets/menos/sprites/bullet_defender.png"))
	default_image_edit.text = str(data.get("default_image", data.get("sprite_idle", "")))
	var animations: Dictionary = data.get("animations", {}) if data.get("animations", {}) is Dictionary else {}
	animation_rects = data.get("animation_rects", {}) if data.get("animation_rects", {}) is Dictionary else {}
	for animation_name in animation_edits.keys():
		(animation_edits[animation_name] as LineEdit).text = str(animations.get(animation_name, data.get("sprite_skill", "")))
	_refresh_all_image_thumbnails()
	_refresh_animation_previews()
	_refresh_robot_preview()

func _create_animation_preview(parent: Container, label_text: String, size: Vector2) -> TextureRect:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(size.x + 8.0, size.y + 24.0)
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

func _animated_texture(path: String, frame: int, total_frames: int, rect_values: Variant = []) -> Texture2D:
	var source_path := path
	var asset_frames := 0
	var resolved := VisualAssetResolver.resolve(path)
	if resolved != null:
		source_path = resolved.source
		asset_frames = resolved.frames
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
	if source_rect.size.x <= 0.0 or source_rect.size.y <= 0.0:
		return texture
	if total_frames <= 1:
		var single := AtlasTexture.new()
		single.atlas = texture
		single.region = source_rect
		return single
	var frame_width := source_rect.size.x / float(total_frames)
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(source_rect.position.x + frame_width * (frame % total_frames), source_rect.position.y, frame_width, source_rect.size.y)
	return atlas

func _refresh_animation_previews() -> void:
	var paths := {
		"idle": idle_edit.text.strip_edges(),
		"attack": attack_edit.text.strip_edges(),
		"move": move_edit.text.strip_edges(),
		"skill": skill_edit.text.strip_edges(),
		"projectile": projectile_edit.text.strip_edges()
	}
	for key in animation_previews.keys():
		var preview: TextureRect = animation_previews[key]
		var path := str(paths.get(key, ""))
		var frames := int(ROBOT_ANIMATION_FRAMES.get(key, 1))
		var rect_values: Variant = []
		if key == "idle": rect_values = robot_data.get(selected_type, {}).get("sprite_idle_rect", [])
		elif key == "attack": rect_values = robot_data.get(selected_type, {}).get("sprite_attack_rect", [])
		elif key == "move": rect_values = robot_data.get(selected_type, {}).get("sprite_move_rect", [])
		elif key == "skill": rect_values = robot_data.get(selected_type, {}).get("sprite_skill_rect", [])
		elif key == "projectile": rect_values = animation_rects.get("projectile", [])
		preview.texture = _animated_texture(path, animation_frame, frames, rect_values)

func _on_animation_tick() -> void:
	animation_frame = (animation_frame + 1) % 8
	_refresh_animation_previews()

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
	data["color"] = color_edit.color.to_html(true)
	data["sprite_idle"] = idle_edit.text.strip_edges()
	data["sprite_attack"] = attack_edit.text.strip_edges()
	data["sprite_move"] = move_edit.text.strip_edges()
	data["sprite_skill"] = skill_edit.text.strip_edges()
	data["default_image"] = default_image_edit.text.strip_edges()
	var animations: Dictionary = data.get("animations", {}).duplicate(true)
	for animation_name in animation_edits.keys():
		animations[animation_name] = (animation_edits[animation_name] as LineEdit).text.strip_edges()
	data["animations"] = animations
	data["animation_rects"] = animation_rects.duplicate(true)
	data["projectile_anim"] = projectile_edit.text.strip_edges()
	robot_data[selected_type] = data
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://content/robots"))
	var file := FileAccess.open(ROBOT_FILE, FileAccess.WRITE)
	if file == null:
		_set_status("FAILED to open JSON for writing.")
		return
	file.store_string(JSON.stringify(robot_data, "  "))
	file.close()
	_refresh_robot_list()
	for i in range(robot_list.item_count):
		if str(robot_list.get_item_metadata(i)) == selected_type:
			robot_list.select(i)
			break
	_set_status("SAVED: " + ROBOT_FILE)

func _refresh_image_thumbnail(target: String) -> void:
	if not image_thumbnail_controls.has(target):
		return
	var thumbnail := image_thumbnail_controls[target] as TextureRect
	var path := ""
	if target == "default_image":
		path = default_image_edit.text.strip_edges()
	elif target == "projectile":
		path = projectile_edit.text.strip_edges()
	elif target.begins_with("animation:"):
		var animation_name := target.trim_prefix("animation:")
		if animation_name == "idle": path = idle_edit.text.strip_edges()
		elif animation_name == "attack": path = attack_edit.text.strip_edges()
		elif animation_name == "move": path = move_edit.text.strip_edges()
		elif animation_name == "skill": path = skill_edit.text.strip_edges()
		elif animation_edits.has(animation_name): path = (animation_edits[animation_name] as LineEdit).text.strip_edges()
	thumbnail.texture = _animated_texture(path, 0, 1) if not path.is_empty() else null
	if target == "default_image" or target == "animation:idle":
		_refresh_robot_preview()

func _on_preview_color_changed(_color: Color) -> void:
	_apply_preview_color()

func _apply_preview_color() -> void:
	if not robot_preview:
		return
	var material := robot_preview.material as ShaderMaterial
	if material == null:
		material = ShaderMaterial.new()
		material.shader = ROBOT_COLOR_SHADER
		robot_preview.material = material
	material.set_shader_parameter("team_color", color_edit.color)

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
	for animation_name in ["idle", "attack", "move", "skill"]:
		_refresh_image_thumbnail("animation:" + animation_name)
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
		if animation_name == "idle": path = idle_edit.text.strip_edges()
		elif animation_name == "attack": path = attack_edit.text.strip_edges()
		elif animation_name == "move": path = move_edit.text.strip_edges()
		elif animation_name == "skill": path = skill_edit.text.strip_edges()
		elif animation_edits.has(animation_name): path = (animation_edits[animation_name] as LineEdit).text.strip_edges()
	if path.is_empty():
		_set_status("No image assigned for %s." % target)
		return
	IMAGE_STATE.open_image(path, target)
	request_image_editor.emit()

func _apply_pending_asset_selection() -> void:
	var target := IMAGE_STATE.selection_target
	if target.is_empty() or not IMAGE_STATE.selection_pending:
		return
	var path := IMAGE_STATE.consume_selection(target)
	if path.is_empty():
		return
	if target == "default_image":
		default_image_edit.text = path
	elif target == "projectile":
		projectile_edit.text = path
	elif target.begins_with("animation:"):
		var animation_name := target.trim_prefix("animation:")
		if animation_name == "idle": idle_edit.text = path
		elif animation_name == "attack": attack_edit.text = path
		elif animation_name == "move": move_edit.text = path
		elif animation_name == "skill": skill_edit.text = path
		elif animation_name == "hit": hit_edit.text = path
		elif animation_name == "death": death_edit.text = path
		elif animation_name == "skill1": skill1_edit.text = path
		elif animation_name == "skill2": skill2_edit.text = path
		elif animation_name == "skill3": skill3_edit.text = path
		elif animation_name == "special": special_edit.text = path
		elif animation_name == "finisher": finisher_edit.text = path
		elif animation_edits.has(animation_name):
			(animation_edits[animation_name] as LineEdit).text = path
	elif target == "sprite":
		idle_edit.text = path
	_refresh_all_image_thumbnails()
	_set_status("Asset selected: " + path)

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
		if animation_name == "idle":
			idle_edit.text = resource_path
		elif animation_name == "attack":
			attack_edit.text = resource_path
		elif animation_name == "move":
			move_edit.text = resource_path
		elif animation_name == "skill":
			skill_edit.text = resource_path
		elif animation_edits.has(animation_name):
			(animation_edits[animation_name] as LineEdit).text = resource_path
	_refresh_animation_previews()
	_set_status("Imported image: " + resource_path)

func _set_status(message: String) -> void:
	if status_label:
		status_label.text = "Status: " + message
