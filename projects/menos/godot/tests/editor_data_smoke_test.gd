extends SceneTree

const MAP_LOADER := preload("res://scripts/map_loader.gd")
const EDITOR_CANVAS := preload("res://editor/editor_canvas.gd")
const TEST_MAP_PATH := "user://menos_editor_data_smoke.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var source_map := {
		"version": 7,
		"map_id": "roundtrip_fixture",
		"name": "Roundtrip Fixture",
		"map_size": [36, 24],
		"map_origin": [0.0, 58.0],
		"map_pixel_size": [1152.0, 768.0],
		"goal": {"id": "legacy_hq", "position": [1080.0, 122.0], "custom_goal_flag": "keep"},
		"spawns": {"left": [70.0, 346.0], "right": [288.0, 794.0]},
		"robot_spots": {"CENTER": [720.0, 250.0]},
		"tower_slots": {"L1": [220.0, 310.0]},
		"tiles": {"Ground": {}},
		"objects": [],
		"custom_runtime_metadata": {"revision": "alpha", "preserve": true}
	}
	var map_data: Dictionary = MAP_LOADER.parse_raw_data(source_map)
	map_data["gameplay_areas"] = []
	map_data["gameplay_points"] = []
	if not _check(_save_and_check_map(map_data, source_map), "MapLoader did not preserve legacy or unknown map data"):
		return
	var catalog_file := FileAccess.open("res://content/editor/asset_catalog.json", FileAccess.READ)
	if not _check(catalog_file != null, "Could not open Asset Catalog"):
		return
	var catalog_data: Variant = JSON.parse_string(catalog_file.get_as_text())
	var basic_meadow: Dictionary = {}
	if catalog_data is Dictionary:
		for entry in catalog_data.get("assets", []):
			if entry is Dictionary and str(entry.get("asset_id", "")) == "asset.tile.ground.basic_meadow":
				basic_meadow = entry
	if not _check(str(basic_meadow.get("group", "")) == "Ground" and ResourceLoader.exists(str(basic_meadow.get("source_path", ""))), "Basic Meadow is not registered as a loadable Ground asset"):
		return

	var canvas = EDITOR_CANVAS.new()
	root.add_child(canvas)
	canvas.set_map_data(map_data)
	for element_type in ["spawn_area", "tower_placement_area", "goal_area", "obstacle_area"]:
		if not _check(canvas.create_gameplay_area(element_type, Vector2(34, 92), Vector2(96, 150)), "Could not create %s" % element_type):
			return
	if not _check(canvas.map_data["gameplay_areas"].size() == 4, "Gameplay areas were not stored independently"):
		return

	canvas._select_gameplay_area(0)
	var spawn_area_id := str(canvas.selected_object["id"])
	if not _check(canvas.update_selected_gameplay_properties("zone.spawn.alpha", "North Spawn", false), "Could not update area properties"):
		return
	if not _check(canvas.update_selected_gameplay_area_size(Vector2(96, 64)), "Could not resize gameplay area"):
		return
	var start_position: Vector2 = canvas.selected_object["position"]
	canvas._begin_selected_move(start_position)
	var moved := canvas._apply_selected_move(start_position + Vector2(32, 32))
	if moved:
		canvas._mark_map_data_changed()
		canvas._finish_edit_stroke()
	if not _check(moved and canvas.map_data["gameplay_areas"][0]["position"] == [64.0, 122.0], "Gameplay area drag did not move the area"):
		return

	if not _check(canvas.create_gameplay_point("tower_placement_point", Vector2(170, 220)), "Could not create tower point"):
		return
	if not _check(canvas.create_gameplay_point("robot_position_point", Vector2(230, 260)), "Could not create robot point"):
		return
	var robot_point_id := str(canvas.selected_object["id"])
	canvas._select_gameplay_point(0)
	if not _check(canvas.delete_selected_editor_object(), "Could not delete the selected Tower Point"):
		return
	if not _check(canvas.map_data["gameplay_points"].size() == 1 and str(canvas.map_data["gameplay_points"][0]["id"]) == robot_point_id, "Deleting the Tower Point affected the Robot Point"):
		return
	canvas._select_gameplay_point(0)
	if not _check(canvas.update_selected_gameplay_properties(robot_point_id, "Robot Position A", false, "zone.spawn.alpha"), "Could not edit point properties"):
		return
	if not _check(canvas.update_selected_gameplay_position(Vector2(262, 292)), "Could not move point from Inspector"):
		return

	canvas._select_gameplay_area(0)
	if not _check(canvas.delete_selected_editor_object(), "Could not delete the selected area"):
		return
	var remaining_point: Dictionary = canvas.map_data["gameplay_points"][0]
	if not _check(canvas.map_data["gameplay_areas"].size() == 3 and str(remaining_point.get("area_id", "")) == "", "Deleting an area should preserve its points and clear their relationship"):
		return
	if not _check(spawn_area_id != "", "Area IDs were not generated"):
		return

	var ground_asset := {
		"asset_id": "test.basic_meadow",
		"display_name": "Basic Meadow",
		"group": "Ground",
		"kind": "tile",
		"source_path": "res://assets/menos/maps/ground_basic_32.svg",
		"source_rect_px": [0, 0, 32, 32],
		"footprint_tiles": [1, 1]
	}
	canvas.set_catalog_assets([ground_asset])
	canvas.set_catalog_asset(ground_asset)
	canvas.paint_tile_at(Vector2(16, 74))
	if not _check(canvas.map_data["tiles"]["Ground"].has("0,0"), "Basic Meadow was not placed through the Catalog path"):
		return
	canvas._begin_selected_move(Vector2(16, 74))
	var asset_moved := canvas._apply_selected_move(Vector2(48, 74))
	if asset_moved:
		canvas._mark_map_data_changed()
		canvas._finish_edit_stroke()
	if not _check(asset_moved and canvas.map_data["tiles"]["Ground"].has("1,0"), "Catalog tile placement did not move"):
		return
	if not _check(_save_and_check_map(canvas.map_data, source_map), "Moved Catalog tile did not survive map save/reload"):
		return
	if not _check(canvas.delete_selected_editor_object() and not canvas.map_data["tiles"]["Ground"].has("1,0"), "Catalog tile placement did not delete"):
		return

	if not _check(_save_and_check_map(canvas.map_data, source_map), "Edited map failed save/reload persistence checks"):
		return
	root.size = Vector2i(1600, 900)
	await process_frame
	var editor_scene: PackedScene = load("res://editor/map_editor.tscn")
	if not _check(editor_scene != null, "Could not load the Map Editor scene"):
		return
	var map_editor = editor_scene.instantiate()
	root.add_child(map_editor)
	await process_frame
	if not _check(not map_editor.current_map_data.is_empty(), "The existing Northbridge map did not load in the Editor"):
		return
	if not _check(map_editor.current_map_data.get("lanes", {}).size() == 2 and map_editor.current_map_data.get("robot_spots", {}).size() == 3 and map_editor.current_map_data.get("slots", {}).size() == 6, "Existing spawn, robot, or tower data was not loaded"):
		return
	var editor_asset_rows: VBoxContainer = map_editor.get_node("MainLayout/Inspector/VBox/AssetScroll/AssetRows")
	var meadow_visible := false
	var ground_group_visible := false
	var basic_meadow_button: Button
	for child in editor_asset_rows.get_children():
		if child is Label and str(child.text) == "GROUND":
			ground_group_visible = true
		if child is HBoxContainer:
			for row_child in child.get_children():
				if row_child is Button and str(row_child.text).contains("Basic Meadow"):
					meadow_visible = true
					basic_meadow_button = row_child
				if row_child is TextureButton and row_child.texture_normal != null:
					meadow_visible = meadow_visible or str(child.get_child(1).text).contains("Basic Meadow")
	if not _check(ground_group_visible and meadow_visible, "Ground group or Basic Meadow thumbnail is missing from the Editor Catalog"):
		return
	if not _check(map_editor.get_node_or_null("MainLayout/Toolbox/VBox/PaletteContainer") == null and map_editor.get_node_or_null("MainLayout/Toolbox/VBox/BtnTileGround") == null and map_editor.get_node_or_null("MainLayout/Toolbox/VBox/LblGuideContent") == null, "Obsolete tile palette, Basic Meadow button, or controls guide remains"):
		return
	if not _check(ResourceLoader.exists("res://assets/menos/maps/ground4.png"), "Ground4 asset file was unexpectedly removed"):
		return
	var editor_canvas = map_editor.get_node("MainLayout/CanvasContainer/CanvasRoot")
	var canvas_container: Control = map_editor.get_node("MainLayout/CanvasContainer")
	canvas_container.size = Vector2(640, 700)
	if not _check(not editor_canvas.is_painting_drag and not editor_canvas.is_moving_selection and not editor_canvas.is_resizing_gameplay_area and not editor_canvas.is_creating_gameplay_area, "Canvas gesture was active before Gameplay tab click"):
		return
	var interactive_map: Dictionary = MAP_LOADER.parse_raw_data(source_map)
	interactive_map["gameplay_areas"] = []
	interactive_map["gameplay_points"] = []
	editor_canvas.set_map_data(interactive_map)
	var gameplay_mode_button: Button = map_editor.get_node("MainLayout/Toolbox/VBox/ModeBar/BtnGameplayMode")
	var gameplay_gui_events: Array[String] = []
	gameplay_mode_button.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			gameplay_gui_events.append("pressed=%s button=%s pos=%s" % [str(event.pressed), str(event.button_index), str(event.position)])
		else:
			gameplay_gui_events.append(str(event))
	)
	if not _check(await _click_control(gameplay_mode_button), "Viewport click did not reach the Gameplay tab"):
		return
	if not _check(editor_canvas.editor_mode == "GAMEPLAY" and gameplay_mode_button.button_pressed and map_editor.get_node("MainLayout/Toolbox/VBox/GameplayTools").visible, "Gameplay mode click failed: mode=%s pressed=%s visible=%s rect=%s mouse_filter=%s" % [editor_canvas.editor_mode, str(gameplay_mode_button.button_pressed), str(gameplay_mode_button.visible), str(gameplay_mode_button.get_global_rect()), str(gameplay_mode_button.mouse_filter)]):
		push_error("Gameplay button GUI events=%s hover=%s" % [str(gameplay_gui_events), str(root.gui_get_hovered_control())])
		return
	var asset_mode_button: Button = map_editor.get_node("MainLayout/Toolbox/VBox/ModeBar/BtnAssetMode")
	if not _check(await _click_control(asset_mode_button), "Viewport click did not reach the Asset tab"):
		return
	if not _check(editor_canvas.editor_mode == "ASSET" and asset_mode_button.button_pressed, "Asset editor mode did not activate after a real UI click"):
		return
	if not _check(await _click_control(gameplay_mode_button) and editor_canvas.editor_mode == "GAMEPLAY", "Gameplay tab did not reactivate the Gameplay editor mode"):
		return
	editor_canvas.camera_zoom = 0.5
	editor_canvas.camera_offset = Vector2(8, 8)
	var spawn_screen_position := _world_to_canvas_view(editor_canvas, Vector2(70, 346))
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, spawn_screen_position + Vector2(14.0, 0.0))
	_send_mouse_motion(editor_canvas, spawn_screen_position + Vector2(30.0, 16.0), MOUSE_BUTTON_MASK_LEFT)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, spawn_screen_position + Vector2(30.0, 16.0))
	if not _check(editor_canvas.map_data["lanes"]["left"] == Vector2(102, 378), "Spawn Point did not drag under zoom and pan"):
		return
	var tower_screen_position := _world_to_canvas_view(editor_canvas, Vector2(220, 310))
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, tower_screen_position + Vector2(14.0, 0.0))
	_send_mouse_motion(editor_canvas, tower_screen_position + Vector2(30.0, 16.0), MOUSE_BUTTON_MASK_LEFT)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, tower_screen_position + Vector2(30.0, 16.0))
	if not _check(editor_canvas.map_data["slots"]["L1"] == Vector2(252, 342), "Tower Placement Point did not drag under zoom and pan"):
		return
	var robot_screen_position := _world_to_canvas_view(editor_canvas, Vector2(720, 250))
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, robot_screen_position + Vector2(16.0, 0.0))
	_send_mouse_motion(editor_canvas, robot_screen_position + Vector2(32.0, 16.0), MOUSE_BUTTON_MASK_LEFT)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, robot_screen_position + Vector2(32.0, 16.0))
	if not _check(editor_canvas.map_data["robot_spots"]["CENTER"] == Vector2(752, 282), "Robot Position Point did not drag under zoom and pan"):
		return
	var base_screen_position := _world_to_canvas_view(editor_canvas, Vector2(1080, 122))
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, base_screen_position + Vector2(17.5, 0.0))
	_send_mouse_motion(editor_canvas, base_screen_position + Vector2(33.5, 16.0), MOUSE_BUTTON_MASK_LEFT)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, base_screen_position + Vector2(33.5, 16.0))
	if not _check(editor_canvas.map_data["base"] == Vector2(1112, 154), "Base did not select and drag from the visible hitbox edge"):
		return
	var gameplay_properties: VBoxContainer = map_editor.get_node("MainLayout/Inspector/VBox/GameplayProperties")
	var delete_gameplay_button: Button = gameplay_properties.get_node("BtnDeleteGameplayElement")
	var delete_status: Label = gameplay_properties.get_node("LblGameplayDeleteStatus")
	if not _check(gameplay_properties.visible and str(map_editor.get_node("MainLayout/Inspector/VBox/LblSelectedType").text).contains("Goal") and delete_gameplay_button.disabled and delete_status.visible, "Base Inspector or required-object deletion warning is missing"):
		return
	map_editor.get_node("MainLayout/Inspector/VBox/GameplayProperties/GameplayPositionRow/SpinGameplayX").value = 1120
	map_editor.get_node("MainLayout/Inspector/VBox/GameplayProperties/GameplayPositionRow/SpinGameplayY").value = 160
	map_editor.get_node("MainLayout/Inspector/VBox/GameplayProperties/BtnApplyGameplayProperties").pressed.emit()
	if not _check(editor_canvas.map_data["base"] == Vector2(1120, 160), "Base Inspector position edit did not update the map data"):
		return
	var expected_legacy_map: Dictionary = source_map.duplicate(true)
	expected_legacy_map["goal"]["position"] = [1120.0, 160.0]
	expected_legacy_map["spawns"]["left"] = [102.0, 378.0]
	expected_legacy_map["tower_slots"]["L1"] = [252.0, 342.0]
	expected_legacy_map["robot_spots"]["CENTER"] = [752.0, 282.0]
	if not _check(_save_and_check_map(editor_canvas.map_data, expected_legacy_map), "Moved legacy Points or Base did not persist after save/reload"):
		return
	_send_key(editor_canvas, KEY_DELETE)
	if not _check(editor_canvas.map_data.has("base"), "Delete key removed the required Base"):
		return
	var tower_after_move := _world_to_canvas_view(editor_canvas, Vector2(252, 342))
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, tower_after_move)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, tower_after_move)
	_send_key(editor_canvas, KEY_DELETE)
	if not _check(not editor_canvas.map_data["slots"].has("L1"), "Delete key did not remove only the selected Tower Point"):
		return
	_send_key(editor_canvas, KEY_Z, true)
	if not _check(editor_canvas.map_data["slots"].get("L1") == Vector2(252, 342), "Undo did not restore the deleted Tower Point"):
		return
	var spawn_after_move := _world_to_canvas_view(editor_canvas, Vector2(102, 378))
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, spawn_after_move)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, spawn_after_move)
	if not _check(str(editor_canvas.selected_object.get("type", "")) == "Spawn" and str(editor_canvas.selected_object.get("id", "")) == "left", "Could not select the moved Spawn Point before deletion"):
		return
	map_editor.get_node("MainLayout/Inspector/VBox/GameplayProperties/BtnDeleteGameplayElement").pressed.emit()
	var spawn_delete_button: Button = map_editor.get_node("MainLayout/Inspector/VBox/GameplayProperties/BtnDeleteGameplayElement")
	var inspector_status: Label = map_editor.get_node("BottomBar/HBox/LblStatus")
	if not _check(not editor_canvas.map_data["lanes"].has("left") and editor_canvas.map_data["lanes"].has("right"), "Spawn deletion failed. Remaining lanes=%s; disabled=%s; status=%s" % [JSON.stringify(editor_canvas.map_data.get("lanes", {})), str(spawn_delete_button.disabled), inspector_status.text]):
		return
	var robot_after_move := _world_to_canvas_view(editor_canvas, Vector2(752, 282))
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, robot_after_move)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, robot_after_move)
	map_editor.get_node("MainLayout/Inspector/VBox/GameplayProperties/BtnDeleteGameplayElement").pressed.emit()
	if not _check(not editor_canvas.map_data["robot_spots"].has("CENTER"), "Delete key did not remove the selected Robot Position Point"):
		return
	editor_canvas.camera_zoom = 1.0
	editor_canvas.camera_offset = Vector2.ZERO
	map_editor.get_node("MainLayout/Toolbox/VBox/GameplayTools/BtnSpawnArea").pressed.emit()
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, Vector2(48, 100))
	_send_mouse_motion(editor_canvas, Vector2(112, 164), MOUSE_BUTTON_MASK_LEFT)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, Vector2(112, 164))
	if not _check(editor_canvas.map_data["gameplay_areas"].size() == 1, "Canvas input did not create a Spawn Area"):
		return
	map_editor.get_node("MainLayout/Toolbox/VBox/GameplayTools/BtnGameplaySelect").pressed.emit()
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, Vector2(48, 106))
	_send_mouse_motion(editor_canvas, Vector2(80, 106), MOUSE_BUTTON_MASK_LEFT)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, Vector2(80, 106))
	if not _check(editor_canvas.map_data["gameplay_areas"][0]["position"] == [64.0, 90.0], "Canvas input did not move the selected Spawn Area"):
		return
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, Vector2(154, 180))
	_send_mouse_motion(editor_canvas, Vector2(186, 212), MOUSE_BUTTON_MASK_LEFT)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, Vector2(186, 212))
	if not _check(editor_canvas.map_data["gameplay_areas"][0]["size"] == [128.0, 128.0], "Canvas input did not resize the Spawn Area"):
		return
	map_editor.get_node("MainLayout/Toolbox/VBox/GameplayTools/BtnRobotPoint").pressed.emit()
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, Vector2(208, 202))
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, Vector2(208, 202))
	if not _check(editor_canvas.map_data["gameplay_points"].size() == 1, "Canvas input did not create a Robot Position Point"):
		return
	map_editor.get_node("MainLayout/Toolbox/VBox/GameplayTools/BtnGameplaySelect").pressed.emit()
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, Vector2(208, 202))
	_send_mouse_motion(editor_canvas, Vector2(240, 202), MOUSE_BUTTON_MASK_LEFT)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, Vector2(240, 202))
	if not _check(editor_canvas.map_data["gameplay_points"][0]["position"] == [240.0, 202.0], "Canvas input did not move the selected Robot Point"):
		return
	var gameplay_name_edit: LineEdit = map_editor.get_node("MainLayout/Inspector/VBox/GameplayProperties/EditGameplayName")
	gameplay_name_edit.text = "Relay Position"
	map_editor.get_node("MainLayout/Inspector/VBox/GameplayProperties/BtnApplyGameplayProperties").pressed.emit()
	if not _check(str(editor_canvas.map_data["gameplay_points"][0]["name"]) == "Relay Position", "Inspector did not apply Gameplay Point properties"):
		return
	map_editor.get_node("MainLayout/Inspector/VBox/GameplayProperties/BtnDeleteGameplayElement").pressed.emit()
	if not _check(editor_canvas.map_data["gameplay_points"].is_empty(), "Inspector did not delete the selected Gameplay Point"):
		return
	map_editor.get_node("MainLayout/Toolbox/VBox/ModeBar/BtnAssetMode").pressed.emit()
	if not _check(editor_canvas.editor_mode == "ASSET" and not map_editor.get_node("MainLayout/Toolbox/VBox/GameplayTools").visible, "Asset editor mode did not activate"):
		return
	if not _check(basic_meadow_button != null, "Basic Meadow Catalog row button was not created"):
		return
	basic_meadow_button.pressed.emit()
	map_editor.get_node("MainLayout/Inspector/VBox/BtnPlaceCatalogAsset").pressed.emit()
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, Vector2(16, 74))
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, Vector2(16, 74))
	if not _check(editor_canvas.map_data["tiles"]["Ground"].has("0,0"), "Catalog UI did not place Basic Meadow"):
		return
	map_editor.get_node("MainLayout/Toolbox/VBox/BtnSelect").pressed.emit()
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, Vector2(16, 74))
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, Vector2(16, 74))
	if not _check(str(editor_canvas.selected_object.get("id", "")) == "asset.tile.ground.basic_meadow", "Catalog placement could not be selected in the Editor"):
		return
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, true, Vector2(16, 74))
	_send_mouse_motion(editor_canvas, Vector2(48, 74), MOUSE_BUTTON_MASK_LEFT)
	_send_mouse_button(editor_canvas, MOUSE_BUTTON_LEFT, false, Vector2(48, 74))
	if not _check(editor_canvas.map_data["tiles"]["Ground"].has("1,0"), "Catalog placement could not be moved in the Editor"):
		return
	map_editor.get_node("MainLayout/Inspector/VBox/BtnDeletePlacement").pressed.emit()
	if not _check(not editor_canvas.map_data["tiles"]["Ground"].has("1,0"), "Inspector could not delete the moved Catalog placement"):
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_MAP_PATH))
	print("EDITOR_DATA_SMOKE_TEST_PASS")
	quit(0)

