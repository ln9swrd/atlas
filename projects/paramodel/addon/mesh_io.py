import bpy
import os


def parts_dir(root):
    """Return parts directory from project root or existing parts path."""
    if not root:
        return ""
    if os.path.basename(root.rstrip(os.sep)) == "parts" and os.path.isdir(root):
        return root
    candidate = os.path.join(root, "data", "parts")
    if os.path.isdir(candidate):
        return candidate
    candidate = os.path.join(root, "parts")
    if os.path.isdir(candidate):
        return candidate
    return os.path.join(root, "data", "parts")


def resolve_mesh_path(part, part_id, root):
    """Resolve absolute path to mesh file from part metadata or auto-convention."""
    pdir = parts_dir(root)
    candidates = []
    mesh_rel = part.get("mesh")
    if mesh_rel:
        candidates.append(os.path.join(pdir, mesh_rel))
        if not os.path.isabs(mesh_rel):
            candidates.append(os.path.join(pdir, "meshes", os.path.basename(mesh_rel)))
    for ext in (".glb", ".gltf", ".obj", ".fbx", ".blend"):
        candidates.append(os.path.join(pdir, "meshes", f"{part_id}{ext}"))
    seen = set()
    for path in candidates:
        if not path or path in seen:
            continue
        seen.add(path)
        if os.path.isfile(path):
            return path
    return None


def unlink_from_all_collections(obj):
    for coll in list(obj.users_collection):
        coll.objects.unlink(obj)


def import_mesh_file(filepath):
    """Import a mesh file; return list of newly created objects."""
    ext = os.path.splitext(filepath)[1].lower()
    before = set(bpy.data.objects.keys())

    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        try:
            bpy.ops.object.mode_set(mode="OBJECT")
        except Exception:
            pass

    try:
        if ext in (".glb", ".gltf"):
            bpy.ops.import_scene.gltf(filepath=filepath)
        elif ext == ".obj":
            if hasattr(bpy.ops.wm, "obj_import"):
                bpy.ops.wm.obj_import(filepath=filepath)
            else:
                bpy.ops.import_scene.obj(filepath=filepath)
        elif ext == ".fbx":
            bpy.ops.import_scene.fbx(filepath=filepath)
        elif ext == ".blend":
            with bpy.data.libraries.load(filepath, link=False) as (data_from, data_to):
                data_to.objects = [name for name in data_from.objects]
            for obj in data_to.objects:
                if obj is not None and obj.name not in bpy.context.scene.collection.objects:
                    bpy.context.scene.collection.objects.link(obj)
        else:
            return []
    except Exception:
        return []

    after = set(bpy.data.objects.keys())
    new_names = after - before
    return [bpy.data.objects[n] for n in new_names if n in bpy.data.objects]


def create_placeholder_cube(name, size, uf, coll):
    import bmesh
    sx = float(size[0]) * uf if len(size) > 0 else 0.3 * uf
    sy = float(size[1]) * uf if len(size) > 1 else 0.3 * uf
    sz = float(size[2]) * uf if len(size) > 2 else 0.3 * uf
    mesh = bpy.data.meshes.new(name + "_mesh")
    obj = bpy.data.objects.new(name, mesh)
    coll.objects.link(obj)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bm.to_mesh(mesh)
    bm.free()
    obj.scale = (sx, sy, sz)
    return obj
