extends SceneTree

const PROFILE_PATH := "user://menos_campaign_robot_profile.json"
const LEGACY_PROFILE_TABLE := "player_profile"
const LEGACY_PROFILE_ID := "campaign_robot_profile"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if OS.get_cmdline_user_args().has("--verify-profile"):
		var profile := PlayerProfileRepository.load_profile()
		if not _require(
			profile.get("level") == 8
			and profile.get("xp") == 56
			and profile.get("gold") == 91
			and profile.get("completed_stage_ids", []) == ["stage_01"]
			and profile.get("unlocked_stage_ids", []) == ["stage_01", "stage_02"]
			and profile.get("inventory", []) == [{"id": "legacy_item"}],
			"profile progression did not survive a separate process"
		):
			return
		print("P1_2_SEPARATE_PROCESS_PROFILE_PASS")
		quit(0)
		return
	if not _test_profile_persistence():
		return
	if not _test_stage_reference_validation():
		return
	if not await _test_mission_completion():
		return
	print("GAMEPLAY_P1_REGRESSION_PASS")
	quit(0)

func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("GAMEPLAY_P1_REGRESSION_FAIL: %s" % message)
	quit(1)
	return false

func _test_profile_persistence() -> bool:
	var profile_path := ProjectSettings.globalize_path(PROFILE_PATH)
	if FileAccess.file_exists(PROFILE_PATH):
		if not _require(DirAccess.remove_absolute(profile_path) == OK, "could not isolate the user profile fixture"):
			return false
	var legacy_profile := {
		"level": 7,
		"xp": 42,
		"unlocked_abilities": ["legacy_skill"],
		"unlocked_stage_ids": ["stage_01", "stage_02"],
		"completed_stage_ids": ["stage_01"],
		"gold": 91,
		"inventory": [{"id": "legacy_item"}],
		"equipped_items": {"weapon": "legacy_item"}
	}
	var db = SQLite.new()
	db.path = PlayerProfileRepository.SQLITE_PATH
	db.read_only = false
	db.verbosity_level = 0
	if not _require(db.open_db(), "could not open isolated fixture database"):
		return false
	if not _require(db.query('CREATE TABLE IF NOT EXISTS "%s" (document_id TEXT PRIMARY KEY, raw_json TEXT NOT NULL)' % LEGACY_PROFILE_TABLE), "could not prepare legacy profile fixture"):
		db.close_db()
		return false
	if not _require(db.query_with_bindings(
		'INSERT INTO "%s" (document_id, raw_json) VALUES (?, ?) ON CONFLICT(document_id) DO UPDATE SET raw_json = excluded.raw_json' % LEGACY_PROFILE_TABLE,
		[LEGACY_PROFILE_ID, JSON.stringify(legacy_profile)]
	), "could not seed isolated legacy profile"):
		db.close_db()
		return false
	db.close_db()

	var imported := PlayerProfileRepository.load_profile()
	if not _require(imported.get("level") == 7 and imported.get("xp") == 42 and imported.get("gold") == 91 and imported.get("completed_stage_ids", []) == ["stage_01"], "legacy profile fields did not import"):
		return false
	if not _require(FileAccess.file_exists(PROFILE_PATH), "legacy import did not create user profile"):
		return false

	db = SQLite.new()
	db.path = PlayerProfileRepository.SQLITE_PATH
	db.read_only = false
	db.verbosity_level = 0
	if not _require(db.open_db(), "could not reopen isolated fixture database"):
		return false
	var changed_legacy := legacy_profile.duplicate(true)
	changed_legacy["level"] = 99
	if not _require(db.query_with_bindings(
		'UPDATE "%s" SET raw_json = ? WHERE document_id = ?' % LEGACY_PROFILE_TABLE,
		[JSON.stringify(changed_legacy), LEGACY_PROFILE_ID]
	), "could not update isolated legacy profile fixture"):
		db.close_db()
		return false
	db.close_db()
	if not _require(PlayerProfileRepository.load_profile().get("level") == 7, "legacy data was re-imported over the user profile"):
		return false

	var updated_profile := imported.duplicate(true)
	updated_profile["level"] = 8
	updated_profile["xp"] = 56
	if not _require(PlayerProfileRepository.save_profile(updated_profile), "could not save user profile"):
		return false
	var reloaded := PlayerProfileRepository.load_profile()
	if not _require(
		reloaded.get("level") == 8
		and reloaded.get("xp") == 56
		and reloaded.get("gold") == 91
		and reloaded.get("completed_stage_ids", []) == ["stage_01"],
		"user profile did not survive reload"
	):
		return false
	var child_output: Array = []
	var child_exit_code := OS.execute(
		OS.get_executable_path(),
		[
			"--headless",
			"--path",
			ProjectSettings.globalize_path("res://"),
			"--script",
			"res://tests/gameplay_p1_regression_smoke_test.gd",
			"--",
			"--verify-profile"
		],
		child_output,
		true
	)
	if not _require(
		child_exit_code == 0 and str(child_output).contains("P1_2_SEPARATE_PROCESS_PROFILE_PASS"),
		"profile did not survive a separate Godot process"
	):
		return false

	var corrupt_file := FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	if not _require(corrupt_file != null, "could not create corrupt profile fixture"):
		return false
	corrupt_file.store_string("{")
	corrupt_file.close()
	if not _require(PlayerProfileRepository.load_profile().is_empty(), "corrupt profile did not return a safe empty state"):
		return false
	var preserved_corrupt := FileAccess.open(PROFILE_PATH, FileAccess.READ)
	if not _require(preserved_corrupt != null, "corrupt profile was unexpectedly removed"):
		return false
	var corrupt_payload := preserved_corrupt.get_as_text()
	preserved_corrupt.close()
	if not _require(corrupt_payload == "{", "corrupt profile was overwritten"):
		return false

	if not _require(DirAccess.remove_absolute(profile_path) == OK, "could not clear corrupt profile fixture"):
		return false
	db = SQLite.new()
	db.path = PlayerProfileRepository.SQLITE_PATH
	db.read_only = false
	db.verbosity_level = 0
	if not _require(db.open_db(), "could not reopen isolated fixture database for cleanup"):
		return false
	if not _require(db.query_with_bindings('DELETE FROM "%s" WHERE document_id = ?' % LEGACY_PROFILE_TABLE, [LEGACY_PROFILE_ID]), "could not clear legacy profile fixture"):
		db.close_db()
		return false
	db.close_db()
	if not _require(PlayerProfileRepository.load_profile().is_empty(), "missing profile without legacy data did not return an empty state"):
		return false
	print("P1_2_PROFILE_PERSISTENCE_PASS")
	return true

