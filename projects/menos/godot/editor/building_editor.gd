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

func _ready() -> void:
	_build_ui()
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

func _load_data() -> void:
	if not BuildingRepository.ensure_schema():
		_set_status("FAILED to initialize buildings schema.")
		return
	building_list.clear()
	var buildings := BuildingRepository.list_buildings()
	for data in buildings:
		var odb_pk := int(data.get("odb_pk", 0))
		var name := str(data.get("name", "BUILDING"))
		building_list.add_item("#%d %s" % [odb_pk, name])
		building_list.set_item_metadata(building_list.item_count - 1, odb_pk)
	if building_list.item_count > 0:
		building_list.select(0)
		_on_building_selected(0)
	else:
		_clear_form()
	_set_status("Loaded: buildings")

func _on_building_selected(index: int) -> void:
	if index < 0 or index >= building_list.item_count:
		return
	selected_id = int(building_list.get_item_metadata(index))
	var data := BuildingRepository.get_building(selected_id)
	if data.is_empty():
		_clear_form()
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
	var id := BuildingRepository.create_building("NEW BUILDING")
	if id <= 0:
		_set_status("FAILED to add building.")
		return
	_load_data()
	for i in range(building_list.item_count):
		if int(building_list.get_item_metadata(i)) == id:
			building_list.select(i)
			_on_building_selected(i)
			break
	_set_status("ADDED building: #%d" % id)

func _save_data() -> void:
	if selected_id <= 0:
		_set_status("No building selected.")
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
	if data["name"] == "":
		_set_status("Name is required.")
		return
	if not BuildingRepository.save_building(selected_id, data):
		_set_status("FAILED to save building #%d." % selected_id)
		return
	_load_data()
	_set_status("SAVED + VERIFIED: building #%d" % selected_id)

func _delete_building() -> void:
	if selected_id <= 0:
		_set_status("No building selected.")
		return
	if not BuildingRepository.delete_building(selected_id):
		_set_status("FAILED to delete building #%d." % selected_id)
		return
	_load_data()
	_set_status("DELETED building #%d" % selected_id)

func _set_status(message: String) -> void:
	if is_instance_valid(status_label):
		status_label.text = "Status: " + message
