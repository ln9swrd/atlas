class_name MapEditorMain
extends Control

signal request_content_editor
var initial_map_path := ""

const IMAGE_TEXTURE_LOADER := preload("res://editor/image_texture_loader.gd")

@onready var canvas: EditorCanvas = $MainLayout/CanvasContainer/CanvasRoot
@onready var lbl_selected_id: Label = $MainLayout/Toolbox/VBox/LblSelectedID
@onready var lbl_selected_type: Label = $MainLayout/Toolbox/VBox/LblSelectedType
@onready var lbl_position: Label = $MainLayout/Toolbox/VBox/LblPosition
@onready var lbl_tile_coords: Label = $MainLayout/Toolbox/VBox/LblTileCoords
@onready var lbl_placement_size: Label = $MainLayout/Toolbox/VBox/LblPlacementSize
@onready var spin_placement_width: SpinBox = $MainLayout/Toolbox/VBox/PlacementSizeRow/SpinPlacementWidth
@onready var spin_placement_height: SpinBox = $MainLayout/Toolbox/VBox/PlacementSizeRow/SpinPlacementHeight
@onready var btn_resize_placement: Button = $MainLayout/Toolbox/VBox/BtnResizePlacement
@onready var btn_delete_placement: Button = $MainLayout/Toolbox/VBox/BtnDeletePlacement
@onready var asset_rows: VBoxContainer = $MainLayout/Toolbox/VBox/AssetCatalogSection/AssetScroll/AssetRows
@onready var asset_search: LineEdit = $MainLayout/Toolbox/VBox/AssetCatalogSection/AssetSearch
@onready var btn_open_asset_catalog: Button = $MainLayout/Toolbox/VBox/AssetCatalogSection/BtnOpenAssetCatalog
@onready var btn_clear_catalog_selection: Button = $MainLayout/Toolbox/VBox/AssetCatalogSection/BtnClearCatalogSelection
@onready var asset_preview: TextureRect = $MainLayout/Toolbox/VBox/AssetCatalogSection/AssetPreview
@onready var lbl_asset_preview_status: Label = $MainLayout/Toolbox/VBox/AssetCatalogSection/LblAssetPreviewStatus
@onready var lbl_asset_details: Label = $MainLayout/Toolbox/VBox/AssetCatalogSection/LblAssetDetails
@onready var btn_asset_mode: Button = $MainLayout/Toolbox/VBox/ModeBar/BtnAssetMode
@onready var btn_gameplay_mode: Button = $MainLayout/Toolbox/VBox/ModeBar/BtnGameplayMode
@onready var gameplay_tools: VBoxContainer = $MainLayout/Toolbox/VBox/GameplayTools
@onready var lbl_layer_title: Label = $MainLayout/Toolbox/VBox/LblLayerTitle
@onready var eraser_size_row: HBoxContainer = $MainLayout/Toolbox/VBox/EraserSize
@onready var gameplay_properties: VBoxContainer = $MainLayout/Toolbox/VBox/GameplayProperties
@onready var edit_gameplay_id: LineEdit = $MainLayout/Toolbox/VBox/GameplayProperties/EditGameplayID
@onready var edit_gameplay_name: LineEdit = $MainLayout/Toolbox/VBox/GameplayProperties/EditGameplayName
@onready var spin_gameplay_x: SpinBox = $MainLayout/Toolbox/VBox/GameplayProperties/GameplayPositionRow/SpinGameplayX
@onready var spin_gameplay_y: SpinBox = $MainLayout/Toolbox/VBox/GameplayProperties/GameplayPositionRow/SpinGameplayY
@onready var spin_gameplay_width: SpinBox = $MainLayout/Toolbox/VBox/GameplayProperties/GameplaySizeRow/SpinGameplayWidth
@onready var spin_gameplay_height: SpinBox = $MainLayout/Toolbox/VBox/GameplayProperties/GameplaySizeRow/SpinGameplayHeight
@onready var check_gameplay_enabled: CheckButton = $MainLayout/Toolbox/VBox/GameplayProperties/GameplayEnabled
@onready var option_gameplay_area: OptionButton = $MainLayout/Toolbox/VBox/GameplayProperties/GameplayAreaRow/OptionGameplayArea
@onready var lbl_gameplay_delete_status: Label = $MainLayout/Toolbox/VBox/GameplayProperties/LblGameplayDeleteStatus
@onready var lbl_status: Label = $BottomBar/HBox/LblStatus
@onready var open_map_dialog: FileDialog = $OpenMapDialog
@onready var save_map_dialog: FileDialog = $SaveMapDialog
@onready var lbl_current_tool: Label = $MainLayout/Toolbox/VBox/LblCurrentTool
@onready var lbl_selected_tile: Label = $MainLayout/Toolbox/VBox/LblSelectedTile
@onready var option_layer: OptionButton = $MainLayout/Toolbox/VBox/OptionLayer
@onready var spin_eraser_size: SpinBox = $MainLayout/Toolbox/VBox/EraserSize/SpinEraserSize
@onready var btn_fill_ground: Button = $MainLayout/Toolbox/VBox/BtnFillGround
@onready var map_mode_campaign: CheckButton = $MainLayout/Toolbox/VBox/MapModeCampaign
@onready var map_mode_single: CheckButton = $MainLayout/Toolbox/VBox/MapModeSingle
@onready var map_mode_multiplayer: CheckButton = $MainLayout/Toolbox/VBox/MapModeMultiplayer
@onready var third_alliance: CheckButton = $MainLayout/Toolbox/VBox/ThirdAlliance
@onready var map_mode_hint: Label = $MainLayout/Toolbox/VBox/MapModeHint
@onready var asset_catalog_window: Window = $AssetCatalogWindow
@onready var btn_redo: Button = $BottomBar/HBox/BtnRedo
@onready var btn_validate: Button = $BottomBar/HBox/BtnValidate
@onready var map_selector: OptionButton = $BottomBar/HBox/MapSelector
@onready var btn_new_map: Button = $BottomBar/HBox/BtnNewMap
@onready var btn_duplicate_map: Button = $BottomBar/HBox/BtnDuplicateMap
@onready var btn_delete_map: Button = $BottomBar/HBox/BtnDeleteMap

var map_size_panel: PanelContainer
var map_width_spin: SpinBox
var map_height_spin: SpinBox
var option_layer_view: OptionButton
var gameplay_visibility_toggle: CheckButton

var current_map_path := "map_01"
var current_map_data := {}
var map_dirty := false
var catalog_entries: Array[Dictionary] = []
var preview_texture_cache: Dictionary = {}
var selected_asset_id := ""
const FILE_DIALOG_FAVORITES_PATH := "user://map_editor_file_dialog_favorites.json"

