extends Control

signal request_content_editor

var catalog: Dictionary = {}
var selected_id := ""

@onready var faction_list: ItemList = $MainLayout/Body/FactionList
@onready var id_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/IdEdit
@onready var name_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/NameEdit
@onready var color_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/ColorEdit
@onready var status_label: Label = $MainLayout/Status

func _ready() -> void:
    _load_catalog()
    $MainLayout/Body/EditorPanel/Fields/Buttons/NewButton.pressed.connect(_new_faction)
    $MainLayout/Body/EditorPanel/Fields/Buttons/SaveButton.pressed.connect(_save_faction)
    $MainLayout/Body/EditorPanel/Fields/Buttons/DeleteButton.pressed.connect(_delete_faction)
    faction_list.item_selected.connect(_select_faction)
    _clear_editor()
    _refresh_list()

func _load_catalog() -> void:
    catalog = ContentCatalogLoader.load_dictionary_catalog("factions")
    if catalog.is_empty():
        catalog = {}

func _refresh_list() -> void:
    faction_list.clear()
    var ids: Array[String] = []
    for key in catalog.keys():
        ids.append(str(key))
    ids.sort()
    for faction_id in ids:
        var data: Dictionary = catalog.get(faction_id, {})
        var label := str(data.get("name", faction_id))
        faction_list.add_item("%s  [%s]" % [label, faction_id])
        faction_list.set_item_metadata(faction_list.item_count - 1, faction_id)

func _select_faction(index: int) -> void:
    var faction_id := str(faction_list.get_item_metadata(index))
    var data: Dictionary = catalog.get(faction_id, {})
    selected_id = faction_id
    id_edit.text = faction_id
    name_edit.text = str(data.get("name", ""))
    color_edit.text = str(data.get("color", "ffffffff"))
    status_label.text = "Loaded: %s" % faction_id

func _clear_editor() -> void:
    selected_id = ""
    id_edit.text = ""
    name_edit.text = ""
    color_edit.text = "ffffffff"

func _new_faction() -> void:
    _clear_editor()
    id_edit.grab_focus()
    status_label.text = "New faction"

func _save_faction() -> void:
    var faction_id := id_edit.text.strip_edges()
    var faction_name := name_edit.text.strip_edges()
    var color_hex := color_edit.text.strip_edges()
    if faction_id.is_empty():
        status_label.text = "ERROR: faction ID is required"
        return
    if faction_name.is_empty():
        status_label.text = "ERROR: faction name is required"
        return
    if color_hex.is_empty():
        color_hex = "ffffffff"
    if Color.from_string(color_hex, Color.WHITE) == Color.WHITE and color_hex.to_lower() not in ["ffffffff", "ffffff"]:
        status_label.text = "ERROR: invalid color"
        return
    if selected_id != "" and selected_id != faction_id:
        catalog.erase(selected_id)
    catalog[faction_id] = {
        "id": faction_id,
        "name": faction_name,
        "color": color_hex
    }
    if not ObjectPersistence.save_catalog("factions", catalog):
        status_label.text = "ERROR: SQLite save failed"
        return
    _load_catalog()
    _refresh_list()
    selected_id = faction_id
    status_label.text = "Saved to SQLite: %s" % faction_id

func _delete_faction() -> void:
    if selected_id.is_empty():
        status_label.text = "ERROR: select a faction"
        return
    catalog.erase(selected_id)
    if not ObjectPersistence.save_catalog("factions", catalog):
        status_label.text = "ERROR: SQLite delete failed"
        return
    var deleted_id := selected_id
    _load_catalog()
    _refresh_list()
    _clear_editor()
    status_label.text = "Deleted from SQLite: %s" % deleted_id
