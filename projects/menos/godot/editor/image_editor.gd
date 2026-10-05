extends Control
const REGION_VIEW_SCRIPT := preload("res://editor/asset_region_view.gd")
const LOADER := preload("res://editor/image_texture_loader.gd")
const IMAGE_STATE := preload("res://editor/image_editor_state.gd")
const EDITED_DIR := "res://content/editor/edited_assets"
const EDITOR_THUMBNAIL_UTIL = preload("res://scripts/editor_thumbnail_util.gd")

var entries: Array[Dictionary] = []
var list: ItemList
var catalog_tree: Tree
var source_list: ItemList
var view: AssetRegionView
var status: Label
var current_index := -1
var register_selected_asset_button: Button
var originating_asset_id := ""
var catalog_target_index := -1
var current_path := ""
var current_image: Image
var source_index := -1
var source_path := ""
var source_image: Image
var source_dialog: FileDialog
var target_dialog: FileDialog
var source_thumbnail_cache: Dictionary = {}
var target_thumbnail_cache: Dictionary = {}
var editing := false
var background_color_button: ColorPickerButton
var background_tolerance_spin: SpinBox
var background_connected_only_check: CheckBox
var usage_label: Label
var filter_option: OptionButton
var search_edit: LineEdit
var columns_spin: SpinBox
var rows_spin: SpinBox
var frames_spin: SpinBox
var frame_order_option: OptionButton
var anchor_mode_option: OptionButton
var anchor_x_spin: SpinBox
var anchor_y_spin: SpinBox
var grid_status: Label
var frame_transform_status: Label
var frame_index_spin: SpinBox
var frame_x_spin: SpinBox
var frame_y_spin: SpinBox
var frame_scale_spin: SpinBox
var frame_transform_base: Image
var frame_transform_active_index := -1
var frame_transform_values: Dictionary = {}
var frame_transform_syncing := false
var frame_select_mode := false
var filtered_indices: Array[int] = []

signal request_content_editor
signal request_previous_editor

func _request_content_editor() -> void:
	request_content_editor.emit()

func _request_previous_editor() -> void:
	IMAGE_STATE.cancel_selection()
	request_previous_editor.emit()

func _use_selected_asset() -> void:
	if current_path.is_empty():
		status.text = "No Visual Asset is selected. Use the Catalog to select an asset."
		return
	if not IMAGE_STATE.selection_pending:
		status.text = "The selected Asset is not in an editable state."
		return
	var asset_id := IMAGE_STATE.selection_asset_id
	if asset_id.is_empty():
		var resolved := VisualAssetResolver.resolve(current_path)
		if resolved != null:
			asset_id = resolved.id
	if asset_id.is_empty():
		status.text = "No Visual Asset is selected."
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "Select a valid region before using this asset."
		return
	if not _update_visual_asset_region(asset_id, current_path, rect):
		status.text = "Could not update Visual Asset: %s" % asset_id
		return
	VisualAssetResolver.reload()
	# Rebuild the Catalog entry cache before returning to the previous editor.
	# The thumbnail list is populated from the scanned entry data, so leaving the
	# old entries in memory would keep the previous region visible until restart.
	_scan_connected_images()
	_select_asset_id(asset_id)
	IMAGE_STATE.apply_selection(asset_id)
	request_previous_editor.emit()

