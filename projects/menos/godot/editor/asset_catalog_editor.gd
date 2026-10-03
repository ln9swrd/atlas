extends Window

signal catalog_saved(selected_asset_id: String)

const CATALOG_PATH := "res://content/editor/asset_catalog.json"
const TILE_GROUPS := ["Boundary", "Bridge", "City", "Decoration", "Etc", "Facility", "Forest", "Ground", "Military", "Obstacle", "Other", "Prop", "River", "Sea", "Structure"]
const OBJECT_GROUPS := ["Combat", "Decoration", "Ground", "Industrial", "Obstacle", "Other", "Prop", "Structure", "Terrain"]
const REGION_VIEW_SCRIPT := preload("res://editor/asset_region_view.gd")
const IMAGE_TEXTURE_LOADER := preload("res://editor/image_texture_loader.gd")
const EDITED_ASSET_DIR := "res://content/editor/edited_assets"

var entries: Array[Dictionary] = []
var source_path := ""
var source_texture: Texture2D
var preview_source_cache: Dictionary = {}
var source_thumbnail_cache: Dictionary = {}
var selected_index := -1
var editing_asset_index := -1
var source_dialog: FileDialog
var asset_list: ItemList
var region_view: AssetRegionView
var source_label: Label
var source_preview_panel: PanelContainer
var source_preview: TextureRect
var id_edit: LineEdit
var name_edit: LineEdit
var kind_option: OptionButton
var group_option: OptionButton
var footprint_width_label: Label
var footprint_height_label: Label
var footprint_row: HBoxContainer
var rect_label: Label
var status_label: Label
var maximize_button: Button
var brush_size_spin: SpinBox
var save_edited_button: Button
var cancel_edit_button: Button
var windowed_size := Vector2i(1280, 820)
var windowed_position := Vector2i.ZERO

func _ready() -> void:
	close_requested.connect(hide)
	min_size = Vector2i(960, 640)
	windowed_size = size
	windowed_position = position
	_build_interface()
	_load_catalog()

func open_for_asset_id(asset_id: String, edit_target: String) -> void:
	_load_catalog()
	var target_index := -1
	for index in range(entries.size()):
		if str(entries[index].get("asset_id", "")) == asset_id:
			target_index = index
			break
	if target_index < 0:
		status_label.text = "Catalog entry not found: " + asset_id
		return
	_on_asset_selected(target_index)
	if edit_target == "image":
		status_label.text = "Source image/region edit: choose a project image or drag a new region, then Update Selected and Save Catalog."
	else:
		status_label.text = "Metadata edit: update the visible ID, name, kind, group, and footprint fields, then Update Selected and Save Catalog."

func open_catalog() -> void:
	_load_catalog()
	_clear_form()
	status_label.text = "Catalog ready. Select an entry or add a new one."

