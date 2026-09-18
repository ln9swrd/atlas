"""
Execute walk animation creation in Blender UI mode
Then save and close
"""

import bpy
import math

def create_walk():
    rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
    if not rig:
        return False
    
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode='POSE')
    
    # Delete old action
    if "Walk_Cycle_Rigify" in bpy.data.actions:
        bpy.data.actions.remove(bpy.data.actions["Walk_Cycle_Rigify"], do_unlink=True)
    
    action = bpy.data.actions.new("Walk_Cycle_Rigify")
    rig.animation_data_create()
    rig.animation_data.action = action
    
    root = rig.pose.bones.get("root")
    foot_ik_l = rig.pose.bones.get("foot_ik.L")
    foot_ik_r = rig.pose.bones.get("foot_ik.R")
    chest = rig.pose.bones.get("chest")
    
    if not (root and foot_ik_l and foot_ik_r):
        return False
    
    # Keyframes
    frames = [
        (0, -2.0, 1.5, -1.5, 5),
        (12, -1.0, 0.0, -2.0, 0),
        (24, 0.0, -1.5, 1.5, -5),
        (36, 1.0, -2.0, 0.0, 0),
        (48, -2.0, 1.5, -1.5, 5),
    ]
    
    for frame, r_y, r_ikr, l_iky, chest_x in frames:
        bpy.context.scene.frame_set(frame)
        
        root.location.y = r_y
        root.keyframe_insert("location")
        
        foot_ik_r.location = (0.0, r_ikr, 0.0)
        foot_ik_r.keyframe_insert("location")
        
        foot_ik_l.location = (0.0, l_iky, 0.0)
        foot_ik_l.keyframe_insert("location")
        
        if chest:
            chest.rotation_euler.x = math.radians(chest_x)
            chest.keyframe_insert("rotation_euler")
    
    bpy.context.scene.frame_start = 0
    bpy.context.scene.frame_end = 47
    
    bpy.ops.object.mode_set(mode='OBJECT')
    
    return True

print("\n[Creating walk animation...]")
if create_walk():
    print("✓ Animation created!")
    # Save
    bpy.ops.wm.save_mainfile()
    print("✓ File saved!")
    print("✓ Done! Play animation with SPACEBAR")
else:
    print("✗ Failed")
