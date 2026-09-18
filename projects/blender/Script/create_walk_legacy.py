"""
Walk Animation Creator - Using Legacy Action System (Blender 5.2)
"""

import bpy
import math

print("\n" + "="*70)
print("WALK ANIMATION - LEGACY ACTION SYSTEM")
print("="*70)

rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
if not rig:
    print("[!] RIG not found")
    exit(1)

print(f"✅ Found rig: {rig.name}")

# Try using legacy action
bpy.context.view_layer.objects.active = rig
rig.select_set(True)
bpy.ops.object.mode_set(mode='POSE')

print("\n[CHECKING ACTION SYSTEM]")

# Remove old
if "Walk_Cycle_Rigify" in bpy.data.actions:
    old_action = bpy.data.actions["Walk_Cycle_Rigify"]
    print(f"Old action: is_layered={old_action.is_action_layered}, is_legacy={old_action.is_action_legacy}")
    bpy.data.actions.remove(old_action, do_unlink=True)

# Create new
action = bpy.data.actions.new("Walk_Cycle_Rigify")
print(f"New action created: is_layered={action.is_action_layered}, is_legacy={action.is_action_legacy}")

# Check if we can access fcurves
if hasattr(action, 'fcurves'):
    print("✅ action.fcurves is available")
else:
    print("⚠️  action.fcurves NOT available")
    
    # Try to enable legacy mode if possible
    if hasattr(action, 'is_action_legacy'):
        try:
            print("Attempting to switch to legacy action...")
            # Some versions allow setting this
        except:
            pass

# Assign to rig
rig.animation_data_create()
rig.animation_data.action = action

# Get bones
root = rig.pose.bones.get("root")
foot_ik_l = rig.pose.bones.get("foot_ik.L")
foot_ik_r = rig.pose.bones.get("foot_ik.R")
chest = rig.pose.bones.get("chest")

if not all([root, foot_ik_l, foot_ik_r]):
    print("[!] Required bones missing!")
    exit(1)

print(f"✓ All bones found")

# Try inserting keyframes
print("\n[ATTEMPTING KEYFRAME INSERTION]")

keyframe_data = [
    (0, -2.0, 1.5, -1.5, 5),
    (12, -1.0, 0.0, -2.0, 0),
    (24, 0.0, -1.5, 1.5, -5),
    (36, 1.0, -2.0, 0.0, 0),
    (48, -2.0, 1.5, -1.5, 5),
]

success_count = 0
for frame, r_y, r_ikr, l_iky, chest_x in keyframe_data:
    try:
        bpy.context.scene.frame_set(frame)
        
        # Try keyframe_insert
        root.location.y = r_y
        root.keyframe_insert("location", frame=frame)
        
        foot_ik_r.location = (0.0, r_ikr, 0.0)
        foot_ik_r.keyframe_insert("location", frame=frame)
        
        foot_ik_l.location = (0.0, l_iky, 0.0)
        foot_ik_l.keyframe_insert("location", frame=frame)
        
        if chest:
            chest.rotation_euler.x = math.radians(chest_x)
            chest.keyframe_insert("rotation_euler", frame=frame)
        
        print(f"  ✓ Frame {frame}: OK")
        success_count += 1
        
    except Exception as e:
        print(f"  ✗ Frame {frame}: {e}")

print(f"\n✅ Keyframes inserted: {success_count}/{len(keyframe_data)}")

# Set frame range
bpy.context.scene.frame_start = 0
bpy.context.scene.frame_end = 47

# Object mode
bpy.ops.object.mode_set(mode='OBJECT')

# Save
filepath = bpy.data.filepath
bpy.ops.wm.save_mainfile(filepath=filepath, compress=False)
print(f"✓ File saved: {filepath}")

print("\n" + "="*70)
print("✅ PROCESS COMPLETE")
print("="*70 + "\n")