func focus_edit_target(edit_target: String) -> void:
	if edit_target == "image":
		region_view.grab_focus()
	else:
		id_edit.grab_focus()

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
	intro.text = "Register image regions and edit asset crops safely. Double-click a registered asset to erase alpha inside its catalog region on the full source image. Edited crops save as separate project PNGs; original sheets stay unchanged."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vertical.add_child(intro)
	var toolbar := HBoxContainer.new()
	vertical.add_child(toolbar)
	var choose_button := Button.new()
	choose_button.text = "Choose Project Image"
	choose_button.pressed.connect(_open_source_dialog)
	toolbar.add_child(choose_button)
	maximize_button = Button.new()
	maximize_button.text = "Maximize"
	maximize_button.pressed.connect(_toggle_window_mode)
	toolbar.add_child(maximize_button)
	source_label = Label.new()
	source_label.text = "No project image selected"
	source_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(source_label)
	source_preview_panel = PanelContainer.new()
	source_preview_panel.custom_minimum_size = Vector2(88, 64)
	source_preview_panel.visible = false
	var preview_style := StyleBoxFlat.new()
	preview_style.bg_color = Color("151d26")
	source_preview_panel.add_theme_stylebox_override("panel", preview_style)
	source_preview = TextureRect.new()
	source_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	source_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	source_preview.tooltip_text = "Loaded source image preview"
	source_preview_panel.add_child(source_preview)
	toolbar.add_child(source_preview_panel)
	var image_edit_toolbar := HBoxContainer.new()
	vertical.add_child(image_edit_toolbar)
	image_edit_toolbar.add_child(_new_label("Erase brush (source px):"))
	brush_size_spin = _new_spin(1, 256)
	brush_size_spin.value = 12
	brush_size_spin.value_changed.connect(_on_erase_brush_size_changed)
	image_edit_toolbar.add_child(brush_size_spin)
	save_edited_button = Button.new()
	save_edited_button.text = "Save Edited Image"
	save_edited_button.disabled = true
	save_edited_button.pressed.connect(_save_edited_image)
	image_edit_toolbar.add_child(save_edited_button)
	cancel_edit_button = Button.new()
	cancel_edit_button.text = "Cancel Image Edit"
	cancel_edit_button.disabled = true
	cancel_edit_button.pressed.connect(_cancel_image_edit)
	image_edit_toolbar.add_child(cancel_edit_button)
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
	preview_title.text = "SOURCE REGION / Drag over the image to select a region."
	preview_box.add_child(preview_title)
	region_view = REGION_VIEW_SCRIPT.new()
	region_view.custom_minimum_size = Vector2(520, 520)
	region_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	region_view.focus_mode = Control.FOCUS_ALL
	region_view.region_changed.connect(_on_region_changed)
	preview_box.add_child(region_view)
	var details := VBoxContainer.new()
	details.custom_minimum_size.x = 400
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(details)
	var list_title := Label.new()
	list_title.text = "REGISTERED ASSETS (double-click row to edit crop)"
	details.add_child(list_title)
	asset_list = ItemList.new()
	asset_list.custom_minimum_size.y = 170
	asset_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	asset_list.icon_mode = ItemList.ICON_MODE_LEFT
	asset_list.fixed_icon_size = Vector2i(48, 48)
	asset_list.item_selected.connect(_on_asset_selected)
	asset_list.item_activated.connect(_on_asset_activated)
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
	_add_form_label(form, "Grid size (map tiles)")
	footprint_row = HBoxContainer.new()
	footprint_row.add_child(_new_label("W"))
	footprint_width_label = Label.new()
	footprint_width_label.custom_minimum_size.x = 48
	footprint_width_label.text = "1"
	footprint_row.add_child(footprint_width_label)
	footprint_row.add_child(_new_label("H"))
	footprint_height_label = Label.new()
	footprint_height_label.custom_minimum_size.x = 48
	footprint_height_label.text = "1"
	footprint_row.add_child(footprint_height_label)
	form.add_child(footprint_row)
	var buttons := HBoxContainer.new()
	details.add_child(buttons)
	_add_button(buttons, "항목 추가", _add_entry)
	_add_button(buttons, "선택 항목 업데이트", _update_entry)
	_add_button(buttons, "선택 항목 삭제", _remove_entry)
	_add_button(buttons, "카탈로그 저장", _on_save_catalog_pressed)
	status_label = Label.new()
	status_label.text = "Catalog ready. Choose an image and drag-select a pixel region."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vertical.add_child(status_label)
	source_dialog = FileDialog.new()
	source_dialog.title = "Choose Project Source Image"
	source_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	source_dialog.access = FileDialog.ACCESS_RESOURCES
	source_dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp,*.bmp,*.svg ; Project Images"])
	source_dialog.display_mode = FileDialog.DISPLAY_THUMBNAILS
	source_dialog.add_theme_constant_override("thumbnail_size", 112)
	FileDialog.set_get_thumbnail_callback(Callable(self, "_get_source_thumbnail"))
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
	source_thumbnail_cache.clear()
	source_dialog.invalidate()
	source_dialog.popup_centered(Vector2i(1000, 700))

func _get_source_thumbnail(path: String) -> Texture2D:
	var cached: Texture2D = source_thumbnail_cache.get(path) as Texture2D
	if cached != null:
		return cached
	var loaded: Texture2D = IMAGE_TEXTURE_LOADER.load_texture(path)
	if loaded != null:
		source_thumbnail_cache[path] = loaded
	return loaded

