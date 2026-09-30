extends Node2D

var _catalog_tile_cache: Dictionary = {}


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
var MAP_TILES := Vector2i(36, 24)
var MAP_ORIGIN := Vector2(0, 58)
var MAP_PIXEL_SIZE := Vector2(1152, 768)
const SIDEBAR_X := 20.0
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

var base_hp := 0.0
var gold := 0
var wave := 1
var run_state := RunState.READY
var wave_running := false
var wave_clear := false
var wave_auto_start_timer := 0.0
var wave_auto_start_delay := 0.0
var elapsed := 0.0
var spawn_clock := 0.0
var spawn_queue: Array = []
var enemies: Array = []
var enemy_catalog: Dictionary = {}
var enemy_definitions: Dictionary = {}
var enemy_weapon_definitions: Dictionary = {}
var enemy_robot_weapon_definitions: Dictionary = {}
var enemy_sprite_catalog: Dictionary = {}
var enemy_projectile_catalog: Dictionary = {}
var tower_catalog: Dictionary = {}
var tower_definitions: Dictionary = {}
var tower_sprite_catalog: Dictionary = {}
var tower_projectile_catalog: Dictionary = {}
var robot_catalog: Dictionary = {}
var robot_definition: RobotDefinition
var robot_weapon_definition: WeaponDefinition
var robot_sprite_catalog: Dictionary = {}
var robot_projectile_catalog: Dictionary = {}
var towers: Array = []
var robot: RobotRuntimeState
var player_profile: PlayerProfileState = PlayerProfileState.new()
var robot_progression: RobotProgressionState = player_profile.robot_progression
var inventory_open := false
const INVENTORY_COLS := 6
const INVENTORY_ROWS := 4
const ROBOT_PROFILE_PATH := "user://menos_campaign_robot_profile.json"
const ITEM_CATALOG_PATH := "res://content/items/items.json"
var skills_catalog: Dictionary = {}
var gameplay_settings: Dictionary = {}
var robot_progression_definition: Dictionary = {}
var robot_energy_definition: Dictionary = {}
var finisher_definition: Dictionary = {}
var feed: Array[String] = []
var selected_slot := ""
var selected_slot_position := Vector2.ZERO
var selected_tower := ""
var pending_tower_type := ""
var robot_selected := false
var selected_enemy_index := -1
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
	_load_robot_catalog()
	_load_combat_definitions()
	_load_robot_progression()
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
	var camera: Camera2D = get_parent().get_node("Camera2D")
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
	enemy_catalog = ContentCatalogLoader.load_dictionary_catalog("res://content/enemies/enemies.json")
	enemy_definitions.clear()
	for enemy_id in enemy_catalog.keys():
		enemy_definitions[enemy_id] = EnemyDefinition.from_catalog(str(enemy_id), enemy_catalog[enemy_id])
		enemy_weapon_definitions[enemy_id] = WeaponDefinition.from_actor("enemy", str(enemy_id), enemy_catalog[enemy_id])
		enemy_robot_weapon_definitions[enemy_id] = WeaponDefinition.from_enemy_robot_attack(str(enemy_id), enemy_catalog[enemy_id])
	if enemy_catalog.is_empty():
		return
	enemy_sprite_catalog.clear()
	enemy_projectile_catalog.clear()
	for enemy_type in enemy_catalog:
		var sprite: Texture2D = _texture_from_catalog_entry(enemy_catalog[enemy_type], "sprite_anim")
		if sprite:
			enemy_sprite_catalog[enemy_type] = sprite
		else:
			enemy_sprite_catalog[enemy_type] = VISUALS.get("enemy_%s_anim" % enemy_type)
		var projectile: Texture2D = _texture_from_catalog_entry(enemy_catalog[enemy_type], "projectile_anim")
		enemy_projectile_catalog[enemy_type] = projectile if projectile else VISUALS["bullet_threat"]

func _load_robot_catalog() -> void:
	robot_catalog = ContentCatalogLoader.load_single_entry("res://content/robots/robots.json", "robot_main")
	if robot_catalog.is_empty():
		return
	robot_sprite_catalog = {
		"idle": _texture_from_catalog_entry(robot_catalog, "sprite_idle"),
		"attack": _texture_from_catalog_entry(robot_catalog, "sprite_attack"),
		"move": _texture_from_catalog_entry(robot_catalog, "sprite_move"),
		"skill": _texture_from_catalog_entry(robot_catalog, "sprite_skill")
	}
	robot_definition = RobotDefinition.from_catalog(robot_catalog)
	robot_weapon_definition = WeaponDefinition.from_actor("robot", "basic", robot_catalog)
	robot_projectile_catalog["robot"] = _texture_from_catalog_entry(robot_catalog, "projectile_anim")

func _load_combat_definitions() -> void:
	gameplay_settings = GameSettingsLoader.load_gameplay()
	skills_catalog = SkillDefinitionLoader.load_catalog()
	robot_progression_definition = robot_definition.progression.duplicate(true)
	robot_energy_definition = robot_definition.energy.duplicate(true)
	finisher_definition = skills_catalog.get("finisher", {}).duplicate(true)
	if gameplay_settings.is_empty() or skills_catalog.is_empty() or robot_progression_definition.is_empty() or robot_energy_definition.is_empty() or finisher_definition.is_empty():
		push_error("Combat definitions are incomplete; runtime configuration cannot start.")
		return
	wave_auto_start_delay = float(gameplay_settings.get("wave_auto_start", {}).get("delay", 0.0))

func _load_tower_catalog() -> void:
	tower_catalog = ContentCatalogLoader.load_dictionary_catalog("res://content/towers/towers.json")
	tower_definitions.clear()
	for tower_id in tower_catalog:
		tower_definitions[tower_id] = TowerDefinition.from_catalog(str(tower_id), tower_catalog[tower_id])
	tower_sprite_catalog.clear()
	tower_projectile_catalog.clear()
	for tower_type in tower_catalog:
		var sprite: Texture2D = _texture_from_catalog_entry(tower_catalog[tower_type], "sprite_anim")
		if sprite:
			tower_sprite_catalog[tower_type] = sprite
		else:
			tower_sprite_catalog[tower_type] = VISUALS.get("tower_%s_anim" % tower_type)
		var projectile: Texture2D = _texture_from_catalog_entry(tower_catalog[tower_type], "projectile_anim")
		tower_projectile_catalog[tower_type] = projectile if projectile else VISUALS["bullet_defender"]

func load_stage_map(stage_id: String) -> bool:
	if StageManager.load_stage(stage_id).is_empty():
		return false
	var loaded_map := MapLoader.load_map_data(StageManager.get_map_file())
	if loaded_map.is_empty():
		return false
	apply_map_spatial_data(loaded_map)
	if get_parent().has_node("Camera2D"):
		_setup_camera()
	if not build_map_from_data(loaded_map):
		build_first_battle_map()
	return true

