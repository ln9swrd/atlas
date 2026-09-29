extends Node2D

var _catalog_tile_cache: Dictionary = {}

const DATA = preload("res://data.gd")
const VISUALS := {
	"floor_tile": preload("res://assets/menos/environment/tile_dark_floor.tres"),
	"facility_base": preload("res://assets/menos/sprites/facility_base.png"),
	"impact_blast": preload("res://assets/menos/sprites/impact_blast.png"),
	"status_victory": preload("res://assets/menos/sprites/status_victory.png"),
	"status_defeat": preload("res://assets/menos/sprites/status_defeat.png"),
	"slot_empty": preload("res://assets/menos/sprites/tower_slot_empty.png"),
	"slot_selected": preload("res://assets/menos/sprites/tower_slot_selected.png"),
	"tower_cannon": preload("res://assets/menos/sprites/tower_cannon.png"),
	"tower_gatling": preload("res://assets/menos/sprites/tower_gatling.png"),
	"enemy_normal": preload("res://assets/menos/sprites/enemy_normal.png"),
	"enemy_rusher": preload("res://assets/menos/sprites/enemy_rusher.png"),
	"enemy_heavy": preload("res://assets/menos/sprites/enemy_heavy.png"),
	"enemy_giant": preload("res://content/editor/edited_assets/enemy_giant_edit_292534902.png"),
	"robot": preload("res://assets/menos/sprites/robot_atlas01.png"),
	"atlas_idle": preload("res://assets/menos/sprites/atlas_idle.png"),
	"atlas_attack": preload("res://assets/menos/sprites/atlas_attack.png"),
	"atlas_move": preload("res://assets/menos/sprites/atlas_move.png"),
	"atlas_skill": preload("res://assets/menos/sprites/atlas_skill.png"),
	"bullet_defender": preload("res://assets/menos/sprites/bullet_defender.png"),
	"bullet_threat": preload("res://assets/menos/sprites/bullet_threat.png"),
	"impact_explosion": preload("res://assets/menos/sprites/impact_explosion.png"),
	"tower_cannon_anim": preload("res://assets/menos/sprites/tower_cannon_anim.png"),
	"tower_gatling_anim": preload("res://assets/menos/sprites/tower_gatling_anim.png"),
	"enemy_normal_anim": preload("res://assets/menos/sprites/enemy_normal_anim.png"),
	"enemy_rusher_anim": preload("res://assets/menos/sprites/enemy_rusher_anim.png"),
	"enemy_heavy_anim": preload("res://assets/menos/sprites/enemy_heavy_anim.png"),
	"enemy_giant_anim": preload("res://assets/menos/sprites/enemy_giant_anim.png")
}
const ENEMY_SPRITE_SIZES := {
	"normal": Vector2(38, 52),
	"rusher": Vector2(42, 54),
	"heavy": Vector2(64, 72),
	"giant": Vector2(112, 150)
}
const SFX_STREAMS := {
	"ui_click": preload("res://sound/sfx_ui_click_1.mp3"),
	"ui_confirm": preload("res://sound/Menu Choice.mp3"),
	"ui_cancel": preload("res://sound/Decline.wav"),
	"ui_error": preload("res://sound/Error or failed.mp3"),
	"tower_select": preload("res://sound/beep.mp3"),
	"tower_build": preload("res://sound/buzz_0.ogg"),
	"enemy_spawn": preload("res://sound/172206__fins__teleport.wav"),
	"wave_start": preload("res://sound/g_get_ready.wav")
}
var BASE := Vector2.ZERO
var LANES: Dictionary = {}
var SPAWN_AREAS: Dictionary = {}
var SPAWN_AREA_SEQUENCE: Dictionary = {}
var ROBOT_SPOTS: Dictionary = {}
var TOWER_PLACEMENT_AREAS: Array[Rect2] = []
var SLOTS: Dictionary = {}
const ROBOT_GROWTH_OPTIONS := {
	"ability_area": {"name": "AREA ATTACK", "description": "Hits 3 or more nearby enemies."},
	"ability_heavy_pierce": {"name": "HEAVY PIERCE", "description": "Targets Heavy and Giant enemies."}
}
const GROWTH_OPTION_RECTS := {
	"ability_area": Rect2(180, 320, 300, 78),
	"ability_heavy_pierce": Rect2(500, 320, 300, 78)
}
var MAP_TILES := Vector2i(36, 24)
var MAP_ORIGIN := Vector2(0, 58)
var MAP_PIXEL_SIZE := Vector2(1152, 768)
const SIDEBAR_X := 20.0
const CAMPAIGN_STAGE_COUNT := 3
const MAP_TILE_SOURCE_GROUND := 0
const MAP_TILE_SOURCE_ROAD := 1
const MAP_TILE_SOURCE_BOUNDARY := 2
const MAP_TILE_SOURCE_ROAD_COMPOSITION := 3
const MAP_TILE_SOURCE_GRASS := 4
const MAP_TILE_SOURCE_A7_MODULE := 5
const MAP_TILE_SOURCE_GROUND_DARK := 6
const MAP_TILE_SOURCE_A7_CONCRETE := 7
const VEGETATION_ANCHORS := [Vector2i(1, 7), Vector2i(21, 7), Vector2i(1, 13), Vector2i(21, 13)]
enum RunState { READY, RUNNING, GROWTH, VICTORY, DEFEAT }

var base_hp := 100.0
var gold := 180
var wave := 1
var run_state := RunState.READY
var wave_running := false
var wave_clear := false
var wave_auto_start_timer := 0.0
const WAVE_AUTO_START_DELAY := 2.5
var elapsed := 0.0
var spawn_clock := 0.0
var spawn_queue: Array = []
var enemies: Array = []
var enemy_catalog: Dictionary = DATA.ENEMIES.duplicate(true)
var enemy_sprite_catalog: Dictionary = {}
var tower_catalog: Dictionary = DATA.TOWERS.duplicate(true)
var tower_sprite_catalog: Dictionary = {}
var towers: Array = []
var robot := {}
var robot_progression := {}
const ROBOT_SPECIAL_DURATION := 0.5
var feed: Array[String] = []
var selected_slot := ""
var selected_slot_position := Vector2.ZERO
var selected_tower := ""
var pending_tower_type := ""
var robot_selected := false
var camera_dragging := false
var camera_last_mouse := Vector2.ZERO
const CAMERA_EDGE_MARGIN := 28.0
const CAMERA_EDGE_SPEED := 720.0
const BOTTOM_HUD_HEIGHT := 188.0
var damage_numbers: Array = []
var effects: Array = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_load_enemy_catalog()
	_load_tower_catalog()
	if StageManager.run_mode == "single":
		if not load_stage_map(StageManager.selected_stage_id):
			build_first_battle_map()
	else:
		StageManager.reset_session()
		if not load_stage_map("stage_01"):
			build_first_battle_map()
	reset_game()
	_setup_camera()
	queue_redraw()


func _setup_camera() -> void:
	var camera: Camera2D = $Camera2D
	# Keep the battlefield centered in the visible play area above the bottom HUD.
	camera.position = MAP_ORIGIN + MAP_PIXEL_SIZE * 0.5 + Vector2(0.0, BOTTOM_HUD_HEIGHT * 0.5)
	var viewport_size := get_viewport_rect().size
	camera.limit_left = int(MAP_ORIGIN.x)
	camera.limit_top = int(MAP_ORIGIN.y)
	camera.limit_right = int(MAP_ORIGIN.x + MAP_PIXEL_SIZE.x)
	camera.limit_bottom = int(MAP_ORIGIN.y + MAP_PIXEL_SIZE.y)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0

func _texture_from_catalog_entry(data: Dictionary, field: String) -> Texture2D:
	var sprite_path := str(data.get(field, ""))
	if sprite_path.is_empty():
		return null
	var base_texture: Texture2D = load(sprite_path) as Texture2D
	if base_texture == null:
		return null
	var rect_values: Variant = data.get(field + "_rect", [])
	if rect_values is Array and rect_values.size() >= 4:
		var rect := Rect2i(int(rect_values[0]), int(rect_values[1]), int(rect_values[2]), int(rect_values[3]))
		var image_size := Vector2i(base_texture.get_width(), base_texture.get_height())
		if rect.size.x > 0 and rect.size.y > 0 and rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= image_size.x and rect.end.y <= image_size.y:
			var atlas := AtlasTexture.new()
			atlas.atlas = base_texture
			atlas.region = Rect2(rect.position, rect.size)
			return atlas
	return base_texture

func _load_enemy_catalog() -> void:
	var path := "res://content/enemies/enemies.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary and not parsed.is_empty():
		for enemy_type in parsed:
			if parsed[enemy_type] is Dictionary and DATA.ENEMIES.has(enemy_type):
				enemy_catalog[enemy_type] = parsed[enemy_type].duplicate(true)
	enemy_sprite_catalog.clear()
	for enemy_type in DATA.ENEMIES:
		var sprite: Texture2D = _texture_from_catalog_entry(enemy_catalog[enemy_type], "sprite_anim")
		if sprite:
			enemy_sprite_catalog[enemy_type] = sprite
		else:
			enemy_sprite_catalog[enemy_type] = VISUALS.get("enemy_%s_anim" % enemy_type)

