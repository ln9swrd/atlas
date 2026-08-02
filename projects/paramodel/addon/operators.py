import bpy
import json
import math
import os
from mathutils import Vector
from bpy.types import Operator


def _addon_root():
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


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


def _resolve_mesh_path(part: dict) -> str:
    mesh_rel = part.get("mesh")
    if not mesh_rel:
        return ""
    if os.path.isabs(mesh_rel) and os.path.isfile(mesh_rel):
        return mesh_rel
    candidates = [
        os.path.join(_addon_root(), mesh_rel),
        os.path.join(_addon_root(), "data", "parts", mesh_rel),
        os.path.join(_addon_root(), "data", "parts", "meshes", mesh_rel),
        os.path.join(_addon_root(), "data", "parts", "meshes", f"{part.get('id', '')}.glb"),
        os.path.join(_addon_root(), "data", "parts", "meshes", f"{part.get('id', '')}.blend"),
    ]
    for c in candidates:
        if c and os.path.isfile(c):
            return c
    return ""


def _import_mesh_file(filepath: str, name: str):
    before = set(bpy.data.objects)
    ext = os.path.splitext(filepath)[1].lower()

    if ext in (".glb", ".gltf"):
        bpy.ops.import_scene.gltf(filepath=filepath)
    elif ext == ".obj":
        if bpy.app.version >= (4, 0, 0):
            bpy.ops.wm.obj_import(filepath=filepath)
        else:
            bpy.ops.import_scene.obj(filepath=filepath)
    elif ext == ".fbx":
        bpy.ops.import_scene.fbx(filepath=filepath)
    elif ext == ".blend":
        with bpy.data.libraries.load(filepath, link=False) as (data_from, data_to):
            data_to.objects = list(data_from.objects)
        for obj in data_to.objects:
            if obj is not None:
                bpy.context.collection.objects.link(obj)
    else:
        return []

    new_objs = [o for o in bpy.data.objects if o not in before and o.type == "MESH"]
    if len(new_objs) == 1:
        new_objs[0].name = name
    return new_objs


def create_root(mecha: dict, collection_name: str = "ParaModel_Root"):
    coll = _ensure_collection(collection_name)
    mecha_id = mecha.get("id", "mecha")
    name = f"root_{mecha_id}"

    if name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)

    root = bpy.data.objects.new(name, None)
    root.empty_display_type = "PLAIN_AXES"
    root.empty_display_size = 0.5
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

        if root:
            empty.parent = root

        empty["paramodel_slot"] = slot_id
        empty["paramodel_part_id"] = slot_data.get("part_id") or ""
        empty["paramodel_mecha_id"] = mecha.get("id", "")
        empty["paramodel_connection_type"] = defn.get("connection_type", "")

        coll.objects.link(empty)
        created.append(name)

    return created


_BONE_PARENT = {
    "torso_lower": None,
    "torso_upper": "torso_lower",
    "head": "torso_upper",
    "arm_l": "torso_upper",
    "arm_r": "torso_upper",
    "leg_l": "torso_lower",
    "leg_r": "torso_lower",
    "backpack": "torso_upper",
    "skirt": "torso_lower",
    "weapon_l": "arm_l",
    "weapon_r": "arm_r",
    "thruster": "torso_upper",
}

_BONE_LENGTH = {
    "head": 0.25,
    "torso_upper": 0.45,
    "torso_lower": 0.35,
    "arm_l": 0.55,
    "arm_r": 0.55,
    "leg_l": 0.7,
    "leg_r": 0.7,
    "backpack": 0.3,
    "skirt": 0.25,
    "weapon_l": 0.35,
    "weapon_r": 0.35,
    "thruster": 0.25,
}


