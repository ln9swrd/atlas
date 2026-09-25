extends Node2D

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
	"enemy_giant": preload("res://assets/menos/sprites/enemy_giant.png"),
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
var BASE := Vector2(1080, 122)
var LANES := {"left": Vector2(70, 346), "right": Vector2(288, 794)}
var ROBOT_SPOTS := {"LEFT": Vector2(480, 300), "CENTER": Vector2(720, 250), "RIGHT": Vector2(480, 540)}
var SLOTS := {"L1": Vector2(220, 310), "L2": Vector2(450, 270), "L3": Vector2(720, 210), "R1": Vector2(300, 650), "R2": Vector2(520, 500), "R3": Vector2(760, 340)}
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
const SIDEBAR_X := 1172.0
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
var elapsed := 0.0
var spawn_clock := 0.0
var spawn_queue: Array = []
var enemies: Array = []
var towers: Array = []
var robot := {}
var robot_progression := {}
var feed: Array[String] = []
var selected_slot := ""
var selected_tower := ""
var robot_selected := false
var effects: Array = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var loaded_map := MapLoader.load_map_data("res://map_data/northbridge_sector_01.json")
	if not loaded_map.is_empty():
		apply_map_spatial_data(loaded_map)
		if not build_map_from_data(loaded_map):
			build_first_battle_map()
	else:
		build_first_battle_map()
	reset_game()
	queue_redraw()

func apply_map_spatial_data(loaded_map: Dictionary) -> void:
	if loaded_map.has("base"): BASE = loaded_map["base"]
	if loaded_map.has("lanes"): LANES = loaded_map["lanes"]
	if loaded_map.has("robot_spots"): ROBOT_SPOTS = loaded_map["robot_spots"]
	if loaded_map.has("slots"): SLOTS = loaded_map["slots"]
	if loaded_map.has("map_tiles"): MAP_TILES = loaded_map["map_tiles"]
	if loaded_map.has("map_origin"): MAP_ORIGIN = loaded_map["map_origin"]
	if loaded_map.has("map_pixel_size"): MAP_PIXEL_SIZE = loaded_map["map_pixel_size"]

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
			var val: Array = tiles_info[key]
			if val.size() < 3:
				continue
			var source_id := int(val[0])
			var atlas_x := int(val[1])
			var atlas_y := int(val[2])

			layer_node.set_cell(Vector2i(cx, cy), source_id, Vector2i(atlas_x, atlas_y))

	return true

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
	base_hp = 100.0; gold = 180; wave = 1; run_state = RunState.READY; wave_running = false; wave_clear = false; elapsed = 0.0
	spawn_clock = 0.0; spawn_queue.clear(); enemies.clear(); towers.clear(); effects.clear(); selected_slot = ""; selected_tower = ""; robot_selected = false
	robot = {"active": false, "spot": "CENTER", "position": ROBOT_SPOTS.CENTER, "manual_position": false, "hp": DATA.ROBOT.hp, "commands": DATA.ROBOT.max_moves, "attack": 0.0, "area": 0.0, "pierce": 0.0, "flash": 0.0}
	robot_progression = {"unlocked_abilities": []}
	feed.clear(); log_event("Build towers, launch ATLAS-01, then start Wave 1.")

func log_event(text: String) -> void:
	feed.push_front(text); feed = feed.slice(0, 5); queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	if wave_running:
		spawn_clock += delta
		spawn_enemies()
		move_enemies(delta)
		update_towers(delta)
		update_robot(delta)
		check_wave_clear()
	if robot.get("active", false):
		robot["flash"] = max(0.0, float(robot.get("flash", 0.0)) - delta)
	for effect in effects:
		if effect.has("progress"):
			effect["progress"] = float(effect["progress"]) + delta * float(effect.get("speed", 4.0))
		else:
			effect["life"] = float(effect["life"]) - delta
	effects = effects.filter(func(item): return float(item.get("progress", 0.0)) < 1.0 and float(item.get("life", 1.0)) > 0.0)
	queue_redraw()