func restart_run() -> void:
	var mode := StageManager.run_mode
	var stage_id := StageManager.selected_stage_id if mode == "single" else "stage_01"
	StageManager.begin_run(mode, stage_id)
	if not load_stage_map(stage_id):
		push_error("Could not reload stage '%s'." % stage_id)
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

	var ground: TileMapLayer = get_parent().get_node("Ground")
	var vegetation: TileMapLayer = get_parent().get_node("Vegetation")
	var road: TileMapLayer = get_parent().get_node("Road")
	var road_composition: TileMapLayer = get_parent().get_node("RoadComposition")
	var boundary: TileMapLayer = get_parent().get_node("Boundary")

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
	var ground: TileMapLayer = get_parent().get_node("Ground")
	var vegetation: TileMapLayer = get_parent().get_node("Vegetation")
	var road: TileMapLayer = get_parent().get_node("Road")
	var road_composition: TileMapLayer = get_parent().get_node("RoadComposition")
	var boundary: TileMapLayer = get_parent().get_node("Boundary")
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
	wave_auto_start_timer = wave_auto_start_delay
	var initial_robot_spot := ""
	var initial_robot_position := BASE
	if not ROBOT_SPOTS.is_empty():
		initial_robot_spot = str(ROBOT_SPOTS.keys()[0])
		initial_robot_position = ROBOT_SPOTS[initial_robot_spot]
	var robot_stats := get_robot_runtime_stats()
	robot = RobotRuntimeState.new()
	robot.reset(initial_robot_position, robot_stats.hp, float(robot_energy_definition.get("max", 0.0)), robot_stats.max_moves)
	robot.spot = initial_robot_spot
	if robot_progression == null:
		robot_progression = RobotProgressionState.new()
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
		move_robot_automatically(delta)
		update_robot(delta)
		check_wave_clear()
	for damage_number in damage_numbers:
		damage_number["life"] = float(damage_number.get("life", 0.0)) - delta
		damage_number["position"] = damage_number.get("position", Vector2.ZERO) + Vector2(0, -18.0 * delta)
	damage_numbers = damage_numbers.filter(func(item): return float(item.get("life", 0.0)) > 0.0)
	if robot.state_get("active", false):
		robot["flash"] = max(0.0, float(robot.state_get("flash", 0.0)) - delta)
	for effect in effects:
		if effect.has("progress"):
			effect["progress"] = float(effect["progress"]) + delta * float(effect.get("speed", 4.0))
			if float(effect["progress"]) >= 1.0 and effect.get("source", "") in ["robot", "tower"] and not effect.get("hit_applied", false):
				effect["hit_applied"] = true
				var hit_event := GameplayEvent.create("damage_requested", str(effect.get("source", "robot")), str(effect.get("weapon", "robot")))
				hit_event.target = effect.get("target_enemy", null)
				hit_event.position = effect.get("target", Vector2.ZERO)
				hit_event.damage = float(effect.get("damage", 0.0))
				hit_event.payload = {"source": str(effect.get("source", ""))}
				_handle_gameplay_event(hit_event)
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
		robot.hp = get_robot_runtime_stats().hp
		robot.max_hp = get_robot_runtime_stats().hp
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
		var definition: EnemyDefinition = enemy_definitions[entry.type]
		var spawn_position: Vector2 = LANES[lane]
		if SPAWN_AREAS.has(lane):
			var spawn_rect: Rect2 = SPAWN_AREAS[lane]
			var segment_count := 4
			var segment_index := int(SPAWN_AREA_SEQUENCE.get(lane, 0)) % segment_count
			SPAWN_AREA_SEQUENCE[lane] = int(SPAWN_AREA_SEQUENCE.get(lane, 0)) + 1
			var segment_width := spawn_rect.size.x / float(segment_count)
			var segment_rect := Rect2(spawn_rect.position + Vector2(segment_width * segment_index, 0.0), Vector2(segment_width, spawn_rect.size.y))
			spawn_position = Vector2(randf_range(segment_rect.position.x, segment_rect.end.x), randf_range(segment_rect.position.y, segment_rect.end.y))
		enemies.append(EnemyRuntimeState.create(entry.type, lane, spawn_position, float(definition.get_combat_value("hp", 0.0))))

func damage_robot(amount: float) -> void:
	if not robot.active: return
	robot.hp = max(0.0, robot.hp - amount)
	robot["flash"] = 0.12
	effects.append({"position": robot.position, "type": "giantHit", "life": 0.28})
	if robot.hp <= 0.0:
		robot.hp = 0.0; robot.active = false; robot_selected = false; log_event("ATLAS-01 destroyed. Base defense remains active.")

func update_giant_robot_attack(delta: float, enemy: EnemyRuntimeState) -> void:
	if enemy.type != "giant" or not robot.active or robot.hp <= 0.0: return
	enemy.robot_attack_timer -= delta
	var weapon: WeaponDefinition = enemy_robot_weapon_definitions.get(enemy.type)
	if weapon == null or enemy.position.distance_to(robot.position) > weapon.range: return
	if enemy.robot_attack_timer > 0.0: return
	effects.append({"type": "proj_threat", "start": enemy.position, "target": robot.position, "progress": 0.0, "speed": 4.0, "enemy_type": enemy.type})
	damage_robot(weapon.damage)
	enemy.robot_attack_timer = weapon.cooldown
	if robot.active:
		log_event("GIANT hit ATLAS-01 for %d damage." % int(weapon.damage))

func update_enemy_attack(delta: float, enemy: EnemyRuntimeState, data: Dictionary) -> bool:
	if enemy.type == "giant" or not robot.active or robot.hp <= 0.0:
		return false
	var weapon: WeaponDefinition = enemy_weapon_definitions.get(enemy.type)
	if weapon == null:
		return false
	var attack_type := weapon.attack_type
	if attack_type.is_empty() and bool(data.get("melee", false)):
		attack_type = "melee"
	if attack_type == "none" or attack_type.is_empty():
		return false
	var attack_range := weapon.range
	if attack_range <= 0.0 or enemy.position.distance_to(robot.position) > attack_range:
		return false
	enemy.attack_timer = max(0.0, float(enemy.state_get("attack_timer", 0.0)) - delta)
	if enemy.attack_timer > 0.0:
		return true
	var damage := weapon.damage
	if attack_type == "ranged":
		effects.append({"type": "proj_threat", "start": enemy.position, "target": robot.position, "progress": 0.0, "speed": 4.0, "enemy_type": enemy.type})
	damage_robot(damage)
	enemy.attack_timer = max(0.05, weapon.cooldown)
	log_event("%s hit ATLAS-01 for %d damage." % [data.name, int(damage)])
	return true

func update_melee_enemy_attack(delta: float, enemy: EnemyRuntimeState, data: Dictionary) -> bool:
	return update_enemy_attack(delta, enemy, data)

func move_enemies(delta: float) -> void:
	for enemy in enemies:
		if enemy.hp <= 0.0: continue
		var definition: EnemyDefinition = enemy_definitions[enemy.type]
		var data: Dictionary = {
			"name": definition.name,
			"speed": definition.get_combat_value("speed", 0.0), "base_damage": definition.get_combat_value("base_damage", 0.0),
			"attack_type": definition.get_combat_value("attack_type", ""), "attack_range": definition.get_combat_value("attack_range", 0.0),
			"attack_cooldown": definition.get_combat_value("attack_cooldown", 0.0), "armor": definition.get_combat_value("armor", 0.0),
			"reward": definition.get_combat_value("reward", 0.0)
		}
		if update_enemy_attack(delta, enemy, data):
			continue
		var start: Vector2 = enemy.state_get("start_position", LANES[enemy.lane])
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
				play_sfx("ui_cancel")
				log_event("DEFEAT. The base was destroyed. Press RESTART to try again.")
				return

