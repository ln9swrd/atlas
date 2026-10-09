class_name BuildingEditorMain
extends Control

var building_list: OptionButton
var id_edit: LineEdit
var name_edit: LineEdit
var category_edit: LineEdit
var hp_spin: SpinBox
var armor_spin: SpinBox
var blocks_check: CheckButton
var destructible_check: CheckButton
var sprite_edit: LineEdit
var status_label: Label
var selected_id := 0
var building_data: Dictionary = {}
var building_dirty := false
var building_loading := false
var pending_delete_id := 0
var pending_new := false

func _ready() -> void:
	_build_ui()
	_connect_dirty_signals()
	_load_data()

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 12)
	add_child(root)

	var title := Label.new()
	title.text = "MENOS // BUILDING EDITOR"
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)

	var top := HBoxContainer.new()
	root.add_child(top)

	var add_btn := Button.new()
	add_btn.text = "ADD BUILDING"
	add_btn.pressed.connect(_add_building)
	top.add_child(add_btn)

	building_list = OptionButton.new()
	building_list.custom_minimum_size.x = 260
	building_list.item_selected.connect(_on_building_selected)
	top.add_child(building_list)

	var reload_btn := Button.new()
	reload_btn.text = "RELOAD"
	reload_btn.pressed.connect(_load_data)
	top.add_child(reload_btn)

	var save_btn := Button.new()
	save_btn.text = "SAVE"
	save_btn.pressed.connect(_save_data)
	top.add_child(save_btn)

	var delete_btn := Button.new()
	delete_btn.text = "DELETE BUILDING"
	delete_btn.pressed.connect(_delete_building)
	top.add_child(delete_btn)

	status_label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(status_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)

	var identity := Label.new()
	identity.text = "IDENTITY"
	identity.add_theme_font_size_override("font_size", 16)
	content.add_child(identity)

	id_edit = _line_row(content, "ODB PK", true)
	name_edit = _line_row(content, "Name")
	category_edit = _line_row(content, "Category")

	var properties := Label.new()
	properties.text = "PROPERTIES"
	properties.add_theme_font_size_override("font_size", 16)
	content.add_child(properties)

	hp_spin = _spin_row(content, "HP", 0, 999999, 1, 100)
	armor_spin = _spin_row(content, "Armor", 0, 99999, 1, 0)
	blocks_check = _check_row(content, "Blocks Movement")
	destructible_check = _check_row(content, "Destructible")

	var visual := Label.new()
	visual.text = "VISUAL"
	visual.add_theme_font_size_override("font_size", 16)
	content.add_child(visual)

	sprite_edit = _line_row(content, "Sprite Asset")

func _line_row(parent: VBoxContainer, label_text: String, read_only := false) -> LineEdit:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 130
	row.add_child(label)
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.editable = not read_only
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

func _check_row(parent: VBoxContainer, label_text: String) -> CheckButton:
	var check := CheckButton.new()
	check.text = label_text
	parent.add_child(check)
	return check

func _connect_dirty_signals() -> void:
	name_edit.text_changed.connect(_on_building_text_changed)
	category_edit.text_changed.connect(_on_building_text_changed)
	sprite_edit.text_changed.connect(_on_building_text_changed)
	hp_spin.value_changed.connect(_on_building_value_changed)
	armor_spin.value_changed.connect(_on_building_value_changed)
	blocks_check.toggled.connect(_on_building_toggled)
	destructible_check.toggled.connect(_on_building_toggled)

func _on_building_text_changed(_value: String) -> void:
	_mark_building_dirty()

func _on_building_value_changed(_value: float) -> void:
	_mark_building_dirty()

func _on_building_toggled(_pressed: bool) -> void:
	_mark_building_dirty()

func _mark_building_dirty() -> void:
	if building_loading:
		return
	building_dirty = true
	_set_status("Unsaved Building changes.")

func _refresh_building_list() -> void:
	building_list.clear()
	for id_variant in building_data.keys():
		var id := int(id_variant)
		var data: Dictionary = building_data.get(id, {})
		var label := "#%d %s" % [id, str(data.get("name", "BUILDING"))] if id > 0 else "#NEW %s" % str(data.get("name", "BUILDING"))
		building_list.add_item(label)
		building_list.set_item_metadata(building_list.item_count - 1, id)

func _load_data() -> void:
	if building_dirty:
		_set_status("Unsaved Building changes. SAVE before RELOAD.")
		return
	building_loading = true
	if not BuildingRepository.ensure_schema():
		_set_status("FAILED to initialize buildings schema.")
		return
	building_data.clear()
	building_list.clear()
	var buildings := BuildingRepository.list_buildings()
	for data in buildings:
		var odb_pk := int(data.get("odb_pk", 0))
		building_data[odb_pk] = data.duplicate(true)
		var name := str(data.get("name", "BUILDING"))
		building_list.add_item("#%d %s" % [odb_pk, name])
		building_list.set_item_metadata(building_list.item_count - 1, odb_pk)
	if building_list.item_count > 0:
		building_list.select(0)
		_on_building_selected(0)
	else:
		_clear_form()
	building_dirty = false
	building_loading = false
	_set_status("Loaded: buildings")

