import bpy
import math

INPUT_FILE = r"D:\Atlas\projects\blender\axion_proto.blend"
OUTPUT_FILE = r"D:\Atlas\projects\blender\axion_proto_improved.blend"
ARMATURE_NAME = "axion_metarig"
SOURCE_ACTION = "axion_Run Forward"
OUTPUT_ACTION = "axion_Run Forward Improved"
FRAMES = (1, 7, 13, 19, 25, 31)


def get_object_slot(action, armature):
    identifier = f"OB{armature.name}"
    for slot in action.slots:
        if slot.target_id_type == "OBJECT" and slot.identifier == identifier:
            return slot
    return action.slots.new("OBJECT", armature.name)


def reset_pose(armature):
    for bone in armature.pose.bones:
        bone.location = (0.0, 0.0, 0.0)
        bone.rotation_mode = "XYZ"
        bone.rotation_euler = (0.0, 0.0, 0.0)
        bone.scale = (1.0, 1.0, 1.0)


def set_rotation(armature, name, values):
    bone = armature.pose.bones.get(name)
    if bone:
        bone.rotation_mode = "XYZ"
        bone.rotation_euler = tuple(math.radians(value) for value in values)


def key_all(armature, frame):
    for bone in armature.pose.bones:
        bone.keyframe_insert(data_path="location", frame=frame, group=bone.name)
        bone.keyframe_insert(data_path="rotation_euler", frame=frame, group=bone.name)
        bone.keyframe_insert(data_path="scale", frame=frame, group=bone.name)


bpy.ops.wm.open_mainfile(filepath=INPUT_FILE)
armature = bpy.data.objects.get(ARMATURE_NAME)
if armature is None or armature.type != "ARMATURE":
    raise RuntimeError(f"Armature not found: {ARMATURE_NAME}")

old = bpy.data.actions.get(OUTPUT_ACTION)
if old:
    bpy.data.actions.remove(old, do_unlink=True)

action = bpy.data.actions.new(OUTPUT_ACTION)
slot = get_object_slot(action, armature)
armature.animation_data_create()
armature.animation_data.action = action
armature.animation_data.action_slot = slot

