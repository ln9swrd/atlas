extends SceneTree

const VISUAL_ASSET_DEFINITION := preload("res://scripts/visual_asset_definition.gd")
const VISUAL_ASSET_FRAME := preload("res://scripts/visual_asset_frame.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var definition = VISUAL_ASSET_DEFINITION.from_dict({
		"asset_id": "test.frame_anchor",
		"display_name": "Frame Anchor Fixture",
		"owner_kind": "visual_asset",
		"owner_key": "test.frame_anchor",
		"source_path": "res://tests/frame_anchor_fixture.png",
		"region": [0, 0, 192, 64],
		"frames": 3,
		"columns": 3,
		"rows": 1,
		"anchor": {"mode": "CUSTOM", "x": 0.5, "y": 1.0},
		"frame_anchors": [[0.40, 0.80], [0.60, 0.70]]
	})
	if not _check(definition != null, "Definition creation failed"):
		return
	if not _check(definition.frame_anchors.size() == 2, "Per-frame anchors were not parsed"):
		return

	var resolved0 := VISUAL_ASSET_FRAME.anchor_normalized(definition, 0)
	var resolved1 := VISUAL_ASSET_FRAME.anchor_normalized(definition, 1)
	var resolved2 := VISUAL_ASSET_FRAME.anchor_normalized(definition, 2)
	if not _check(resolved0.is_equal_approx(Vector2(0.40, 0.80)), "Frame 0 anchor resolution failed"):
		return
	if not _check(resolved1.is_equal_approx(Vector2(0.60, 0.70)), "Frame 1 anchor resolution failed"):
		return
	if not _check(resolved2.is_equal_approx(Vector2(0.50, 1.00)), "Missing frame anchor did not fall back to shared anchor"):
		return

	var offset0 := VISUAL_ASSET_FRAME.anchor_offset(definition, Vector2(64, 64), 0)
	var offset1 := VISUAL_ASSET_FRAME.anchor_offset(definition, Vector2(64, 64), 1)
	if not _check(offset0.is_equal_approx(Vector2(6.4, -19.2)), "Frame 0 anchor offset failed"):
		return
	if not _check(offset1.is_equal_approx(Vector2(-6.4, -12.8)), "Frame 1 anchor offset failed"):
		return

	var serialized: Dictionary = definition.to_dict()
	if not _check(serialized.get("frame_anchors", []) == [[0.40, 0.80], [0.60, 0.70]], "Per-frame anchors were not serialized"):
		return
	var reloaded = VISUAL_ASSET_DEFINITION.from_dict(serialized)
	if not _check(reloaded != null, "Serialized definition could not be reloaded"):
		return
	if not _check(VISUAL_ASSET_FRAME.anchor_normalized(reloaded, 0).is_equal_approx(Vector2(0.40, 0.80)), "Reloaded Frame 0 anchor failed"):
		return
	if not _check(VISUAL_ASSET_FRAME.anchor_normalized(reloaded, 1).is_equal_approx(Vector2(0.60, 0.70)), "Reloaded Frame 1 anchor failed"):
		return
	if not _check(VISUAL_ASSET_FRAME.anchor_normalized(reloaded, 2).is_equal_approx(Vector2(0.50, 1.00)), "Reloaded fallback anchor failed"):
		return

	print("FRAME_ANCHOR_SMOKE_TEST_PASS")
	quit(0)

func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false
