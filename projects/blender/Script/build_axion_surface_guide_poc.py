import bpy
import hashlib
import math
import os
from mathutils import Vector
from mathutils.bvhtree import BVHTree


INPUT = r"D:\Antigravity\Atlas\projects\blender\axion_modeling_guide_v2.blend"
OUTPUT = r"D:\Atlas\projects\blender\axion_surface_guide_poc.blend"
LOG = r"D:\Atlas\projects\blender\axion_surface_guide_poc.log"


def mesh_snapshot(obj):
    coords = tuple(tuple(float(value) for value in vertex.co) for vertex in obj.data.vertices)
    digest = hashlib.sha256(repr(coords).encode("ascii")).hexdigest()
    return (len(coords), len(obj.data.edges), len(obj.data.polygons), coords, digest)


def ray_surface_points(bvh, z=130.0, start=-150.0, end=150.0, step=0.025):
    points = []
    x = start
    while x <= end + 1e-6:
        point, normal, _, _ = bvh.ray_cast(Vector((x, -500.0, z)), Vector((0.0, 1.0, 0.0)), 1000.0)
        if point is None:
            raise RuntimeError(f"Surface gap at x={x}")
        points.append(tuple(point))
        x += step
    return points


def segment_samples(points, per_segment=4):
    samples = []
    for first, second in zip(points, points[1:]):
        first_vector = Vector(first)
        second_vector = Vector(second)
        for index in range(per_segment):
            samples.append(first_vector.lerp(second_vector, index / per_segment))
    samples.append(Vector(points[-1]))
    return samples


def is_inside_mesh(bvh, point):
    direction = Vector((1.0, 0.123, 0.071)).normalized()
    origin = point + direction * 1e-4
    hits = 0
    for _ in range(32):
        hit, _, _, distance = bvh.ray_cast(origin, direction, 100000.0)
        if hit is None:
            break
        hits += 1
        origin = hit + direction * max(distance, 1e-4)
    return hits % 2 == 1


bpy.ops.wm.open_mainfile(filepath=INPUT)
mesh_obj = bpy.data.objects["geometry_0"]
before = mesh_snapshot(mesh_obj)
depsgraph = bpy.context.evaluated_depsgraph_get()
bvh = BVHTree.FromObject(mesh_obj, depsgraph)

# The uninterrupted front-surface interval at Z=130 is the only tested chest edge.
surface_points = ray_surface_points(bvh)

collection = bpy.data.collections.get("AXION_SURFACE_GUIDE_POC")
if collection is None:
    collection = bpy.data.collections.new("AXION_SURFACE_GUIDE_POC")
    bpy.context.scene.collection.children.link(collection)
else:
    for obj in list(collection.objects):
        bpy.data.objects.remove(obj, do_unlink=True)

curve_data = bpy.data.curves.new("CHEST_STRUCTURAL_EDGE_SURFACE", type="CURVE")
curve_data.dimensions = "3D"
curve_data.resolution_u = 1
curve_data.bevel_depth = 1.5
curve_data.bevel_resolution = 2
spline = curve_data.splines.new("POLY")
spline.points.add(len(surface_points) - 1)
for spline_point, point in zip(spline.points, surface_points):
    spline_point.co = (*point, 1.0)
curve = bpy.data.objects.new("CHEST_STRUCTURAL_EDGE_SURFACE_GUIDE", curve_data)
collection.objects.link(curve)

material = bpy.data.materials.new("AXION_SURFACE_GUIDE_POC_MATERIAL")
material.diffuse_color = (1.0, 0.12, 0.02, 1.0)
curve_data.materials.append(material)

shrinkwrap = curve.modifiers.new("SURFACE_PROJECTION_VERIFICATION", "SHRINKWRAP")
shrinkwrap.target = mesh_obj
shrinkwrap.wrap_method = "NEAREST_SURFACEPOINT"
shrinkwrap.wrap_mode = "ON_SURFACE"

curve["TARGET"] = "CHEST"
curve["TYPE"] = "STRUCTURAL_EDGE"
curve["METHOD"] = "SURFACE_PROJECTED_CURVE"
curve["MESH_MODIFIED"] = False
curve["SURFACE_CONTACT"] = "VERIFIED"
curve["INTERPRETATION"] = "Chest lower front volume transition at Z=130, sampled only across the uninterrupted central surface interval."
curve["CONFIDENCE"] = "CONFIRMED for surface contact; INFERENCE for structural-edge meaning."
curve["SOURCE_SURFACE_POINTS"] = len(surface_points)

samples = segment_samples(surface_points)
distances = []
inside_samples = 0
for sample in samples:
    nearest, _, _, distance = bvh.find_nearest(sample)
    distances.append(float(distance))
    if distance > 0.005 and is_inside_mesh(bvh, sample):
        inside_samples += 1

after = mesh_snapshot(mesh_obj)
max_displacement = max((math.dist(first, second) for first, second in zip(before[3], after[3])), default=0.0)
if before[:3] != after[:3] or before[4] != after[4] or max_displacement != 0.0:
    raise RuntimeError("geometry_0 changed during surface guide generation")

result = {
    "TARGET": "CHEST",
    "TYPE": "STRUCTURAL_EDGE",
    "METHOD": "SURFACE_PROJECTED_CURVE",
    "MESH_MODIFIED": "FALSE",
    "SURFACE_CONTACT": "VERIFIED" if max(distances) <= 5e-3 else "UNVERIFIED",
    "INTERPRETATION": curve["INTERPRETATION"],
    "CONFIDENCE": curve["CONFIDENCE"],
    "CONTROL_POINTS": len(surface_points),
    "SAMPLED_POINTS": len(samples),
    "MAX_SURFACE_DISTANCE": max(distances),
    "MEAN_SURFACE_DISTANCE": sum(distances) / len(distances),
    "INSIDE_SAMPLE_COUNT": inside_samples,
    "VERTEX_COUNT": after[0],
    "EDGE_COUNT": after[1],
    "POLYGON_COUNT": after[2],
    "MAX_VERTEX_DISPLACEMENT": max_displacement,
}
scene = bpy.context.scene
for key, value in result.items():
    scene[f"AXION_POC_{key}"] = value

if result["SURFACE_CONTACT"] != "VERIFIED" or inside_samples != 0:
    raise RuntimeError(f"Surface validation failed: {result}")

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT)
with open(LOG, "w", encoding="ascii") as log_file:
    for key, value in result.items():
        log_file.write(f"{key} | {value}\n")
print("AXION_POC_RESULT", result)
print("AXION_POC_OUTPUT", OUTPUT)