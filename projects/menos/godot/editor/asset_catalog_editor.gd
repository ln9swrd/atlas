extends Window

signal catalog_saved(selected_asset_id: String)

const CATALOG_PATH := "res://content/editor/asset_catalog.json"
const TILE_GROUPS := ["Boundary", "Bridge", "City", "Decoration", "Etc", "Facility", "Forest", "Ground", "Military", "Obstacle", "Other", "Prop", "River", "Sea", "Structure"]
const OBJECT_GROUPS := ["Combat", "Decoration", "Ground", "Industrial", "Obstacle", "Other", "Prop", "Structure", "Terrain"]
const REGION_VIEW_SCRIPT := preload("res://editor/asset_region_view.gd")
const IMAGE_TEXTURE_LOADER := preload("res://editor/image_texture_loader.gd")
const EDITOR_THUMBNAIL_UTIL := preload("res://scripts/editor_thumbnail_util.gd")
const EDITED_ASSET_DIR := "res://content/editor/edited_assets"

var entries: Array[Dictionary] = []
var source_path := ""
var source_texture: Texture2D
var preview_source_cache: Dictionary = {}
var source_thumbnail_cache: Dictionary = {}
var selected_index := -1
var editing_asset_index := -1
var search_edit: LineEdit
var visual_assets: Dictionary = {}
var visual_asset_ids: Array[String] = []
var usage_cache: Dictionary = {}
var selected_is_visual_asset := false
var source_dialog: FileDialog
var asset_list: VBoxContainer
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
var visual_frames_spin: SpinBox
var visual_columns_spin: SpinBox
var visual_rows_spin: SpinBox
var visual_frame_order_option: OptionButton
var visual_anchor_x_spin: SpinBox
var visual_anchor_y_spin: SpinBox
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
	var target_index := _find_entry_index(asset_id)
	if target_index < 0:
		id_edit.text = asset_id
		selected_index = -1
		selected_is_visual_asset = true
		visual_frames_spin.visible = true
		visual_columns_spin.visible = true
		visual_rows_spin.visible = true
		visual_frame_order_option.visible = true
		visual_anchor_x_spin.visible = true
		visual_anchor_y_spin.visible = true
		status_label.text = "Asset ID not registered. Choose a project image, select a region, then click Visual Asset 저장."
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
	list_title.text = "REGISTERED ASSETS / VISUAL ASSETS"
	details.add_child(list_title)
	search_edit = LineEdit.new()
	search_edit.placeholder_text = "Search Asset ID / name / source"
	search_edit.text_changed.connect(_on_search_changed)
	details.add_child(search_edit)
	var list_header := HBoxContainer.new()
	list_header.custom_minimum_size.y = 28
	var id_header := Label.new()
	id_header.text = "ID"
	id_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_header.add_child(id_header)
	var image_header := Label.new()
	image_header.text = "Image"
	image_header.custom_minimum_size.x = 64
	list_header.add_child(image_header)
	var usage_header := Label.new()
	usage_header.text = "사용 여부"
	usage_header.custom_minimum_size.x = 120
	list_header.add_child(usage_header)
	details.add_child(list_header)
	var list_scroll := ScrollContainer.new()
	list_scroll.custom_minimum_size.y = 170
	list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	asset_list = VBoxContainer.new()
	asset_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	asset_list.mouse_filter = Control.MOUSE_FILTER_STOP
	list_scroll.add_child(asset_list)
	details.add_child(list_scroll)
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
	_add_form_label(form, "Visual Frames")
	visual_frames_spin = _new_spin(1, 999)
	form.add_child(visual_frames_spin)
	_add_form_label(form, "Visual Columns")
	visual_columns_spin = _new_spin(1, 999)
	form.add_child(visual_columns_spin)
	_add_form_label(form, "Visual Rows")
	visual_rows_spin = _new_spin(1, 999)
	form.add_child(visual_rows_spin)
	_add_form_label(form, "Frame Order")
	visual_frame_order_option = OptionButton.new()
	visual_frame_order_option.add_item("row_major")
	visual_frame_order_option.add_item("column_major")
	form.add_child(visual_frame_order_option)
	_add_form_label(form, "Anchor X")
	visual_anchor_x_spin = _new_spin(0.0, 1.0)
	visual_anchor_x_spin.step = 0.01
	visual_anchor_x_spin.value = 0.5
	form.add_child(visual_anchor_x_spin)
	_add_form_label(form, "Anchor Y")
	visual_anchor_y_spin = _new_spin(0.0, 1.0)
	visual_anchor_y_spin.step = 0.01
	visual_anchor_y_spin.value = 1.0
	form.add_child(visual_anchor_y_spin)
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
	_add_button(buttons, "Visual Asset 저장", _save_visual_asset)
	_add_button(buttons, "이름 변경", _rename_entry)
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
	source_dialog.add_theme_constant_override("thumbnail_size", int(ConfigRepository.get_editor_value("ui", "file_dialog_thumbnail_size", 112)))
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
	_select_asset_row(completed_index)

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

