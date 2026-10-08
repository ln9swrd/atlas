extends Control

const RepositoryScript = preload("res://scripts/sfx_definition_repository.gd")
const DefinitionScript = preload("res://scripts/sfx_definition.gd")
const ValidatorScript = preload("res://editor/sfx_validator.gd")

var repository = RepositoryScript
var current_id := ""

@onready var list: ItemList = $Root/Body/ListPanel/List
@onready var id_edit: LineEdit = $Root/Body/Editor/Fields/ID
@onready var name_edit: LineEdit = $Root/Body/Editor/Fields/Name
@onready var category_edit: LineEdit = $Root/Body/Editor/Fields/Category
@onready var asset_edit: LineEdit = $Root/Body/Editor/Fields/AudioAsset
@onready var volume_edit: SpinBox = $Root/Body/Editor/Fields/Volume
@onready var pitch_edit: SpinBox = $Root/Body/Editor/Fields/Pitch
@onready var bus_edit: LineEdit = $Root/Body/Editor/Fields/Bus
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
	for sfx_id in repository.list():
		var d = repository.get_definition(sfx_id)
		if d != null:
			list.add_item("%s  [%s]" % [d.id, d.status])
	status_label.text = "SFX Definitions: %d" % list.item_count

func _new_definition() -> void:
	current_id = ""
	id_edit.text = ""
	name_edit.text = ""
	category_edit.text = "generic"
	asset_edit.text = ""
	volume_edit.value = 1.0
	pitch_edit.value = 1.0
	bus_edit.text = "SFX"
	status_label.text = "New SFX Definition"

func _select(index: int) -> void:
	var label := list.get_item_text(index)
	var id := label.split("  [")[0]
	var d = repository.get_definition(id)
	if d == null:
		return
	current_id = d.id
	id_edit.text = d.id
	name_edit.text = d.name
	category_edit.text = d.category
	asset_edit.text = d.audio_asset
	volume_edit.value = d.volume
	pitch_edit.value = d.pitch
	bus_edit.text = d.bus
	status_label.text = "Loaded: %s" % d.id

func _collect():
	return DefinitionScript.from_dict({
		"id": id_edit.text.strip_edges(),
		"name": name_edit.text.strip_edges(),
		"category": category_edit.text.strip_edges(),
		"status": "Draft",
		"audio_asset": asset_edit.text.strip_edges(),
		"volume": volume_edit.value,
		"pitch": pitch_edit.value,
		"bus": bus_edit.text.strip_edges(),
		"playback": "one_shot",
		"spatial_mode": "screen"
	})

func _save() -> void:
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
	if not repository.delete_definition(current_id):
		status_label.text = "DELETE FAILED"
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
	preview.volume_db = linear_to_db(maxf(d.volume, 0.0001))
	preview.pitch_scale = maxf(d.pitch, 0.01)
	preview.play()
	status_label.text = "Preview: %s" % d.audio_asset
