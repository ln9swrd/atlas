extends Control

signal request_content_editor
const CAMPAIGN_ID := "main_campaign"
var document: Dictionary = {}
var stage_entries: Array[Dictionary] = []
var available_stage_ids: Array[String] = []
var mission_ids: Array[String] = []
var mission_catalog: Dictionary = {}
var selected_entry_index: int = -1
var rebuilding: bool = false

@onready var name_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/NameEdit
@onready var stage_list: ItemList = $MainLayout/Body/EditorPanel/Fields/StageList
@onready var source_stage_option: OptionButton = $MainLayout/Body/EditorPanel/Fields/SelectedStageFields/SourceStageRow/SourceStageOption
@onready var mission_option: OptionButton = $MainLayout/Body/EditorPanel/Fields/SelectedStageFields/MissionRow/MissionOption
@onready var status_label: Label = $MainLayout/Status

func _ready() -> void:
	$MainLayout/Body/EditorPanel/Fields/Buttons/ReloadButton.pressed.connect(_reload)
	$MainLayout/Body/EditorPanel/Fields/Buttons/SaveButton.pressed.connect(_save)
	$MainLayout/Body/EditorPanel/Fields/StageActions/AddStageButton.pressed.connect(_add_stage)
	$MainLayout/Body/EditorPanel/Fields/StageActions/DeleteStageButton.pressed.connect(_delete_selected_stage)
	stage_list.item_selected.connect(_on_stage_selected)
	source_stage_option.item_selected.connect(_on_source_stage_changed)
	mission_option.item_selected.connect(_on_mission_changed)
	_reload()

func _reload() -> void:
	document = ContentCatalogLoader.load_document("campaign")
	if document.is_empty():
		document = {"campaign_id": CAMPAIGN_ID, "name": "", "stages": []}
	name_edit.text = str(document.get("name", ""))
	stage_entries.clear()
	var stored_stages: Variant = document.get("stages", [])
	var stored_mapping: Variant = document.get("stage_missions", {})
	var stored_entry_missions: Variant = document.get("stage_mission_entries", [])
	if stored_stages is Array:
		for i in range(stored_stages.size()):
			var raw_stage_id: Variant = stored_stages[i]
			var stage_id: String = str(raw_stage_id).strip_edges()
			if raw_stage_id is int or raw_stage_id is float:
				stage_id = ContentCatalogLoader.resolve_odb_pk("stage", int(raw_stage_id))
			if stage_id.is_empty():
				continue
			var mission_id: String = ""
			if stored_entry_missions is Array and i < stored_entry_missions.size():
				var entry: Variant = stored_entry_missions[i]
				if entry is Dictionary:
					mission_id = str(entry.get("mission_id", ""))
			if mission_id.is_empty() and stored_mapping is Dictionary:
				mission_id = str(stored_mapping.get(stage_id, ""))
			if mission_id.is_empty():
				var stage_doc: Dictionary = ContentCatalogLoader.load_document(StageLoader.resolve_stage_path(stage_id))
				mission_id = str(stage_doc.get("mission_id", ""))
			stage_entries.append({"stage_id": stage_id, "mission_id": mission_id})
	_refresh_available_stages()
	_refresh_missions()
	_rebuild_stage_list()
	if not stage_entries.is_empty():
		stage_list.select(0)
		_on_stage_selected(0)
	else:
		_clear_selected_stage()
	status_label.text = "Loaded campaign: %s" % CAMPAIGN_ID

func _normalize_mission_id(value: Variant) -> String:
	if value is int or value is float:
		return ContentCatalogLoader.resolve_odb_pk("mission", int(value))
	return str(value).strip_edges()

func _refresh_available_stages() -> void:
	available_stage_ids = _stage_ids_from_authoring_catalog()
	available_stage_ids.sort()
	source_stage_option.clear()
	for stage_id in available_stage_ids:
		source_stage_option.add_item(stage_id)
		source_stage_option.set_item_metadata(source_stage_option.item_count - 1, stage_id)
	source_stage_option.disabled = source_stage_option.item_count == 0
	$MainLayout/Body/EditorPanel/Fields/StageActions/AddStageButton.disabled = source_stage_option.item_count == 0

func _refresh_missions() -> void:
	mission_catalog = ContentCatalogLoader.load_dictionary_catalog("missions")
	mission_ids.clear()
	for key in mission_catalog.keys():
		mission_ids.append(str(key))
	mission_ids.sort()
	mission_option.clear()
	for mission_id in mission_ids:
		var data: Dictionary = mission_catalog.get(mission_id, {})
		mission_option.add_item("%s [%s]" % [str(data.get("title", mission_id)), mission_id])
		mission_option.set_item_metadata(mission_option.item_count - 1, mission_id)
	mission_option.disabled = mission_option.item_count == 0

func _stage_ids_from_authoring_catalog() -> Array[String]:
	var catalog: Dictionary = ContentCatalogLoader.load_document("stage_catalog")
	var result: Array[String] = []
	var values: Variant = catalog.get("stages", [])
	if values is Array:
		for value in values:
			var stage_id: String = str(value).strip_edges()
			if not stage_id.is_empty() and not result.has(stage_id):
				result.append(stage_id)
	return result

func _add_stage() -> void:
	if available_stage_ids.is_empty() or mission_ids.is_empty():
		status_label.text = "ERROR: at least one stage and one mission are required."
		return
	var source_index: int = maxi(0, source_stage_option.selected)
	var stage_id: String = str(source_stage_option.get_item_metadata(source_index))
	var mission_index: int = maxi(0, mission_option.selected)
	var mission_id: String = str(mission_option.get_item_metadata(mission_index))
	if stage_entries.any(func(entry: Dictionary) -> bool: return str(entry.get("stage_id", "")) == stage_id):
		status_label.text = "ERROR: stage is already in the campaign: %s" % stage_id
		return
	stage_entries.append({"stage_id": stage_id, "mission_id": mission_id})
	selected_entry_index = stage_entries.size() - 1
	_rebuild_stage_list()
	stage_list.select(selected_entry_index)
	_on_stage_selected(selected_entry_index)
	status_label.text = "Added Campaign Stage %02d" % (selected_entry_index + 1)

