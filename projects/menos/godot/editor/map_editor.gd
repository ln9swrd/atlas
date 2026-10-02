class_name MapEditorMain
extends Control

const IMAGE_TEXTURE_LOADER := preload("res://editor/image_texture_loader.gd")

@onready var canvas: EditorCanvas = $MainLayout/CanvasContainer/CanvasRoot
@onready var lbl_selected_id: Label = $MainLayout/Inspector/VBox/LblSelectedID
@onready var lbl_selected_type: Label = $MainLayout/Inspector/VBox/LblSelectedType
@onready var lbl_position: Label = $MainLayout/Inspector/VBox/LblPosition
@onready var lbl_tile_coords: Label = $MainLayout/Inspector/VBox/LblTileCoords
@onready var lbl_placement_size: Label = $MainLayout/Inspector/VBox/LblPlacementSize
@onready var spin_placement_width: SpinBox = $MainLayout/Inspector/VBox/PlacementSizeRow/SpinPlacementWidth
@onready var spin_placement_height: SpinBox = $MainLayout/Inspector/VBox/PlacementSizeRow/SpinPlacementHeight
@onready var btn_resize_placement: Button = $MainLayout/Inspector/VBox/BtnResizePlacement
@onready var btn_delete_placement: Button = $MainLayout/Inspector/VBox/BtnDeletePlacement
@onready var asset_rows: VBoxContainer = $MainLayout/Toolbox/VBox/AssetCatalogSection/AssetScroll/AssetRows
@onready var btn_open_asset_catalog: Button = $MainLayout/Toolbox/VBox/AssetCatalogSection/BtnOpenAssetCatalog
@onready var asset_preview: TextureRect = $MainLayout/Toolbox/VBox/AssetCatalogSection/AssetPreview
@onready var lbl_asset_preview_status: Label = $MainLayout/Toolbox/VBox/AssetCatalogSection/LblAssetPreviewStatus
@onready var lbl_asset_details: Label = $MainLayout/Toolbox/VBox/AssetCatalogSection/LblAssetDetails
@onready var btn_asset_mode: Button = $MainLayout/Toolbox/VBox/ModeBar/BtnAssetMode
@onready var btn_gameplay_mode: Button = $MainLayout/Toolbox/VBox/ModeBar/BtnGameplayMode
@onready var gameplay_tools: VBoxContainer = $MainLayout/Toolbox/VBox/GameplayTools
@onready var lbl_layer_title: Label = $MainLayout/Toolbox/VBox/LblLayerTitle
@onready var eraser_size_row: HBoxContainer = $MainLayout/Toolbox/VBox/EraserSize
@onready var gameplay_properties: VBoxContainer = $MainLayout/Inspector/VBox/GameplayProperties
@onready var edit_gameplay_id: LineEdit = $MainLayout/Inspector/VBox/GameplayProperties/EditGameplayID
@onready var edit_gameplay_name: LineEdit = $MainLayout/Inspector/VBox/GameplayProperties/EditGameplayName
@onready var spin_gameplay_x: SpinBox = $MainLayout/Inspector/VBox/GameplayProperties/GameplayPositionRow/SpinGameplayX
@onready var spin_gameplay_y: SpinBox = $MainLayout/Inspector/VBox/GameplayProperties/GameplayPositionRow/SpinGameplayY
@onready var spin_gameplay_width: SpinBox = $MainLayout/Inspector/VBox/GameplayProperties/GameplaySizeRow/SpinGameplayWidth
@onready var spin_gameplay_height: SpinBox = $MainLayout/Inspector/VBox/GameplayProperties/GameplaySizeRow/SpinGameplayHeight
@onready var check_gameplay_enabled: CheckButton = $MainLayout/Inspector/VBox/GameplayProperties/GameplayEnabled
@onready var option_gameplay_area: OptionButton = $MainLayout/Inspector/VBox/GameplayProperties/GameplayAreaRow/OptionGameplayArea
@onready var lbl_gameplay_delete_status: Label = $MainLayout/Inspector/VBox/GameplayProperties/LblGameplayDeleteStatus
@onready var lbl_status: Label = $BottomBar/HBox/LblStatus
@onready var open_map_dialog: FileDialog = $OpenMapDialog
@onready var save_map_dialog: FileDialog = $SaveMapDialog
@onready var lbl_current_tool: Label = $MainLayout/Toolbox/VBox/LblCurrentTool
@onready var lbl_selected_tile: Label = $MainLayout/Toolbox/VBox/LblSelectedTile
@onready var option_layer: OptionButton = $MainLayout/Toolbox/VBox/OptionLayer
@onready var spin_eraser_size: SpinBox = $MainLayout/Toolbox/VBox/EraserSize/SpinEraserSize
@onready var asset_catalog_window: Window = $AssetCatalogWindow

