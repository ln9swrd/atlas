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
@onready var asset_rows: VBoxContainer = $MainLayout/Inspector/VBox/AssetScroll/AssetRows
@onready var btn_open_asset_catalog: Button = $MainLayout/Inspector/VBox/BtnOpenAssetCatalog
@onready var btn_place_catalog_asset: Button = $MainLayout/Inspector/VBox/BtnPlaceCatalogAsset
@onready var asset_preview: TextureRect = $MainLayout/Inspector/VBox/AssetPreview
@onready var lbl_asset_preview_status: Label = $MainLayout/Inspector/VBox/LblAssetPreviewStatus
@onready var lbl_asset_details: Label = $MainLayout/Inspector/VBox/LblAssetDetails
@onready var lbl_status: Label = $BottomBar/HBox/LblStatus
@onready var open_map_dialog: FileDialog = $OpenMapDialog
@onready var save_map_dialog: FileDialog = $SaveMapDialog
@onready var lbl_current_tool: Label = $MainLayout/Toolbox/VBox/LblCurrentTool
@onready var lbl_selected_tile: Label = $MainLayout/Toolbox/VBox/LblSelectedTile
@onready var option_layer: OptionButton = $MainLayout/Toolbox/VBox/OptionLayer
@onready var spin_atlas_x: SpinBox = $MainLayout/Toolbox/VBox/AtlasPicker/SpinX
@onready var spin_atlas_y: SpinBox = $MainLayout/Toolbox/VBox/AtlasPicker/SpinY
@onready var spin_eraser_size: SpinBox = $MainLayout/Toolbox/VBox/EraserSize/SpinEraserSize
@onready var atlas_palette: AtlasPalette = $MainLayout/Toolbox/VBox/PaletteContainer/AtlasPaletteView
@onready var asset_catalog_window: Window = $AssetCatalogWindow

var current_map_path := "res://map_data/northbridge_sector_01.json"
var current_map_data := {}
var active_atlas_x := 0
var active_atlas_y := 0
var catalog_entries: Array[Dictionary] = []
var preview_texture_cache: Dictionary = {}
var selected_asset_id := ""

func _ready() -> void:
	asset_catalog_window.close_requested.connect(_on_asset_catalog_closed)
	asset_catalog_window.connect("catalog_saved", _on_asset_catalog_saved)
	if canvas:
		canvas.object_selected.connect(_on_object_selected)
		canvas.map_data_changed.connect(_on_map_data_changed)
		canvas.placement_resize_failed.connect(update_status)
		canvas.set_eraser_size(int(spin_eraser_size.value))
	btn_resize_placement.pressed.connect(_on_resize_placement_pressed)
	btn_delete_placement.pressed.connect(_on_delete_placement_pressed)
	btn_open_asset_catalog.pressed.connect(_on_open_asset_catalog_pressed)
	lbl_placement_size.hide()
	spin_placement_width.get_parent().hide()
	btn_resize_placement.hide()
	btn_delete_placement.hide()

	if atlas_palette:
		atlas_palette.tile_selected.connect(_on_atlas_palette_tile_selected)

	setup_layer_options()
	load_asset_catalog()
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
	lbl_asset_preview_status.text = "Select an asset to preview its source region."
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
		lbl_asset_details.text = "Select an asset, then use Place Selected to paint it."

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
	for index in range(catalog_entries.size()):
		var entry: Dictionary = catalog_entries[index]
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 58
		asset_rows.add_child(row)
		var image_button := TextureButton.new()
		image_button.custom_minimum_size = Vector2(58, 54)
		image_button.ignore_texture_size = true
		image_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		image_button.texture_normal = _catalog_entry_preview(entry)
		image_button.tooltip_text = "Select asset; double-click to edit its source image or region"
		image_button.pressed.connect(_on_catalog_image_pressed.bind(index))
		image_button.gui_input.connect(_on_catalog_asset_gui_input.bind(index, "image"))
		row.add_child(image_button)
		var text_button := Button.new()
		text_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_button.custom_minimum_size.y = 54
		text_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		text_button.text = "%s\n%s · %s" % [entry.get("display_name", entry.get("asset_id", "?")), str(entry.get("kind", "tile")).capitalize(), entry.get("group", "?")]
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
	set_asset_preview(entry)
	var rect: Array = entry.get("source_rect_px", [0, 0, 0, 0])
	var footprint := canvas.catalog_asset_footprint(entry)
	lbl_asset_details.text = "%s\n%s · %s\nID: %s\nSource: %s\nPixels: %s\nFootprint: %s × %s" % [entry.get("display_name", ""), str(entry.get("kind", "tile")).capitalize(), entry.get("group", ""), entry.get("asset_id", ""), entry.get("source_path", ""), str(rect), str(footprint.x), str(footprint.y)]
	update_tool_label("CATALOG: " + str(entry.get("display_name", entry.get("asset_id", ""))))
	update_selected_tile_label("Use Place Selected, then click canvas")

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

