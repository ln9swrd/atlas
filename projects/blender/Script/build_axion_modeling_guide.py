import bpy
import math
import os


INPUT = r"D:\Atlas\projects\blender\axion_annotation_v2.blend"
OUTPUT = r"D:\Antigravity\Atlas\projects\blender\axion_modeling_guide_v2.blend"


def material(name, color):
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.metallic = 0.0
    mat.roughness = 0.35
    return mat


def curve_object(name, points, mat, bevel=1.8, collection=None):
    data = bpy.data.curves.new(name, type="CURVE")
    data.dimensions = "3D"
    data.bevel_depth = bevel
    data.bevel_resolution = 2
    spline = data.splines.new("POLY")
    spline.points.add(len(points) - 1)
    for point, co in zip(spline.points, points):
        point.co = (*co, 1.0)
    obj = bpy.data.objects.new(name, data)
    (collection or bpy.context.scene.collection).objects.link(obj)
    obj.data.materials.append(mat)
    return obj


def text_object(name, body, location, mat, size=16.0, collection=None):
    data = bpy.data.curves.new(name, type="FONT")
    data.body = body
    data.align_x = "LEFT"
    data.size = size
    data.extrude = 0.15
    obj = bpy.data.objects.new(name, data)
    (collection or bpy.context.scene.collection).objects.link(obj)
    obj.location = location
    obj.rotation_euler = (math.radians(72), 0.0, 0.0)
    obj.data.materials.append(mat)
    return obj


def marker_object(name, location, mat, collection):
    obj = bpy.data.objects.new(name, None)
    collection.objects.link(obj)
    obj.empty_display_type = "SPHERE"
    obj.empty_display_size = 10.0
    obj.location = location
    obj.color = (*mat.diffuse_color[:3], 1.0)
    return obj


def annotation(collection, index, region, kind, priority, target, purpose, guide, reference, confidence, points, label_offset, color=None):
    prefix = f"MG_{index:02d}_{kind}_{region.replace(' ', '_')}"
    if color is None:
        color = {"SILHOUETTE": (1.0, 0.18, 0.05), "PRIMARY_EDGE": (0.05, 0.65, 1.0), "HARD_SURFACE": (1.0, 0.55, 0.05), "SECTION": (0.35, 1.0, 0.25), "LANDMARK": (1.0, 0.12, 0.65)}[kind]
    line_mat = material(f"AXION_GUIDE_{kind}", color)
    marker = marker_object(prefix + "_MARKER", points[0], line_mat, collection)
    curve = curve_object(prefix + "_GUIDE", points, line_mat, 2.4 if kind in {"SILHOUETTE", "PRIMARY_EDGE"} else 1.8, collection)
    leader_end = (points[0][0] + label_offset[0], points[0][1] + label_offset[1], points[0][2] + label_offset[2])
    leader = curve_object(prefix + "_LEADER", [points[0], leader_end], line_mat, 1.1, collection)
    body = "\n".join([
        f"REGION | {region}",
        f"TYPE | {kind}",
        f"PRIORITY | {priority}",
        f"TARGET | {target}",
        f"PURPOSE | {purpose}",
        f"MODELING_GUIDE | {guide}",
        f"REFERENCE | {reference}",
        "SYMMETRY | MIRROR TO OPPOSITE SIDE",
        f"CONFIDENCE | {confidence}",
    ])
    text = text_object(prefix + "_TEXT", body, leader_end, line_mat, 12.0, collection)
    for obj in (marker, curve, leader, text):
        obj["annotation_type"] = kind
        obj["priority"] = priority
        obj["target"] = target
        obj["confidence"] = confidence


bpy.ops.wm.open_mainfile(filepath=INPUT)
mesh_obj = bpy.data.objects["geometry_0"]
before_counts = (len(mesh_obj.data.vertices), len(mesh_obj.data.edges), len(mesh_obj.data.polygons))
before_coords = [tuple(v.co) for v in mesh_obj.data.vertices]