var map_size_panel: PanelContainer
var map_width_spin: SpinBox
var map_height_spin: SpinBox

var current_map_path := "res://map_data/northbridge_sector_01.json"
var current_map_data := {}
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
	btn_open_asset_catalog.pressed.connect(_on_open_asset_catalog_pressed)
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
	$MainLayout/Inspector/VBox/GameplayProperties/BtnApplyGameplayProperties.pressed.connect(_on_apply_gameplay_properties_pressed)
	$MainLayout/Inspector/VBox/GameplayProperties/BtnDeleteGameplayElement.pressed.connect(_on_delete_gameplay_element_pressed)
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
	load_map(current_map_path)

func load_asset_catalog(preferred_asset_id: String = "", force_clear_selection: bool = false) -> void:
	var desired_asset_id := selected_asset_id
	if not preferred_asset_id.is_empty() or force_clear_selection:
		desired_asset_id = preferred_asset_id
	var file := FileAccess.open("res://content/editor/asset_catalog.json", FileAccess.READ)
	if file == null:
		update_status("Could not open asset catalog")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.get("assets", []) is Array:
		update_status("Invalid asset catalog JSON")
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

func _find_catalog_asset_index(asset_id: String) -> int:
	if asset_id.is_empty():
		return -1
	for index in range(catalog_entries.size()):
		if str(catalog_entries[index].get("asset_id", "")) == asset_id:
			return index
	return -1

func _rebuild_asset_rows() -> void:
	for child in asset_rows.get_children():
		child.queue_free()
	var grouped_entries: Dictionary = {}
	for index in range(catalog_entries.size()):
		var group_name := str(catalog_entries[index].get("group", "Other"))
		var group_indices: Array = grouped_entries.get(group_name, [])
		group_indices.append(index)
		grouped_entries[group_name] = group_indices
	var group_names: Array = grouped_entries.keys()
	group_names.sort()
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
	lbl_asset_details.text = "%s\n%s · %s\nID: %s\nSource: %s\nPixels: %s\nFootprint: %s × %s" % [entry.get("display_name", ""), str(entry.get("kind", "tile")).capitalize(), entry.get("group", ""), entry.get("asset_id", ""), entry.get("source_path", ""), str(rect), str(footprint.x), str(footprint.y)]
	update_tool_label("CATALOG: " + str(entry.get("display_name", entry.get("asset_id", ""))))
	var asset_kind := str(entry.get("kind", "tile"))
	var asset_group := str(entry.get("group", ""))
	if asset_kind == "tile":
		var layer_by_group := {"Ground": "Ground", "Vegetation": "Vegetation", "RoadComposition": "RoadComposition"}
		if layer_by_group.has(asset_group):
			canvas.set_active_layer(str(layer_by_group[asset_group]))
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
	map_size_panel.custom_minimum_size.y = 86
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
	apply.text = "적용"
	apply.disabled = true
	apply.tooltip_text = "W/H 스피너 변경 시 실시간으로 적용됩니다."
	row.add_child(apply)
	$MainLayout/Inspector/VBox.add_child(map_size_panel)
	$MainLayout/Inspector/VBox.move_child(map_size_panel, 0)

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
	update_status("Map preview resized to %d × %d tiles. Save JSON to keep the change." % [new_size.x, new_size.y])

func _on_map_size_apply_pressed() -> void:
	if current_map_data.is_empty() or canvas == null:
		return
	var new_size := Vector2i(maxi(1, int(map_width_spin.value)), maxi(1, int(map_height_spin.value)))
	var old_value: Variant = current_map_data.get("map_tiles", [36, 24])
	var old_size := Vector2i(int(old_value[0]), int(old_value[1])) if old_value is Array and old_value.size() >= 2 else Vector2i(36, 24)
	if new_size == old_size:
		update_status("Map size unchanged: %d × %d." % [new_size.x, new_size.y])
		return
	if (new_size.x < old_size.x or new_size.y < old_size.y) and not _map_size_can_contain(new_size):
		_sync_map_size_controls()
		update_status("Resize rejected: existing content is outside the new map bounds.")
		return
	current_map_data["map_tiles"] = [new_size.x, new_size.y]
	current_map_data["map_pixel_size"] = [new_size.x * 32, new_size.y * 32]
	canvas.set_map_data(current_map_data)
	_sync_map_size_controls()
	update_status("Map resized to %d × %d tiles (%d × %d px). Save JSON to keep the change." % [new_size.x, new_size.y, new_size.x * 32, new_size.y * 32])

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
		option_layer.add_item("RoadComposition Layer", 2)
		option_layer.select(0)

