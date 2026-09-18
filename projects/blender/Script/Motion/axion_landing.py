import bpy
import math

ARMATURE_NAME = "axion_metarig"
ACTION_NAME = "axion_Landing"
FRAMES = (1, 7, 13, 19, 25, 31)


def action_slot_for(action, armature):
    identifier = f"OB{armature.name}"
    for slot in action.slots:
        if slot.target_id_type == "OBJECT" and slot.identifier == identifier:
            return slot
    return action.slots.new("OBJECT", armature.name)


def key_pose(armature, frame, pose):
    bpy.context.scene.frame_set(frame)
    for bone in armature.pose.bones:
        bone.location = (0.0, 0.0, 0.0)
        bone.rotation_mode = "XYZ"
        bone.rotation_euler = (0.0, 0.0, 0.0)
        bone.scale = (1.0, 1.0, 1.0)
    for name, rotation in pose.get("rotations", {}).items():
        bone = armature.pose.bones.get(name)
        if bone:
            bone.rotation_euler = tuple(math.radians(value) for value in rotation)
    root = armature.pose.bones.get("spine")
    if root:
        root.location = pose.get("location", (0.0, 0.0, 0.0))
    for bone in armature.pose.bones:
        bone.keyframe_insert(data_path="location", frame=frame, group=bone.name)
        bone.keyframe_insert(data_path="rotation_euler", frame=frame, group=bone.name)
        bone.keyframe_insert(data_path="scale", frame=frame, group=bone.name)


armature = bpy.data.objects.get(ARMATURE_NAME)
if armature is None or armature.type != "ARMATURE":
    raise RuntimeError(f"Armature not found: {ARMATURE_NAME}")
action = bpy.data.actions.get(ACTION_NAME) or bpy.data.actions.new(ACTION_NAME)
slot = action_slot_for(action, armature)
armature.animation_data_create()
armature.animation_data.action = action
armature.animation_data.action_slot = slot

poses = [
    {"location": (0.0, 0.0, 0.0), "rotations": {"thigh.L": (20, 0, 0), "thigh.R": (-20, 0, 0), "shin.L": (20, 0, 0), "shin.R": (20, 0, 0), "upper_arm.L": (-10, 0, 0), "upper_arm.R": (10, 0, 0)}},
    {"location": (0.0, 0.0, -0.2), "rotations": {"thigh.L": (35, 0, 0), "thigh.R": (-35, 0, 0), "shin.L": (70, 0, 0), "shin.R": (70, 0, 0), "upper_arm.L": (-18, 0, 0), "upper_arm.R": (18, 0, 0)}},
    {"location": (0.0, 0.0, -0.45), "rotations": {"thigh.L": (48, 0, 0), "thigh.R": (-48, 0, 0), "shin.L": (92, 0, 0), "shin.R": (92, 0, 0), "upper_arm.L": (-25, 0, 0), "upper_arm.R": (25, 0, 0)}},
    {"location": (0.0, 0.0, -0.25), "rotations": {"thigh.L": (32, 0, 0), "thigh.R": (-32, 0, 0), "shin.L": (64, 0, 0), "shin.R": (64, 0, 0), "upper_arm.L": (-15, 0, 0), "upper_arm.R": (15, 0, 0)}},
    {"location": (0.0, 0.0, -0.08), "rotations": {"thigh.L": (24, 0, 0), "thigh.R": (-24, 0, 0), "shin.L": (38, 0, 0), "shin.R": (38, 0, 0), "upper_arm.L": (-12, 0, 0), "upper_arm.R": (12, 0, 0)}},
    {"location": (0.0, 0.0, 0.0), "rotations": {"thigh.L": (20, 0, 0), "thigh.R": (-20, 0, 0), "shin.L": (20, 0, 0), "shin.R": (20, 0, 0), "upper_arm.L": (-10, 0, 0), "upper_arm.R": (10, 0, 0)}},
]
for frame, pose in zip(FRAMES, poses):
    key_pose(armature, frame, pose)

action.frame_start = FRAMES[0]
action.frame_end = FRAMES[-1]
bpy.context.scene.frame_start = FRAMES[0]
bpy.context.scene.frame_end = FRAMES[-1]
bpy.context.scene.frame_set(FRAMES[0])
bpy.context.view_layer.update()
print(f"Created {ACTION_NAME}: {slot.identifier}, frames {FRAMES[0]}-{FRAMES[-1]}")
