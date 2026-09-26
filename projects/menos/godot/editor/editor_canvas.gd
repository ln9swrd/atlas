class_name EditorCanvas
extends Node2D

signal object_selected(info: Dictionary)
signal map_data_changed()

const TILESET: TileSet = preload("res://assets/menos/maps/northbridge_tileset.tres")

var map_data: Dictionary = {}
var selected_object: Dictionary = {}

var edit_mode := "SELECT" # SELECT, PAINT, ERASE
var active_layer := "Ground" # Ground, Vegetation, RoadComposition
var selected_tile_source_id := 0
var selected_tile_atlas_coords := Vector2i.ZERO

var camera_zoom := 1.0
var camera_offset := Vector2.ZERO
var is_panning := false
var is_painting_drag := false
var pan_start_pos := Vector2.ZERO

func _ready() -> void:
	queue_redraw()

func set_map_data(data: Dictionary) -> void:
	map_data = data.duplicate(true)
	if not map_data.has("tiles"):
		map_data["tiles"] = {}
	queue_redraw()

func set_edit_mode(mode: String) -> void:
	edit_mode = mode
	select_object({})
	queue_redraw()

func set_active_layer(layer_name: String) -> void:
	active_layer = layer_name
	queue_redraw()

func set_selected_tile(source_id: int, atlas_coords: Vector2i) -> void:
	selected_tile_source_id = source_id
	selected_tile_atlas_coords = atlas_coords
	edit_mode = "PAINT"
	select_object({})
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton
		var local_position := viewport_to_canvas_position(mb_event.position)
		var inside_canvas := pointer_is_inside_canvas(local_position)

		if mb_event.button_index in [MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]:
			if mb_event.pressed and inside_canvas:
				is_panning = true
				pan_start_pos = local_position
				get_viewport().set_input_as_handled()
			elif not mb_event.pressed and is_panning:
				is_panning = false
				get_viewport().set_input_as_handled()
		elif mb_event.button_index == MOUSE_BUTTON_LEFT:
			if not mb_event.pressed:
				if is_painting_drag:
					is_painting_drag = false
					get_viewport().set_input_as_handled()
				return
			if not inside_canvas:
				return
			is_painting_drag = true
			var world_pos: Vector2 = (local_position - camera_offset) / camera_zoom
			handle_canvas_click(world_pos)
			get_viewport().set_input_as_handled()
		elif not inside_canvas:
			return
		elif mb_event.button_index == MOUSE_BUTTON_WHEEL_UP and mb_event.pressed:
			camera_zoom = minf(3.0, camera_zoom + 0.1)
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif mb_event.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb_event.pressed:
			camera_zoom = maxf(0.4, camera_zoom - 0.1)
			queue_redraw()
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion:
		var mm_event := event as InputEventMouseMotion
		var local_position := viewport_to_canvas_position(mm_event.position)
		if is_panning:
			camera_offset += local_position - pan_start_pos
			pan_start_pos = local_position
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif is_painting_drag and edit_mode in ["PAINT", "ERASE"]:
			if pointer_is_inside_canvas(local_position):
				var world_pos: Vector2 = (local_position - camera_offset) / camera_zoom
				handle_canvas_click(world_pos)
			get_viewport().set_input_as_handled()