func _ready() -> void:
	asset_catalog_window.close_requested.connect(_on_asset_catalog_closed)
	asset_catalog_window.connect("catalog_saved", _on_asset_catalog_saved)
	open_map_dialog.visibility_changed.connect(_on_file_dialog_visibility_changed)
	save_map_dialog.visibility_changed.connect(_on_file_dialog_visibility_changed)
	if canvas:
		canvas.object_selected.connect(_on_object_selected)
		canvas.map_data_changed.connect(_on_map_data_changed)
		canvas.placement_resize_failed.connect(update_status)
		canvas.placement_rejected.connect(update_status)
		canvas.set_eraser_size(int(spin_eraser_size.value))
	btn_resize_placement.pressed.connect(_on_resize_placement_pressed)
	btn_delete_placement.pressed.connect(_on_delete_placement_pressed)
	btn_fill_ground.pressed.connect(_on_fill_ground_pressed)
	btn_fill_ground.visible = true
	map_mode_campaign.toggled.connect(_on_map_mode_toggled)
	map_mode_single.toggled.connect(_on_map_mode_toggled)
	map_mode_multiplayer.toggled.connect(_on_map_mode_toggled)
	third_alliance.toggled.connect(_on_third_alliance_toggled)
	btn_open_asset_catalog.pressed.connect(_on_open_asset_catalog_pressed)
	btn_clear_catalog_selection.pressed.connect(_clear_catalog_selection)
	asset_search.text_changed.connect(_on_asset_search_changed)
	btn_asset_mode.pressed.connect(_on_asset_mode_pressed)
	btn_gameplay_mode.pressed.connect(_on_gameplay_mode_pressed)
	btn_asset_mode.gui_input.connect(_on_mode_tab_gui_input.bind("ASSET"))
	btn_gameplay_mode.gui_input.connect(_on_mode_tab_gui_input.bind("GAMEPLAY"))
	$MainLayout/Toolbox/VBox/GameplayTools/CommonTools/BtnGameplaySelect.pressed.connect(_on_gameplay_tool_pressed.bind("SELECT"))
	$MainLayout/Toolbox/VBox/GameplayTools/EnemyTools/BtnSpawnArea.pressed.connect(_on_gameplay_tool_pressed.bind("SPAWN_AREA"))
	$MainLayout/Toolbox/VBox/GameplayTools/AllyTools/BtnTowerArea.pressed.connect(_on_gameplay_tool_pressed.bind("TOWER_PLACEMENT_AREA"))
	$MainLayout/Toolbox/VBox/GameplayTools/AllyTools/BtnTowerPoint.pressed.connect(_on_gameplay_tool_pressed.bind("TOWER_PLACEMENT_POINT"))
	$MainLayout/Toolbox/VBox/GameplayTools/AllyTools/BtnRobotPoint.pressed.connect(_on_gameplay_tool_pressed.bind("ROBOT_POSITION_POINT"))
	$MainLayout/Toolbox/VBox/GameplayTools/EnemyTools/BtnGoalArea.pressed.connect(_on_gameplay_tool_pressed.bind("GOAL_AREA"))
	$MainLayout/Toolbox/VBox/GameplayTools/CommonTools/BtnObstacleArea.pressed.connect(_on_gameplay_tool_pressed.bind("OBSTACLE_AREA"))
	$MainLayout/Toolbox/VBox/GameplayTools/CommonTools/BtnMovementArea.pressed.connect(_on_gameplay_tool_pressed.bind("MOVEMENT_AREA"))
	$MainLayout/Toolbox/VBox/GameplayTools/CommonTools/BtnBlockedArea.pressed.connect(_on_gameplay_tool_pressed.bind("BLOCKED_AREA"))
	$MainLayout/Toolbox/VBox/GameplayProperties/BtnApplyGameplayProperties.pressed.connect(_on_apply_gameplay_properties_pressed)
	$MainLayout/Toolbox/VBox/GameplayProperties/BtnDeleteGameplayElement.pressed.connect(_on_delete_gameplay_element_pressed)
	lbl_placement_size.hide()
	spin_placement_width.get_parent().hide()
	btn_resize_placement.hide()
	btn_delete_placement.hide()
	gameplay_properties.hide()
	_build_map_size_controls()
	_set_mode_ui("ASSET")

	setup_layer_options()
	load_asset_catalog()
	_load_file_dialog_favorites()
	if not initial_map_path.is_empty():
		current_map_path = initial_map_path
	btn_new_map.pressed.connect(_on_btn_new_map_pressed)
	btn_duplicate_map.pressed.connect(_on_btn_duplicate_map_pressed)
	btn_delete_map.pressed.connect(_on_btn_delete_map_pressed)
	map_selector.item_selected.connect(_on_map_selector_item_selected)
	_refresh_map_selector(current_map_path)
	load_map(current_map_path)

func load_asset_catalog(preferred_asset_id: String = "", force_clear_selection: bool = false) -> void:
	var desired_asset_id := selected_asset_id
	if not preferred_asset_id.is_empty() or force_clear_selection:
		desired_asset_id = preferred_asset_id
	var parsed: Variant = ContentCatalogLoader.load_document("asset_catalog")
	if not parsed is Dictionary or not parsed.get("assets", []) is Array:
		update_status("Invalid asset catalog in SQLite")
		return
	catalog_entries.clear()
	asset_preview.texture = null
	lbl_asset_preview_status.text = ""
	preview_texture_cache.clear()
	for value in parsed.get("assets", []):
		if value is Dictionary:
			var entry: Dictionary = value.duplicate(true)
			catalog_entries.append(entry)
	if canvas:
		canvas.set_catalog_assets(catalog_entries)
	_rebuild_asset_rows()
	var selected_index := _find_catalog_asset_index(desired_asset_id)
	if selected_index >= 0:
		_select_catalog_asset(selected_index)
	else:
		selected_asset_id = ""
		if canvas:
			canvas.set_catalog_asset({})
		lbl_asset_details.text = ""

func _clear_catalog_selection() -> void:
	selected_asset_id = ""
	if canvas:
		canvas.set_catalog_asset({})
	asset_preview.texture = null
	lbl_asset_preview_status.text = ""
	lbl_asset_details.text = ""
	update_selected_tile_label("None")
	update_tool_label("CATALOG: None")
	update_status("Catalog selection cleared.")

func _find_catalog_asset_index(asset_id: String) -> int:
	if asset_id.is_empty():
		return -1
	for index in range(catalog_entries.size()):
		if str(catalog_entries[index].get("asset_id", "")) == asset_id:
			return index
	return -1

func _on_asset_search_changed(_text: String) -> void:
	_rebuild_asset_rows()

func _rebuild_asset_rows() -> void:
	for child in asset_rows.get_children():
		child.queue_free()
	var grouped_entries: Dictionary = {}
	var query := asset_search.text.strip_edges().to_lower()
	for index in range(catalog_entries.size()):
		var entry_name := str(catalog_entries[index].get("display_name", catalog_entries[index].get("asset_id", "")))
		if not query.is_empty() and not entry_name.to_lower().contains(query):
			continue
		var group_name := str(catalog_entries[index].get("group", "Other"))
		var group_indices: Array = grouped_entries.get(group_name, [])
		group_indices.append(index)
		grouped_entries[group_name] = group_indices
	var group_names: Array = grouped_entries.keys()
	group_names.sort()
	if group_names.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No search results."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		asset_rows.add_child(empty_label)
		return
	for group_name in group_names:
		var heading := Label.new()
		heading.text = str(group_name).to_upper()
		heading.add_theme_font_size_override("font_size", 12)
		asset_rows.add_child(heading)
		var indices: Array = grouped_entries[group_name]
		indices.sort_custom(func(left: int, right: int) -> bool:
			var left_name := str(catalog_entries[left].get("display_name", catalog_entries[left].get("asset_id", "?")))
			var right_name := str(catalog_entries[right].get("display_name", catalog_entries[right].get("asset_id", "?")))
			return left_name.naturalnocasecmp_to(right_name) < 0
		)
		for index in indices:
			var entry: Dictionary = catalog_entries[index]
			var row := HBoxContainer.new()
			row.custom_minimum_size.y = 62
			asset_rows.add_child(row)
			var image_button := TextureButton.new()
			image_button.custom_minimum_size = Vector2(64, 58)
			image_button.ignore_texture_size = true
			image_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			image_button.texture_normal = _catalog_entry_preview(entry)
			image_button.tooltip_text = "Select asset; double-click to edit its source image or region"
			image_button.pressed.connect(_on_catalog_image_pressed.bind(index))
			image_button.gui_input.connect(_on_catalog_asset_gui_input.bind(index, "image"))
			row.add_child(image_button)
			var text_button := Button.new()
			text_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			text_button.custom_minimum_size.y = 58
			text_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			text_button.text = "%s\n%s" % [entry.get("display_name", entry.get("asset_id", "?")), str(entry.get("kind", "tile")).capitalize()]
			text_button.tooltip_text = "Select asset; double-click to edit its metadata"
			text_button.pressed.connect(_on_catalog_text_pressed.bind(index))
			text_button.gui_input.connect(_on_catalog_asset_gui_input.bind(index, "metadata"))
			row.add_child(text_button)