func _toggle_window_mode() -> void:
	if mode == Window.MODE_MAXIMIZED:
		max_size = Vector2i.ZERO
		mode = Window.MODE_WINDOWED
		position = windowed_position
		size = windowed_size
		maximize_button.text = "Maximize"
	else:
		windowed_size = size
		windowed_position = position
		var usable_rect := DisplayServer.screen_get_usable_rect(current_screen)
		if usable_rect.size.x <= 0 or usable_rect.size.y <= 0:
			return
		max_size = usable_rect.size
		position = usable_rect.position
		size = usable_rect.size
		mode = Window.MODE_MAXIMIZED
		maximize_button.text = "Restore"

func _on_erase_brush_size_changed(value: float) -> void:
	region_view.set_erase_brush_size(int(value))

func _on_asset_activated(index: int) -> void:
	if index < 0 or index >= entries.size():
		return
	if region_view.is_editing_pixels():
		status_label.text = "Save or cancel the current image edit before opening another asset."
		return
	_on_asset_selected(index)
	var rect_values: Array = entries[index].get("source_rect_px", [])
	if rect_values.size() < 4:
		status_label.text = "Cannot edit image: source pixel rectangle is missing."
		return
	var rect := Rect2i(int(rect_values[0]), int(rect_values[1]), int(rect_values[2]), int(rect_values[3]))
	if rect.size.x <= 0 or rect.size.y <= 0:
		status_label.text = "Cannot edit image: source pixel rectangle is empty."
		return
	var entry_path := str(entries[index].get("source_path", ""))
	var full_image := IMAGE_TEXTURE_LOADER.load_image(entry_path)
	if full_image == null:
		status_label.text = "Cannot edit image: could not load source file %s." % entry_path
		return
	if rect.position.x < 0 or rect.position.y < 0 or rect.end.x > full_image.get_width() or rect.end.y > full_image.get_height():
		status_label.text = "Cannot edit image: source region is outside the image bounds."
		return
	region_view.begin_image_edit_clipped(full_image, rect, int(brush_size_spin.value))
	editing_asset_index = index
	asset_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	save_edited_button.disabled = false
	cancel_edit_button.disabled = false
	status_label.text = "Editing catalog region on the full source image. Wheel zooms; Space/Alt/middle/right drag pans; left drag erases alpha inside the red outline. Save Edited Image writes a separate PNG."

func _cancel_image_edit() -> void:
	if editing_asset_index < 0 or editing_asset_index >= entries.size():
		return
	var rect_values: Array = entries[editing_asset_index].get("source_rect_px", [0, 0, 0, 0])
	var rect := Rect2i(int(rect_values[0]), int(rect_values[1]), int(rect_values[2]), int(rect_values[3]))
	region_view.cancel_image_edit()
	_load_source_for_entry(rect)
	_finish_image_edit()
	status_label.text = "Image edit cancelled; catalog data was not changed."

func _finish_image_edit() -> void:
	editing_asset_index = -1
	asset_list.mouse_filter = Control.MOUSE_FILTER_STOP
	save_edited_button.disabled = true
	cancel_edit_button.disabled = true