func _save_and_check_map(map_data: Dictionary, original_map: Dictionary) -> bool:
	if not MAP_LOADER.save_map_data(TEST_MAP_PATH, map_data):
		push_error("MapLoader save failed")
		return false
	var loaded := MAP_LOADER.load_map_data(TEST_MAP_PATH)
	if loaded.is_empty():
		push_error("MapLoader reload failed")
		return false
	if loaded.get("map_id") != original_map.get("map_id") or loaded.get("name") != original_map.get("name") or loaded.get("version") != original_map.get("version"):
		push_error("Map identity metadata changed during round trip")
		return false
	var goal_position: Array = original_map.get("goal", {}).get("position", [1080, 122])
	var expected_base := Vector2(float(goal_position[0]), float(goal_position[1]))
	var spawn_position: Array = original_map.get("spawns", {}).get("left", [70, 346])
	var expected_spawn := Vector2(float(spawn_position[0]), float(spawn_position[1]))
	if loaded.get("base") != expected_base or loaded.get("lanes", {}).get("left") != expected_spawn:
		push_error("Legacy goal/spawn fields changed during round trip")
		return false
	var robot_spot_position: Array = original_map.get("robot_spots", {}).get("CENTER", [720, 250])
	var expected_robot_spot := Vector2(float(robot_spot_position[0]), float(robot_spot_position[1]))
	var tower_slot_position: Array = original_map.get("tower_slots", {}).get("L1", [220, 310])
	var expected_tower_slot := Vector2(float(tower_slot_position[0]), float(tower_slot_position[1]))
	if loaded.get("robot_spots", {}).get("CENTER") != expected_robot_spot or loaded.get("slots", {}).get("L1") != expected_tower_slot:
		push_error("Legacy robot/tower fields changed during round trip")
		return false
	var file := FileAccess.open(TEST_MAP_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not read serialized fixture")
		return false
	var serialized: Variant = JSON.parse_string(file.get_as_text())
	if not serialized is Dictionary:
		push_error("Serialized fixture is not a JSON object")
		return false
	if serialized.get("custom_runtime_metadata") != original_map.get("custom_runtime_metadata"):
		push_error("Unknown top-level field was lost")
		return false
	if serialized.get("goal", {}).get("custom_goal_flag") != "keep":
		push_error("Unknown goal field was lost")
		return false
	var expected_tiles: Variant = JSON.parse_string(JSON.stringify(map_data.get("tiles", {})))
	var expected_objects: Variant = JSON.parse_string(JSON.stringify(map_data.get("objects", [])))
	if serialized.get("tiles") != expected_tiles or serialized.get("objects") != expected_objects:
		push_error("Visual asset map data changed during round trip")
		return false
	if serialized.get("gameplay_areas") != map_data.get("gameplay_areas") or serialized.get("gameplay_points") != map_data.get("gameplay_points"):
		push_error("Gameplay area/point data changed during round trip")
		return false
	return true

func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false

func _send_mouse_button(canvas, button_index: MouseButton, pressed: bool, local_position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	event.pressed = pressed
	event.position = canvas.get_global_transform_with_canvas() * local_position
	canvas._input(event)

func _send_mouse_motion(canvas, local_position: Vector2, button_mask: MouseButtonMask) -> void:
	var event := InputEventMouseMotion.new()
	event.button_mask = button_mask
	event.position = canvas.get_global_transform_with_canvas() * local_position
	canvas._input(event)

func _send_key(canvas, keycode: Key, control_pressed: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	event.ctrl_pressed = control_pressed
	canvas._input(event)

func _click_control(control: Control) -> bool:
	var click_position := control.get_global_rect().get_center()
	if control.get_global_rect().size.x <= 0.0 or control.get_global_rect().size.y <= 0.0:
		return false
	var mouse_down := InputEventMouseButton.new()
	mouse_down.button_index = MOUSE_BUTTON_LEFT
	mouse_down.pressed = true
	mouse_down.position = click_position
	mouse_down.global_position = click_position
	root.push_input(mouse_down)
	var mouse_up := InputEventMouseButton.new()
	mouse_up.button_index = MOUSE_BUTTON_LEFT
	mouse_up.pressed = false
	mouse_up.position = click_position
	mouse_up.global_position = click_position
	root.push_input(mouse_up)
	await process_frame
	return true

func _world_to_canvas_view(canvas, world_position: Vector2) -> Vector2:
	return canvas.camera_offset + world_position * canvas.camera_zoom