func _on_building_selected(index: int) -> void:
	if index < 0 or index >= building_list.item_count:
		return
	var target_id := int(building_list.get_item_metadata(index))
	if building_dirty and target_id != selected_id:
		_set_status("Unsaved Building changes. SAVE before changing selection.")
		return
	selected_id = target_id
	building_loading = true
	var data: Dictionary = building_data.get(selected_id, {})
	if data.is_empty():
		_clear_form()
		building_loading = false
		_set_status("Building not found: %d" % selected_id)
		return
	id_edit.text = str(selected_id)
	name_edit.text = str(data.get("name", ""))
	category_edit.text = str(data.get("category", "structure"))
	hp_spin.value = float(data.get("hp", 100.0))
	armor_spin.value = float(data.get("armor", 0.0))
	blocks_check.button_pressed = bool(data.get("blocks_movement", true))
	destructible_check.button_pressed = bool(data.get("destructible", true))
	sprite_edit.text = str(data.get("sprite", ""))
	building_loading = false

func _clear_form() -> void:
	selected_id = 0
	id_edit.text = ""
	name_edit.text = ""
	category_edit.text = "structure"
	hp_spin.value = 100
	armor_spin.value = 0
	blocks_check.button_pressed = true
	destructible_check.button_pressed = true
	sprite_edit.text = ""

func _add_building() -> void:
	if building_dirty:
		_set_status("Unsaved Building changes. SAVE before adding another Building.")
		return
	var temp_id := -1
	var data := {
		"name": "NEW BUILDING",
		"category": "structure",
		"hp": 100.0,
		"armor": 0.0,
		"blocks_movement": true,
		"destructible": true,
		"sprite": ""
	}
	building_data[temp_id] = data
	selected_id = temp_id
	pending_new = true
	building_dirty = true
	building_loading = true
	id_edit.text = "NEW"
	name_edit.text = str(data["name"])
	category_edit.text = str(data["category"])
	hp_spin.value = float(data["hp"])
	armor_spin.value = float(data["armor"])
	blocks_check.button_pressed = bool(data["blocks_movement"])
	destructible_check.button_pressed = bool(data["destructible"])
	sprite_edit.text = str(data["sprite"])
	building_loading = false
	_refresh_building_list()
	_set_status("ADDED to working copy. SAVE to persist.")

func _save_data() -> void:
	if not building_dirty:
		_set_status("No unsaved Building changes.")
		return
	var data := {
		"name": name_edit.text.strip_edges(),
		"category": category_edit.text.strip_edges(),
		"hp": float(hp_spin.value),
		"armor": float(armor_spin.value),
		"blocks_movement": blocks_check.button_pressed,
		"destructible": destructible_check.button_pressed,
		"sprite": sprite_edit.text.strip_edges()
	}
	if selected_id == 0 and pending_delete_id <= 0:
		_set_status("No building selected.")
		return
	if selected_id < 0 and pending_new:
		if data["name"] == "":
			_set_status("Name is required.")
			return
		var new_id := BuildingRepository.create_building_with_data(data)
		if new_id <= 0:
			_set_status("FAILED to persist new building. Working copy preserved.")
			return
		building_data.erase(selected_id)
		selected_id = new_id
		pending_new = false
		building_dirty = false
		_load_data()
		for i in range(building_list.item_count):
			if int(building_list.get_item_metadata(i)) == new_id:
				building_list.select(i)
				_on_building_selected(i)
				break
		_set_status("SAVED + VERIFIED: building #%d" % new_id)
		return
	if pending_delete_id > 0:
		var delete_id := pending_delete_id
		if not BuildingRepository.delete_building(delete_id):
			_set_status("FAILED to delete building #%d. Working copy preserved." % delete_id)
			return
		pending_delete_id = 0
		building_dirty = false
		selected_id = 0
		_load_data()
		_set_status("SAVED + VERIFIED: deleted building #%d" % delete_id)
		return
	if selected_id <= 0 or not building_data.has(selected_id):
		_set_status("No building selected.")
		return
	if data["name"] == "":
		_set_status("Name is required.")
		return
	building_data[selected_id] = data.duplicate(true)
	if not BuildingRepository.save_building(selected_id, data):
		_set_status("FAILED to save building #%d. Working copy preserved." % selected_id)
		return
	building_dirty = false
	_load_data()
	for i in range(building_list.item_count):
		if int(building_list.get_item_metadata(i)) == selected_id:
			building_list.select(i)
			_on_building_selected(i)
			break
	_set_status("SAVED + VERIFIED: building #%d" % selected_id)

func _delete_building() -> void:
	if selected_id <= 0 or not building_data.has(selected_id):
		_set_status("No building selected.")
		return
	pending_delete_id = selected_id
	building_data.erase(selected_id)
	selected_id = 0
	building_dirty = true
	_refresh_building_list()
	_set_status("DELETED from working copy. SAVE to persist.")

func _set_status(message: String) -> void:
	if is_instance_valid(status_label):
		status_label.text = "Status: " + message
