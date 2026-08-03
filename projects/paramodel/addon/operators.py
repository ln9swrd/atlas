import bpy
import json
import math
import os
from mathutils import Vector
from bpy.types import Operator
from . import mesh_io


def _unit_to_bu(m):
    try:
        s = float(bpy.context.scene.unit_settings.scale_length)
    except Exception:
        s = 1.0
    return m / (s if s > 0 else 1.0)


def _uf():
    return _unit_to_bu(1.0)


def _package_dir():
    """Directory containing this addon module (operators.py)."""
    return os.path.dirname(os.path.abspath(__file__))


def _project_root():
    """paramodel project root when running from repo (addon/ is one level down)."""
    pkg = _package_dir()
    parent = os.path.dirname(pkg)
    if os.path.isdir(os.path.join(parent, "schema")):
        return parent
    if os.path.isdir(os.path.join(pkg, "schema")):
        return pkg
    return parent


def _find_file(*relative_parts, data_path=None):
    """Locate a project file across zip-install and repo layouts."""
    candidates = []
    pkg = _package_dir()
    proj = _project_root()
    candidates.append(os.path.join(pkg, *relative_parts))
    candidates.append(os.path.join(proj, *relative_parts))
    if data_path:
        # data_path = .../data/mecha → project = .../paramodel
        mecha_dir = os.path.abspath(data_path)
        data_dir = os.path.dirname(mecha_dir)
        paramodel_dir = os.path.dirname(data_dir)
        candidates.append(os.path.join(paramodel_dir, *relative_parts))
        candidates.append(os.path.join(data_dir, *relative_parts))
    for path in candidates:
        if path and os.path.isfile(path):
            return path
    return None


def _load_bones():
    path = os.path.join(_package_dir(), "bones.json")
    with open(path, "r", encoding="utf-8") as f:
        return [(n, p, tuple(h), tuple(t)) for n, p, h, t in json.load(f)]


def load_mecha_json(data_path, mecha_id):
    fp = os.path.join(data_path, f"{mecha_id}.json")
    if not os.path.isfile(fp):
        raise FileNotFoundError(f"Mecha data not found: {fp}")
    with open(fp, "r", encoding="utf-8") as f:
        return json.load(f)


def load_template(template_id, data_path=None):
    """Load schema/templates/{id}.json; empty dict if missing."""
    if not template_id:
        return {}
    path = _find_file("schema", "templates", f"{template_id}.json", data_path=data_path)
    if not path and template_id in ("standard_25m", "standard_15m", "standard_50m"):
        path = _find_file("schema", "templates", "humanoid.json", data_path=data_path)
    if not path:
        return {}
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def resolve_size(mecha, data_path=None):
    """Return (primary, value_m, reference_m, scale_factor).

    Contract: sf = value / template.reference_value
    Fallback: parameters.height; reference default 2.0 (humanoid authored scale).
    """
    size = mecha.get("size") or {}
    primary = size.get("primary") or "height"
    value = size.get("value")
    if value is None:
        value = (mecha.get("parameters") or {}).get("height")
    if value is None:
        value = 25.0
    value = float(value)

    template_id = (
        mecha.get("archetype")
        or (mecha.get("base_body") or {}).get("template")
        or "humanoid"
    )
    tmpl = load_template(template_id, data_path=data_path)
    tsize = tmpl.get("size") or {}
    ref = tsize.get("reference_value")
    if ref is None:
        ref = 2.0
    ref = float(ref)
    if ref <= 0:
        ref = 2.0
    sf = value / ref
    return primary, value, ref, sf


def load_default_slots(data_path=None):
    path = _find_file("schema", "base-body-slots.json", data_path=data_path)
    if not path:
        return {}
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return {s["id"]: s for s in data.get("default_slots", []) if s.get("id")}


def _parts_root(data_path=None):
    """Directory containing part JSON files."""
    if data_path:
        mecha_dir = os.path.abspath(data_path)
        data_dir = os.path.dirname(mecha_dir)
        candidate = os.path.join(data_dir, "parts")
        if os.path.isdir(candidate):
            return candidate
    for base in (_package_dir(), _project_root()):
        candidate = os.path.join(base, "data", "parts")
        if os.path.isdir(candidate):
            return candidate
    return os.path.join(_project_root(), "data", "parts")


def load_part(part_id, data_path=None):
    if not part_id:
        return {}
    path = os.path.join(_parts_root(data_path), f"{part_id}.json")
    if not os.path.isfile(path):
        return {}
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def _ensure_collection(name):
    if name in bpy.data.collections:
        return bpy.data.collections[name]
    coll = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(coll)
    return coll


def _set_active(obj):
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def _mode(obj, mode):
    _set_active(obj)
    try:
        if hasattr(bpy.context, "temp_override"):
            with bpy.context.temp_override(
                active_object=obj, object=obj,
                selected_objects=[obj], selected_editable_objects=[obj],
            ):
                bpy.ops.object.mode_set(mode=mode)
        else:
            bpy.ops.object.mode_set(mode=mode)
    except Exception:
        _set_active(obj)
        bpy.ops.object.mode_set(mode=mode)


