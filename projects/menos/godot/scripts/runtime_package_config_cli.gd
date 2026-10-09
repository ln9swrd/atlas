extends SceneTree

const CONFIG_PATH := "user://runtime_content_package.json"

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var package_root := ""
	for index in range(args.size() - 1):
		if args[index] == "--package-root":
			package_root = args[index + 1].strip_edges()
			break
	if package_root.is_empty() or not package_root.is_absolute_path():
		push_error("Runtime package config requires an absolute --package-root.")
		quit(2)
		return
	var manifest_path := package_root.path_join("manifest.json")
	var database_path := package_root.path_join("content/menos.sqlite")
	if not FileAccess.file_exists(manifest_path) or not FileAccess.file_exists(database_path):
		push_error("Runtime package is missing manifest.json or content/menos.sqlite: " + package_root)
		quit(3)
		return
	var config := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if config == null:
		push_error("Cannot write Runtime package selection: " + CONFIG_PATH)
		quit(4)
		return
	config.store_string(JSON.stringify({"package_root": package_root.simplify_path()}, "\t"))
	config.close()
	print("RUNTIME_PACKAGE_CONFIG_PASS")
	quit(0)