func _rebuild_stage_list() -> void:
	rebuilding = true
	stage_list.clear()
	for i in range(stage_entries.size()):
		var entry: Dictionary = stage_entries[i]
		var stage_id: String = str(entry.get("stage_id", ""))
		var mission_id: String = str(entry.get("mission_id", ""))
		var mission_data: Dictionary = mission_catalog.get(mission_id, {})
		stage_list.add_item("Stage %02d  |  %s  |  %s" % [i + 1, stage_id, str(mission_data.get("title", mission_id))])
	if selected_entry_index >= 0 and selected_entry_index < stage_entries.size():
		stage_list.select(selected_entry_index)
	rebuilding = false

func _on_stage_selected(index: int) -> void:
	if rebuilding or index < 0 or index >= stage_entries.size():
		return
	selected_entry_index = index
	var entry: Dictionary = stage_entries[index]
	_select_option_by_metadata(source_stage_option, str(entry.get("stage_id", "")))
	_select_option_by_metadata(mission_option, str(entry.get("mission_id", "")))
	$MainLayout/Body/EditorPanel/Fields/SelectedStageLabel.text = "Selected: Stage %02d" % (index + 1)
	$MainLayout/Body/EditorPanel/Fields/StageActions/DeleteStageButton.disabled = false

func _select_option_by_metadata(option: OptionButton, value: String) -> void:
	for i in range(option.item_count):
		if str(option.get_item_metadata(i)) == value:
			option.select(i)
			return
	if option.item_count > 0:
		option.select(0)

func _on_source_stage_changed(index: int) -> void:
	if selected_entry_index < 0 or selected_entry_index >= stage_entries.size() or index < 0:
		return
	stage_entries[selected_entry_index]["stage_id"] = str(source_stage_option.get_item_metadata(index))
	_rebuild_stage_list()

func _on_mission_changed(index: int) -> void:
	if selected_entry_index < 0 or selected_entry_index >= stage_entries.size() or index < 0:
		return
	stage_entries[selected_entry_index]["mission_id"] = str(mission_option.get_item_metadata(index))
	_rebuild_stage_list()

func _delete_selected_stage() -> void:
	if selected_entry_index < 0 or selected_entry_index >= stage_entries.size():
		status_label.text = "Select a campaign stage to delete."
		return
	var removed_index: int = selected_entry_index
	stage_entries.remove_at(removed_index)
	selected_entry_index = -1
	_rebuild_stage_list()
	if not stage_entries.is_empty():
		var next_index: int = mini(removed_index, stage_entries.size() - 1)
		stage_list.select(next_index)
		_on_stage_selected(next_index)
	else:
		_clear_selected_stage()
	status_label.text = "Deleted campaign stage."

func _clear_selected_stage() -> void:
	selected_entry_index = -1
	$MainLayout/Body/EditorPanel/Fields/SelectedStageLabel.text = "Select a campaign stage"
	$MainLayout/Body/EditorPanel/Fields/StageActions/DeleteStageButton.disabled = true
	if source_stage_option.item_count > 0:
		source_stage_option.select(0)
	if mission_option.item_count > 0:
		mission_option.select(0)

func _save() -> void:
	var campaign_name: String = name_edit.text.strip_edges()
	if campaign_name.is_empty():
		status_label.text = "ERROR: campaign name is required"
		return
	if stage_entries.is_empty():
		status_label.text = "ERROR: add at least one stage"
		return
	var stage_catalog := ContentCatalogLoader.load_document("stage_catalog")
	var valid_ids: Dictionary = {}
	var values: Variant = stage_catalog.get("stages", [])
	if values is Array:
		for value in values:
			valid_ids[str(value)] = true
	var stage_pks: Array[int] = []
	var entry_missions: Array[Dictionary] = []
	var legacy_missions: Dictionary = {}
	for entry in stage_entries:
		var stage_id: String = str(entry.get("stage_id", ""))
		var mission_id: String = str(entry.get("mission_id", ""))
		if not valid_ids.has(stage_id):
			status_label.text = "ERROR: stage is not registered in Content Editor SQLite. Import Runtime Data first: %s" % stage_id
			return
		if not mission_catalog.has(mission_id):
			status_label.text = "ERROR: choose a valid mission for %s" % stage_id
			return
		var stage_pk: int = ContentCatalogLoader.resolve_odb_pk_from_legacy("stage", stage_id)
		if stage_pk < 1:
			status_label.text = "ERROR: stage is not registered in Content Editor database: %s" % stage_id
			return
		stage_pks.append(stage_pk)
		entry_missions.append({"stage_id": stage_id, "mission_id": mission_id})
		if not legacy_missions.has(stage_id):
			legacy_missions[stage_id] = mission_id
	var next_document: Dictionary = document.duplicate(true)
	next_document["campaign_id"] = CAMPAIGN_ID
	next_document["name"] = campaign_name
	next_document["stages"] = stage_pks
	next_document["stage_missions"] = legacy_missions
	next_document["stage_mission_entries"] = entry_missions
	if not ObjectPersistence.save_content_document("campaign", next_document):
		status_label.text = "ERROR: campaign SQLite save failed"
		return
	document = ContentCatalogLoader.load_document("campaign")
	status_label.text = "Saved campaign with %d stages to Content Editor SQLite." % stage_entries.size()
