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


# SuperRobotRig bone table (from user metarig.001 dump)
# (name, parent_name or None, head_xyz, tail_xyz)
_SUPER_ROBOT_BONES = [
    ("Root", None, (0.0, 0.0, -1.0252), (0.0, 0.0, -0.8559)),
    ("Hip", "Root", (0.0, 0.0, 0.0862), (0.0, 0.0, 0.2597)),
    ("Waist", "Hip", (0.0, 0.0172, 0.2562), (0.0, 0.0542, 0.3505)),
    ("Midriff", "Waist", (0.0, 0.0542, 0.3505), (0.0, 0.1108, 0.493)),
    ("Chest", "Midriff", (0.0, 0.1094, 0.5142), (0.0, 0.1048, 0.6946)),
    ("Neck", "Chest", (0.0, 0.1048, 0.6946), (0.0, 0.0673, 0.7451)),
    ("Head", "Neck", (0.0, 0.0673, 0.7451), (-0.0, 0.0622, 0.8531)),
    ("wing", "Chest", (0.0, 0.1048, 0.6946), (-0.0, 0.1899, 0.6633)),
    ("wing_01.L", "wing", (0.0, 0.1899, 0.6633), (0.4129, 0.3744, 0.7134)),
    ("wing_02.L", "wing_01.L", (0.4125, 0.3739, 0.7189), (0.8226, 0.52, 1.3624)),
    ("wing_03.L", "wing_02.L", (0.8226, 0.52, 1.3624), (1.2663, 0.5993, 1.0093)),
    ("wing_03_02.L", "wing_03.L", (1.2663, 0.5993, 1.0093), (1.1904, 0.5803, 0.4181)),
    ("wing_03_01.L", "wing_03.L", (1.2663, 0.5993, 1.0093), (1.785, 0.7469, 0.1779)),
    ("wing_02_03.L", "wing_02.L", (0.8226, 0.52, 1.3624), (0.6684, 0.4743, 0.6008)),
    ("wing_01.R", "wing", (-0.0, 0.1899, 0.6633), (-0.4129, 0.3744, 0.7134)),
    ("wing_02.R", "wing_01.R", (-0.4125, 0.3739, 0.7189), (-0.8226, 0.52, 1.3624)),
    ("wing_03.R", "wing_02.R", (-0.8226, 0.52, 1.3624), (-1.2663, 0.5993, 1.0093)),
    ("wing_03_01.R", "wing_03.R", (-1.2663, 0.5993, 1.0093), (-1.785, 0.7469, 0.1779)),
    ("wing_03_02.R", "wing_03.R", (-1.2663, 0.5993, 1.0093), (-1.1904, 0.5803, 0.4181)),
    ("wing_02_03.R", "wing_02.R", (-0.8226, 0.52, 1.3624), (-0.6684, 0.4743, 0.6008)),
    ("clavicle.L", "Chest", (0.061, 0.0966, 0.6625), (0.2086, 0.0964, 0.6195)),
    ("shoulder_joint.L", "clavicle.L", (0.2116, 0.0966, 0.6207), (0.3588, 0.1737, 0.6631)),
    ("shoulder.L", "shoulder_joint.L", (0.4865, 0.1375, 0.6475), (0.4119, 0.1445, 1.2197)),
    ("upper_arm.L", "shoulder.L", (0.4924, 0.1605, 0.6265), (0.557, 0.1518, 0.5175)),
    ("elbow_double_top.L", "upper_arm.L", (0.557, 0.1518, 0.5175), (0.577, 0.1474, 0.4797)),
    ("elbow_double_bottom.L", "elbow_double_top.L", (0.577, 0.1474, 0.4797), (0.597, 0.1431, 0.4419)),
    ("forearm.L", "elbow_double_bottom.L", (0.597, 0.1431, 0.4419), (0.5874, 0.1016, 0.0702)),
    ("hand.L", "forearm.L", (0.5874, 0.1016, 0.0702), (0.5638, 0.0936, -0.0062)),
    ("palm.01.L", "hand.L", (0.5814, 0.0748, 0.0333), (0.5618, 0.0574, -0.0314)),
    ("f_index.01.L", "palm.01.L", (0.5618, 0.0574, -0.0314), (0.5354, 0.0536, -0.0678)),
    ("f_index.02.L", "f_index.01.L", (0.5354, 0.0536, -0.0678), (0.5155, 0.052, -0.0878)),
    ("f_index.03.L", "f_index.02.L", (0.5155, 0.052, -0.0878), (0.4962, 0.0529, -0.1002)),
    ("thumb.01.L", "palm.01.L", (0.5606, 0.0738, 0.0489), (0.5341, 0.0538, 0.0233)),
    ("thumb.02.L", "thumb.01.L", (0.5341, 0.0538, 0.0233), (0.5163, 0.0466, -0.0041)),
    ("thumb.03.L", "thumb.02.L", (0.5163, 0.0466, -0.0041), (0.5068, 0.0425, -0.0222)),
    ("palm.02.L", "hand.L", (0.5826, 0.0913, 0.0285), (0.5641, 0.0801, -0.0363)),
    ("f_middle.01.L", "palm.02.L", (0.5641, 0.0801, -0.0363), (0.5317, 0.0758, -0.0737)),
    ("f_middle.02.L", "f_middle.01.L", (0.5317, 0.0758, -0.0737), (0.5055, 0.0742, -0.0925)),
    ("f_middle.03.L", "f_middle.02.L", (0.5055, 0.0742, -0.0925), (0.4856, 0.074, -0.1035)),
    ("palm.03.L", "hand.L", (0.5821, 0.1069, 0.0291), (0.5644, 0.1045, -0.0386)),
    ("f_ring.01.L", "palm.03.L", (0.5644, 0.1045, -0.0386), (0.5313, 0.1023, -0.0689)),
    ("f_ring.02.L", "f_ring.01.L", (0.5313, 0.1023, -0.0689), (0.5049, 0.1018, -0.0867)),
    ("f_ring.03.L", "f_ring.02.L", (0.5049, 0.1018, -0.0867), (0.4869, 0.1022, -0.0916)),
    ("palm.04.L", "hand.L", (0.5806, 0.1221, 0.0322), (0.5589, 0.1288, -0.0392)),
    ("f_pinky.01.L", "palm.04.L", (0.5589, 0.1288, -0.0392), (0.5352, 0.129, -0.0541)),
    ("f_pinky.02.L", "f_pinky.01.L", (0.5352, 0.129, -0.0541), (0.515, 0.1295, -0.0644)),
    ("f_pinky.03.L", "f_pinky.02.L", (0.515, 0.1295, -0.0644), (0.5006, 0.1297, -0.0687)),
    ("clavicle.R", "Chest", (-0.061, 0.0966, 0.6625), (-0.2086, 0.0964, 0.6195)),
    ("shoulder_joint.R", "clavicle.R", (-0.2116, 0.0966, 0.6207), (-0.3588, 0.1737, 0.6631)),
    ("shoulder.R", "shoulder_joint.R", (-0.4865, 0.1375, 0.6475), (-0.4119, 0.1445, 1.2197)),
    ("upper_arm.R", "shoulder.R", (-0.4924, 0.1605, 0.6265), (-0.557, 0.1518, 0.5175)),
    ("elbow_double_top.R", "upper_arm.R", (-0.557, 0.1518, 0.5175), (-0.577, 0.1474, 0.4797)),
    ("elbow_double_bottom.R", "elbow_double_top.R", (-0.577, 0.1474, 0.4797), (-0.597, 0.1431, 0.4419)),
    ("forearm.R", "elbow_double_bottom.R", (-0.597, 0.1431, 0.4419), (-0.5874, 0.1016, 0.0702)),
    ("hand.R", "forearm.R", (-0.5874, 0.1016, 0.0702), (-0.5638, 0.0936, -0.0062)),
    ("palm.01.R", "hand.R", (-0.5814, 0.0748, 0.0333), (-0.5618, 0.0574, -0.0314)),
    ("f_index.01.R", "palm.01.R", (-0.5618, 0.0574, -0.0314), (-0.5354, 0.0536, -0.0678)),
    ("f_index.02.R", "f_index.01.R", (-0.5354, 0.0536, -0.0678), (-0.5155, 0.052, -0.0878)),
    ("f_index.03.R", "f_index.02.R", (-0.5155, 0.052, -0.0878), (-0.4962, 0.0529, -0.1002)),
    ("thumb.01.R", "palm.01.R", (-0.5606, 0.0738, 0.0489), (-0.5341, 0.0538, 0.0233)),
    ("thumb.02.R", "thumb.01.R", (-0.5341, 0.0538, 0.0233), (-0.5163, 0.0466, -0.0041)),
    ("thumb.03.R", "thumb.02.R", (-0.5163, 0.0466, -0.0041), (-0.5068, 0.0425, -0.0222)),
    ("palm.02.R", "hand.R", (-0.5826, 0.0913, 0.0285), (-0.5641, 0.0801, -0.0363)),
    ("f_middle.01.R", "palm.02.R", (-0.5641, 0.0801, -0.0363), (-0.5317, 0.0758, -0.0737)),
    ("f_middle.02.R", "f_middle.01.R", (-0.5317, 0.0758, -0.0737), (-0.5055, 0.0742, -0.0925)),
    ("f_middle.03.R", "f_middle.02.R", (-0.5055, 0.0742, -0.0925), (-0.4856, 0.074, -0.1035)),
    ("palm.03.R", "hand.R", (-0.5821, 0.1069, 0.0291), (-0.5644, 0.1045, -0.0386)),
    ("f_ring.01.R", "palm.03.R", (-0.5644, 0.1045, -0.0386), (-0.5313, 0.1023, -0.0689)),
    ("f_ring.02.R", "f_ring.01.R", (-0.5313, 0.1023, -0.0689), (-0.5049, 0.1018, -0.0867)),
    ("f_ring.03.R", "f_ring.02.R", (-0.5049, 0.1018, -0.0867), (-0.4869, 0.1022, -0.0916)),
    ("palm.04.R", "hand.R", (-0.5806, 0.1221, 0.0322), (-0.5589, 0.1288, -0.0392)),
    ("f_pinky.01.R", "palm.04.R", (-0.5589, 0.1288, -0.0392), (-0.5352, 0.129, -0.0541)),
    ("f_pinky.02.R", "f_pinky.01.R", (-0.5352, 0.129, -0.0541), (-0.515, 0.1295, -0.0644)),
    ("f_pinky.03.R", "f_pinky.02.R", (-0.515, 0.1295, -0.0644), (-0.5006, 0.1297, -0.0687)),
    ("pelvis.L", "Hip", (-0.0, 0.0552, 0.1083), (0.1112, -0.0451, 0.118)),
    ("thigh.L", "pelvis.L", (0.1239, 0.0124, 0.1455), (0.23, 0.0278, -0.1272)),
    ("knee_double_top.L", "thigh.L", (0.23, 0.0278, -0.1272), (0.2604, 0.0401, -0.2097)),
    ("knee_double_bottom.L", "knee_double_top.L", (0.2604, 0.0401, -0.2097), (0.2842, 0.051, -0.2742)),
    ("shin.L", "knee_double_bottom.L", (0.2842, 0.051, -0.2742), (0.4426, 0.1523, -0.7694)),
    ("ankle.L", "shin.L", (0.4426, 0.1523, -0.7694), (0.4865, 0.1636, -0.9038)),
    ("foot.L", "ankle.L", (0.4865, 0.1636, -0.9038), (0.5149, 0.1431, -0.9884)),
    ("toe.L", "foot.L", (0.5149, 0.1431, -0.9884), (0.5793, -0.129, -0.9915)),
    ("heel.02.L", "foot.L", (0.5106, 0.1615, -0.9904), (0.4886, 0.2545, -0.989)),
    ("pelvis.R", "Hip", (0.0, 0.0552, 0.1083), (-0.1112, -0.0451, 0.118)),
    ("thigh.R", "pelvis.R", (-0.1239, 0.0124, 0.1455), (-0.23, 0.0278, -0.1272)),
    ("knee_double_top.R", "thigh.R", (-0.23, 0.0278, -0.1272), (-0.2604, 0.0401, -0.2097)),
    ("knee_double_bottom.R", "knee_double_top.R", (-0.2604, 0.0401, -0.2097), (-0.2842, 0.051, -0.2742)),
    ("shin.R", "knee_double_bottom.R", (-0.2842, 0.051, -0.2742), (-0.4426, 0.1523, -0.7694)),
    ("ankle.R", "shin.R", (-0.4426, 0.1523, -0.7694), (-0.4865, 0.1636, -0.9038)),
    ("foot.R", "ankle.R", (-0.4865, 0.1636, -0.9038), (-0.5149, 0.1431, -0.9884)),
    ("toe.R", "foot.R", (-0.5149, 0.1431, -0.9884), (-0.5793, -0.129, -0.9915)),
    ("heel.02.R", "foot.R", (-0.5106, 0.1615, -0.9904), (-0.4886, 0.2545, -0.989)),
]