func _load_tower_catalog() -> void:
	var path := "res://content/towers/towers.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary and not parsed.is_empty():
			for tower_type in parsed:
				if parsed[tower_type] is Dictionary and DATA.TOWERS.has(tower_type):
					tower_catalog[tower_type] = parsed[tower_type].duplicate(true)
	tower_sprite_catalog.clear()
	for tower_type in DATA.TOWERS:
		var sprite: Texture2D = _texture_from_catalog_entry(tower_catalog[tower_type], "sprite_anim")
		if sprite:
			tower_sprite_catalog[tower_type] = sprite
		else:
			tower_sprite_catalog[tower_type] = VISUALS.get("tower_%s_anim" % tower_type)

func load_stage_map(stage_id: String) -> bool:
	if StageManager.load_stage(stage_id).is_empty():
		return false
	var loaded_map := MapLoader.load_map_data(StageManager.get_map_file())
	if loaded_map.is_empty():
		return false
	apply_map_spatial_data(loaded_map)
	if has_node("Camera2D"):
		_setup_camera()
	if not build_map_from_data(loaded_map):
		build_first_battle_map()
	return true

func restart_campaign() -> void:
	StageManager.reset_session()
	if not load_stage_map("stage_01"):
		push_error("Could not reload campaign Stage 1.")
		return
	reset_game()

func apply_map_spatial_data(loaded_map: Dictionary) -> void:
	BASE = Vector2.ZERO
	LANES.clear()
	SPAWN_AREAS.clear()
	SPAWN_AREA_SEQUENCE.clear()
	ROBOT_SPOTS.clear()
	TOWER_PLACEMENT_AREAS.clear()
	SLOTS.clear()

	if loaded_map.has("base"):
		BASE = loaded_map["base"]
	if loaded_map.has("map_tiles"):
		MAP_TILES = loaded_map["map_tiles"]
	if loaded_map.has("map_origin"):
		MAP_ORIGIN = loaded_map["map_origin"]
	if loaded_map.has("map_pixel_size"):
		MAP_PIXEL_SIZE = loaded_map["map_pixel_size"]

	var gameplay_areas: Variant = loaded_map.get("gameplay_areas", [])
	if gameplay_areas is Array:
		var spawn_index := 0
		for area_data in gameplay_areas:
			if not area_data is Dictionary or not bool(area_data.get("enabled", true)):
				continue
			var area_position: Variant = area_data.get("position", [0.0, 0.0])
			var area_size: Variant = area_data.get("size", [0.0, 0.0])
			if not area_position is Array or area_position.size() < 2 or not area_size is Array or area_size.size() < 2:
				continue
			var rect := Rect2(float(area_position[0]), float(area_position[1]), float(area_size[0]), float(area_size[1]))
			var area_type := str(area_data.get("type", ""))
			if area_type == "spawn_area":
				var lane_id := "spawn_%d" % spawn_index
				SPAWN_AREAS[lane_id] = rect
				LANES[lane_id] = rect.get_center()
				spawn_index += 1
			elif area_type == "tower_placement_area":
				TOWER_PLACEMENT_AREAS.append(rect)

	var gameplay_points: Variant = loaded_map.get("gameplay_points", [])
	if gameplay_points is Array:
		var point_index := 0
		for point_data in gameplay_points:
			if not point_data is Dictionary or not bool(point_data.get("enabled", true)):
				continue
			if str(point_data.get("type", "")) != "robot_position_point":
				continue
			var point_position: Variant = point_data.get("position", [0.0, 0.0])
			if not point_position is Array or point_position.size() < 2:
				continue
			var point_id := str(point_data.get("id", "robot_position_%d" % point_index))
			ROBOT_SPOTS[point_id] = Vector2(float(point_position[0]), float(point_position[1]))
			point_index += 1

	# Legacy fields are accepted only when explicitly present in the map.
	if LANES.is_empty() and loaded_map.has("lanes"):
		LANES = loaded_map["lanes"].duplicate(true)
	if ROBOT_SPOTS.is_empty() and loaded_map.has("robot_spots"):
		ROBOT_SPOTS = loaded_map["robot_spots"].duplicate(true)
	if loaded_map.has("slots"):
		SLOTS = loaded_map["slots"].duplicate(true)

func build_map_from_data(map_data: Dictionary) -> bool:
	if not map_data.has("tiles") or map_data["tiles"].is_empty():
		return false

	var layers_dict: Dictionary = map_data["tiles"]
	var has_any_tile := false
	for layer_name in layers_dict:
		if not layers_dict[layer_name].is_empty():
			has_any_tile = true
			break

	if not has_any_tile:
		return false

	var ground: TileMapLayer = $Ground
	var vegetation: TileMapLayer = $Vegetation
	var road: TileMapLayer = $Road
	var road_composition: TileMapLayer = $RoadComposition
	var boundary: TileMapLayer = $Boundary

	ground.clear()
	vegetation.clear()
	road.clear()
	road_composition.clear()
	boundary.clear()

	var layer_nodes := {
		"Ground": ground,
		"Vegetation": vegetation,
		"Road": road,
		"RoadComposition": road_composition,
		"Boundary": boundary
	}

	for layer_name in layers_dict:
		if not layer_nodes.has(layer_name):
			continue
		var layer_node: TileMapLayer = layer_nodes[layer_name]
		var tiles_info: Dictionary = layers_dict[layer_name]

		for key in tiles_info:
			var parts := str(key).split(",")
			if parts.size() < 2:
				continue
			var cx := parts[0].to_int()
			var cy := parts[1].to_int()
			var tile_data: Variant = tiles_info[key]
			var tile_values: Array = []
			if tile_data is Array:
				tile_values = tile_data
			elif tile_data is Dictionary:
				var asset_id := str(tile_data.get("asset_id", ""))
				var resolved := _resolve_catalog_tile(layer_node, asset_id)
				if resolved.is_empty():
					continue
				tile_values = resolved
			if tile_values.size() < 3:
				continue
			var source_id := int(tile_values[0])
			var atlas_x := int(tile_values[1])
			var atlas_y := int(tile_values[2])

			layer_node.set_cell(Vector2i(cx, cy), source_id, Vector2i(atlas_x, atlas_y))

	return true

func _resolve_catalog_tile(layer_node: TileMapLayer, asset_id: String) -> Array:
	if _catalog_tile_cache.has(asset_id):
		return _catalog_tile_cache[asset_id]
	var file := FileAccess.open("res://content/editor/asset_catalog.json", FileAccess.READ)
	if file == null:
		_catalog_tile_cache[asset_id] = []
		return []
	var catalog_data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not catalog_data is Dictionary:
		_catalog_tile_cache[asset_id] = []
		return []
	var assets: Variant = catalog_data.get("assets", [])
	if not assets is Array:
		_catalog_tile_cache[asset_id] = []
		return []
	for entry_data in assets:
		if not entry_data is Dictionary or str(entry_data.get("asset_id", "")) != asset_id:
			continue
		var source_path := str(entry_data.get("source_path", ""))
		var rect_values: Variant = entry_data.get("source_rect_px", [0, 0, 32, 32])
		if not rect_values is Array or rect_values.size() < 2:
			break
		var tile_set := layer_node.tile_set
		if tile_set == null:
			break
		for source_index in range(tile_set.get_source_count()):
			var source_id := tile_set.get_source_id(source_index)
			var atlas_source := tile_set.get_source(source_id) as TileSetAtlasSource
			if atlas_source == null or atlas_source.get_texture() == null:
				continue
			if atlas_source.get_texture().resource_path != source_path:
				continue
			var region_size := atlas_source.get_texture_region_size()
			if region_size.x <= 0 or region_size.y <= 0:
				continue
			var atlas_coords := Vector2i(int(float(rect_values[0]) / region_size.x), int(float(rect_values[1]) / region_size.y))
			if atlas_source.has_tile(atlas_coords):
				var resolved := [source_id, atlas_coords.x, atlas_coords.y]
				_catalog_tile_cache[asset_id] = resolved
				return resolved
		break
	_catalog_tile_cache[asset_id] = []
	return []

func build_first_battle_map() -> void:
	var ground: TileMapLayer = $Ground
	var vegetation: TileMapLayer = $Vegetation
	var road: TileMapLayer = $Road
	var road_composition: TileMapLayer = $RoadComposition
	var boundary: TileMapLayer = $Boundary
	ground.clear()
	vegetation.clear()
	road.clear()
	road_composition.clear()
	boundary.clear()
	for y in range(MAP_TILES.y):
		for x in range(MAP_TILES.x):
			var mod_x := x % 4
			var mod_y := y % 4
			ground.set_cell(Vector2i(x, y), MAP_TILE_SOURCE_A7_MODULE, Vector2i(40 + mod_x, 16 + mod_y))
	for x in range(1, MAP_TILES.x - 1):
		var lower_start := 9.0
		var lower_span := float(MAP_TILES.x - 1) - lower_start
		var lower_progress := clampf((float(x) - lower_start) / lower_span, 0.0, 1.0)
		var lower_y := int(lerpf(23.0, 2.0, lower_progress))
		var upper_y := int(lerpf(9.0, 2.0, float(x) / float(MAP_TILES.x - 1)))
		if x >= int(lower_start): road.set_cell(Vector2i(x, lower_y), MAP_TILE_SOURCE_ROAD, Vector2i.ZERO)
		road.set_cell(Vector2i(x, upper_y), MAP_TILE_SOURCE_ROAD, Vector2i.ZERO)