collection = bpy.data.collections.get("AXION_MODELING_GUIDE")
if collection is None:
    collection = bpy.data.collections.new("AXION_MODELING_GUIDE")
    bpy.context.scene.collection.children.link(collection)
else:
    for obj in list(collection.objects):
        bpy.data.objects.remove(obj, do_unlink=True)

silhouette = (1.0, 0.18, 0.05)
primary = (0.05, 0.65, 1.0)
hard = (1.0, 0.55, 0.05)
section = (0.35, 1.0, 0.25)
landmark = (1.0, 0.12, 0.65)

annotations = [
    ("HEAD", "SILHOUETTE", "P1", "UPPER HEAD OUTER SILHOUETTE", "Defines the primary head silhouette for clean retopology.", "Use as the outer contour and build a clean continuous edge flow around the crown.", "Observed crown transition near Z=500-530; X and Y bounds narrow toward the neck.", "CONFIRMED", [(-118, -8, 520), (-150, -15, 570), (-125, -12, 640), (-55, -8, 685)], (-250, 30, 35), silhouette),
    ("NECK", "SILHOUETTE", "P1", "NECK OUTER CONNECTION", "Preserves the narrow transition between head and torso.", "Create a controlled neck loop that blends into the shoulder without copying source triangles.", "Narrow vertical transition below head, inferred from the body bounds.", "INFERENCE", [(-78, 0, 470), (-70, 0, 430), (-82, 0, 390)], (-240, 25, 0), silhouette),
    ("SHOULDER", "SILHOUETTE", "P1", "SHOULDER OUTER SILHOUETTE", "Defines the maximum upper-body width and arm root placement.", "Block the shoulder as a broad continuous contour, mirrored across the centerline.", "Broad lateral mass around the upper torso; measured X width is about 600 in this band.", "CONFIRMED", [(-300, 0, 410), (-365, -5, 370), (-350, -5, 320), (-275, 0, 285)], (-210, 30, 10), silhouette),
    ("CHEST", "SILHOUETTE", "P1", "CHEST FRONT OUTER CONTOUR", "Defines the primary torso silhouette for production modeling.", "Use this as the front chest contour; establish supporting loops from shoulder to waist.", "Broad chest band from approximately Z=130 to Z=410; centerline symmetry is visually intended.", "CONFIRMED", [(-275, -250, 300), (-295, -270, 230), (-280, -270, 150)], (-230, -35, 0), silhouette),
    ("WAIST", "SILHOUETTE", "P1", "WAIST NARROWEST OUTER SILHOUETTE", "Defines the key torso compression before the pelvis.", "Place a clean waist loop at the narrow transition and interpolate evenly to chest and pelvis.", "X width contracts from about 660 near Z=0 toward about 500 near Z=-150.", "CONFIRMED", [(-285, 0, 60), (-245, 0, 0), (-235, 0, -90)], (-225, 30, 0), silhouette),
    ("PELVIS", "SILHOUETTE", "P1", "PELVIS OUTER SILHOUETTE", "Controls the lower torso mass and thigh attachment.", "Build a stable pelvis ring, then derive thigh flow from its left and right attachment points.", "Lower-body mass widens again below the waist; exact armor intent is inferred.", "INFERENCE", [(-235, 0, -110), (-300, 0, -170), (-285, 0, -230)], (-220, 30, 0), silhouette),
    ("UPPER ARM", "SILHOUETTE", "P1", "UPPER ARM OUTER CONTOUR", "Defines the arm mass and shoulder-to-elbow taper.", "Model a continuous arm contour with a readable shoulder root and elbow direction.", "Lateral appendage separates from shoulder mass; source topology is intentionally ignored.", "INFERENCE", [(-350, 0, 320), (-375, 0, 220), (-365, 0, 120)], (-225, 25, 0), silhouette),
    ("FOREARM", "SILHOUETTE", "P1", "FOREARM OUTER CONTOUR", "Defines the distal arm taper and wrist approach.", "Use a simple tapering contour and preserve a clear elbow-to-wrist axis.", "Distal arm contour is visible but exact joint articulation is unverified.", "INFERENCE", [(-365, 0, 105), (-350, 0, 0), (-330, 0, -90)], (-220, 25, 0), silhouette),
    ("THIGH", "SILHOUETTE", "P1", "THIGH OUTER CONTOUR", "Defines the major leg volume below the pelvis.", "Establish thigh loops from pelvis to knee with a gradual taper and symmetric axis.", "Large lower-body volume transitions toward the knee band.", "CONFIRMED", [(-230, 0, -180), (-205, 0, -300), (-185, 0, -400)], (-235, 30, 0), silhouette),
    ("KNEE", "SILHOUETTE", "P1", "KNEE OUTER CONTOUR", "Defines the leg break and articulation envelope.", "Reserve a clean knee volume with front clearance; do not follow small source facets.", "Volume contracts around the knee region; articulation behavior is not directly observable.", "INFERENCE", [(-185, 0, -400), (-170, 0, -455), (-175, 0, -510)], (-225, 25, 0), silhouette),
    ("LOWER LEG", "SILHOUETTE", "P1", "LOWER LEG OUTER CONTOUR", "Defines the shin taper and ankle approach.", "Use long, clean loops from knee to ankle and keep the leg axis legible.", "Lower leg narrows before the foot; exact hard-surface break is inferred.", "INFERENCE", [(-175, 0, -510), (-150, 0, -610), (-135, 0, -680)], (-230, 25, 0), silhouette),
    ("FOOT", "SILHOUETTE", "P1", "FOOT TOE AND HEEL SILHOUETTE", "Defines ground contact and the final leg silhouette.", "Block a stable foot outline with explicit toe, heel, and ground-contact points.", "Lowest geometry reaches approximately Z=-715 and has greater Y depth than the knee bands.", "CONFIRMED", [(-135, -255, -680), (-160, -305, -710), (-20, -305, -715), (70, -220, -700)], (-230, -30, 0), silhouette),
    ("CHEST", "PRIMARY_EDGE", "P1", "CHEST LOWER BOUNDARY", "Provides the main loop separating chest volume from waist transition.", "Create one continuous loop across the torso, mirrored and relaxed through the side planes.", "Major volume transition at approximately Z=130; no source edge loop is being reused.", "INFERENCE", [(-280, -260, 135), (-120, -305, 130), (0, -310, 130), (120, -305, 130), (280, -260, 135)], (-250, -40, 0), primary),
    ("SHOULDER", "PRIMARY_EDGE", "P1", "SHOULDER TO UPPER ARM LOOP", "Defines the shoulder cap and arm-root transition.", "Use as a clean ring around the shoulder cap before routing longitudinal arm loops.", "Broad shoulder mass transitions into the upper arm around Z=300-350.", "INFERENCE", [(-335, -40, 350), (-280, -80, 330), (-215, -110, 325)], (-240, -30, 0), primary),
    ("WAIST", "PRIMARY_EDGE", "P1", "WAIST CONTROL LOOP", "Locks the narrowest torso section for proportional control.", "Build a continuous waist loop and distribute adjacent loops toward chest and pelvis.", "Narrow transition centered near Z=0; measured bounds support the volume change.", "CONFIRMED", [(-245, -120, 0), (-120, -220, 0), (0, -235, 0), (120, -220, 0), (245, -120, 0)], (-220, -45, 0), primary),
    ("PELVIS", "PRIMARY_EDGE", "P1", "PELVIS UPPER BOUNDARY", "Separates the torso from the pelvis mass.", "Use as a stable ring before branching into thigh topology.", "Volume widens again below the waist; exact panel interpretation is inferred.", "INFERENCE", [(-275, -190, -125), (-130, -245, -125), (0, -250, -125), (130, -245, -125), (275, -190, -125)], (-250, -40, 0), primary),
    ("KNEE", "PRIMARY_EDGE", "P2", "KNEE CONTROL LOOP", "Provides a clean articulation loop independent of base topology.", "Place a loop around the knee envelope and maintain clearance for later deformation.", "Knee contraction is visible in the mass profile; pivot center remains unverified.", "INFERENCE", [(-175, -130, -465), (-80, -185, -465), (0, -190, -465), (80, -185, -465), (175, -130, -465)], (-210, -35, 0), primary),
    ("SHOULDER", "HARD_SURFACE", "P2", "SHOULDER ARMOR BOUNDARY", "Marks a plausible armor part split at the arm root.", "Separate the shoulder shell from the torso and upper arm with a controlled hard edge.", "A distinct broad shoulder mass is confirmed; armor semantics are inferred.", "INFERENCE", [(-320, -170, 365), (-285, -205, 330), (-230, -220, 315)], (-230, -45, 0), hard),
    ("CHEST", "HARD_SURFACE", "P2", "CHEST PLATE LOWER BOUNDARY", "Identifies where a chest armor panel could terminate.", "Use as a panel boundary only after confirming the intended design language.", "Front chest volume is broad and changes toward the waist around Z=130.", "UNVERIFIED", [(-240, -300, 150), (-120, -325, 135), (0, -330, 135)], (-230, -45, 0), hard),
    ("PELVIS", "HARD_SURFACE", "P2", "PELVIS ARMOR TRANSITION", "Marks the structural break between waist and pelvis shell.", "Create a separate panel boundary if the production design calls for armor separation.", "Lower torso widens below the waist; no source topology is treated as authority.", "UNVERIFIED", [(-250, -230, -115), (-170, -275, -135), (-120, -290, -160)], (-230, -45, 0), hard),
    ("KNEE", "HARD_SURFACE", "P2", "KNEE CAP BOUNDARY", "Marks a possible hard-surface knee cap perimeter.", "Use a clean closed boundary around the knee cap and preserve the leg axis.", "Knee volume contraction is confirmed; cap design is not confirmed by the mesh alone.", "UNVERIFIED", [(-150, -220, -435), (-95, -255, -465), (-120, -230, -500)], (-220, -40, 0), hard),
    ("WAIST", "SECTION", "P1", "WAIST Z-LEVEL", "Records the main torso control section for proportion matching.", "Recreate this section as a clean symmetric loop before adding surface detail.", "Z=0; estimated X width 490 and Y depth 470 from measured body bounds and transition samples.", "INFERENCE", [(0, -235, 0), (245, -120, 0), (0, 235, 0), (-245, -120, 0), (0, -235, 0)], (270, 20, 0), section),
    ("CHEST", "SECTION", "P1", "CHEST MAXIMUM WIDTH SECTION", "Captures the broad chest proportion.", "Use this section to set maximum torso width and depth, then loft toward shoulder and waist.", "Z=250; X width approximately 600 and Y depth approximately 350 from the observed torso band.", "INFERENCE", [(0, -275, 250), (300, -80, 250), (0, 70, 250), (-300, -80, 250), (0, -275, 250)], (320, 20, 0), section),
    ("PELVIS", "SECTION", "P1", "PELVIS CONTROL SECTION", "Captures the lower-body width before thigh branching.", "Use as a symmetric pelvis ring and derive thigh sockets from its side landmarks.", "Z=-160; X width approximately 570 and Y depth approximately 300, inferred from lower-body bounds.", "INFERENCE", [(0, -255, -160), (285, -80, -160), (0, 55, -160), (-285, -80, -160), (0, -255, -160)], (310, 20, 0), section),
    ("KNEE", "SECTION", "P2", "KNEE ARTICULATION SECTION", "Records the joint envelope needed for later deformation.", "Keep a compact, clear section around the pivot and avoid collapsing the front-back clearance.", "Z=-465; X width approximately 350 and Y depth approximately 250, with pivot center unverified.", "INFERENCE", [(0, -180, -465), (175, -60, -465), (0, 70, -465), (-175, -60, -465), (0, -180, -465)], (220, 20, 0), section),
    ("CENTERLINE", "LANDMARK", "P1", "BODY CENTERLINE", "Anchors symmetry and all mirrored guide construction.", "Build one side from this axis, then mirror to the opposite side unless asymmetry is confirmed.", "X=0 is the modeling symmetry reference; no reliable intentional asymmetry was confirmed.", "CONFIRMED", [(0, -320, 680), (0, -320, 300), (0, -320, -160), (0, -320, -465), (0, -300, -710)], (110, -25, 0), landmark),
    ("SHOULDER", "LANDMARK", "P1", "SHOULDER JOINT CENTER", "Anchors the shoulder pivot and arm attachment.", "Place the shoulder joint around this point and route loops around the pivot envelope.", "Approximate landmark at X=-315, Y=-20, Z=330; exact anatomical pivot is inferred.", "INFERENCE", [(-315, -30, 330)], (-210, -30, 0), landmark),
    ("ELBOW", "LANDMARK", "P2", "ELBOW CENTER", "Anchors the arm bend and longitudinal edge-flow direction.", "Use as the center of a clean elbow loop; preserve a readable upper-arm to forearm axis.", "Approximate landmark at X=-360, Y=-20, Z=120 from the limb contour.", "INFERENCE", [(-360, -30, 120)], (-210, -30, 0), landmark),
    ("KNEE", "LANDMARK", "P1", "KNEE CENTER", "Anchors the primary leg articulation point.", "Build the knee envelope around this point and mirror the opposite side.", "Approximate landmark at X=-170, Y=-30, Z=-465; static geometry cannot confirm the pivot.", "UNVERIFIED", [(-170, -30, -465)], (-210, -30, 0), landmark),
    ("FOOT", "LANDMARK", "P1", "FOOT GROUND CONTACT", "Defines the lowest support point and foot placement.", "Keep this point on the intended ground plane while shaping toe and heel contours.", "Lowest observed region reaches approximately Z=-715; contact interpretation is inferred.", "INFERENCE", [(0, -300, -715)], (150, -30, 0), landmark),
]