func _catalog_entry_preview(entry: Dictionary) -> Texture2D:
	var source_path := str(entry.get("source_path", ""))
	var source_texture: Texture2D = preview_texture_cache.get(source_path)
	if source_texture == null and not source_path.is_empty():
		var loaded: Texture2D = IMAGE_TEXTURE_LOADER.load_texture(source_path)
		if loaded != null:
			source_texture = loaded
			preview_texture_cache[source_path] = source_texture
	if source_texture == null:
		return null
	var rect_values: Array = entry.get("source_rect_px", [])
	if rect_values.size() < 4:
		return null
	var rect := Rect2(float(rect_values[0]), float(rect_values[1]), float(rect_values[2]), float(rect_values[3]))
	if rect.position.x < 0.0 or rect.position.y < 0.0 or rect.size.x <= 0.0 or rect.size.y <= 0.0 or rect.end.x > source_texture.get_width() or rect.end.y > source_texture.get_height():
		return null
	var preview := AtlasTexture.new()
	preview.atlas = source_texture
	preview.region = rect
	return preview

func _select_catalog_asset(index: int) -> void:
	if index < 0 or index >= catalog_entries.size():
		return
	var entry: Dictionary = catalog_entries[index]
	selected_asset_id = str(entry.get("asset_id", ""))
	if canvas:
		canvas.set_catalog_asset(entry)
	_set_mode_ui("ASSET")
	set_asset_preview(entry)
	var rect: Array = entry.get("source_rect_px", [0, 0, 0, 0])
	var footprint := canvas.catalog_asset_footprint(entry)
	lbl_asset_details.text = "%s\\n%s / %s\\nID: %s\\nSource: %s\\nPixels: %s\\nFootprint: %s x %s" % [entry.get("display_name", ""), str(entry.get("kind", "tile")).capitalize(), entry.get("group", ""), entry.get("asset_id", ""), entry.get("source_path", ""), str(rect), str(footprint.x), str(footprint.y)]
	update_tool_label("CATALOG: " + str(entry.get("display_name", entry.get("asset_id", ""))))
	var asset_kind := str(entry.get("kind", "tile"))
	var asset_group := str(entry.get("group", ""))
	if asset_kind == "tile":
		var layer_by_group := {"Ground": "Ground", "Vegetation": "Vegetation", "RoadComposition": "RoadComposition"}
		if layer_by_group.has(asset_group):
			canvas.set_active_layer(str(layer_by_group[asset_group]))
	btn_fill_ground.visible = canvas.active_layer == "Ground"
	canvas.set_edit_mode("PAINT")
	update_selected_tile_label(str(entry.get("display_name", entry.get("asset_id", "Selected asset"))))

func _on_catalog_image_pressed(index: int) -> void:
	_select_catalog_asset(index)

func _on_catalog_text_pressed(index: int) -> void:
	_select_catalog_asset(index)

func _on_catalog_asset_gui_input(event: InputEvent, index: int, edit_target: String) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.double_click:
			_open_catalog_editor(index, edit_target)

func _open_catalog_editor(index: int, edit_target: String) -> void:
	if index < 0 or index >= catalog_entries.size():
		return
	_select_catalog_asset(index)
	asset_catalog_window.call("open_for_asset_id", selected_asset_id, edit_target)
	_popup_asset_catalog_window()
	asset_catalog_window.call_deferred("focus_edit_target", edit_target)

func _on_open_asset_catalog_pressed() -> void:
	var selected_index := _find_catalog_asset_index(selected_asset_id)
	if selected_index >= 0:
		_open_catalog_editor(selected_index, "metadata")
		return
	asset_catalog_window.call("open_catalog")
	_popup_asset_catalog_window()
	asset_catalog_window.call_deferred("focus_edit_target", "metadata")

func _popup_asset_catalog_window() -> void:
	if asset_catalog_window.mode == Window.MODE_MAXIMIZED:
		asset_catalog_window.popup()
	else:
		asset_catalog_window.popup_centered(Vector2i(1280, 820))

func _on_asset_catalog_saved(asset_id: String) -> void:
	load_asset_catalog(asset_id, true)

func _on_asset_catalog_closed() -> void:
	load_asset_catalog()

func _build_map_size_controls() -> void:
	map_size_panel = PanelContainer.new()
	map_size_panel.custom_minimum_size.y = 64
	var box := VBoxContainer.new()
	map_size_panel.add_child(box)
	var title := Label.new()
	title.text = "MAP SIZE (32 px / tile)"
	title.add_theme_font_size_override("font_size", 13)
	box.add_child(title)
	var row := HBoxContainer.new()
	box.add_child(row)
	var width_label := Label.new()
	width_label.text = "W"
	row.add_child(width_label)
	map_width_spin = SpinBox.new()
	map_width_spin.min_value = 1
	map_width_spin.max_value = 256
	map_width_spin.step = 1
	map_width_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_width_spin.value_changed.connect(_on_map_size_spin_changed)
	row.add_child(map_width_spin)
	var height_label := Label.new()
	height_label.text = "H"
	row.add_child(height_label)
	map_height_spin = SpinBox.new()
	map_height_spin.min_value = 1
	map_height_spin.max_value = 256
	map_height_spin.step = 1
	map_height_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_height_spin.value_changed.connect(_on_map_size_spin_changed)
	row.add_child(map_height_spin)
	var apply := Button.new()
	apply.text = "Apply"
	apply.disabled = false
	apply.tooltip_text = "Apply the current map width and height."
	apply.pressed.connect(_on_map_size_apply_pressed)
	row.add_child(apply)
	$MainLayout/Toolbox/VBox.add_child(map_size_panel)
	$MainLayout/Toolbox/VBox.move_child(map_size_panel, 0)

func _sync_map_size_controls() -> void:
	if map_width_spin == null or current_map_data.is_empty():
		return
	var tile_value: Variant = current_map_data.get("map_tiles", [36, 24])
	var tiles := Vector2i(int(tile_value[0]), int(tile_value[1])) if tile_value is Array and tile_value.size() >= 2 else Vector2i(36, 24)
	map_width_spin.value = tiles.x
	map_height_spin.value = tiles.y

