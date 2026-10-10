extends Control

const RepositoryScript = preload("res://scripts/vfx_definition_repository.gd")
const VFXDefinitionScript = preload("res://scripts/vfx_definition.gd")
const VFXRuntimeAdapterScript = preload("res://scripts/vfx_runtime_adapter.gd")

var repository = RepositoryScript
var current_id := ""
var component_rows: Array[Dictionary] = []
var track_rows: Array[Dictionary] = []
var key_rows: Array[Dictionary] = []
var preview_time := 0.0
var preview_playing := false
var preview_duration := 0.25
var preview_adapter = VFXRuntimeAdapterScript.new()

@onready var list: ItemList = $MainLayout/Body/ListPanel/List
@onready var id_edit: LineEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Identity/Id
@onready var name_edit: LineEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Identity/Name
@onready var category_edit: LineEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Identity/Category
@onready var revision_edit: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Identity/Revision
@onready var status_edit: OptionButton = $MainLayout/Body/Editor/FieldScroll/Fields/Identity/Status
@onready var description_edit: TextEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Description
@onready var component_list: ItemList = $MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentList
@onready var component_type_edit: LineEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentType
@onready var component_resource_edit: LineEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentResource
@onready var timeline_duration_edit: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/Controls/Duration
@onready var timeline_loop: CheckButton = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/Controls/Loop
@onready var timeline_playback: OptionButton = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/Controls/Playback
@onready var track_list: ItemList = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/TrackList
@onready var track_property_edit: LineEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/TrackProperty
@onready var track_start_edit: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/TrackStart
@onready var track_end_edit: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/TrackEnd
@onready var key_list: ItemList = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/KeyList
@onready var key_time_edit: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/KeyTime
@onready var key_value_edit: LineEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/KeyValue
@onready var key_interpolation: OptionButton = $MainLayout/Body/Editor/FieldScroll/Fields/Timeline/KeyInterpolation
@onready var transform_space: OptionButton = $MainLayout/Body/Editor/FieldScroll/Fields/Transform/Space
@onready var transform_anchor: LineEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Transform/Anchor
@onready var transform_offset_x: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Transform/OffsetX
@onready var transform_offset_y: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Transform/OffsetY
@onready var transform_rotation: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Transform/Rotation
@onready var transform_scale: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Transform/Scale
@onready var resources_edit: TextEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Resources
@onready var priority_edit: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Policy/Priority
@onready var concurrency_edit: LineEdit = $MainLayout/Body/Editor/FieldScroll/Fields/Policy/Concurrency
@onready var max_instances_edit: SpinBox = $MainLayout/Body/Editor/FieldScroll/Fields/Policy/MaxInstances
@onready var preview_canvas: Control = $MainLayout/Body/PreviewPanel/PreviewVBox/PreviewCanvas
@onready var preview_status: Label = $MainLayout/Body/PreviewPanel/PreviewVBox/PreviewStatus
@onready var status_label: Label = $MainLayout/Status

