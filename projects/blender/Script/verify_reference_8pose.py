import bpy

rig = bpy.data.objects["RIG-Axion_Rigify_Metarig"]
action = rig.animation_data.action if rig.animation_data else None
print("ACTION:", action.name if action else None)
print("FRAME_RANGE:", bpy.context.scene.frame_start, bpy.context.scene.frame_end)
for frame in (0, 6, 12, 18, 24, 30, 36, 42, 48):
    bpy.context.scene.frame_set(frame)
    left = rig.pose.bones["foot_ik.L"].location.copy()
    right = rig.pose.bones["foot_ik.R"].location.copy()
    root = rig.pose.bones["root"].location.copy()
    print(f"FRAME {frame}: L={tuple(round(v, 3) for v in left)} R={tuple(round(v, 3) for v in right)} ROOT={tuple(round(v, 3) for v in root)}")