func play_sfx(id: String) -> void:
	if not SFX_STREAMS.has(id): return
	var player := AudioStreamPlayer.new()
	player.stream = SFX_STREAMS[id]
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func reset_game() -> void:
	base_hp = StageManager.get_base_hp(); gold = StageManager.get_initial_gold(); wave = 1; run_state = RunState.READY; wave_running = false; wave_clear = false; elapsed = 0.0
	spawn_clock = 0.0; spawn_queue.clear(); enemies.clear(); towers.clear(); effects.clear(); damage_numbers.clear(); selected_slot = ""; selected_slot_position = Vector2.ZERO; selected_tower = ""; robot_selected = false
	wave_auto_start_timer = WAVE_AUTO_START_DELAY
	var initial_robot_spot := ""
	var initial_robot_position := BASE
	if not ROBOT_SPOTS.is_empty():
		initial_robot_spot = str(ROBOT_SPOTS.keys()[0])
		initial_robot_position = ROBOT_SPOTS[initial_robot_spot]
	robot = {"active": false, "spot": initial_robot_spot, "position": initial_robot_position, "manual_position": false, "hp": DATA.ROBOT.hp, "commands": DATA.ROBOT.max_moves, "attack": 0.0, "area": 0.0, "pierce": 0.0, "special": 0.0, "special_type": "", "flash": 0.0}
	robot_progression = {"unlocked_abilities": []}
	feed.clear(); log_event("Build towers and prepare ATLAS-01. Wave 1 starts automatically.")

func log_event(text: String) -> void:
	feed.push_front(text); feed = feed.slice(0, 5); queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	update_camera_edge_scroll(delta)
	update_robot_manual_input(delta)
	if run_state == RunState.READY and not wave_running and wave_auto_start_timer > 0.0:
		wave_auto_start_timer -= delta
		if wave_auto_start_timer <= 0.0:
			start_wave()
	if wave_running:
		spawn_clock += delta
		spawn_enemies()
		move_enemies(delta)
		update_towers(delta)
		update_robot(delta)
		check_wave_clear()
	for damage_number in damage_numbers:
		damage_number["life"] = float(damage_number.get("life", 0.0)) - delta
		damage_number["position"] = damage_number.get("position", Vector2.ZERO) + Vector2(0, -18.0 * delta)
	damage_numbers = damage_numbers.filter(func(item): return float(item.get("life", 0.0)) > 0.0)
	if robot.get("active", false):
		robot["flash"] = max(0.0, float(robot.get("flash", 0.0)) - delta)
	for effect in effects:
		if effect.has("progress"):
			effect["progress"] = float(effect["progress"]) + delta * float(effect.get("speed", 4.0))
			if float(effect["progress"]) >= 1.0 and effect.get("source", "") == "robot" and not effect.get("hit_applied", false):
				effect["hit_applied"] = true
				damage_enemy(effect.get("target_enemy", null), float(effect.get("damage", 0.0)), str(effect.get("source", "")))
				effect["type"] = "impact_explosion"
				effect.erase("progress")
				effect["life"] = 0.35
				effect["max_life"] = 0.35
		elif effect.has("damage_delay"):
			effect["damage_delay"] = float(effect["damage_delay"]) - delta
			if float(effect["damage_delay"]) <= 0.0 and not effect.get("damage_applied", false):
				effect["damage_applied"] = true
				if effect.has("damage_targets"):
					for target in effect["damage_targets"]:
						damage_enemy(target, float(effect.get("damage", 0.0)), str(effect.get("source", "special")))
				else:
					damage_enemy(effect.get("target_enemy", null), float(effect.get("damage", 0.0)), str(effect.get("source", "special")))
				effect.erase("damage_delay")
				effect["life"] = 0.35
				effect["max_life"] = 0.35
		else:
			effect["life"] = float(effect["life"]) - delta
	effects = effects.filter(func(item): return (item.has("progress") and float(item.get("progress", 0.0)) < 1.0) or (not item.has("progress") and float(item.get("life", 0.0)) > 0.0))
	queue_redraw()

func start_wave() -> void:
	var waves_data := StageManager.get_waves()
	if run_state != RunState.READY or wave_running or base_hp <= 0.0 or wave > waves_data.size(): return
	if not robot.active:
		robot.hp = DATA.ROBOT.hp
		robot.active = true
		robot_selected = false
		log_event("ATLAS-01 deployed at %s." % robot.spot)
	spawn_queue.clear()
	var offset := 0.0
	for group in waves_data[wave - 1]["groups"]:
		for index in range(group[1]):
			spawn_queue.append({"type": group[0], "delay": offset + index * group[2], "lanes": group[3]})
		offset += group[1] * group[2] + 0.3
	spawn_clock = 0.0; SPAWN_AREA_SEQUENCE.clear(); wave_running = true; run_state = RunState.RUNNING; wave_clear = false
	play_sfx("wave_start")
	log_event("WAVE %d STARTED: %s" % [wave, waves_data[wave - 1]["label"]])

func spawn_enemies() -> void:
	if LANES.is_empty():
		return
	var spawn_points: Array = LANES.keys()
	while not spawn_queue.is_empty() and spawn_queue[0].delay <= spawn_clock:
		var entry: Dictionary = spawn_queue.pop_front()
		var requested_lanes: Array = entry.get("lanes", [])
		var lane := ""
		if not requested_lanes.is_empty():
			var requested_lane := str(requested_lanes[enemies.size() % requested_lanes.size()])
			if LANES.has(requested_lane) and not SPAWN_AREAS.has(requested_lane):
				lane = requested_lane
			elif requested_lane in ["left", "right"] and not SPAWN_AREAS.is_empty():
				var area_keys: Array = SPAWN_AREAS.keys()
				var area_index := int(SPAWN_AREA_SEQUENCE.get("__global__", 0)) % area_keys.size()
				lane = str(area_keys[area_index])
				SPAWN_AREA_SEQUENCE["__global__"] = area_index + 1
		if lane.is_empty():
			lane = str(spawn_points[enemies.size() % spawn_points.size()])
		var data: Dictionary = enemy_catalog[entry.type]
		var spawn_position: Vector2 = LANES[lane]
		if SPAWN_AREAS.has(lane):
			var spawn_rect: Rect2 = SPAWN_AREAS[lane]
			var segment_count := 4
			var segment_index := int(SPAWN_AREA_SEQUENCE.get(lane, 0)) % segment_count
			SPAWN_AREA_SEQUENCE[lane] = int(SPAWN_AREA_SEQUENCE.get(lane, 0)) + 1
			var segment_width := spawn_rect.size.x / float(segment_count)
			var segment_rect := Rect2(spawn_rect.position + Vector2(segment_width * segment_index, 0.0), Vector2(segment_width, spawn_rect.size.y))
			spawn_position = Vector2(randf_range(segment_rect.position.x, segment_rect.end.x), randf_range(segment_rect.position.y, segment_rect.end.y))
		enemies.append({"type": entry.type, "lane": lane, "position": spawn_position, "start_position": spawn_position, "hp": data.hp, "max_hp": data.hp, "flash": 0.0, "robot_attack_timer": 0.0})

func damage_robot(amount: float) -> void:
	if not robot.active: return
	robot.hp = max(0.0, robot.hp - amount)
	robot["flash"] = 0.12
	effects.append({"position": robot.position, "type": "giantHit", "life": 0.28})
	if robot.hp <= 0.0:
		robot.hp = 0.0; robot.active = false; robot_selected = false; log_event("ATLAS-01 destroyed. Base defense remains active.")

func update_giant_robot_attack(delta: float, enemy: Dictionary) -> void:
	if enemy.type != "giant" or not robot.active or robot.hp <= 0.0: return
	var data: Dictionary = enemy_catalog[enemy.type]
	enemy.robot_attack_timer -= delta
	if enemy.position.distance_to(robot.position) > data.robot_range: return
	if enemy.robot_attack_timer > 0.0: return
	effects.append({"type": "proj_threat", "start": enemy.position, "target": robot.position, "progress": 0.0, "speed": 4.0})
	damage_robot(data.robot_damage)
	enemy.robot_attack_timer = data.robot_cooldown
	if robot.active:
		log_event("GIANT hit ATLAS-01 for %d damage." % int(data.robot_damage))

func move_enemies(delta: float) -> void:
	for enemy in enemies:
		if enemy.hp <= 0.0: continue
		var data: Dictionary = enemy_catalog[enemy.type]
		var start: Vector2 = enemy.get("start_position", LANES[enemy.lane])
		enemy.position.x += data.speed * delta
		var progress: float = clampf((enemy.position.x - start.x) / (BASE.x - start.x), 0.0, 1.0)
		enemy.position.y = lerp(start.y, BASE.y, progress)
		if enemy.type == "giant":
			update_giant_robot_attack(delta, enemy)
		if enemy.position.x >= BASE.x - 25.0:
			base_hp -= data.base_damage; enemy.hp = 0.0
			log_event("%s breached the base (-%d HP)." % [data.name, data.base_damage])
			if base_hp <= 0.0:
				base_hp = 0.0; wave_running = false; run_state = RunState.DEFEAT
				log_event("DEFEAT. The base was destroyed. Press RESTART to try again.")
				return

func damage_enemy(enemy: Dictionary, amount: float, source: String) -> void:
	if enemy == null or enemy.hp <= 0.0: return
	var data: Dictionary = enemy_catalog[enemy.type]
	var dealt: float = max(1.0, amount - data.armor)
	enemy.hp -= dealt; enemy.flash = 0.12
	effects.append({"position": enemy.position, "type": "impact_explosion", "life": 0.35, "max_life": 0.35, "source": source})
	damage_numbers.append({"position": enemy.position + Vector2(0, -32), "value": int(dealt), "life": 0.7, "max_life": 0.7})
	if enemy.hp <= 0.0:
		gold += data.reward
		if enemy.type == "giant": log_event("GIANT NEUTRALIZED. ATLAS-01 changed the outcome.")