func start_wave() -> void:
	if run_state != RunState.READY or wave_running or base_hp <= 0.0 or wave > DATA.WAVES.size(): return
	if not robot.active:
		robot.hp = DATA.ROBOT.hp
		robot.active = true
		robot_selected = false
		log_event("ATLAS-01 deployed at %s." % robot.spot)
	spawn_queue.clear()
	var offset := 0.0
	for group in DATA.WAVES[wave - 1].groups:
		for index in range(group[1]):
			spawn_queue.append({"type": group[0], "delay": offset + index * group[2], "lanes": group[3]})
		offset += group[1] * group[2] + 0.3
	spawn_clock = 0.0; wave_running = true; run_state = RunState.RUNNING; wave_clear = false
	play_sfx("wave_start")
	log_event("WAVE %d STARTED: %s" % [wave, DATA.WAVES[wave - 1].label])

func spawn_enemies() -> void:
	while not spawn_queue.is_empty() and spawn_queue[0].delay <= spawn_clock:
		var entry = spawn_queue.pop_front()
		var lane: String = entry.lanes[enemies.size() % entry.lanes.size()]
		var data: Dictionary = DATA.ENEMIES[entry.type]
		enemies.append({"type": entry.type, "lane": lane, "position": LANES[lane], "hp": data.hp, "max_hp": data.hp, "flash": 0.0, "robot_attack_timer": 0.0})

func damage_robot(amount: float) -> void:
	if not robot.active: return
	robot.hp = max(0.0, robot.hp - amount)
	robot["flash"] = 0.12
	effects.append({"position": robot.position, "type": "giantHit", "life": 0.28})
	if robot.hp <= 0.0:
		robot.hp = 0.0; robot.active = false; robot_selected = false; log_event("ATLAS-01 destroyed. Base defense remains active.")

func update_giant_robot_attack(delta: float, enemy: Dictionary) -> void:
	if enemy.type != "giant" or not robot.active or robot.hp <= 0.0: return
	var data: Dictionary = DATA.ENEMIES[enemy.type]
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
		var data: Dictionary = DATA.ENEMIES[enemy.type]
		var start: Vector2 = LANES[enemy.lane]
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
	var data: Dictionary = DATA.ENEMIES[enemy.type]
	enemy.hp -= max(1.0, amount - data.armor); enemy.flash = 0.12
	effects.append({"position": enemy.position, "type": "impact_explosion", "life": 0.35, "max_life": 0.35})
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
	var lane_progress := {"left": -1.0, "right": -1.0}
	for enemy in enemies:
		if enemy.hp <= 0.0: continue
		var lane: String = enemy.lane
		var start: Vector2 = LANES[lane]
		var progress := clampf((enemy.position.x - start.x) / (BASE.x - start.x), 0.0, 1.0)
		lane_progress[lane] = maxf(float(lane_progress[lane]), progress)
	if lane_progress.left < 0.0 and lane_progress.right < 0.0: return ""
	if lane_progress.left >= 0.0 and lane_progress.right >= 0.0 and absf(lane_progress.left - lane_progress.right) < 0.12:
		return "CENTER"
	return "LEFT" if lane_progress.left > lane_progress.right else "RIGHT"

func move_robot_automatically(delta: float) -> void:
	if not wave_running: return
	var chase_target: Dictionary = get_robot_chase_target()
	if not chase_target.is_empty():
		var target_distance: float = robot.position.distance_to(chase_target.position)
		var engagement_distance: float = DATA.ROBOT.range
		if target_distance > engagement_distance:
			var chase_step: float = minf(DATA.ROBOT.speed * delta, target_distance - engagement_distance)
			robot.erase("target_pos")
			robot.position += robot.position.direction_to(chase_target.position) * chase_step
			return
		robot.erase("target_pos")
		return
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
		effects.append({"type": "proj_defender", "start": tower.position, "target": target.position, "progress": 0.0, "speed": 5.0})
		damage_enemy(target, tower.data.damage, tower.type); tower.cooldown = tower.data.cooldown