func _find_entry_index(asset_id: String) -> int:
	for index in range(entries.size()):
		if str(entries[index].get("asset_id", "")) == asset_id:
			return index
	return -1

func _load_visual_assets() -> void:
	visual_assets.clear()
	visual_asset_ids.clear()
	VisualAssetRepository.reload()
	for asset_id in VisualAssetRepository.list():
		var definition := VisualAssetRepository.get_asset(asset_id)
		if definition == null:
			continue
		visual_assets[asset_id] = definition.to_dict()
		visual_asset_ids.append(asset_id)
	visual_asset_ids.sort()

func _visual_asset_entry(asset_id: String, data: Dictionary) -> Dictionary:
	var region: Array = data.get("region", [0, 0, 0, 0])
	var display_name := str(data.get("display_name", ""))
	if display_name.is_empty():
		display_name = asset_id
	return {
		"asset_id": asset_id,
		"display_name": display_name,
		"kind": "visual_asset",
		"group": str(data.get("category", "Other")),
		"source_path": str(data.get("source", "")),
		"source_rect_px": region,
		"footprint_tiles": [1, 1],
		"frames": maxi(1, int(data.get("frames", 1))),
		"columns": maxi(1, int(data.get("columns", data.get("frames", 1)))),
		"rows": maxi(1, int(data.get("rows", 1))),
		"frame_order": str(data.get("frame_order", "row_major")),
		"anchor": data.get("anchor", {"mode": "BOTTOM_CENTER", "x": 0.5, "y": 1.0}),
		"frame_regions": data.get("frame_regions", []).duplicate(true) if data.get("frame_regions", []) is Array else [],
		"catalog_kind": "visual_asset"
	}

func _save_visual_asset() -> void:
	var asset_id := id_edit.text.strip_edges()
	var rect := _current_rect()
	if asset_id.is_empty() or source_path.is_empty() or rect.size.x <= 0 or rect.size.y <= 0:
		status_label.text = "Asset ID, project image, and a valid selected region are required."
		return
	_load_visual_assets()
	var previous: Dictionary = visual_assets.get(asset_id, {}).duplicate(true)
	if visual_assets.has(asset_id) and not selected_is_visual_asset:
		status_label.text = "Visual Asset ID already exists. Select it and use Update instead."
		return
	var definition := VisualAssetDefinition.from_dict(previous) if not previous.is_empty() else VisualAssetDefinition.new()
	definition.id = asset_id
	definition.category = "Robot" if asset_id.begins_with("robot.") else "Other"
	definition.source = source_path
	definition.region = Rect2(rect.position, rect.size)
	definition.frames = maxi(1, int(visual_frames_spin.value))
	definition.columns = maxi(1, int(visual_columns_spin.value))
	definition.rows = maxi(1, int(visual_rows_spin.value))
	definition.frame_order = "column_major" if visual_frame_order_option.selected == 1 else "row_major"
	definition.anchor_mode = "CUSTOM"
	definition.anchor_x = clampf(float(visual_anchor_x_spin.value), 0.0, 1.0)
	definition.anchor_y = clampf(float(visual_anchor_y_spin.value), 0.0, 1.0)
	definition.owner_id = str(previous.get("owner", ""))
	definition.usage = "visual_asset_catalog"
	if definition.frames > definition.columns * definition.rows:
		status_label.text = "Visual Frames cannot exceed Columns × Rows."
		return
	visual_assets[asset_id] = definition.to_dict()
	if not _write_visual_assets():
		status_label.text = "Visual Asset Catalog 저장에 실패했습니다."
		return
	_load_catalog()
	var new_index := _find_entry_index(asset_id)
	if new_index >= 0:
		_on_asset_selected(new_index)
	status_label.text = "Visual Asset 저장 완료: " + asset_id

