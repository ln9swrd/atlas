import bpy
import math

ARMATURE_NAME = "axion_metarig"
ACTION_NAME = "axion_Strafe Left"
FRAMES = (1, 9, 17, 25, 33)


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
    {"location": (-1.0, 0.0, 0.0), "rotations": {"thigh.L": (0, 0, 4), "thigh.R": (0, 0, 4), "upper_arm.L": (0, 0, -8), "upper_arm.R": (0, 0, 8)}},
    {"location": (-2.0, 0.0, 0.0), "rotations": {"thigh.L": (0, 0, -4), "thigh.R": (0, 0, -4), "upper_arm.L": (0, 0, 8), "upper_arm.R": (0, 0, -8)}},
    {"location": (-1.0, 0.0, 0.0), "rotations": {"thigh.L": (0, 0, 4), "thigh.R": (0, 0, 4), "upper_arm.L": (0, 0, -8), "upper_arm.R": (0, 0, 8)}},
    {"location": (0.0, 0.0, 0.0), "rotations": {"thigh.L": (0, 0, -4), "thigh.R": (0, 0, -4), "upper_arm.L": (0, 0, 8), "upper_arm.R": (0, 0, -8)}},
    {"location": (-1.0, 0.0, 0.0), "rotations": {"thigh.L": (0, 0, 4), "thigh.R": (0, 0, 4), "upper_arm.L": (0, 0, -8), "upper_arm.R": (0, 0, 8)}},
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