func _on_map_size_spin_changed(_value: float) -> void:
	if current_map_data.is_empty() or canvas == null or map_width_spin == null or map_height_spin == null:
		return
	var new_size := Vector2i(maxi(1, int(map_width_spin.value)), maxi(1, int(map_height_spin.value)))
	var old_value: Variant = current_map_data.get("map_tiles", [36, 24])
	var old_size := Vector2i(int(old_value[0]), int(old_value[1])) if old_value is Array and old_value.size() >= 2 else Vector2i(36, 24)
	if new_size == old_size:
		return
	if (new_size.x < old_size.x or new_size.y < old_size.y) and not _map_size_can_contain(new_size):
		_sync_map_size_controls()
		update_status("Resize rejected: existing content is outside the new map bounds.")
		return
	current_map_data["map_tiles"] = [new_size.x, new_size.y]
	current_map_data["map_pixel_size"] = [new_size.x * 32, new_size.y * 32]
	canvas.set_map_size_preview(new_size)
	current_map_data = canvas.map_data
	update_status("Map size changed: %d x %d. Preview updated." % [new_size.x, new_size.y])

func _on_map_size_apply_pressed() -> void:
	if current_map_data.is_empty() or canvas == null:
		return
	var new_size := Vector2i(maxi(1, int(map_width_spin.value)), maxi(1, int(map_height_spin.value)))
	var old_value: Variant = current_map_data.get("map_tiles", [36, 24])
	var old_size := Vector2i(int(old_value[0]), int(old_value[1])) if old_value is Array and old_value.size() >= 2 else Vector2i(36, 24)
	if new_size == old_size:
		update_status("Map size is already %d x %d." % [new_size.x, new_size.y])
		return
	if (new_size.x < old_size.x or new_size.y < old_size.y) and not _map_size_can_contain(new_size):
		_sync_map_size_controls()
		update_status("Resize rejected: existing content is outside the new map bounds.")
		return
	current_map_data["map_tiles"] = [new_size.x, new_size.y]
	current_map_data["map_pixel_size"] = [new_size.x * 32, new_size.y * 32]
	canvas.set_map_data(current_map_data)
	_sync_map_size_controls()
	update_status("Map size applied: %d x %d (%d x %d px)." % [new_size.x, new_size.y, new_size.x * 32, new_size.y * 32])

func _map_size_can_contain(new_size: Vector2i) -> bool:
	var pixel_size := Vector2(new_size) * 32.0
	var origin_value: Variant = current_map_data.get("map_origin", [0, 58])
	var origin := _map_data_position(origin_value, Vector2(0, 58))
	var bounds := Rect2(origin, pixel_size)
	if current_map_data.has("tiles"):
		var layers: Dictionary = current_map_data["tiles"]
		for layer_name in layers.keys():
			var layer_tiles: Dictionary = layers[layer_name]
			for key in layer_tiles.keys():
				var parts := str(key).split(",")
				if parts.size() >= 2:
					var cell := Vector2i(parts[0].to_int(), parts[1].to_int())
					if cell.x < 0 or cell.y < 0 or cell.x >= new_size.x or cell.y >= new_size.y:
						return false
	for object_data in current_map_data.get("objects", []):
			if object_data is Dictionary:
				var pos := _map_data_position(object_data.get("position", []), origin)
				var footprint: Array = object_data.get("footprint_tiles", object_data.get("footprint_override", [1, 1]))
				var size := Vector2(32, 32)
				if footprint.size() >= 2:
					size = Vector2(maxi(1, int(footprint[0])), maxi(1, int(footprint[1]))) * 32.0
				if not bounds.encloses(Rect2(pos, size)):
					return false
	for area in current_map_data.get("gameplay_areas", []):
			if area is Dictionary:
				var area_pos := _map_data_position(area.get("position", []), origin)
				var area_size_values: Array = area.get("size", [32, 32])
				var area_size := Vector2(32, 32)
				if area_size_values.size() >= 2:
					area_size = Vector2(float(area_size_values[0]), float(area_size_values[1]))
				if not bounds.encloses(Rect2(area_pos, area_size)):
					return false
	for point in current_map_data.get("gameplay_points", []):
			if point is Dictionary and not bounds.has_point(_map_data_position(point.get("position", []), origin)):
				return false
	for key in current_map_data.get("lanes", {}):
			if not bounds.has_point(_map_data_position(current_map_data["lanes"][key], origin)):
				return false
	if current_map_data.has("base") and not bounds.has_point(_map_data_position(current_map_data["base"], origin)):
		return false
	return true

func _map_data_position(value: Variant, origin: Vector2) -> Vector2:
	if value is Vector2:
		return value
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return origin

func setup_layer_options() -> void:
	if option_layer:
		option_layer.clear()
		option_layer.add_item("Ground Layer", 0)
		option_layer.add_item("Vegetation Layer", 1)
		option_layer.add_item("Road Layer", 2)
		option_layer.select(0)
		option_layer.item_selected.connect(_on_edit_layer_selected)

	if option_layer_view == null:
		var parent := option_layer.get_parent() as Container
		if parent != null:
			var view_label := Label.new()
			view_label.text = "View Layer"
			view_label.tooltip_text = "Select the layer shown in the map preview."
			option_layer_view = OptionButton.new()
			option_layer_view.name = "OptionLayerView"
			option_layer_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			option_layer_view.add_item("All Layers", 0)
			option_layer_view.add_item("Ground Layer", 1)
			option_layer_view.add_item("Vegetation Layer", 2)
			option_layer_view.add_item("Road Layer", 3)
			option_layer_view.select(0)
			option_layer_view.item_selected.connect(_on_layer_view_selected)
			var index := parent.get_children().find(option_layer)
			parent.add_child(view_label)
			parent.move_child(view_label, index)
			parent.add_child(option_layer_view)
			parent.move_child(option_layer_view, index + 1)
			gameplay_visibility_toggle = CheckButton.new()
			gameplay_visibility_toggle.name = "GameplayVisibilityToggle"
			gameplay_visibility_toggle.text = "Gameplay Elements"
			gameplay_visibility_toggle.tooltip_text = "Toggle gameplay element visibility."
			gameplay_visibility_toggle.button_pressed = true
			gameplay_visibility_toggle.toggled.connect(_on_gameplay_visibility_toggled)
			parent.add_child(gameplay_visibility_toggle)
			parent.move_child(gameplay_visibility_toggle, index + 2)

func _on_edit_layer_selected(index: int) -> void:
	var layer_names := ["Ground", "Vegetation", "RoadComposition"]
	if index >= 0 and index < layer_names.size() and canvas:
		canvas.set_active_layer(layer_names[index])

func _on_layer_view_selected(index: int) -> void:
	var layer_names := ["ALL", "Ground", "Vegetation", "RoadComposition"]
	if index >= 0 and index < layer_names.size() and canvas:
		canvas.set_visible_layer(layer_names[index])
		update_status("Visible layer: %s" % ("All" if index == 0 else layer_names[index]))

func _on_gameplay_visibility_toggled(visible: bool) -> void:
	if canvas:
		canvas.set_gameplay_visible(visible)
	update_status("Gameplay elements: %s" % ("Visible" if visible else "Hidden"))

func _sync_map_play_mode_controls() -> void:
	var modes: Array = canvas.map_data.get("play_modes", ["campaign", "single", "multiplayer"]) if canvas and canvas.map_data.get("play_modes", []) is Array else ["campaign", "single", "multiplayer"]
	map_mode_campaign.set_pressed_no_signal("campaign" in modes)
	map_mode_single.set_pressed_no_signal("single" in modes)
	map_mode_multiplayer.set_pressed_no_signal("multiplayer" in modes)
	var multiplayer: Dictionary = canvas.map_data.get("multiplayer", {}) if canvas and canvas.map_data.get("multiplayer", {}) is Dictionary else {}
	third_alliance.set_pressed_no_signal(bool(multiplayer.get("third_alliance_enabled", false)))
	third_alliance.visible = map_mode_multiplayer.button_pressed
	map_mode_hint.visible = map_mode_multiplayer.button_pressed
	map_mode_hint.text = "Multiplayer maps can use allied, enemy, and third-faction AI units."