func _ready() -> void:
	repository.reload()
	$MainLayout/Body/ListPanel/Buttons/New.pressed.connect(_new_definition)
	$MainLayout/Body/ListPanel/Buttons/Refresh.pressed.connect(_refresh)
	$MainLayout/Body/Editor/FieldScroll/Fields/Buttons/Save.pressed.connect(_save_definition)
	$MainLayout/Body/Editor/FieldScroll/Fields/Buttons/Delete.pressed.connect(_delete_definition)
	list.item_selected.connect(_select_definition)
	$MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentButtons/Add.pressed.connect(_add_component)
	$MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentButtons/Remove.pressed.connect(_remove_component)
	component_list.item_selected.connect(_select_component)
	$MainLayout/Body/Editor/FieldScroll/Fields/Timeline/TrackButtons/Add.pressed.connect(_add_track)
	$MainLayout/Body/Editor/FieldScroll/Fields/Timeline/TrackButtons/Remove.pressed.connect(_remove_track)
	track_list.item_selected.connect(_select_track)
	$MainLayout/Body/Editor/FieldScroll/Fields/Timeline/KeyButtons/Add.pressed.connect(_add_key)
	$MainLayout/Body/Editor/FieldScroll/Fields/Timeline/KeyButtons/Remove.pressed.connect(_remove_key)
	key_list.item_selected.connect(_select_key)
	$MainLayout/Body/PreviewPanel/PreviewVBox/Controls/Play.pressed.connect(_preview_play)
	$MainLayout/Body/PreviewPanel/PreviewVBox/Controls/Stop.pressed.connect(_preview_stop)
	$MainLayout/Body/PreviewPanel/PreviewVBox/Controls/Restart.pressed.connect(_preview_restart)
	$MainLayout/Body/PreviewPanel/PreviewVBox/Controls/Scrub.value_changed.connect(_preview_scrub)
	preview_canvas.draw.connect(_on_preview_canvas_draw)
	_refresh()
	_new_definition()

func _process(delta: float) -> void:
	if not preview_playing:
		return
	preview_adapter.tick(delta)
	preview_time = preview_adapter.time
	preview_playing = preview_adapter.playing
	$MainLayout/Body/PreviewPanel/PreviewVBox/Controls/Scrub.value = preview_time
	_update_preview()

func _refresh() -> void:
	list.clear()
	for vfx_id in repository.list():
		var definition = repository.get_definition(vfx_id)
		if definition == null:
			continue
		list.add_item("%s  [%s]" % [definition.id, definition.status])
	status_label.text = "VFX Definitions: %d" % list.item_count

func _new_definition() -> void:
	current_id = ""
	id_edit.text = ""
	name_edit.text = ""
	category_edit.text = "generic"
	revision_edit.value = 1
	status_edit.select(0)
	description_edit.text = ""
	component_rows = []
	track_rows = []
	key_rows = []
	_refresh_components()
	_refresh_tracks()
	_refresh_keys()
	timeline_duration_edit.value = 0.25
	timeline_loop.button_pressed = false
	timeline_playback.select(0)
	transform_space.select(0)
	transform_anchor.text = "origin"
	transform_offset_x.value = 0
	transform_offset_y.value = 0
	transform_rotation.value = 0
	transform_scale.value = 1
	resources_edit.text = "[]"
	priority_edit.value = 0
	concurrency_edit.text = "allow_multiple"
	max_instances_edit.value = 0
	preview_time = 0.0
	preview_duration = 0.25
	preview_playing = false
	_update_preview()
	status_label.text = "New VFX Definition"

func _select_definition(index: int) -> void:
	var ids := repository.list()
	if index < 0 or index >= ids.size():
		return
	var definition = repository.get_definition(ids[index])
	if definition == null:
		return
	current_id = definition.id
	id_edit.text = definition.id
	name_edit.text = definition.name
	category_edit.text = definition.category
	revision_edit.value = definition.revision
	_select_status(definition.status)
	description_edit.text = definition.description
	component_rows = definition.components.duplicate(true)
	_refresh_components()
	var timeline: Dictionary = definition.timeline
	timeline_duration_edit.value = float(timeline.get("duration", 0.0))
	timeline_loop.button_pressed = bool(timeline.get("loop", false))
	_select_playback(str(timeline.get("playback", "once")))
	track_rows = timeline.get("tracks", []).duplicate(true) if timeline.get("tracks", []) is Array else []
	_refresh_tracks()
	var transform: Dictionary = definition.transform
	_select_transform_space(str(transform.get("space", "world")))
	transform_anchor.text = str(transform.get("anchor", "origin"))
	var offset: Dictionary = transform.get("offset", {})
	transform_offset_x.value = float(offset.get("x", 0.0))
	transform_offset_y.value = float(offset.get("y", 0.0))
	transform_rotation.value = float(transform.get("rotation", 0.0))
	transform_scale.value = float(transform.get("scale", 1.0))
	resources_edit.text = JSON.stringify(definition.visual_resource_refs)
	priority_edit.value = definition.priority
	concurrency_edit.text = definition.concurrency
	max_instances_edit.value = definition.max_instances
	preview_time = 0.0
	preview_duration = maxf(float(timeline.get("duration", 0.25)), 0.01)
	preview_playing = false
	_update_preview()
	status_label.text = "Loaded: %s" % definition.id

