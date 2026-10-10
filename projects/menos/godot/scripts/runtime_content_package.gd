class_name RuntimeContentPackage
extends RefCounted

const RuntimePackageIdentity = preload("res://scripts/runtime_package_identity.gd")

const MANIFEST_NAME := "manifest.json"
const PACKAGE_FORMAT_VERSION := 1

static var _test_package_root := ""
static var _test_allow_config_selection := false
static var _loaded := false
static var _selected := false
static var _valid := false
static var _package_root := ""
static var _database_path := ""
static var _manifest: Dictionary = {}
static var _asset_paths: Dictionary = {}
static var _validation_error := ""

static func set_package_root_for_tests(root: String) -> void:
	if not OS.is_debug_build():
		return
	_test_package_root = root
	_reset_cache()

static func clear_package_root_for_tests() -> void:
	if not OS.is_debug_build():
		return
	_test_package_root = ""
	_reset_cache()

static func set_config_selection_for_tests(enabled: bool) -> void:
	if not OS.is_debug_build():
		return
	_test_allow_config_selection = enabled
	_reset_cache()

static func reload_configuration() -> void:
	_reset_cache()

static func _reset_cache() -> void:
	_loaded = false
	_selected = false
	_valid = false
	_package_root = ""
	_database_path = ""
	_manifest.clear()
	_asset_paths.clear()
	_validation_error = ""

static func is_package_selected() -> bool:
	_ensure_loaded()
	return _selected

static func is_package_valid() -> bool:
	_ensure_loaded()
	return _valid

static func validation_error() -> String:
	_ensure_loaded()
	return _validation_error

static func package_root() -> String:
	_ensure_loaded()
	return _package_root

static func database_path() -> String:
	_ensure_loaded()
	if not _selected:
		return "res://content/menos.sqlite"
	return _database_path if _valid else ""

static func resolve_resource_path(resource_path: String) -> String:
	_ensure_loaded()
	if not _selected:
		return resource_path
	if not _valid:
		return ""
	if not resource_path.begins_with("res://"):
		return resource_path
	if not _asset_paths.has(resource_path):
		return resource_path
	var relative := resource_path.trim_prefix("res://").replace("\\", "/")
	if relative.is_empty() or relative.begins_with("/") or relative.split("/").has(".."):
		return ""
	var resolved := (_package_root.path_join(relative)).simplify_path()
	return resolved if FileAccess.file_exists(resolved) else ""