func _on_map_mode_toggled(_pressed: bool) -> void:
	if not canvas:
		return
	var modes: Array[String] = []
	if map_mode_campaign.button_pressed:
		modes.append("campaign")
	if map_mode_single.button_pressed:
		modes.append("single")
	if map_mode_multiplayer.button_pressed:
		modes.append("multiplayer")
	if modes.is_empty():
		map_mode_single.set_pressed_no_signal(true)
		modes.append("single")
	canvas.map_data["play_modes"] = modes
	third_alliance.visible = map_mode_multiplayer.button_pressed
	map_mode_hint.visible = map_mode_multiplayer.button_pressed
	if map_mode_multiplayer.button_pressed:
		_ensure_multiplayer_config()
	_update_map_mode_status()

func _on_third_alliance_toggled(enabled: bool) -> void:
	if not canvas:
		return
	_ensure_multiplayer_config()
	var multiplayer: Dictionary = canvas.map_data["multiplayer"]
	multiplayer["third_alliance_enabled"] = enabled
	_update_map_mode_status()

func _ensure_multiplayer_config() -> void:
	if not canvas.map_data.has("multiplayer") or not canvas.map_data["multiplayer"] is Dictionary:
		canvas.map_data["multiplayer"] = {}
	var multiplayer: Dictionary = canvas.map_data["multiplayer"]
	multiplayer["enabled"] = true
	multiplayer["alliance_controllers"] = {"ally": "ai", "enemy": "ai", "third": "ai"}
	if not multiplayer.has("third_alliance_enabled"):
		multiplayer["third_alliance_enabled"] = false
	multiplayer["alliances"] = [
		{"id": "ally", "name": "Allied Unit", "controller": "ai"},
		{"id": "enemy", "name": "Enemy Unit", "controller": "ai"},
		{"id": "third", "name": "Third Faction Unit", "controller": "ai"}
	]
	multiplayer["relations"] = {
		"ally": {"enemy": "hostile", "third": "hostile"},
		"enemy": {"ally": "hostile", "third": "hostile"},
		"third": {"ally": "hostile", "enemy": "hostile"}
	}

func _update_map_mode_status() -> void:
	var modes: Array[String] = []
	if map_mode_campaign.button_pressed:
		modes.append("Campaign")
	if map_mode_single.button_pressed:
		modes.append("Single Play")
	if map_mode_multiplayer.button_pressed:
		modes.append("Multiplayer")
	var mode_text := ", ".join(modes)
	update_status("Map mode: %s" % mode_text)

func load_map(path: String) -> void:
	if map_dirty:
		update_status("Load blocked: unsaved changes exist. Save the current map first.")
		return
	current_map_path = path
	current_map_data = MapLoader.load_map_data(path)
	if current_map_data.is_empty():
		update_status("FAILED to load map data from: " + path)
		return

	if canvas:
		canvas.set_map_data(current_map_data)
	map_dirty = false
	_sync_map_size_controls()
	_sync_map_play_mode_controls()
	var linked_stages := _find_linked_stages(path)
	if linked_stages.is_empty():
		update_status("Loaded map: %s | No linked stages" % path)
	else:
		update_status("Loaded map: %s | Linked stages: %s" % [path, ", ".join(linked_stages)])

func _find_linked_stages(map_path: String) -> Array[String]:
	var result: Array[String] = []
	var catalog: Dictionary = ContentCatalogLoader.load_document("stage_catalog")
	for stage_id in catalog.get("stages", []):
		var id := str(stage_id)
		var stage_path := id
		var stage_data := StageLoader.load_stage_data(stage_path)
		if not stage_data.is_empty() and str(stage_data.get("map_file", "")) == map_path:
			result.append(str(stage_data.get("stage_id", id)))
	result.sort()
	return result

func save_map() -> void:
	if current_map_data.is_empty():
		update_status("Cannot save: No map data loaded")
		return

	if canvas:
		current_map_data = canvas.map_data

	var validation := validate_map()
	if not validation.get("errors", []).is_empty():
		update_status("Save blocked: validation failed. " + str(validation.get("errors", [])[0]))
		return

	var success := MapLoader.save_map_data(current_map_path, current_map_data)
	if success:
		map_dirty = false
		update_status("SAVED map successfully to: " + current_map_path)
	else:
		update_status("FAILED to save map to: " + current_map_path)

func _on_file_dialog_visibility_changed() -> void:
	if not open_map_dialog.visible and not save_map_dialog.visible:
		_save_file_dialog_favorites()

func _load_file_dialog_favorites() -> void:
	var settings := ContentCatalogLoader.load_document("editor")
	var values: Variant = settings.get("map_editor_file_dialog_favorites", [])
	if not values is Array:
		return
	var favorites := PackedStringArray()
	for favorite in values:
		var path := str(favorite)
		if not path.is_empty() and not favorites.has(path):
			favorites.append(path)
	FileDialog.set_favorite_list(favorites)

func _save_file_dialog_favorites() -> void:
	var settings := ContentCatalogLoader.load_document("editor")
	settings["map_editor_file_dialog_favorites"] = Array(FileDialog.get_favorite_list())
	if not ObjectPersistence.save_content_document("editor", settings):
		push_warning("MapEditor: failed to save file dialog favorites to SQLite")

func set_dialog_path(dialog: FileDialog) -> void:
	_save_file_dialog_favorites()
	var global_map_path := current_map_path
	if global_map_path.begins_with("res://") or global_map_path.begins_with("user://"):
		global_map_path = ProjectSettings.globalize_path(global_map_path)
	dialog.current_dir = global_map_path.get_base_dir()
	dialog.current_file = global_map_path.get_file()

func update_status(text: String) -> void:
	if lbl_status:
		var dirty_suffix := " [UNSAVED]" if map_dirty else ""
		lbl_status.text = "Status: " + text + dirty_suffix

func _on_btn_redo_pressed() -> void:
	if canvas == null:
		return
	var before := canvas.map_data.duplicate(true)
	canvas.redo_last_edit()
	if JSON.stringify(before) != JSON.stringify(canvas.map_data):
		current_map_data = canvas.map_data
		map_dirty = true
		update_status("Redo applied.")

