extends Control

signal request_content_editor

const CAMPAIGN_ID := "main_campaign"

var document: Dictionary = {}

@onready var name_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/NameEdit
@onready var stages_edit: TextEdit = $MainLayout/Body/EditorPanel/Fields/StagesEdit
@onready var status_label: Label = $MainLayout/Status

func _ready() -> void:
	$MainLayout/Body/EditorPanel/Fields/Buttons/ReloadButton.pressed.connect(_reload)
	$MainLayout/Body/EditorPanel/Fields/Buttons/SaveButton.pressed.connect(_save)
	_reload()

func _reload() -> void:
	document = ContentCatalogLoader.load_document("campaign")
	if document.is_empty():
		document = {"campaign_id": CAMPAIGN_ID, "name": "", "stages": []}
	name_edit.text = str(document.get("name", ""))
	stages_edit.text = "\n".join(_stage_ids_from_document())
	status_label.text = "Loaded from SQLite: %s" % CAMPAIGN_ID

func _stage_ids_from_document() -> Array[String]:
	var result: Array[String] = []
	var value = document.get("stages", [])
	if value is Array:
		for entry in value:
			var stage_id := str(entry).strip_edges()
			if entry is int or entry is float:
				stage_id = ContentCatalogLoader.resolve_odb_pk("stage", int(entry))
			if not stage_id.is_empty():
				result.append(stage_id)
	return result

func _save() -> void:
	var name := name_edit.text.strip_edges()
	var stage_ids := _parse_stage_ids()
	if name.is_empty():
		status_label.text = "ERROR: campaign name is required"
		return
	if stage_ids.is_empty():
		status_label.text = "ERROR: at least one stage is required"
		return
	var stage_catalog := ContentCatalogLoader.load_document("stage_catalog")
	var valid_ids := {}
	var catalog_stages = stage_catalog.get("stages", [])
	if catalog_stages is Array:
		for entry in catalog_stages:
			valid_ids[str(entry)] = true
	for stage_id in stage_ids:
		if not valid_ids.has(stage_id):
			status_label.text = "ERROR: unknown stage: %s" % stage_id
			return
	var next_document := document.duplicate(true)
	next_document["campaign_id"] = CAMPAIGN_ID
	next_document["name"] = name
	var stage_pks: Array[int] = []
	for stage_id in stage_ids:
		var stage_pk := ContentCatalogLoader.resolve_odb_pk("stage", int(stage_id)) if stage_id.is_valid_int() else -1
		if stage_pk < 1:
			status_label.text = "ERROR: stage has no ODB PK: %s" % stage_id
			return
		stage_pks.append(stage_pk)
	next_document["stages"] = stage_pks
	if not ObjectPersistence.save_content_document("campaign", next_document):
		status_label.text = "ERROR: SQLite save failed"
		return
	document = ContentCatalogLoader.load_document("campaign")
	name_edit.text = str(document.get("name", ""))
	stages_edit.text = "\n".join(_stage_ids_from_document())
	status_label.text = "Saved to SQLite: %s" % CAMPAIGN_ID

func _parse_stage_ids() -> Array[String]:
	var result: Array[String] = []
	for line in stages_edit.text.split("\n"):
		var stage_id := line.strip_edges()
		if stage_id.is_empty():
			continue
		if not result.has(stage_id):
			result.append(stage_id)
	return result