func _update_visual_asset_region(asset_id: String, source_path_value: String, rect: Rect2i) -> bool:
	var path := "res://content/editor/visual_assets.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary or not data.has(asset_id) or not data[asset_id] is Dictionary:
		return false
	var asset: Dictionary = data[asset_id]
	asset["source"] = source_path_value
	asset["region"] = [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
	data[asset_id] = asset
	return _write_json(path, data)

func _ready() -> void:
	# Snapshot the semantic ID supplied by the originating editor. Catalog browsing
	# must not be able to replace or clear the registration identity.
	originating_asset_id = IMAGE_STATE.selection_asset_id.strip_edges()
	_build_ui()
	_scan_connected_images()
	_sync_register_selected_asset_button()
	if not originating_asset_id.is_empty():
		_select_asset_id(originating_asset_id)
	elif not IMAGE_STATE.selected_path.is_empty():
		_select_path(IMAGE_STATE.selected_path)

func _sync_register_selected_asset_button() -> void:
	if register_selected_asset_button == null:
		return
	register_selected_asset_button.disabled = originating_asset_id.is_empty()

func _select_asset_id(asset_id: String) -> void:
	_sync_register_selected_asset_button()
	if asset_id.is_empty():
		return
	for visible_index in range(filtered_indices.size()):
		var entry_index := filtered_indices[visible_index]
		var entry: Dictionary = entries[entry_index]
		if str(entry.get("owner_kind", "")) == "visual_asset" and str(entry.get("owner_key", "")) == asset_id:
			if catalog_tree.visible:
				var row := catalog_tree.get_root()
				if row != null:
					row = row.get_first_child()
					while row != null:
						if int(row.get_metadata(0)) == entry_index:
							row.select(0)
							_select_entry_index(entry_index)
							return
						row = row.get_next()
			else:
				list.select(visible_index)
				_select_entry(visible_index)
			return
	# Keep the current source-path fallback if the requested Visual Asset is unavailable.
	_select_path(IMAGE_STATE.selected_path)

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var title_row := HBoxContainer.new()
	root.add_child(title_row)
	var title := Label.new()
	title.text = "Catalog Editor"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title_row.add_child(title)
	var previous_button := Button.new()
	previous_button.text = "Previous Editor"
	previous_button.pressed.connect(_request_previous_editor)
	title_row.add_child(previous_button)
	previous_button.visible = false
	var content_button := Button.new()
	content_button.text = "Content Editor"
	content_button.pressed.connect(_request_content_editor)
	title_row.add_child(content_button)
	content_button.visible = false
	var intro := Label.new()
	intro.text = "Choose a Source Image, then drag to select a region or register it as a Visual Asset."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(intro)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	var left := VBoxContainer.new()
	# Catalog browser: keep thumbnail cells uniform so very large source images do not dominate the list.
	left.custom_minimum_size.x = 420
	body.add_child(left)
	var list_title := Label.new()
	list_title.text = "Catalog Editor"
	left.add_child(list_title)
	var search_row := HBoxContainer.new()
	left.add_child(search_row)
	search_edit = LineEdit.new()
	search_edit.placeholder_text = "Search image / project / category"
	search_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_edit.text_changed.connect(func(_text: String): _refresh_entry_list())
	search_row.add_child(search_edit)
	filter_option = OptionButton.new()
	for filter_name in ["All", "Catalog", "Map", "Unit", "Robot", "Tower", "Enemy", "Runtime"]:
		filter_option.add_item(filter_name)
	filter_option.select(1)
	filter_option.item_selected.connect(func(_index: int): _refresh_entry_list())
	search_row.add_child(filter_option)
	list = ItemList.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Use a fixed thumbnail box and grid so large/small source images have equal visual weight.
	list.icon_mode = ItemList.ICON_MODE_TOP
	list.fixed_icon_size = Vector2i(140, 100)
	list.fixed_column_width = 190
	list.max_text_lines = 2
	list.item_selected.connect(_select_entry)
	left.add_child(list)
	catalog_tree = Tree.new()
	catalog_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	catalog_tree.columns = 3
	catalog_tree.hide_root = true
	catalog_tree.set_column_title(0, "ID")
	catalog_tree.set_column_title(1, "Image")
	catalog_tree.set_column_title(2, "사용 여부")
	catalog_tree.set_column_titles_visible(true)
	catalog_tree.set_column_expand(0, true)
	catalog_tree.set_column_expand(1, false)
	catalog_tree.set_column_expand(2, true)
	catalog_tree.set_column_custom_minimum_width(0, 180)
	catalog_tree.set_column_custom_minimum_width(1, 72)
	catalog_tree.set_column_custom_minimum_width(2, 150)
	catalog_tree.item_selected.connect(_select_catalog_tree_entry)
	left.add_child(catalog_tree)
	catalog_tree.visible = false
	var clear_selection := Button.new()
	clear_selection.text = "Clear Selection"
	clear_selection.pressed.connect(_clear_image_selection)
	left.add_child(clear_selection)
	var use_selected_button := Button.new()
	use_selected_button.text = "Use Selected Asset"
	use_selected_button.pressed.connect(_use_selected_asset)
	left.add_child(use_selected_button)
	var open_target_button := Button.new()
	open_target_button.text = "Open Source Image"
	open_target_button.pressed.connect(_open_target_dialog)
	left.add_child(open_target_button)
	var reconnect_target_button := Button.new()
	reconnect_target_button.text = "Reconnect to Previous Editor"
	reconnect_target_button.pressed.connect(_reconnect_current_to_selected_entry)
	left.add_child(reconnect_target_button)
	reconnect_target_button.visible = false
	register_selected_asset_button = Button.new()
	register_selected_asset_button.text = "Register Selected Visual Asset"
	register_selected_asset_button.disabled = originating_asset_id.is_empty()
	register_selected_asset_button.pressed.connect(_create_visual_asset_from_selection)
	left.add_child(register_selected_asset_button)
	var delete_visual_asset_button := Button.new()
	delete_visual_asset_button.text = "Delete Visual Asset"
	delete_visual_asset_button.pressed.connect(_confirm_delete_visual_asset)
	left.add_child(delete_visual_asset_button)
	var full_catalog_button := Button.new()
	full_catalog_button.text = "Register All PNGs as Visual Assets"
	full_catalog_button.pressed.connect(_create_visual_asset_from_full_image)
	left.add_child(full_catalog_button)
	full_catalog_button.visible = false
	var audit_button := Button.new()
	audit_button.text = "Audit Image References"
	audit_button.pressed.connect(_audit_image_references)
	left.add_child(audit_button)
	audit_button.visible = false
	var source_panel := VBoxContainer.new()
	source_panel.custom_minimum_size.x = 280
	body.add_child(source_panel)
	source_panel.visible = false
	var source_title := Label.new()
	source_title.text = "Source Image"
	source_panel.add_child(source_title)
	source_list = ItemList.new()
	source_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	source_list.item_selected.connect(_select_source_entry)
	source_panel.add_child(source_list)
	var source_help := Label.new()
	source_help.text = "Select a Source Image or Asset, then choose a region."
	source_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	source_panel.add_child(source_help)
	var source_full := Button.new()
	source_full.text = "Use Full Source"
	source_full.pressed.connect(_replace_from_source_full)
	source_panel.add_child(source_full)
	var source_open := Button.new()
	source_open.text = "Open Source Image"
	source_open.pressed.connect(_open_source_dialog)
	source_panel.add_child(source_open)
	var source_region := Button.new()
	source_region.text = "Use Selected Region"
	source_region.pressed.connect(_replace_from_source_region)
	source_panel.add_child(source_region)
	var normalize := Button.new()
	normalize.name = "NormalizeUnitButton"
	normalize.text = "Normalize Selection"
	normalize.pressed.connect(_replace_source_region_as_unit)
	source_panel.add_child(normalize)
	var source_reference := Button.new()
	source_reference.text = "Use Previous Editor Source"
	source_reference.pressed.connect(_apply_source_region_reference)
	source_panel.add_child(source_reference)
	source_dialog = FileDialog.new()
	source_dialog.title = "Open Source Image"
	source_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	source_dialog.access = FileDialog.ACCESS_RESOURCES
	source_dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp,*.bmp ; Image files"])
	source_dialog.display_mode = FileDialog.DISPLAY_THUMBNAILS
	source_dialog.add_theme_constant_override("thumbnail_size", int(ConfigRepository.get_editor_value("ui", "file_dialog_thumbnail_size", 112)))
	FileDialog.set_get_thumbnail_callback(Callable(self, "_get_source_thumbnail"))
	source_dialog.current_dir = "res://"
	source_dialog.file_selected.connect(_on_source_file_selected)
	add_child(source_dialog)
	target_dialog = FileDialog.new()
	target_dialog.title = "Open Target Image"
	target_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	target_dialog.access = FileDialog.ACCESS_RESOURCES
	target_dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp,*.bmp ; Image files"])
	target_dialog.display_mode = FileDialog.DISPLAY_THUMBNAILS
	target_dialog.add_theme_constant_override("thumbnail_size", int(ConfigRepository.get_editor_value("ui", "file_dialog_thumbnail_size", 112)))
	FileDialog.set_get_thumbnail_callback(Callable(self, "_get_target_thumbnail"))
	target_dialog.current_dir = "res://"
	target_dialog.file_selected.connect(_on_target_file_selected)
	add_child(target_dialog)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	usage_label = Label.new()
	usage_label.text = "Asset Usage"
	usage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	usage_label.add_theme_font_size_override("font_size", 16)
	right.add_child(usage_label)
	view = REGION_VIEW_SCRIPT.new()
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view.frame_selected.connect(_on_frame_selected)
	right.add_child(view)
	var tools := HBoxContainer.new()
	right.add_child(tools)
	_add_button(tools, "Erase", _start_erase)
	_add_button(tools, "Crop Selection", _crop_selection)
	_add_button(tools, "Flip Horizontal", _flip_h)
	_add_button(tools, "Flip Vertical", _flip_v)
	_add_button(tools, "Rotate Clockwise", _rotate_cw)
	_add_button(tools, "Rotate Counterclockwise", _rotate_ccw)
	_add_button(tools, "Trim Transparent Pixels", _trim_alpha)
	_add_button(tools, "Save + Reconnect", _save_reconnect)
	var bg_row := HBoxContainer.new()
	right.add_child(bg_row)
	var bg_label := Label.new()
	bg_label.text = "Background"
	bg_row.add_child(bg_label)
	background_color_button = ColorPickerButton.new()
	background_color_button.color = Color.WHITE
	background_color_button.tooltip_text = "투명 처리할 배경색"
	bg_row.add_child(background_color_button)
	var bg_tolerance_label := Label.new()
	bg_tolerance_label.text = "Tolerance"
	bg_row.add_child(bg_tolerance_label)
	background_tolerance_spin = SpinBox.new()
	background_tolerance_spin.min_value = 0.0
	background_tolerance_spin.max_value = 1.0
	background_tolerance_spin.step = 0.01
	background_tolerance_spin.value = 0.08
	background_tolerance_spin.custom_minimum_size.x = 90
	bg_row.add_child(background_tolerance_spin)
	background_connected_only_check = CheckBox.new()
	background_connected_only_check.text = "Edge-connected only"
	background_connected_only_check.tooltip_text = "선택 색상과 가까우면서 이미지 가장자리와 연결된 영역만 투명 처리"
	bg_row.add_child(background_connected_only_check)
	var bg_apply := Button.new()
	bg_apply.text = "Remove Background Color"
	bg_apply.pressed.connect(_remove_background_color)
	bg_row.add_child(bg_apply)
	var resize_row := HBoxContainer.new()
	right.add_child(resize_row)
	var resize_label := Label.new()
	resize_label.text = "Size"
	resize_row.add_child(resize_label)
	var width_spin := SpinBox.new()
	width_spin.name = "WidthSpin"
	width_spin.min_value = 1
	width_spin.max_value = 4096
	width_spin.step = 1
	resize_row.add_child(width_spin)
	var height_spin := SpinBox.new()
	height_spin.name = "HeightSpin"
	height_spin.min_value = 1
	height_spin.max_value = 4096
	height_spin.step = 1
	resize_row.add_child(height_spin)
	var resize_btn := Button.new()
	resize_btn.text = "Apply Size"
	resize_btn.pressed.connect(func(): _resize_image(int(width_spin.value), int(height_spin.value)))
	resize_row.add_child(resize_btn)
	var grid_title := Label.new()
	grid_title.text = "Sprite Sheet Grid / Anchor"
	grid_title.add_theme_font_size_override("font_size", 16)
	right.add_child(grid_title)
	var grid_row := HBoxContainer.new()
	right.add_child(grid_row)
	columns_spin = _make_grid_spin("Columns", 1, 128, 1)
	grid_row.add_child(columns_spin)
	rows_spin = _make_grid_spin("Rows", 1, 128, 1)
	grid_row.add_child(rows_spin)
	frames_spin = _make_grid_spin("Frames", 1, 4096, 1)
	grid_row.add_child(frames_spin)
	var order_label := Label.new()
	order_label.text = "Order"
	grid_row.add_child(order_label)
	frame_order_option = OptionButton.new()
	frame_order_option.add_item("Row Major", 0)
	frame_order_option.add_item("Column Major", 1)
	grid_row.add_child(frame_order_option)
	var anchor_row := HBoxContainer.new()
	right.add_child(anchor_row)
	var anchor_label := Label.new()
	anchor_label.text = "Anchor"
	anchor_row.add_child(anchor_label)
	anchor_mode_option = OptionButton.new()
	anchor_mode_option.add_item("BOTTOM_CENTER", 0)
	anchor_mode_option.add_item("CENTER", 1)
	anchor_mode_option.add_item("CENTER_LEFT", 2)
	anchor_mode_option.add_item("BOTTOM_LEFT", 3)
	anchor_mode_option.add_item("CUSTOM", 4)
	anchor_row.add_child(anchor_mode_option)
	anchor_x_spin = _make_grid_spin("X", 0.0, 1.0, 0.01)
	anchor_x_spin.step = 0.01
	anchor_row.add_child(anchor_x_spin)
	anchor_y_spin = _make_grid_spin("Y", 0.0, 1.0, 0.01)
	anchor_y_spin.step = 0.01
	anchor_row.add_child(anchor_y_spin)
	var apply_grid_button := Button.new()
	apply_grid_button.text = "Apply Grid / Anchor"
	apply_grid_button.pressed.connect(_apply_grid_metadata)
	anchor_row.add_child(apply_grid_button)
	grid_status = Label.new()
	grid_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(grid_status)
	var frame_transform_title := Label.new()
	frame_transform_title.text = "Frame Transform"
	frame_transform_title.add_theme_font_size_override("font_size", 16)
	right.add_child(frame_transform_title)
	var frame_select_button := Button.new()
	frame_select_button.text = "Frame Select: OFF"
	frame_select_button.toggle_mode = true
	frame_select_button.toggled.connect(func(enabled: bool):
		frame_select_mode = enabled
		frame_select_button.text = "Frame Select: ON" if enabled else "Frame Select: OFF"
		view.set_frame_select_mode(enabled)
	)
	right.add_child(frame_select_button)
	var frame_transform_help := Label.new()
	frame_transform_help.text = "Frame Select ON: click a frame, then use Arrow keys to move it. Shift = 10 px."
	frame_transform_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(frame_transform_help)
	var frame_transform_row := HBoxContainer.new()
	right.add_child(frame_transform_row)
	var frame_label := Label.new()
	frame_label.text = "Frame"
	frame_transform_row.add_child(frame_label)
	frame_index_spin = _make_grid_spin("Frame", 1, 4096, 1)
	frame_index_spin.value = 1
	frame_index_spin.value_changed.connect(_on_frame_transform_changed)
	frame_transform_row.add_child(frame_index_spin)
	var x_label := Label.new()
	x_label.text = "X"
	frame_transform_row.add_child(x_label)
	frame_x_spin = _make_grid_spin("X", -4096, 4096, 1)
	frame_x_spin.value_changed.connect(_on_frame_transform_changed)
	frame_transform_row.add_child(frame_x_spin)
	var y_label := Label.new()
	y_label.text = "Y"
	frame_transform_row.add_child(y_label)
	frame_y_spin = _make_grid_spin("Y", -4096, 4096, 1)
	frame_y_spin.value_changed.connect(_on_frame_transform_changed)
	frame_transform_row.add_child(frame_y_spin)
	var scale_label := Label.new()
	scale_label.text = "%"
	frame_transform_row.add_child(scale_label)
	frame_scale_spin = _make_grid_spin("Scale", 10, 400, 1)
	frame_scale_spin.value = 100
	frame_scale_spin.value_changed.connect(_on_frame_transform_changed)
	frame_transform_row.add_child(frame_scale_spin)
	var reset_frame_button := Button.new()
	reset_frame_button.text = "Reset"
	reset_frame_button.pressed.connect(_reset_frame_transform)
	frame_transform_row.add_child(reset_frame_button)
	frame_transform_status = Label.new()
	frame_transform_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(frame_transform_status)
	status = Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status)
	_refresh_entry_list()

func _make_grid_spin(label_text: String, min_value: float, max_value: float, step_value: float) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.step = step_value
	spin.custom_minimum_size.x = 78
	spin.tooltip_text = label_text
	return spin

func _add_button(parent: HBoxContainer, text_value: String, callback: Callable) -> void:
	var b := Button.new()
	b.text = text_value
	b.pressed.connect(callback)
	parent.add_child(b)