func validate_map() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	if current_map_data.is_empty():
		errors.append("Map data is not loaded.")
		return {"errors": errors, "warnings": warnings}

	var map_id := str(current_map_data.get("map_id", current_map_path))
	if map_id.strip_edges().is_empty():
		errors.append("Map ID is empty.")
	var map_name := str(current_map_data.get("name", ""))
	if map_name.strip_edges().is_empty():
		warnings.append("Map display name is empty.")

	var map_tiles_value: Variant = current_map_data.get("map_tiles", current_map_data.get("map_size", [36, 24]))
	var map_tiles := Vector2i(0, 0)
	if map_tiles_value is Vector2i:
		map_tiles = map_tiles_value
	elif map_tiles_value is Array and map_tiles_value.size() >= 2:
		map_tiles = Vector2i(int(map_tiles_value[0]), int(map_tiles_value[1]))
	if map_tiles.x <= 0 or map_tiles.y <= 0:
		errors.append("Map tile size must be positive.")

	var origin := _map_data_position(current_map_data.get("map_origin", [0, 58]), Vector2.ZERO)
	var pixel_size := _map_data_position(current_map_data.get("map_pixel_size", [map_tiles.x * 32, map_tiles.y * 32]), Vector2.ZERO)
	var expected_size := Vector2(map_tiles) * 32.0
	if pixel_size != expected_size:
		errors.append("Map pixel size does not match map tile size (32px grid).")
	var bounds := Rect2(origin, pixel_size)

	var ids: Dictionary = {}
	for area_value in current_map_data.get("gameplay_areas", []):
		if not area_value is Dictionary:
			errors.append("Invalid gameplay area entry.")
			continue
		var area: Dictionary = area_value
		var area_id := str(area.get("id", ""))
		if area_id.is_empty():
			errors.append("Gameplay Area has an empty ID.")
		elif ids.has(area_id):
			errors.append("Duplicate gameplay ID: " + area_id)
		else:
			ids[area_id] = true
		var area_pos := _map_data_position(area.get("position", [0, 0]), Vector2.ZERO)
		var area_size := _map_data_position(area.get("size", [32, 32]), Vector2(32, 32))
		if area_size.x <= 0 or area_size.y <= 0:
			errors.append("Gameplay Area has invalid size: " + area_id)
		elif not bounds.encloses(Rect2(area_pos, area_size)):
			errors.append("Gameplay Area is outside Map Bounds: " + area_id)

	for point_value in current_map_data.get("gameplay_points", []):
		if not point_value is Dictionary:
			errors.append("Invalid gameplay point entry.")
			continue
		var point: Dictionary = point_value
		var point_id := str(point.get("id", ""))
		if point_id.is_empty():
			errors.append("Gameplay Point has an empty ID.")
		elif ids.has(point_id):
			errors.append("Duplicate gameplay ID: " + point_id)
		else:
			ids[point_id] = true
		var point_pos := _map_data_position(point.get("position", [0, 0]), Vector2.ZERO)
		if not bounds.has_point(point_pos):
			errors.append("Gameplay Point is outside Map Bounds: " + point_id)
		var area_id := str(point.get("area_id", ""))
		if not area_id.is_empty() and not ids.has(area_id) and not _gameplay_area_id_exists(area_id):
			errors.append("Gameplay Point references a missing Area: " + point_id)

	var catalog_ids: Dictionary = {}
	for entry in catalog_entries:
		var asset_id := str(entry.get("asset_id", ""))
		if not asset_id.is_empty():
			catalog_ids[asset_id] = true
	for object_value in current_map_data.get("objects", []):
		if not object_value is Dictionary:
			errors.append("Invalid map object entry.")
			continue
		var object_data: Dictionary = object_value
		var asset_id := str(object_data.get("asset_id", ""))
		if asset_id.is_empty():
			errors.append("Map object has an empty Asset ID.")
		elif not catalog_ids.has(asset_id):
			errors.append("Map object references missing Catalog Asset: " + asset_id)
		var object_pos := _map_data_position(object_data.get("position", [0, 0]), Vector2.ZERO)
		var footprint_value: Variant = object_data.get("footprint_tiles", object_data.get("footprint", [1, 1]))
		var footprint := _map_data_position(footprint_value, Vector2.ONE) * 32.0
		if not bounds.encloses(Rect2(object_pos, footprint)):
			errors.append("Map object is outside Map Bounds: " + asset_id)

	var base_value: Variant = current_map_data.get("base", null)
	if base_value == null:
		errors.append("Required Base position is missing.")
	else:
		var base_pos := _map_data_position(base_value, Vector2.ZERO)
		if not bounds.has_point(base_pos):
			errors.append("Required Base position is outside Map Bounds.")

	for legacy_field in ["spawns", "robot_spots"]:
		var legacy_points: Variant = current_map_data.get(legacy_field, {})
		if legacy_points is Dictionary:
			for legacy_id in legacy_points.keys():
				var legacy_value: Variant = legacy_points[legacy_id]
				var legacy_pos := _map_data_position(legacy_value if not legacy_value is Dictionary else legacy_value.get("position", [0, 0]), Vector2.ZERO)
				if not bounds.has_point(legacy_pos):
					errors.append("%s is outside Map Bounds: %s" % [legacy_field, str(legacy_id)])

	var linked_stages := _find_linked_stages(current_map_path)
	if linked_stages.is_empty():
		warnings.append("No Stage currently references this Map.")
	return {"errors": errors, "warnings": warnings}

func _gameplay_area_id_exists(area_id: String) -> bool:
	for area_value in current_map_data.get("gameplay_areas", []):
		if area_value is Dictionary and str(area_value.get("id", "")) == area_id:
			return true
	return false

func _on_btn_validate_pressed() -> void:
	var result := validate_map()
	var errors: Array = result.get("errors", [])
	var warnings: Array = result.get("warnings", [])
	var lines: Array[String] = ["MAP VALIDATION", "", "Errors: %d" % errors.size(), "Warnings: %d" % warnings.size()]
	if not errors.is_empty():
		lines.append("")
		lines.append("ERRORS")
		for message in errors:
			lines.append("• " + str(message))
	if not warnings.is_empty():
		lines.append("")
		lines.append("WARNINGS")
		for message in warnings:
			lines.append("• " + str(message))
	var dialog := AcceptDialog.new()
	dialog.title = "Map Validation"
	dialog.dialog_text = "\n".join(lines)
	dialog.min_size = Vector2i(760, 520)
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.close_requested.connect(dialog.queue_free)
	dialog.popup_centered()
	if errors.is_empty():
		update_status("Validation PASS: %d warning(s)." % warnings.size())
	else:
		update_status("Validation FAIL: %d error(s), %d warning(s)." % [errors.size(), warnings.size()])

func _on_object_selected(info: Dictionary) -> void:
	var placement_type := str(info.get("type", ""))
	var can_resize := placement_type in ["Catalog Object", "Catalog Tile", "Catalog Tile Overlay"]
	var is_legacy_gameplay_point := placement_type in ["Goal", "Spawn", "Tower Slot", "Robot Spot"]
	var is_gameplay := placement_type in ["Gameplay Area", "Gameplay Point"] or is_legacy_gameplay_point
	var is_gameplay_area := placement_type == "Gameplay Area"
	var is_required_base := placement_type == "Goal"
	lbl_placement_size.visible = can_resize
	spin_placement_width.get_parent().visible = can_resize
	btn_resize_placement.visible = can_resize
	btn_resize_placement.disabled = not can_resize
	btn_delete_placement.visible = can_resize
	btn_delete_placement.disabled = not can_resize
	gameplay_properties.visible = is_gameplay
	$MainLayout/Toolbox/VBox/GameplayProperties/BtnDeleteGameplayElement.disabled = is_required_base
	lbl_gameplay_delete_status.visible = is_required_base
	if is_required_base:
		lbl_gameplay_delete_status.text = "Required runtime Base; deletion is disabled."
	if info.is_empty():
		lbl_selected_id.text = "ID: None"
		lbl_selected_type.text = "Type: -"
		lbl_position.text = "Position: -"
		lbl_tile_coords.text = "Tile: -"
		return

	var pos: Vector2 = info.get("position", Vector2.ZERO)
	var origin := _map_data_position(current_map_data.get("map_origin", [0, 58]), Vector2(0, 58))
	var tile_x := int((pos.x - origin.x) / 32.0)
	var tile_y := int((pos.y - origin.y) / 32.0)

	lbl_selected_id.text = "ID: " + str(info.get("id", "-"))
	lbl_selected_type.text = "Type: " + str(info.get("type", "-"))
	lbl_position.text = "Position: (%.1f, %.1f)" % [pos.x, pos.y]
	lbl_tile_coords.text = "Tile Coords: (%d, %d)" % [tile_x, tile_y]
	if is_gameplay:
		edit_gameplay_id.text = str(info.get("id", ""))
		edit_gameplay_name.text = str(info.get("name", "Base HQ" if is_required_base else placement_type))
		edit_gameplay_id.editable = not is_required_base
		edit_gameplay_name.editable = not is_legacy_gameplay_point
		spin_gameplay_x.value = pos.x
		spin_gameplay_y.value = pos.y
		check_gameplay_enabled.button_pressed = bool(info.get("enabled", true))
		check_gameplay_enabled.disabled = is_legacy_gameplay_point
		$MainLayout/Toolbox/VBox/GameplayProperties/GameplaySizeRow.visible = is_gameplay_area
		$MainLayout/Toolbox/VBox/GameplayProperties/GameplayAreaRow.visible = placement_type == "Gameplay Point"
		if is_gameplay_area:
			var area_size: Vector2 = info.get("size", Vector2(32, 32))
			spin_gameplay_width.value = area_size.x
			spin_gameplay_height.value = area_size.y
		else:
			_refresh_gameplay_area_options(str(info.get("area_id", "")))
	elif can_resize:
		var footprint: Variant = info.get("footprint", [1, 1])
		if footprint is Array and footprint.size() >= 2:
			spin_placement_width.value = int(footprint[0])
			spin_placement_height.value = int(footprint[1])

