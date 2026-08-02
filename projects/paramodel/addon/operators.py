import bpy
import json
import math
import os
from bpy.types import Operator


def _addon_root():
    """projects/paramodel/ (parent of addon/)."""
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load_mecha_json(data_path: str, mecha_id: str) -> dict:
    """Load mecha metadata JSON by id."""
    filepath = os.path.join(data_path, f"{mecha_id}.json")
    if not os.path.isfile(filepath):
        raise FileNotFoundError(f"Mecha data not found: {filepath}")
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)


def load_default_slots(schema_path: str = None) -> dict:
    """Load default slot defs from base-body-slots.json."""
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
    """Load part metadata from data/parts/{part_id}.json."""
    if not part_id:
        return {}
    path = os.path.join(_addon_root(), "data", "parts", f"{part_id}.json")
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


def create_slot_empties(mecha: dict, collection_name: str = "ParaModel_Slots"):
    """Create Empty objects for each enabled Base Body slot with position/rotation."""
    slots = mecha.get("base_body", {}).get("slots", {})
    if not slots:
        raise ValueError("No base_body.slots found in mecha data")

    defaults = load_default_slots()
    coll = _ensure_collection(collection_name)

    created = []
    for slot_id, slot_data in slots.items():
        if not slot_data.get("enabled", False):
            continue

        name = f"slot_{slot_id}"
        if name in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)

        empty = bpy.data.objects.new(name, None)
        empty.empty_display_type = "ARROWS"
        empty.empty_display_size = 0.3

        defn = defaults.get(slot_id, {})
        pos = defn.get("position") or slot_data.get("position") or [0, 0, 0]
        rot = defn.get("rotation") or slot_data.get("rotation") or [0, 0, 0]
        if len(pos) >= 3:
            empty.location = (float(pos[0]), float(pos[1]), float(pos[2]))
        if len(rot) >= 3:
            empty.rotation_euler = (
                math.radians(float(rot[0])),
                math.radians(float(rot[1])),
                math.radians(float(rot[2])),
            )

        empty["paramodel_slot"] = slot_id
        empty["paramodel_part_id"] = slot_data.get("part_id") or ""
        empty["paramodel_mecha_id"] = mecha.get("id", "")
        empty["paramodel_connection_type"] = defn.get("connection_type", "")

        coll.objects.link(empty)
        created.append(name)

    return created


def attach_placeholders(mecha: dict, collection_name: str = "ParaModel_Parts"):
    """Parent cube placeholders to slot empties based on part_id."""
    slots = mecha.get("base_body", {}).get("slots", {})
    coll = _ensure_collection(collection_name)
    attached = []

    for slot_id, slot_data in slots.items():
        if not slot_data.get("enabled", False):
            continue
        part_id = slot_data.get("part_id")
        if not part_id:
            continue

        slot_name = f"slot_{slot_id}"
        slot_obj = bpy.data.objects.get(slot_name)
        if not slot_obj:
            continue

        part = load_part(part_id)
        size = (part.get("placeholder") or {}).get("size") or [0.3, 0.3, 0.3]
        sx, sy, sz = float(size[0]), float(size[1]), float(size[2])

        mesh_name = f"part_{slot_id}_{part_id}"
        if mesh_name in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[mesh_name], do_unlink=True)

        # Cube mesh scaled to placeholder size
        mesh = bpy.data.meshes.new(mesh_name + "_mesh")
        obj = bpy.data.objects.new(mesh_name, mesh)
        coll.objects.link(obj)

        # Build unit cube then scale
        import bmesh
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        bm.to_mesh(mesh)
        bm.free()
        obj.scale = (sx, sy, sz)

        obj.parent = slot_obj
        obj.location = (0, 0, 0)
        obj.rotation_euler = (0, 0, 0)

        obj["paramodel_part"] = True
        obj["paramodel_part_id"] = part_id
        obj["paramodel_slot"] = slot_id

        attached.append(mesh_name)

    return attached


class PARAMODEL_OT_load_mecha(Operator):
    bl_idname = "paramodel.load_mecha"
    bl_label = "Load Mecha"
    bl_description = "Load mecha JSON, create slot empties, attach part placeholders"
    bl_options = {"REGISTER", "UNDO"}

    def execute(self, context):
        settings = context.scene.paramodel
        data_path = settings.data_path
        mecha_id = settings.selected_mecha

        if not data_path:
            self.report({"ERROR"}, "Data Path is empty")
            return {"CANCELLED"}

        try:
            mecha = load_mecha_json(data_path, mecha_id)
        except FileNotFoundError as e:
            self.report({"ERROR"}, str(e))
            return {"CANCELLED"}
        except json.JSONDecodeError as e:
            self.report({"ERROR"}, f"Invalid JSON: {e}")
            return {"CANCELLED"}

        n_slots = 0
        n_parts = 0
        if settings.create_empties:
            try:
                created = create_slot_empties(mecha)
                n_slots = len(created)
            except Exception as e:
                self.report({"ERROR"}, str(e))
                return {"CANCELLED"}

        if settings.create_placeholders:
            try:
                attached = attach_placeholders(mecha)
                n_parts = len(attached)
            except Exception as e:
                self.report({"ERROR"}, str(e))
                return {"CANCELLED"}

        self.report(
            {"INFO"},
            f"Loaded {mecha_id}: {n_slots} slots, {n_parts} placeholders",
        )
        return {"FINISHED"}


class PARAMODEL_OT_clear_slots(Operator):
    bl_idname = "paramodel.clear_slots"
    bl_label = "Clear Slots"
    bl_description = "Remove all ParaModel slot empties and part placeholders"
    bl_options = {"REGISTER", "UNDO"}

    def execute(self, context):
        removed = 0
        for obj in list(bpy.data.objects):
            if obj.get("paramodel_slot") is not None or obj.get("paramodel_part"):
                bpy.data.objects.remove(obj, do_unlink=True)
                removed += 1

        for coll_name in ("ParaModel_Slots", "ParaModel_Parts"):
            if coll_name in bpy.data.collections:
                bpy.data.collections.remove(bpy.data.collections[coll_name])

        self.report({"INFO"}, f"Removed {removed} objects")
        return {"FINISHED"}


classes = (
    PARAMODEL_OT_load_mecha,
    PARAMODEL_OT_clear_slots,
)


def register():
    for cls in classes:
        bpy.utils.register_class(cls)


def unregister():
    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)
