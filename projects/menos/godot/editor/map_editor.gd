class_name MapEditorMain
extends Control

@onready var canvas: EditorCanvas = $MainLayout/CanvasContainer/CanvasRoot
@onready var lbl_selected_id: Label = $MainLayout/Inspector/VBox/LblSelectedID
@onready var lbl_selected_type: Label = $MainLayout/Inspector/VBox/LblSelectedType
@onready var lbl_position: Label = $MainLayout/Inspector/VBox/LblPosition
@onready var lbl_tile_coords: Label = $MainLayout/Inspector/VBox/LblTileCoords
@onready var asset_list: ItemList = $MainLayout/Inspector/VBox/AssetList
@onready var lbl_asset_details: Label = $MainLayout/Inspector/VBox/LblAssetDetails
@onready var lbl_status: Label = $BottomBar/HBox/LblStatus
@onready var open_map_dialog: FileDialog = $OpenMapDialog
@onready var save_map_dialog: FileDialog = $SaveMapDialog
@onready var lbl_current_tool: Label = $MainLayout/Toolbox/VBox/LblCurrentTool
@onready var lbl_selected_tile: Label = $MainLayout/Toolbox/VBox/LblSelectedTile
@onready var option_layer: OptionButton = $MainLayout/Toolbox/VBox/OptionLayer
@onready var spin_atlas_x: SpinBox = $MainLayout/Toolbox/VBox/AtlasPicker/SpinX
@onready var spin_atlas_y: SpinBox = $MainLayout/Toolbox/VBox/AtlasPicker/SpinY
@onready var atlas_palette: AtlasPalette = $MainLayout/Toolbox/VBox/PaletteContainer/AtlasPaletteView
@onready var asset_catalog_window: Window = $AssetCatalogWindow

var current_map_path := "res://map_data/northbridge_sector_01.json"
var current_map_data := {}
var active_atlas_x := 0
var active_atlas_y := 0
var catalog_entries: Array[Dictionary] = []

func _ready() -> void:
	asset_catalog_window.close_requested.connect(load_asset_catalog)
	if canvas:
		canvas.object_selected.connect(_on_object_selected)
		canvas.map_data_changed.connect(_on_map_data_changed)

	if atlas_palette:
		atlas_palette.tile_selected.connect(_on_atlas_palette_tile_selected)

	setup_layer_options()
	load_asset_catalog()
	load_map(current_map_path)

func load_asset_catalog() -> void:
	var file := FileAccess.open("res://content/editor/asset_catalog.json", FileAccess.READ)
	if file == null:
		update_status("Could not open asset catalog")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.get("assets", []) is Array:
		update_status("Invalid asset catalog JSON")
		return
	catalog_entries.clear()
	asset_list.clear()
	for value in parsed.get("assets", []):
		if value is Dictionary:
			var entry: Dictionary = value.duplicate(true)
			catalog_entries.append(entry)
			asset_list.add_item("%s · %s / %s" % [entry.get("display_name", entry.get("asset_id", "?")), entry.get("kind", "?"), entry.get("group", "?")])
	if canvas:
		canvas.set_catalog_assets(catalog_entries)
	lbl_asset_details.text = "Select a catalog asset to place it."

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

func _on_asset_list_item_selected(index: int) -> void:
	if index < 0 or index >= catalog_entries.size():
		return
	var entry: Dictionary = catalog_entries[index]
	if canvas:
		canvas.set_catalog_asset(entry)
	var rect: Array = entry.get("source_rect_px", [0, 0, 0, 0])
	var footprint: Array = entry.get("footprint_tiles", [1, 1])
	lbl_asset_details.text = "%s\n%s · %s\nID: %s\nSource: %s\nPixels: %s\nFootprint: %s × %s" % [entry.get("display_name", ""), str(entry.get("kind", "tile")).capitalize(), entry.get("group", ""), entry.get("asset_id", ""), entry.get("source_path", ""), str(rect), str(footprint[0]), str(footprint[1])]
	update_tool_label("CATALOG: " + str(entry.get("display_name", entry.get("asset_id", ""))))
	update_selected_tile_label("Click canvas to place selected catalog asset")

func _on_asset_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	_on_asset_list_item_selected(index)

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
