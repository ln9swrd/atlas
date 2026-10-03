class_name EditorThumbnailUtil
extends RefCounted

static func create(value: String, fallback_region: Rect2 = Rect2(), fallback_frames: int = 1, canvas_size: int = 48, target_height: int = 44) -> Texture2D:
	if value.is_empty():
		return null
	var resolved := VisualAssetResolver.resolve(value)
	var source_path := value
	var region := fallback_region
	var frame_count := maxi(1, fallback_frames)
	if resolved != null:
		source_path = resolved.source
		if not resolved.id.begins_with("legacy:"):
			if resolved.region.size.x > 0.0 and resolved.region.size.y > 0.0:
				region = resolved.region
			frame_count = resolved.frames
	var source_texture := load(source_path) as Texture2D
	if source_texture == null:
		return null
	var source_size := Vector2i(source_texture.get_width(), source_texture.get_height())
	var clipped := Rect2i(region) if region.size.x > 0.0 and region.size.y > 0.0 else Rect2i(Vector2i.ZERO, source_size)
	clipped = clipped.intersection(Rect2i(Vector2i.ZERO, source_size))
	if clipped.size.x <= 0 or clipped.size.y <= 0:
		return null
	frame_count = maxi(1, frame_count)
	if frame_count > 1:
		var frame_width := float(clipped.size.x) / float(frame_count)
		clipped = Rect2i(clipped.position.x, clipped.position.y, maxi(1, int(round(frame_width))), clipped.size.y)
		clipped = clipped.intersection(Rect2i(Vector2i.ZERO, source_size))
		if clipped.size.x <= 0 or clipped.size.y <= 0:
			return null
	var image := source_texture.get_image()
	if image == null:
		return null
	var region_image := image.get_region(clipped)
	if region_image == null:
		return null
	var used := region_image.get_used_rect()
	if used.size.x <= 0 or used.size.y <= 0:
		return null
	var cropped := region_image.get_region(used)
	var height := maxi(1, target_height)
	var width := maxi(1, int(round(float(cropped.get_width()) * float(height) / float(cropped.get_height()))))
	if width > canvas_size:
		var width_scale := float(canvas_size) / float(width)
		width = canvas_size
		height = maxi(1, int(round(float(height) * width_scale)))
	cropped.resize(width, height, Image.INTERPOLATE_NEAREST)
	var canvas := Image.create(canvas_size, canvas_size, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var offset := Vector2i((canvas_size - width) / 2, (canvas_size - height) / 2)
	canvas.blit_rect(cropped, Rect2i(Vector2i.ZERO, Vector2i(width, height)), offset)
	return ImageTexture.create_from_image(canvas)