func set_dialog_path(dialog: FileDialog) -> void:
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
	var can_resize := placement_type in ["Catalog Object", "Catalog Tile"]
	lbl_placement_size.visible = can_resize
	spin_placement_width.get_parent().visible = can_resize
	btn_resize_placement.visible = can_resize
	btn_resize_placement.disabled = not can_resize
	btn_delete_placement.visible = can_resize
	btn_delete_placement.disabled = not can_resize
	if info.is_empty():
		lbl_selected_id.text = "ID: None"
		lbl_selected_type.text = "Type: -"
		lbl_position.text = "Position: -"
		lbl_tile_coords.text = "Tile: -"
		return

	var pos: Vector2 = info.get("position", Vector2.ZERO)
	var origin: Vector2 = current_map_data.get("map_origin", Vector2(0, 58))
	var tile_x := int((pos.x - origin.x) / 32.0)
	var tile_y := int((pos.y - origin.y) / 32.0)

	lbl_selected_id.text = "ID: " + str(info.get("id", "-"))
	lbl_selected_type.text = "Type: " + str(info.get("type", "-"))
	lbl_position.text = "Position: (%.1f, %.1f)" % [pos.x, pos.y]
	lbl_tile_coords.text = "Tile Coords: (%d, %d)" % [tile_x, tile_y]
	if can_resize:
		var footprint: Variant = info.get("footprint", [1, 1])
		if footprint is Array and footprint.size() >= 2:
			spin_placement_width.value = int(footprint[0])
			spin_placement_height.value = int(footprint[1])

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
		update_status("Delete failed: select a placed catalog asset first.")

func _on_map_data_changed() -> void:
	if canvas:
		current_map_data = canvas.map_data
	update_status("Map edited (Unsaved changes)")

func update_tool_label(name: String) -> void:
	if lbl_current_tool:
		lbl_current_tool.text = "Active Tool: [" + name + "]"

func update_selected_tile_label(tile_desc: String) -> void:
	if lbl_selected_tile:
		lbl_selected_tile.text = "Selected: " + tile_desc

func select_ground4_tile(x: int, y: int) -> void:
	active_atlas_x = clamp(x, 0, 47)
	active_atlas_y = clamp(y, 0, 31)

	if spin_atlas_x and spin_atlas_x.value != active_atlas_x:
		spin_atlas_x.value = active_atlas_x
	if spin_atlas_y and spin_atlas_y.value != active_atlas_y:
		spin_atlas_y.value = active_atlas_y
	if atlas_palette:
		atlas_palette.set_selected_cell(active_atlas_x, active_atlas_y)

	if canvas:
		canvas.set_selected_tile(8, Vector2i(active_atlas_x, active_atlas_y))

	var desc := "Ground4 (%d, %d)" % [active_atlas_x, active_atlas_y]
	update_tool_label("PAINT: " + desc)
	update_selected_tile_label(desc)

func _on_atlas_palette_tile_selected(x: int, y: int) -> void:
	select_ground4_tile(x, y)

func _on_btn_select_pressed() -> void:
	if canvas: canvas.set_edit_mode("SELECT")
	update_tool_label("SELECT")
	update_selected_tile_label("None (Select Mode)")

func _on_btn_erase_pressed() -> void:
	if canvas: canvas.set_edit_mode("ERASE")
	update_tool_label("ERASE TILE")
	update_selected_tile_label("Erase Tool")

func _on_btn_tile_ground_pressed() -> void:
	if canvas: canvas.set_selected_tile(0, Vector2i(0, 0))
	update_tool_label("PAINT: Ground Basic")
	update_selected_tile_label("Ground Basic (0,0)")

func _on_spin_atlas_x_value_changed(value: float) -> void:
	select_ground4_tile(int(value), active_atlas_y)

func _on_spin_atlas_y_value_changed(value: float) -> void:
	select_ground4_tile(active_atlas_x, int(value))

func _on_eraser_size_value_changed(value: float) -> void:
	if canvas:
		canvas.set_eraser_size(int(value))

func _on_btn_tile_g4_preset0_pressed() -> void: select_ground4_tile(0, 0)
func _on_btn_tile_g4_preset1_pressed() -> void: select_ground4_tile(1, 0)
func _on_btn_tile_g4_preset2_pressed() -> void: select_ground4_tile(2, 0)
func _on_btn_tile_g4_preset3_pressed() -> void: select_ground4_tile(3, 0)

func _on_btn_tile_concrete_pressed() -> void:
	if canvas: canvas.set_selected_tile(5, Vector2i(40, 16))
	update_tool_label("PAINT: Concrete Module")
	update_selected_tile_label("Concrete Module")

func _on_btn_tile_grass_pressed() -> void:
	if canvas: canvas.set_selected_tile(4, Vector2i(0, 0))
	update_tool_label("PAINT: Vegetation Cluster")
	update_selected_tile_label("Vegetation Cluster")

func _on_btn_tile_road_pressed() -> void:
	if canvas: canvas.set_selected_tile(3, Vector2i(0, 0))
	update_tool_label("PAINT: Road Segment")
	update_selected_tile_label("Road Segment")

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

func _on_btn_place_catalog_asset_pressed() -> void:
	var index := _find_catalog_asset_index(selected_asset_id)
	if index < 0:
		update_status("Select a catalog item first")
		return
	_select_catalog_asset(index)
	update_status("Place selected catalog asset on the canvas")

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