func _select_status(value: String) -> void:
	for index in status_edit.item_count:
		if status_edit.get_item_text(index) == value:
			status_edit.select(index)
			return

func _select_playback(value: String) -> void:
	for index in timeline_playback.item_count:
		if timeline_playback.get_item_text(index).to_lower() == value.to_lower():
			timeline_playback.select(index)
			return

func _select_transform_space(value: String) -> void:
	for index in transform_space.item_count:
		if transform_space.get_item_text(index).to_lower() == value.to_lower():
			transform_space.select(index)
			return

func _refresh_components() -> void:
	component_list.clear()
	for component in component_rows:
		var component_type := str(component.get("type", ""))
		var resource := str(component.get("resource", ""))
		component_list.add_item(component_type if resource.is_empty() else "%s  →  %s" % [component_type, resource])
	if component_rows.is_empty():
		component_type_edit.text = ""
		component_resource_edit.text = ""

func _select_component(index: int) -> void:
	if index < 0 or index >= component_rows.size():
		return
	var component := component_rows[index]
	component_type_edit.text = str(component.get("type", ""))
	component_resource_edit.text = str(component.get("resource", ""))

func _add_component() -> void:
	var component_type := component_type_edit.text.strip_edges()
	if component_type.is_empty():
		status_label.text = "ERROR: Component type is required"
		return
	component_rows.append({"type": component_type, "resource": component_resource_edit.text.strip_edges()})
	_refresh_components()
	component_list.select(component_rows.size() - 1)
	status_label.text = "Component added"
	_update_preview()

func _remove_component() -> void:
	var selected := component_list.get_selected_items()
	if selected.is_empty():
		return
	component_rows.remove_at(selected[0])
	_refresh_components()
	status_label.text = "Component removed"
	_update_preview()

func _refresh_tracks() -> void:
	track_list.clear()
	for track in track_rows:
		var property_name := str(track.get("property", ""))
		var start_time := float(track.get("start", 0.0))
		var end_time := float(track.get("end", start_time))
		track_list.add_item("%s  %.2f → %.2f" % [property_name, start_time, end_time])
	if track_rows.is_empty():
		track_property_edit.text = ""
		key_rows = []
		_refresh_keys()

func _select_track(index: int) -> void:
	if index < 0 or index >= track_rows.size():
		return
	var track := track_rows[index]
	track_property_edit.text = str(track.get("property", ""))
	track_start_edit.value = float(track.get("start", 0.0))
	track_end_edit.value = float(track.get("end", 0.0))
	key_rows = track.get("keys", []).duplicate(true) if track.get("keys", []) is Array else []
	_refresh_keys()
	_update_preview()

func _refresh_keys() -> void:
	key_list.clear()
	for key in key_rows:
		var time := float(key.get("time", 0.0))
		var value := str(key.get("value", ""))
		var interpolation := str(key.get("interpolation", "linear"))
		key_list.add_item("%.2f  %s  [%s]" % [time, value, interpolation])
	if key_rows.is_empty():
		key_time_edit.value = 0
		key_value_edit.text = ""
		key_interpolation.select(0)

func _select_key(index: int) -> void:
	if index < 0 or index >= key_rows.size():
		return
	var key := key_rows[index]
	key_time_edit.value = float(key.get("time", 0.0))
	key_value_edit.text = str(key.get("value", ""))
	_select_interpolation(str(key.get("interpolation", "linear")))