def _raise_clip_end(minimum=100.0):
    """Ensure 3D view clip_end is large enough for the loaded model."""
    try:
        for window in bpy.context.window_manager.windows:
            screen = window.screen
            if not screen:
                continue
            for area in screen.areas:
                if area.type != "VIEW_3D":
                    continue
                for space in area.spaces:
                    if space.type == "VIEW_3D":
                        if space.clip_end < minimum:
                            space.clip_end = minimum
    except Exception:
        pass


def _parent_keep_local(child, parent):
    """Parent child to parent; location/rotation stay as local coords."""
    child.parent = parent
    child.matrix_parent_inverse.identity()


def create_root(mecha, collection_name="ParaModel_Root", working_scale=0.01, data_path=None):
    coll = _ensure_collection(collection_name)
    mecha_id = mecha.get("id", "mecha")
    name = f"root_{mecha_id}"
    if name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    root = bpy.data.objects.new(name, None)
    root.empty_display_type = "PLAIN_AXES"
    root.empty_display_size = _unit_to_bu(0.5)
    coll.objects.link(root)
    primary, value, ref, sf = resolve_size(mecha, data_path=data_path)
    ws = float(working_scale) if working_scale else 0.01
    if ws <= 0:
        ws = 0.01
    effective = sf * ws
    root.scale = (effective, effective, effective)
    root["paramodel_root"] = True
    root["paramodel_mecha_id"] = mecha_id
    root["paramodel_archetype"] = mecha.get("archetype") or ""
    root["paramodel_size_primary"] = primary
    root["paramodel_size_value"] = value
    root["paramodel_size_reference"] = ref
    root["paramodel_scale_factor"] = sf
    root["paramodel_working_scale"] = ws
    root["paramodel_effective_scale"] = effective
    params = mecha.get("parameters") or {}
    root["paramodel_mass"] = float(params.get("mass") or 0)
    root["paramodel_mobility"] = float(params.get("mobility") or 0)
    root["paramodel_output"] = float(params.get("output") or 0)
    root["paramodel_armor"] = float(params.get("armor_thickness") or 0)
    return root


def create_slot_empties(mecha, root=None, collection_name="ParaModel_Slots", data_path=None):
    slots = mecha.get("base_body", {}).get("slots", {})
    if not slots:
        raise ValueError("No base_body.slots found in mecha data")
    defaults = load_default_slots(data_path=data_path)
    coll = _ensure_collection(collection_name)
    created = []
    uf = _uf()
    for slot_id, slot_data in slots.items():
        if not slot_data.get("enabled", False):
            continue
        name = f"slot_{slot_id}"
        if name in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
        empty = bpy.data.objects.new(name, None)
        empty.empty_display_type = "ARROWS"
        empty.empty_display_size = _unit_to_bu(0.3)
        coll.objects.link(empty)
        if root:
            _parent_keep_local(empty, root)
        defn = defaults.get(slot_id, {})
        pos = defn.get("position") or slot_data.get("position") or [0, 0, 0]
        rot = defn.get("rotation") or slot_data.get("rotation") or [0, 0, 0]
        if len(pos) >= 3:
            empty.location = (float(pos[0]) * uf, float(pos[1]) * uf, float(pos[2]) * uf)
        if len(rot) >= 3:
            empty.rotation_euler = tuple(math.radians(float(r)) for r in rot[:3])
        empty["paramodel_slot"] = slot_id
        empty["paramodel_part_id"] = slot_data.get("part_id") or ""
        empty["paramodel_mecha_id"] = mecha.get("id", "")
        empty["paramodel_connection_type"] = defn.get("connection_type", "")
        created.append(name)
    return created


def create_armature(mecha, root=None, collection_name="ParaModel_Armature"):
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
    _mode(arm_obj, "EDIT")
    created = []
    uf = _uf()
    bones_data = _load_bones()
    min_z = min(min(h[2], t[2]) for _, _, h, t in bones_data)
    z_off = -min_z
    for name, parent_name, head, tail in bones_data:
        bone = arm_data.edit_bones.new(name)
        bone.head = Vector((head[0], head[1], head[2] + z_off)) * uf
        bone.tail = Vector((tail[0], tail[1], tail[2] + z_off)) * uf
        bone.use_connect = False
        if parent_name and parent_name in arm_data.edit_bones:
            bone.parent = arm_data.edit_bones[parent_name]
        created.append(name)
    _mode(arm_obj, "OBJECT")
    arm_obj["paramodel_ground_offset_m"] = z_off
    if root:
        _parent_keep_local(arm_obj, root)
        arm_obj.location = (0, 0, 0)
    return arm_obj, created


