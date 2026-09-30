class_name RobotEditorMain
extends Control

const ROBOT_FILE := "res://content/robots/robots.json"

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
var idle_edit: LineEdit
var attack_edit: LineEdit
var move_edit: LineEdit
var skill_edit: LineEdit
var projectile_edit: LineEdit
var status_label: Label
var animation_previews: Dictionary = {}
var animation_timer: Timer
var animation_frame := 0
const ROBOT_ANIMATION_FRAMES := {"idle": 6, "attack": 7, "move": 5, "skill": 5, "projectile": 8}

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

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 12)
	add_child(root)
	var title := Label.new()
	title.text = "MENOS // ROBOT EDITOR"
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)
	var top := HBoxContainer.new()
	root.add_child(top)
	robot_list = OptionButton.new()
	robot_list.custom_minimum_size.x = 220
	robot_list.item_selected.connect(_on_robot_selected)
	top.add_child(robot_list)
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
	var base_title := Label.new()
	base_title.text = "ROBOT PROPERTIES"
	base_title.add_theme_font_size_override("font_size", 16)
	content.add_child(base_title)
	id_edit = _line_row(content, "ID")
	name_edit = _line_row(content, "Name")
	hp_spin = _spin_row(content, "HP", 1, 999999, 1, 220)
	speed_spin = _spin_row(content, "Speed", 0, 9999, 0.1, 125)
	damage_spin = _spin_row(content, "Damage", 0, 99999, 0.1, 28)
	cooldown_spin = _spin_row(content, "Cooldown", 0.01, 9999, 0.01, 0.65)
	range_spin = _spin_row(content, "Range", 0, 99999, 1, 180)
	var visual_title := Label.new()
	visual_title.text = "VISUAL / PROJECTILE"
	visual_title.add_theme_font_size_override("font_size", 16)
	content.add_child(visual_title)
	idle_edit = _line_row(content, "Idle Animation")
	attack_edit = _line_row(content, "Attack Animation")
	move_edit = _line_row(content, "Move Animation")
	skill_edit = _line_row(content, "Skill Animation")
	projectile_edit = _line_row(content, "Projectile Animation")
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
	id_edit.text = str(data.get("id", selected_type))
	name_edit.text = str(data.get("name", selected_type.to_upper()))
	hp_spin.value = float(data["hp"])
	speed_spin.value = float(data["speed"])
	damage_spin.value = float(data["damage"])
	cooldown_spin.value = float(data["cooldown"])
	range_spin.value = float(data["range"])
	idle_edit.text = str(data.get("sprite_idle", "res://assets/menos/sprites/atlas_idle.png"))
	attack_edit.text = str(data.get("sprite_attack", "res://assets/menos/sprites/atlas_attack.png"))
	move_edit.text = str(data.get("sprite_move", "res://assets/menos/sprites/atlas_move.png"))
	skill_edit.text = str(data.get("sprite_skill", "res://assets/menos/sprites/atlas_skill.png"))
	projectile_edit.text = str(data.get("projectile_anim", "res://assets/menos/sprites/bullet_defender.png"))
	_refresh_animation_previews()

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
		preview.texture = _animated_texture(path, animation_frame, frames)

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
	data["sprite_idle"] = idle_edit.text.strip_edges()
	data["sprite_attack"] = attack_edit.text.strip_edges()
	data["sprite_move"] = move_edit.text.strip_edges()
	data["sprite_skill"] = skill_edit.text.strip_edges()
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

func _set_status(message: String) -> void:
	if status_label:
		status_label.text = "Status: " + message