func _select_interpolation(value: String) -> void:
	for index in key_interpolation.item_count:
		if key_interpolation.get_item_text(index).to_lower().replace(" ", "_") == value.to_lower():
			key_interpolation.select(index)
			return

func _add_key() -> void:
	if track_list.get_selected_items().is_empty():
		status_label.text = "ERROR: Select a Timeline Track first"
		return
	var time := float(key_time_edit.value)
	var value := key_value_edit.text.strip_edges()
	if value.is_empty():
		status_label.text = "ERROR: Key value is required"
		return
	var track_index := track_list.get_selected_items()[0]
	var track: Dictionary = track_rows[track_index]
	var start_time := float(track.get("start", 0.0))
	var end_time := float(track.get("end", 0.0))
	if time < start_time or time > end_time:
		status_label.text = "ERROR: Key time is outside Track range"
		return
	var interpolation := key_interpolation.get_item_text(key_interpolation.selected).to_lower().replace(" ", "_")
	key_rows.append({"time": time, "value": value, "interpolation": interpolation})
	key_rows.sort_custom(func(a, b): return float(a.get("time", 0.0)) < float(b.get("time", 0.0)))
	_sync_selected_track_keys()
	_refresh_keys()
	_update_preview()
	status_label.text = "Key added"

func _remove_key() -> void:
	var selected := key_list.get_selected_items()
	if selected.is_empty():
		return
	key_rows.remove_at(selected[0])
	_sync_selected_track_keys()
	_refresh_keys()
	_update_preview()
	status_label.text = "Key removed"

func _sync_selected_track_keys() -> void:
	var selected := track_list.get_selected_items()
	if selected.is_empty():
		return
	track_rows[selected[0]]["keys"] = key_rows.duplicate(true)

func _add_track() -> void:
	var property_name := track_property_edit.text.strip_edges()
	var start_time := float(track_start_edit.value)
	var end_time := float(track_end_edit.value)
	if property_name.is_empty():
		status_label.text = "ERROR: Track property is required"
		return
	if start_time < 0.0 or end_time <= start_time or end_time > float(timeline_duration_edit.value):
		status_label.text = "ERROR: Track range is invalid"
		return
	track_rows.append({"property": property_name, "start": start_time, "end": end_time, "keys": []})
	_refresh_tracks()
	track_list.select(track_rows.size() - 1)
	key_rows = []
	_refresh_keys()
	_update_preview()
	status_label.text = "Track added"

func _remove_track() -> void:
	var selected := track_list.get_selected_items()
	if selected.is_empty():
		return
	track_rows.remove_at(selected[0])
	_refresh_tracks()
	_update_preview()
	status_label.text = "Track removed"

func _build_timeline() -> Dictionary:
	_sync_selected_track_keys()
	return {
		"duration": float(timeline_duration_edit.value),
		"loop": timeline_loop.button_pressed,
		"playback": timeline_playback.get_item_text(timeline_playback.selected).to_lower(),
		"tracks": track_rows.duplicate(true)
	}

func _build_transform() -> Dictionary:
	return {
		"space": transform_space.get_item_text(transform_space.selected).to_lower(),
		"anchor": transform_anchor.text.strip_edges(),
		"offset": {"x": float(transform_offset_x.value), "y": float(transform_offset_y.value)},
		"rotation": float(transform_rotation.value),
		"scale": float(transform_scale.value)
	}