func find_target(position: Vector2, range_value: float, preference: String = "") -> Dictionary:
	var candidates: Array = enemies.filter(func(enemy): return enemy.hp > 0.0 and enemy.position.distance_to(position) <= range_value)
	if candidates.is_empty(): return {}
	if preference == "heavy":
		var heavy := candidates.filter(func(enemy): return enemy.type in ["heavy", "giant"])
		if not heavy.is_empty(): candidates = heavy
	elif preference == "fast":
		var fast := candidates.filter(func(enemy): return enemy.type in ["normal", "rusher"])
		if not fast.is_empty(): candidates = fast
	candidates.sort_custom(func(a, b): return a.position.x > b.position.x)
	return candidates[0]

func get_robot_target() -> Dictionary:
	var candidates: Array = enemies.filter(func(enemy): return enemy.hp > 0.0 and enemy.position.distance_to(robot.position) <= DATA.ROBOT.range)
	if candidates.is_empty(): return {}
	candidates.sort_custom(func(a, b): return a.position.x > b.position.x)
	return candidates[0]

func get_robot_heavy_target() -> Dictionary:
	var candidates: Array = enemies.filter(func(enemy): return enemy.hp > 0.0 and enemy.type in ["heavy", "giant"] and enemy.position.distance_to(robot.position) <= DATA.ROBOT.range + 20.0)
	if candidates.is_empty(): return {}
	candidates.sort_custom(func(a, b): return a.position.x > b.position.x)
	return candidates[0]

func get_robot_chase_target() -> Dictionary:
	var candidates: Array = enemies.filter(func(enemy): return enemy.hp > 0.0)
	if candidates.is_empty(): return {}
	candidates.sort_custom(func(a, b): return a.position.distance_to(robot.position) < b.position.distance_to(robot.position))
	return candidates[0]

func get_robot_auto_spot() -> String:
	if ROBOT_SPOTS.is_empty():
		return ""
	var active_enemies: Array = enemies.filter(func(enemy): return enemy.hp > 0.0)
	if active_enemies.is_empty():
		return ""
	var target := Vector2.ZERO
	for enemy in active_enemies:
		target += enemy.position
	target /= float(active_enemies.size())
	var best_id := ""
	var best_distance := INF
	for id in ROBOT_SPOTS:
		var distance: float = ROBOT_SPOTS[id].distance_to(target)
		if distance < best_distance:
			best_distance = distance
			best_id = str(id)
	return best_id

func update_robot_manual_input(delta: float) -> void:
	if not robot.get("active", false) or robot.hp <= 0.0 or run_state not in [RunState.READY, RunState.RUNNING]:
		return
	var direction := Vector2.ZERO
	direction.x = float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
	direction.y = float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
	if direction == Vector2.ZERO:
		robot["is_moving"] = false
		return
	direction = direction.normalized()
	robot["manual_position"] = true
	robot.erase("target_pos")
	robot["spot"] = "CUSTOM"
	robot["is_moving"] = true
	var target: Vector2 = robot.position + direction * DATA.ROBOT.speed * delta
	robot.position = Vector2(
		clampf(target.x, MAP_ORIGIN.x + 32.0, MAP_ORIGIN.x + MAP_PIXEL_SIZE.x - 32.0),
		clampf(target.y, MAP_ORIGIN.y + 32.0, MAP_ORIGIN.y + MAP_PIXEL_SIZE.y - 32.0)
	)

func move_robot_automatically(delta: float) -> void:
	if not wave_running or float(robot.get("special", 0.0)) > 0.0: return
	if robot.has("target_pos"):
		var manual_target: Vector2 = robot.target_pos
		var manual_distance: float = robot.position.distance_to(manual_target)
		var manual_step: float = DATA.ROBOT.speed * delta
		if manual_distance <= manual_step:
			robot.position = manual_target
			robot.erase("target_pos")
		else:
			robot.position += robot.position.direction_to(manual_target) * manual_step
		return
	if robot.get("manual_position", false): return
	var auto_spot := get_robot_auto_spot()
	if auto_spot.is_empty(): return
	if robot.spot != auto_spot:
		robot.spot = auto_spot
		robot["target_pos"] = ROBOT_SPOTS[auto_spot]
		log_event("ATLAS-01 moving to %s." % auto_spot)
	if not robot.has("target_pos"): return
	var target_pos: Vector2 = robot.target_pos
	var distance: float = robot.position.distance_to(target_pos)
	var step := DATA.ROBOT.speed * delta
	if distance <= step:
		robot.position = target_pos
		robot.erase("target_pos")
	else:
		robot.position += robot.position.direction_to(target_pos) * step

func move_robot_to_position(point: Vector2) -> void:
	if not robot.active or run_state not in [RunState.READY, RunState.RUNNING]: return
	var target := Vector2(clampf(point.x, MAP_ORIGIN.x + 32.0, MAP_ORIGIN.x + MAP_PIXEL_SIZE.x - 32.0), clampf(point.y, MAP_ORIGIN.y + 32.0, MAP_ORIGIN.y + MAP_PIXEL_SIZE.y - 32.0))
	robot["manual_position"] = true
	robot.spot = "CUSTOM"
	if wave_running:
		robot["target_pos"] = target
	else:
		robot.position = target
	log_event("ATLAS-01 moving to the selected map position.")

func update_towers(delta: float) -> void:
	for tower in towers:
		tower.cooldown -= delta
		if tower.cooldown > 0.0: continue
		var target: Dictionary = find_target(tower.position, tower.data.range, tower.data.preference)
		if target.is_empty(): continue
		effects.append({"type": "proj_defender", "start": tower.position, "target": target.position, "progress": 0.0, "speed": 5.0, "weapon": tower.type})
		damage_enemy(target, tower.data.damage, tower.type); tower.cooldown = tower.data.cooldown

func update_robot(delta: float) -> void:
	if not robot.active or robot.hp <= 0.0: return
	robot["special"] = max(0.0, float(robot.get("special", 0.0)) - delta)
	if float(robot.get("special", 0.0)) > 0.0:
		return
	move_robot_automatically(delta)
	robot.attack -= delta; robot.area -= delta; robot.pierce -= delta
	var target: Dictionary = get_robot_target()
	var heavy: Dictionary = get_robot_heavy_target()
	if robot.attack <= 0.0 and not target.is_empty():
		effects.append({"type": "proj_defender", "start": robot.position, "target": target.position, "target_enemy": target, "damage": DATA.ROBOT.damage, "source": "robot", "weapon": "robot", "progress": 0.0, "speed": 5.5})
		robot.attack = DATA.ROBOT.cooldown

func try_special_attack() -> bool:
	if not robot.active or robot.hp <= 0.0 or run_state != RunState.RUNNING:
		return false
	if float(robot.get("special", 0.0)) > 0.0:
		return false
	var unlocked_abilities: Array = robot_progression.get("unlocked_abilities", [])
	if unlocked_abilities.has("ability_area") and robot.area <= 0.0:
		var nearby: Array = enemies.filter(func(enemy): return enemy.hp > 0.0 and enemy.position.distance_to(robot.position) <= DATA.ROBOT.ability_area.radius)
		if nearby.size() >= DATA.ROBOT.ability_area.threshold:
			effects.append({"position": robot.position, "type": "area", "life": 0.45, "damage_delay": 0.22, "damage_targets": nearby, "damage": DATA.ROBOT.ability_area.damage, "source": "area"})
			robot["special"] = ROBOT_SPECIAL_DURATION
			robot["special_type"] = "area"
			robot.area = DATA.ROBOT.ability_area.cooldown
			log_event("ATLAS-01 used AREA ATTACK.")
			return true
	if unlocked_abilities.has("ability_heavy_pierce") and robot.pierce <= 0.0:
		var heavy: Dictionary = get_robot_heavy_target()
		if not heavy.is_empty():
			effects.append({"position": heavy.position, "type": "pierce", "life": 0.45, "damage_delay": 0.22, "target_enemy": heavy, "damage": DATA.ROBOT.ability_pierce.damage, "source": "pierce"})
			robot["special"] = ROBOT_SPECIAL_DURATION
			robot["special_type"] = "pierce"
			robot.pierce = DATA.ROBOT.ability_pierce.cooldown
			log_event("ATLAS-01 used HEAVY PIERCE on %s." % enemy_catalog[heavy.type].name)
			return true
	return false

func available_robot_growths() -> Array[String]:
	var available: Array[String] = []
	var unlocked_abilities: Array = robot_progression.get("unlocked_abilities", [])
	for ability_key in ROBOT_GROWTH_OPTIONS:
		var ability_id := str(ability_key)
		if not unlocked_abilities.has(ability_id): available.append(ability_id)
	return available

func choose_robot_growth(ability_id: String) -> void:
	if run_state != RunState.GROWTH or not available_robot_growths().has(ability_id): return
	robot_progression["unlocked_abilities"].append(ability_id)
	play_sfx("ui_confirm")
	log_event("ATLAS-01 unlocked %s." % ROBOT_GROWTH_OPTIONS[ability_id]["name"])
	run_state = RunState.READY
	start_wave()