func update_robot(delta: float) -> void:
	if not robot.active or robot.hp <= 0.0: return
	move_robot_automatically(delta)
	robot.attack -= delta; robot.area -= delta; robot.pierce -= delta
	var target: Dictionary = get_robot_target()
	var heavy: Dictionary = get_robot_heavy_target()
	var unlocked_abilities: Array = robot_progression.get("unlocked_abilities", [])
	if unlocked_abilities.has("ability_area") and robot.area <= 0.0:
		var nearby: Array = enemies.filter(func(enemy): return enemy.hp > 0.0 and enemy.position.distance_to(robot.position) <= DATA.ROBOT.ability_area.radius)
		if nearby.size() >= DATA.ROBOT.ability_area.threshold:
			for enemy in nearby: damage_enemy(enemy, DATA.ROBOT.ability_area.damage, "area")
			effects.append({"position": robot.position, "type": "area", "life": 0.45}); robot.area = DATA.ROBOT.ability_area.cooldown
			log_event("ATLAS-01 used AREA ATTACK.")
	if unlocked_abilities.has("ability_heavy_pierce") and robot.pierce <= 0.0 and not heavy.is_empty():
		damage_enemy(heavy, DATA.ROBOT.ability_pierce.damage, "pierce"); robot.pierce = DATA.ROBOT.ability_pierce.cooldown
		log_event("ATLAS-01 used HEAVY PIERCE on %s." % DATA.ENEMIES[heavy.type].name)
	elif robot.attack <= 0.0 and not target.is_empty():
		effects.append({"type": "proj_defender", "start": robot.position, "target": target.position, "progress": 0.0, "speed": 5.5})
		damage_enemy(target, DATA.ROBOT.damage, "robot"); robot.attack = DATA.ROBOT.cooldown

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
	if wave < DATA.WAVES.size():
		log_event("Wave %d clear." % wave); wave += 1
		if available_robot_growths().is_empty():
			run_state = RunState.READY
			start_wave()
		else:
			run_state = RunState.GROWTH
			log_event("Choose one Robot ability before Wave %d." % wave)
	else:
		run_state = RunState.VICTORY
		log_event("VICTORY. ALL FOUR WAVES CLEAR. Press RESTART to repeat.")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_R:
		play_sfx("ui_click")
		reset_game()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT: handle_click(event.position)

func handle_click(point: Vector2) -> void:
	if Rect2(SIDEBAR_X + 20.0, 175, 145, 42).has_point(point): play_sfx("ui_click"); reset_game(); return
	if run_state == RunState.GROWTH:
		for ability_id in available_robot_growths():
			if GROWTH_OPTION_RECTS[ability_id].has_point(point):
				choose_robot_growth(ability_id)
				return
		return
	if Rect2(SIDEBAR_X + 20.0, 120, 145, 42).has_point(point): start_wave(); return
	if Rect2(SIDEBAR_X + 20.0, 250, 145, 42).has_point(point): launch_robot(); return
	if Rect2(SIDEBAR_X + 20.0, 305, 145, 42).has_point(point): build_tower("cannon"); return
	if Rect2(SIDEBAR_X + 20.0, 360, 145, 42).has_point(point): build_tower("gatling"); return
	for tower in towers:
		if point.distance_to(tower.position) < 24.0:
			selected_tower = tower.id; selected_slot = tower.id; robot_selected = false; play_sfx("tower_select"); queue_redraw(); return
	if robot.active and point.distance_to(robot.position) < 28.0:
		if robot_selected:
			robot_selected = false; play_sfx("ui_cancel")
		else:
			robot_selected = true; selected_tower = ""; selected_slot = ""; play_sfx("ui_click")
		queue_redraw(); return
	if robot_selected and Rect2(MAP_ORIGIN, MAP_PIXEL_SIZE).has_point(point):
		move_robot_to_position(point); return
	for id in SLOTS:
		if point.distance_to(SLOTS[id]) < 24.0 and not towers.any(func(tower): return tower.id == id): selected_slot = id; selected_tower = ""; robot_selected = false; play_sfx("tower_select"); queue_redraw(); return
	for id in ROBOT_SPOTS:
		if point.distance_to(ROBOT_SPOTS[id]) < 55.0:
			if robot_selected: move_robot(id)
			return
	if not selected_slot.is_empty() or not selected_tower.is_empty() or robot_selected: play_sfx("ui_cancel")
	selected_slot = ""; selected_tower = ""; robot_selected = false; queue_redraw()