func _set_mode_ui(mode: String) -> void:
	var is_gameplay_mode := mode == "GAMEPLAY"
	btn_asset_mode.button_pressed = not is_gameplay_mode
	btn_gameplay_mode.button_pressed = is_gameplay_mode
	gameplay_tools.visible = is_gameplay_mode
	for node in [lbl_layer_title, option_layer, $MainLayout/Toolbox/VBox/BtnSelect, $MainLayout/Toolbox/VBox/BtnErase, eraser_size_row, btn_fill_ground]:
		node.visible = not is_gameplay_mode
	btn_fill_ground.visible = not is_gameplay_mode and canvas != null and canvas.active_layer == "Ground"
	var asset_nodes = [lbl_placement_size, spin_placement_width.get_parent(), btn_resize_placement, btn_delete_placement, $MainLayout/Toolbox/VBox/AssetCatalogSection, asset_preview, lbl_asset_preview_status, lbl_asset_details]
	for node in asset_nodes:
		node.visible = not is_gameplay_mode

func _on_mode_tab_gui_input(event: InputEvent, mode: String) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	call_deferred("_apply_mode_tab", mode)
	accept_event()

func _apply_mode_tab(mode: String) -> void:
	if mode == "GAMEPLAY":
		_on_gameplay_mode_pressed()
	else:
		_on_asset_mode_pressed()

func _on_asset_mode_pressed() -> void:
	canvas.set_editor_mode("ASSET")
	_set_mode_ui("ASSET")
	update_tool_label("ASSET")

func _on_gameplay_mode_pressed() -> void:
	canvas.set_gameplay_tool("SELECT")
	_set_mode_ui("GAMEPLAY")
	update_tool_label("GAMEPLAY: SELECT / MOVE")

func _on_gameplay_tool_pressed(tool: String) -> void:
	canvas.set_gameplay_tool(tool)
	_set_mode_ui("GAMEPLAY")
	update_tool_label("GAMEPLAY: " + tool.replace("_", " "))
	update_selected_tile_label("Click to place or select")

func _refresh_gameplay_area_options(selected_area_id: String) -> void:
	option_gameplay_area.clear()
	option_gameplay_area.add_item("No Area")
	option_gameplay_area.set_item_metadata(0, "")
	var selected_index := 0
	var areas: Array = canvas.map_data.get("gameplay_areas", [])
	for area in areas:
		if not area is Dictionary:
			continue
		var area_id := str(area.get("id", ""))
		option_gameplay_area.add_item(str(area.get("name", area_id)))
		option_gameplay_area.set_item_metadata(option_gameplay_area.item_count - 1, area_id)
		if area_id == selected_area_id:
			selected_index = option_gameplay_area.item_count - 1
	option_gameplay_area.select(selected_index)

func _on_apply_gameplay_properties_pressed() -> void:
	var selected_type := str(canvas.selected_object.get("type", ""))
	var area_id := ""
	if selected_type == "Gameplay Point" and option_gameplay_area.selected >= 0:
		area_id = str(option_gameplay_area.get_item_metadata(option_gameplay_area.selected))
	if not canvas.update_selected_gameplay_properties(edit_gameplay_id.text, edit_gameplay_name.text, check_gameplay_enabled.button_pressed, area_id):
		update_status("Properties were not applied. Check that the ID is unique and the Area exists.")
		return
	canvas.update_selected_gameplay_position(Vector2(spin_gameplay_x.value, spin_gameplay_y.value))
	if selected_type == "Gameplay Area":
		canvas.update_selected_gameplay_area_size(Vector2(spin_gameplay_width.value, spin_gameplay_height.value))
	update_status("Gameplay properties updated.")

func _on_delete_gameplay_element_pressed() -> void:
	if str(canvas.selected_object.get("type", "")) == "Goal":
		update_status("Base HQ is required by the runtime and cannot be deleted.")
		return
	if canvas.delete_selected_editor_object():
		update_status("Selected gameplay element deleted.")
	else:
		update_status("Select a gameplay Area or Point first.")

func _on_resize_placement_pressed() -> void:
	var width_tiles := int(spin_placement_width.value)
	var height_tiles := int(spin_placement_height.value)
	if canvas.resize_selected_catalog_placement(width_tiles, height_tiles):
		update_status("Placement resized: %d x %d tiles." % [width_tiles, height_tiles])
	else:
		update_status("Placement operation failed.")

func _on_delete_placement_pressed() -> void:
	if canvas.delete_selected_catalog_placement():
		update_status("Selected placement deleted.")
	else:
		update_status("Placement operation failed.")

func _on_map_data_changed() -> void:
	if canvas:
		current_map_data = canvas.map_data
	map_dirty = true
	update_status("Map edited")

func update_tool_label(tool_name: String) -> void:
	if lbl_current_tool:
		lbl_current_tool.text = "Active Tool: [" + tool_name + "]"

func update_selected_tile_label(tile_desc: String) -> void:
	if lbl_selected_tile:
		lbl_selected_tile.text = "Selected: " + tile_desc

func _on_btn_select_pressed() -> void:
	if canvas: canvas.set_edit_mode("SELECT")
	update_tool_label("SELECT")
	update_selected_tile_label("None (Select Mode)")

func _on_btn_erase_pressed() -> void:
	if canvas: canvas.set_edit_mode("ERASE")
	update_tool_label("ERASE TILE")
	update_selected_tile_label("Erase Tool")

func _on_eraser_size_value_changed(value: float) -> void:
	if canvas:
		canvas.set_eraser_size(int(value))

func _on_option_layer_item_selected(index: int) -> void:
	var layers: Array[String] = ["Ground", "Vegetation", "RoadComposition"]
	if index >= 0 and index < layers.size():
		var selected_layer: String = layers[index]
		if canvas:
			canvas.set_active_layer(selected_layer)
		btn_fill_ground.visible = selected_layer == "Ground"
		update_status("Active Layer: " + selected_layer)