func _scan_connected_images() -> void:
	entries.clear()
	var seen := {}
	_scan_json_images("res://content/towers/towers.json", "towers", "sprite_anim", "Tower sprite animation", "Tower", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "Allied Unit", "visuals.sprite", "Sprite", "Unit", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "Allied Unit", "visuals.default_image", "Profile Image", "Unit", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "Allied Unit", "projectile_anim", "Projectile", "Unit", seen)
	_scan_json_images("res://content/enemies/enemies.json", "Enemy", "sprite_anim", "Sprite", "Enemy", seen)
	_scan_json_images("res://content/enemies/enemies.json", "Enemy", "projectile_anim", "Projectile", "Enemy", seen)
	_scan_allied_animations(seen)
	_scan_robot_images(seen)
	_scan_catalog(seen)
	_scan_visual_assets(seen)
	_refresh_visual_asset_usage_from_robot_refs()
	_scan_main_preloads(seen)
	list.clear()
	catalog_tree.clear()
	source_list.clear()
	_refresh_entry_list()
	var catalog_count := 0
	for entry in entries:
		if str(entry.get("owner_kind", "")) == "visual_asset":
			catalog_count += 1
	status.text = "%d Visual Assets registered." % catalog_count

func _refresh_entry_list() -> void:
	if list == null or source_list == null:
		return
	filtered_indices.clear()
	list.clear()
	catalog_tree.clear()
	source_list.clear()
	var catalog_root := catalog_tree.create_item()
	var query := search_edit.text.strip_edges().to_lower() if search_edit else ""
	var filter_name := filter_option.get_item_text(filter_option.selected) if filter_option and filter_option.selected >= 0 else "All"
	catalog_tree.visible = true
	list.visible = false
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var category := str(entry.get("category", "Other"))
		var is_catalog_entry := str(entry.get("owner_kind", "")) == "visual_asset"
		if filter_name == "Catalog" and not is_catalog_entry:
			continue
		if filter_name != "All" and filter_name != "Catalog" and category != filter_name:
			continue
		if not query.is_empty():
			var haystack := (str(entry.get("label", "")) + " " + str(entry.get("path", "")) + " " + str(entry.get("usage", "")) + " " + str(entry.get("owner", ""))).to_lower()
			if not haystack.contains(query):
				continue
		filtered_indices.append(index)
		var icon: Texture2D = _get_catalog_thumbnail(entry) if is_catalog_entry else load(str(entry.get("path", ""))) as Texture2D
		var display_id := str(entry.get("owner_key", ""))
		if display_id.is_empty():
			display_id = str(entry.get("label", "Asset"))
		if not is_catalog_entry:
			var field := str(entry.get("field", ""))
			if not field.is_empty():
				display_id = "%s.%s" % [display_id, field]
		var usage_text := _visual_asset_usage_text(entry) if is_catalog_entry else str(entry.get("usage", ""))
		if usage_text.is_empty():
			usage_text = "미사용"
		var row := catalog_tree.create_item(catalog_root)
		row.set_metadata(0, index)
		row.set_text(0, display_id)
		row.set_editable(0, false)
		row.set_icon(1, icon)
		row.set_text(2, usage_text)
		row.set_icon_max_width(1, 64)
		row.set_tooltip_text(0, str(entry.get("label", "Asset")) + "\nID: " + display_id)
		row.set_tooltip_text(1, str(entry.get("path", "")))
		source_list.add_item("[%s] %s" % [category, str(entry.get("label", "Asset"))], icon)
		source_list.set_item_metadata(source_list.item_count - 1, index)

func _visual_asset_usage_text(entry: Dictionary) -> String:
	var owner := str(entry.get("asset_owner", ""))
	var usage := str(entry.get("asset_usage", ""))
	if owner.is_empty():
		return "No Usage"
	if usage.is_empty():
		return "Owner: %s" % owner
	return "Owner: %s / %s" % [owner, usage]

func _select_catalog_tree_entry() -> void:
	if editing or catalog_tree == null:
		return
	var selected := catalog_tree.get_selected()
	if selected == null:
		return
	var entry_index := int(selected.get_metadata(0))
	if entry_index < 0 or entry_index >= entries.size():
		return
	current_index = entry_index
	_select_entry_index(entry_index)

func _rename_catalog_tree_item() -> void:
	if editing or catalog_tree == null:
		return
	var selected := catalog_tree.get_selected()
	if selected == null:
		return
	var entry_index := int(selected.get_metadata(0))
	if entry_index < 0 or entry_index >= entries.size():
		return
	var entry: Dictionary = entries[entry_index]
	if str(entry.get("owner_kind", "")) != "visual_asset":
		selected.set_text(0, str(entry.get("owner_key", entry.get("label", "Asset"))))
		return
	var old_id := str(entry.get("owner_key", ""))
	var new_id := selected.get_text(0).strip_edges()
	if new_id.is_empty() or old_id == new_id:
		selected.set_text(0, old_id)
		return
	if not _rename_visual_asset_id(old_id, new_id):
		selected.set_text(0, old_id)
		return
	_scan_connected_images()
	_select_asset_id(new_id)

func _rename_visual_asset_id(old_id: String, new_id: String) -> bool:
	if old_id.is_empty() or new_id.is_empty():
		status.text = "Visual Asset ID is required."
		return false
	if new_id.find("/") >= 0 or new_id.find("\\") >= 0:
		status.text = "Visual Asset ID contains invalid characters."
		return false
	var catalog_path := "res://content/editor/visual_assets.json"
	var file := FileAccess.open(catalog_path, FileAccess.READ)
	if file == null:
		status.text = "Visual Asset Catalog could not be loaded."
		return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary or not data.has(old_id):
		status.text = "Visual Asset not found: " + old_id
		return false
	if data.has(new_id):
		status.text = "Visual Asset ID already exists: " + new_id
		return false
	var asset: Dictionary = data[old_id]
	data.erase(old_id)
	asset["id"] = new_id
	data[new_id] = asset
	if not _write_json(catalog_path, data):
		status.text = "Visual Asset ID saved."
		return false
	VisualAssetResolver.reload()
	if IMAGE_STATE.selection_asset_id == old_id:
		IMAGE_STATE.selection_asset_id = new_id
	status.text = "Visual Asset ID: %s -> %s" % [old_id, new_id]
	return true

func _get_catalog_thumbnail(entry: Dictionary) -> Texture2D:
	var value := str(entry.get("owner_key", "")) if str(entry.get("owner_kind", "")) == "visual_asset" else str(entry.get("path", ""))
	var fallback_region := _entry_region(entry)
	var fallback_frames := maxi(1, int(entry.get("frames", 1)))
	return EDITOR_THUMBNAIL_UTIL.create(value, fallback_region, fallback_frames)

func _audit_image_references() -> void:
	var missing: Array[String] = []
	var invalid: Array[String] = []
	for entry in entries:
		var image_path := str(entry.get("path", ""))
		if image_path.is_empty():
			continue
		if not ResourceLoader.exists(image_path):
			missing.append("%s | %s" % [str(entry.get("label", "Asset")), image_path])
			continue
		var texture := load(image_path) as Texture2D
		if texture == null:
			invalid.append("%s | %s" % [str(entry.get("label", "Asset")), image_path])
	var report := "Image Reference Audit\n\nTotal entries: %d\nMissing: %d\nInvalid: %d" % [entries.size(), missing.size(), invalid.size()]
	if not missing.is_empty():
		report += "\n\n[Missing References]\n" + "\n".join(missing)
	if not invalid.is_empty():
		report += "\n\n[Invalid References]\n" + "\n".join(invalid)
	if missing.is_empty() and invalid.is_empty():
		report += "\n\nNo missing or invalid image references were found."
	var dialog := AcceptDialog.new()
	dialog.title = "Image Reference Audit"
	dialog.dialog_text = report
	dialog.ok_button_text = "OK"
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(760, 520))