func get_robot_runtime_stats() -> Dictionary:
	var level: int = robot_progression.level
	var level_count := float(level - 1)
	var stats := {
		"hp": float(robot_definition.get_base_stat("hp")) * pow(1.0 + float(robot_progression_definition.get("hp_growth", 0.0)), level_count),
		"speed": float(robot_definition.get_base_stat("speed")) * pow(1.0 + float(robot_progression_definition.get("speed_growth", 0.0)), level_count),
		"damage": float(robot_definition.get_base_stat("damage")) * pow(1.0 + float(robot_progression_definition.get("damage_growth", 0.0)), level_count),
		"cooldown": float(robot_definition.get_base_stat("cooldown")),
		"range": float(robot_definition.get_base_stat("range")) * pow(1.0 + float(robot_progression_definition.get("range_growth", 0.0)), level_count),
		"max_moves": int(robot_definition.get_base_stat("max_moves"))
	}
	for slot in player_profile.equipped_items:
		var item_id := str(player_profile.equipped_items.get(slot, ""))
		for item in player_profile.inventory:
			if str(item.get("id", "")) != item_id: continue
			var item_stats: Dictionary = item.get("stats", {})
			stats["hp"] += float(item_stats.get("hp", 0.0))
			stats["damage"] += float(item_stats.get("damage", 0.0))
			stats["range"] += float(item_stats.get("range", 0.0))
			stats["speed"] *= 1.0 + float(item_stats.get("speed", 0.0))
			break
	return stats

