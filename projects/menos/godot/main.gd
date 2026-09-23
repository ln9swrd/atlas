extends Node2D

const DATA = preload("res://data.gd")
const BASE := Vector2(790, 330)
const LANES := {"left": Vector2(70, 180), "right": Vector2(70, 480)}
const ROBOT_SPOTS := {"LEFT": Vector2(360, 245), "CENTER": Vector2(555, 330), "RIGHT": Vector2(360, 415)}
const SLOTS := {"L1": Vector2(250, 110), "L2": Vector2(430, 190), "L3": Vector2(650, 235), "R1": Vector2(250, 550), "R2": Vector2(430, 470), "R3": Vector2(650, 425)}
enum RunState { READY, RUNNING, VICTORY, DEFEAT }

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
var feed: Array[String] = []
var selected_slot := ""
var effects: Array = []

func _ready() -> void:
	reset_game()
	queue_redraw()

func reset_game() -> void:
	base_hp = 100.0; gold = 180; wave = 1; run_state = RunState.READY; wave_running = false; wave_clear = false; elapsed = 0.0
	spawn_clock = 0.0; spawn_queue.clear(); enemies.clear(); towers.clear(); effects.clear(); selected_slot = ""
	robot = {"active": false, "spot": "CENTER", "position": ROBOT_SPOTS.CENTER, "hp": DATA.ROBOT.hp, "commands": DATA.ROBOT.max_moves, "attack": 0.0, "area": 0.0, "pierce": 0.0, "flash": 0.0}
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
		effect.life -= delta
	effects = effects.filter(func(item): return item.life > 0.0)
	queue_redraw()

func start_wave() -> void:
	if run_state != RunState.READY or wave_running or base_hp <= 0.0 or wave > DATA.WAVES.size(): return
	spawn_queue.clear()
	var offset := 0.0
	for group in DATA.WAVES[wave - 1].groups:
		for index in range(group[1]):
			spawn_queue.append({"type": group[0], "delay": offset + index * group[2], "lanes": group[3]})
		offset += group[1] * group[2] + 0.3
	spawn_clock = 0.0; wave_running = true; run_state = RunState.RUNNING; wave_clear = false
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
		robot.hp = 0.0; robot.active = false; log_event("ATLAS-01 destroyed. Base defense remains active.")

func update_giant_robot_attack(delta: float, enemy: Dictionary) -> void:
	if enemy.type != "giant" or not robot.active or robot.hp <= 0.0: return
	var data: Dictionary = DATA.ENEMIES[enemy.type]
	enemy.robot_attack_timer -= delta
	if enemy.position.distance_to(robot.position) > data.robot_range: return
	if enemy.robot_attack_timer > 0.0: return
	damage_robot(data.robot_damage)
	enemy.robot_attack_timer = data.robot_cooldown
	if robot.active:
		log_event("GIANT hit ATLAS-01 for %d damage." % int(data.robot_damage))

func move_enemies(delta: float) -> void:
	for enemy in enemies:
		if enemy.hp <= 0.0: continue
		var data: Dictionary = DATA.ENEMIES[enemy.type]
		var start: Vector2 = LANES[enemy.lane]
		var progress: float = clampf(enemy.position.x / BASE.x, 0.0, 1.0)
		enemy.position.x += data.speed * delta
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
	effects.append({"position": enemy.position, "type": source, "life": 0.25})
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

func update_towers(delta: float) -> void:
	for tower in towers:
		tower.cooldown -= delta
		if tower.cooldown > 0.0: continue
		var target: Dictionary = find_target(tower.position, tower.data.range, tower.data.preference)
		if target.is_empty(): continue
		damage_enemy(target, tower.data.damage, tower.type); tower.cooldown = tower.data.cooldown

func update_robot(delta: float) -> void:
	if not robot.active or robot.hp <= 0.0: return
	robot.attack -= delta; robot.area -= delta; robot.pierce -= delta
	var target: Dictionary = find_target(robot.position, DATA.ROBOT.range)
	var heavy: Dictionary = find_target(robot.position, DATA.ROBOT.range + 20.0, "heavy")
	if robot.area <= 0.0:
		var nearby: Array = enemies.filter(func(enemy): return enemy.hp > 0.0 and enemy.position.distance_to(robot.position) <= DATA.ROBOT.ability_area.radius)
		if nearby.size() >= DATA.ROBOT.ability_area.threshold:
			for enemy in nearby: damage_enemy(enemy, DATA.ROBOT.ability_area.damage, "area")
			effects.append({"position": robot.position, "type": "area", "life": 0.45}); robot.area = DATA.ROBOT.ability_area.cooldown
			log_event("ATLAS-01 used AREA ATTACK.")
	if robot.pierce <= 0.0 and not heavy.is_empty():
		damage_enemy(heavy, DATA.ROBOT.ability_pierce.damage, "pierce"); robot.pierce = DATA.ROBOT.ability_pierce.cooldown
		log_event("ATLAS-01 used HEAVY PIERCE on %s." % DATA.ENEMIES[heavy.type].name)
	elif robot.attack <= 0.0 and not target.is_empty():
		damage_enemy(target, DATA.ROBOT.damage, "robot"); robot.attack = DATA.ROBOT.cooldown

