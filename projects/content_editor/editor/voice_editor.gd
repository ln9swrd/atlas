extends Control
const RepositoryScript = preload("res://scripts/voice_definition_repository.gd")
const DefinitionScript = preload("res://scripts/voice_definition.gd")
const ValidatorScript = preload("res://editor/voice_validator.gd")
const AdapterScript = preload("res://scripts/voice_runtime_adapter.gd")
var repository = RepositoryScript
var current_id := ""
@onready var list: ItemList = $Root/Body/ListPanel/List
@onready var id_edit: LineEdit = $Root/Body/Editor/Fields/ID
@onready var dialogue_edit: LineEdit = $Root/Body/Editor/Fields/DialogueID
@onready var profile_edit: LineEdit = $Root/Body/Editor/Fields/VoiceProfileID
@onready var asset_edit: LineEdit = $Root/Body/Editor/Fields/VoiceAsset
@onready var language_edit: LineEdit = $Root/Body/Editor/Fields/Language
@onready var volume_edit: SpinBox = $Root/Body/Editor/Fields/Volume
@onready var bus_edit: LineEdit = $Root/Body/Editor/Fields/Bus
@onready var status_label: Label = $Root/Status
func _ready() -> void:
	$Root/Body/ListPanel/Buttons/New.pressed.connect(_new_definition)
	$Root/Body/ListPanel/Buttons/Refresh.pressed.connect(_refresh)
	$Root/Body/Editor/Fields/Buttons/Save.pressed.connect(_save)
	$Root/Body/Editor/Fields/Buttons/Delete.pressed.connect(_delete)
	$Root/Body/Editor/Fields/Buttons/Preview.pressed.connect(_preview)
	list.item_selected.connect(_select)
	repository.reload(); _refresh(); _new_definition()
func _refresh() -> void:
	list.clear()
	for id in repository.list():
		var d = repository.get_definition(id); list.add_item("%s  [%s]" % [id, d.status])
	status_label.text = "Voice Definitions: %d" % list.item_count
func _new_definition() -> void:
	current_id=""; id_edit.text=""; dialogue_edit.text=""; profile_edit.text=""; asset_edit.text=""; language_edit.text="ko"; volume_edit.value=1.0; bus_edit.text="Master"; status_label.text="New Voice Definition"
func _select(index:int)->void:
	var id:=list.get_item_text(index).split("  [")[0]; var d=repository.get_definition(id)
	if d==null:return
	current_id=d.id; id_edit.text=d.id; dialogue_edit.text=d.dialogue_id; profile_edit.text=d.voice_profile_id; asset_edit.text=d.voice_asset; language_edit.text=d.language; volume_edit.value=d.volume; bus_edit.text=d.bus; status_label.text="Loaded: %s"%d.id
func _collect():
	return DefinitionScript.from_dict({"id":id_edit.text.strip_edges(),"dialogue_id":dialogue_edit.text.strip_edges(),"voice_profile_id":profile_edit.text.strip_edges(),"voice_asset":asset_edit.text.strip_edges(),"language":language_edit.text.strip_edges(),"volume":volume_edit.value,"bus":bus_edit.text.strip_edges(),"status":"Draft"})
func _save()->void:
	var d=_collect(); var errors:Array=[]; var warnings:Array=[]; ValidatorScript.validate_definition(d,errors,warnings)
	if not errors.is_empty(): status_label.text="INVALID: "+errors[0]; return
	if not repository.save_definition(d): status_label.text="SAVE FAILED"; return
	current_id=d.id; _refresh(); status_label.text="Saved: %s"%d.id
func _delete()->void:
	if current_id.is_empty():return
	if not repository.delete_definition(current_id):status_label.text="DELETE FAILED";return
	_refresh(); _new_definition()
func _preview()->void:
	var d=_collect(); var adapter=AdapterScript.new(); adapter.configure(d)
	if not adapter.play(self): status_label.text="PREVIEW UNRESOLVED ??silent fallback"; return
	status_label.text="Preview: %s"%d.voice_asset
