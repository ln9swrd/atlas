extends Control

const RepositoryScript = preload("res://scripts/bgm_definition_repository.gd")
const DefinitionScript = preload("res://scripts/bgm_definition.gd")
const ValidatorScript = preload("res://editor/bgm_validator.gd")

var repository = RepositoryScript
var current_id := ""

@onready var list: ItemList = $Root/Body/ListPanel/List
@onready var id_edit: LineEdit = $Root/Body/Editor/Fields/ID
@onready var name_edit: LineEdit = $Root/Body/Editor/Fields/Name
@onready var faction_edit: LineEdit = $Root/Body/Editor/Fields/Faction
@onready var context_edit: LineEdit = $Root/Body/Editor/Fields/Context
@onready var asset_edit: LineEdit = $Root/Body/Editor/Fields/AudioAsset
@onready var loop_check: CheckButton = $Root/Body/Editor/Fields/Loop
@onready var loop_point_edit: SpinBox = $Root/Body/Editor/Fields/LoopPoint
@onready var duration_edit: SpinBox = $Root/Body/Editor/Fields/Duration
@onready var bpm_edit: SpinBox = $Root/Body/Editor/Fields/BPM
@onready var transition_edit: LineEdit = $Root/Body/Editor/Fields/Transition
@onready var crossfade_edit: SpinBox = $Root/Body/Editor/Fields/Crossfade
@onready var volume_edit: SpinBox = $Root/Body/Editor/Fields/Volume
@onready var bus_edit: LineEdit = $Root/Body/Editor/Fields/Bus
@onready var priority_edit: SpinBox = $Root/Body/Editor/Fields/Priority
@onready var variant_edit: LineEdit = $Root/Body/Editor/Fields/Variant
@onready var approval_edit: LineEdit = $Root/Body/Editor/Fields/ApprovalStatus
@onready var lock_check: CheckButton = $Root/Body/Editor/Fields/ProductionLock
@onready var status_label: Label = $Root/Status
@onready var preview: AudioStreamPlayer = $Preview

func _ready() -> void:
	$Root/Body/ListPanel/Buttons/New.pressed.connect(_new_definition)
	$Root/Body/ListPanel/Buttons/Refresh.pressed.connect(_refresh)
	$Root/Body/Editor/Buttons/Save.pressed.connect(_save)
	$Root/Body/Editor/Buttons/Delete.pressed.connect(_delete)
	$Root/Body/Editor/Buttons/Preview.pressed.connect(_preview)
	list.item_selected.connect(_select)
	repository.reload()
	_refresh()
	_new_definition()

func _refresh() -> void:
	list.clear()
	for bgm_id in repository.list():
		var d = repository.get_definition(bgm_id)
		if d != null:
			list.add_item("%s  [%s/%s]" % [d.id, d.faction, d.context])
	status_label.text = "BGM Definitions: %d" % list.item_count

func _new_definition() -> void:
	current_id = ""
	id_edit.text = ""
	name_edit.text = ""
	faction_edit.text = "FACTION_01"
	context_edit.text = "COMBAT"
	asset_edit.text = ""
	loop_check.button_pressed = true
	loop_point_edit.value = 0.0
	duration_edit.value = 0.0
	bpm_edit.value = 0.0
	transition_edit.text = "crossfade"
	crossfade_edit.value = 1.0
	volume_edit.value = 1.0
	bus_edit.text = "BGM"
	priority_edit.value = 0
	variant_edit.text = ""
	approval_edit.text = "UNVERIFIED"
	lock_check.button_pressed = false
	status_label.text = "New BGM Definition"

func _select(index: int) -> void:
	var id := list.get_item_text(index).split("  [")[0]
	var d = repository.get_definition(id)
	if d == null:
		return
	current_id = d.id
	id_edit.text = d.id
	name_edit.text = d.name
	faction_edit.text = d.faction
	context_edit.text = d.context
	asset_edit.text = d.audio_asset
	loop_check.button_pressed = d.loop
	loop_point_edit.value = d.loop_point
	duration_edit.value = d.duration
	bpm_edit.value = d.bpm
	transition_edit.text = d.transition
	crossfade_edit.value = d.crossfade_seconds
	volume_edit.value = d.volume
	bus_edit.text = d.bus
	priority_edit.value = d.priority
	variant_edit.text = d.variant
	approval_edit.text = d.approval_status
	lock_check.button_pressed = d.production_lock
	status_label.text = "Loaded: %s" % d.id

func _collect():
	var existing = repository.get_definition(current_id) if not current_id.is_empty() else null
	var revision := int(existing.revision) if existing != null else 1
	return DefinitionScript.from_dict({
		"id": id_edit.text.strip_edges(),
		"name": name_edit.text.strip_edges(),
		"faction": faction_edit.text.strip_edges(),
		"context": context_edit.text.strip_edges().to_upper(),
		"schema_version": 1,
		"revision": revision,
		"status": "Draft",
		"audio_asset": asset_edit.text.strip_edges(),
		"loop": loop_check.button_pressed,
		"loop_point": loop_point_edit.value,
		"duration": duration_edit.value,
		"bpm": bpm_edit.value,
		"transition": transition_edit.text.strip_edges(),
		"crossfade_seconds": crossfade_edit.value,
		"volume": volume_edit.value,
		"bus": bus_edit.text.strip_edges(),
		"priority": int(priority_edit.value),
		"variant": variant_edit.text.strip_edges(),
		"approval_status": approval_edit.text.strip_edges().to_upper(),
		"production_lock": lock_check.button_pressed
	})

func _save() -> void:
	var existing = repository.get_definition(current_id) if not current_id.is_empty() else null
	if existing != null and bool(existing.production_lock):
		status_label.text = "SAVE BLOCKED: PRODUCTION LOCK"
		return
	var d = _collect()
	var errors: Array = []
	var warnings: Array = []
	ValidatorScript.validate_definition(d, errors, warnings)
	if not errors.is_empty():
		status_label.text = "INVALID: " + errors[0]
		return
	if not repository.save_definition(d):
		status_label.text = "SAVE FAILED"
		return
	current_id = d.id
	_refresh()
	status_label.text = "Saved: %s" % d.id

func _delete() -> void:
	if current_id.is_empty():
		return
	var existing = repository.get_definition(current_id)
	if existing != null and bool(existing.production_lock):
		status_label.text = "DELETE BLOCKED: PRODUCTION LOCK"
		return
	if not repository.delete_definition(current_id):
		status_label.text = "DELETE BLOCKED: REFERENCED OR FAILED"
		return
	_refresh()
	_new_definition()

func _preview() -> void:
	var d = _collect()
	if d == null or d.audio_asset.is_empty() or not ResourceLoader.exists(d.audio_asset):
		status_label.text = "PREVIEW UNRESOLVED"
		return
	var stream = load(d.audio_asset) as AudioStream
	if stream == null:
		status_label.text = "PREVIEW INVALID AUDIO"
		return
	preview.stream = stream
	preview.bus = d.bus
	preview.volume_db = linear_to_db(maxf(d.volume, 0.0001))
	preview.play()
	status_label.text = "Preview: %s" % d.audio_asset
