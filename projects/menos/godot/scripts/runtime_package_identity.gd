class_name RuntimePackageIdentity
extends RefCounted

static func normalize_project_root(path: String) -> String:
	var normalized := path.strip_edges().replace("\\", "/").simplify_path()
	while normalized.length() > 1 and normalized.ends_with("/"):
		normalized = normalized.trim_suffix("/")
	if OS.get_name() == "Windows":
		normalized = normalized.to_lower()
	return normalized

static func identity_for_project_root(path: String) -> String:
	var normalized := normalize_project_root(path)
	if normalized.is_empty() or not normalized.is_absolute_path():
		return ""
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	context.update(normalized.to_utf8_buffer())
	return context.finish().hex_encode()

static func current_project_root() -> String:
	return normalize_project_root(ProjectSettings.globalize_path("res://"))

static func config_path_for_project_root(path: String) -> String:
	var identity := identity_for_project_root(path)
	if identity.is_empty():
		return ""
	return "user://runtime_content_package_" + identity + ".json"

static func current_config_path() -> String:
	return config_path_for_project_root(current_project_root())
