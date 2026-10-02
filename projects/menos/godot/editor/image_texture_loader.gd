extends RefCounted

static func load_texture(source_path: String) -> Texture2D:
	var image := load_image(source_path)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)

static func load_image(source_path: String) -> Image:
	if source_path.is_empty():
		return null
	var absolute_path := source_path
	if source_path.begins_with("res://") or source_path.begins_with("user://"):
		absolute_path = ProjectSettings.globalize_path(source_path)
	var image := Image.new()
	if image.load(absolute_path) != OK:
		return null
	prepare_for_pixel_edit(image)
	return image

static func prepare_for_pixel_edit(image: Image) -> void:
	if image.is_compressed():
		image.decompress()
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