func check_wave_clear() -> void:
	if run_state == RunState.DEFEAT or run_state == RunState.VICTORY or not wave_running: return
	if not spawn_queue.is_empty() or enemies.any(func(enemy): return enemy.hp > 0.0): return
	wave_running = false; wave_clear = true
	if wave < DATA.WAVES.size():
		run_state = RunState.READY
		log_event("Wave clear. Next: %s" % DATA.WAVES[wave].label); wave += 1
	else:
		run_state = RunState.VICTORY
		log_event("VICTORY. ALL FOUR WAVES CLEAR. Press RESTART to repeat.")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_R: reset_game()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT: handle_click(event.position)

func handle_click(point: Vector2) -> void:
	if Rect2(920, 120, 145, 42).has_point(point): start_wave(); return
	if Rect2(920, 175, 145, 42).has_point(point): reset_game(); return
	if Rect2(920, 250, 145, 42).has_point(point): launch_robot(); return
	if Rect2(920, 305, 145, 42).has_point(point): build_tower("cannon"); return
	if Rect2(920, 360, 145, 42).has_point(point): build_tower("gatling"); return
	for id in SLOTS:
		if point.distance_to(SLOTS[id]) < 24.0 and not towers.any(func(tower): return tower.id == id): selected_slot = id; return
	for id in ROBOT_SPOTS:
		if point.distance_to(ROBOT_SPOTS[id]) < 55.0: move_robot(id); return

func build_tower(type: String) -> void:
	if run_state != RunState.READY: return
	if selected_slot.is_empty(): log_event("Select an empty tower slot first."); return
	if towers.any(func(tower): return tower.id == selected_slot): return
	var data: Dictionary = DATA.TOWERS[type]
	if gold < data.cost: log_event("Need %d gold for %s." % [data.cost, data.name]); return
	gold -= data.cost; towers.append({"id": selected_slot, "type": type, "position": SLOTS[selected_slot], "data": data, "cooldown": 0.0}); log_event("%s deployed at %s." % [data.name, selected_slot]); selected_slot = ""

func launch_robot() -> void:
	if not can_launch_robot(): return
	robot.hp = DATA.ROBOT.hp
	robot.active = true; log_event("ATLAS-01 launched at %s. Choose a crisis zone." % robot.spot)

func can_launch_robot() -> bool:
	return not robot.active and run_state in [RunState.READY, RunState.RUNNING]

