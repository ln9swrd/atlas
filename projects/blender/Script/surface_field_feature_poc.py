import bpy
import hashlib
import math
import os
from collections import deque
from mathutils import Vector
from mathutils.bvhtree import BVHTree


INPUT = r"D:\Antigravity\Atlas\projects\blender\axion_modeling_guide_v2.blend"
OUTPUT = r"D:\Atlas\projects\blender\axion_surface_feature_poc.blend"
LOG = r"D:\Atlas\projects\blender\axion_surface_feature_poc.log"


def snapshot(obj):
    coords = tuple(tuple(float(value) for value in vertex.co) for vertex in obj.data.vertices)
    return (len(coords), len(obj.data.edges), len(obj.data.polygons), hashlib.sha256(repr(coords).encode("ascii")).hexdigest(), coords)


def annotation_points(name):
    obj = bpy.data.objects[name]
    return [Vector(point.co[:3]) for spline in obj.data.splines for point in spline.points]


def sample_surface(bvh, x_values, z_values, y_start):
    samples = {}
    for row, z in enumerate(z_values):
        for column, x in enumerate(x_values):
            point, normal, _, _ = bvh.ray_cast(Vector((x, y_start, z)), Vector((0.0, 1.0, 0.0)), 1000.0)
            if point is not None and normal.length > 0:
                samples[(row, column)] = {"position": point.copy(), "normal": normal.normalized()}
    return samples


def analyze_field(samples, rows, columns, radius, threshold):
    radius_squared = radius * radius
    for (row, column), sample in samples.items():
        neighbors = []
        for other_row in range(max(0, row - int(radius / 5) - 1), min(rows, row + int(radius / 5) + 2)):
            for other_column in range(max(0, column - int(radius / 5) - 1), min(columns, column + int(radius / 5) + 2)):
                other = samples.get((other_row, other_column))
                if other is None or (other_row == row and other_column == column):
                    continue
                dx = other["position"].x - sample["position"].x
                dz = other["position"].z - sample["position"].z
                if dx * dx + dz * dz <= radius_squared:
                    neighbors.append(other)
        sample["neighbors"] = len(neighbors)
        if len(neighbors) < 4:
            sample["feature"] = 0.0
            continue
        smoothed = sample["normal"] + sum((other["normal"] for other in neighbors), Vector())
        smoothed.normalize()
        sample["smoothed_normal"] = smoothed
        sample["feature"] = sum(math.degrees(smoothed.angle(other["normal"])) for other in neighbors) / len(neighbors)

    high = {key for key, sample in samples.items() if sample.get("feature", 0.0) >= threshold and sample.get("neighbors", 0) >= 4}
    components = []
    while high:
        seed = high.pop()
        component = {seed}
        queue = deque([seed])
        while queue:
            row, column = queue.popleft()
            for neighbor in ((row - 1, column), (row + 1, column), (row, column - 1), (row, column + 1)):
                if neighbor in high:
                    high.remove(neighbor)
                    component.add(neighbor)
                    queue.append(neighbor)
        components.append(component)
    components.sort(key=len, reverse=True)
    return components


def make_contour(bvh, component, samples, x_values, z_values):
    by_row = {}
    for row, column in component:
        by_row.setdefault(row, []).append(column)
    points = []
    for row in sorted(by_row):
        column = round(sum(by_row[row]) / len(by_row[row]))
        x = x_values[column]
        z = z_values[row]
        point, _, _, _ = bvh.ray_cast(Vector((x, -500.0, z)), Vector((0.0, 1.0, 0.0)), 1000.0)
        if point is not None:
            points.append(tuple(point))
    return points


