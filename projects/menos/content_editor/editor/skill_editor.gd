extends Control

var catalog: Dictionary = {}
var selected_id := ""

@onready var skill_list: ItemList = $MainLayout/Body/SkillList
@onready var id_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/IdEdit
@onready var name_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/NameEdit
@onready var desc_edit: TextEdit = $MainLayout/Body/EditorPanel/Fields/DescriptionEdit
@onready var growth_check: CheckButton = $MainLayout/Body/EditorPanel/Fields/GrowthCheck
@onready var execution_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/ExecutionEdit
@onready var damage_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/DamageEdit
@onready var radius_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/RadiusEdit
@onready var cooldown_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/CooldownEdit
@onready var energy_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/EnergyEdit
@onready var duration_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/DurationEdit
@onready var status_label: Label = $MainLayout/Status

const NUMERIC_FIELDS := ["damage", "radius", "cooldown", "energy_cost", "duration", "threshold", "meter_max", "charge_normal", "charge_boss"]

func _ready() -> void:
	_load_catalog()
	skill_list.item_selected.connect(_select_skill)
	$MainLayout/Body/EditorPanel/Fields/Buttons/NewButton.pressed.connect(_new_skill)
	$MainLayout/Body/EditorPanel/Fields/Buttons/SaveButton.pressed.connect(_save_skill)
	$MainLayout/Body/EditorPanel/Fields/Buttons/DeleteButton.pressed.connect(_delete_skill)
	_clear_editor()
	_refresh_list()

func _load_catalog() -> void:
	catalog = ContentCatalogLoader.load_dictionary_catalog("skills")

func _refresh_list() -> void:
	skill_list.clear()
	var ids: Array[String] = []
	for key in catalog.keys():
		ids.append(str(key))
	ids.sort()
	for skill_id in ids:
		var data: Dictionary = catalog.get(skill_id, {})
		skill_list.add_item("%s  [%s]" % [str(data.get("name", skill_id)), skill_id])
		skill_list.set_item_metadata(skill_list.item_count - 1, skill_id)

func _select_skill(index: int) -> void:
	var skill_id := str(skill_list.get_item_metadata(index))
	var data: Dictionary = catalog.get(skill_id, {})
	selected_id = skill_id
	id_edit.text = skill_id
	name_edit.text = str(data.get("name", ""))
	desc_edit.text = str(data.get("description", ""))
	growth_check.button_pressed = bool(data.get("growth_available", false))
	execution_edit.text = str(data.get("execution_type", ""))
	damage_edit.text = _value_text(data, "damage")
	radius_edit.text = _value_text(data, "radius")
	cooldown_edit.text = _value_text(data, "cooldown")
	energy_edit.text = _value_text(data, "energy_cost")
	duration_edit.text = _value_text(data, "duration")
	status_label.text = "Loaded: %s" % skill_id

func _value_text(data: Dictionary, key: String) -> String:
	return "" if not data.has(key) else str(data[key])

func _clear_editor() -> void:
	selected_id = ""
	id_edit.text = ""
	name_edit.text = ""
	desc_edit.text = ""
	growth_check.button_pressed = false
	execution_edit.text = ""
	damage_edit.text = ""
	radius_edit.text = ""
	cooldown_edit.text = ""
	energy_edit.text = ""
	duration_edit.text = ""

func _new_skill() -> void:
	_clear_editor()
	id_edit.grab_focus()
	status_label.text = "New skill"

func _save_skill() -> void:
	var skill_id := id_edit.text.strip_edges()
	if skill_id.is_empty() or name_edit.text.strip_edges().is_empty():
		status_label.text = "ERROR: skill ID and name are required"
		return
	if not selected_id.is_empty() and skill_id != selected_id:
		status_label.text = "ERROR: skill ID rename is not supported; create a new skill"
		return
	if selected_id.is_empty() and catalog.has(skill_id):
		status_label.text = "ERROR: skill ID already exists; select it to edit"
		return
	if not _validate_numeric_inputs():
		return
	var data: Dictionary = catalog.get(selected_id, {}).duplicate(true) if not selected_id.is_empty() else {}
	if selected_id != "" and selected_id != skill_id:
		catalog.erase(selected_id)
	data["id"] = skill_id
	data["name"] = name_edit.text.strip_edges()
	data["description"] = desc_edit.text
	data["growth_available"] = growth_check.button_pressed
	var execution_type := execution_edit.text.strip_edges()
	if execution_type.is_empty():
		data.erase("execution_type")
	else:
		data["execution_type"] = execution_type
	_set_number(data, "damage", damage_edit.text)
	_set_number(data, "radius", radius_edit.text)
	_set_number(data, "cooldown", cooldown_edit.text)
	_set_number(data, "energy_cost", energy_edit.text)
	_set_number(data, "duration", duration_edit.text)
	catalog[skill_id] = data
	if not ObjectPersistence.save_catalog("skills", catalog):
		status_label.text = "ERROR: SQLite save failed"
		return
	_load_catalog()
	_refresh_list()
	selected_id = skill_id
	status_label.text = "Saved to SQLite: %s" % skill_id

func _set_number(data: Dictionary, key: String, text_value: String) -> void:
	var value := text_value.strip_edges()
	if value.is_empty():
		data.erase(key)
	else:
		data[key] = float(value)

func _validate_numeric_inputs() -> bool:
	for value in [damage_edit.text, radius_edit.text, cooldown_edit.text, energy_edit.text, duration_edit.text]:
		if not value.strip_edges().is_empty() and not value.is_valid_float():
			status_label.text = "ERROR: numeric field is invalid"
			return false
		if not value.strip_edges().is_empty() and float(value) < 0.0:
			status_label.text = "ERROR: negative values are not allowed"
			return false
	return true

func _delete_skill() -> void:
	if selected_id.is_empty():
		status_label.text = "ERROR: select a skill"
		return
	if _is_skill_referenced(selected_id):
		status_label.text = "ERROR: skill is referenced by gameplay skill slots and cannot be deleted"
		return
	catalog.erase(selected_id)
	if not ObjectPersistence.save_catalog("skills", catalog):
		status_label.text = "ERROR: SQLite delete failed"
		return
	var deleted_id := selected_id
	_load_catalog()
	_refresh_list()
	_clear_editor()
	status_label.text = "Deleted from SQLite: %s" % deleted_id

func _is_skill_referenced(skill_id: String) -> bool:
	var gameplay := ContentCatalogLoader.load_document("gameplay")
	if gameplay.is_empty():
		return true
	var slots = gameplay.get("skill_slots", {})
	if not (slots is Dictionary):
		return true
	for slot_value in slots.values():
		var reference := str(slot_value)
		if reference == skill_id:
			return true
		if slot_value is int or slot_value is float:
			if ContentCatalogLoader.resolve_odb_pk("skill", int(slot_value)) == skill_id:
				return true
	return false