def _set_active(obj):
    """Make obj active and selected; deselect others."""
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def create_armature(mecha: dict, root=None, collection_name: str = "ParaModel_Armature"):
    """Create basic armature aligned to enabled Base Body slots."""
    slots = mecha.get("base_body", {}).get("slots", {})
    defaults = load_default_slots()
    mecha_id = mecha.get("id", "mecha")
    arm_name = f"armature_{mecha_id}"

    # Remove existing object + data
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

    # Must be in OBJECT mode on a valid active object before EDIT
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        try:
            bpy.ops.object.mode_set(mode="OBJECT")
        except Exception:
            pass

    _set_active(arm_obj)

    # Enter edit mode (with temp_override when available)
    try:
        if hasattr(bpy.context, "temp_override"):
            with bpy.context.temp_override(
                active_object=arm_obj,
                object=arm_obj,
                selected_objects=[arm_obj],
                selected_editable_objects=[arm_obj],
            ):
                bpy.ops.object.mode_set(mode="EDIT")
        else:
            bpy.ops.object.mode_set(mode="EDIT")
    except Exception as e:
        # Fallback: still try once more after force-active
        _set_active(arm_obj)
        bpy.ops.object.mode_set(mode="EDIT")

    edit_bones = arm_data.edit_bones
    created_bones = []

    order = [
        "torso_lower",
        "torso_upper",
        "head",
        "arm_l",
        "arm_r",
        "leg_l",
        "leg_r",
        "backpack",
        "skirt",
        "weapon_l",
        "weapon_r",
        "thruster",
    ]

    for slot_id in order:
        slot_data = slots.get(slot_id)
        if not slot_data or not slot_data.get("enabled", False):
            continue

        defn = defaults.get(slot_id, {})
        pos = defn.get("position") or slot_data.get("position") or [0, 0, 0]
        head = Vector((float(pos[0]), float(pos[1]), float(pos[2])))
        length = _BONE_LENGTH.get(slot_id, 0.3)

        if slot_id.startswith("leg"):
            tail = head + Vector((0.0, 0.0, -length))
        elif slot_id.startswith("arm"):
            side = -1.0 if slot_id.endswith("_l") else 1.0
            tail = head + Vector((side * length * 0.3, 0.0, -length * 0.8))
        else:
            tail = head + Vector((0.0, 0.0, length))

        # Avoid zero-length bones
        if (tail - head).length < 1e-6:
            tail = head + Vector((0.0, 0.0, 0.1))

        bone = edit_bones.new(slot_id)
        bone.head = head
        bone.tail = tail
        bone.use_connect = False

        parent_id = _BONE_PARENT.get(slot_id)
        if parent_id and parent_id in edit_bones:
            bone.parent = edit_bones[parent_id]

        created_bones.append(slot_id)

    # Back to object mode
    try:
        if hasattr(bpy.context, "temp_override"):
            with bpy.context.temp_override(
                active_object=arm_obj,
                object=arm_obj,
                selected_objects=[arm_obj],
            ):
                bpy.ops.object.mode_set(mode="OBJECT")
        else:
            bpy.ops.object.mode_set(mode="OBJECT")
    except Exception:
        _set_active(arm_obj)
        bpy.ops.object.mode_set(mode="OBJECT")

    if root:
        arm_obj.parent = root

    # Parent slot empties to bones (after object mode)
    for slot_id in created_bones:
        slot_obj = bpy.data.objects.get(f"slot_{slot_id}")
        if not slot_obj:
            continue
        # Clear previous parent (root) without moving world matrix first
        mw = slot_obj.matrix_world.copy()
        slot_obj.parent = arm_obj
        slot_obj.parent_type = "BONE"
        slot_obj.parent_bone = slot_id
        slot_obj.matrix_world = mw

    if not created_bones:
        raise RuntimeError("No bones created — check enabled slots in mecha JSON")

    return arm_obj, created_bones


def attach_parts(mecha: dict, prefer_mesh: bool = True, collection_name: str = "ParaModel_Parts"):
    slots = mecha.get("base_body", {}).get("slots", {})
    coll = _ensure_collection(collection_name)
    attached = []
    mesh_count = 0
    placeholder_count = 0

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

        imported = []
        if prefer_mesh:
            mesh_path = _resolve_mesh_path(part)
            if mesh_path:
                try:
                    imported = _import_mesh_file(mesh_path, mesh_name)
                except Exception as e:
                    print(f"ParaModel mesh import failed ({mesh_path}): {e}")
                    imported = []

        if imported:
            for obj in imported:
                for c in list(obj.users_collection):
                    c.objects.unlink(obj)
                coll.objects.link(obj)
                obj.parent = slot_obj
                obj.location = (0, 0, 0)
                obj.rotation_euler = (0, 0, 0)
                obj["paramodel_part"] = True
                obj["paramodel_part_id"] = part_id
                obj["paramodel_slot"] = slot_id
                obj["paramodel_mesh_source"] = "file"
                attached.append(obj.name)
            mesh_count += 1
        else:
            size = (part.get("placeholder") or {}).get("size") or [0.3, 0.3, 0.3]
            sx, sy, sz = float(size[0]), float(size[1]), float(size[2])

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
    bl_description = "Load mecha: root, slots, armature, mesh/placeholder parts"
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

        # Ensure object mode at start
        if context.object and context.object.mode != "OBJECT":
            try:
                bpy.ops.object.mode_set(mode="OBJECT")
            except Exception:
                pass

        root = None
        if settings.apply_parameters:
            try:
                root = create_root(mecha)
            except Exception as e:
                self.report({"ERROR"}, f"Root/params: {e}")
                return {"CANCELLED"}

        n_slots = 0
        if settings.create_empties:
            try:
                created = create_slot_empties(mecha, root=root)
                n_slots = len(created)
            except Exception as e:
                self.report({"ERROR"}, str(e))
                return {"CANCELLED"}

        n_bones = 0
        if getattr(settings, "create_armature", False):
            try:
                _, bones = create_armature(mecha, root=root)
                n_bones = len(bones)
            except Exception as e:
                # Do not cancel whole load — report and continue
                self.report({"WARNING"}, f"Armature failed: {e}")
                print(f"ParaModel armature error: {e}")

        n_parts = 0
        n_mesh = 0
        n_ph = 0
        if settings.create_placeholders:
            try:
                attached, n_mesh, n_ph = attach_parts(
                    mecha, prefer_mesh=settings.prefer_mesh
                )
                n_parts = len(attached)
            except Exception as e:
                self.report({"ERROR"}, str(e))
                return {"CANCELLED"}

        self.report(
            {"INFO"},
            f"Loaded {mecha_id}: {n_slots} slots, {n_bones} bones, "
            f"{n_parts} parts (mesh={n_mesh}, ph={n_ph})",
        )
        return {"FINISHED"}


class PARAMODEL_OT_clear_slots(Operator):
    bl_idname = "paramodel.clear_slots"
    bl_label = "Clear All"
    bl_description = "Remove ParaModel root, slots, armature, and parts"
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

        for coll_name in (
            "ParaModel_Root",
            "ParaModel_Slots",
            "ParaModel_Parts",
            "ParaModel_Armature",
        ):
            if coll_name in bpy.data.collections:
                bpy.data.collections.remove(bpy.data.collections[coll_name])

        for arm in list(bpy.data.armatures):
            if arm.name.startswith("armature_"):
                bpy.data.armatures.remove(arm)

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
