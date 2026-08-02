import bpy
import json
import math
import os
from mathutils import Vector
from bpy.types import Operator


def _unit_to_bu(meters: float) -> float:
    try:
        scale_length = float(bpy.context.scene.unit_settings.scale_length)
    except Exception:
        scale_length = 1.0
    if scale_length <= 0:
        scale_length = 1.0
    return meters / scale_length


def _unit_factor() -> float:
    return _unit_to_bu(1.0)


def _addon_root():
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def _parts_dir():
    return os.path.join(_addon_root(), "data", "parts")


def _load_bones():
    path = os.path.join(os.path.dirname(__file__), "bones.json")
    with open(path, "r", encoding="utf-8") as f:
        raw = json.load(f)
    return [(n, p, tuple(h), tuple(t)) for n, p, h, t in raw]


def load_mecha_json(data_path: str, mecha_id: str) -> dict:
    filepath = os.path.join(data_path, f"{mecha_id}.json")
    if not os.path.isfile(filepath):
        raise FileNotFoundError(f"Mecha data not found: {filepath}")
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)


def load_default_slots(schema_path: str = None) -> dict:
    if schema_path is None:
        schema_path = os.path.join(_addon_root(), "schema", "base-body-slots.json")
    if not os.path.isfile(schema_path):
        return {}
    with open(schema_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    result = {}
    for slot in data.get("default_slots", []):
        sid = slot.get("id")
        if sid:
            result[sid] = slot
    return result


def load_part(part_id: str) -> dict:
    if not part_id:
        return {}
    path = os.path.join(_parts_dir(), f"{part_id}.json")
    if not os.path.isfile(path):
        return {}
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def _ensure_collection(name: str):
    if name in bpy.data.collections:
        return bpy.data.collections[name]
    coll = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(coll)
    return coll


def create_root(mecha: dict, collection_name: str = "ParaModel_Root"):
    coll = _ensure_collection(collection_name)
    mecha_id = mecha.get("id", "mecha")
    name = f"root_{mecha_id}"
    if name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    root = bpy.data.objects.new(name, None)
    root.empty_display_type = "PLAIN_AXES"
    root.empty_display_size = _unit_to_bu(0.5)
    coll.objects.link(root)
    params = mecha.get("parameters") or {}
    height = float(params.get("height") or 25.0)
    scale_factor = (height / 25.0) if height > 0 else 1.0
    root.scale = (scale_factor, scale_factor, scale_factor)
    root["paramodel_root"] = True
    root["paramodel_mecha_id"] = mecha_id
    root["paramodel_height"] = height
    root["paramodel_mass"] = float(params.get("mass") or 0)
    root["paramodel_mobility"] = float(params.get("mobility") or 0)
    root["paramodel_output"] = float(params.get("output") or 0)
    root["paramodel_armor"] = float(params.get("armor_thickness") or 0)
    return root


def create_slot_empties(mecha: dict, root=None, collection_name: str = "ParaModel_Slots"):
    slots = mecha.get("base_body", {}).get("slots", {})
    if not slots:
        raise ValueError("No base_body.slots found in mecha data")
    defaults = load_default_slots()
    coll = _ensure_collection(collection_name)
    created = []
    uf = _unit_factor()
    for slot_id, slot_data in slots.items():
        if not slot_data.get("enabled", False):
            continue
        name = f"slot_{slot_id}"
    