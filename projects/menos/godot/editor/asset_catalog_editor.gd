extends Window

const CATALOG_PATH := "res://content/editor/asset_catalog.json"
const TILE_GROUPS := ["Boundary", "Bridge", "City", "Decoration", "Etc", "Facility", "Forest", "Ground", "Military", "River", "Sea"]
const OBJECT_GROUPS := ["Combat", "Industrial", "Terrain"]
const REGION_VIEW_SCRIPT := preload("res://editor/asset_region_view.gd")

var entries: Array[Dictionary] = []
var source_path := ""
var source_texture: Texture2D
var selected_index := -1
var source_dialog: FileDialog
var asset_list: ItemList
var region_view: Control
var source_label: Label
var id_edit: LineEdit
var name_edit: LineEdit
var kind_option: OptionButton
var group_option: OptionButton
var footprint_x: SpinBox
var footprint_y: SpinBox
var footprint_row: HBoxContainer
var rect_label: Label
var status_label: Label

func _ready() -> void:
	close_requested.connect(hide)
	_build_interface()
	_load_catalog()

func _build_interface() -> void:
	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 16)
	root.add_theme_constant_override("margin_right", 16)
	root.add_theme_constant_override("margin_top", 14)
	root.add_theme_constant_override("margin_bottom", 14)
	add_child(root)
	var vertical := VBoxContainer.new()
	root.add_child(vertical)
	var heading := Label.new()
	heading.text = "ASSET DATA AUTHORING"
	heading.add_theme_font_size_override("font_size", 22)
	vertical.add_child(heading)
	var intro := Label.new()
	intro.text = "Register source image regions for later map-editor integration. Entries are saved separately from map data."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vertical.add_child(intro)
	var toolbar := HBoxContainer.new()
	vertical.add_child(toolbar)
	var choose_button := Button.new()
	choose_button.text = "Choose Project Image"
	choose_button.pressed.connect(_open_source_dialog)
	toolbar.add_child(choose_button)
	source_label = Label.new()
	source_label.text = "No project image selected"
	source_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(source_label)
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vertical.add_child(columns)
	var preview_panel := PanelContainer.new()
	preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_panel.size_flags_stretch_ratio = 1.5
	columns.add_child(preview_panel)
	var preview_box := VBoxContainer.new()
	preview_panel.add_child(preview_box)
	var preview_title := Label.new()
	preview_title.text = "SOURCE REGION — drag over the image"
	preview_box.add_child(preview_title)
	region_view = REGION_VIEW_SCRIPT.new()
	region_view.custom_minimum_size = Vector2(520, 520)
	region_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	region_view.region_changed.connect(_on_region_changed)
	preview_box.add_child(region_view)
	var details := VBoxContainer.new()
	details.custom_minimum_size.x = 400
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(details)
	var list_title := Label.new()
	list_title.text = "REGISTERED ASSETS"
	details.add_child(list_title)
	asset_list = ItemList.new()
	asset_list.custom_minimum_size.y = 170
	asset_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	asset_list.item_selected.connect(_on_asset_selected)
	details.add_child(asset_list)
	var form := GridContainer.new()
	form.columns = 2
	details.add_child(form)
	_add_form_label(form, "Asset ID")
	id_edit = LineEdit.new()
	id_edit.placeholder_text = "asset.tile.ground.001"
	form.add_child(id_edit)
	_add_form_label(form, "Display Name")
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Meadow tile"
	form.add_child(name_edit)
	_add_form_label(form, "Kind")
	kind_option = OptionButton.new()
	kind_option.add_item("Tile")
	kind_option.add_item("Object")
	kind_option.item_selected.connect(_on_kind_changed)
	form.add_child(kind_option)
	_add_form_label(form, "Group")
	group_option = OptionButton.new()
	form.add_child(group_option)
	_add_form_label(form, "Source")
	var source_detail := Label.new()
	source_detail.text = "Selected project image"
	source_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	form.add_child(source_detail)
	_add_form_label(form, "Pixel Rect")
	rect_label = Label.new()
	rect_label.text = "[0, 0, 0, 0]"
	form.add_child(rect_label)
	_add_form_label(form, "Object Footprint")
	footprint_row = HBoxContainer.new()
	footprint_row.add_child(_new_label("W"))
	footprint_x = _new_spin(1, 128)
	footprint_row.add_child(footprint_x)
	footprint_row.add_child(_new_label("H"))
	footprint_y = _new_spin(1, 128)
	footprint_row.add_child(footprint_y)
	form.add_child(footprint_row)
	var buttons := HBoxContainer.new()
	details.add_child(buttons)
	_add_button(buttons, "Add Entry", _add_entry)
	_add_button(buttons, "Update Selected", _update_entry)
	_add_button(buttons, "Remove Selected", _remove_entry)
	_add_button(buttons, "Save Catalog", _save_catalog)
	status_label = Label.new()
	status_label.text = "Catalog ready. Choose an image and drag-select a pixel region."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vertical.add_child(status_label)
	source_dialog = FileDialog.new()
	source_dialog.title = "Choose Project Source Image"
	source_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	source_dialog.access = FileDialog.ACCESS_RESOURCES
	source_dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp,*.bmp,*.svg ; Project Images"])
	source_dialog.current_dir = "res://"
	source_dialog.file_selected.connect(_on_source_file_selected)
	add_child(source_dialog)
	_refresh_group_options()

