class_name EditorThumbnailUtil
extends RefCounted

static func create(value: String, fallback_region: Rect2 = Rect2(), fallback_frames: int = 1, canvas_size: int = 48, target_height: int = 44) -> Texture2D:
	if value.is_empty():
		return null
	var resolved := VisualAssetResolver.resolve(value)
	var source_path := value
	var region := fallback_region
	var frame_count := maxi(1, fallback_frames)
	var columns := maxi(1, frame_count)
	var rows := 1
	if resolved != null:
		source_path = resolved.source
		if not resolved.id.begins_with("legacy:"):
			if resolved.region.size.x > 0.0 and resolved.region.size.y > 0.0:
				region = resolved.region
			frame_count = resolved.frames
			columns = resolved.columns
			rows = resolved.rows
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
		columns = maxi(1, columns)
		rows = maxi(1, rows)
		if frame_count > columns * rows:
			return null
		if resolved != null and not resolved.id.begins_with("legacy:"):
			clipped = Rect2i(VisualAssetFrame.region_for(resolved, 0, Rect2(clipped.position, clipped.size)))
		else:
			var frame_index := 0
			var column := frame_index % columns
			var row := frame_index / columns
			var cell_width := float(clipped.size.x) / float(columns)
			var cell_height := float(clipped.size.y) / float(rows)
			clipped = Rect2i(
				int(round(float(clipped.position.x) + cell_width * float(column))),
				int(round(float(clipped.position.y) + cell_height * float(row))),
				maxi(1, int(round(cell_width))),
				maxi(1, int(round(cell_height)))
			)
		clipped = clipped.intersection(Rect2i(Vector2i.ZERO, source_size))
		if clipped.size.x <= 0 or clipped.size.y <= 0:
			return null
	var image := source_texture.get_image()
	if image == null:
		return null
	# Normalize the source before region/alpha analysis. Valkyrie and other catalog sheets can
	# arrive as RGB/RGBA variants depending on the imported PNG format.
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	var region_image := image.get_region(clipped)
	if region_image == null:
		return null
	var used := region_image.get_used_rect()
	# A fully opaque/RGB source has no alpha bounds; use the selected frame itself in that case.
	if used.size.x <= 0 or used.size.y <= 0:
		used = Rect2i(Vector2i.ZERO, region_image.get_size())
	if used.size.x <= 0 or used.size.y <= 0:
		return null
	var cropped := region_image.get_region(used)
	if cropped.get_format() != Image.FORMAT_RGBA8:
		cropped.convert(Image.FORMAT_RGBA8)
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
	if resolved != null and not resolved.id.begins_with("legacy:"):
		var anchor := VisualAssetFrame.anchor_normalized(resolved)
		var anchor_source := Vector2(region_image.get_width() * anchor.x, region_image.get_height() * anchor.y)
		var anchor_used := anchor_source - Vector2(used.position)
		var scale_x := float(width) / float(maxi(1, used.size.x))
		var scale_y := float(height) / float(maxi(1, used.size.y))
		offset = Vector2i(
			round(float(canvas_size) * 0.5 - anchor_used.x * scale_x),
			round(float(canvas_size) * 0.5 - anchor_used.y * scale_y)
		)
	canvas.blit_rect(cropped, Rect2i(Vector2i.ZERO, Vector2i(width, height)), offset)
	return ImageTexture.create_from_image(canvas)