func _scan_json_images(path: String, kind: String, field: String, usage: String, category: String, seen: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return
	for key in data:
		if not data[key] is Dictionary: continue
		var value: Variant = data[key]
		for part in field.split("."):
			if value is Dictionary:
				value = value.get(part, "")
			else:
				value = ""
		var image_path := str(value)
		if image_path.is_empty(): continue
		if not ResourceLoader.exists(image_path):
			var alias_path := "res://assets/menos/sprites/%s.png" % image_path
			if ResourceLoader.exists(alias_path):
				image_path = alias_path
		if seen.has(image_path): continue
		seen[image_path] = true
		entries.append({"label": "%s / %s" % [kind, str(data[key].get("name", key))], "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": field, "usage": usage, "category": category})

func _scan_allied_animations(seen: Dictionary) -> void:
	var path := "res://content/allied_units/allied_units.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return
	for key in data:
		if not data[key] is Dictionary: continue
		var visuals: Dictionary = data[key].get("visuals", {})
		if not visuals is Dictionary: continue
		var animations: Dictionary = visuals.get("animations", {})
		if not animations is Dictionary: continue
		for animation_name in animations:
			var image_path := str(animations[animation_name])
			if image_path.is_empty() or seen.has(image_path): continue
			seen[image_path] = true
			entries.append({"label": "Unit / %s / %s" % [str(data[key].get("name", key)), str(animation_name)], "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": "visuals.animations." + str(animation_name), "usage": "Unit animation %s" % str(animation_name), "category": "Unit"})

func _scan_robot_images(seen: Dictionary) -> void:
	var path := "res://content/robots/robots.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return
	for key in data:
		if not data[key] is Dictionary: continue
		var robot_name := str(data[key].get("name", key))
		for field in ["sprite_idle", "sprite_attack", "sprite_move", "sprite_skill", "default_image", "projectile_anim"]:
			var image_path := str(data[key].get(field, ""))
			if VisualAssetResolver.get_asset(image_path) != null:
				continue
			if image_path.is_empty() or seen.has(image_path): continue
			seen[image_path] = true
			var usage := "Robot asset"
			match field:
				"sprite_attack": usage = "Robot attack"
				"default_image": usage = "Profile Image"
				"sprite_move": usage = "Robot move"
				"sprite_skill": usage = "Robot skill"
				"projectile_anim": usage = "Robot projectile"
			entries.append({"label": "Robot / %s" % robot_name, "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": field, "usage": usage, "category": "Robot"})
		var animations: Dictionary = data[key].get("animations", {})
		if animations is Dictionary:
			for animation_name in animations:
				var animation_path := str(animations[animation_name])
				if VisualAssetResolver.get_asset(animation_path) != null:
					continue
				if animation_path.is_empty() or seen.has(animation_path): continue
				seen[animation_path] = true
				entries.append({"label": "Robot / %s / %s" % [robot_name, str(animation_name)], "path": animation_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": "animations." + str(animation_name), "usage": "Robot animation %s" % str(animation_name), "category": "Robot"})

func _scan_catalog(seen: Dictionary) -> void:
	var path := "res://content/editor/asset_catalog.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return
	var assets: Array = data.get("assets", [])
	for asset in assets:
		if not asset is Dictionary: continue
		var image_path := str(asset.get("source_path", ""))
		if image_path.is_empty() or seen.has(image_path): continue
		seen[image_path] = true
		entries.append({"label": "Allied Unit / %s" % str(asset.get("display_name", asset.get("asset_id", "Asset"))), "path": image_path, "owner": path, "owner_kind": "catalog", "owner_key": str(asset.get("asset_id", "")), "field": "source_path", "usage": "%s / %s" % [str(asset.get("group", "Unit")), str(asset.get("kind", "asset"))], "category": "Map"})
func _scan_visual_assets(seen: Dictionary) -> void:
	var path := "res://content/editor/visual_assets.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary:
		return
	for asset_id in data:
		var asset = data[asset_id]
		if not asset is Dictionary:
			continue
		var image_path := str(asset.get("source", ""))
		if image_path.is_empty():
			continue
		# Visual Assets are distinct catalog entries even when they share a source image.
		var region_data: Array = asset.get("region", [])
		var region_text := ""
		if region_data.size() >= 4:
			region_text = " [%s,%s %sx%s]" % [region_data[0], region_data[1], region_data[2], region_data[3]]
		entries.append({
			"label": "Visual Asset / %s" % str(asset.get("id", asset_id)),
			"path": image_path,
			"region": region_data,
			"frames": maxi(1, int(asset.get("frames", 1))),
			"columns": maxi(1, int(asset.get("columns", asset.get("frames", 1)))),
			"rows": maxi(1, int(asset.get("rows", 1))),
			"frame_order": str(asset.get("frame_order", "row_major")),
			"anchor": asset.get("anchor", {"mode": "BOTTOM_CENTER", "x": 0.5, "y": 1.0}),
			"owner": path,
			"owner_kind": "visual_asset",
			"owner_key": str(asset_id),
			"field": "source",
			"usage": "Visual Asset%s" % region_text,
			"asset_owner": str(asset.get("owner", "")),
			"asset_usage": str(asset.get("usage", "")),
			"category": str(asset.get("category", "Other"))
		})

func _refresh_visual_asset_usage_from_robot_refs() -> void:
	var path := "res://content/robots/robots.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary:
		return
	var usage_by_asset: Dictionary = {}
	for robot_key in data:
		if not data[robot_key] is Dictionary:
			continue
		var robot: Dictionary = data[robot_key]
		var robot_name := str(robot.get("name", robot_key))
		var usages: Array[String] = []
		var fields := {
			"default_image": "profile",
			"sprite_idle": "idle",
			"sprite_move": "move",
			"sprite_attack": "attack",
			"sprite_skill": "skill",
			"projectile_anim": "projectile"
		}
		for field in fields:
			var asset_id := str(robot.get(field, "")).strip_edges()
			if asset_id.is_empty():
				continue
			var usage_name := str(fields[field])
			if not usages.has(usage_name):
				usages.append(usage_name)
			usage_by_asset[asset_id] = str(usage_by_asset.get(asset_id, ""))
			if not usage_by_asset[asset_id].is_empty():
				usage_by_asset[asset_id] += ", "
			usage_by_asset[asset_id] += "%s:%s" % [robot_name, usage_name]
		var animations: Dictionary = robot.get("animations", {})
		if animations is Dictionary:
			for animation_name in animations:
				var asset_id := str(animations[animation_name]).strip_edges()
				if asset_id.is_empty():
					continue
				var usage_text := "%s:%s" % [robot_name, str(animation_name)]
				usage_by_asset[asset_id] = str(usage_by_asset.get(asset_id, ""))
				if not usage_by_asset[asset_id].is_empty():
					usage_by_asset[asset_id] += ", "
				usage_by_asset[asset_id] += usage_text
	for entry in entries:
		if str(entry.get("owner_kind", "")) != "visual_asset":
			continue
		var asset_id := str(entry.get("owner_key", ""))
		if usage_by_asset.has(asset_id):
			entry["asset_owner"] = "robot"
			entry["asset_usage"] = str(usage_by_asset[asset_id])
		else:
			entry["asset_owner"] = str(entry.get("asset_owner", ""))
			entry["asset_usage"] = str(entry.get("asset_usage", ""))

func _scan_main_preloads(seen: Dictionary) -> void:
	var path := "res://main.gd"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var source_text := file.get_as_text()
	file.close()
	var regex := RegEx.new()
	regex.compile('preload\\("([^"]+\\.(?:png|jpg|jpeg|webp))"\\)')
	var matches: Array = regex.search_all(source_text)
	for match_data in matches:
		var image_path := str(match_data.get_string(1))
		if seen.has(image_path): continue
		seen[image_path] = true
		entries.append({"label": "Runtime / %s" % image_path.get_file(), "path": image_path, "owner": path, "owner_kind": "main", "owner_key": image_path, "field": "preload", "usage": "Runtime preload", "category": "Runtime"})

func _select_path(path: String) -> void:
	for visible_index in range(filtered_indices.size()):
		var entry_index := filtered_indices[visible_index]
		if str(entries[entry_index].get("path", "")) == path:
			list.select(visible_index)
			_select_entry(visible_index)
			return
	for entry_index in range(entries.size()):
		if str(entries[entry_index].get("path", "")) == path:
			if search_edit:
				search_edit.text = ""
			if filter_option:
				filter_option.select(0)
			_refresh_entry_list()
			if entry_index < filtered_indices.size():
				var visible_index := filtered_indices.find(entry_index)
				if visible_index >= 0:
					if catalog_tree.visible:
						var row := catalog_tree.get_root()
						if row != null:
							row = row.get_first_child()
							while row != null:
								if int(row.get_metadata(0)) == entry_index:
									row.select(0)
									_select_entry_index(entry_index)
									break
								row = row.get_next()
					else:
						list.select(visible_index)
						_select_entry(visible_index)
			return

func _clear_image_selection() -> void:
	if editing:
		_finish_erase()
	current_index = -1
	current_path = ""
	current_image = null
	source_index = -1
	source_path = ""
	source_image = null
	list.deselect_all()
	catalog_tree.deselect_all()
	source_list.deselect_all()
	IMAGE_STATE.selected_path = ""
	usage_label.text = "Asset Usage"
	view.set_source_texture(null)
	status.text = "Image connection updated."

func _select_entry(index: int) -> void:
	if editing: return
	if index < 0 or index >= list.item_count: return
	var entry_index := int(list.get_item_metadata(index))
	_select_entry_index(entry_index)

func _load_grid_metadata(entry: Dictionary) -> void:
	if columns_spin == null:
		return
	var frames := maxi(1, int(entry.get("frames", 1)))
	var columns := maxi(1, int(entry.get("columns", frames)))
	var rows := maxi(1, int(entry.get("rows", 1)))
	var order := str(entry.get("frame_order", "row_major"))
	var anchor_data: Dictionary = entry.get("anchor", {}) if entry.get("anchor", {}) is Dictionary else {}
	var anchor_mode := str(anchor_data.get("mode", "BOTTOM_CENTER"))
	var anchor_x := clampf(float(anchor_data.get("x", 0.5)), 0.0, 1.0)
	var anchor_y := clampf(float(anchor_data.get("y", 1.0)), 0.0, 1.0)
	columns_spin.value = columns
	rows_spin.value = rows
	frames_spin.value = frames
	frame_order_option.select(1 if order == "column_major" else 0)
	var modes := ["BOTTOM_CENTER", "CENTER", "CENTER_LEFT", "BOTTOM_LEFT", "CUSTOM"]
	anchor_mode_option.select(modes.find(anchor_mode) if modes.find(anchor_mode) >= 0 else 4)
	anchor_x_spin.value = anchor_x
	anchor_y_spin.value = anchor_y
	view.set_grid_metadata(columns, rows, frames, Vector2(anchor_x, anchor_y), order)
	var cell_w := 0.0
	var cell_h := 0.0
	var region := _entry_region(entry)
	if columns > 0:
		cell_w = float(region.size.x) / float(columns)
	if rows > 0:
		cell_h = float(region.size.y) / float(rows)
	grid_status.text = "Grid %d × %d | Frames %d | Cell %.0f × %.0f | Anchor %s (%.2f, %.2f)" % [columns, rows, frames, cell_w, cell_h, anchor_mode, anchor_x, anchor_y]
	if frame_index_spin != null:
		frame_index_spin.max_value = maxi(1, frames)
		frame_index_spin.value = clampi(int(frame_index_spin.value), 1, maxi(1, frames))
		frame_x_spin.value = 0
		frame_y_spin.value = 0
		frame_scale_spin.value = 100
		frame_transform_base = current_image.duplicate() if current_image != null else null
		frame_transform_values.clear()
		frame_transform_active_index = -1
		frame_transform_status.text = "Select a frame number, then adjust X/Y and scale. Each frame keeps its own transform."

func _apply_grid_metadata() -> void:
	if current_index < 0 or current_index >= entries.size():
		grid_status.text = "Select a Visual Asset first."
		return
	var entry: Dictionary = entries[current_index]
	if str(entry.get("owner_kind", "")) != "visual_asset":
		grid_status.text = "Grid / Anchor metadata can only be saved for Visual Assets."
		return
	var columns := maxi(1, int(columns_spin.value))
	var rows := maxi(1, int(rows_spin.value))
	var frames := maxi(1, int(frames_spin.value))
	var region := _entry_region(entry)
	if frames > columns * rows:
		grid_status.text = "Invalid: Frames cannot exceed Columns × Rows."
		return
	if region.size.x <= 0 or region.size.y <= 0:
		grid_status.text = "Invalid: Region must have positive width and height."
		return
	var order := "column_major" if frame_order_option.selected == 1 else "row_major"
	var anchor_mode := anchor_mode_option.get_item_text(anchor_mode_option.selected)
	var anchor_x := clampf(float(anchor_x_spin.value), 0.0, 1.0)
	var anchor_y := clampf(float(anchor_y_spin.value), 0.0, 1.0)
	match anchor_mode:
		"BOTTOM_CENTER":
			anchor_x = 0.5
			anchor_y = 1.0
		"CENTER":
			anchor_x = 0.5
			anchor_y = 0.5
		"CENTER_LEFT":
			anchor_x = 0.0
			anchor_y = 0.5
		"BOTTOM_LEFT":
			anchor_x = 0.0
			anchor_y = 1.0
	var catalog_path := "res://content/editor/visual_assets.json"
	var file := FileAccess.open(catalog_path, FileAccess.READ)
	if file == null:
		grid_status.text = "Cannot open Visual Asset Catalog."
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary or not data.has(str(entry.get("owner_key", ""))):
		grid_status.text = "Visual Asset not found in Catalog."
		return
	var asset: Dictionary = data[str(entry.get("owner_key", ""))]
	asset["columns"] = columns
	asset["rows"] = rows
	asset["frames"] = frames
	asset["frame_order"] = order
	asset["anchor"] = {"mode": anchor_mode, "x": anchor_x, "y": anchor_y}
	data[str(entry.get("owner_key", ""))] = asset
	if not _write_json(catalog_path, data):
		grid_status.text = "Failed to save Grid / Anchor metadata."
		return
	VisualAssetResolver.reload()
	entry["columns"] = columns
	entry["rows"] = rows
	entry["frames"] = frames
	entry["frame_order"] = order
	entry["anchor"] = asset["anchor"]
	entries[current_index] = entry
	view.set_grid_metadata(columns, rows, frames, Vector2(anchor_x, anchor_y), order)
	var cell_w := float(region.size.x) / float(columns)
	var cell_h := float(region.size.y) / float(rows)
	grid_status.text = "Saved: %d × %d grid | %d frames | Cell %.0f × %.0f | Anchor %s (%.2f, %.2f)" % [columns, rows, frames, cell_w, cell_h, anchor_mode, anchor_x, anchor_y]

func _on_frame_transform_changed(_value: float = 0.0) -> void:
	if current_image == null or current_image.is_empty():
		return
	if columns_spin == null or rows_spin == null or frames_spin == null or frame_index_spin == null:
		return
	var region := _entry_region(entries[current_index]) if current_index >= 0 and current_index < entries.size() else Rect2i()
	var columns := maxi(1, int(columns_spin.value))
	var rows := maxi(1, int(rows_spin.value))
	var frames := maxi(1, int(frames_spin.value))
	var frame_index := clampi(int(frame_index_spin.value) - 1, 0, frames - 1)
	if region.size.x <= 0 or region.size.y <= 0:
		return
	if frame_transform_base == null:
		frame_transform_base = current_image.duplicate()

	# Keep a separate transform for every frame. Switching frames must not
	# discard the scale/X/Y already applied to another frame.
	if frame_transform_active_index >= 0 and frame_transform_active_index != frame_index and not frame_transform_syncing:
		frame_transform_values[frame_transform_active_index] = [float(frame_x_spin.value), float(frame_y_spin.value), float(frame_scale_spin.value)]
	var saved: Array = frame_transform_values.get(frame_index, [0.0, 0.0, 100.0])
	if frame_transform_active_index != frame_index:
		frame_transform_syncing = true
		frame_x_spin.value = float(saved[0])
		frame_y_spin.value = float(saved[1])
		frame_scale_spin.value = float(saved[2])
		frame_transform_syncing = false
		frame_transform_active_index = frame_index
	frame_transform_values[frame_index] = [float(frame_x_spin.value), float(frame_y_spin.value), float(frame_scale_spin.value)]

	var cell_w := maxi(1, floori(float(region.size.x) / float(columns)))
	var cell_h := maxi(1, floori(float(region.size.y) / float(rows)))
	var result := frame_transform_base.duplicate()

	# Rebuild the whole sheet from the original base so transforms from all
	# previously edited frames remain visible when another frame is selected.
	for index in range(frames):
		var column := index % columns
		var row := index / columns
		if frame_order_option.selected == 1:
			column = index / rows
			row = index % rows
		var cell := Rect2i(region.position.x + column * cell_w, region.position.y + row * cell_h, cell_w, cell_h)
		var transform: Array = frame_transform_values.get(index, [0.0, 0.0, 100.0])
		var frame := frame_transform_base.get_region(cell)
		var scale := clampf(float(transform[2]) / 100.0, 0.1, 4.0)
		var scaled_w := maxi(1, roundi(float(frame.get_width()) * scale))
		var scaled_h := maxi(1, roundi(float(frame.get_height()) * scale))
		frame.resize(scaled_w, scaled_h, Image.INTERPOLATE_LANCZOS)
		var canvas := Image.create(cell.size.x, cell.size.y, false, Image.FORMAT_RGBA8)
		canvas.fill(Color(0, 0, 0, 0))
		var dest := Vector2i(
			floori((cell.size.x - scaled_w) * 0.5 + float(transform[0])),
			floori((cell.size.y - scaled_h) * 0.5 + float(transform[1]))
		)
		var dst := Rect2i(dest.x, dest.y, scaled_w, scaled_h)
		var clipped := dst.intersection(Rect2i(0, 0, canvas.get_width(), canvas.get_height()))
		if clipped.size.x > 0 and clipped.size.y > 0:
			var src := Rect2i(clipped.position - dst.position, clipped.size)
			canvas.blit_rect(frame, src, clipped.position)
		result.fill_rect(cell, Color(0, 0, 0, 0))
		result.blit_rect(canvas, Rect2i(0, 0, canvas.get_width(), canvas.get_height()), cell.position)

	current_image = result
	view.set_source_texture(ImageTexture.create_from_image(current_image))
	view.selected_region = region
	view.queue_redraw()
	frame_transform_status.text = "Frame %d | X %+d | Y %+d | Scale %.0f%% | Per-frame transform retained" % [frame_index + 1, int(frame_x_spin.value), int(frame_y_spin.value), float(frame_scale_spin.value)]

func _on_frame_selected(frame_index: int) -> void:
	if frame_index_spin == null:
		return
	frame_index_spin.value = frame_index + 1
	view.set_selected_frame(frame_index)
	frame_transform_status.text = "Selected Frame %d | Arrow keys move the frame | Shift = 10 px" % [frame_index + 1]

func _unhandled_key_input(event: InputEvent) -> void:
	if not frame_select_mode or frame_transform_active_index < 0:
		return
	if not event.pressed or event.echo:
		return
	var step := 10 if event.shift_pressed else 1
	var changed := true
	match event.keycode:
		KEY_LEFT:
			frame_x_spin.value -= step
		KEY_RIGHT:
			frame_x_spin.value += step
		KEY_UP:
			frame_y_spin.value -= step
		KEY_DOWN:
			frame_y_spin.value += step
		_:
			changed = false
	if changed:
		get_viewport().set_input_as_handled()

func _reset_frame_transform() -> void:
	if frame_transform_base == null:
		return
	frame_x_spin.value = 0
	frame_y_spin.value = 0
	frame_scale_spin.value = 100
	_on_frame_transform_changed(0.0)

func _select_entry_index(entry_index: int) -> void:
	if editing: return
	if entry_index < 0 or entry_index >= entries.size(): return
	catalog_target_index = entry_index
	current_index = entry_index
	var entry: Dictionary = entries[entry_index]
	current_path = str(entry.get("path", ""))
	if IMAGE_STATE.selection_pending:
		# Selection mode edits the existing target asset. Keep its ID and only
		# change the source path/region currently being authored.
		IMAGE_STATE.selected_path = current_path
	else:
		IMAGE_STATE.open_image(current_path)
	current_image = LOADER.load_image(current_path)
	var catalog_region: Rect2i = _entry_region(entry)
	usage_label.text = "[%s] %s\nUsage: %s\nSource: %s\nOwner: %s\nField: %s" % [str(entry.get("category", "Other")), str(entry.get("label", "Asset")), str(entry.get("usage", "Unknown")), current_path, str(entry.get("owner", "Unknown")), str(entry.get("field", "Unknown"))]
	if current_image == null:
		status.text = "Previous reference could not be resolved: %s" % current_path
		return
	view.set_source_texture(ImageTexture.create_from_image(current_image))
	frame_transform_base = current_image.duplicate()
	frame_transform_active_index = -1
	if frame_index_spin != null:
		var transform_frames := maxi(1, int(entry.get("frames", 1)))
		frame_index_spin.max_value = transform_frames
		frame_index_spin.value = 1
		frame_x_spin.value = 0
		frame_y_spin.value = 0
		frame_scale_spin.value = 100
		frame_transform_status.text = "Select a frame number, then adjust X/Y and scale. Changes preview immediately."
	if catalog_region.size.x > 0 and catalog_region.size.y > 0:
		view.selected_region = catalog_region
		view.queue_redraw()
	if str(entry.get("owner_kind", "")) == "visual_asset":
		_load_grid_metadata(entry)
	else:
		view.clear_grid_metadata()
		grid_status.text = "Grid / Anchor metadata is available when a Visual Asset is selected."
	status.text = "Selected region: %s | area %d x %d px" % [str(entry.get("label", "Asset")), catalog_region.size.x, catalog_region.size.y]

func _entry_region(entry: Dictionary) -> Rect2i:
	var region_data: Array = entry.get("region", [])
	if region_data.size() < 4:
		return Rect2i()
	return Rect2i(int(region_data[0]), int(region_data[1]), int(region_data[2]), int(region_data[3]))

func _open_target_dialog() -> void:
	if target_dialog == null:
		return
	target_thumbnail_cache.clear()
	target_dialog.invalidate()
	target_dialog.popup_centered(Vector2i(1000, 700))

func _get_target_thumbnail(path: String) -> Texture2D:
	var cached: Texture2D = target_thumbnail_cache.get(path) as Texture2D
	if cached != null:
		return cached
	var loaded := load(path) as Texture2D
	if loaded != null:
		target_thumbnail_cache[path] = loaded
	return loaded

func _on_target_file_selected(path: String) -> void:
	if editing:
		_finish_erase()
	var loaded := LOADER.load_image(path)
	if loaded == null:
		status.text = "Edited reference could not be resolved: %s" % current_path
		return
	current_index = -1
	current_path = path
	current_image = loaded
	IMAGE_STATE.open_image(path)
	list.deselect_all()
	usage_label.text = "Usage: Edited Reference"
	_refresh_view()
	status.text = "No valid source reference. Select an image or region first."

func _save_current_image_copy() -> String:
	if not _require_image():
		return ""
	var dir := ProjectSettings.globalize_path(EDITED_DIR)
	var err := DirAccess.make_dir_recursive_absolute(dir)
	if err != OK:
		return ""
	var name := current_path.get_file().get_basename().to_snake_case()
	if name.is_empty():
		name = "image"
	var output := "%s/%s_edit_%d.png" % [EDITED_DIR, name, Time.get_ticks_usec()]
	err = current_image.save_png(ProjectSettings.globalize_path(output))
	return output if err == OK else ""

func _reconnect_current_to_selected_entry() -> void:
	if not _require_image():
		return
	if catalog_target_index < 0 or catalog_target_index >= entries.size():
		status.text = "Select a source image or asset from the catalog first."
		return
	if str(entries[catalog_target_index].get("path", "")) == current_path:
		status.text = "Select a valid source image or region."
		return
	if source_path == current_path:
		source_path = ""
		source_image = null
	var output := _save_current_image_copy()
	if output.is_empty():
		status.text = "The source image could not be loaded from the catalog."
		return
	if catalog_target_index < 0 or catalog_target_index >= entries.size():
		status.text = "Select a source image or asset from the catalog first."
		return
	if not _replace_entry_reference(entries[catalog_target_index], output):
		status.text = "The selected source could not be resolved."
		return
	current_path = output
	IMAGE_STATE.open_image(output)
	_refresh_view()
	_scan_connected_images()
	_select_path(output)
	status.text = "Selected catalog source: %s" % output

func _replace_entry_reference(entry: Dictionary, new_path: String) -> bool:
	var owner_kind := str(entry.get("owner_kind", ""))
	if owner_kind == "json":
		return _replace_json_value(str(entry.get("owner", "")), str(entry.get("owner_key", "")), str(entry.get("field", "")), new_path)
	if owner_kind == "catalog":
		return _replace_catalog_value(str(entry.get("owner_key", "")), new_path)
	if owner_kind == "main":
		return _replace_main_path(str(entry.get("owner_key", "")), new_path)
	return false

func _confirm_delete_visual_asset() -> void:
	var entry_index := -1
	if catalog_tree != null and catalog_tree.visible:
		var selected := catalog_tree.get_selected()
		if selected != null:
			entry_index = int(selected.get_metadata(0))
	if entry_index < 0 or entry_index >= entries.size():
		if current_index >= 0 and current_index < entries.size():
			entry_index = current_index
	if entry_index < 0 or entry_index >= entries.size():
		status.text = "Select an asset first."
		return
	current_index = entry_index
	var entry: Dictionary = entries[entry_index]
	var target := _resolve_delete_target(entry)
	if target.is_empty():
		status.text = "Selected item has no deletable catalog/reference target."
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "Delete Asset"
	dialog.dialog_text = "Delete this asset/reference from all managed catalogs?\nThe source image file will be preserved."
	add_child(dialog)
	dialog.confirmed.connect(func(): _delete_managed_asset(target, dialog))
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(640, 260))

func _resolve_delete_target(entry: Dictionary) -> String:
	var visual_asset_id := _resolve_visual_asset_id(entry)
	if not visual_asset_id.is_empty():
		return visual_asset_id
	var path := str(entry.get("path", "")).strip_edges()
	if not path.is_empty():
		return path
	return ""

func _delete_managed_asset(target: String, dialog: ConfirmationDialog) -> void:
	var changed_files: Array[String] = []
	var failed_files: Array[String] = []
	if _delete_visual_asset_definition(target):
		changed_files.append("visual_assets.json")
	for path in [
		"res://content/towers/towers.json",
		"res://content/allied_units/allied_units.json",
		"res://content/enemies/enemies.json",
		"res://content/robots/robots.json"
	]:
		var result := _remove_json_references(path, target)
		if result == 1:
			changed_files.append(path.get_file())
		elif result == -1:
			failed_files.append(path.get_file())
	var catalog_result := _remove_asset_catalog_references(target)
	if catalog_result == 1:
		changed_files.append("asset_catalog.json")
	elif catalog_result == -1:
		failed_files.append("asset_catalog.json")
	var main_result := _remove_main_preload_reference(target)
	if main_result == 1:
		changed_files.append("main.gd")
	elif main_result == -1:
		failed_files.append("main.gd")
	VisualAssetResolver.reload()
	_scan_connected_images()
	current_index = -1
	dialog.queue_free()
	if not failed_files.is_empty():
		status.text = "Deleted with incomplete cleanup: %s / failed: %s" % [target, ", ".join(failed_files)]
	elif changed_files.is_empty():
		status.text = "No managed references found: " + target
	else:
		status.text = "Deleted from managed catalogs: %s" % target

func _delete_visual_asset_definition(asset_id: String) -> bool:
	var path := "res://content/editor/visual_assets.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary or not data.has(asset_id):
		return false
	data.erase(asset_id)
	return _write_json(path, data)

func _remove_json_references(path: String, target: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return -1
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null:
		return -1
	if not _remove_matching_values(data, target):
		return 0
	return 1 if _write_json(path, data) else -1

func _remove_asset_catalog_references(target: String) -> int:
	var path := "res://content/editor/asset_catalog.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return -1
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary:
		return -1
	var assets: Array = data.get("assets", [])
	var changed := false
	for index in range(assets.size() - 1, -1, -1):
		var asset = assets[index]
		if not asset is Dictionary:
			continue
		if str(asset.get("asset_id", "")) == target or str(asset.get("source_path", "")) == target:
			assets.remove_at(index)
			changed = true
	if not changed:
		return 0
	data["assets"] = assets
	return 1 if _write_json(path, data) else -1

func _remove_main_preload_reference(target: String) -> int:
	var path := "res://main.gd"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return -1
	var lines := file.get_as_text().split("\n")
	file.close()
	var needle := 'preload("' + target + '")'
	var changed := false
	for index in range(lines.size() - 1, -1, -1):
		if lines[index].contains(needle):
			lines.remove_at(index)
			changed = true
	if not changed:
		return 0
	var out := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE)
	if out == null:
		return -1
	out.store_string("\n".join(lines))
	out.close()
	return 1

func _resolve_visual_asset_id(entry: Dictionary) -> String:
	var file := FileAccess.open("res://content/editor/visual_assets.json", FileAccess.READ)
	if file == null:
		return ""
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary:
		return ""
	# ALL rows can originate from robots.json, catalog, or other references.
	# Their owner_key is not necessarily the Visual Asset ID. The actual
	# reference path is the primary candidate, while owner_key/id are fallbacks.
	var candidates: Array[String] = []
	for key in ["path", "owner_key", "id"]:
		var candidate := str(entry.get(key, "")).strip_edges()
		if not candidate.is_empty() and not candidates.has(candidate):
			candidates.append(candidate)
	for candidate in candidates:
		if data.has(candidate):
			return candidate
	return ""

func _delete_visual_asset(asset_id: String, dialog: ConfirmationDialog) -> void:
	var catalog_path := "res://content/editor/visual_assets.json"
	var file := FileAccess.open(catalog_path, FileAccess.READ)
	if file == null:
		status.text = "Visual Asset Catalog could not be loaded."
		dialog.queue_free()
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary or not data.has(asset_id):
		status.text = "Visual Asset not found: " + asset_id
		dialog.queue_free()
		return
	data.erase(asset_id)
	if not _write_json(catalog_path, data):
		status.text = "Failed to update Visual Asset Catalog."
		dialog.queue_free()
		return
	if not _remove_visual_asset_robot_references(asset_id):
		status.text = "Visual Asset deleted, but some robot references could not be removed: " + asset_id
		VisualAssetResolver.reload()
		_scan_connected_images()
		current_index = -1
		dialog.queue_free()
		return
	VisualAssetResolver.reload()
	_scan_connected_images()
	current_index = -1
	status.text = "Visual Asset and all robot references deleted: " + asset_id
	dialog.queue_free()

func _remove_visual_asset_robot_references(asset_id: String) -> bool:
	var robots_path := "res://content/robots/robots.json"
	var file := FileAccess.open(robots_path, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary:
		return false
	var changed := _remove_matching_values(data, asset_id)
	if not changed:
		return true
	return _write_json(robots_path, data)

func _remove_matching_values(value: Variant, target: String) -> bool:
	var changed := false
	if value is Dictionary:
		var keys_to_remove: Array = []
		for key in value.keys():
			var child = value[key]
			if child is String and str(child) == target:
				keys_to_remove.append(key)
			elif _remove_matching_values(child, target):
				changed = true
		for key in keys_to_remove:
			value.erase(key)
			changed = true
	elif value is Array:
		for index in range(value.size() - 1, -1, -1):
			var child = value[index]
			if child is String and str(child) == target:
				value.remove_at(index)
				changed = true
			elif _remove_matching_values(child, target):
				changed = true
	return changed

func _create_visual_asset_from_selection() -> void:
	if not _require_image():
		return
	var rect := view.selected_region
	# When arriving from Robot/Unit/Tower Editor, the selected Visual Asset already
	# defines the intended region. Keep that region as the default registration area.
	if rect.size.x <= 0 or rect.size.y <= 0:
		var selected_entry: Dictionary = entries[current_index] if current_index >= 0 and current_index < entries.size() else {}
		rect = _entry_region(selected_entry)
		if rect.size.x > 0 and rect.size.y > 0:
			view.selected_region = rect
			view.queue_redraw()
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "Select a source image or asset, then drag-select a region."
		return
	_create_visual_asset(rect)

func _create_visual_asset_from_full_image() -> void:
	if not _require_image():
		return
	_create_visual_asset(Rect2i(0, 0, current_image.get_width(), current_image.get_height()))

func _create_visual_asset(rect: Rect2i) -> void:
	var catalog_path := "res://content/editor/visual_assets.json"
	var data: Variant = {}
	if FileAccess.file_exists(catalog_path):
		var file := FileAccess.open(catalog_path, FileAccess.READ)
		if file != null:
			data = JSON.parse_string(file.get_as_text())
			file.close()
	if not data is Dictionary:
		data = {}
	var base_name := current_path.get_file().get_basename().to_snake_case()
	if base_name.is_empty():
		base_name = "image"
	var inherited_frames := 1
	var inherited_category := "Other"
	if current_index >= 0 and current_index < entries.size():
		var source_entry: Dictionary = entries[current_index]
		if str(source_entry.get("owner_kind", "")) == "visual_asset":
			var source_asset_id := str(source_entry.get("owner_key", ""))
			var source_definition := VisualAssetResolver.get_asset(source_asset_id)
			if source_definition != null:
				inherited_frames = source_definition.frames
				inherited_category = source_definition.category
	var owner_kind := str(IMAGE_STATE.selection_owner_kind)
	var owner_key := str(IMAGE_STATE.selection_owner_key)
	var owner_usage := str(IMAGE_STATE.selection_usage)
	var registered_frames := maxi(1, int(IMAGE_STATE.selection_frames))
	var base_id := "image." + base_name
	if owner_kind == "robot" and not owner_key.is_empty() and not owner_usage.is_empty():
		base_id = "robot.%s.%s" % [owner_key, owner_usage]
		inherited_category = "Robot"
		registered_frames = maxi(registered_frames, inherited_frames)
	var assets: Dictionary = data
	# Registration from another editor is valid only when that editor supplied
	# the exact semantic Visual Asset ID. Never derive a new ID from the source image.
	var asset_id := originating_asset_id.strip_edges()
	if asset_id.is_empty():
		status.text = "Registration blocked: no Visual Asset ID was supplied by the originating editor."
		return
	var asset_definition: Dictionary = {
		"id": asset_id,
		"category": inherited_category,
		"source": current_path,
		"region": [rect.position.x, rect.position.y, rect.size.x, rect.size.y],
		"frames": registered_frames,
		"columns": registered_frames,
		"rows": 1,
		"frame_order": "row_major",
		"anchor": {"mode": "BOTTOM_CENTER", "x": 0.5, "y": 1.0},
		"owner": ("%s.%s" % [owner_kind, owner_key]) if not owner_kind.is_empty() and not owner_key.is_empty() else "",
		"usage": owner_usage if not owner_usage.is_empty() else "visual_asset_catalog"
	}
	# Profile team-color masks belong to the Profile Visual Asset definition.
	# The mask uses the same atlas coordinates as the profile region, so only its
	# source needs to be stored; Robot Editor can resolve the exact asset later.
	if owner_kind == "robot" and owner_usage == "profile" and not owner_key.is_empty():
		var mask_path := "res://images/robot/%s/profile_team_mask.png" % owner_key
		if FileAccess.file_exists(mask_path):
			asset_definition["team_mask"] = {"source": mask_path}
	assets[asset_id] = asset_definition
	if not _write_json(catalog_path, assets):
		status.text = "Failed to write Visual Asset Catalog: %s" % catalog_path
		return
	VisualAssetResolver.reload()
	_scan_connected_images()
	var created_index := -1
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		if str(entry.get("owner_kind", "")) == "visual_asset" and str(entry.get("owner_key", "")) == asset_id:
			created_index = index
			break
	if created_index >= 0:
		for list_index in range(filtered_indices.size()):
			if filtered_indices[list_index] == created_index:
				list.select(list_index)
				_select_entry(list_index)
				break
	else:
		_select_path(current_path)
	if IMAGE_STATE.selection_pending and not IMAGE_STATE.selection_target.is_empty():
		IMAGE_STATE.apply_selection(asset_id)
		status.text = "Visual Asset registration complete: %s | region %d x %d px" % [asset_id, rect.size.x, rect.size.y]
		request_previous_editor.emit()
	else:
		status.text = "Visual Asset registration complete: %s | region %d x %d px" % [asset_id, rect.size.x, rect.size.y]

func _add_current_image_to_asset_catalog() -> void:
	if not _require_image():
		return
	var output := _save_current_image_copy()
	if output.is_empty():
		status.text = "The selected catalog source is not a valid PNG."
		return
	var catalog_path := "res://content/editor/asset_catalog.json"
	var data: Variant = {}
	if FileAccess.file_exists(catalog_path):
		var file := FileAccess.open(catalog_path, FileAccess.READ)
		if file != null:
			data = JSON.parse_string(file.get_as_text())
			file.close()
	if not data is Dictionary:
		data = {}
	var assets: Array = data.get("assets", []) if data.get("assets", []) is Array else []
	var base_id := "asset.image." + current_path.get_file().get_basename().to_snake_case()
	if base_id == "asset.image.":
		base_id = "asset.image.generated"
	var asset_id := IMAGE_STATE.selection_asset_id if not IMAGE_STATE.selection_asset_id.is_empty() else base_id
	var suffix := 1
	while _catalog_asset_id_exists(assets, asset_id):
		asset_id = "%s.%02d" % [base_id, suffix]
		suffix += 1
	var display_name := current_path.get_file().get_basename().replace("_", " ").capitalize()
	var width := current_image.get_width()
	var height := current_image.get_height()
	assets.append({
		"asset_id": asset_id,
		"kind": "object",
		"group": "Other",
		"display_name": display_name,
		"source_path": output,
		"source_rect_px": [0, 0, width, height],
		"footprint_tiles": [maxi(1, ceili(float(width) / 32.0)), maxi(1, ceili(float(height) / 32.0))]
	})
	data["schema_version"] = int(data.get("schema_version", 1))
	data["assets"] = assets
	if not _write_json(catalog_path, data):
		status.text = "PNG import failed for Asset Catalog: %s" % output
		return
	_scan_connected_images()
	_select_path(output)
	status.text = "Asset Catalog registration failed: %s" % output

func _catalog_asset_id_exists(assets: Array, asset_id: String) -> bool:
	for asset in assets:
		if asset is Dictionary and str(asset.get("asset_id", "")) == asset_id:
			return true
	return false

func _get_source_thumbnail(path: String) -> Texture2D:
	var cached: Texture2D = source_thumbnail_cache.get(path) as Texture2D
	if cached != null:
		return cached
	var loaded := load(path) as Texture2D
	if loaded != null:
		source_thumbnail_cache[path] = loaded
	return loaded

func _open_source_dialog() -> void:
	source_thumbnail_cache.clear()
	if source_dialog != null:
		source_dialog.popup_centered(Vector2i(1000, 700))

func _on_source_file_selected(path: String) -> void:
	if path == current_path:
		status.text = "Select a source image or asset first."
		return
	source_path = path
	source_index = -1
	source_image = LOADER.load_image(source_path)
	if source_image == null:
		status.text = "Source image could not be resolved: %s" % source_path
		return
	view.set_source_texture(ImageTexture.create_from_image(source_image))
	status.text = "Select a region from: %s" % source_path

func _select_source_entry(index: int) -> void:
	if editing: return
	if index < 0 or index >= source_list.item_count: return
	var entry_index := int(source_list.get_item_metadata(index))
	if entry_index < 0 or entry_index >= entries.size(): return
	source_index = entry_index
	source_path = str(entries[entry_index].get("path", ""))
	if source_path == current_path:
		status.text = "Select a source image or asset first."
		return
	source_image = LOADER.load_image(source_path)
	if source_image == null:
		status.text = "Source image could not be resolved: %s" % source_path
		return
	view.set_source_texture(ImageTexture.create_from_image(source_image))
	status.text = "Use the full source image from %s" % source_path

func _replace_from_source_full() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "Select a source image or asset first."
		return
	current_image = source_image.duplicate()
	_refresh_view()
	status.text = "The full source image is already selected. Use reconnect to change the reference."

func _apply_source_region_reference() -> void:
	if not _require_image(): return
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "Select a source image or asset first."
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "Select a source image or asset, then choose a region."
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	if not _save_source_reference(source_path, rect):
		status.text = "The selected source region is invalid."
		return
	status.text = "Source region updated: %s [%d, %d, %d, %d]" % [source_path, rect.position.x, rect.position.y, rect.size.x, rect.size.y]

func _replace_from_source_region() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "Select a source image or asset first."
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "Select a source image or asset, then choose a region."
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	current_image = source_image.get_region(rect)
	_refresh_view()
	status.text = "Region %d x %d px applied. Use reconnect to change the source reference." % [rect.size.x, rect.size.y]

func _replace_source_region_as_unit() -> void:
	if not _require_image(): return
	if current_index < 0 or current_index >= entries.size():
		status.text = "Select an edited image or asset first."
		return
	var entry: Dictionary = entries[current_index]
	var owner_path := str(entry.get("owner", ""))
	var owner_key := str(entry.get("owner_key", ""))
	if str(entry.get("owner_kind", "")) != "json" or (owner_path != "res://content/towers/towers.json" and owner_path != "res://content/allied_units/allied_units.json"):
		status.text = "The edited image is not connected to a source reference."
		return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "Select a source image or asset first."
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "The selected source region is registered as the Visual Asset region."
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	var region := source_image.get_region(rect)
	var unit_sheet: Dictionary = ConfigRepository.get_editor_value("image_editor", "unit_sheet", {})
	var default_size: Array = unit_sheet.get("default_frame_size", [60, 90])
	var frame_size := Vector2i(int(default_size[0]), int(default_size[1])) if default_size.size() >= 2 else Vector2i(60, 90)
	var frame_count := int(unit_sheet.get("default_frame_count", 4))
	var unit_label := "Unit"
	if owner_path == "res://content/allied_units/allied_units.json":
		var configured_sizes: Dictionary = unit_sheet.get("allied_unit_frame_sizes", {})
		var size_data: Array = configured_sizes.get(owner_key, default_size)
		frame_size = Vector2i(int(size_data[0]), int(size_data[1])) if size_data.size() >= 2 else Vector2i(60, 90)
		frame_count = int(unit_sheet.get("allied_unit_frame_count", 8))
		unit_label = "Allied Unit"
	var frame := Image.create(frame_size.x, frame_size.y, false, Image.FORMAT_RGBA8)
	frame.fill(Color(0, 0, 0, 0))
	var scale := minf(float(frame_size.x) / float(region.get_width()), float(frame_size.y) / float(region.get_height()))
	var fitted_w := maxi(1, roundi(region.get_width() * scale))
	var fitted_h := maxi(1, roundi(region.get_height() * scale))
	region.resize(fitted_w, fitted_h, Image.INTERPOLATE_LANCZOS)
	var dest := Rect2i((frame_size.x - fitted_w) / 2, frame_size.y - fitted_h, fitted_w, fitted_h)
	frame.blit_rect(region, Rect2i(0, 0, fitted_w, fitted_h), dest.position)
	var sheet := Image.create(frame_size.x * frame_count, frame_size.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0, 0, 0, 0))
	for frame_index in frame_count:
		sheet.blit_rect(frame, Rect2i(0, 0, frame_size.x, frame_size.y), Vector2i(frame_index * frame_size.x, 0))
	current_image = sheet
	_refresh_view()
	status.text = "%s | %d frames | %d x %d px | reconnect the reference to apply changes." % [current_path, frame_count, frame_size.x, frame_size.y]

func _resize_image(width_px: int, height_px: int) -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	current_image.resize(maxi(1, width_px), maxi(1, height_px), Image.INTERPOLATE_LANCZOS)
	_refresh_view()

func _require_image() -> bool:
	if current_image == null or current_image.is_empty():
		status.text = "Select a connected image first."
		return false
	return true

func _refresh_view() -> void:
	view.set_source_texture(ImageTexture.create_from_image(current_image))
	status.text = "%s ??%d ??%d px" % [current_path, current_image.get_width(), current_image.get_height()]
func _start_erase() -> void:
	if not _require_image(): return
	view.begin_image_edit(current_image, 12)
	editing = true
	status.text = "Erase mode active. Drag over pixels, then save."

func _finish_erase() -> void:
	if not editing: return
	var edited := view.get_edited_image()
	if edited == null: return
	current_image = edited
	view.cancel_image_edit()
	editing = false
	_refresh_view()

func _crop_selection() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "Drag-select a region first."
		return
	rect = rect.intersection(Rect2i(0, 0, current_image.get_width(), current_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	current_image = current_image.get_region(rect)
	_refresh_view()

func _flip_h() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	current_image.flip_x()
	_refresh_view()

func _flip_v() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	current_image.flip_y()
	_refresh_view()

func _rotate_cw() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	current_image.rotate_90(CLOCKWISE)
	_refresh_view()
func _rotate_ccw() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	current_image.rotate_90(COUNTERCLOCKWISE)
	_refresh_view()

func _remove_background_color() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	var target := background_color_button.color
	var tolerance := float(background_tolerance_spin.value)
	var tolerance_sq := tolerance * tolerance
	var w := current_image.get_width()
	var h := current_image.get_height()
	var changed := 0
	if background_connected_only_check.button_pressed:
		var mask := PackedByteArray()
		mask.resize(w * h)
		for y in range(h):
			for x in range(w):
				var pixel := current_image.get_pixel(x, y)
				if pixel.a <= 0.0: continue
				var dr := pixel.r - target.r
				var dg := pixel.g - target.g
				var db := pixel.b - target.b
				if dr * dr + dg * dg + db * db <= tolerance_sq:
					mask[y * w + x] = 1
		var queue := PackedInt32Array()
		for x in range(w):
			if mask[x] == 1:
				mask[x] = 2
				queue.append(x)
			var bottom := (h - 1) * w + x
			if mask[bottom] == 1:
				mask[bottom] = 2
				queue.append(bottom)
		for y in range(h):
			var left := y * w
			if mask[left] == 1:
				mask[left] = 2
				queue.append(left)
			var right := y * w + w - 1
			if mask[right] == 1:
				mask[right] = 2
				queue.append(right)
		var head := 0
		while head < queue.size():
			var index := queue[head]
			head += 1
			var px := index % w
			var py := index / w
			var neighbors: Array[int] = [index - 1, index + 1, index - w, index + w]
			for neighbor: int in neighbors:
				if neighbor < 0 or neighbor >= w * h or mask[neighbor] != 1: continue
				var nx: int = neighbor % w
				var ny: int = neighbor / w
				if abs(nx - px) + abs(ny - py) != 1: continue
				mask[neighbor] = 2
				queue.append(neighbor)
		for index in range(mask.size()):
			if mask[index] == 2:
				var pixel := current_image.get_pixel(index % w, index / w)
				current_image.set_pixel(index % w, index / w, Color(pixel.r, pixel.g, pixel.b, 0.0))
				changed += 1
	else:
		for y in range(h):
			for x in range(w):
				var pixel := current_image.get_pixel(x, y)
				if pixel.a <= 0.0: continue
				var dr := pixel.r - target.r
				var dg := pixel.g - target.g
				var db := pixel.b - target.b
				if dr * dr + dg * dg + db * db <= tolerance_sq:
					current_image.set_pixel(x, y, Color(pixel.r, pixel.g, pixel.b, 0.0))
					changed += 1
	_refresh_view()
	status.text = "Background removed: %d pixels (tolerance %.2f)" % [changed, tolerance]

func _trim_alpha() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	var rect := _visible_bounds(current_image)
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "Image has no visible pixels."
		return
	current_image = current_image.get_region(rect)
	_refresh_view()

func _visible_bounds(image: Image) -> Rect2i:
	var w := image.get_width()
	var h := image.get_height()
	var min_x := w
	var min_y := h
	var max_x := -1
	var max_y := -1
	for y in range(h):
		for x in range(w):
			if image.get_pixel(x, y).a > 0.0:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < 0: return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

func _save_reconnect() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	var dir := ProjectSettings.globalize_path(EDITED_DIR)
	var err := DirAccess.make_dir_recursive_absolute(dir)
	if err != OK:
		status.text = "Could not create edited asset directory."
		return
	var name := current_path.get_file().get_basename().to_snake_case()
	var output := "%s/%s_edit_%d.png" % [EDITED_DIR, name, Time.get_ticks_usec()]
	err = current_image.save_png(ProjectSettings.globalize_path(output))
	if err != OK:
		status.text = "PNG save failed: %d" % err
		return
	if not _reconnect_entry(output):
		status.text = "Saved edit, but reconnect failed: %s" % output
		return
	current_path = output
	# The PNG now contains the current per-frame transforms. Make this saved
	# image the new transform baseline so switching to another frame cannot
	# rebuild from the pre-save/original sheet and undo the saved movement.
	frame_transform_base = current_image.duplicate()
	frame_transform_values.clear()
	frame_transform_active_index = -1
	_refresh_view()
	status.text = "Saved edited image and reconnected the selected reference."
func _save_source_reference(path: String, rect: Rect2i) -> bool:
	if current_index < 0 or current_index >= entries.size(): return false
	var entry: Dictionary = entries[current_index]
	var owner_kind := str(entry.owner_kind)
	if owner_kind == "json":
		return _replace_json_reference(str(entry.owner), str(entry.owner_key), str(entry.field), path, rect)
	if owner_kind == "catalog":
		return _replace_catalog_reference(str(entry.owner_key), path, rect)
	return false

func _replace_json_reference(path: String, key: String, field: String, source_path_value: String, rect: Rect2i) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary or not data.has(key): return false
	_set_nested_value(data[key], field, source_path_value)
	_set_nested_value(data[key], _field_suffix(field, "_rect"), [rect.position.x, rect.position.y, rect.size.x, rect.size.y])
	return _write_json(path, data)

func _field_suffix(field: String, suffix: String) -> String:
	var parts := field.split(".")
	parts[parts.size() - 1] = str(parts[parts.size() - 1]) + suffix
	return ".".join(parts)

func _set_nested_value(root: Dictionary, field: String, value: Variant) -> void:
	var parts := field.split(".")
	var target := root
	for i in range(parts.size() - 1):
		var part := str(parts[i])
		if not target.has(part) or not target[part] is Dictionary:
			target[part] = {}
		target = target[part]
	target[str(parts[parts.size() - 1])] = value

func _erase_nested_value(root: Dictionary, field: String) -> void:
	var parts := field.split(".")
	var target := root
	for i in range(parts.size() - 1):
		var part := str(parts[i])
		if not target.has(part) or not target[part] is Dictionary:
			return
		target = target[part]
	target.erase(str(parts[parts.size() - 1]))

func _replace_catalog_reference(asset_id: String, source_path_value: String, rect: Rect2i) -> bool:
	var path := "res://content/editor/asset_catalog.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return false
	var assets: Array = data.get("assets", [])
	for asset in assets:
		if asset is Dictionary and str(asset.get("asset_id", "")) == asset_id:
			asset["source_path"] = source_path_value
			asset["source_rect_px"] = [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
			return _write_json(path, data)
	return false

func _reconnect_entry(new_path: String) -> bool:
	if current_index < 0 or current_index >= entries.size(): return false
	var entry: Dictionary = entries[current_index]
	var owner_kind := str(entry.owner_kind)
	if owner_kind == "json":
		return _replace_json_value(str(entry.owner), str(entry.owner_key), str(entry.field), new_path)
	if owner_kind == "catalog":
		return _replace_catalog_value(str(entry.owner_key), new_path)
	if owner_kind == "main":
		return _replace_main_path(str(entry.owner_key), new_path)
	return false

func _replace_json_value(path: String, key: String, field: String, new_path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary or not data.has(key): return false
	_set_nested_value(data[key], field, new_path)
	# ????+ ???????ㅻ깹????????怨뺤른????黎앸럽??筌???????????耀붾굝???????袁⑸즴筌??PNG?????????ㅻ깹?????????????????살몝????遺얘턁?????????????????대첉?????????쇰뮡????????饔낅떽??????
	# ??PNG ????????????????쎛 ????????黎앸럽??筌??????????????利?????롮쾸?椰???????곌퇈?????筌뤾쑬???????????꾩룆梨띰쭕????????遺얘턁????????????????繹먮굞彛?????饔낅떽??????
	_erase_nested_value(data[key], _field_suffix(field, "_rect"))
	return _write_json(path, data)

func _replace_catalog_value(asset_id: String, new_path: String) -> bool:
	var path := "res://content/editor/asset_catalog.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return false
	var assets: Array = data.get("assets", [])
	for asset in assets:
		if asset is Dictionary and str(asset.get("asset_id", "")) == asset_id:
			asset["source_path"] = new_path
			asset["source_rect_px"] = [0, 0, current_image.get_width(), current_image.get_height()]
			return _write_json(path, data)
	return false

func _replace_main_path(old_path: String, new_path: String) -> bool:
	var file := FileAccess.open("res://main.gd", FileAccess.READ)
	if file == null: return false
	var text := file.get_as_text()
	file.close()
	if not text.contains(old_path): return false
	text = text.replace(old_path, new_path)
	var out := FileAccess.open(ProjectSettings.globalize_path("res://main.gd"), FileAccess.WRITE)
	if out == null: return false
	out.store_string(text)
	out.close()
	return true

func _write_json(path: String, data: Variant) -> bool:
	var out := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE)
	if out == null: return false
	out.store_string(JSON.stringify(data, "\t"))
	out.close()
	return true