func _add_form_label(parent: GridContainer, text_value: String) -> void:
	var label := Label.new()
	label.text = text_value
	parent.add_child(label)

func _new_label(text_value: String) -> Label:
	var label := Label.new()
	label.text = text_value
	return label

func _new_spin(minimum: float, maximum: float) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.value = 1
	spin.custom_minimum_size.x = 82
	return spin

func _add_button(parent: HBoxContainer, label_text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = label_text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	parent.add_child(button)

func _open_source_dialog() -> void:
	source_dialog.popup_centered(Vector2i(1000, 700))

func _on_source_file_selected(path: String) -> void:
	var loaded := ResourceLoader.load(path)
	if not loaded is Texture2D:
		status_label.text = "Could not load image resource: " + path
		return
	source_path = path
	source_texture = loaded
	source_label.text = "%s  (%d × %d)" % [path, source_texture.get_width(), source_texture.get_height()]
	region_view.set("texture", source_texture)
	region_view.set("selected_region", Rect2i())
	region_view.queue_redraw()
	_update_rect_label(Rect2i())
	if selected_index < 0 and id_edit.text.strip_edges().is_empty():
		id_edit.text = "asset.tile." + path.get_file().get_basename().to_snake_case()
	if selected_index < 0 and name_edit.text.strip_edges().is_empty():
		name_edit.text = path.get_file().get_basename().replace("_", " ").capitalize()
	status_label.text = "Image loaded. Drag across the preview to define source pixel bounds."

func _on_region_changed(rect: Rect2i) -> void:
	_update_rect_label(rect)

func _update_rect_label(rect: Rect2i) -> void:
	rect_label.text = "[%d, %d, %d, %d]" % [rect.position.x, rect.position.y, rect.size.x, rect.size.y]

func _on_kind_changed(_index: int) -> void:
	_refresh_group_options()

func _refresh_group_options(preferred: String = "") -> void:
	if group_option == null:
		return
	var groups: Array = OBJECT_GROUPS if kind_option != null and kind_option.selected == 1 else TILE_GROUPS
	group_option.clear()
	for group_name in groups:
		group_option.add_item(group_name)
	var preferred_index := groups.find(preferred)
	group_option.select(preferred_index if preferred_index >= 0 else 0)
	if footprint_row != null:
		footprint_row.visible = kind_option != null and kind_option.selected == 1

func _current_rect() -> Rect2i:
	var value: Variant = region_view.get("selected_region")
	if value is Rect2i:
		return value
	return Rect2i()

func _build_entry() -> Dictionary:
	var rect := _current_rect()
	if id_edit.text.strip_edges().is_empty() or name_edit.text.strip_edges().is_empty() or source_path.is_empty() or rect.size.x <= 0 or rect.size.y <= 0:
		status_label.text = "Add an ID, name, project image, and valid selected region first."
		return {}
	var entry := {
		"asset_id": id_edit.text.strip_edges(),
		"kind": "object" if kind_option.selected == 1 else "tile",
		"group": group_option.get_item_text(group_option.selected),
		"display_name": name_edit.text.strip_edges(),
		"source_path": source_path,
		"source_rect_px": [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
	}
	if kind_option.selected == 1:
		entry["footprint_tiles"] = [int(footprint_x.value), int(footprint_y.value)]
	return entry

func _id_exists(asset_id: String, except_index: int = -1) -> bool:
	for index in range(entries.size()):
		if index != except_index and str(entries[index].get("asset_id", "")) == asset_id:
			return true
	return false

func _add_entry() -> void:
	var entry := _build_entry()
	if entry.is_empty():
		return
	if _id_exists(str(entry.asset_id)):
		status_label.text = "Asset ID already exists. Choose a stable unique ID."
		return
	entries.append(entry)
	selected_index = entries.size() - 1
	_refresh_list()
	status_label.text = "Added %s. Save Catalog to persist changes." % entry.asset_id

func _update_entry() -> void:
	if selected_index < 0 or selected_index >= entries.size():
		status_label.text = "Select a catalog entry to update."
		return
	var entry := _build_entry()
	if entry.is_empty():
		return
	if _id_exists(str(entry.asset_id), selected_index):
		status_label.text = "Asset ID already exists. Choose a stable unique ID."
		return
	entries[selected_index] = entry
	_refresh_list()
	asset_list.select(selected_index)
	status_label.text = "Updated entry. Save Catalog to persist changes."

func _remove_entry() -> void:
	if selected_index < 0 or selected_index >= entries.size():
		status_label.text = "Select a catalog entry to remove."
		return
	entries.remove_at(selected_index)
	selected_index = -1
	_refresh_list()
	_clear_form()
	status_label.text = "Removed entry. Save Catalog to persist changes."

func _on_asset_selected(index: int) -> void:
	if index < 0 or index >= entries.size():
		return
	selected_index = index
	var entry: Dictionary = entries[index]
	id_edit.text = str(entry.get("asset_id", ""))
	name_edit.text = str(entry.get("display_name", ""))
	kind_option.select(1 if str(entry.get("kind", "tile")) == "object" else 0)
	_refresh_group_options(str(entry.get("group", "")))
	var rect_values: Array = entry.get("source_rect_px", [0, 0, 0, 0])
	var rect := Rect2i(int(rect_values[0]), int(rect_values[1]), int(rect_values[2]), int(rect_values[3]))
	source_path = str(entry.get("source_path", ""))
	_load_source_for_entry(rect)
	var footprint: Array = entry.get("footprint_tiles", [1, 1])
	footprint_x.value = int(footprint[0])
	footprint_y.value = int(footprint[1])

func _load_source_for_entry(rect: Rect2i) -> void:
	var loaded := ResourceLoader.load(source_path)
	if loaded is Texture2D:
		source_texture = loaded
		source_label.text = "%s  (%d × %d)" % [source_path, source_texture.get_width(), source_texture.get_height()]
		region_view.set("texture", source_texture)
		region_view.set("selected_region", rect)
		region_view.queue_redraw()
		_update_rect_label(rect)
	else:
		source_texture = null
		source_label.text = "Missing project image: " + source_path
		region_view.set("texture", null)
		region_view.queue_redraw()
		_update_rect_label(rect)

func _clear_form() -> void:
	id_edit.clear()
	name_edit.clear()
	source_path = ""
	source_texture = null
	source_label.text = "No project image selected"
	region_view.set("texture", null)
	region_view.set("selected_region", Rect2i())
	region_view.queue_redraw()
	_update_rect_label(Rect2i())

func _refresh_list() -> void:
	asset_list.clear()
	for entry in entries:
		asset_list.add_item("%s  ·  %s / %s" % [entry.get("asset_id", "?"), entry.get("kind", "?"), entry.get("display_name", "?")])
	if selected_index >= 0 and selected_index < entries.size():
		asset_list.select(selected_index)

func _load_catalog() -> void:
	if not FileAccess.file_exists(CATALOG_PATH):
		return
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		status_label.text = "Could not open asset catalog."
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary and parsed.get("assets", []) is Array:
		for value in parsed.assets:
			if value is Dictionary:
				entries.append(value.duplicate(true))
	_refresh_list()
	status_label.text = "Loaded %d catalog entries." % entries.size()

func _save_catalog() -> void:
	var directory := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://content/editor"))
	if directory != OK:
		status_label.text = "Could not create catalog directory. Error %d" % directory
		return
	var file := FileAccess.open(CATALOG_PATH, FileAccess.WRITE)
	if file == null:
		status_label.text = "Could not write catalog. Error %d" % FileAccess.get_open_error()
		return
	file.store_string(JSON.stringify({"schema_version": 1, "assets": entries}, "\t") + "\n")
	status_label.text = "Saved %d assets to %s" % [entries.size(), CATALOG_PATH]