func _save_definition() -> void:
	var id := id_edit.text.strip_edges()
	if id.is_empty():
		status_label.text = "ERROR: VFX ID is required"
		return
	if current_id != "" and current_id != id:
		status_label.text = "ERROR: ID rename is not supported; create a new definition"
		return
	var definition = VFXDefinitionScript.from_dict({
		"id": id, "name": name_edit.text, "category": category_edit.text,
		"schema_version": 1, "revision": int(revision_edit.value),
		"status": status_edit.get_item_text(status_edit.selected),
		"description": description_edit.text,
		"components": component_rows.duplicate(true),
		"timeline": _build_timeline(),
		"transform": _build_transform(),
		"parameters": {},
		"visual_resource_refs": _parse_json_array(resources_edit.text),
		"priority": int(priority_edit.value), "concurrency": concurrency_edit.text.strip_edges(),
		"max_instances": int(max_instances_edit.value)
	})
	var errors: Array[String] = []
	_validate_definition(definition, errors)
	if not errors.is_empty():
		status_label.text = "ERROR: " + errors[0]
		return
	if not repository.save_definition(definition):
		status_label.text = "ERROR: Save failed"
		return
	current_id = id
	_refresh()
	_update_preview()
	status_label.text = "Saved: %s" % id

func _parse_json_array(text: String) -> Array:
	var parsed = JSON.parse_string(text)
	return parsed if parsed is Array else []

func _validate_definition(definition, errors: Array[String]) -> void:
	if definition.id.is_empty() or definition.category.is_empty():
		errors.append("VFX ID and Category are required")
	if definition.revision < 1:
		errors.append("Revision must be >= 1")
	if definition.status not in ["Draft", "Review", "Validated", "Production", "Deprecated"]:
		errors.append("Invalid status")
	if definition.priority < 0 or definition.max_instances < 0:
		errors.append("Runtime policy value is invalid")
	if float(definition.timeline.get("duration", 0.0)) <= 0.0:
		errors.append("Timeline duration must be > 0")
	if definition.timeline.get("playback", "") not in ["once", "loop", "ping_pong"]:
		errors.append("Invalid timeline playback")
	var validated_tracks = definition.timeline.get("tracks", [])
	if not (validated_tracks is Array):
		errors.append("Timeline tracks must be an array")
		validated_tracks = []
	for track in validated_tracks:
		if not (track is Dictionary):
			errors.append("Timeline track must be an object")
			continue
		var start_time := float(track.get("start", -1.0))
		var end_time := float(track.get("end", -1.0))
		if str(track.get("property", "")).strip_edges().is_empty() or start_time < 0.0 or end_time <= start_time or end_time > float(definition.timeline.get("duration", 0.0)):
			errors.append("Timeline track is invalid")
		var validated_keys = track.get("keys", [])
		if not (validated_keys is Array):
			errors.append("Timeline track keys must be an array")
			validated_keys = []
		for key in validated_keys:
			if not (key is Dictionary):
				errors.append("Timeline key must be an object")
				continue
			var key_time := float(key.get("time", -1.0))
			if key_time < start_time or key_time > end_time:
				errors.append("Timeline key time is outside Track range")
			if str(key.get("value", "")).strip_edges().is_empty():
				errors.append("Timeline key value is required")
			if str(key.get("interpolation", "linear")) not in ["linear", "step", "ease_in", "ease_out"]:
				errors.append("Timeline key interpolation is invalid")
	var transform: Dictionary = definition.transform
	if str(transform.get("space", "")) not in ["world", "attached", "local", "screen"] or float(transform.get("scale", 0.0)) <= 0.0:
		errors.append("Transform is invalid")
	for component in definition.components:
		if not (component is Dictionary) or str(component.get("type", "")).strip_edges().is_empty():
			errors.append("Every component requires a type")
	for resource_id in definition.visual_resource_refs:
		var ref := str(resource_id).strip_edges()
		if ref.is_empty():
			errors.append("Visual resource reference cannot be empty")
		elif not ref.begins_with("res://") and not ContentCatalogLoader.load_dictionary_catalog("visual_assets").has(ref):
			errors.append("Missing Visual Asset: %s" % ref)

func _delete_definition() -> void:
	if current_id.is_empty():
		return
	var deleted_id := current_id
	if repository.delete_definition(deleted_id):
		_refresh()
		_new_definition()
		status_label.text = "Deleted: %s" % deleted_id
	else:
		status_label.text = "ERROR: Delete failed"