func _on_fill_ground_pressed() -> void:
	if canvas == null:
		return
	if canvas.active_layer != "Ground":
		update_status("Only Ground assets can be used on the Ground layer.")
		return
	if canvas.selected_catalog_asset.is_empty():
		update_status("Select a Ground catalog asset first.")
		return
	if str(canvas.selected_catalog_asset.get("kind", "tile")) != "tile":
		update_status("Only tile assets can be used for Fill Ground.")
		return
	var filled := canvas.fill_ground_empty_with_selected_tile()
	update_status("Fill Ground complete: %d tiles." % filled)

func set_asset_preview(entry: Dictionary) -> void:
	asset_preview.texture = null
	var source_path := str(entry.get("source_path", ""))
	var source_texture: Texture2D = preview_texture_cache.get(source_path)
	if source_texture == null and not source_path.is_empty():
		var loaded: Texture2D = IMAGE_TEXTURE_LOADER.load_texture(source_path)
		if loaded != null:
			source_texture = loaded
			preview_texture_cache[source_path] = source_texture
	if source_texture == null:
		lbl_asset_preview_status.text = "Preview unavailable: could not load source image."
		return
	var rect_values: Array = entry.get("source_rect_px", [])
	if rect_values.size() < 4:
		lbl_asset_preview_status.text = "Preview unavailable: source pixel rectangle is missing."
		return
	var rect := Rect2(float(rect_values[0]), float(rect_values[1]), float(rect_values[2]), float(rect_values[3]))
	if rect.position.x < 0.0 or rect.position.y < 0.0 or rect.size.x <= 0.0 or rect.size.y <= 0.0 or rect.end.x > source_texture.get_width() or rect.end.y > source_texture.get_height():
		lbl_asset_preview_status.text = "Preview unavailable: source rectangle exceeds image bounds."
		return
	var cropped_preview := AtlasTexture.new()
	cropped_preview.atlas = source_texture
	cropped_preview.region = rect
	asset_preview.texture = cropped_preview
	lbl_asset_preview_status.text = "Source region: %d x %d px / original aspect ratio" % [int(rect.size.x), int(rect.size.y)]


func _refresh_map_selector(preferred_id: String = "") -> void:
	if not map_selector:
		return
	map_selector.clear()
	var paths := MapLoader.list_map_paths()
	var selected := -1
	for path in paths:
		map_selector.add_item(str(path))
		if str(path) == preferred_id:
			selected = map_selector.item_count - 1
	if selected >= 0:
		map_selector.select(selected)

func _on_map_selector_item_selected(index: int) -> void:
	if index < 0 or index >= map_selector.item_count:
		return
	var path := map_selector.get_item_text(index)
	load_map(path)

func _default_new_map_data() -> Dictionary:
	var source := current_map_data.duplicate(true)
	if source.is_empty():
		source = MapLoader.load_map_data("map_01")
	var data := source.duplicate(true)
	data["map_id"] = ""
	data["name"] = "New Map"
	data["tiles"] = {"Ground": {}}
	data["objects"] = []
	data["gameplay_areas"] = []
	data["gameplay_points"] = []
	data["lanes"] = {}
	data["robot_spots"] = {}
	data["slots"] = {}
	return data

func _find_map_references(map_id: String) -> Array[String]:
	var result: Array[String] = []
	var catalog: Dictionary = ContentCatalogLoader.load_document("stage_catalog")
	for stage_id in catalog.get("stages", []):
		var id := str(stage_id)
		var stage_data := StageLoader.load_stage_data(id)
		if not stage_data.is_empty() and str(stage_data.get("map_file", "")) == map_id:
			result.append(str(stage_data.get("stage_id", id)))
	result.sort()
	return result

func _prompt_map_identity(title: String, default_id: String, default_name: String, duplicate_source: String = "") -> void:
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.size = Vector2i(460, 210)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	var id_edit := LineEdit.new()
	id_edit.placeholder_text = "Map ID"
	id_edit.text = default_id
	var name_edit := LineEdit.new()
	name_edit.placeholder_text = "Display Name"
	name_edit.text = default_name
	box.add_child(Label.new())
	box.get_child(0).text = "Map ID"
	box.add_child(id_edit)
	var name_label := Label.new()
	name_label.text = "Display Name"
	box.add_child(name_label)
	box.add_child(name_edit)
	dialog.add_child(box)
	add_child(dialog)
	dialog.confirmed.connect(func():
		var id := id_edit.text.strip_edges()
		var name := name_edit.text.strip_edges()
		if id.is_empty() or not id.is_valid_filename():
			update_status("Invalid Map ID. Use filename-safe characters.")
			dialog.queue_free()
			return
		var ok := MapLoader.duplicate_map(duplicate_source, id, name) if not duplicate_source.is_empty() else MapLoader.create_map(id, _default_new_map_data())
		if not ok:
			update_status("Map creation failed or Map ID already exists: " + id)
		else:
			current_map_path = id
			_refresh_map_selector(id)
			load_map(id)
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered()

func _on_btn_new_map_pressed() -> void:
	if map_dirty:
		update_status("New Map blocked: unsaved changes exist. Save the current map first.")
		return
	_prompt_map_identity("New Map", "map_new", "New Map")

func _on_btn_duplicate_map_pressed() -> void:
	if map_dirty:
		update_status("Duplicate blocked: unsaved changes exist. Save the current map first.")
		return
	if current_map_data.is_empty():
		update_status("Duplicate blocked: no map loaded.")
		return
	var base_id := str(current_map_data.get("map_id", current_map_path)) + "_copy"
	_prompt_map_identity("Duplicate Map", base_id, str(current_map_data.get("name", "")) + " Copy", current_map_path)

func _on_btn_delete_map_pressed() -> void:
	if map_dirty:
		update_status("Delete blocked: unsaved changes exist. Save the current map first.")
		return
	var refs := _find_map_references(current_map_path)
	if not refs.is_empty():
		update_status("Delete blocked: map is referenced by stages: " + ", ".join(refs))
		return
	if current_map_path in ["map_01", "map_02", "map_03"]:
		update_status("Delete blocked: canonical maps are protected.")
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "Delete Map"
	dialog.dialog_text = "Delete map '" + current_map_path + "' permanently?"
	add_child(dialog)
	dialog.confirmed.connect(func():
		if MapLoader.delete_map(current_map_path):
			var paths := MapLoader.list_map_paths()
			var next_id := paths[0] if not paths.is_empty() else "map_01"
			current_map_path = next_id
			_refresh_map_selector(next_id)
			load_map(next_id)
		else:
			update_status("Delete failed: " + current_map_path)
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered()

func _on_btn_load_pressed() -> void:
	if map_dirty:
		update_status("Load blocked: unsaved changes exist. Save the current map first.")
		return
	set_dialog_path(open_map_dialog)
	open_map_dialog.popup_centered(Vector2i(900, 640))

func _on_btn_save_pressed() -> void:
	set_dialog_path(save_map_dialog)
	save_map_dialog.popup_centered(Vector2i(900, 640))

func _on_open_map_file_selected(path: String) -> void:
	load_map(path)

func _on_save_map_file_selected(path: String) -> void:
	var selected_id := path.get_file().get_basename()
	if selected_id != current_map_path:
		update_status("Save As blocked: Map ID changes are not allowed by the Content Editor Canon.")
		return
	save_map()

func _on_btn_asset_catalog_pressed() -> void:
	asset_catalog_window.popup_centered(Vector2i(1280, 820))