func _test_stage_reference_validation() -> bool:
	var stage_data := ContentCatalogLoader.load_document("stage_01")
	if not _require(not stage_data.is_empty(), "could not load baseline Stage fixture"):
		return false
	if not _require(not StageLoader.load_stage_data("stage_01").is_empty(), "valid baseline Stage failed runtime validation"):
		return false
	if not _require(StageManager.validate_campaign(), "valid baseline Campaign failed runtime validation"):
		return false

	var unknown_enemy := stage_data.duplicate(true)
	var enemy_group: Array = unknown_enemy["encounters"][0]["waves"][0]["groups"][0]
	enemy_group[0] = "__unknown_enemy__"
	if not _require(StageLoader.parse_and_validate_raw_data(unknown_enemy, "fixture_unknown_enemy").is_empty(), "unknown Enemy did not fail Stage validation"):
		return false

	var unknown_lane := stage_data.duplicate(true)
	var lane_group: Array = unknown_lane["encounters"][0]["waves"][0]["groups"][0]
	lane_group[3] = ["__unknown_lane__"]
	if not _require(StageLoader.parse_and_validate_raw_data(unknown_lane, "fixture_unknown_lane").is_empty(), "unknown Lane did not fail Stage validation"):
		return false

	var unknown_map := stage_data.duplicate(true)
	unknown_map["map_file"] = "__unknown_map__"
	if not _require(StageLoader.parse_and_validate_raw_data(unknown_map, "fixture_unknown_map").is_empty(), "unknown Map did not fail Stage validation"):
		return false
	print("P1_4_STAGE_REFERENCE_VALIDATION_PASS")
	return true

