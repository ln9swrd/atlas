class_name VisualAssetPreview
extends Control

var texture: Texture2D:
	set(value):
		texture = value
		queue_redraw()

var anchor := Vector2(0.5, 1.0):
	set(value):
		anchor = Vector2(clampf(value.x, 0.0, 1.0), clampf(value.y, 0.0, 1.0))
		queue_redraw()

func _draw() -> void:
	if texture == null:
		return
	var source_size := Vector2(texture.get_size())
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return
	var margin := 6.0
	var available := Vector2(maxf(1.0, size.x - margin * 2.0), maxf(1.0, size.y - margin * 2.0))
	var scale := minf(available.x / source_size.x, available.y / source_size.y)
	var draw_size := source_size * scale
	var anchor_point := size * 0.5
	var draw_position := anchor_point - draw_size * anchor
	draw_texture_rect(texture, Rect2(draw_position, draw_size), false)