func load_map(path: String) -> void:
	current_map_path = path
	current_map_data = MapLoader.load_map_data(path)
	if current_map_data.is_empty():
		update_status("FAILED to load map data from: " + path)
		return

	if canvas:
		canvas.set_map_data(current_map_data)
	_sync_map_size_controls()
	update_status("Loaded map: " + path)

func save_map() -> void:
	if current_map_data.is_empty():
		update_status("Cannot save: No map data loaded")
		return

	if canvas:
		current_map_data = canvas.map_data

	var success := MapLoader.save_map_data(current_map_path, current_map_data)
	if success:
		update_status("SAVED map successfully to: " + current_map_path)
	else:
		update_status("FAILED to save map to: " + current_map_path)

func _on_file_dialog_visibility_changed() -> void:
	if not open_map_dialog.visible and not save_map_dialog.visible:
		_save_file_dialog_favorites()

func _load_file_dialog_favorites() -> void:
	if not FileAccess.file_exists(FILE_DIALOG_FAVORITES_PATH):
		return
	var file := FileAccess.open(FILE_DIALOG_FAVORITES_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Array:
		return
	var favorites := PackedStringArray()
	for favorite in parsed:
		var path := str(favorite)
		if not path.is_empty() and not favorites.has(path):
			favorites.append(path)
	FileDialog.set_favorite_list(favorites)

func _save_file_dialog_favorites() -> void:
	var favorites := FileDialog.get_favorite_list()
	var file := FileAccess.open(FILE_DIALOG_FAVORITES_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(favorites, "  "))
	file.close()

func set_dialog_path(dialog: FileDialog) -> void:
	_save_file_dialog_favorites()
	var global_map_path := current_map_path
	if global_map_path.begins_with("res://") or global_map_path.begins_with("user://"):
		global_map_path = ProjectSettings.globalize_path(global_map_path)
	dialog.current_dir = global_map_path.get_base_dir()
	dialog.current_file = global_map_path.get_file()

func update_status(text: String) -> void:
	if lbl_status:
		lbl_status.text = "Status: " + text

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
	$MainLayout/Inspector/VBox/GameplayProperties/BtnDeleteGameplayElement.disabled = is_required_base
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
		$MainLayout/Inspector/VBox/GameplayProperties/GameplaySizeRow.visible = is_gameplay_area
		$MainLayout/Inspector/VBox/GameplayProperties/GameplayAreaRow.visible = placement_type == "Gameplay Point"
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
	for node in [lbl_layer_title, option_layer, $MainLayout/Toolbox/VBox/BtnSelect, $MainLayout/Toolbox/VBox/BtnErase, eraser_size_row]:
		node.visible = not is_gameplay_mode
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
		update_status("Placed asset resized to %d × %d cells." % [width_tiles, height_tiles])
	else:
		update_status("Resize failed: target bounds are outside the map or overlap another tile.")

func _on_delete_placement_pressed() -> void:
	if canvas.delete_selected_catalog_placement():
		update_status("Selected asset placement deleted.")
	else:
		update_status("삭제 failed: select a placed catalog asset first.")

func _on_map_data_changed() -> void:
	if canvas:
		current_map_data = canvas.map_data
	update_status("Map edited (Unsaved changes)")

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
		if canvas: canvas.set_active_layer(selected_layer)
		update_status("Active Layer: " + selected_layer)

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
	lbl_asset_preview_status.text = "Source region: %d × %d px · original aspect ratio" % [int(rect.size.x), int(rect.size.y)]


func _on_btn_load_pressed() -> void:
	set_dialog_path(open_map_dialog)
	open_map_dialog.popup_centered(Vector2i(900, 640))

func _on_btn_save_pressed() -> void:
	set_dialog_path(save_map_dialog)
	save_map_dialog.popup_centered(Vector2i(900, 640))

func _on_open_map_file_selected(path: String) -> void:
	load_map(path)

func _on_save_map_file_selected(path: String) -> void:
	current_map_path = path
	save_map()

func _on_btn_asset_catalog_pressed() -> void:
	asset_catalog_window.popup_centered(Vector2i(1280, 820))
