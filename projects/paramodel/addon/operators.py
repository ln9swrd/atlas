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
        if name in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
        empty = bpy.data.objects.new(name, None)
        empty.empty_display_type = "ARROWS"
        empty.empty_display_size = _unit_to_bu(0.3)
        defn = defaults.get(slot_id, {})
        pos = defn.get("position") or slot_data.get("position") or [0, 0, 0]
        rot = defn.get("rotation") or slot_data.get("rotation") or [0, 0, 0]
        if len(pos) >= 3:
            empty.location = (float(pos[0]) * uf, float(pos[1]) * uf, float(pos[2]) * uf)
        if len(rot) >= 3:
            empty.rotation_euler = (
                math.radians(float(rot[0])),
                math.radians(float(rot[1])),
                math.radians(float(rot[2])),
            )
        if root:
            empty.parent = root
        empty["paramodel_slot"] = slot_id
        empty["paramodel_part_id"] = slot_data.get("part_id") or ""
        empty["paramodel_mecha_id"] = mecha.get("id", "")
        empty["paramodel_connection_type"] = defn.get("connection_type", "")
        coll.objects.link(empty)
        created.append(name)
    return created


def _set_active(obj):
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def create_armature(mecha: dict, root=None, collection_name: str = "ParaModel_Armature"):
    mecha_id = mecha.get("id", "mecha")
    arm_name = "SuperRobotRig"
    if arm_name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[arm_name], do_unlink=True)
    if arm_name in bpy.data.armatures:
        bpy.data.armatures.remove(bpy.data.armatures[arm_name])
    arm_data = bpy.data.armatures.new(arm_name)
    arm_obj = bpy.data.objects.new(arm_name, arm_data)
    coll = _ensure_collection(collection_name)
    coll.objects.link(arm_obj)
    arm_obj["paramodel_armature"] = True
    arm_obj["paramodel_mecha_id"] = mecha_id
    arm_obj["paramodel_rig_source"] = "SuperRobotRig"
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        try:
            bpy.ops.object.mode_set(mode="OBJECT")
        except Exception:
            pass
    _set_active(arm_obj)
    try:
        if hasattr(bpy.context, "temp_override"):
            with bpy.context.temp_override(
                active_object=arm_obj, object=arm_obj,
                selected_objects=[arm_obj], selected_editable_objects=[arm_obj],
            ):
                bpy.ops.object.mode_set(mode="EDIT")
        else:
            bpy.ops.object.mode_set(mode="EDIT")
    except Exception:
        _set_active(arm_obj)
        bpy.ops.object.mode_set(mode="EDIT")
    edit_bones = arm_data.edit_bones
    created = []
    uf = _unit_factor()
    for name, parent_name, head, tail in _load_bones():
        bone = edit_bones.new(name)
        bone.head = Vector(head) * uf
        bone.tail = Vector(tail) * uf
        bone.use_connect = False
        if parent_name and parent_name in edit_bones:
            bone.parent = edit_bones[parent_name]
        created.append(name)
    try:
        if hasattr(bpy.context, "temp_override"):
            with bpy.context.temp_override(
                active_object=arm_obj, object=arm_obj, selected_objects=[arm_obj],
            ):
                bpy.ops.object.mode_set(mode="OBJECT")
        else:
            bpy.ops.object.mode_set(mode="OBJECT")
    except Exception:
        _set_active(arm_obj)
        bpy.ops.object.mode_set(mode="OBJECT")
    if root:
        arm_obj.parent = root
    return arm_obj, created


def attach_parts(mecha: dict, prefer_mesh: bool = True, collection_name: str = "ParaModel_Parts"):
    slots = mecha.get("base_body", {}).get("slots", {})
    coll = _ensure_collection(collection_name)
    attached = []
    mesh_count = 0
    placeholder_count = 0
    uf = _unit_factor()
    for slot_id, slot_data in slots.items():
        if not slot_data.get("enabled", False):
            continue
        part_id = slot_data.get("part_id")
        if not part_id:
            continue
        slot_obj = bpy.data.objects.get(f"slot_{slot_id}")
        if not slot_obj:
            continue
        part = load_part(part_id)
        mesh_name = f"part_{slot_id}_{part_id}"
        if mesh_name in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[mesh_name], do_unlink=True)
        size = (part.get("placeholder") or {}).get("size") or [0.3, 0.3, 0.3]
        sx, sy, sz = float(size[0]) * uf, float(size[1]) * uf, float(size[2]) * uf
        mesh = bpy.data.meshes.new(mesh_name + "_mesh")
        obj = bpy.data.objects.new(mesh_name, mesh)
        coll.objects.link(obj)
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
        obj["paramodel_mesh_source"] = "placeholder"
        attached.append(mesh_name)
        placeholder_count += 1
    return attached, mesh_count, placeholder_count


class PARAMODEL_OT_load_mecha(Operator):
    bl_idname = "paramodel.load_mecha"
    bl_label = "Load Mecha"
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
        except Exception as e:
            self.report({"ERROR"}, str(e))
            return {"CANCELLED"}
        if context.object and context.object.mode != "OBJECT":
            try:
                bpy.ops.object.mode_set(mode="OBJECT")
            except Exception:
                pass
        root = create_root(mecha) if settings.apply_parameters else None
        n_slots = 0
        if settings.create_empties:
            n_slots = len(create_slot_empties(mecha, root=root))
        n_bones = 0
        if getattr(settings, "create_armature", False):
            try:
                _, bones = create_armature(mecha, root=root)
                n_bones = len(bones)
            except Exception as e:
                self.report({"WARNING"}, f"Armature failed: {e}")
        n_parts = 0
        if settings.create_placeholders:
            attached, _, _ = attach_parts(mecha, prefer_mesh=settings.prefer_mesh)
            n_parts = len(attached)
        self.report({"INFO"}, f"Loaded {mecha_id}: {n_slots} slots, {n_bones} bones, {n_parts} parts")
        return {"FINISHED"}


class PARAMODEL_OT_clear_slots(Operator):
    bl_idname = "paramodel.clear_slots"
    bl_label = "Clear All"
    bl_options = {"REGISTER", "UNDO"}

    def execute(self, context):
        if context.object and context.object.mode != "OBJECT":
            try:
                bpy.ops.object.mode_set(mode="OBJECT")
            except Exception:
                pass
        removed = 0
        for obj in list(bpy.data.objects):
            if (
                obj.get("paramodel_slot") is not None
                or obj.get("paramodel_part")
                or obj.get("paramodel_root")
                or obj.get("paramodel_armature")
            ):
                bpy.data.objects.remove(obj, do_unlink=True)
                removed += 1
        for coll_name in ("ParaModel_Root", "ParaModel_Slots", "ParaModel_Parts", "ParaModel_Armature"):
            if coll_name in bpy.data.collections:
                bpy.data.collections.remove(bpy.data.collections[coll_name])
        for arm in list(bpy.data.armatures):
            if arm.name.startswith("armature_") or arm.name == "SuperRobotRig":
                if arm.users == 0:
                    bpy.data.armatures.remove(arm)
        self.report({"INFO"}, f"Removed {removed} objects")
        return {"FINISHED"}


classes = (PARAMODEL_OT_load_mecha, PARAMODEL_OT_clear_slots)


def register():
    for cls in classes:
        bpy.utils.register_class(cls)


def unregister():
    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)
