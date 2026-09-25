class_name MapEditorMain
extends Control

@onready var canvas: EditorCanvas = $MainLayout/CanvasContainer/CanvasRoot
@onready var lbl_selected_id: Label = $MainLayout/Inspector/VBox/LblSelectedID
@onready var lbl_selected_type: Label = $MainLayout/Inspector/VBox/LblSelectedType
@onready var lbl_position: Label = $MainLayout/Inspector/VBox/LblPosition
@onready var lbl_tile_coords: Label = $MainLayout/Inspector/VBox/LblTileCoords
@onready var lbl_status: Label = $BottomBar/HBox/LblStatus
@onready var lbl_current_tool: Label = $MainLayout/Toolbox/VBox/LblCurrentTool
@onready var option_layer: OptionButton = $MainLayout/Toolbox/VBox/OptionLayer

var current_map_path := "res://map_data/northbridge_sector_01.json"
var current_map_data := {}

func _ready() -> void:
	if canvas:
		canvas.object_selected.connect(_on_object_selected)
		canvas.map_data_changed.connect(_on_map_data_changed)

	setup_layer_options()
	load_map(current_map_path)

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

func _on_btn_select_pressed() -> void:
	if canvas: canvas.set_edit_mode("SELECT")
	update_tool_label("SELECT")

func _on_btn_erase_pressed() -> void:
	if canvas: canvas.set_edit_mode("ERASE")
	update_tool_label("ERASE TILE")

func _on_btn_tile_ground_pressed() -> void:
	if canvas: canvas.set_selected_tile(0, Vector2i(0, 0))
	update_tool_label("PAINT: Ground Basic")

func _on_btn_tile_concrete_pressed() -> void:
	if canvas: canvas.set_selected_tile(5, Vector2i(40, 16))
	update_tool_label("PAINT: Concrete Module")

func _on_btn_tile_grass_pressed() -> void:
	if canvas: canvas.set_selected_tile(4, Vector2i(0, 0))
	update_tool_label("PAINT: Vegetation Cluster")

func _on_btn_tile_road_pressed() -> void:
	if canvas: canvas.set_selected_tile(3, Vector2i(0, 0))
	update_tool_label("PAINT: Road Segment")

func _on_option_layer_item_selected(index: int) -> void:
	var layers := ["Ground", "Vegetation", "RoadComposition"]
	if index >= 0 and index < layers.size():
		var selected_layer := layers[index]
		if canvas: canvas.set_active_layer(selected_layer)
		update_status("Active Layer: " + selected_layer)

func _on_btn_load_pressed() -> void:
	load_map(current_map_path)

func _on_btn_save_pressed() -> void:
	save_map()
