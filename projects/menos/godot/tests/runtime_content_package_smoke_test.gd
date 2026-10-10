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
		push_error("RUNTIME_CONTENT_PACKAGE_FAIL: --package-root required"); quit(2); return
	RuntimeContentPackage.set_package_root_for_tests(package_root)
	_assert(RuntimeContentPackage.is_package_selected(), "package selection enabled")
	_assert(RuntimeContentPackage.is_package_valid(), "manifest, database hash and listed assets validate: " + RuntimeContentPackage.validation_error())
	_assert(RuntimeContentPackage.database_path().replace("\\", "/") == package_root.path_join("content/menos.sqlite").replace("\\", "/"), "package database path resolves under selected root")
	var maps := MapLoader.list_map_paths()
	_assert(maps.has("map_01") and maps.has("map_02") and maps.has("map_03") and maps.has("northbridge_sector_01"), "MapLoader reads selected package DB")
	_assert(str(MapLoader.load_map_data("map_01").get("map_id", "")) == "northbridge_sector_01", "legacy map alias reads package canonical map")
	_assert(ContentCatalogLoader.load_dictionary_catalog("robots").has("valkyrie"), "ContentCatalogLoader reads selected package DB")
	var manifest_file := FileAccess.open(package_root.path_join("manifest.json"), FileAccess.READ)
	var manifest: Dictionary = JSON.parse_string(manifest_file.get_as_text())
	manifest_file.close()
	var texture_loaded := false
	for item in manifest.get("assets", []):
		var path := str(item.get("path", ""))
		if str(item.get("role", "")) == "content_asset" and path.get_extension().to_lower() == "png":
			var texture := RuntimeContentPackage.load_resource(path) as Texture2D
			if texture != null:
				texture_loaded = true
				break
	_assert(texture_loaded, "external package PNG loads as Texture2D")
	var svg_loaded := false
	for item in manifest.get("assets", []):
		var path := str(item.get("path", ""))
		if str(item.get("role", "")) == "content_asset" and path.get_extension().to_lower() == "svg":
			var svg_texture := RuntimeContentPackage.load_resource(path) as Texture2D
			if svg_texture != null and svg_texture.get_width() > 0 and svg_texture.get_height() > 0:
				svg_loaded = true
				break
	_assert(svg_loaded, "external package SVG loads as Texture2D")
	var audio := RuntimeContentPackage.load_resource("res://sound/BGM_FACTION_01_NORMAL.ogg") as AudioStream
	_assert(audio != null, "external package OGG loads as AudioStream")
	var wav := RuntimeContentPackage.load_resource("res://sound/ROBOT_LASER_FIRE.wav") as AudioStream
	_assert(wav != null, "external package WAV loads as AudioStream")
	if failures == 0:
		print("RUNTIME_CONTENT_PACKAGE_SMOKE_PASS"); quit(0)
	else:
		push_error("RUNTIME_CONTENT_PACKAGE_SMOKE_FAIL: %d assertion(s) failed" % failures); quit(1)
func _assert(ok: bool, label: String) -> void:
	if ok: print("PASS: " + label)
	else: failures += 1; push_error("FAIL: " + label)