func move_robot(id: String) -> void:
	if not robot.active or robot.commands <= 0 or robot.spot == id: return
	robot.spot = id; robot.position = ROBOT_SPOTS[id]; robot.commands -= 1; log_event("ATLAS-01 moved to %s. %d commands remain." % [id, robot.commands])

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1100, 700), Color("091419"))
	for x in range(0, 900, 32): draw_line(Vector2(x, 0), Vector2(x, 700), Color("13282d"), 1)
	for y in range(0, 700, 32): draw_line(Vector2(0, y), Vector2(900, y), Color("13282d"), 1)
	draw_string(ThemeDB.fallback_font, Vector2(30, 35), "MENOS // TACTICAL DEFENSE PoC", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("d7fff7"))
	for lane in LANES.values(): draw_line(lane, BASE, Color("263c43"), 32); draw_line(lane, BASE, Color("527079"), 1)
	draw_circle(BASE, 38, Color("18353a")); draw_arc(BASE, 38, 0, TAU, 32, Color("7ed6ce"), 2); draw_string(ThemeDB.fallback_font, BASE + Vector2(-22, 58), "BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("7ed6ce"))
	for id in SLOTS:
		var occupied := towers.any(func(tower): return tower.id == id)
		if not occupied: draw_arc(SLOTS[id], 18, 0, TAU, 20, Color("f0a35a") if selected_slot == id else Color("6a858a"), 2)
		else: draw_circle(SLOTS[id], 15, Color("f0a35a") if towers.filter(func(tower): return tower.id == id)[0].type == "cannon" else Color("7ed6ce"))
		draw_string(ThemeDB.fallback_font, SLOTS[id] + Vector2(-10, 4), id, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("a9c5c7"))
	for id in ROBOT_SPOTS: draw_string(ThemeDB.fallback_font, ROBOT_SPOTS[id] + Vector2(-24, 58), id, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("7ed6ce"))
	for enemy in enemies:
		if enemy.hp <= 0.0: continue
		var data: Dictionary = DATA.ENEMIES[enemy.type]; draw_circle(enemy.position, data.radius, Color.WHITE if enemy.flash > 0.0 else data.color); draw_rect(Rect2(enemy.position - Vector2(data.radius, data.radius + 8), Vector2(data.radius * 2, 4)), Color("263238")); draw_rect(Rect2(enemy.position - Vector2(data.radius, data.radius + 8), Vector2(data.radius * 2 * max(0.0, enemy.hp / enemy.max_hp), 4)), Color("92d28b"))
	for effect in effects:
		if effect.get("type", "") == "giantHit":
			draw_arc(effect.position, 35.0, 0, TAU, 16, Color("ef7068"), 3.0)
	if robot.active:
		var is_flashing: bool = float(robot.get("flash", 0.0)) > 0.0
		draw_circle(robot.position, 22, Color.WHITE if is_flashing else Color("7ed6ce"))
		draw_arc(robot.position, 28, 0, TAU, 6, Color("ef7068") if is_flashing else Color("d7fff7"), 3 if is_flashing else 2)
	draw_ui()

func draw_ui() -> void:
	draw_rect(Rect2(900, 0, 200, 700), Color("101f25")); draw_string(ThemeDB.fallback_font, Vector2(920, 42), "FIELD CONTROL", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("d7fff7"))
	draw_string(ThemeDB.fallback_font, Vector2(920, 78), "BASE HP  %03d" % max(0, ceil(base_hp)), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("92d28b") if base_hp > 30 else Color("ef7068")); draw_string(ThemeDB.fallback_font, Vector2(920, 101), "GOLD     %03d" % gold, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("f0b35a")); draw_string(ThemeDB.fallback_font, Vector2(920, 124), "WAVE     %d / 4" % wave, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("d7fff7"))
	var next_label: String = DATA.WAVES[min(wave - 1, 3)].label; draw_string(ThemeDB.fallback_font, Vector2(920, 470), "NEXT THREAT", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("6a858a")); draw_string(ThemeDB.fallback_font, Vector2(920, 491), next_label, HORIZONTAL_ALIGNMENT_LEFT, 165, 11, Color("a9c5c7"))
	var status_text := "READY"
	if run_state == RunState.RUNNING: status_text = "WAVE %d IN PROGRESS" % wave
	elif run_state == RunState.VICTORY: status_text = "VICTORY"
	elif run_state == RunState.DEFEAT: status_text = "DEFEAT"
	draw_string(ThemeDB.fallback_font, Vector2(920, 585), status_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("92d28b") if run_state == RunState.VICTORY else Color("ef7068") if run_state == RunState.DEFEAT else Color("d7fff7"))
	button(Rect2(920, 120, 145, 42), "START WAVE %d" % wave, run_state != RunState.READY); button(Rect2(920, 175, 145, 42), "RESTART", false); button(Rect2(920, 250, 145, 42), "LAUNCH ROBOT", not can_launch_robot()); button(Rect2(920, 305, 145, 42), "BUILD CANNON  55", run_state != RunState.READY); button(Rect2(920, 360, 145, 42), "BUILD GATLING 35", run_state != RunState.READY)
	draw_string(ThemeDB.fallback_font, Vector2(920, 535), "ATLAS-01  %s" % ("DEPLOYED / " + robot.spot if robot.active else "DOCKED"), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("7ed6ce")); draw_string(ThemeDB.fallback_font, Vector2(920, 557), "HP %03d   MOVES %d" % [max(0, ceil(robot.hp)), robot.commands], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("a9c5c7"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 665), "CLICK SLOTS TO SELECT  /  CLICK LEFT CENTER RIGHT TO MOVE  /  R TO RESTART", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("6a858a"))
	for index in range(feed.size()): draw_string(ThemeDB.fallback_font, Vector2(30, 590 - index * 20), feed[index], HORIZONTAL_ALIGNMENT_LEFT, 820, 12, Color("a9c5c7"))

func button(rect: Rect2, label: String, disabled: bool) -> void:
	draw_rect(rect, Color("263c43") if disabled else Color("1d4a4e")); draw_rect(rect, Color("527079"), false, 1); draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, 26), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("6a858a") if disabled else Color("d7fff7"))