func _load_robot_progression() -> void:
	player_profile.reset()
	if StageManager.run_mode != "campaign":
		return
	var file := FileAccess.open(ROBOT_PROFILE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		player_profile.load_from_data(parsed)
	if player_profile.inventory.is_empty():
		player_profile.inventory.append(create_item("weapon"))
		player_profile.inventory.append(create_item("armor"))
		player_profile.inventory.append(create_item("core"))
		for item in player_profile.inventory:
			equip_item(str(item.get("id", "")))
	_save_robot_progression()

func create_item(base_id: String) -> Dictionary:
	var file := FileAccess.open(ITEM_CATALOG_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary or not parsed.has(base_id):
		return {}
	var base: Dictionary = parsed[base_id]
	var stats: Dictionary = base.get("base_stats", {}).duplicate(true)
	var prefix: Dictionary = {}
	var suffix: Dictionary = {}
	var prefixes: Array = base.get("prefixes", [])
	var suffixes: Array = base.get("suffixes", [])
	if not prefixes.is_empty():
		prefix = prefixes[randi() % prefixes.size()].duplicate(true)
	if not suffixes.is_empty():
		suffix = suffixes[randi() % suffixes.size()].duplicate(true)
	for affix in [prefix, suffix]:
		if affix.is_empty(): continue
		var stat := str(affix.get("stat", ""))
		if stat.is_empty(): continue
		stats[stat] = float(stats.get(stat, 0.0)) + randf_range(float(affix.get("min", 0)), float(affix.get("max", 0)))
	var names: Array[String] = []
	if not prefix.is_empty(): names.append(str(prefix.name))
	names.append(str(base.name))
	if not suffix.is_empty(): names.append(str(suffix.name))
	return {"id": "%s_%d" % [base_id, Time.get_ticks_usec()], "base_id": base_id, "name": " ".join(names), "slot": str(base.slot), "size": base.size.duplicate(), "stats": stats}

func equip_item(item_id: String) -> bool:
	for item in player_profile.inventory:
		if str(item.get("id", "")) == item_id:
			player_profile.equipped_items[str(item.get("slot", ""))] = item_id
			_save_robot_progression()
			return true
	return false

func _save_robot_progression() -> void:
	if StageManager.run_mode != "campaign":
		return
	var file := FileAccess.open(ROBOT_PROFILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to save campaign robot profile.")
		return
	var save_data := player_profile.to_data()
	file.store_string(JSON.stringify(save_data, "  "))
	file.close()

func add_robot_xp(amount: int) -> void:
	if StageManager.run_mode != "campaign" or amount <= 0:
		return
	robot_progression.xp += amount
	var leveled_up := false
	while robot_progression.xp >= int(robot_progression_definition.get("xp_per_level", 0)) * robot_progression.level:
		var required_xp := int(robot_progression_definition.get("xp_per_level", 0)) * robot_progression.level
		robot_progression.xp -= required_xp
		robot_progression.level += 1
		leveled_up = true
		var new_stats := get_robot_runtime_stats()
		var old_max_hp := float(robot.state_get("max_hp", robot_definition.get_base_stat("hp")))
		robot["max_hp"] = new_stats.hp
		if robot.state_get("active", false):
			robot.hp = min(new_stats.hp, float(robot.state_get("hp", old_max_hp)) + (new_stats.hp - old_max_hp))
	if leveled_up:
		play_sfx("ui_confirm")
		log_event("ATLAS-01 LEVEL UP! Lv.%d" % robot_progression.level)
	_save_robot_progression()

func damage_enemy(enemy: EnemyRuntimeState, amount: float, source: String) -> void:
	if enemy == null or enemy.hp <= 0.0: return
	var definition: EnemyDefinition = enemy_definitions[enemy.type]
	var dealt: float = max(1.0, amount - float(definition.get_combat_value("armor", 0.0)))
	enemy.hp -= dealt; enemy.flash = 0.12
	effects.append({"position": enemy.position, "type": "impact_explosion", "life": 0.35, "max_life": 0.35, "source": source})
	damage_numbers.append({"position": enemy.position + Vector2(0, -32), "value": int(dealt), "life": 0.7, "max_life": 0.7})
	if enemy.hp <= 0.0:
		gold += float(definition.get_combat_value("reward", 0.0))
		add_robot_xp(int(definition.get_combat_value("reward", 0.0)))
		robot["finisher"] = min(float(finisher_definition.get("meter_max", 0.0)), float(robot.state_get("finisher", 0.0)) + float(finisher_definition.get("charge_boss", 0.0)) if enemy.type == "giant" else float(finisher_definition.get("charge_normal", 0.0)))
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

func get_selected_robot_target() -> Dictionary:
	if selected_enemy_index < 0 or selected_enemy_index >= enemies.size():
		return {}
	var target: Dictionary = enemies[selected_enemy_index]
	if float(target.get("hp", 0.0)) <= 0.0:
		return {}
	return target

func get_robot_target() -> Dictionary:
	return get_selected_robot_target()

func select_robot_target_at(point: Vector2) -> bool:
	var best_index := -1
	var best_distance := INF
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		if float(enemy.state_get("hp", 0.0)) <= 0.0:
			continue
		var enemy_size: Vector2 = ENEMY_SPRITE_SIZES.get(str(enemy.state_get("type", "normal")), Vector2(48, 56))
		var hit_radius: float = max(24.0, max(enemy_size.x, enemy_size.y) * 0.42)
		var distance := point.distance_to(enemy.position)
		if distance <= hit_radius and distance < best_distance:
			best_distance = distance
			best_index = index
	if best_index < 0:
		return false
	selected_enemy_index = best_index
	robot_selected = false
	selected_tower = ""
	selected_slot = ""
	play_sfx("ui_click")
	log_event("Target locked: %s." % str(enemy_catalog[enemies[best_index].type].name))
	queue_redraw()
	return true

func switch_robot_target(direction: int = 1) -> bool:
	var active_indices: Array[int] = []
	for index in range(enemies.size()):
		if float(enemies[index].get("hp", 0.0)) > 0.0:
			active_indices.append(index)
	if active_indices.is_empty():
		selected_enemy_index = -1
		return false
	var current_pos := active_indices.find(selected_enemy_index)
	if current_pos < 0:
		current_pos = 0 if direction > 0 else active_indices.size() - 1
	else:
		current_pos = posmod(current_pos + direction, active_indices.size())
	selected_enemy_index = active_indices[current_pos]
	play_sfx("ui_click")
	log_event("Target switched: %s." % str(enemy_catalog[enemies[selected_enemy_index].type].name))
	queue_redraw()
	return true

func get_robot_heavy_target() -> Dictionary:
	var robot_stats := get_robot_runtime_stats()
	var candidates: Array = enemies.filter(func(enemy): return enemy.hp > 0.0 and enemy.type in ["heavy", "giant"] and enemy.position.distance_to(robot.position) <= robot_stats.range + 20.0)
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
	if not robot.state_get("active", false) or robot.hp <= 0.0 or run_state not in [RunState.READY, RunState.RUNNING]:
		return
	var direction := Vector2.ZERO
	direction.x = float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
	direction.y = float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
	if direction == Vector2.ZERO:
		robot["is_moving"] = false
		return
	direction = direction.normalized()
	robot["manual_position"] = true
	robot.erase_state("target_pos")
	robot["spot"] = "CUSTOM"
	robot["is_moving"] = true
	var target: Vector2 = robot.position + direction * get_robot_runtime_stats().speed * delta
	robot.position = Vector2(
		clampf(target.x, MAP_ORIGIN.x + 32.0, MAP_ORIGIN.x + MAP_PIXEL_SIZE.x - 32.0),
		clampf(target.y, MAP_ORIGIN.y + 32.0, MAP_ORIGIN.y + MAP_PIXEL_SIZE.y - 32.0)
	)

func move_robot_automatically(delta: float) -> void:
	if not wave_running or float(robot.state_get("special", 0.0)) > 0.0: return
	if robot.has_state("target_pos"):
		var manual_target: Vector2 = robot.target_pos
		var manual_distance: float = robot.position.distance_to(manual_target)
		var manual_step: float = get_robot_runtime_stats().speed * delta
		if manual_distance <= manual_step:
			robot.position = manual_target
			robot.erase_state("target_pos")
		else:
			robot.position += robot.position.direction_to(manual_target) * manual_step
		return
	if robot.state_get("manual_position", false): return
	var auto_spot := get_robot_auto_spot()
	if auto_spot.is_empty(): return
	if robot.spot != auto_spot:
		robot.spot = auto_spot
		robot["target_pos"] = ROBOT_SPOTS[auto_spot]
		log_event("ATLAS-01 moving to %s." % auto_spot)
	if not robot.has_state("target_pos"): return
	var target_pos: Vector2 = robot.target_pos
	var distance: float = robot.position.distance_to(target_pos)
	var step: float = float(get_robot_runtime_stats().speed) * delta
	if distance <= step:
		robot.position = target_pos
		robot.erase_state("target_pos")
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
		var weapon: WeaponDefinition = tower.get_weapon_definition()
		var target: Dictionary = find_target(tower.position, weapon.range, weapon.preference)
		if target.is_empty(): continue
		var event := GameplayEvent.create("weapon_fired", "tower", tower.type)
		event.target = target
		event.position = tower.position
		event.damage = weapon.damage
		event.payload = {
			"weapon": tower.type,
			"target_position": target.position,
			"projectile_speed": 5.0
		}
		_handle_gameplay_event(event)
		tower.cooldown = weapon.cooldown

func _handle_gameplay_event(event: GameplayEvent) -> void:
	if event == null:
		return
	match event.type:
		"weapon_fired":
			if event.source in ["robot", "tower"]:
				var target_enemy: Variant = event.target
				if target_enemy == null:
					return
				effects.append({
					"type": "proj_defender",
					"start": event.position,
					"target": event.payload.get("target_position", event.position),
					"target_enemy": target_enemy,
					"damage": event.damage,
					"source": event.source,
					"weapon": event.payload.get("weapon", "robot"),
					"progress": 0.0,
					"speed": float(event.payload.get("projectile_speed", 5.5))
				})
		"damage_requested":
			var target_enemy: Variant = event.target
			if target_enemy != null:
				damage_enemy(target_enemy, event.damage, str(event.payload.get("source", event.source)))


func update_robot(delta: float) -> void:
	if selected_enemy_index >= enemies.size() or (selected_enemy_index >= 0 and float(enemies[selected_enemy_index].get("hp", 0.0)) <= 0.0):
		selected_enemy_index = -1
	if not robot.active or robot.hp <= 0.0: return
	robot["special"] = max(0.0, float(robot.state_get("special", 0.0)) - delta)
	if float(robot.state_get("special", 0.0)) > 0.0:
		return
	robot["energy"] = min(float(robot_energy_definition.get("max", 0.0)), float(robot.state_get("energy", float(robot_energy_definition.get("max", 0.0)))) + float(robot_energy_definition.get("regen", 0.0)) * delta)
	robot.attack = max(0.0, float(robot.state_get("attack", 0.0)) - delta)
	robot.area -= delta; robot.pierce -= delta
	if bool(robot.state_get("auto_attack", true)):
		try_basic_attack()

func try_basic_attack() -> bool:
	if not robot.active or robot.hp <= 0.0 or run_state != RunState.RUNNING:
		return false
	if robot.attack > 0.0:
		return false
	var target: Dictionary = get_selected_robot_target()
	if target.is_empty() and bool(robot.state_get("auto_attack", true)):
		target = find_target(robot.position, robot_weapon_definition.range)
		if not target.is_empty():
			selected_enemy_index = enemies.find(target)
	if target.is_empty():
		return false
	if target.position.distance_to(robot.position) > robot_weapon_definition.range:
		log_event("Target is out of weapon range.")
		return false
	var event := GameplayEvent.create("weapon_fired", "robot", robot_weapon_definition.id)
	event.target = target
	event.position = robot.position
	event.damage = robot_weapon_definition.damage
	event.payload = {
		"weapon": "robot",
		"target_position": target.position,
		"projectile_speed": 5.5
	}
	_handle_gameplay_event(event)
	robot.attack = robot_weapon_definition.cooldown
	log_event("ATLAS-01 fired BASIC WEAPON.")
	return true

func try_finisher() -> bool:
	if not robot.active or robot.hp <= 0.0 or run_state != RunState.RUNNING:
		return false
	if float(robot.state_get("finisher", 0.0)) < float(finisher_definition.get("meter_max", 0.0)):
		return false
	var targets: Array = enemies.filter(func(enemy): return enemy.hp > 0.0 and enemy.position.distance_to(robot.position) <= float(finisher_definition.get("radius", 0.0)))
	if targets.is_empty():
		log_event("FINISHER requires enemies in range.")
		return false
	effects.append({"position": robot.position, "type": "area", "life": float(finisher_definition.get("duration", 0.0)), "damage_delay": 0.28, "damage_targets": targets, "damage": float(finisher_definition.get("damage", 0.0)), "source": "finisher"})
	robot["special"] = float(finisher_definition.get("duration", 0.0))
	robot["special_type"] = "finisher"
	robot["finisher"] = 0.0
	log_event("ATLAS-01 FINISHER: ALL-RANGE STRIKE.")
	play_sfx("ui_confirm")
	return true

func try_special_attack() -> bool:
	if not robot.active or robot.hp <= 0.0 or run_state != RunState.RUNNING:
		return false
	if float(robot.state_get("special", 0.0)) > 0.0:
		return false
	if float(robot.state_get("energy", float(robot_energy_definition.get("max", 0.0)))) < float(skills_catalog.get("area_attack", {}).get("energy_cost", 0.0)):
		log_event("ENERGY 부족: SPECIAL 사용 불가.")
		return false
	var unlocked_abilities: Array = robot_progression.unlocked_abilities
	# Base SPECIAL is always available; progression abilities remain optional upgrades.
	if robot.area <= 0.0:
		var nearby_base: Array = enemies.filter(func(enemy): return enemy.hp > 0.0 and enemy.position.distance_to(robot.position) <= skills_catalog.area_attack.radius)
		if not nearby_base.is_empty():
			effects.append({"position": robot.position, "type": "area", "life": 0.45, "damage_delay": 0.22, "damage_targets": nearby_base, "damage": skills_catalog.area_attack.damage, "source": "area"})
			robot["special"] = float(skills_catalog.get("area_attack", {}).get("duration", 0.0))
			robot["special_type"] = "area"
			robot["energy"] = max(0.0, float(robot.state_get("energy", float(robot_energy_definition.get("max", 0.0)))) - float(skills_catalog.get("area_attack", {}).get("energy_cost", 0.0)))
			robot.area = skills_catalog.area_attack.cooldown
			log_event("ATLAS-01 used BASE SPECIAL.")
			return true
	if unlocked_abilities.has("area_attack") and robot.area <= 0.0:
		var nearby: Array = enemies.filter(func(enemy): return enemy.hp > 0.0 and enemy.position.distance_to(robot.position) <= skills_catalog.area_attack.radius)
		if nearby.size() >= skills_catalog.area_attack.threshold:
			effects.append({"position": robot.position, "type": "area", "life": 0.45, "damage_delay": 0.22, "damage_targets": nearby, "damage": skills_catalog.area_attack.damage, "source": "area"})
			robot["special"] = float(skills_catalog.get("area_attack", {}).get("duration", 0.0))
			robot["special_type"] = "area"
			robot["energy"] = max(0.0, float(robot.state_get("energy", float(robot_energy_definition.get("max", 0.0)))) - float(skills_catalog.get("area_attack", {}).get("energy_cost", 0.0)))
			robot.area = skills_catalog.area_attack.cooldown
			log_event("ATLAS-01 used AREA ATTACK.")
			return true
	if unlocked_abilities.has("heavy_pierce") and robot.pierce <= 0.0:
		var heavy: Dictionary = get_robot_heavy_target()
		if not heavy.is_empty():
			effects.append({"position": heavy.position, "type": "pierce", "life": float(skills_catalog.get("heavy_pierce", {}).get("duration", 0.0)), "damage_delay": 0.22, "target_enemy": heavy, "damage": skills_catalog.heavy_pierce.damage, "source": "pierce"})
			robot["special"] = float(skills_catalog.get("heavy_pierce", {}).get("duration", 0.0))
			robot["special_type"] = "pierce"
			robot["energy"] = max(0.0, float(robot.state_get("energy", float(robot_energy_definition.get("max", 0.0)))) - float(skills_catalog.get("heavy_pierce", {}).get("energy_cost", 0.0)))
			robot.pierce = skills_catalog.heavy_pierce.cooldown
			log_event("ATLAS-01 used HEAVY PIERCE on %s." % enemy_catalog[heavy.type].name)
			return true
	return false

func try_skill_slot(slot: int) -> bool:
	if not robot.active or robot.hp <= 0.0 or run_state != RunState.RUNNING:
		return false
	# Three additional HUD skill slots are reserved for future distinct skills.
	log_event("SKILL %d is not implemented yet." % slot)
	play_sfx("ui_cancel")
	return false

func available_robot_growths() -> Array[String]:
	var available: Array[String] = []
	var unlocked_abilities: Array = robot_progression.unlocked_abilities
	for ability_key in skills_catalog:
		var ability_id := str(ability_key)
		if ability_id == "finisher": continue
		if not unlocked_abilities.has(ability_id): available.append(ability_id)
	return available

func choose_robot_growth(ability_id: String) -> void:
	if run_state != RunState.GROWTH or not available_robot_growths().has(ability_id): return
	robot_progression.unlock_ability(ability_id)
	play_sfx("ui_confirm")
	log_event("ATLAS-01 unlocked %s." % skills_catalog[ability_id]["name"])
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
		var next_stage_id := StageManager.get_next_campaign_stage_id()
		if StageManager.run_mode != "campaign":
			next_stage_id = ""
		player_profile.campaign_progression.complete_stage(StageManager.current_stage_id, next_stage_id)
		_save_robot_progression()
		if not next_stage_id.is_empty():
			if not load_stage_map(next_stage_id):
				push_error("Could not load next campaign Stage '%s'." % next_stage_id)
				run_state = RunState.DEFEAT
				play_sfx("ui_cancel")
				log_event("STAGE LOAD FAILED. Press RESTART to retry the campaign.")
				return
			reset_game()
			log_event("STAGE %d READY. Build defenses before Wave 1." % StageManager.get_current_stage().get("order", 1))
		else:
			run_state = RunState.VICTORY
			play_sfx("ui_confirm")
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
	get_parent().get_node("Camera2D").position = _camera_target_clamped(get_parent().get_node("Camera2D").position + direction.normalized() * CAMERA_EDGE_SPEED * delta)

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
	get_parent().get_node("Camera2D").position = _camera_target_clamped(target)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		switch_robot_target(-1 if event.shift_pressed else 1)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_I:
		inventory_open = not inventory_open
		queue_redraw()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_J:
		try_basic_attack()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_SPACE:
		try_special_attack()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		try_finisher()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		camera_dragging = event.pressed
		camera_last_mouse = event.position
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion and camera_dragging:
		get_parent().get_node("Camera2D").position = _camera_target_clamped(get_parent().get_node("Camera2D").position - event.relative)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_minimap_screen_rect().has_point(event.position):
			center_camera_from_minimap(event.position)
			get_viewport().set_input_as_handled()
			return
		var point := get_global_mouse_position()
		# The bottom HUD overlaps the map's world rectangle, so UI hit-testing must happen first.
		if _ui_button_rect(100).has_point(point) or _ui_action_rect(0).has_point(point) or _ui_action_rect(1).has_point(point) or _ui_action_rect(2).has_point(point) or _ui_action_rect(3).has_point(point) or _ui_action_rect(4).has_point(point) or _ui_action_rect(5).has_point(point) or _ui_action_rect(6).has_point(point):
			handle_click(point)
			get_viewport().set_input_as_handled()
			return
		# World clicks: target selection and placed-tower selection must be resolved before movement.
		if select_robot_target_at(point):
			get_viewport().set_input_as_handled()
			return
		var tower_position := get_tower_placement_position(point)
		if not pending_tower_type.is_empty() and tower_position != Vector2.INF:
			handle_click(point)
			get_viewport().set_input_as_handled()
			return
		for tower in towers:
			if point.distance_to(tower.position) < 24.0:
				handle_click(point)
				get_viewport().set_input_as_handled()
				return
		if robot.active and Rect2(MAP_ORIGIN, MAP_PIXEL_SIZE).has_point(point):
			move_robot_to_position(point)
			get_viewport().set_input_as_handled()
			return
		handle_click(point)

func handle_click(point: Vector2) -> void:
	if inventory_open:
		var inventory_rect := get_inventory_rect()
		if inventory_rect.has_point(point):
			var grid_origin := inventory_rect.position + Vector2(24, 70)
			var cell := Vector2i(floor((point.x - grid_origin.x) / 52.0), floor((point.y - grid_origin.y) / 52.0))
			if cell.x >= 0 and cell.x < INVENTORY_COLS and cell.y >= 0 and cell.y < INVENTORY_ROWS:
				var index := cell.y * INVENTORY_COLS + cell.x
				if index < player_profile.inventory.size():
					equip_item(str(player_profile.inventory[index].get("id", "")))
					play_sfx("ui_confirm")
					log_event("Equipped %s." % str(player_profile.inventory[index].get("name", "ITEM")))
					queue_redraw()
			return
	if _ui_action_rect(183).has_point(point):
		if run_state in [RunState.VICTORY, RunState.DEFEAT]:
			restart_run()
			play_sfx("ui_confirm")
			return
	if _ui_action_rect(0).has_point(point): select_tower_for_build("cannon"); return
	if _ui_action_rect(1).has_point(point): select_tower_for_build("gatling"); return
	if _ui_action_rect(2).has_point(point): try_special_attack(); return
	if _ui_action_rect(3).has_point(point): try_skill_slot(1); return
	if _ui_action_rect(4).has_point(point): try_skill_slot(2); return
	if _ui_action_rect(5).has_point(point): try_skill_slot(3); return
	if _ui_action_rect(6).has_point(point): try_finisher(); return
	if _ui_button_rect(100).has_point(point): toggle_robot_attack_mode(); return
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
			# Placement zone click without a selected tower only clears the temporary selection.
			selected_slot = ""
			selected_slot_position = Vector2.ZERO
			selected_tower = ""
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
	log_event("%s: 설치 위치를 클릭하세요." % tower_definitions[type].name)
	queue_redraw()

func build_tower(type: String) -> void:
	if run_state not in [RunState.READY, RunState.RUNNING]: return
	if selected_slot.is_empty(): play_sfx("ui_error"); log_event("Select an empty tower slot first."); return
	if towers.any(func(tower): return tower.id == selected_slot): upgrade_tower(type); return
	if not tower_catalog.has(type): play_sfx("ui_error"); return
	var definition: TowerDefinition = tower_definitions[type]
	var cost := float(definition.get_combat_value("cost", 0.0))
	if gold < cost: play_sfx("ui_error"); log_event("Need %d gold for %s." % [int(cost), definition.name]); return
	gold -= cost
	towers.append(TowerRuntimeState.create(selected_slot, type, selected_slot_position, definition))
	play_sfx("tower_build"); log_event("%s deployed at %s." % [definition.name, selected_slot]); selected_slot = ""; selected_slot_position = Vector2.ZERO; selected_tower = ""; robot_selected = false

func upgrade_tower(type: String) -> void:
	if run_state == RunState.RUNNING: play_sfx("ui_error"); log_event("Cannot upgrade towers during a wave."); return
	var index := towers.find_custom(func(tower): return tower.id == selected_slot)
	if index < 0: return
	var tower: TowerRuntimeState = towers[index]
	if tower.type != type: play_sfx("ui_error"); log_event("Select the matching tower type to upgrade."); return
	if tower.level >= 2: play_sfx("ui_error"); log_event("Tower is already MAX LVL 2."); return
	var cost := int(tower.get_upgrade_value("upgrade_cost", 0))
	if gold < cost: play_sfx("ui_error"); log_event("Not enough gold for LVL 2 upgrade."); return
	gold -= cost
	tower.upgrade_to_level2()
	towers[index] = tower
	play_sfx("ui_confirm"); log_event("%s upgraded to LVL 2." % tower.definition.name)
	selected_slot = ""; selected_slot_position = Vector2.ZERO; selected_tower = ""; robot_selected = false; queue_redraw()

func toggle_robot_attack_mode() -> void:
	if not robot.active:
		return
	robot["auto_attack"] = not bool(robot.state_get("auto_attack", true))
	play_sfx("ui_confirm")
	log_event("ATLAS-01 기본 공격: %s." % ("자동" if bool(robot.auto_attack) else "수동"))
	queue_redraw()

func launch_robot() -> void:
	if not can_launch_robot(): return
	robot.hp = get_robot_runtime_stats().hp
	robot.max_hp = get_robot_runtime_stats().hp
	robot["auto_attack"] = true
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
	for tower in towers:
		var tower_pos: Vector2 = tower.position
		var tower_feet := tower_pos + Vector2(0, 26)
		var anim_key := "tower_cannon_anim" if tower.type == "cannon" else "tower_gatling_anim"
		var cd_left: float = tower.cooldown
		var max_cd: float = float(tower.get_combat_value("cooldown", 0.6))
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
		var definition: EnemyDefinition = enemy_definitions[enemy.type]
		var enemy_size: Vector2 = ENEMY_SPRITE_SIZES[enemy.type] * 1.08
		
		# Presentation-only scale increase keeps battlefield combat as the primary visual focus.
		# Enemy data, collision, targeting and movement are unchanged.
		# Strategic Base Indicator at Enemy Feet (drawn BEFORE sprite so feet sit inside base ring)
		var feet_pos: Vector2 = enemy.position + Vector2(0, enemy_size.y * 0.48)
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
		if selected_enemy_index == enemies.find(enemy):
			draw_arc(feet_pos, ring_radius * 1.28, 0, TAU, 28, Color("f0d28a"), 3.0)
			draw_string(ThemeDB.fallback_font, enemy.position + Vector2(-34, enemy_size.y * 0.5 + 24), "TARGET", HORIZONTAL_ALIGNMENT_CENTER, 68, 9, Color("f0d28a"))
		var hp_position: Vector2 = enemy.position + Vector2(-enemy_size.x * 0.5, -enemy_size.y * 0.5 - 11)
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
			var projectile_texture: Texture2D = (robot_projectile_catalog.get("robot", VISUALS["bullet_defender"]) if weapon_type == "robot" else tower_projectile_catalog.get(weapon_type, VISUALS["bullet_defender"])) as Texture2D
			draw_rotated_animated_sprite(projectile_texture, current_p, Vector2(36, 44), angle, p_frame, 8)
		elif etype == "proj_threat":
			var progress: float = clampf(float(effect.get("progress", 0.0)), 0.0, 1.0)
			var start_p: Vector2 = effect.get("start", Vector2.ZERO)
			var end_p: Vector2 = effect.get("target", Vector2.ZERO)
			var current_p: Vector2 = start_p.lerp(end_p, progress)
			var angle: float = start_p.angle_to_point(end_p) + PI / 2.0
			var p_frame: int = int(elapsed * 16.0) % 6
			var enemy_type := str(effect.get("enemy_type", "giant"))
			var projectile_texture: Texture2D = enemy_projectile_catalog.get(enemy_type, VISUALS["bullet_threat"]) as Texture2D
			draw_rotated_animated_sprite(projectile_texture, current_p, Vector2(40, 48), angle, p_frame, 6)

	# Player Unit ATLAS-01 Robot (Heroic Strategic Unit Base & Visibility)
	if robot.active:
		var is_flashing: bool = float(robot.state_get("flash", 0.0)) > 0.0
		
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
		if float(robot.state_get("special", 0.0)) > 0.0:
			anim_key = "atlas_skill"
			total_f = 5
			fps = 10.0
		elif float(robot.state_get("attack", 0.0)) > 0.3:
			anim_key = "atlas_attack"
			total_f = 7
			fps = 14.0
		elif float(robot.state_get("area", 0.0)) > 5.0 or float(robot.state_get("pierce", 0.0)) > 6.0:
			anim_key = "atlas_skill"
			total_f = 5
			fps = 10.0
		elif bool(robot.state_get("is_moving", false)):
			anim_key = "atlas_move"
			total_f = 5
			fps = 12.0
		var r_frame: int = int(elapsed * fps) % total_f
		if float(robot.state_get("special", 0.0)) > 0.0:
			draw_arc(r_feet_pos, 47.0, elapsed * 2.5, elapsed * 2.5 + PI * 1.35, 24, Color("f0d28a", 0.85), 3.0)
		elif float(robot.state_get("attack", 0.0)) > 0.3:
			draw_arc(r_feet_pos, 46.0, elapsed * 4.0, elapsed * 4.0 + PI, 20, Color("7ed6ce", 0.9), 2.5)
		draw_animated_sprite(robot_sprite_catalog.get(anim_key.replace("atlas_", ""), VISUALS[anim_key]) as Texture2D, robot.position, Vector2(78, 132), r_frame, total_f)
		
		# Player Robot Unit HP Bar
		var r_hp_pos: Vector2 = robot.position + Vector2(-39, -76)
		draw_rect(Rect2(r_hp_pos - Vector2(1, 1), Vector2(80, 6)), Color("101f25"))
		draw_rect(Rect2(r_hp_pos, Vector2(78, 4)), Color("1c3e38"))
		var robot_max_hp: float = max(1.0, float(robot.state_get("max_hp", get_robot_runtime_stats().hp)))
		draw_rect(Rect2(r_hp_pos, Vector2(78 * max(0.0, robot.hp / robot_max_hp), 4)), Color("7ed6ce"))

	for damage_number in damage_numbers:
		var life := float(damage_number.get("life", 0.0))
		var alpha := clampf(life / 0.7, 0.0, 1.0)
		draw_string(ThemeDB.fallback_font, damage_number.get("position", Vector2.ZERO), str(damage_number.get("value", 0)), HORIZONTAL_ALIGNMENT_CENTER, 50, 16, Color(1, 0.85, 0.35, alpha))
	draw_ui2()

func _ui_origin() -> Vector2:
	var screen_to_world: Transform2D = get_viewport().get_canvas_transform().affine_inverse()
	return screen_to_world * Vector2(0, get_viewport_rect().size.y - BOTTOM_HUD_HEIGHT)

func _ui_action_rect(index: int) -> Rect2:
	return Rect2(_ui_origin() + Vector2(330.0 + index * 78.0, 14.0), Vector2(72, 76))

func _ui_button_rect(y: float) -> Rect2:
	return Rect2(_ui_origin() + Vector2(330, y), Vector2(300, 44))

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
	button(_ui_button_rect(183), "전투 재시작", false)

	button(_ui_button_rect(279), "캐논 건설", run_state not in [RunState.READY, RunState.RUNNING])
	button(_ui_button_rect(327), "개틀링 건설", run_state not in [RunState.READY, RunState.RUNNING])
	var special_ready: bool = robot.active and run_state == RunState.RUNNING and float(robot.state_get("special", 0.0)) <= 0.0 and not robot_progression.unlocked_abilities.is_empty()
	button(_ui_button_rect(375), "필살기 [SPACE]", not special_ready)
	var auto_attack := bool(robot.state_get("auto_attack", true))
	button(_ui_button_rect(423), "기본 공격: " + ("자동" if auto_attack else "수동"), not robot.active)
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

func get_inventory_rect() -> Rect2:
	var screen_to_world: Transform2D = get_viewport().get_canvas_transform().affine_inverse()
	var viewport_size := get_viewport_rect().size
	var screen_origin: Vector2 = screen_to_world * Vector2.ZERO
	return Rect2(screen_origin + viewport_size * 0.5 - Vector2(390, 270), Vector2(780, 540))

func draw_inventory() -> void:
	if not inventory_open: return
	var rect := get_inventory_rect()
	draw_rect(rect, Color(0.02, 0.035, 0.04, 0.98), true)
	draw_rect(rect, Color("7ed6ce"), false, 2.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(24, 32), "ATLAS-01  EQUIPMENT / INVENTORY", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("d7fff7"))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(24, 51), "I  CLOSE   •   CLICK AN ITEM TO EQUIP", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("829aa0"))
	var slot_y := rect.position.y + 72.0
	for slot in ["weapon", "armor", "core"]:
		var slot_rect := Rect2(rect.position + Vector2(500, slot_y), Vector2(240, 100 if slot == "armor" else 72))
		draw_rect(slot_rect, Color("101f25"), true)
		draw_rect(slot_rect, Color("527079"), false, 1.0)
		draw_string(ThemeDB.fallback_font, slot_rect.position + Vector2(10, 17), str(slot).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("829aa0"))
		var equipped_id := str(player_profile.equipped_items.get(slot, ""))
		var equipped_name := "EMPTY"
		for item in player_profile.inventory:
			if str(item.get("id", "")) == equipped_id: equipped_name = str(item.get("name", "ITEM"))
		draw_string(ThemeDB.fallback_font, slot_rect.position + Vector2(10, 39), equipped_name, HORIZONTAL_ALIGNMENT_LEFT, 220, 11, Color("f0d28a"))
		slot_y += slot_rect.size.y + 10.0
	var grid_origin := rect.position + Vector2(24, 70)
	for y in range(INVENTORY_ROWS):
		for x in range(INVENTORY_COLS):
			var cell_rect := Rect2(grid_origin + Vector2(x * 52, y * 52), Vector2(46, 46))
			draw_rect(cell_rect, Color("0b171b"), true)
			draw_rect(cell_rect, Color("30484f"), false, 1.0)
	for index in range(min(player_profile.inventory.size(), INVENTORY_COLS * INVENTORY_ROWS)):
		var item: Dictionary = player_profile.inventory[index]
		var x := index % INVENTORY_COLS
		var y := index / INVENTORY_COLS
		var item_rect := Rect2(grid_origin + Vector2(x * 52, y * 52), Vector2(46, 46))
		var slot := str(item.get("slot", ""))
		var item_color := Color("f0d28a") if player_profile.equipped_items.get(slot, "") == item.get("id", "") else Color("7ed6ce")
		draw_rect(item_rect.grow(-3), Color(item_color, 0.14), true)
		draw_rect(item_rect.grow(-3), item_color, false, 2.0)
		draw_string(ThemeDB.fallback_font, item_rect.position + Vector2(4, 17), str(item.get("base_id", "ITEM")).to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 38, 8, item_color)
		var stats: Dictionary = item.get("stats", {})
		var stat_text := ""
		if stats.has("damage"): stat_text = "+%d ATK" % int(stats.damage)
		elif stats.has("hp"): stat_text = "+%d HP" % int(stats.hp)
		draw_string(ThemeDB.fallback_font, item_rect.position + Vector2(2, 35), stat_text, HORIZONTAL_ALIGNMENT_CENTER, 42, 7, Color("d7fff7"))

func draw_ui2() -> void:
	var viewport_size := get_viewport_rect().size
	var screen_to_world: Transform2D = get_viewport().get_canvas_transform().affine_inverse()
	var screen_origin: Vector2 = screen_to_world * Vector2.ZERO
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
	var selected_target := get_selected_robot_target()
	var target_text := "TARGET: NONE"
	if not selected_target.is_empty():
		var target_definition: EnemyDefinition = enemy_definitions[selected_target.type]
		var target_range_text := "IN RANGE" if selected_target.position.distance_to(robot.position) <= get_robot_runtime_stats().range else "OUT OF RANGE"
		target_text = "TARGET: %s  %s  HP %03d" % [str(target_definition.name), target_range_text, max(0, ceil(selected_target.hp))]
	draw_string(ThemeDB.fallback_font, top_rect.position + Vector2(viewport_size.x - 410, 35), target_text, HORIZONTAL_ALIGNMENT_RIGHT, 385, 11, Color("f0d28a") if not selected_target.is_empty() else Color("829aa0"))

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
	var robot_max_hp: float = max(1.0, float(robot.state_get("max_hp", get_robot_runtime_stats().hp)))
	draw_rect(Rect2(portrait_panel.position + Vector2(132, 86), Vector2(150 * max(0.0, robot.hp / robot_max_hp), 8)), Color("7ed6ce"), true)
	draw_string(ThemeDB.fallback_font, portrait_panel.position + Vector2(132, 112), "%03d / %03d" % [max(0, ceil(robot.hp)), ceil(robot_max_hp)], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("a9c5c7"))
	var robot_energy: float = clampf(float(robot.state_get("energy", float(robot_energy_definition.get("max", 0.0)))), 0.0, float(robot_energy_definition.get("max", 0.0)))
	draw_rect(Rect2(portrait_panel.position + Vector2(182, 122), Vector2(100, 7)), Color("172a2d"), true)
	draw_rect(Rect2(portrait_panel.position + Vector2(182, 122), Vector2(100 * robot_energy / float(robot_energy_definition.get("max", 0.0)), 7)), Color("c58cff"), true)
	var robot_level: int = robot_progression.level
	var robot_xp: int = robot_progression.xp
	var robot_xp_need: int = int(robot_progression_definition.get("xp_per_level", 0)) * robot_level
	draw_string(ThemeDB.fallback_font, portrait_panel.position + Vector2(132, 145), "LV.%d  XP %d / %d" % [robot_level, robot_xp, robot_xp_need], HORIZONTAL_ALIGNMENT_LEFT, 155, 9, Color("f0d28a"))
	draw_string(ThemeDB.fallback_font, portrait_panel.position + Vector2(14, 140), "COMMANDS  %02d" % int(robot.state_get("commands", 0)), HORIZONTAL_ALIGNMENT_LEFT, 130, 10, Color("829aa0"))
	draw_string(ThemeDB.fallback_font, portrait_panel.position + Vector2(160, 140), "SPACE SPECIAL  R FINISHER", HORIZONTAL_ALIGNMENT_LEFT, 130, 9, Color("829aa0"))

	# Build / skill palette.
	for index in range(7):
		var rect := _ui_action_rect(index)
		var disabled := false
		var label := ""
		var sub := ""
		if index == 0:
			label = "CANNON"; sub = "BUILD"
		elif index == 1:
			label = "GATLING"; sub = "BUILD"
		elif index == 2:
			label = "SPECIAL"; sub = "SPACE"
			var special_ready: bool = robot.active and run_state == RunState.RUNNING and float(robot.state_get("special", 0.0)) <= 0.0
			disabled = not special_ready
		elif index <= 5:
			label = "SKILL %d" % (index - 2); sub = "READY"
			disabled = not (robot.active and run_state == RunState.RUNNING)
		else:
			var finisher_value: float = float(robot.state_get("finisher", 0.0))
			label = "FINISHER"; sub = "R  %03d%%" % int(finisher_value)
			disabled = not (robot.active and run_state == RunState.RUNNING and finisher_value >= float(finisher_definition.get("meter_max", 0.0)) and float(robot.state_get("special", 0.0)) <= 0.0)
		draw_rect(rect, Color("173337") if not disabled else Color("182226"), true)
		var selected := (index == 0 and selected_tower == "cannon") or (index == 1 and selected_tower == "gatling")
		draw_rect(rect, Color("7ed6ce") if selected else Color("527079"), false, 2.0)
		if index < 2:
			var texture_key := "tower_cannon" if index == 0 else "tower_gatling"
			if VISUALS.get(texture_key) != null:
				draw_sprite(VISUALS[texture_key], rect.position + Vector2(37, 31), Vector2(42, 42))
		elif index == 2:
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(8, 39), "SP", HORIZONTAL_ALIGNMENT_CENTER, 56, 15, Color("c58cff") if not disabled else Color("65777b"))
		elif index >= 3 and index <= 5:
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(8, 39), str(index - 2), HORIZONTAL_ALIGNMENT_CENTER, 56, 15, Color("7ed6ce") if not disabled else Color("65777b"))
		else:
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(8, 39), "F", HORIZONTAL_ALIGNMENT_CENTER, 56, 15, Color("f0d28a") if not disabled else Color("65777b"))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(6, 56), label, HORIZONTAL_ALIGNMENT_CENTER, 62, 9, Color("d7fff7") if not disabled else Color("65777b"))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(6, 68), sub, HORIZONTAL_ALIGNMENT_CENTER, 62, 8, Color("7ed6ce") if not disabled else Color("65777b"))

	# Basic attack mode toggle is always visible below the combat palette.
	var auto_attack := bool(robot.state_get("auto_attack", true))
	var attack_mode_rect := _ui_button_rect(100)
	button(attack_mode_rect, "기본 공격  [" + ("자동" if auto_attack else "수동") + "]", false)
	draw_string(ThemeDB.fallback_font, attack_mode_rect.position + Vector2(8, 38), "클릭하여 자동 / 수동 전환", HORIZONTAL_ALIGNMENT_LEFT, attack_mode_rect.size.x - 16, 9, Color("7ed6ce"))

	# Recent combat feed.
	var feed_rect := Rect2(bottom + Vector2(900, 12), Vector2(230, 164))
	draw_rect(feed_rect, Color(0.035, 0.065, 0.07, 0.98), true)
	draw_rect(feed_rect, Color("30484f"), false, 1.0)
	draw_string(ThemeDB.fallback_font, feed_rect.position + Vector2(12, 20), "COMBAT LOG", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("829aa0"))
	for index in range(min(feed.size(), 7)):
		draw_string(ThemeDB.fallback_font, feed_rect.position + Vector2(12, 42 + index * 17), feed[index], HORIZONTAL_ALIGNMENT_LEFT, 205, 9, Color("a9c5c7"))

	draw_minimap2(bottom + Vector2(viewport_size.x - 238, 38))
	draw_inventory()

	if run_state == RunState.VICTORY or run_state == RunState.DEFEAT:
		var overlay := Rect2(screen_origin, viewport_size)
		draw_rect(overlay, Color(0.01, 0.025, 0.03, 0.72), true)
		var status_texture: Texture2D = VISUALS["status_victory"] if run_state == RunState.VICTORY else VISUALS["status_defeat"]
		draw_sprite(status_texture, screen_origin + viewport_size * 0.5 + Vector2(0, -28), Vector2(300, 100))
		var result_text := "CAMPAIGN VICTORY" if run_state == RunState.VICTORY else "BASE DEFENSE FAILED"
		draw_string(ThemeDB.fallback_font, screen_origin + viewport_size * 0.5 + Vector2(-180, 48), result_text, HORIZONTAL_ALIGNMENT_CENTER, 360, 18, Color("d7fff7"))
		draw_string(ThemeDB.fallback_font, screen_origin + viewport_size * 0.5 + Vector2(-180, 78), "RESTART TO PLAY AGAIN", HORIZONTAL_ALIGNMENT_CENTER, 360, 11, Color("a9c5c7"))

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
	var view_top_left: Vector2 = get_parent().get_node("Camera2D").position - view_world_size * 0.5 - MAP_ORIGIN
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
		var option: Dictionary = skills_catalog[ability_id]
		var option_rect := Rect2(rect.position + Vector2(20 + available_robot_growths().find(ability_id) * 240, 55), Vector2(220, 78))
		button(option_rect, "해금 " + option["name"], false)
		draw_string(ThemeDB.fallback_font, option_rect.position + Vector2(8, 55), option["description"], HORIZONTAL_ALIGNMENT_LEFT, 205, 10, Color("a9c5c7"))

func button(rect: Rect2, label: String, disabled: bool) -> void:
	draw_rect(rect, Color("263c43") if disabled else Color("1d4a4e"), true)
	draw_rect(rect, Color("527079"), false, 1)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, 26), label, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 20, 11, Color("6a858a") if disabled else Color("d7fff7"))