annotations.extend([
    ("HAND", "SILHOUETTE", "P1", "HAND OUTER SILHOUETTE", "Defines the distal hand outline needed to start clean palm and finger-block modeling.", "Block the palm, thumb side, and fingertip envelope as a simple mirrored contour; do not copy source triangles.", "The base guide has no hand annotation; the hand region must be confirmed in the source viewport before production modeling.", "UNVERIFIED", [(-330, -5, -90), (-360, -15, -125), (-355, -20, -170), (-320, -15, -190)], (-225, 30, 0), silhouette),
    ("HAND", "SECTION", "P2", "HAND PALM CONTROL SECTION", "Sets the palm width and depth before individual finger decisions.", "Create a compact symmetric palm section and keep finger geometry as a later design decision.", "Hand section dimensions cannot be confirmed from the existing guide; this is a modeling placeholder requiring visual confirmation.", "UNVERIFIED", [(-335, -20, -145), (-360, -5, -145), (-335, 25, -145), (-305, -5, -145), (-335, -20, -145)], (-225, 25, 0), section),
    ("HAND", "LANDMARK", "P2", "WRIST CENTER", "Anchors the hand-to-forearm placement.", "Place the palm block around this point and align its main axis with the forearm.", "Approximate wrist transition at X=-335, Z=-100; exact joint location requires viewport confirmation.", "UNVERIFIED", [(-335, -5, -100)], (-220, 25, 0), landmark),
    ("UPPER ARM", "SECTION", "P2", "UPPER ARM MID SECTION", "Provides the missing arm width and depth control between shoulder and elbow.", "Loft a clean circular or designed section through the shoulder and elbow landmarks.", "The original guide has only an upper-arm silhouette; section dimensions require confirmation against geometry_0.", "UNVERIFIED", [(-360, -35, 220), (-375, -5, 220), (-360, 35, 220), (-345, -5, 220), (-360, -35, 220)], (-225, 25, 0), section),
    ("FOREARM", "SECTION", "P2", "FOREARM MID SECTION", "Provides the missing forearm depth and taper control.", "Use a clean section between elbow and wrist and interpolate it along the forearm axis.", "The original guide has only a forearm silhouette; section dimensions require confirmation against geometry_0.", "UNVERIFIED", [(-350, -28, 0), (-365, -5, 0), (-350, 28, 0), (-335, -5, 0), (-350, -28, 0)], (-225, 25, 0), section),
    ("THIGH", "SECTION", "P2", "THIGH MID SECTION", "Provides the missing thigh width and depth control.", "Loft from the pelvis section to the knee section using a continuous, symmetric leg axis.", "The original guide has only a thigh silhouette; section dimensions require confirmation against geometry_0.", "UNVERIFIED", [(-205, -100, -300), (-225, -5, -300), (-205, 100, -300), (-185, -5, -300), (-205, -100, -300)], (-225, 25, 0), section),
    ("LOWER LEG", "SECTION", "P2", "LOWER LEG MID SECTION", "Provides the missing shin width and depth control.", "Use a clean shin section between knee and ankle and preserve the leg axis.", "The original guide has only a lower-leg silhouette; section dimensions require confirmation against geometry_0.", "UNVERIFIED", [(-150, -70, -610), (-170, -5, -610), (-150, 70, -610), (-130, -5, -610), (-150, -70, -610)], (-225, 25, 0), section),
    ("CHEST", "SECTION", "P1", "REAR CHEST DEPTH SECTION", "Confirms the rear torso boundary so chest volume is not reconstructed from the front alone.", "Match the rear arc and front arc as one continuous torso section before adding armor panels.", "Existing chest section records front and side extents but does not explicitly identify the rear surface.", "INFERENCE", [(0, 58, 250), (300, -80, 250), (0, -275, 250), (-300, -80, 250), (0, 58, 250)], (320, 20, 0), section),
    ("WAIST", "SECTION", "P1", "REAR WAIST DEPTH SECTION", "Confirms the rear waist boundary for a complete torso volume.", "Use the front and rear points to close the waist loop and maintain the centerline.", "Existing waist section includes a rear point but does not label the rear reconstruction requirement.", "INFERENCE", [(0, 58, 0), (245, -120, 0), (0, -235, 0), (-245, -120, 0), (0, 58, 0)], (270, 20, 0), section),
    ("PELVIS", "SECTION", "P1", "REAR PELVIS DEPTH SECTION", "Confirms the rear pelvis boundary before thigh sockets are built.", "Close the pelvis volume through the rear arc and preserve symmetric thigh attachment points.", "Existing pelvis section includes a rear point but does not label the rear reconstruction requirement.", "INFERENCE", [(0, 55, -160), (285, -80, -160), (0, -255, -160), (-285, -80, -160), (0, 55, -160)], (310, 20, 0), section),
])

