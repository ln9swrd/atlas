"""
Walk Animation for RIG-Axion_Rigify_Metarig - Blender UI Version
Run this in Blender's Python Console (Shift+F4)
"""

import bpy
import math

print("\n" + "="*60)
print("WALK ANIMATION CREATOR - UI VERSION")
print("="*60)

# Select rig
rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
if not rig:
    print("[!] RIG-Axion_Rigify_Metarig not found")
else:
    print(f"\n✅ Found: {rig.name}")
    
    # Set active
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    
    # Enter pose mode
    bpy.ops.object.mode_set(mode='POSE')
    print("✓ Entered Pose Mode")
    
    # Create action
    action_name = "Walk_Cycle_Rigify"
    if action_name in bpy.data.actions:
        bpy.data.actions.remove(bpy.data.actions[action_name], do_unlink=True)
    
    action = bpy.data.actions.new(action_name)
    rig.animation_data_create()
    rig.animation_data.action = action
    print(f"✓ Created action: {action.name}")
    
    # Get bones
    root = rig.pose.bones.get("root")
    foot_ik_l = rig.pose.bones.get("foot_ik.L")
    foot_ik_r = rig.pose.bones.get("foot_ik.R")
    chest = rig.pose.bones.get("chest")
    
    if not (root and foot_ik_l and foot_ik_r):
        print("[!] Required bones not found")
    else:
        print("✓ Found all bones")
        
        # Frame 0
        bpy.context.scene.frame_set(0)
        root.location.y = -2.0
        root.keyframe_insert("location")
        foot_ik_r.location = (0.0, 1.5, 0.0)
        foot_ik_r.keyframe_insert("location")
        foot_ik_l.location = (0.0, -1.5, 0.0)
        foot_ik_l.keyframe_insert("location")
        if chest:
            chest.rotation_euler.x = math.radians(5)
            chest.keyframe_insert("rotation_euler")
        print("  ✓ Frame 0")
        
        # Frame 12
        bpy.context.scene.frame_set(12)
        root.location.y = -1.0
        root.keyframe_insert("location")
        foot_ik_r.location = (0.0, 0.0, 0.0)
        foot_ik_r.keyframe_insert("location")
        foot_ik_l.location = (0.0, -2.0, 0.0)
        foot_ik_l.keyframe_insert("location")
        if chest:
            chest.rotation_euler.x = 0.0
            chest.keyframe_insert("rotation_euler")
        print("  ✓ Frame 12")
        
        # Frame 24
        bpy.context.scene.frame_set(24)
        root.location.y = 0.0
        root.keyframe_insert("location")
        foot_ik_l.location = (0.0, 1.5, 0.0)
        foot_ik_l.keyframe_insert("location")
        foot_ik_r.location = (0.0, -1.5, 0.0)
        foot_ik_r.keyframe_insert("location")
        if chest:
            chest.rotation_euler.x = math.radians(-5)
            chest.keyframe_insert("rotation_euler")
        print("  ✓ Frame 24")
        
        # Frame 36
        bpy.context.scene.frame_set(36)
        root.location.y = 1.0
        root.keyframe_insert("location")
        foot_ik_l.location = (0.0, 0.0, 0.0)
        foot_ik_l.keyframe_insert("location")
        foot_ik_r.location = (0.0, -2.0, 0.0)
        foot_ik_r.keyframe_insert("location")
        if chest:
            chest.rotation_euler.x = 0.0
            chest.keyframe_insert("rotation_euler")
        print("  ✓ Frame 36")
        
        # Frame 48
        bpy.context.scene.frame_set(48)
        root.location.y = -2.0
        root.keyframe_insert("location")
        foot_ik_r.location = (0.0, 1.5, 0.0)
        foot_ik_r.keyframe_insert("location")
        foot_ik_l.location = (0.0, -1.5, 0.0)
        foot_ik_l.keyframe_insert("location")
        if chest:
            chest.rotation_euler.x = math.radians(5)
            chest.keyframe_insert("rotation_euler")
        print("  ✓ Frame 48")
        
        # Set frame range
        bpy.context.scene.frame_start = 0
        bpy.context.scene.frame_end = 47
        
        # Return to object mode
        bpy.ops.object.mode_set(mode='OBJECT')
        
        print(f"\n✅ SUCCESS!")
        print(f"   Animation created: {action.name}")
        print(f"   Now save file and press SPACEBAR to play")

print("\n" + "="*60 + "\n")