func _save_edited_image() -> void:
	if editing_asset_index < 0 or editing_asset_index >= entries.size():
		status_label.text = "Double-click a registered asset thumbnail before saving an image edit."
		return
	var edited_image: Image = region_view.get_edited_image()
	if edited_image == null or edited_image.is_empty():
		status_label.text = "No editable image is available."
		return
	var directory_path := ProjectSettings.globalize_path(EDITED_ASSET_DIR)
	var directory_error := DirAccess.make_dir_recursive_absolute(directory_path)
	if directory_error != OK:
		status_label.text = "Could not create edited asset directory. Error %d" % directory_error
		return
	var asset_id := str(entries[editing_asset_index].get("asset_id", "asset"))
	var safe_id := _safe_asset_filename(asset_id)
	var output_path := "%s/%s_edit_%d.png" % [EDITED_ASSET_DIR, safe_id, Time.get_ticks_usec()]
	var save_error := edited_image.save_png(ProjectSettings.globalize_path(output_path))
	if save_error != OK:
		status_label.text = "Could not save edited PNG. Error %d" % save_error
		return
	var updated_entry: Dictionary = entries[editing_asset_index].duplicate(true)
	updated_entry["source_path"] = output_path
	updated_entry["source_rect_px"] = [0, 0, edited_image.get_width(), edited_image.get_height()]
	var edited_footprint := _footprint_for_size(edited_image.get_width(), edited_image.get_height())
	updated_entry["footprint_tiles"] = [edited_footprint.x, edited_footprint.y]
	var old_entry: Dictionary = entries[editing_asset_index]
	var completed_index := editing_asset_index
	entries[editing_asset_index] = updated_entry
	if not _save_catalog():
		entries[editing_asset_index] = old_entry
		status_label.text = "PNG saved to %s, but catalog save failed. The catalog entry was kept unchanged." % output_path
		return
	source_path = output_path
	source_texture = ImageTexture.create_from_image(edited_image)
	_set_source_preview(source_texture)
	source_label.text = "%s  (%d x %d)" % [output_path, edited_image.get_width(), edited_image.get_height()]
	region_view.cancel_image_edit()
	region_view.set_source_texture(source_texture)
	region_view.selected_region = Rect2i(0, 0, edited_image.get_width(), edited_image.get_height())
	region_view.queue_redraw()
	_update_rect_label(region_view.selected_region)
	_update_footprint_display(region_view.selected_region)
	preview_source_cache.clear()
	_finish_image_edit()
	status_label.text = "Saved edited crop %s and updated asset %s." % [output_path, asset_id]
	_refresh_list()
	asset_list.select(completed_index)

func _safe_asset_filename(asset_id: String) -> String:
	var result := ""
	for character in asset_id.to_lower():
		if character in "abcdefghijklmnopqrstuvwxyz0123456789_-":
			result += character
		else:
			result += "_"
	return result if not result.is_empty() else "asset"

func _on_source_file_selected(path: String) -> void:
	var loaded: Texture2D = IMAGE_TEXTURE_LOADER.load_texture(path)
	if loaded == null:
		source_path = ""
		source_texture = null
		_set_source_preview(null)
		region_view.set_source_texture(null)
		source_label.text = "Could not load image: " + path
		status_label.text = "Could not load image resource: " + path
		return
	source_path = path
	source_texture = loaded
	_set_source_preview(loaded)
	source_label.text = "%s  (%d x %d)" % [path, source_texture.get_width(), source_texture.get_height()]
	region_view.set_source_texture(source_texture)
	_update_rect_label(Rect2i())
	_update_footprint_display(Rect2i())
	if selected_index < 0 and id_edit.text.strip_edges().is_empty():
		id_edit.text = "asset.tile." + path.get_file().get_basename().to_snake_case()
	if selected_index < 0 and name_edit.text.strip_edges().is_empty():
		name_edit.text = path.get_file().get_basename().replace("_", " ").capitalize()
	status_label.text = "Image loaded. Drag across the preview to define source pixel bounds."

func _on_region_changed(rect: Rect2i) -> void:
	_update_rect_label(rect)
	_update_footprint_display(rect)
	status_label.text = "Region changed to [%d, %d, %d, %d]. Click Update Selected, then Save Catalog." % [rect.position.x, rect.position.y, rect.size.x, rect.size.y]

func _set_source_preview(value: Texture2D) -> void:
	source_preview.texture = value
	source_preview_panel.visible = value != null

func _update_rect_label(rect: Rect2i) -> void:
	rect_label.text = "[%d, %d, %d, %d]" % [rect.position.x, rect.position.y, rect.size.x, rect.size.y]

func _footprint_for_size(width_px: int, height_px: int) -> Vector2i:
	return Vector2i(maxi(1, ceili(float(width_px) / 32.0)), maxi(1, ceili(float(height_px) / 32.0)))

func _update_footprint_display(rect: Rect2i) -> void:
	var footprint := _footprint_for_size(rect.size.x, rect.size.y)
	footprint_width_label.text = str(footprint.x)
	footprint_height_label.text = str(footprint.y)

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
		footprint_row.visible = true

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
	var footprint := _footprint_for_size(rect.size.x, rect.size.y)
	var entry := {
		"asset_id": id_edit.text.strip_edges(),
		"kind": "object" if kind_option.selected == 1 else "tile",
		"group": group_option.get_item_text(group_option.selected),
		"display_name": name_edit.text.strip_edges(),
		"source_path": source_path,
		"source_rect_px": [rect.position.x, rect.position.y, rect.size.x, rect.size.y],
		"footprint_tiles": [footprint.x, footprint.y]
	}
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
	_update_footprint_display(rect)