for index, item in enumerate(annotations, 1):
    annotation(collection, index, *item)

after_counts = (len(mesh_obj.data.vertices), len(mesh_obj.data.edges), len(mesh_obj.data.polygons))
after_coords = [tuple(v.co) for v in mesh_obj.data.vertices]
max_displacement = max((math.dist(a, b) for a, b in zip(before_coords, after_coords)), default=0.0)
scene = bpy.context.scene
scene["AXION_GUIDE_SOURCE"] = INPUT
scene["AXION_GUIDE_GEOMETRY_COUNTS_BEFORE"] = before_counts
scene["AXION_GUIDE_GEOMETRY_COUNTS_AFTER"] = after_counts
scene["AXION_GUIDE_MAX_VERTEX_DISPLACEMENT"] = max_displacement
scene["AXION_GUIDE_ANNOTATION_COUNT"] = len(annotations)

if before_counts != after_counts or max_displacement != 0.0:
    raise RuntimeError(f"Geometry changed: {before_counts} -> {after_counts}, displacement={max_displacement}")

os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT)
print("AXION_GUIDE_COUNTS", before_counts, after_counts)
print("AXION_GUIDE_MAX_VERTEX_DISPLACEMENT", max_displacement)
print("AXION_GUIDE_ANNOTATIONS", len(annotations))
print("AXION_GUIDE_OUTPUT", OUTPUT)