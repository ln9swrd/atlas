import bpy
import math
from mathutils import Vector

INPUT_FILE = r"D:\Atlas\projects\blender\anime.blend"
OUTPUT_FILE = r"D:\Atlas\projects\blender\anime_skinned.blend"
ARMATURE_NAME = "axion_metarig"
MESH_NAME = "axion_skin_mesh"


def add_sphere(name, location, scale):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=24,
        ring_count=16,
        location=location,
    )
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return obj


def add_segment(name, head, tail, radius):
    head = Vector(head)
    tail = Vector(tail)
    direction = tail - head
    length = direction.length
    if length <= 0.001:
        return None
    midpoint = (head + tail) * 0.5
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=20,
        radius=radius,
        depth=length,
        location=midpoint,
    )
    obj = bpy.context.object
    obj.name = name
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector((0.0, 0.0, 1.0)).rotation_difference(direction)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    return obj


def distance_to_segment(point, head, tail):
    segment = tail - head
    length_squared = segment.length_squared
    if length_squared == 0.0:
        return (point - head).length
    factor = max(0.0, min(1.0, (point - head).dot(segment) / length_squared))
    return (point - (head + factor * segment)).length


bpy.ops.wm.open_mainfile(filepath=INPUT_FILE)
armature = bpy.data.objects.get(ARMATURE_NAME)
if armature is None or armature.type != "ARMATURE":
    raise RuntimeError(f"Armature not found: {ARMATURE_NAME}")

old_mesh = bpy.data.objects.get(MESH_NAME)
if old_mesh is not None:
    bpy.data.objects.remove(old_mesh, do_unlink=True)

parts = []
parts.append(add_sphere("skin_torso", (0.0, 155.0, 300.0), (210.0, 135.0, 300.0)))
parts.append(add_sphere("skin_head", (0.0, 155.0, 760.0), (145.0, 125.0, 170.0)))
parts.append(add_segment("skin_upper_arm.L", (160.0, 166.0, 570.0), (256.0, 222.0, 331.0), 62.0))
parts.append(add_segment("skin_upper_arm.R", (-160.0, 166.0, 570.0), (-256.0, 222.0, 331.0), 62.0))
parts.append(add_segment("skin_forearm.L", (256.0, 222.0, 331.0), (324.0, 186.0, 103.0), 52.0))
parts.append(add_segment("skin_forearm.R", (-256.0, 222.0, 331.0), (-322.0, 186.0, 103.0), 52.0))
parts.append(add_segment("skin_thigh.L", (71.0, 153.0, 101.0), (106.0, 116.0, -388.0), 90.0))
parts.append(add_segment("skin_thigh.R", (-69.0, 153.0, 101.0), (-35.0, 116.0, -388.0), 90.0))
parts.append(add_segment("skin_shin.L", (106.0, 116.0, -388.0), (134.0, 157.0, -802.0), 68.0))
parts.append(add_segment("skin_shin.R", (-35.0, 116.0, -388.0), (-6.0, 157.0, -802.0), 68.0))
parts.append(add_segment("skin_foot.L", (134.0, 157.0, -802.0), (139.0, 56.0, -865.0), 72.0))
parts.append(add_segment("skin_foot.R", (-6.0, 157.0, -802.0), (-1.0, 56.0, -865.0), 72.0))
parts = [part for part in parts if part is not None]

bpy.ops.object.select_all(action="DESELECT")
for part in parts:
    part.select_set(True)
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.join()
mesh = bpy.context.object
mesh.name = MESH_NAME
mesh.data.name = f"{MESH_NAME}_data"

modifier = mesh.modifiers.new(name="Armature", type="ARMATURE")
modifier.object = armature

bones = [bone for bone in armature.data.bones if bone.use_deform]
for bone in bones:
    mesh.vertex_groups.new(name=bone.name)

world_matrix = armature.matrix_world
for vertex in mesh.data.vertices:
    point = mesh.matrix_world @ vertex.co
    nearest_bone = min(
        bones,
        key=lambda bone: distance_to_segment(
            point,
            world_matrix @ bone.head_local,
            world_matrix @ bone.tail_local,
        ),
    )
    mesh.vertex_groups[nearest_bone.name].add([vertex.index], 1.0, "REPLACE")

material = bpy.data.materials.get("Axion Skin") or bpy.data.materials.new("Axion Skin")
material.diffuse_color = (0.24, 0.42, 0.68, 1.0)
mesh.data.materials.append(material)

bpy.ops.object.select_all(action="DESELECT")
mesh.select_set(True)
bpy.context.view_layer.objects.active = mesh
bpy.context.scene.frame_set(1)
bpy.context.view_layer.update()

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_FILE)
print("SKIN_MESH_SAVED", OUTPUT_FILE)
print("MESH", mesh.name, "VERTICES", len(mesh.data.vertices), "MODIFIER", modifier.object.name)
print("VERTEX_GROUPS", len(mesh.vertex_groups))
