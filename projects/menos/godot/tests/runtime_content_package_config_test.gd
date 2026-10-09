extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var package_root := ""
	for i in range(args.size() - 1):
		if args[i] == "--package-root": package_root = args[i + 1]
	if package_root.is_empty():
		push_error("RUNTIME_CONTENT_PACKAGE_CONFIG_FAIL: --package-root required"); quit(2); return
	RuntimeContentPackage.set_config_selection_for_tests(true)
	var had_original := FileAccess.file_exists(RuntimeContentPackage.CONFIG_PATH)
	var original_bytes := FileAccess.get_file_as_bytes(RuntimeContentPackage.CONFIG_PATH) if had_original else PackedByteArray()
	var config := FileAccess.open(RuntimeContentPackage.CONFIG_PATH, FileAccess.WRITE)
	if config == null:
		push_error("Cannot write temporary package config for test"); quit(2); return
	config.store_string(JSON.stringify({"package_root": package_root}, "	")); config.close()
	RuntimeContentPackage.clear_package_root_for_tests()
	RuntimeContentPackage.reload_configuration()
	_assert(RuntimeContentPackage.is_package_selected(), "user:// config selects external package")
	_assert(RuntimeContentPackage.is_package_valid(), "selected package config validates manifest and hashes")
	_assert(RuntimeContentPackage.package_root().replace("\\", "/") == package_root.replace("\\", "/"), "selected root matches config")
	ContentCatalogLoader.set_database_path_for_tests("")
	_assert(ContentCatalogLoader.load_dictionary_catalog("robots").has("valkyrie"), "catalog loader uses configured package DB")
	MapLoader.clear_sqlite_path_override()
	_assert(MapLoader.list_map_paths().has("northbridge_sector_01"), "map loader uses configured package DB")
	# Invalid selection must fail closed; it must not read the built-in DB.
	var bad_config := FileAccess.open(RuntimeContentPackage.CONFIG_PATH, FileAccess.WRITE)
	if bad_config != null:
		bad_config.store_string(JSON.stringify({"package_root": package_root.path_join("missing_package_for_fail_closed_test")}, "\t"))
		bad_config.close()
	RuntimeContentPackage.reload_configuration()
	ContentCatalogLoader.set_database_path_for_tests("")
	_assert(RuntimeContentPackage.is_package_selected() and not RuntimeContentPackage.is_package_valid(), "invalid configured package is rejected")
	_assert(MapLoader.list_map_paths().is_empty(), "invalid package does not expose built-in map aliases")
	_assert(MapLoader.load_map_data("map_01").is_empty(), "invalid package does not load built-in map data")
	_assert(ContentCatalogLoader.load_dictionary_catalog("robots").is_empty(), "invalid package does not load built-in catalogs")
	# Restore the user's original config byte-for-byte, or remove the temporary one.
	if had_original:
		var restore := FileAccess.open(RuntimeContentPackage.CONFIG_PATH, FileAccess.WRITE)
		if restore != null:
			restore.store_buffer(original_bytes); restore.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RuntimeContentPackage.CONFIG_PATH))
	RuntimeContentPackage.reload_configuration()
	RuntimeContentPackage.set_config_selection_for_tests(false)
	ContentCatalogLoader.set_database_path_for_tests("")
	if failures == 0:
		print("RUNTIME_CONTENT_PACKAGE_CONFIG_PASS"); quit(0)
	else:
		push_error("RUNTIME_CONTENT_PACKAGE_CONFIG_FAIL: %d assertion(s) failed" % failures); quit(1)
func _assert(ok: bool, label: String) -> void:
	if ok: print("PASS: " + label)
	else: failures += 1; push_error("FAIL: " + label)