func check_wave_clear() -> void:
	if run_state == RunState.DEFEAT or run_state == RunState.VICTORY or not wave_running: return
	if not spawn_queue.is_empty() or enemies.any(func(enemy): return enemy.hp > 0.0): return
	wave_running = false; wave_clear = true
	var waves_count := StageManager.get_waves().size()
	if wave < waves_count:
		log_event("Wave %d clear." % wave); wave += 1
		run_state = RunState.READY
		start_wave()
	else:
		var next_stage_id := str(StageManager.get_current_stage().get("next_stage_id", ""))
		if not next_stage_id.is_empty():
			if not load_stage_map(next_stage_id):
				push_error("Could not load next campaign Stage '%s'." % next_stage_id)
				run_state = RunState.DEFEAT
				log_event("STAGE LOAD FAILED. Press RESTART to retry the campaign.")
				return
			reset_game()
			log_event("STAGE %d READY. Build defenses before Wave 1." % StageManager.get_current_stage().get("order", 1))
		else:
			run_state = RunState.VICTORY
			log_event("CAMPAIGN VICTORY. ALL STAGES CLEAR. Press RESTART to repeat.")

func _camera_target_clamped(target: Vector2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	# Camera bounds use the gameplay-safe area rather than the HUD-covered area.
	var gameplay_viewport_size := Vector2(viewport_size.x, max(1.0, viewport_size.y - BOTTOM_HUD_HEIGHT))
	var half_view := gameplay_viewport_size * 0.5
	var min_x := MAP_ORIGIN.x + half_view.x
	var max_x := MAP_ORIGIN.x + MAP_PIXEL_SIZE.x - half_view.x
	var min_y := MAP_ORIGIN.y + half_view.y
	var max_y := MAP_ORIGIN.y + MAP_PIXEL_SIZE.y - half_view.y
	if min_x > max_x:
		target.x = MAP_ORIGIN.x + MAP_PIXEL_SIZE.x * 0.5
	else:
		target.x = clampf(target.x, min_x, max_x)
	if min_y > max_y:
		target.y = MAP_ORIGIN.y + MAP_PIXEL_SIZE.y * 0.5
	else:
		target.y = clampf(target.y, min_y, max_y)
	return target

func update_camera_edge_scroll(delta: float) -> void:
	if camera_dragging or not has_node("Camera2D"):
		return
	var mouse := get_viewport().get_mouse_position()
	var viewport_size := get_viewport_rect().size
	if get_minimap_screen_rect().has_point(mouse):
		return
	var direction := Vector2.ZERO
	if mouse.x <= CAMERA_EDGE_MARGIN:
		direction.x -= 1.0
	elif mouse.x >= viewport_size.x - CAMERA_EDGE_MARGIN:
		direction.x += 1.0
	if mouse.y <= CAMERA_EDGE_MARGIN:
		direction.y -= 1.0
	elif mouse.y < viewport_size.y - BOTTOM_HUD_HEIGHT and mouse.y >= viewport_size.y - BOTTOM_HUD_HEIGHT - CAMERA_EDGE_MARGIN:
		direction.y += 1.0
	if direction == Vector2.ZERO:
		return
	$Camera2D.position = _camera_target_clamped($Camera2D.position + direction.normalized() * CAMERA_EDGE_SPEED * delta)

func get_minimap_screen_rect() -> Rect2:
	var viewport_size := get_viewport_rect().size
	return Rect2(Vector2(viewport_size.x - 238.0, viewport_size.y - 150.0), Vector2(220, 112))

func center_camera_from_minimap(screen_position: Vector2) -> void:
	var rect := get_minimap_screen_rect()
	if not rect.has_point(screen_position):
		return
	var normalized := Vector2(
		clampf((screen_position.x - rect.position.x) / rect.size.x, 0.0, 1.0),
		clampf((screen_position.y - rect.position.y) / rect.size.y, 0.0, 1.0)
	)
	var target := MAP_ORIGIN + Vector2(normalized.x * MAP_PIXEL_SIZE.x, normalized.y * MAP_PIXEL_SIZE.y)
	$Camera2D.position = _camera_target_clamped(target)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_SPACE:
		try_special_attack()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		camera_dragging = event.pressed
		camera_last_mouse = event.position
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion and camera_dragging:
		$Camera2D.position = _camera_target_clamped($Camera2D.position - event.relative)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_minimap_screen_rect().has_point(event.position):
			center_camera_from_minimap(event.position)
			get_viewport().set_input_as_handled()
			return
		handle_click(get_global_mouse_position())

func handle_click(point: Vector2) -> void:
	if _ui_action_rect(0).has_point(point): select_tower_for_build("cannon"); return
	if _ui_action_rect(1).has_point(point): select_tower_for_build("gatling"); return
	if _ui_action_rect(2).has_point(point): try_special_attack(); return
	for tower in towers:
		if point.distance_to(tower.position) < 24.0:
			selected_tower = tower.id; selected_slot = tower.id; selected_slot_position = tower.position; robot_selected = false; play_sfx("tower_select"); queue_redraw(); return
	if robot.active and point.distance_to(robot.position) < 28.0:
		if robot_selected:
			robot_selected = false; play_sfx("ui_cancel")
		else:
			robot_selected = true; selected_tower = ""; selected_slot = ""; play_sfx("ui_click")
		queue_redraw(); return
	if robot_selected and Rect2(MAP_ORIGIN, MAP_PIXEL_SIZE).has_point(point):
		move_robot_to_position(point); return
	if not robot_selected:
		var tower_position := get_tower_placement_position(point)
		if tower_position != Vector2.INF and not pending_tower_type.is_empty():
			selected_slot_position = tower_position
			selected_slot = "tower_%d_%d" % [int(tower_position.x), int(tower_position.y)]
			selected_tower = ""
			build_tower(pending_tower_type)
			if selected_slot.is_empty():
				pending_tower_type = ""
			queue_redraw()
			return
		if tower_position != Vector2.INF:
			selected_slot_position = tower_position
			selected_slot = "tower_%d_%d" % [int(tower_position.x), int(tower_position.y)]
			selected_tower = ""
			robot_selected = false
			play_sfx("tower_select")
			queue_redraw()
			return
	for id in ROBOT_SPOTS:
		if point.distance_to(ROBOT_SPOTS[id]) < 55.0:
			if robot_selected: move_robot(id)
			return
	if not selected_slot.is_empty() or not selected_tower.is_empty() or robot_selected: play_sfx("ui_cancel")
	selected_slot = ""; selected_slot_position = Vector2.ZERO; selected_tower = ""; robot_selected = false; queue_redraw()

func get_tower_placement_position(point: Vector2) -> Vector2:
	for area in TOWER_PLACEMENT_AREAS:
		if not area.has_point(point):
			continue
		var local := point - MAP_ORIGIN
		var snapped := MAP_ORIGIN + Vector2(floor(local.x / 32.0 + 0.5) * 32.0, floor(local.y / 32.0 + 0.5) * 32.0)
		if area.has_point(snapped):
			return snapped
	return Vector2.INF

func select_tower_for_build(type: String) -> void:
	if run_state not in [RunState.READY, RunState.RUNNING]:
		play_sfx("ui_error")
		return
	if not tower_catalog.has(type):
		play_sfx("ui_error")
		return
	pending_tower_type = type
	selected_slot = ""
	selected_slot_position = Vector2.ZERO
	selected_tower = ""
	robot_selected = false
	play_sfx("tower_select")
	log_event("%s: 설치 위치를 클릭하세요." % str(tower_catalog[type].name))
	queue_redraw()

func build_tower(type: String) -> void:
	if run_state not in [RunState.READY, RunState.RUNNING]: return
	if selected_slot.is_empty(): play_sfx("ui_error"); log_event("Select an empty tower slot first."); return
	if towers.any(func(tower): return tower.id == selected_slot): upgrade_tower(type); return
	if not tower_catalog.has(type): play_sfx("ui_error"); return
	var data: Dictionary = tower_catalog[type]
	if gold < data.cost: play_sfx("ui_error"); log_event("Need %d gold for %s." % [data.cost, data.name]); return
	gold -= data.cost; towers.append({"id": selected_slot, "type": type, "position": selected_slot_position, "data": data, "cooldown": 0.0}); play_sfx("tower_build"); log_event("%s deployed at %s." % [data.name, selected_slot]); selected_slot = ""; selected_slot_position = Vector2.ZERO; selected_tower = ""; robot_selected = false

func upgrade_tower(type: String) -> void:
	if run_state == RunState.RUNNING: play_sfx("ui_error"); log_event("Cannot upgrade towers during a wave."); return
	var index := towers.find_custom(func(tower): return tower.id == selected_slot)
	if index < 0: return
	var tower: Dictionary = towers[index]
	if tower.type != type: play_sfx("ui_error"); log_event("Select the matching tower type to upgrade."); return
	if int(tower.get("level", 1)) >= 2: play_sfx("ui_error"); log_event("Tower is already MAX LVL 2."); return
	var level2: Dictionary = tower.data.get("level2", {})
	var cost := int(level2.get("upgrade_cost", 0))
	if gold < cost: play_sfx("ui_error"); log_event("Not enough gold for LVL 2 upgrade."); return
	gold -= cost
	tower.level = 2
	tower.data = tower.data.duplicate(true)
	tower.data.damage = level2.damage
	tower.data.cooldown = level2.cooldown
	tower.data.range = level2.range
	towers[index] = tower
	play_sfx("ui_confirm"); log_event("%s upgraded to LVL 2." % tower.data.name)
	selected_slot = ""; selected_slot_position = Vector2.ZERO; selected_tower = ""; robot_selected = false; queue_redraw()

func launch_robot() -> void:
	if not can_launch_robot(): return
	robot.hp = DATA.ROBOT.hp
	robot.active = true; robot_selected = true; selected_tower = ""; selected_slot = ""; play_sfx("ui_confirm"); log_event("ATLAS-01 launched at %s. Choose a crisis zone." % robot.spot)

func can_launch_robot() -> bool:
	return not robot.active and run_state in [RunState.READY, RunState.RUNNING]

func move_robot(id: String) -> void:
	if not robot.active or run_state not in [RunState.READY, RunState.RUNNING] or not ROBOT_SPOTS.has(id) or robot.spot == id: return
	robot["manual_position"] = true; robot.spot = id; robot["target_pos"] = ROBOT_SPOTS[id]; log_event("ATLAS-01 moved to %s." % id)

func draw_sprite(texture: Texture2D, center: Vector2, size: Vector2) -> void:
	draw_texture_rect(texture, Rect2(center - size * 0.5, size), false)

func draw_animated_sprite(texture: Texture2D, center: Vector2, size: Vector2, frame: int, total_frames: int) -> void:
	var tex_size := texture.get_size()
	var frame_w := tex_size.x / float(max(1, total_frames))
	var frame_h := tex_size.y
	var src_rect := Rect2((frame % total_frames) * frame_w, 0, frame_w, frame_h)
	var dest_rect := Rect2(center - size * 0.5, size)
	draw_texture_rect_region(texture, dest_rect, src_rect)

func draw_rotated_animated_sprite(texture: Texture2D, center: Vector2, size: Vector2, angle: float, frame: int, total_frames: int) -> void:
	var tex_size := texture.get_size()
	var frame_w := tex_size.x / float(max(1, total_frames))
	var frame_h := tex_size.y
	var src_rect := Rect2((frame % total_frames) * frame_w, 0, frame_w, frame_h)
	draw_set_transform(center, angle, Vector2.ONE)
	var dest_rect := Rect2(-size * 0.5, size)
	draw_texture_rect_region(texture, dest_rect, src_rect)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_oval(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var points := PackedVector2Array()
	var segs := 24
	for i in range(segs):
		var a := (float(i) / float(segs)) * TAU
		points.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polygon(points, PackedColorArray([color]))

func _draw() -> void:
	# Tactical Grid Background & Field Control Sidebar
	# Battle HUD is rendered over the battlefield; it is not a separate sidebar.

	# Tactical Field Boundary
	draw_rect(Rect2(MAP_ORIGIN, MAP_PIXEL_SIZE), Color("7ed6ce"), false, 2)
	# Tower placement areas are always shown as a subtle translucent build zone.
	for area in TOWER_PLACEMENT_AREAS:
		draw_rect(area, Color(0.25, 0.85, 0.72, 0.10), true)
		draw_rect(area, Color(0.45, 0.92, 0.82, 0.32), false, 1.5)
	# Spawn location labels are intentionally hidden.

	# Base Facility (Strategic HQ Node)
	var base_feet := BASE + Vector2(0, 30)
	draw_oval(base_feet, 54.0, 16.0, Color(0, 0, 0, 0.5))
	draw_arc(base_feet, 56, 0, TAU, 32, Color("7ed6ce"), 2.5)
	draw_sprite(VISUALS["facility_base"], BASE, Vector2(112, 92))
	# Base HQ label is intentionally hidden.

	# Placed towers
	if not selected_slot.is_empty() and towers.all(func(tower): return tower.id != selected_slot):
		draw_oval(selected_slot_position + Vector2(0, 26), 30.0, 10.0, Color(0, 0, 0, 0.35))
		draw_arc(selected_slot_position + Vector2(0, 26), 32.0, 0, TAU, 24, Color("f0a35a"), 2.0)
		draw_sprite(VISUALS["slot_selected"], selected_slot_position, Vector2(76, 76))
	for tower in towers:
		var tower_pos: Vector2 = tower.position
		var tower_feet := tower_pos + Vector2(0, 26)
		var anim_key := "tower_cannon_anim" if tower.type == "cannon" else "tower_gatling_anim"
		var cd_left: float = float(tower.get("cooldown", 0.0))
		var max_cd: float = float(tower.get("data", {}).get("cooldown", 0.6))
		var is_firing: bool = cd_left > (max_cd - 0.25)
		var frame_idx := 0
		if is_firing:
			var fire_progress: float = 1.0 - clampf((cd_left - (max_cd - 0.25)) / 0.25, 0.0, 1.0)
			frame_idx = int(fire_progress * 4.0) % 4
		draw_oval(tower_feet, 28.0, 10.0, Color(0, 0, 0, 0.45))
		draw_arc(tower_feet, 30.0, 0, TAU, 24, Color("7ed6ce" if tower.type == "cannon" else "f0a35a"), 2.5)
		draw_animated_sprite(tower_sprite_catalog.get(tower.type, VISUALS[anim_key]), tower_pos, Vector2(64, 96), frame_idx, 4)
		if selected_tower == tower.id: draw_arc(tower_feet, 38.0, 0, TAU, 24, Color("d7fff7"), 2.0)

	# Enemy Units (High Contrast Strategic Visibility)
	for enemy in enemies:
		if enemy.hp <= 0.0: continue
		var data: Dictionary = enemy_catalog[enemy.type]
		var enemy_size: Vector2 = ENEMY_SPRITE_SIZES[enemy.type] * 1.08
		
		# Presentation-only scale increase keeps battlefield combat as the primary visual focus.
		# Enemy data, collision, targeting and movement are unchanged.
		# Strategic Base Indicator at Enemy Feet (drawn BEFORE sprite so feet sit inside base ring)
		var feet_pos := enemy.position + Vector2(0, enemy_size.y * 0.48)
		var enemy_accent := Color("ef7068")
		if enemy.type == "rusher":
			enemy_accent = Color("f0a35a")
		elif enemy.type == "heavy":
			enemy_accent = Color("c58cff")
		elif enemy.type == "giant":
			enemy_accent = Color("f0d28a")
		var ring_radius: float = enemy_size.x * 0.55
		draw_oval(feet_pos, ring_radius, 9.0, Color(0, 0, 0, 0.5))
		draw_arc(feet_pos, ring_radius, 0, TAU, 20, Color(enemy_accent, 0.9), 2.5)
		if enemy.type == "giant":
			var giant_pulse := 1.0 + sin(elapsed * 3.0) * 0.04
			draw_arc(feet_pos, ring_radius * 1.16 * giant_pulse, 0, TAU, 24, Color(enemy_accent, 0.35), 1.5)
		
		if enemy.flash > 0.0:
			draw_circle(enemy.position, max(enemy_size.x, enemy_size.y) * 0.28, Color.WHITE, false, 3.0)
		var anim_key: String = "enemy_" + enemy.type + "_anim"
		var fps: float = 14.0 if enemy.type == "rusher" else (6.0 if enemy.type == "giant" else 10.0)
		var e_frame: int = int((elapsed + float(enemy.position.x)) * fps) % 8
		draw_animated_sprite(enemy_sprite_catalog.get(enemy.type, VISUALS[anim_key]), enemy.position, enemy_size, e_frame, 8)
		
		# Strategic HP Bar
		var hp_position := enemy.position + Vector2(-enemy_size.x * 0.5, -enemy_size.y * 0.5 - 11)
		var hp_width: float = max(34.0, enemy_size.x)
		hp_position.x = enemy.position.x - hp_width * 0.5
		draw_string(ThemeDB.fallback_font, hp_position + Vector2(0, -6), data.name, HORIZONTAL_ALIGNMENT_LEFT, hp_width, 10, Color("ffd6d1"))
		draw_rect(Rect2(hp_position - Vector2(1, 1), Vector2(hp_width + 2, 7)), Color("101f25"))
		draw_rect(Rect2(hp_position, Vector2(hp_width, 5)), Color("3a1c1a"))
		draw_rect(Rect2(hp_position, Vector2(hp_width * max(0.0, enemy.hp / enemy.max_hp), 5)), enemy_accent)

	# Effects
	for effect in effects:
		var etype: String = str(effect.get("type", ""))
		if etype == "giantHit":
			draw_arc(effect.get("position", Vector2.ZERO), 35.0, 0, TAU, 16, Color("ef7068"), 3.0)
		elif etype == "impact_explosion" or etype in ["cannon", "gatling", "robot", "area", "pierce"]:
			var life_progress: float = 1.0 - clampf(float(effect.get("life", 0.0)) / max(0.01, float(effect.get("max_life", 0.35))), 0.0, 1.0)
			var impact_position: Vector2 = effect.get("position", Vector2.ZERO)
			var impact_color := Color("7ed6ce")
			if etype == "area":
				impact_color = Color("f0d28a")
			elif etype == "pierce":
				impact_color = Color("c58cff")
			elif str(effect.get("source", "")) == "cannon":
				impact_color = Color("f0d28a")
			elif str(effect.get("source", "")) == "gatling":
				impact_color = Color("f0a35a")
			var impact_scale := 1.0 + life_progress * 0.35
			draw_arc(impact_position, 24.0 * impact_scale, 0, TAU, 20, Color(impact_color, 0.7 * (1.0 - life_progress)), 2.5)
			var frame_idx: int = int(life_progress * 8.0) % 8
			draw_animated_sprite(VISUALS["impact_explosion"], impact_position, Vector2(54, 54) * impact_scale, frame_idx, 8)
		elif etype == "proj_defender":
			var progress: float = clampf(float(effect.get("progress", 0.0)), 0.0, 1.0)
			var start_p: Vector2 = effect.get("start", Vector2.ZERO)
			var end_p: Vector2 = effect.get("target", Vector2.ZERO)
			var current_p: Vector2 = start_p.lerp(end_p, progress)
			var angle: float = start_p.angle_to_point(end_p) + PI / 2.0
			var p_frame: int = int(elapsed * 18.0) % 8
			var weapon_type := str(effect.get("weapon", "robot"))
			var projectile_color := Color("7ed6ce")
			if weapon_type == "cannon":
				projectile_color = Color("f0d28a")
			elif weapon_type == "gatling":
				projectile_color = Color("f0a35a")
			var trail_start := current_p - Vector2.from_angle(angle - PI / 2.0) * 22.0
			draw_line(trail_start, current_p, Color(projectile_color, 0.55), 3.0)
			draw_circle(current_p, 5.0, Color(projectile_color, 0.85))
			draw_rotated_animated_sprite(VISUALS["bullet_defender"], current_p, Vector2(36, 44), angle, p_frame, 8)
		elif etype == "proj_threat":
			var progress: float = clampf(float(effect.get("progress", 0.0)), 0.0, 1.0)
			var start_p: Vector2 = effect.get("start", Vector2.ZERO)
			var end_p: Vector2 = effect.get("target", Vector2.ZERO)
			var current_p: Vector2 = start_p.lerp(end_p, progress)
			var angle: float = start_p.angle_to_point(end_p) + PI / 2.0
			var p_frame: int = int(elapsed * 16.0) % 6
			draw_rotated_animated_sprite(VISUALS["bullet_threat"], current_p, Vector2(40, 48), angle, p_frame, 6)

	# Player Unit ATLAS-01 Robot (Heroic Strategic Unit Base & Visibility)
	if robot.active:
		var is_flashing: bool = float(robot.get("flash", 0.0)) > 0.0
		
		# Strategic Base Indicator at Player Robot Feet (positioned at y=+52 at feet)
		var r_feet_pos: Vector2 = robot.position + Vector2(0, 60)
		draw_oval(r_feet_pos, 42.0, 12.0, Color(0, 0, 0, 0.5))
		draw_arc(r_feet_pos, 42.0, 0, TAU, 24, Color("ef7068") if is_flashing else Color("7ed6ce"), 2.5)
		if robot_selected:
			var select_pulse := 1.0 + sin(elapsed * 5.0) * 0.06
			draw_arc(r_feet_pos, 52.0 * select_pulse, 0, TAU, 32, Color("f0a35a", 0.9), 2.5)
			draw_arc(r_feet_pos, 58.0 * select_pulse, -0.7, 0.7, 16, Color("f0a35a", 0.45), 1.5)
			draw_arc(r_feet_pos, 58.0 * select_pulse, PI - 0.7, PI + 0.7, 16, Color("f0a35a", 0.45), 1.5)
		
		if is_flashing: draw_circle(robot.position, 42, Color("ef7068", 0.30))
		var anim_key := "atlas_idle"
		var total_f := 6
		var fps := 8.0
		if float(robot.get("special", 0.0)) > 0.0:
			anim_key = "atlas_skill"
			total_f = 5
			fps = 10.0
		elif float(robot.get("attack", 0.0)) > 0.3:
			anim_key = "atlas_attack"
			total_f = 7
			fps = 14.0
		elif float(robot.get("area", 0.0)) > 5.0 or float(robot.get("pierce", 0.0)) > 6.0:
			anim_key = "atlas_skill"
			total_f = 5
			fps = 10.0
		elif bool(robot.get("is_moving", false)):
			anim_key = "atlas_move"
			total_f = 5
			fps = 12.0
		var r_frame: int = int(elapsed * fps) % total_f
		if float(robot.get("special", 0.0)) > 0.0:
			draw_arc(r_feet_pos, 47.0, elapsed * 2.5, elapsed * 2.5 + PI * 1.35, 24, Color("f0d28a", 0.85), 3.0)
		elif float(robot.get("attack", 0.0)) > 0.3:
			draw_arc(r_feet_pos, 46.0, elapsed * 4.0, elapsed * 4.0 + PI, 20, Color("7ed6ce", 0.9), 2.5)
		draw_animated_sprite(VISUALS[anim_key], robot.position, Vector2(78, 132), r_frame, total_f)
		
		# Player Robot Unit HP Bar
		var r_hp_pos: Vector2 = robot.position + Vector2(-39, -76)
		draw_rect(Rect2(r_hp_pos - Vector2(1, 1), Vector2(80, 6)), Color("101f25"))
		draw_rect(Rect2(r_hp_pos, Vector2(78, 4)), Color("1c3e38"))
		draw_rect(Rect2(r_hp_pos, Vector2(78 * max(0.0, robot.hp / DATA.ROBOT.hp), 4)), Color("7ed6ce"))

	for damage_number in damage_numbers:
		var life := float(damage_number.get("life", 0.0))
		var alpha := clampf(life / 0.7, 0.0, 1.0)
		draw_string(ThemeDB.fallback_font, damage_number.get("position", Vector2.ZERO), str(damage_number.get("value", 0)), HORIZONTAL_ALIGNMENT_CENTER, 50, 16, Color(1, 0.85, 0.35, alpha))
	draw_ui2()

func _ui_origin() -> Vector2:
	return $Camera2D.position - get_viewport_rect().size * 0.5 + Vector2(0, get_viewport_rect().size.y - BOTTOM_HUD_HEIGHT)

func _ui_action_rect(index: int) -> Rect2:
	return Rect2(_ui_origin() + Vector2(350.0 + index * 82.0, 82.0), Vector2(74, 74))

func _ui_button_rect(y: float) -> Rect2:
	return Rect2(_ui_origin() + Vector2(20, y), Vector2(154, 46))

func draw_ui() -> void:
	var origin := _ui_origin()
	var stage_data := StageManager.get_current_stage()
	var waves_data := StageManager.get_waves()
	draw_string(ThemeDB.fallback_font, origin + Vector2(20, 64), "기지 HP %03d   골드 %03d" % [max(0, ceil(base_hp)), gold], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("d7fff7"))
	draw_string(ThemeDB.fallback_font, origin + Vector2(20, 88), "스테이지 %d   웨이브 %d / %d" % [int(stage_data.get("order", 1)), wave, waves_data.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("a9c5c7"))
	var status_text := "대기"
	if run_state == RunState.RUNNING: status_text = "웨이브 진행 중"
	elif run_state == RunState.GROWTH: status_text = "로봇 능력 선택"
	elif run_state == RunState.VICTORY: status_text = "승리"
	elif run_state == RunState.DEFEAT: status_text = "패배"
	draw_string(ThemeDB.fallback_font, origin + Vector2(20, 112), "상태: " + status_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("7ed6ce"))
	button(_ui_button_rect(135), "웨이브 시작", run_state != RunState.READY)
	button(_ui_button_rect(183), "전투 재시작", false)

	button(_ui_button_rect(279), "캐논 건설", run_state not in [RunState.READY, RunState.RUNNING])
	button(_ui_button_rect(327), "개틀링 건설", run_state not in [RunState.READY, RunState.RUNNING])
	var special_ready: bool = robot.active and run_state == RunState.RUNNING and float(robot.get("special", 0.0)) <= 0.0 and not robot_progression.get("unlocked_abilities", []).is_empty()
	button(_ui_button_rect(375), "필살기 [SPACE]", not special_ready)
	var robot_status := "대기"
	if robot.active: robot_status = "출격 / " + robot.spot
	draw_string(ThemeDB.fallback_font, origin + Vector2(20, 452), "ATLAS-01  " + robot_status, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("7ed6ce"))
	draw_string(ThemeDB.fallback_font, origin + Vector2(20, 474), "HP %03d" % max(0, ceil(robot.hp)), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("a9c5c7"))
	for index in range(mini(feed.size(), 5)):
		draw_string(ThemeDB.fallback_font, origin + Vector2(20, 500 + index * 18), feed[index], HORIZONTAL_ALIGNMENT_LEFT, 320, 10, Color("a9c5c7"))
	draw_minimap(origin + Vector2(185, 520))
	if run_state == RunState.GROWTH: draw_robot_growth_choice()

func draw_minimap(position: Vector2) -> void:
	var rect := Rect2(position, Vector2(155, 90))
	var sx: float = rect.size.x / max(1.0, MAP_PIXEL_SIZE.x)
	var sy: float = rect.size.y / max(1.0, MAP_PIXEL_SIZE.y)
	draw_rect(rect, Color(0.02, 0.07, 0.08, 0.94), true)
	draw_rect(rect, Color("527079"), false, 1)
	for enemy in enemies:
		if enemy.hp <= 0.0: continue
		var local: Vector2 = enemy.position - MAP_ORIGIN
		draw_circle(rect.position + Vector2(local.x * sx, local.y * sy), 2.5 if enemy.type != "giant" else 4.0, Color("ef7068"))
	if robot.active:
		var local_robot: Vector2 = robot.position - MAP_ORIGIN
		draw_circle(rect.position + Vector2(local_robot.x * sx, local_robot.y * sy), 3.0, Color("7ed6ce"))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(6, 14), "적 접근", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("d7fff7"))

func draw_ui2() -> void:
	var viewport_size := get_viewport_rect().size
	var screen_origin := $Camera2D.position - viewport_size * 0.5
	var bottom := _ui_origin()
	var stage_data := StageManager.get_current_stage()
	var waves_data := StageManager.get_waves()

	# Top-center combat bar: compact, readable, MOBA-style information hierarchy.
	var top_rect := Rect2(screen_origin + Vector2(0, 10), Vector2(viewport_size.x, 58))
	draw_rect(top_rect, Color(0.025, 0.045, 0.055, 0.94), true)
	draw_line(top_rect.position + Vector2(0, top_rect.size.y), top_rect.position + Vector2(top_rect.size.x, top_rect.size.y), Color("527079"), 2.0)
	draw_string(ThemeDB.fallback_font, top_rect.position + Vector2(22, 25), "BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("829aa0"))
	draw_string(ThemeDB.fallback_font, top_rect.position + Vector2(22, 46), "%03d" % max(0, ceil(base_hp)), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("7ed6ce"))
	draw_string(ThemeDB.fallback_font, top_rect.position + Vector2(112, 25), "GOLD", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("829aa0"))
	draw_string(ThemeDB.fallback_font, top_rect.position + Vector2(112, 46), "%03d" % gold, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f0d28a"))
	var status_text := "READY"
	if run_state == RunState.RUNNING: status_text = "WAVE IN PROGRESS"
	elif run_state == RunState.VICTORY: status_text = "VICTORY"
	elif run_state == RunState.DEFEAT: status_text = "DEFEAT"
	draw_string(ThemeDB.fallback_font, top_rect.position + Vector2(viewport_size.x * 0.5 - 95, 23), "STAGE %d" % int(stage_data.get("order", 1)), HORIZONTAL_ALIGNMENT_CENTER, 190, 11, Color("a9c5c7"))
	draw_string(ThemeDB.fallback_font, top_rect.position + Vector2(viewport_size.x * 0.5 - 110, 45), "WAVE %d / %d   •   %s" % [wave, waves_data.size(), status_text], HORIZONTAL_ALIGNMENT_CENTER, 220, 13, Color("d7fff7"))

	# Bottom HUD: Atlas portrait/readout, build palette, combat log and minimap.
	var hud_rect := Rect2(bottom, Vector2(viewport_size.x, BOTTOM_HUD_HEIGHT))
	draw_rect(hud_rect, Color(0.025, 0.045, 0.055, 0.97), true)
	draw_line(bottom, bottom + Vector2(viewport_size.x, 0), Color("527079"), 2.0)

	var portrait_panel := Rect2(bottom + Vector2(14, 12), Vector2(300, 164))
	draw_rect(portrait_panel, Color(0.045, 0.08, 0.09, 0.98), true)
	draw_rect(portrait_panel, Color("527079"), false, 1.0)
	var portrait_rect := Rect2(portrait_panel.position + Vector2(10, 10), Vector2(112, 112))
	draw_rect(portrait_rect, Color("0b171b"), true)
	if VISUALS.get("robot") != null:
		draw_sprite(VISUALS["robot"], portrait_rect.position + portrait_rect.size * 0.5, Vector2(94, 94))
	draw_string(ThemeDB.fallback_font, portrait_panel.position + Vector2(132, 29), "ATLAS-01", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d7fff7"))
	var robot_status := "STANDBY"
	if robot.active: robot_status = "ACTIVE / " + robot.spot
	draw_string(ThemeDB.fallback_font, portrait_panel.position + Vector2(132, 49), robot_status, HORIZONTAL_ALIGNMENT_LEFT, 150, 9, Color("7ed6ce"))
	draw_string(ThemeDB.fallback_font, portrait_panel.position + Vector2(132, 78), "HP", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("829aa0"))
	draw_rect(Rect2(portrait_panel.position + Vector2(132, 86), Vector2(150, 8)), Color("172a2d"), true)
	draw_rect(Rect2(portrait_panel.position + Vector2(132, 86), Vector2(150 * max(0.0, robot.hp / DATA.ROBOT.hp), 8)), Color("7ed6ce"), true)
	draw_string(ThemeDB.fallback_font, portrait_panel.position + Vector2(132, 112), "%03d / %03d" % [max(0, ceil(robot.hp)), DATA.ROBOT.hp], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("a9c5c7"))
	draw_string(ThemeDB.fallback_font, portrait_panel.position + Vector2(14, 140), "COMMANDS  %02d" % int(robot.get("commands", 0)), HORIZONTAL_ALIGNMENT_LEFT, 130, 10, Color("829aa0"))
	draw_string(ThemeDB.fallback_font, portrait_panel.position + Vector2(160, 140), "SPACE  SPECIAL", HORIZONTAL_ALIGNMENT_LEFT, 130, 10, Color("829aa0"))

	# Build / skill palette.
	for index in range(3):
		var rect := _ui_action_rect(index)
		var disabled := false
		var label := ""
		var sub := ""
		if index == 0:
			label = "CANNON"; sub = "BUILD"
		elif index == 1:
			label = "GATLING"; sub = "BUILD"
		else:
			label = "SPECIAL"; sub = "SPACE"
			var special_ready := robot.active and run_state == RunState.RUNNING and float(robot.get("special", 0.0)) <= 0.0
			disabled = not special_ready
		draw_rect(rect, Color("173337") if not disabled else Color("182226"), true)
		var selected := (index == 0 and selected_tower == "cannon") or (index == 1 and selected_tower == "gatling")
		draw_rect(rect, Color("7ed6ce") if selected else Color("527079"), false, 2.0)
		if index < 2:
			var texture_key := "tower_cannon" if index == 0 else "tower_gatling"
			if VISUALS.get(texture_key) != null:
				draw_sprite(VISUALS[texture_key], rect.position + Vector2(37, 31), Vector2(42, 42))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(6, 56), label, HORIZONTAL_ALIGNMENT_CENTER, 62, 9, Color("d7fff7") if not disabled else Color("65777b"))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(6, 68), sub, HORIZONTAL_ALIGNMENT_CENTER, 62, 8, Color("7ed6ce") if not disabled else Color("65777b"))

	# Recent combat feed.
	var feed_rect := Rect2(bottom + Vector2(606, 12), Vector2(230, 164))
	draw_rect(feed_rect, Color(0.035, 0.065, 0.07, 0.98), true)
	draw_rect(feed_rect, Color("30484f"), false, 1.0)
	draw_string(ThemeDB.fallback_font, feed_rect.position + Vector2(12, 20), "COMBAT LOG", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("829aa0"))
	for index in range(min(feed.size(), 7)):
		draw_string(ThemeDB.fallback_font, feed_rect.position + Vector2(12, 42 + index * 17), feed[index], HORIZONTAL_ALIGNMENT_LEFT, 205, 9, Color("a9c5c7"))

	draw_minimap2(bottom + Vector2(viewport_size.x - 238, 38))

func draw_minimap2(position: Vector2) -> void:
	var rect := Rect2(position, Vector2(220, 112))
	var sx: float = rect.size.x / max(1.0, MAP_PIXEL_SIZE.x)
	var sy: float = rect.size.y / max(1.0, MAP_PIXEL_SIZE.y)
	draw_rect(rect, Color(0.02, 0.07, 0.08, 0.96), true)
	draw_rect(rect, Color("527079"), false, 1)
	var base_local := BASE - MAP_ORIGIN
	draw_circle(rect.position + Vector2(base_local.x * sx, base_local.y * sy), 5.0, Color("7ed6ce"))
	for enemy in enemies:
		if enemy.hp <= 0.0: continue
		var local: Vector2 = enemy.position - MAP_ORIGIN
		draw_circle(rect.position + Vector2(local.x * sx, local.y * sy), 3.0 if enemy.type != "giant" else 5.0, Color("ef7068"))
	var local_robot: Vector2 = robot.position - MAP_ORIGIN
	draw_circle(rect.position + Vector2(local_robot.x * sx, local_robot.y * sy), 4.0, Color("f0d28a"))
	var viewport_size: Vector2 = get_viewport_rect().size
	var view_world_size: Vector2 = viewport_size
	var view_top_left: Vector2 = $Camera2D.position - view_world_size * 0.5 - MAP_ORIGIN
	var view_rect: Rect2 = Rect2(
		rect.position + Vector2(view_top_left.x * sx, view_top_left.y * sy),
		Vector2(view_world_size.x * sx, view_world_size.y * sy)
	)
	var map_bounds := Rect2(rect.position, rect.size)
	view_rect = view_rect.intersection(map_bounds)
	if not view_rect.size.is_zero_approx():
		draw_rect(view_rect, Color("f0d28a"), false, 2.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(6, 14), SettingsManager.text("기지 / ATLAS / 적", "BASE / ATLAS / ENEMIES"), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("d7fff7"))

func draw_robot_growth_choice() -> void:
	var rect := Rect2(_ui_origin() + Vector2(385, 180), Vector2(500, 185))
	draw_rect(rect, Color("101f25"), true)
	draw_rect(rect, Color("7ed6ce"), false, 2)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(20, 35), "웨이브 클리어 / 로봇 능력 선택", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d7fff7"))
	for ability_id in available_robot_growths():
		var option: Dictionary = ROBOT_GROWTH_OPTIONS[ability_id]
		var option_rect := Rect2(rect.position + Vector2(20 + available_robot_growths().find(ability_id) * 240, 55), Vector2(220, 78))
		button(option_rect, "해금 " + option["name"], false)
		draw_string(ThemeDB.fallback_font, option_rect.position + Vector2(8, 55), option["description"], HORIZONTAL_ALIGNMENT_LEFT, 205, 10, Color("a9c5c7"))

func button(rect: Rect2, label: String, disabled: bool) -> void:
	draw_rect(rect, Color("263c43") if disabled else Color("1d4a4e"), true)
	draw_rect(rect, Color("527079"), false, 1)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, 26), label, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 20, 11, Color("6a858a") if disabled else Color("d7fff7"))