func viewport_to_canvas_position(viewport_position: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * viewport_position

func pointer_is_inside_canvas(local_position: Vector2) -> bool:
	var canvas_container := get_parent() as Control
	return canvas_container != null and Rect2(Vector2.ZERO, canvas_container.size).has_point(local_position)

func handle_canvas_click(world_pos: Vector2) -> void:
	if edit_mode == "SELECT":
		pick_object_at(world_pos)
	elif edit_mode == "PAINT":
		paint_tile_at(world_pos)
	elif edit_mode == "ERASE":
		erase_tile_at(world_pos)

func get_cell_coords(world_pos: Vector2) -> Vector2i:
	var origin: Vector2 = map_data.get("map_origin", Vector2(0, 58))
	var cell_x := int(floor((world_pos.x - origin.x) / 32.0))
	var cell_y := int(floor((world_pos.y - origin.y) / 32.0))
	return Vector2i(cell_x, cell_y)

func paint_tile_at(world_pos: Vector2) -> void:
	var map_tiles: Vector2i = map_data.get("map_tiles", Vector2i(36, 24))
	var cell := get_cell_coords(world_pos)

	if cell.x < 0 or cell.x >= map_tiles.x or cell.y < 0 or cell.y >= map_tiles.y:
		return

	if not map_data.has("tiles"):
		map_data["tiles"] = {}
	if not map_data["tiles"].has(active_layer):
		map_data["tiles"][active_layer] = {}

	var key := "%d,%d" % [cell.x, cell.y]
	var tile_info := [selected_tile_source_id, selected_tile_atlas_coords.x, selected_tile_atlas_coords.y]

	if map_data["tiles"][active_layer].get(key) != tile_info:
		map_data["tiles"][active_layer][key] = tile_info
		map_data_changed.emit()
		queue_redraw()

func erase_tile_at(world_pos: Vector2) -> void:
	var map_tiles: Vector2i = map_data.get("map_tiles", Vector2i(36, 24))
	var cell := get_cell_coords(world_pos)

	if cell.x < 0 or cell.x >= map_tiles.x or cell.y < 0 or cell.y >= map_tiles.y:
		return

	if not map_data.has("tiles") or not map_data["tiles"].has(active_layer):
		return

	var key := "%d,%d" % [cell.x, cell.y]
	if map_data["tiles"][active_layer].has(key):
		map_data["tiles"][active_layer].erase(key)
		map_data_changed.emit()
		queue_redraw()

func pick_object_at(point: Vector2) -> void:
	# Check Goal
	if map_data.has("base"):
		var base_pos: Vector2 = map_data["base"]
		if point.distance_to(base_pos) < 40.0:
			select_object({"type": "Goal", "id": "base_hq", "position": base_pos})
			return

	# Check Spawns
	if map_data.has("lanes"):
		for key in map_data["lanes"]:
			var spawn_pos: Vector2 = map_data["lanes"][key]
			if point.distance_to(spawn_pos) < 30.0:
				select_object({"type": "Spawn", "id": str(key), "position": spawn_pos})
				return

	# Check Tower Slots
	if map_data.has("slots"):
		for key in map_data["slots"]:
			var slot_pos: Vector2 = map_data["slots"][key]
			if point.distance_to(slot_pos) < 30.0:
				select_object({"type": "Tower Slot", "id": str(key), "position": slot_pos})
				return

	# Check Robot Spots
	if map_data.has("robot_spots"):
		for key in map_data["robot_spots"]:
			var spot_pos: Vector2 = map_data["robot_spots"][key]
			if point.distance_to(spot_pos) < 35.0:
				select_object({"type": "Robot Spot", "id": str(key), "position": spot_pos})
				return

	select_object({})

func select_object(info: Dictionary) -> void:
	selected_object = info
	object_selected.emit(info)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(camera_offset, 0.0, Vector2(camera_zoom, camera_zoom))

	var map_tiles: Vector2i = map_data.get("map_tiles", Vector2i(36, 24))
	var origin: Vector2 = map_data.get("map_origin", Vector2(0, 58))
	var pixel_size: Vector2 = map_data.get("map_pixel_size", Vector2(1152, 768))

	# Canvas Background
	draw_rect(Rect2(origin - Vector2(20, 20), pixel_size + Vector2(40, 40)), Color("0b1519"))
	draw_rect(Rect2(origin, pixel_size), Color("12272e"))

	# Render Tiles from map_data["tiles"]
	if map_data.has("tiles"):
		var layers: Dictionary = map_data["tiles"]
		for layer_name in ["Ground", "RoadComposition", "Vegetation"]:
			if not layers.has(layer_name):
				continue
			var layer_tiles: Dictionary = layers[layer_name]
			for key in layer_tiles:
				var parts := str(key).split(",")
				if parts.size() < 2:
					continue
				var cx := parts[0].to_int()
				var cy := parts[1].to_int()
				var tile_val: Array = layer_tiles[key]
				if tile_val.size() < 3:
					continue
				var source_id := int(tile_val[0])
				var atlas_x := int(tile_val[1])
				var atlas_y := int(tile_val[2])

				var dest_pos := origin + Vector2(cx * 32, cy * 32)
				draw_tile_cell(dest_pos, source_id, Vector2i(atlas_x, atlas_y), layer_name)

	# Grid Lines (32x32)
	var grid_color := Color("7ed6ce", 0.25)
	for x in range(map_tiles.x + 1):
		var x_pos := origin.x + float(x * 32)
		draw_line(Vector2(x_pos, origin.y), Vector2(x_pos, origin.y + pixel_size.y), grid_color, 1.0)
	for y in range(map_tiles.y + 1):
		var y_pos := origin.y + float(y * 32)
		draw_line(Vector2(origin.x, y_pos), Vector2(origin.x + pixel_size.x, y_pos), grid_color, 1.0)

	# Grid Header & Mode Info
	draw_rect(Rect2(origin, pixel_size), Color("7ed6ce"), false, 2.0)
	var mode_str := "MODE: " + edit_mode + " (Layer: " + active_layer + ")"
	draw_string(ThemeDB.fallback_font, origin + Vector2(12, -8), mode_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("d7fff7"))

	# Render Goal Base HQ
	if map_data.has("base"):
		var base_pos: Vector2 = map_data["base"]
		draw_rect(Rect2(base_pos - Vector2(36, 24), Vector2(72, 48)), Color("1c4852", 0.85))
		draw_rect(Rect2(base_pos - Vector2(36, 24), Vector2(72, 48)), Color("7ed6ce"), false, 2.0)
		draw_string(ThemeDB.fallback_font, base_pos + Vector2(-28, 6), "BASE HQ", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("7ed6ce"))

	# Render Spawn Points
	if map_data.has("lanes"):
		for key in map_data["lanes"]:
			var pos: Vector2 = map_data["lanes"][key]
			draw_circle(pos, 16.0, Color("ef7068", 0.7))
			draw_arc(pos, 18.0, 0, TAU, 16, Color("ef7068"), 2.0)
			draw_string(ThemeDB.fallback_font, pos + Vector2(-24, 32), "SPAWN: " + str(key), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ef7068"))

	# Render Tower Slots
	if map_data.has("slots"):
		for key in map_data["slots"]:
			var pos: Vector2 = map_data["slots"][key]
			draw_circle(pos, 14.0, Color("f0a35a", 0.6))
			draw_arc(pos, 16.0, 0, TAU, 16, Color("f0a35a"), 2.0)
			draw_string(ThemeDB.fallback_font, pos + Vector2(-16, 28), "SLOT: " + str(key), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("f0a35a"))

	# Render Robot Spots
	if map_data.has("robot_spots"):
		for key in map_data["robot_spots"]:
			var pos: Vector2 = map_data["robot_spots"][key]
			draw_circle(pos, 18.0, Color("7ed6ce", 0.4))
			draw_arc(pos, 20.0, 0, TAU, 16, Color("7ed6ce"), 2.0)
			draw_string(ThemeDB.fallback_font, pos + Vector2(-24, 34), "SPOT: " + str(key), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("7ed6ce"))

	# Render Selected Object Highlight
	if not selected_object.is_empty() and selected_object.has("position"):
		var sel_pos: Vector2 = selected_object["position"]
		draw_arc(sel_pos, 28.0, 0, TAU, 24, Color("ffe066"), 3.0)
		draw_string(ThemeDB.fallback_font, sel_pos + Vector2(-30, -32), "[SELECTED]", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ffe066"))

func draw_tile_cell(dest_pos: Vector2, source_id: int, atlas_coords: Vector2i, _layer_name: String) -> void:
	var rect := Rect2(dest_pos, Vector2(32, 32))
	if TILESET and TILESET.has_source(source_id):
		var source := TILESET.get_source(source_id) as TileSetAtlasSource
		if source:
			var texture := source.texture
			if texture:
				var src_rect := Rect2(atlas_coords.x * 32, atlas_coords.y * 32, 32, 32)
				draw_texture_rect_region(texture, rect, src_rect)
				return

	# Fallback colored rect if texture region is unavailable
	var col := Color("3a7d44") if source_id == 0 else (Color("5a6275") if source_id == 3 else Color("2b9e66"))
	draw_rect(rect, col)