poses = [
    {
        "spine_location": (0.0, 0.0, 0.00),
        "spine": (2.0, 0.0, 0.0),
        "thigh.L": (34.0, 0.0, 0.0), "thigh.R": (-30.0, 0.0, 0.0),
        "shin.L": (-14.0, 0.0, 0.0), "shin.R": (48.0, 0.0, 0.0),
        "foot.L": (-8.0, 0.0, 0.0), "foot.R": (10.0, 0.0, 0.0),
        "upper_arm.L": (-24.0, 0.0, 0.0), "upper_arm.R": (24.0, 0.0, 0.0),
        "forearm.L": (-10.0, 0.0, 0.0), "forearm.R": (-10.0, 0.0, 0.0),
    },
    {
        "spine_location": (0.0, 0.0, 0.025),
        "spine": (0.0, 0.0, 0.0),
        "thigh.L": (10.0, 0.0, 0.0), "thigh.R": (10.0, 0.0, 0.0),
        "shin.L": (50.0, 0.0, 0.0), "shin.R": (-12.0, 0.0, 0.0),
        "foot.L": (12.0, 0.0, 0.0), "foot.R": (-8.0, 0.0, 0.0),
        "upper_arm.L": (18.0, 0.0, 0.0), "upper_arm.R": (-18.0, 0.0, 0.0),
        "forearm.L": (-8.0, 0.0, 0.0), "forearm.R": (-8.0, 0.0, 0.0),
    },
    {
        "spine_location": (0.0, 0.0, 0.00),
        "spine": (-2.0, 0.0, 0.0),
        "thigh.L": (-30.0, 0.0, 0.0), "thigh.R": (34.0, 0.0, 0.0),
        "shin.L": (48.0, 0.0, 0.0), "shin.R": (-14.0, 0.0, 0.0),
        "foot.L": (10.0, 0.0, 0.0), "foot.R": (-8.0, 0.0, 0.0),
        "upper_arm.L": (24.0, 0.0, 0.0), "upper_arm.R": (-24.0, 0.0, 0.0),
        "forearm.L": (-10.0, 0.0, 0.0), "forearm.R": (-10.0, 0.0, 0.0),
    },
    {
        "spine_location": (0.0, 0.0, 0.025),
        "spine": (0.0, 0.0, 0.0),
        "thigh.L": (10.0, 0.0, 0.0), "thigh.R": (10.0, 0.0, 0.0),
        "shin.L": (50.0, 0.0, 0.0), "shin.R": (-12.0, 0.0, 0.0),
        "foot.L": (12.0, 0.0, 0.0), "foot.R": (-8.0, 0.0, 0.0),
        "upper_arm.L": (18.0, 0.0, 0.0), "upper_arm.R": (-18.0, 0.0, 0.0),
        "forearm.L": (-8.0, 0.0, 0.0), "forearm.R": (-8.0, 0.0, 0.0),
    },
    {
        "spine_location": (0.0, 0.0, 0.00),
        "spine": (2.0, 0.0, 0.0),
        "thigh.L": (34.0, 0.0, 0.0), "thigh.R": (-30.0, 0.0, 0.0),
        "shin.L": (-14.0, 0.0, 0.0), "shin.R": (48.0, 0.0, 0.0),
        "foot.L": (-8.0, 0.0, 0.0), "foot.R": (10.0, 0.0, 0.0),
        "upper_arm.L": (-24.0, 0.0, 0.0), "upper_arm.R": (24.0, 0.0, 0.0),
        "forearm.L": (-10.0, 0.0, 0.0), "forearm.R": (-10.0, 0.0, 0.0),
    },
    {
        "spine_location": (0.0, 0.0, 0.00),
        "spine": (2.0, 0.0, 0.0),
        "thigh.L": (34.0, 0.0, 0.0), "thigh.R": (-30.0, 0.0, 0.0),
        "shin.L": (-14.0, 0.0, 0.0), "shin.R": (48.0, 0.0, 0.0),
        "foot.L": (-8.0, 0.0, 0.0), "foot.R": (10.0, 0.0, 0.0),
        "upper_arm.L": (-24.0, 0.0, 0.0), "upper_arm.R": (24.0, 0.0, 0.0),
        "forearm.L": (-10.0, 0.0, 0.0), "forearm.R": (-10.0, 0.0, 0.0),
    },
]

for frame, pose in zip(FRAMES, poses):
    bpy.context.scene.frame_set(frame)
    reset_pose(armature)
    armature.pose.bones["spine"].location = pose["spine_location"]
    for name, values in pose.items():
        if name not in ("spine_location",):
            set_rotation(armature, name, values)
    key_all(armature, frame)

for layer in action.layers:
    for strip in layer.strips:
        for action_slot in action.slots:
            bag = strip.channelbag(slot=action_slot)
            if bag:
                for fcurve in bag.fcurves:
                    for point in fcurve.keyframe_points:
                        point.interpolation = "BEZIER"
                        point.handle_left_type = "AUTO_CLAMPED"
                        point.handle_right_type = "AUTO_CLAMPED"
                    fcurve.update()

action.frame_start = FRAMES[0]
action.frame_end = FRAMES[-1]
armature.animation_data.action = action
armature.animation_data.action_slot = slot
bpy.context.scene.frame_start = FRAMES[0]
bpy.context.scene.frame_end = FRAMES[-1]
bpy.context.scene.frame_set(FRAMES[0])
bpy.context.view_layer.update()
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_FILE)
print("SAVED", OUTPUT_FILE)
print("ACTION", action.name, "SLOT", slot.identifier, "FRAMES", action.frame_range)
