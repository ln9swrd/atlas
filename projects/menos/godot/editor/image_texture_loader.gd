extends RefCounted

static func load_texture(source_path: String) -> Texture2D:
	if source_path.is_empty():
		return null
	var loaded: Resource = ResourceLoader.load(source_path)
	if loaded is Texture2D:
		return loaded
	var absolute_path := source_path
	if source_path.begins_with("res://") or source_path.begins_with("user://"):
		absolute_path = ProjectSettings.globalize_path(source_path)
	var image := Image.new()
	if image.load(absolute_path) != OK:
		return null
	return ImageTexture.create_from_image(image)
