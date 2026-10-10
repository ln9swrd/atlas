extends SceneTree

const RuntimePackageIdentity = preload("res://scripts/runtime_package_identity.gd")

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var root := RuntimePackageIdentity.current_project_root()
	var id := RuntimePackageIdentity.identity_for_project_root(root)
	_assert(not root.is_empty(), "current project root resolves")
	_assert(id.length() == 64, "identity is SHA-256 hex")
	_assert(RuntimePackageIdentity.config_path_for_project_root(root) == RuntimePackageIdentity.config_path_for_project_root(root.replace("/", "\\")), "slash variants share identity")
	var other := root.path_join("_other_runtime_identity_test")
	_assert(RuntimePackageIdentity.identity_for_project_root(other) != id, "different project roots are isolated")
	if OS.get_name() == "Windows":
		_assert(RuntimePackageIdentity.identity_for_project_root(root.to_upper()) == id, "Windows path casing is normalized")
	var config_path := RuntimePackageIdentity.current_config_path()
	_assert(config_path.get_file().begins_with("runtime_content_package_") and config_path.get_extension() == "json", "config filename includes Runtime identity")
	if failures == 0:
		print("RUNTIME_PACKAGE_IDENTITY_PASS")
		quit(0)
	else:
		push_error("RUNTIME_PACKAGE_IDENTITY_FAIL: %d assertion(s) failed" % failures)
		quit(1)

func _assert(ok: bool, label: String) -> void:
	if ok:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)
