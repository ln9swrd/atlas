extends SceneTree

const RuntimePackageIdentity = preload("res://scripts/runtime_package_identity.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--show-config"):
		_show_config()
		return
	var package_root := ""
	for index in range(args.size() - 1):
		if args[index] == "--package-root":
			package_root = args[index + 1].strip_edges()
			break
	if package_root.is_empty() or not package_root.is_absolute_path():
		push_error("Runtime package config requires an absolute --package-root, or use --show-config.")
		quit(2)
		return
	var manifest_path := package_root.path_join("manifest.json")
	var database_path := package_root.path_join("content/menos.sqlite")
	if not FileAccess.file_exists(manifest_path) or not FileAccess.file_exists(database_path):
		push_error("Runtime package is missing manifest.json or content/menos.sqlite: " + package_root)
		quit(3)
		return
	var config_path := RuntimePackageIdentity.current_config_path()
	if config_path.is_empty():
		push_error("Could not derive Runtime-specific package config path.")
		quit(5)
		return
	var config := FileAccess.open(config_path, FileAccess.WRITE)
	if config == null:
		push_error("Cannot write Runtime package selection: " + config_path)
		quit(4)
		return
	config.store_string(JSON.stringify({"package_root": package_root.simplify_path()}, "\t"))
	config.close()
	print(JSON.stringify({"status":"PASS", "action":"CONFIG_WRITE", "identity":RuntimePackageIdentity.identity_for_project_root(RuntimePackageIdentity.current_project_root()), "config_path":ProjectSettings.globalize_path(config_path), "package_root":package_root.simplify_path()}))
	quit(0)

func _show_config() -> void:
	var project_root := RuntimePackageIdentity.current_project_root()
	var identity := RuntimePackageIdentity.identity_for_project_root(project_root)
	var config_path := RuntimePackageIdentity.current_config_path()
	if identity.is_empty() or config_path.is_empty():
		print(JSON.stringify({"status":"ERROR", "error":"Could not derive Runtime identity/config path."}))
		quit(5)
		return
	var absolute_config_path := ProjectSettings.globalize_path(config_path)
	var result := {"status":"PASS", "action":"CONFIG_READ", "identity":identity, "project_root":project_root, "config_path":absolute_config_path, "configured":false, "package_root":"", "config_state":"BUILT_IN_CONTENT_CONFIGURED"}
	if FileAccess.file_exists(config_path):
		var file := FileAccess.open(config_path, FileAccess.READ)
		if file == null:
			result["status"] = "ERROR"
			result["config_state"] = "UNREADABLE_CONFIG"
			result["error"] = "Cannot read Runtime-specific config."
			print(JSON.stringify(result))
			quit(6)
			return
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		file.close()
		if not parsed is Dictionary or not parsed.get("package_root", "") is String or str(parsed.get("package_root", "")).strip_edges().is_empty():
			result["status"] = "INVALID_CONFIG"
			result["config_state"] = "INVALID_CONFIG"
		else:
			result["configured"] = true
			result["package_root"] = str(parsed.get("package_root", "")).strip_edges().simplify_path()
			result["config_state"] = "PACKAGE_CONFIGURED_FOR_NEXT_LAUNCH"
	print(JSON.stringify(result))
	quit(0 if str(result["status"]) == "PASS" else 7)
