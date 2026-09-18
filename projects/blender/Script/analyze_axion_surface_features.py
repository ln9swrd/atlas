import bpy
import math
import os
from collections import defaultdict
from mathutils import Vector


INPUT = r"D:\Antigravity\Atlas\projects\blender\axion_modeling_guide_v2.blend"


bpy.ops.wm.open_mainfile(filepath=INPUT)
mesh_obj = bpy.data.objects["geometry_0"]
mesh = mesh_obj.data
chest_guide = bpy.data.objects.get("MG_13_PRIMARY_EDGE_CHEST_GUIDE")
if chest_guide is None:
    raise RuntimeError("CHEST guide ROI not found")

guide_points = [tuple(point.co[:3]) for spline in chest_guide.data.splines for point in spline.points]
guide_min = [min(point[i] for point in guide_points) for i in range(3)]
guide_max = [max(point[i] for point in guide_points) for i in range(3)]
# The existing chest guide defines a review region; it is not copied as the feature result.
roi_min = (guide_min[0] - 45.0, -350.0, 90.0)
roi_max = (guide_max[0] + 45.0, 70.0, 430.0)

vertices = [vertex.co.copy() for vertex in mesh.vertices]
face_data = {}
edge_faces = defaultdict(list)
for polygon in mesh.polygons:
    center = polygon.center
    if not all(roi_min[i] <= center[i] <= roi_max[i] for i in range(3)):
        continue
    face_data[polygon.index] = polygon.normal.copy()
    vertex_indices = polygon.vertices
    for first, second in zip(vertex_indices, vertex_indices[1:] + vertex_indices[:1]):
        edge_faces[(min(first, second), max(first, second))].append(polygon.index)

candidate_edges = []
for edge_key, faces in edge_faces.items():
    if len(faces) != 2:
        continue
    first_normal = face_data[faces[0]]
    second_normal = face_data[faces[1]]
    angle = math.degrees(first_normal.angle(second_normal))
    first_vertex = vertices[edge_key[0]]
    second_vertex = vertices[edge_key[1]]
    length = (first_vertex - second_vertex).length
    if angle >= 35.0 and length >= 2.0:
        candidate_edges.append((edge_key, angle, length))

adjacency = defaultdict(list)
for index, (edge_key, _, _) in enumerate(candidate_edges):
    adjacency[edge_key[0]].append(index)
    adjacency[edge_key[1]].append(index)
visited = set()
components = []
for index in range(len(candidate_edges)):
    if index in visited:
        continue
    stack = [index]
    visited.add(index)
    component = []
    while stack:
        current = stack.pop()
        component.append(current)
        edge_key = candidate_edges[current][0]
        for vertex_index in edge_key:
            for neighbor in adjacency[vertex_index]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    stack.append(neighbor)
    components.append(component)

summary = []
for component in components:
    points = []
    total_length = 0.0
    angles = []
    for index in component:
        edge_key, angle, length = candidate_edges[index]
        points.extend((vertices[edge_key[0]], vertices[edge_key[1]]))
        total_length += length
        angles.append(angle)
    min_point = [min(point[i] for point in points) for i in range(3)]
    max_point = [max(point[i] for point in points) for i in range(3)]
    summary.append((total_length, len(component), sum(angles) / len(angles), tuple(round(value, 2) for value in min_point), tuple(round(value, 2) for value in max_point)))

summary.sort(reverse=True)
print("ROI", tuple(round(value, 2) for value in roi_min), tuple(round(value, 2) for value in roi_max))
print("FACES", len(face_data), "EDGES", len(edge_faces), "CANDIDATE_EDGES", len(candidate_edges), "COMPONENTS", len(components))
for item in summary[:20]:
    print("COMPONENT", item)