static func load_resource(resource_path: String) -> Resource:
	var resolved := resolve_resource_path(resource_path)
	if resolved.is_empty():
		return null
	if resolved.begins_with("res://") or resolved.begins_with("uid://"):
		return load(resolved)
	var extension := resolved.get_extension().to_lower()
	if extension in ["png", "jpg", "jpeg", "webp", "bmp", "tga"]:
		var image := Image.new()
		if image.load(resolved) != OK:
			return null
		return ImageTexture.create_from_image(image)
	if extension == "svg":
		var svg_file := FileAccess.open(resolved, FileAccess.READ)
		if svg_file == null:
			return null
		var svg_bytes := svg_file.get_buffer(svg_file.get_length())
		svg_file.close()
		var svg_image := Image.new()
		if svg_image.load_svg_from_buffer(svg_bytes) != OK:
			return null
		return ImageTexture.create_from_image(svg_image)
	if extension == "ogg":
		return AudioStreamOggVorbis.load_from_file(resolved)
	if extension == "wav":
		return AudioStreamWAV.load_from_file(resolved)
	if extension == "mp3":
		return AudioStreamMP3.load_from_file(resolved)
	# Static/other Godot resources remain bundled with the Runtime project.
	return load(resource_path) if ResourceLoader.exists(resource_path) else null

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var root := _test_package_root
	if root.is_empty():
		# Package selection applies to Runtime builds only. Running project tools in
		# the Godot editor must retain access to the project-owned authoring DB.
		if (OS.has_feature("editor") and not _test_allow_config_selection) or not FileAccess.file_exists(RuntimePackageIdentity.current_config_path()):
			return
		_selected = true
		var config_file := FileAccess.open(RuntimePackageIdentity.current_config_path(), FileAccess.READ)
		if config_file == null:
			_validation_error = "Cannot read package selection config: " + RuntimePackageIdentity.current_config_path()
			push_error("RuntimeContentPackage: " + _validation_error)
			return
		var parsed: Variant = JSON.parse_string(config_file.get_as_text())
		config_file.close()
		if not parsed is Dictionary or not parsed.get("package_root", "") is String:
			_validation_error = "Package config must contain a string package_root"
			push_error("RuntimeContentPackage: " + _validation_error)
			return
		root = str(parsed.get("package_root", "")).strip_edges()
	else:
		_selected = true
	if root.is_empty() or not root.is_absolute_path():
		_validation_error = "Selected package_root must be an absolute filesystem path"
		push_error("RuntimeContentPackage: " + _validation_error)
		return
	_package_root = root.simplify_path()
	var manifest_path := _package_root.path_join(MANIFEST_NAME)
	var manifest_file := FileAccess.open(manifest_path, FileAccess.READ)
	if manifest_file == null:
		_validation_error = "Package manifest is missing: " + manifest_path
		push_error("RuntimeContentPackage: " + _validation_error)
		return
	var manifest_value: Variant = JSON.parse_string(manifest_file.get_as_text())
	manifest_file.close()
	if not manifest_value is Dictionary:
		_validation_error = "Package manifest is not a JSON object"
		push_error("RuntimeContentPackage: " + _validation_error)
		return
	_manifest = manifest_value
	if int(_manifest.get("package_format_version", -1)) != PACKAGE_FORMAT_VERSION:
		_validation_error = "Unsupported package_format_version"
		push_error("RuntimeContentPackage: " + _validation_error)
		return
	var database: Variant = _manifest.get("database", {})
	if not database is Dictionary or str(database.get("path", "")) != "content/menos.sqlite":
		_validation_error = "Manifest database path is invalid"
		push_error("RuntimeContentPackage: " + _validation_error)
		return
	_database_path = _package_root.path_join("content/menos.sqlite")
	if not FileAccess.file_exists(_database_path):
		_validation_error = "Package database is missing: " + _database_path
		push_error("RuntimeContentPackage: " + _validation_error)
		return
	var expected_hash := str(database.get("sha256", ""))
	if expected_hash.length() != 64 or _sha256_file(_database_path) != expected_hash:
		_validation_error = "Package database SHA-256 does not match manifest"
		push_error("RuntimeContentPackage: " + _validation_error)
		return
	var assets: Variant = _manifest.get("assets", [])
	if not assets is Array:
		_validation_error = "Manifest assets must be an array"
		push_error("RuntimeContentPackage: " + _validation_error)
		return
	for item in assets:
		if not item is Dictionary:
			_validation_error = "Manifest contains an invalid asset entry"
			push_error("RuntimeContentPackage: " + _validation_error)
			return
		var path := str(item.get("path", ""))
		if not path.begins_with("res://"):
			continue
		var relative := path.trim_prefix("res://").replace("\\", "/")
		if relative.is_empty() or relative.begins_with("/") or relative.split("/").has(".."):
			_validation_error = "Manifest contains an unsafe asset path: " + path
			push_error("RuntimeContentPackage: " + _validation_error)
			return
		var asset_path := _package_root.path_join(relative).simplify_path()
		if not FileAccess.file_exists(asset_path):
			_validation_error = "Manifest asset is missing: " + path
			push_error("RuntimeContentPackage: " + _validation_error)
			return
		var expected_size := int(item.get("size_bytes", -1))
		var expected_asset_hash := str(item.get("sha256", ""))
		if expected_size < 0 or _file_size(asset_path) != expected_size or expected_asset_hash.length() != 64 or _sha256_file(asset_path) != expected_asset_hash:
			_validation_error = "Package asset integrity check failed: " + path
			push_error("RuntimeContentPackage: " + _validation_error)
			return
		if str(item.get("role", "")) == "content_asset":
			_asset_paths[path] = true
	_valid = true

static func _sha256_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		file.close()
		return ""
	while not file.eof_reached():
		var chunk := file.get_buffer(1024 * 1024)
		if chunk.is_empty():
			break
		context.update(chunk)
	file.close()
	return context.finish().hex_encode()

static func _file_size(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return -1
	var size := file.get_length()
	file.close()
	return size