func build_tower(type: String) -> void:
	if run_state not in [RunState.READY, RunState.RUNNING]: return
	if selected_slot.is_empty(): play_sfx("ui_error"); log_event("Select an empty tower slot first."); return
	if towers.any(func(tower): return tower.id == selected_slot): upgrade_tower(type); return
	if not DATA.TOWERS.has(type): play_sfx("ui_error"); return
	var data: Dictionary = DATA.TOWERS[type]
	if gold < data.cost: play_sfx("ui_error"); log_event("Need %d gold for %s." % [data.cost, data.name]); return
	gold -= data.cost; towers.append({"id": selected_slot, "type": type, "position": SLOTS[selected_slot], "data": data, "cooldown": 0.0}); play_sfx("tower_build"); log_event("%s deployed at %s." % [data.name, selected_slot]); selected_slot = ""; selected_tower = ""; robot_selected = false

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
	selected_slot = ""; selected_tower = ""; robot_selected = false; queue_redraw()

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
	draw_rect(Rect2(SIDEBAR_X, 0, 208, 860), Color("101f25"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 32), "MENOS // STRATEGIC BATTLE GRID", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("d7fff7"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 50), "NORTHBRIDGE SECTOR // 36x24 TACTICAL FIELD", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("7ed6ce"))

	# Tactical 32x32 Grid Overlay over 36x24 battlefield (1152x768)
	draw_rect(Rect2(MAP_ORIGIN, MAP_PIXEL_SIZE), Color("102b31", 0.55))
	draw_rect(Rect2(MAP_ORIGIN, Vector2(320, MAP_PIXEL_SIZE.y)), Color("ef7068", 0.08))
	draw_rect(Rect2(MAP_ORIGIN + Vector2(320, 0), Vector2(576, MAP_PIXEL_SIZE.y)), Color("7ed6ce", 0.07))
	draw_rect(Rect2(MAP_ORIGIN + Vector2(896, 0), Vector2(256, MAP_PIXEL_SIZE.y)), Color("f0a35a", 0.08))
	draw_string(ThemeDB.fallback_font, MAP_ORIGIN + Vector2(16, 24), "ENEMY APPROACH", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("ef7068", 0.85))
	draw_string(ThemeDB.fallback_font, MAP_ORIGIN + Vector2(336, 24), "ENGAGEMENT ZONE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("7ed6ce", 0.85))
	draw_string(ThemeDB.fallback_font, MAP_ORIGIN + Vector2(912, 24), "BASE DEFENSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("f0a35a", 0.85))
	var grid_color := Color("7ed6ce", 0.28)
	for gx in range(MAP_TILES.x + 1):
		var x_pos := MAP_ORIGIN.x + float(gx * 32)
		draw_line(Vector2(x_pos, MAP_ORIGIN.y), Vector2(x_pos, MAP_ORIGIN.y + MAP_PIXEL_SIZE.y), grid_color, 1.0)
	for gy in range(MAP_TILES.y + 1):
		var y_pos := MAP_ORIGIN.y + float(gy * 32)
		draw_line(Vector2(MAP_ORIGIN.x, y_pos), Vector2(MAP_ORIGIN.x + MAP_PIXEL_SIZE.x, y_pos), grid_color, 1.0)

	# Tactical Field Boundary
	draw_rect(Rect2(MAP_ORIGIN, MAP_PIXEL_SIZE), Color("7ed6ce"), false, 2)
	draw_string(ThemeDB.fallback_font, MAP_ORIGIN + Vector2(16, 56), "WEST MID GATE 01", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("ef7068"))
	draw_string(ThemeDB.fallback_font, MAP_ORIGIN + Vector2(176, MAP_PIXEL_SIZE.y - 16), "SOUTH QUARTER GATE 02", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("ef7068"))

	# Strategic Lanes & Waypoint Trails
	for lane in LANES.values():
		draw_line(lane, BASE, Color("1e343b", 0.8), 36)
		draw_dashed_line(lane, BASE, Color("7ed6ce", 0.6), 2.0, 10.0)
	draw_rect(Rect2(LANES.left - Vector2(8, 16), Vector2(16, 32)), Color("ef7068"))
	draw_rect(Rect2(LANES.right - Vector2(8, 16), Vector2(16, 32)), Color("ef7068"))

	# Base Facility (Strategic HQ Node)
	var base_feet := BASE + Vector2(0, 30)
	draw_oval(base_feet, 54.0, 16.0, Color(0, 0, 0, 0.5))
	draw_arc(base_feet, 56, 0, TAU, 32, Color("7ed6ce"), 2.5)
	draw_sprite(VISUALS["facility_base"], BASE, Vector2(112, 92))
	draw_string(ThemeDB.fallback_font, BASE + Vector2(-24, 64), "BASE HQ", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("7ed6ce"))

	# Tower Slots & Placed Towers (Strategic Node Bases)
	for id in SLOTS:
		var placed_tower: Dictionary = towers.filter(func(t): return t.id == id).front() if towers.any(func(t): return t.id == id) else {}
		var occupied := not placed_tower.is_empty()
		var slot_pos: Vector2 = SLOTS[id]
		var slot_feet := slot_pos + Vector2(0, 26)
		if not occupied:
			var slot_visual: Texture2D = VISUALS["slot_selected"] if selected_slot == id else VISUALS["slot_empty"]
			draw_oval(slot_feet, 30.0, 10.0, Color(0, 0, 0, 0.35))
			draw_arc(slot_feet, 32.0, 0, TAU, 24, Color("f0a35a" if selected_slot == id else "6a858a"), 2.0)
			draw_sprite(slot_visual, slot_pos, Vector2(76, 76))
		else:
			var anim_key := "tower_cannon_anim" if placed_tower.type == "cannon" else "tower_gatling_anim"
			var cd_left: float = float(placed_tower.get("cooldown", 0.0))
			var max_cd: float = float(placed_tower.get("data", {}).get("cooldown", 0.6))
			var is_firing: bool = cd_left > (max_cd - 0.25)
			var frame_idx := 0
			if is_firing:
				var fire_progress: float = 1.0 - clampf((cd_left - (max_cd - 0.25)) / 0.25, 0.0, 1.0)
				frame_idx = int(fire_progress * 4.0) % 4
			draw_oval(slot_feet, 28.0, 10.0, Color(0, 0, 0, 0.45))
			draw_arc(slot_feet, 30.0, 0, TAU, 24, Color("7ed6ce" if placed_tower.type == "cannon" else "f0a35a"), 2.5)
			draw_animated_sprite(VISUALS[anim_key], slot_pos, Vector2(60, 90), frame_idx, 4)
			if selected_tower == id: draw_arc(slot_feet, 38.0, 0, TAU, 24, Color("d7fff7"), 2.0)
		draw_string(ThemeDB.fallback_font, slot_pos + Vector2(-10, 54), id, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("a9c5c7"))

	# Robot Movement Spots
	for id in ROBOT_SPOTS:
		var spot_pos: Vector2 = ROBOT_SPOTS[id]
		var is_current: bool = robot.active and robot.spot == id
		draw_arc(spot_pos, 28, 0, TAU, 16, Color("7ed6ce", 0.5) if not is_current else Color("f0a35a"), 2.0 if is_current else 1.0)
		draw_string(ThemeDB.fallback_font, spot_pos + Vector2(-24, 42), id, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("7ed6ce"))

	# Enemy Units (High Contrast Strategic Visibility)
	for enemy in enemies:
		if enemy.hp <= 0.0: continue
		var data: Dictionary = DATA.ENEMIES[enemy.type]
		var enemy_size: Vector2 = ENEMY_SPRITE_SIZES[enemy.type]
		
		# Strategic Base Indicator at Enemy Feet (drawn BEFORE sprite so feet sit inside base ring)
		var feet_pos: Vector2 = enemy.position + Vector2(0, enemy_size.y * 0.48)
		draw_oval(feet_pos, enemy_size.x * 0.55, 9.0, Color(0, 0, 0, 0.5))
		draw_arc(feet_pos, enemy_size.x * 0.55, 0, TAU, 16, Color("ef7068", 0.9), 2.5)
		
		if enemy.flash > 0.0: draw_circle(enemy.position, data.radius + 4, Color.WHITE)
		var anim_key: String = "enemy_" + enemy.type + "_anim"
		var fps: float = 14.0 if enemy.type == "rusher" else (6.0 if enemy.type == "giant" else 10.0)
		var e_frame: int = int((elapsed + float(enemy.position.x)) * fps) % 8
		draw_animated_sprite(VISUALS[anim_key], enemy.position, enemy_size, e_frame, 8)
		
		# Strategic HP Bar
		var hp_position: Vector2 = enemy.position + Vector2(-enemy_size.x * 0.5, -enemy_size.y * 0.5 - 9)
		draw_string(ThemeDB.fallback_font, hp_position + Vector2(0, -5), data.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("ffd6d1"))
		draw_rect(Rect2(hp_position - Vector2(1, 1), Vector2(enemy_size.x + 2, 6)), Color("101f25"))
		draw_rect(Rect2(hp_position, Vector2(enemy_size.x, 4)), Color("3a1c1a"))
		draw_rect(Rect2(hp_position, Vector2(enemy_size.x * max(0.0, enemy.hp / enemy.max_hp), 4)), Color("ef7068"))

	# Effects
	for effect in effects:
		var etype: String = str(effect.get("type", ""))
		if etype == "giantHit":
			draw_arc(effect.position, 35.0, 0, TAU, 16, Color("ef7068"), 3.0)
		elif etype == "impact_explosion" or etype in ["cannon", "gatling", "robot", "area", "pierce"]:
			var life_progress: float = 1.0 - clampf(float(effect.get("life", 0.0)) / max(0.01, float(effect.get("max_life", 0.35))), 0.0, 1.0)
			var frame_idx: int = int(life_progress * 8.0) % 8
			draw_animated_sprite(VISUALS["impact_explosion"], effect.position, Vector2(54, 54), frame_idx, 8)
		elif etype == "proj_defender":
			var progress: float = clampf(float(effect.get("progress", 0.0)), 0.0, 1.0)
			var start_p: Vector2 = effect.get("start", Vector2.ZERO)
			var end_p: Vector2 = effect.get("target", Vector2.ZERO)
			var current_p: Vector2 = start_p.lerp(end_p, progress)
			var angle: float = start_p.angle_to_point(end_p) + PI / 2.0
			var p_frame: int = int(elapsed * 18.0) % 8
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
		var r_feet_pos: Vector2 = robot.position + Vector2(0, 52)
		draw_oval(r_feet_pos, 42.0, 12.0, Color(0, 0, 0, 0.5))
		draw_arc(r_feet_pos, 42.0, 0, TAU, 24, Color("ef7068") if is_flashing else Color("7ed6ce"), 2.5)
		if robot_selected:
			draw_arc(r_feet_pos, 52.0, 0, TAU, 24, Color("f0a35a"), 2.0)
			draw_line(r_feet_pos - Vector2(60, 0), r_feet_pos + Vector2(60, 0), Color("f0a35a", 0.6), 1.5)
			draw_line(r_feet_pos - Vector2(0, 18), r_feet_pos + Vector2(0, 18), Color("f0a35a", 0.6), 1.5)
		
		if is_flashing: draw_circle(robot.position, 34, Color("ef7068", 0.35))
		var anim_key := "atlas_idle"
		var total_f := 6
		var fps := 8.0
		if float(robot.get("attack", 0.0)) > 0.3:
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
		draw_animated_sprite(VISUALS[anim_key], robot.position, Vector2(64, 114), r_frame, total_f)
		
		# Player Robot Unit HP Bar
		var r_hp_pos: Vector2 = robot.position + Vector2(-32, -66)
		draw_rect(Rect2(r_hp_pos - Vector2(1, 1), Vector2(66, 6)), Color("101f25"))
		draw_rect(Rect2(r_hp_pos, Vector2(64, 4)), Color("1c3e38"))
		draw_rect(Rect2(r_hp_pos, Vector2(64 * max(0.0, robot.hp / DATA.ROBOT.hp), 4)), Color("7ed6ce"))

	draw_ui()




func draw_ui() -> void:
	draw_rect(Rect2(SIDEBAR_X, 0, 208, 860), Color("101f25")); draw_string(ThemeDB.fallback_font, Vector2(SIDEBAR_X + 20.0, 42), "FIELD CONTROL", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("d7fff7"))
	draw_string(ThemeDB.fallback_font, Vector2(SIDEBAR_X + 20.0, 78), "BASE HP  %03d" % max(0, ceil(base_hp)), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("92d28b") if base_hp > 30 else Color("ef7068")); draw_string(ThemeDB.fallback_font, Vector2(SIDEBAR_X + 20.0, 101), "GOLD     %03d" % gold, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("f0b35a")); draw_string(ThemeDB.fallback_font, Vector2(SIDEBAR_X + 20.0, 124), "WAVE     %d / 4" % wave, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("d7fff7"))
	var next_label: String = DATA.WAVES[min(wave - 1, 3)].label; draw_string(ThemeDB.fallback_font, Vector2(SIDEBAR_X + 20.0, 470), "NEXT THREAT", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("6a858a")); draw_string(ThemeDB.fallback_font, Vector2(SIDEBAR_X + 20.0, 491), next_label, HORIZONTAL_ALIGNMENT_LEFT, 165, 11, Color("a9c5c7"))
	var status_text := "READY"
	if run_state == RunState.RUNNING: status_text = "WAVE %d IN PROGRESS" % wave
	elif run_state == RunState.GROWTH: status_text = "SELECT ROBOT ABILITY"
	elif run_state == RunState.VICTORY: status_text = "VICTORY"
	elif run_state == RunState.DEFEAT: status_text = "DEFEAT"
	if run_state == RunState.VICTORY: draw_sprite(VISUALS["status_victory"], Vector2(SIDEBAR_X + 127.0, 585), Vector2(48, 48))
	elif run_state == RunState.DEFEAT: draw_sprite(VISUALS["status_defeat"], Vector2(SIDEBAR_X + 127.0, 585), Vector2(48, 48))
	draw_string(ThemeDB.fallback_font, Vector2(SIDEBAR_X + 20.0, 585), status_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("92d28b") if run_state == RunState.VICTORY else Color("ef7068") if run_state == RunState.DEFEAT else Color("d7fff7"))
	button(Rect2(SIDEBAR_X + 20.0, 120, 145, 42), "START WAVE %d" % wave, run_state != RunState.READY); button(Rect2(SIDEBAR_X + 20.0, 175, 145, 42), "RESTART", false); button(Rect2(SIDEBAR_X + 20.0, 250, 145, 42), "LAUNCH ROBOT", not can_launch_robot()); button(Rect2(SIDEBAR_X + 20.0, 305, 145, 42), "BUILD CANNON  55", run_state not in [RunState.READY, RunState.RUNNING]); button(Rect2(SIDEBAR_X + 20.0, 360, 145, 42), "BUILD GATLING 35", run_state not in [RunState.READY, RunState.RUNNING])
	var robot_status := "DOCKED"
	if robot.active: robot_status = "DEPLOYED / " + robot.spot
	if robot_selected: robot_status += " / SELECTED"
	draw_string(ThemeDB.fallback_font, Vector2(SIDEBAR_X + 20.0, 535), "ATLAS-01  " + robot_status, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("7ed6ce"))
	draw_string(ThemeDB.fallback_font, Vector2(SIDEBAR_X + 20.0, 557), "HP %03d   MOVES ∞" % max(0, ceil(robot.hp)), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("a9c5c7"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 850), "CLICK TOWER / ROBOT TO SELECT  /  SELECT ROBOT, THEN CLICK DESTINATION  /  R TO RESTART", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("6a858a"))
	for index in range(feed.size()): draw_string(ThemeDB.fallback_font, Vector2(SIDEBAR_X + 20.0, 650 + index * 20), feed[index], HORIZONTAL_ALIGNMENT_LEFT, 165, 11, Color("a9c5c7"))
	if run_state == RunState.GROWTH: draw_robot_growth_choice()

func draw_robot_growth_choice() -> void:
	draw_rect(Rect2(145, 250, 690, 185), Color("101f25"))
	draw_rect(Rect2(145, 250, 690, 185), Color("7ed6ce"), false, 2)
	draw_string(ThemeDB.fallback_font, Vector2(185, 285), "WAVE CLEAR  /  SELECT ONE ROBOT ABILITY", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d7fff7"))
	for ability_id in available_robot_growths():
		var option: Dictionary = ROBOT_GROWTH_OPTIONS[ability_id]
		var rect: Rect2 = GROWTH_OPTION_RECTS[ability_id]
		button(rect, "UNLOCK " + option["name"], false)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, 55), option["description"], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 20, 11, Color("a9c5c7"))

func button(rect: Rect2, label: String, disabled: bool) -> void:
	draw_rect(rect, Color("263c43") if disabled else Color("1d4a4e")); draw_rect(rect, Color("527079"), false, 1); draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, 26), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("6a858a") if disabled else Color("d7fff7"))