func _preview_play() -> void:
	preview_duration = maxf(float(timeline_duration_edit.value), 0.01)
	preview_playing = true
	_update_preview()

func _preview_stop() -> void:
	preview_playing = false
	_update_preview()

func _preview_restart() -> void:
	preview_time = 0.0
	preview_duration = maxf(float(timeline_duration_edit.value), 0.01)
	preview_playing = true
	$MainLayout/Body/PreviewPanel/PreviewVBox/Controls/Scrub.value = 0.0
	_update_preview()

func _preview_scrub(value: float) -> void:
	preview_time = clampf(value, 0.0, preview_duration)
	preview_playing = false
	_update_preview()

func _preview_definition():
	return VFXDefinitionScript.from_dict({
		"id": id_edit.text.strip_edges(),
		"name": name_edit.text,
		"category": category_edit.text,
		"schema_version": 1,
		"revision": int(revision_edit.value),
		"status": status_edit.get_item_text(status_edit.selected),
		"description": description_edit.text,
		"components": component_rows.duplicate(true),
		"timeline": _build_timeline(),
		"transform": _build_transform(),
		"parameters": {},
		"visual_resource_refs": _parse_json_array(resources_edit.text),
		"priority": int(priority_edit.value),
		"concurrency": concurrency_edit.text.strip_edges(),
		"max_instances": int(max_instances_edit.value)
	})

func _sync_preview_adapter() -> void:
	var definition = _preview_definition()
	preview_adapter.configure(definition)
	preview_adapter.seek(preview_time)
	preview_adapter.playing = preview_playing

func _update_preview() -> void:
	if not is_instance_valid(preview_canvas):
		return
	preview_duration = maxf(float(timeline_duration_edit.value), 0.01)
	_sync_preview_adapter()
	$MainLayout/Body/PreviewPanel/PreviewVBox/Controls/Scrub.max_value = preview_duration
	preview_canvas.queue_redraw()
	preview_status.text = "t=%.2f / %.2f  |  %s" % [preview_time, preview_duration, "Playing" if preview_playing else "Stopped"]

func _on_preview_canvas_draw() -> void:
	var center := preview_canvas.size * 0.5
	var commands := preview_adapter.render_commands()
	for command in commands:
		var position: Vector2 = center + command.get("position", Vector2.ZERO)
		var scale := maxf(0.01, float(command.get("scale", 1.0)))
		var rotation := float(command.get("rotation", 0.0))
		var alpha := clampf(float(command.get("opacity", 1.0)), 0.0, 1.0)
		match str(command.get("type", "")):
			"ring":
				preview_canvas.draw_arc(position, 36.0 * scale, 0.0, TAU, 48, Color(0.95, 0.7, 0.25, alpha), 4.0)
			"shape":
				preview_canvas.draw_circle(position, 24.0 * scale, Color(0.35, 0.75, 1.0, alpha))
			"line", "trail", "beam":
				var direction := Vector2(cos(rotation), sin(rotation))
				preview_canvas.draw_line(position - direction * 45.0 * scale, position + direction * 45.0 * scale, Color(0.65, 0.9, 1.0, alpha), 6.0 * scale)
			"sprite":
				preview_canvas.draw_circle(position, 20.0 * scale, Color(0.9, 0.9, 0.9, alpha))
			"unsupported":
				preview_canvas.draw_circle(position, 14.0 * scale, Color(0.6, 0.6, 0.6, alpha))
	preview_canvas.draw_line(center - Vector2(45, 0), center + Vector2(45, 0), Color(0.35, 0.35, 0.35, 0.6), 1.0)
	preview_canvas.draw_line(center - Vector2(0, 45), center + Vector2(0, 45), Color(0.35, 0.35, 0.35, 0.6), 1.0)