func _write_visual_assets() -> bool:
	var path := "res://content/editor/visual_assets.json"
	if not ObjectPersistence.save_catalog(path, visual_assets):
		return false
	VisualAssetRepository.reload()
	VisualAssetResolver.reload()
	return true

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

func _rename_entry() -> void:
	if selected_is_visual_asset:
		_rename_visual_asset()
		return
	if selected_index < 0 or selected_index >= entries.size():
		status_label.text = "Select a catalog entry before changing its name."
		return
	var new_name := name_edit.text.strip_edges()
	if new_name.is_empty():
		status_label.text = "Enter a display name first."
		return
	entries[selected_index]["display_name"] = new_name
	_refresh_list()
	status_label.text = "Name changed. Save Catalog to persist the change."

func _rename_visual_asset() -> void:
	if selected_index < 0 or selected_index >= entries.size():
		status_label.text = "Select a Visual Asset first."
		return
	var old_id := str(entries[selected_index].get("asset_id", ""))
	var new_id := id_edit.text.strip_edges()
	if old_id.is_empty() or new_id.is_empty() or old_id == new_id:
		status_label.text = "Enter a new Visual Asset ID."
		return
	_load_visual_assets()
	if not visual_assets.has(old_id):
		status_label.text = "Visual Asset not found: " + old_id
		return
	if visual_assets.has(new_id):
		status_label.text = "Visual Asset ID already exists: " + new_id
		return
	var data: Dictionary = visual_assets[old_id]
	visual_assets.erase(old_id)
	data["id"] = new_id
	visual_assets[new_id] = data
	if not _write_visual_assets():
		status_label.text = "Visual Asset ID rename failed."
		return
	_load_catalog()
	var new_index := _find_entry_index(new_id)
	if new_index >= 0:
		_on_asset_selected(new_index)
	status_label.text = "Visual Asset ID changed: %s -> %s" % [old_id, new_id]

func _update_entry() -> void:
	if selected_is_visual_asset:
		_save_visual_asset()
		return
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
	_select_asset_row(selected_index)
	status_label.text = "Updated entry. Save Catalog to persist changes."

func _remove_entry() -> void:
	if selected_index < 0 or selected_index >= entries.size():
		status_label.text = "Select a catalog entry to remove."
		return
	if selected_is_visual_asset:
		var visual_id := str(entries[selected_index].get("asset_id", ""))
		_load_visual_assets()
		if visual_assets.has(visual_id):
			visual_assets.erase(visual_id)
			if not _write_visual_assets():
				status_label.text = "Visual Asset 삭제에 실패했습니다."
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
	selected_is_visual_asset = str(entries[index].get("catalog_kind", "")) == "visual_asset"
	var entry: Dictionary = entries[index]
	id_edit.text = str(entry.get("asset_id", ""))
	name_edit.text = str(entry.get("display_name", ""))
	kind_option.select(1 if str(entry.get("kind", "tile")) == "object" else 0)
	_refresh_group_options(str(entry.get("group", "")))
	var rect_values: Array = entry.get("source_rect_px", [0, 0, 0, 0])
	var rect := Rect2i(int(rect_values[0]), int(rect_values[1]), int(rect_values[2]), int(rect_values[3]))
	if selected_is_visual_asset:
		visual_frames_spin.value = maxi(1, int(entry.get("frames", 1)))
		visual_columns_spin.value = maxi(1, int(entry.get("columns", entry.get("frames", 1))))
		visual_rows_spin.value = maxi(1, int(entry.get("rows", 1)))
		visual_frame_order_option.select(1 if str(entry.get("frame_order", "row_major")) == "column_major" else 0)
		var anchor_data: Variant = entry.get("anchor", {})
		if anchor_data is Dictionary:
			visual_anchor_x_spin.value = clampf(float(anchor_data.get("x", 0.5)), 0.0, 1.0)
			visual_anchor_y_spin.value = clampf(float(anchor_data.get("y", 1.0)), 0.0, 1.0)
	else:
		visual_frames_spin.value = 1
		visual_columns_spin.value = 1
		visual_rows_spin.value = 1
		visual_frame_order_option.select(0)
		visual_anchor_x_spin.value = 0.5
		visual_anchor_y_spin.value = 1.0
	source_path = str(entry.get("source_path", ""))
	_load_source_for_entry(rect)
	_update_footprint_display(rect)
	var visual_meta_visible := selected_is_visual_asset
	visual_frames_spin.visible = visual_meta_visible
	visual_columns_spin.visible = visual_meta_visible
	visual_rows_spin.visible = visual_meta_visible
	visual_frame_order_option.visible = visual_meta_visible
	visual_anchor_x_spin.visible = visual_meta_visible
	visual_anchor_y_spin.visible = visual_meta_visible

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
	selected_is_visual_asset = false
	id_edit.clear()
	name_edit.clear()
	source_path = ""
	source_texture = null
	_set_source_preview(null)
	source_label.text = "No project image selected"
	region_view.set_source_texture(null)
	region_view.set("selected_region", Rect2i())
	visual_frames_spin.value = 1
	visual_columns_spin.value = 1
	visual_rows_spin.value = 1
	visual_frame_order_option.select(0)
	visual_anchor_x_spin.value = 0.5
	visual_anchor_y_spin.value = 1.0
	visual_frames_spin.visible = false
	visual_columns_spin.visible = false
	visual_rows_spin.visible = false
	visual_frame_order_option.visible = false
	visual_anchor_x_spin.visible = false
	visual_anchor_y_spin.visible = false
	_update_rect_label(Rect2i())
	_update_footprint_display(Rect2i())