func _load_source_for_entry(rect: Rect2i) -> void:
	var loaded: Texture2D = IMAGE_TEXTURE_LOADER.load_texture(source_path)
	if loaded != null:
		source_texture = loaded
		_set_source_preview(loaded)
		source_label.text = "%s  (%d x %d)" % [source_path, source_texture.get_width(), source_texture.get_height()]
		region_view.set_source_texture(source_texture)
		region_view.set("selected_region", rect)
		region_view.queue_redraw()
		_update_rect_label(rect)
	else:
		source_texture = null
		_set_source_preview(null)
		source_label.text = "Missing project image: " + source_path
		region_view.set_source_texture(null)
		_update_rect_label(rect)

func _clear_form() -> void:
	id_edit.clear()
	name_edit.clear()
	source_path = ""
	source_texture = null
	_set_source_preview(null)
	source_label.text = "No project image selected"
	region_view.set_source_texture(null)
	region_view.set("selected_region", Rect2i())
	_update_rect_label(Rect2i())
	_update_footprint_display(Rect2i())

func _refresh_list() -> void:
	asset_list.clear()
	for entry in entries:
		var kind_text := str(entry.get("kind", "tile")).capitalize()
		var group_text := str(entry.get("group", "?"))
		var display_text := "%s\n%s  / %s" % [entry.get("display_name", "?"), kind_text, group_text]
		asset_list.add_item(display_text, _entry_preview_icon(entry))
	if selected_index >= 0 and selected_index < entries.size():
		asset_list.select(selected_index)

func _entry_preview_icon(entry: Dictionary) -> Texture2D:
	var rect_values: Variant = entry.get("source_rect_px", [])
	if not rect_values is Array or rect_values.size() != 4:
		return null
	var source_path_value := str(entry.get("source_path", ""))
	if source_path_value.is_empty():
		return null
	var texture: Texture2D = preview_source_cache.get(source_path_value) as Texture2D
	if texture == null:
		var loaded: Texture2D = IMAGE_TEXTURE_LOADER.load_texture(source_path_value)
		if loaded == null:
			return null
		texture = loaded
		preview_source_cache[source_path_value] = texture
	var rect := Rect2i(int(rect_values[0]), int(rect_values[1]), int(rect_values[2]), int(rect_values[3]))
	if rect.size.x <= 0 or rect.size.y <= 0 or rect.position.x < 0 or rect.position.y < 0:
		return null
	if rect.end.x > texture.get_width() or rect.end.y > texture.get_height():
		return null
	var preview := AtlasTexture.new()
	preview.atlas = texture
	preview.region = Rect2(rect.position, rect.size)
	return preview

func _load_catalog() -> void:
	entries.clear()
	selected_index = -1
	if not FileAccess.file_exists(CATALOG_PATH):
		_refresh_list()
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

func _save_catalog() -> bool:
	var directory := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://content/editor"))
	if directory != OK:
		status_label.text = "Could not create catalog directory. Error %d" % directory
		return false
	var file := FileAccess.open(CATALOG_PATH, FileAccess.WRITE)
	if file == null:
		status_label.text = "Could not write catalog. Error %d" % FileAccess.get_open_error()
		return false
	file.store_string(JSON.stringify({"schema_version": 1, "assets": entries}, "	") + "\n")
	file.close()
	status_label.text = "Saved %d assets to %s" % [entries.size(), CATALOG_PATH]
	var selected_asset_id := ""
	if selected_index >= 0 and selected_index < entries.size():
		selected_asset_id = str(entries[selected_index].get("asset_id", ""))
	catalog_saved.emit(selected_asset_id)
	return true

func _on_save_catalog_pressed() -> void:
	if region_view.is_editing_pixels():
		_save_edited_image()
		return
	_save_catalog()
