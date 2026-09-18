"""
Walk Animation Creator - Explicit Save Version
"""

import bpy
import math
import os

print("\n" + "="*70)
print("WALK ANIMATION CREATOR - EXPLICIT SAVE")
print("="*70)

# Get rig
rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
if not rig:
    print("[!] RIG not found")
    exit(1)

print(f"✅ Found rig: {rig.name} ({len(rig.pose.bones)} bones)")

# Make active and select
bpy.context.view_layer.objects.active = rig
rig.select_set(True)

# Pose mode
bpy.ops.object.mode_set(mode='POSE')
print("✓ Entered Pose Mode")

# Remove old action
if "Walk_Cycle_Rigify" in bpy.data.actions:
    bpy.data.actions.remove(bpy.data.actions["Walk_Cycle_Rigify"], do_unlink=True)
    print("✓ Cleared old action")

# Create new action
action = bpy.data.actions.new("Walk_Cycle_Rigify")
rig.animation_data_create()
rig.animation_data.action = action
print(f"✓ Created action: {action.name}")

# Get bones
root = rig.pose.bones.get("root")
foot_ik_l = rig.pose.bones.get("foot_ik.L")
foot_ik_r = rig.pose.bones.get("foot_ik.R")
chest = rig.pose.bones.get("chest")

if not all([root, foot_ik_l, foot_ik_r]):
    print("[!] Required bones missing!")
    print(f"   root: {root}, foot_ik.L: {foot_ik_l}, foot_ik.R: {foot_ik_r}")
    exit(1)

print(f"✓ Found all bones: root, foot_ik.L, foot_ik.R, chest={chest is not None}")

# Keyframe data: (frame, root_y, foot_ik_r_y, foot_ik_l_y, chest_x_degrees)
keyframe_data = [
    (0, -2.0, 1.5, -1.5, 5),
    (12, -1.0, 0.0, -2.0, 0),
    (24, 0.0, -1.5, 1.5, -5),
    (36, 1.0, -2.0, 0.0, 0),
    (48, -2.0, 1.5, -1.5, 5),
]

print("\n[INSERTING KEYFRAMES]")
for frame, r_y, r_ikr, l_iky, chest_x in keyframe_data:
    bpy.context.scene.frame_set(frame)
    
    # Root location Y
    root.location.y = r_y
    root.keyframe_insert("location", frame=frame)
    
    # Foot IK R location
    foot_ik_r.location = (0.0, r_ikr, 0.0)
    foot_ik_r.keyframe_insert("location", frame=frame)
    
    # Foot IK L location
    foot_ik_l.location = (0.0, l_iky, 0.0)
    foot_ik_l.keyframe_insert("location", frame=frame)
    
    # Chest rotation
    if chest:
        chest.rotation_euler.x = math.radians(chest_x)
        chest.keyframe_insert("rotation_euler", frame=frame)
    
    print(f"  ✓ Frame {frame:3d}: root_y={r_y:5.1f}, foot_ik_r_y={r_ikr:5.1f}, foot_ik_l_y={l_iky:5.1f}, chest_x={chest_x:3d}°")

# Set frame range
bpy.context.scene.frame_start = 0
bpy.context.scene.frame_end = 47
print(f"\n✓ Set frame range: 0-47")

# Switch back to object mode
bpy.ops.object.mode_set(mode='OBJECT')

# Save file
filepath = bpy.data.filepath
print(f"\n[SAVING FILE]")
print(f"  Path: {filepath}")

# Use full save
bpy.ops.wm.save_mainfile(filepath=filepath, compress=False, relative_remap=False)
print(f"  ✓ File saved!")

# Verify
action = bpy.data.actions.get("Walk_Cycle_Rigify")
if action:
    # Check for curves in Blender 5.2
    if hasattr(action, 'fcurves'):
        curve_count = len(action.fcurves)
    else:
        curve_count = 0
    print(f"\n[VERIFICATION]")
    print(f"  ✅ Action found: {action.name}")
    print(f"  ✅ File saved at: {filepath}")
    print(f"  Curves: {curve_count} (checking...)")

print("\n" + "="*70)
print("✅ COMPLETE!")
print("="*70 + "\n")