def _set_active(obj):
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def create_armature(mecha: dict, root=None, collection_name: str = "ParaModel_Armature"):
    """Create SuperRobotRig procedurally from hard-coded bone table."""
    mecha_id = mecha.get("id", "mecha")
    arm_name = "SuperRobotRig"

    # Remove existing
    if arm_name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[arm_name], do_unlink=True)
    if arm_name in bpy.data.armatures:
        bpy.data.armatures.remove(bpy.data.armatures[arm_name])
    # also remove old procedural names
    old_name = f"armature_{mecha_id}"
    if old_name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[old_name], do_unlink=True)
    if old_name in bpy.data.armatures:
        bpy.data.armatures.remove(bpy.data.armatures[old_name])

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
                active_object=arm_obj,
                object=arm_obj,
                selected_objects=[arm_obj],
                selected_editable_objects=[arm_obj],
            ):
                bpy.ops.object.mode_set(mode="EDIT")
        else:
            bpy.ops.object.mode_set(mode="EDIT")
    except Exception:
        _set_active(arm_obj)
        bpy.ops.object.mode_set(mode="EDIT")

    edit_bones = arm_data.edit_bones
    created = []

    for name, parent_name, head, tail in _SUPER_ROBOT_BONES:
        bone = edit_bones.new(name)
        bone.head = Vector(head)
        bone.tail = Vector(tail)
        bone.use_connect = False
        if parent_name and parent_name in edit_bones:
            bone.parent = edit_bones[parent_name]
        created.append(name)

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

    # Optional slot bone-parent if names overlap
    parented = []
    if arm_obj.type == "ARMATURE" and arm_obj.data:
        bone_names = {b.name for b in arm_obj.data.bones}
        slots = mecha.get("base_body", {}).get("slots", {})
        for slot_id, slot_data in slots.items():
            if not slot_data.get("enabled", False):
                continue
            if slot_id not in bone_names:
                continue
            slot_obj = bpy.data.objects.get(f"slot_{slot_id}")
            if not slot_obj:
                continue
            mw = slot_obj.matrix_world.copy()
            slot_obj.parent = arm_obj
            slot_obj.parent_type = "BONE"
            slot_obj.parent_bone = slot_id
            slot_obj.matrix_world = mw
            parented.append(slot_id)

    return arm_obj, created


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
    bl_description = "Load mecha: root, slots, SuperRobotRig, mesh/placeholder parts"
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
            if arm.name.startswith("armature_") or arm.name == "SuperRobotRig":
                if arm.users == 0:
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