def attach_parts(mecha, prefer_mesh=True, collection_name="ParaModel_Parts", data_path=None):
    slots = mecha.get("base_body", {}).get("slots", {})
    coll = _ensure_collection(collection_name)
    attached, mesh_count, placeholder_count = [], 0, 0
    parts_root = _parts_root(data_path)
    for slot_id, slot_data in slots.items():
        if not slot_data.get("enabled", False):
            continue
        part_id = slot_data.get("part_id")
        if not part_id:
            continue
        slot_obj = bpy.data.objects.get(f"slot_{slot_id}")
        if not slot_obj:
            continue
        part = load_part(part_id, data_path=data_path)
        mesh_name = f"part_{slot_id}_{part_id}"
        if mesh_name in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[mesh_name], do_unlink=True)
        used = False
        mesh_path = (
            mesh_io.resolve_mesh_path(part, part_id, os.path.dirname(parts_root))
            if prefer_mesh else None
        )
        if mesh_path:
            imported = mesh_io.import_mesh_file(mesh_path)
            if imported:
                if len(imported) == 1:
                    obj = imported[0]
                    mesh_io.unlink_from_all_collections(obj)
                    coll.objects.link(obj)
                    obj.name = mesh_name
                    _parent_keep_local(obj, slot_obj)
                    obj.location = (0, 0, 0)
                    obj.rotation_euler = (0, 0, 0)
                    obj["paramodel_part"] = True
                    obj["paramodel_part_id"] = part_id
                    obj["paramodel_slot"] = slot_id
                    obj["paramodel_mesh_source"] = mesh_path
                    attached.append(obj.name)
                else:
                    parent = bpy.data.objects.new(mesh_name, None)
                    parent.empty_display_type = "PLAIN_AXES"
                    parent.empty_display_size = _unit_to_bu(0.15)
                    coll.objects.link(parent)
                    _parent_keep_local(parent, slot_obj)
                    parent.location = (0, 0, 0)
                    parent.rotation_euler = (0, 0, 0)
                    parent["paramodel_part"] = True
                    parent["paramodel_part_id"] = part_id
                    parent["paramodel_slot"] = slot_id
                    parent["paramodel_mesh_source"] = mesh_path
                    for i, obj in enumerate(imported):
                        mesh_io.unlink_from_all_collections(obj)
                        coll.objects.link(obj)
                        obj.name = f"{mesh_name}_{i}"
                        _parent_keep_local(obj, parent)
                        obj.location = (0, 0, 0)
                        obj["paramodel_part"] = True
                        obj["paramodel_part_id"] = part_id
                        obj["paramodel_slot"] = slot_id
                        obj["paramodel_mesh_source"] = mesh_path
                    attached.append(parent.name)
                mesh_count += 1
                used = True
        if not used:
            size = (part.get("placeholder") or {}).get("size") or [0.3, 0.3, 0.3]
            obj = mesh_io.create_placeholder_cube(mesh_name, size, _uf(), coll)
            _parent_keep_local(obj, slot_obj)
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
        s = context.scene.paramodel
        if not s.data_path:
            self.report({"ERROR"}, "Data Path is empty")
            return {"CANCELLED"}
        data_path = s.data_path
        try:
            mecha = load_mecha_json(data_path, s.selected_mecha)
        except Exception as e:
            self.report({"ERROR"}, str(e))
            return {"CANCELLED"}
        if context.object and context.object.mode != "OBJECT":
            try:
                bpy.ops.object.mode_set(mode="OBJECT")
            except Exception:
                pass
        ws = getattr(s, "working_scale", 0.01)
        root = (
            create_root(mecha, working_scale=ws, data_path=data_path)
            if s.apply_parameters else None
        )
        n_slots = (
            len(create_slot_empties(mecha, root=root, data_path=data_path))
            if s.create_empties else 0
        )
        n_bones = 0
        if getattr(s, "create_armature", False):
            try:
                _, bones = create_armature(mecha, root=root)
                n_bones = len(bones)
            except Exception as e:
                self.report({"WARNING"}, f"Armature failed: {e}")
        n_parts = n_mesh = n_ph = 0
        if s.create_placeholders:
            attached, n_mesh, n_ph = attach_parts(
                mecha, prefer_mesh=s.prefer_mesh, data_path=data_path
            )
            n_parts = len(attached)
        primary, value, ref, sf = resolve_size(mecha, data_path=data_path)
        effective = sf * float(ws if ws else 0.01)
        _raise_clip_end(minimum=max(100.0, value * float(ws if ws else 0.01) * 20))
        slot_src = "ok" if load_default_slots(data_path=data_path) else "MISSING_SCHEMA"
        self.report(
            {"INFO"},
            f"Loaded {s.selected_mecha}: {n_slots} slots, {n_bones} bones, "
            f"{n_parts} parts ({n_mesh} mesh / {n_ph} placeholder), "
            f"sf={sf:.3f} ws={float(ws):.4f} eff={effective:.4f} "
            f"({primary} {value}/{ref}) slots={slot_src}",
        )
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
            if any(obj.get(k) is not None for k in (
                "paramodel_slot", "paramodel_part", "paramodel_root", "paramodel_armature"
            )):
                bpy.data.objects.remove(obj, do_unlink=True)
                removed += 1
        for name in ("ParaModel_Root", "ParaModel_Slots", "ParaModel_Parts", "ParaModel_Armature"):
            if name in bpy.data.collections:
                bpy.data.collections.remove(bpy.data.collections[name])
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
