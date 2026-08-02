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
    """Load default slot defs (id -> {position, rotation, ...}) from base-body-slots.json."""
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


def create_slot_empties(mecha: dict, collection_name: str = "ParaModel_Slots"):
    """Create Empty objects for each enabled Base Body slot with position/rotation."""
    slots = mecha.get("base_body", {}).get("slots", {})
    if not slots:
        raise ValueError("No base_body.slots found in mecha data")

    defaults = load_default_slots()

    if collection_name in bpy.data.collections:
        coll = bpy.data.collections[collection_name]
    else:
        coll = bpy.data.collections.new(collection_name)
        bpy.context.scene.collection.children.link(coll)

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

        # Apply position/rotation from default_slots schema
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


class PARAMODEL_OT_load_mecha(Operator):
    bl_idname = "paramodel.load_mecha"
    bl_label = "Load Mecha"
    bl_description = "Load selected mecha JSON and create Base Body slot empties"
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

        if settings.create_empties:
            try:
                created = create_slot_empties(mecha)
                self.report({"INFO"}, f"Loaded {mecha_id}: {len(created)} slots")
            except Exception as e:
                self.report({"ERROR"}, str(e))
                return {"CANCELLED"}
        else:
            self.report({"INFO"}, f"Loaded {mecha_id} (no empties)")

        return {"FINISHED"}


class PARAMODEL_OT_clear_slots(Operator):
    bl_idname = "paramodel.clear_slots"
    bl_label = "Clear Slots"
    bl_description = "Remove all ParaModel slot empties"
    bl_options = {"REGISTER", "UNDO"}

    def execute(self, context):
        removed = 0
        for obj in list(bpy.data.objects):
            if obj.get("paramodel_slot") is not None:
                bpy.data.objects.remove(obj, do_unlink=True)
                removed += 1

        coll_name = "ParaModel_Slots"
        if coll_name in bpy.data.collections:
            bpy.data.collections.remove(bpy.data.collections[coll_name])

        self.report({"INFO"}, f"Removed {removed} slot objects")
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