def run_experiment(label, spacing, radius, threshold):
    bpy.ops.wm.open_mainfile(filepath=INPUT)
    mesh_obj = bpy.data.objects["geometry_0"]
    before = snapshot(mesh_obj)
    bvh = BVHTree.FromObject(mesh_obj, bpy.context.evaluated_depsgraph_get())
    roi_points = annotation_points("MG_04_SILHOUETTE_CHEST_GUIDE")
    min_x = min(point.x for point in roi_points) - 20.0
    max_x = max(point.x for point in roi_points) + 20.0
    min_z = 100.0
    max_z = 430.0
    x_values = [min_x + index * spacing for index in range(round((max_x - min_x) / spacing) + 1)]
    z_values = [min_z + index * spacing for index in range(round((max_z - min_z) / spacing) + 1)]
    samples = sample_surface(bvh, x_values, z_values, -500.0)
    components = analyze_field(samples, len(z_values), len(x_values), radius, threshold)
    large = [component for component in components if len(component) >= 8]
    contours = [make_contour(bvh, component, samples, x_values, z_values) for component in large]
    contours = [contour for contour in contours if len(contour) >= 4]
    lengths = []
    agreements = []
    for contour, component in zip(contours, large):
        lengths.append(sum((Vector(second) - Vector(first)).length for first, second in zip(contour, contour[1:])))
        agreements.append(sum(samples[key]["feature"] for key in component) / len(component))
    result = {
        "label": label,
        "spacing": spacing,
        "radius": radius,
        "threshold": threshold,
        "sample_count": len(samples),
        "candidate_components": len(components),
        "large_components": len(large),
        "contour_count": len(contours),
        "longest_contour": max(lengths, default=0.0),
        "feature_agreement": max(agreements, default=0.0),
        "mesh_snapshot": before,
        "samples": samples,
        "components": components,
        "contours": contours,
    }
    print("EXPERIMENT", {key: value for key, value in result.items() if key not in {"mesh_snapshot", "samples", "components", "contours"}})
    return result


experiments = [
    ("R1", 5.0, 10.0, 12.0),
    ("R2", 5.0, 15.0, 12.0),
    ("R3", 5.0, 15.0, 10.0),
]
results = [run_experiment(*experiment) for experiment in experiments]
chosen = next((result for result in results if result["contour_count"] == 1 and result["longest_contour"] >= 80.0), None)

if chosen is None:
    with open(LOG, "w", encoding="ascii") as log_file:
        for result in results:
            log_file.write(" ".join(f"{key}={value}" for key, value in result.items() if key not in {"mesh_snapshot", "samples", "components", "contours"}) + "\n")
    print("AUTOMATION_NOT_PRACTICAL")
    raise SystemExit(0)

bpy.ops.wm.open_mainfile(filepath=INPUT)
mesh_obj = bpy.data.objects["geometry_0"]
before = snapshot(mesh_obj)
collection = bpy.data.collections.new("AXION_SURFACE_FEATURE_POC")
bpy.context.scene.collection.children.link(collection)
curve_data = bpy.data.curves.new("CHEST_SURFACE_FEATURE_CONTOUR", type="CURVE")
curve_data.dimensions = "3D"
curve_data.bevel_depth = 1.2
spline = curve_data.splines.new("POLY")
spline.points.add(len(chosen["contours"][0]) - 1)
for spline_point, point in zip(spline.points, chosen["contours"][0]):
    spline_point.co = (*point, 1.0)
curve = bpy.data.objects.new("CHEST_SURFACE_FEATURE_CONTOUR", curve_data)
collection.objects.link(curve)
curve["SOURCE"] = "geometry_0"
curve["TYPE"] = "SURFACE_FEATURE"
curve["METHOD"] = "SPATIAL_NORMAL_FIELD_CONTOUR"
curve["MESH_MODIFIED"] = False
curve["SURFACE_CONTACT"] = True
after = snapshot(mesh_obj)
displacement = max((math.dist(first, second) for first, second in zip(before[4], after[4])), default=0.0)
if before[:4] != after[:4] or displacement != 0.0:
    raise RuntimeError("geometry_0 changed")
bpy.context.scene["AXION_FEATURE_SPACING"] = chosen["spacing"]
bpy.context.scene["AXION_FEATURE_RADIUS"] = chosen["radius"]
bpy.context.scene["AXION_FEATURE_THRESHOLD"] = chosen["threshold"]
bpy.context.scene["AXION_FEATURE_MAX_VERTEX_DISPLACEMENT"] = displacement
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT)
print("SAVED", OUTPUT)