func _test_mission_completion() -> bool:
	StageManager.begin_run("single", "stage_01")
	var main_scene: PackedScene = load("res://main.tscn")
	if not _require(main_scene != null, "could not load gameplay scene"):
		return false
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var controller = main.get_node_or_null("GameController")
	if not _require(controller != null, "GameController failed to instantiate"):
		return false
	if not _require(controller._runtime_stage_load_error.is_empty(), "valid Stage failed to enter Runtime"):
		return false

	controller.mission_definition = MissionDefinition.new("fixture_giant", "Giant Objective")
	controller.mission_definition.primary_type = "defeat_giant"
	controller.encounter = StageManager.get_encounters().size()
	controller.wave = StageManager.get_waves(controller.encounter - 1).size()
	controller.run_state = controller.RunState.RUNNING
	controller.wave_running = true
	controller.spawn_queue.clear()
	controller.enemies.clear()
	controller._completed_mission_stage_id = ""
	controller._mission_objective_failed = false
	controller.check_wave_clear()
	if not _require(controller.run_state == controller.RunState.DEFEAT and controller._mission_objective_failed, "unmet Giant mission did not stop with an objective failure"):
		return false
	if not _require(StageManager.current_stage_id == "stage_01" and not controller.stage_reward_granted, "unmet Giant mission advanced or granted rewards"):
		return false
	print("P1_3_GIANT_REQUIRED_PASS")

	controller.restart_run()
	controller.mission_definition = MissionDefinition.new("fixture_giant", "Giant Objective")
	controller.mission_definition.primary_type = "defeat_giant"
	var giant: EnemyRuntimeState = EnemyRuntimeState.create("giant", "left", Vector2.ZERO, 10.0)
	controller.enemies.append(giant)
	controller.damage_enemy(giant, 1000.0, "p1_test")
	if not _require(controller.run_state == controller.RunState.VICTORY and controller._completed_mission_stage_id == "stage_01", "Giant defeat did not resolve the mission"):
		return false
	var completed_stage: String = controller._completed_mission_stage_id
	controller.damage_enemy(giant, 1000.0, "p1_test_duplicate")
	if not _require(controller._completed_mission_stage_id == completed_stage and not controller.stage_reward_granted, "duplicate Giant defeat changed the completed Stage"):
		return false

	controller.restart_run()
	controller.mission_definition = MissionDefinition.new("fixture_clear", "Clear Objective")
	controller.mission_definition.primary_type = "clear_encounters"
	controller.encounter = StageManager.get_encounters().size()
	controller.wave = StageManager.get_waves(controller.encounter - 1).size()
	controller.run_state = controller.RunState.RUNNING
	controller.wave_running = true
	controller.spawn_queue.clear()
	controller.enemies.clear()
	controller.check_wave_clear()
	if not _require(controller.run_state == controller.RunState.VICTORY, "clear_encounters progression regressed"):
		return false

	controller.restart_run()
	controller.mission_definition = MissionDefinition.new("fixture_defend", "Defense Objective")
	controller.mission_definition.primary_type = "defend_base"
	controller.run_state = controller.RunState.RUNNING
	controller.base_hp = 100.0
	controller._complete_defend_base_mission()
	if not _require(controller.run_state == controller.RunState.VICTORY and controller._completed_mission_stage_id == "stage_01", "defend_base completion regressed"):
		return false
	print("P1_3_MISSION_REGRESSION_PASS")
	main.queue_free()
	return true