func _sort_entries_by_name() -> void:
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_name := str(a.get("display_name", "")).strip_edges().to_lower()
		var b_name := str(b.get("display_name", "")).strip_edges().to_lower()
		if a_name == b_name:
			return str(a.get("asset_id", "")) < str(b.get("asset_id", ""))
		return a_name < b_name
	)

func _select_asset_row(index: int) -> void:
	if index < 0 or index >= entries.size():
		return
	selected_index = index
	for row in asset_list.get_children():
		if row.get_child_count() > 1 and row.get_child(1) is Button:
			var row_button: Button = row.get_child(1)
			row_button.button_pressed = row_button.get_meta("asset_index", -1) == index

func _on_asset_row_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		_on_asset_activated(index)

func _rebuild_usage_cache() -> void:
	usage_cache.clear()
	_scan_usage_directory("res://content")

func _scan_usage_directory(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	for file_name in dir.get_files():
		if not file_name.to_lower().ends_with(".json"):
			continue
		if file_name in ["asset_catalog.json", "visual_assets.json"]:
			continue
		var file_path := path.path_join(file_name)
		var file := FileAccess.open(file_path, FileAccess.READ)
		if file == null:
			continue
		var text := file.get_as_text()
		file.close()
		for asset_id in entries.map(func(value: Dictionary) -> String: return str(value.get("asset_id", ""))):
			if asset_id.is_empty() or not text.contains(asset_id):
				continue
			var refs: Array = usage_cache.get(asset_id, [])
			var short_name := file_name.get_basename()
			if not refs.has(short_name):
				refs.append(short_name)
			usage_cache[asset_id] = refs
	for directory_name in dir.get_directories():
		_scan_usage_directory(path.path_join(directory_name))

func _catalog_usage_text(entry: Dictionary) -> String:
	var asset_id := str(entry.get("asset_id", ""))
	if str(entry.get("catalog_kind", "")) == "visual_asset":
		_load_visual_assets()
		var data: Dictionary = visual_assets.get(asset_id, {})
		var owner := str(data.get("owner", ""))
		var usage := str(data.get("usage", ""))
		if not owner.is_empty():
			if not usage.is_empty() and usage != "visual_asset_catalog":
				return "사용중: %s / %s" % [owner, usage]
			return "사용중: %s" % owner
		if not usage.is_empty() and usage != "visual_asset_catalog":
			return "사용중: %s" % usage
	var refs: Array = usage_cache.get(asset_id, [])
	if refs.is_empty():
		return "미사용"
	return "사용중: %s" % ", ".join(PackedStringArray(refs))

func _build_asset_row(entry: Dictionary, index: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 68
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	asset_list.add_child(row)

	var text_button := Button.new()
	text_button.text = str(entry.get("asset_id", "?"))
	text_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_button.toggle_mode = true
	text_button.set_meta("asset_index", index)
	text_button.tooltip_text = "%s\nID: %s\n%s / %s" % [entry.get("source_path", ""), entry.get("asset_id", ""), str(entry.get("kind", "tile")).capitalize(), str(entry.get("group", "?"))]
	text_button.pressed.connect(func() -> void:
		_on_asset_selected(index)
		_select_asset_row(index)
	)
	text_button.gui_input.connect(func(event: InputEvent) -> void:
		_on_asset_row_gui_input(event, index)
	)
	row.add_child(text_button)

	var preview := TextureRect.new()
	preview.custom_minimum_size = Vector2(64, 64)
	preview.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.texture = _entry_preview_icon(entry)
	row.add_child(preview)

	var usage_label := Label.new()
	usage_label.text = _catalog_usage_text(entry)
	usage_label.custom_minimum_size.x = 120
	usage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	usage_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	usage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(usage_label)

func _refresh_list() -> void:
	var selected_asset_id := ""
	if selected_index >= 0 and selected_index < entries.size():
		selected_asset_id = str(entries[selected_index].get("asset_id", ""))
	_sort_entries_by_name()
	selected_index = -1
	if not selected_asset_id.is_empty():
		for index in range(entries.size()):
			if str(entries[index].get("asset_id", "")) == selected_asset_id:
				selected_index = index
				break
	for child in asset_list.get_children():
		child.queue_free()
	var query := search_edit.text.strip_edges().to_lower() if search_edit != null else ""
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		if not query.is_empty():
			var haystack := "%s %s %s %s" % [str(entry.get("asset_id", "")), str(entry.get("display_name", "")), str(entry.get("source_path", "")), str(entry.get("group", ""))]
			if not haystack.to_lower().contains(query):
				continue
		_build_asset_row(entry, index)
	if selected_index >= 0 and selected_index < entries.size():
		_select_asset_row(selected_index)

func _entry_preview_icon(entry: Dictionary) -> Texture2D:
	var is_visual_asset := str(entry.get("catalog_kind", "")) == "visual_asset"
	var value := str(entry.get("asset_id", "")) if is_visual_asset else str(entry.get("source_path", ""))
	var fallback_region := Rect2()
	var rect_values: Variant = entry.get("source_rect_px", [])
	if rect_values is Array and rect_values.size() == 4:
		fallback_region = Rect2(int(rect_values[0]), int(rect_values[1]), int(rect_values[2]), int(rect_values[3]))
	var fallback_frames := maxi(1, int(entry.get("frames", 1)))
	return EDITOR_THUMBNAIL_UTIL.create(value, fallback_region, fallback_frames)

func _load_catalog() -> void:
	entries.clear()
	selected_index = -1
	usage_cache.clear()
	_load_visual_assets()
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
	var visual_index := 0
	while visual_index < visual_asset_ids.size():
		var visual_id := visual_asset_ids[visual_index]
		entries.append(_visual_asset_entry(visual_id, visual_assets.get(visual_id, {})))
		visual_index += 1
	_rebuild_usage_cache()
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
	var catalog_assets: Array[Dictionary] = []
	for entry in entries:
		if str(entry.get("catalog_kind", "")) != "visual_asset":
			catalog_assets.append(entry.duplicate(true))
	file.store_string(JSON.stringify({"schema_version": 1, "assets": catalog_assets}, "	") + "\n")
	file.close()
	status_label.text = "Saved %d catalog assets to %s" % [catalog_assets.size(), CATALOG_PATH]
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

func _on_search_changed(text: String) -> void:
	_refresh_list()
	if text.strip_edges().is_empty():
		return
	if asset_list.get_child_count() == 0:
		id_edit.text = text.strip_edges()
		selected_index = -1
		selected_is_visual_asset = true
		status_label.text = "새 Visual Asset ID: %s / 이미지를 선택하고 Visual Asset 저장을 누르세요." % text.strip_edges()
