extends SceneTree

const EXPECTED_MAP_IDS := ["map_02", "map_03", "northbridge_sector_01"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ids := MapLoader.list_map_paths()
	_assert(ids == EXPECTED_MAP_IDS, "authoring map list matches JSON filenames")

	var canonical := MapLoader.load_map_data("northbridge_sector_01")
	_assert(not canonical.is_empty(), "canonical map JSON loads")
	_assert(str(canonical.get("map_id", "")) == "northbridge_sector_01", "JSON map_id is authoritative")
	_assert(canonical.get("objects", []).size() == 309, "all 309 authored map objects are preserved")

	var legacy_alias := MapLoader.load_map_data("map_01")
	_assert(str(legacy_alias.get("map_id", "")) == "northbridge_sector_01", "legacy stage map_01 alias resolves to canonical map ID")
	var legacy_path := MapLoader.load_map_data("res://content/maps/map_01.json")
	_assert(str(legacy_path.get("map_id", "")) == "northbridge_sector_01", "legacy map path resolves to canonical map ID")
	_assert(not MapLoader.create_map("map_01", canonical), "legacy alias cannot be reused as a new map ID")
	_assert(not MapLoader.delete_map("northbridge_sector_01"), "canonical map deletion is blocked")

	var validation := ContentValidator.new().run()
	var map_errors: Array[String] = []
	for error in validation.get("errors", []):
		if str(error).begins_with("MAP"):
			map_errors.append(str(error))
	_assert(map_errors.is_empty(), "content validator accepts map JSON identities and existing Stage map aliases")
	var multiplayer_warning_found := false
	for warning in validation.get("warnings", []):
		if str(warning).contains("unsupported play mode 'multiplayer'"):
			multiplayer_warning_found = true
	_assert(multiplayer_warning_found, "legacy Multiplayer metadata is retained and reported as unsupported")

	var temp_dir := "user://map_authoring_contract_test_%d" % Time.get_ticks_usec()
	MapLoader.set_maps_directory_for_tests(temp_dir)
	var duplicate := canonical.duplicate(true)
	duplicate["map_id"] = "contract_test"
	duplicate["name"] = "Contract Test"
	_assert(MapLoader.create_map("contract_test", duplicate), "create writes a new standalone JSON map")
	var loaded := MapLoader.load_map_data("contract_test")
	_assert(str(loaded.get("map_id", "")) == "contract_test", "created JSON reloads with matching identity")
	_assert(loaded.get("objects", []).size() == 309, "create round-trip preserves map objects")
	_assert(not MapLoader.create_map("contract_test", duplicate), "duplicate IDs do not overwrite existing JSON")
	loaded["name"] = "Saved Contract Test"
	_assert(MapLoader.save_map_data("contract_test", loaded), "save atomically replaces an existing JSON map")
	var saved := MapLoader.load_map_data("contract_test")
	_assert(str(saved.get("name", "")) == "Saved Contract Test", "saved JSON reloads with updated content")
	_assert(MapLoader.delete_map("contract_test"), "non-canonical unreferenced map can be deleted")
	_assert(not FileAccess.file_exists(MapLoader.map_file_path("contract_test")), "delete removes only the selected authoring JSON")
	MapLoader.clear_maps_directory_override()
	var absolute_temp := ProjectSettings.globalize_path(temp_dir)
	if DirAccess.dir_exists_absolute(absolute_temp):
		DirAccess.remove_absolute(absolute_temp)

	if _failures == 0:
		print("MAP_AUTHORING_CONTRACT_PASS")
		quit(0)
	else:
		push_error("MAP_AUTHORING_CONTRACT_FAIL: %d assertions failed" % _failures)
		quit(1)

var _failures := 0
func _assert(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		_failures += 1
		push_error("FAIL: " + description)
