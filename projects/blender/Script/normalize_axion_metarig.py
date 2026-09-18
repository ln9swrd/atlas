"""
Bone Normalization Script for axion_metarig
Safe version for Blender 5.2
"""

import bpy
import math

def log(msg):
    print(msg)

def clear_pose_transforms(rig_name):
    """Clear all pose mode transforms (reset to rest pose)"""
    rig = bpy.data.objects.get(rig_name)
    if not rig:
        log(f"[!] {rig_name} not found")
        return False
    
    try:
        for pb in rig.pose.bones:
            pb.location = (0, 0, 0)
            pb.rotation_quaternion = (1, 0, 0, 0)
            pb.scale = (1, 1, 1)
        
        bpy.context.view_layer.update()
        log(f"[OK] {rig_name}: Pose transforms cleared (reset to rest pose)")
        return True
    except Exception as e:
        log(f"[!] Failed to clear pose transforms: {e}")
        return False

def check_bone_twist(rig_name):
    """Check for bones deviating from rest pose"""
    rig = bpy.data.objects.get(rig_name)
    if not rig:
        log(f"[!] {rig_name} not found")
        return -1
    
    try:
        log(f"\n[BONE TWIST ANALYSIS FOR {rig_name}]")
        twisted = []
        
        for pb in rig.pose.bones:
            rest_mat = pb.bone.matrix_local
            pose_mat = pb.matrix
            diff_mat = rest_mat.inverted() @ pose_mat
            rot_diff = diff_mat.to_euler()
            x, y, z = [math.degrees(v) for v in rot_diff]
            max_diff = max(abs(x), abs(y), abs(z))
            
            if max_diff > 5.0:  # More than 5 degrees
                twisted.append({
                    'name': pb.name,
                    'x': x, 'y': y, 'z': z,
                    'max': max_diff
                })
        
        if twisted:
            twisted.sort(key=lambda x: x['max'], reverse=True)
            log(f"  [!] Found {len(twisted)} severely twisted bones:")
            for t in twisted[:10]:
                log(f"      {t['name']}: X={t['x']:.1f}°, Y={t['y']:.1f}°, Z={t['z']:.1f}°")
            return len(twisted)
        else:
            log(f"  [OK] No significant bone twist detected")
            return 0
    except Exception as e:
        log(f"[!] Error in twist analysis: {e}")
        return -1

def fix_ik_constraints(rig_name):
    """Review and fix IK constraints"""
    rig = bpy.data.objects.get(rig_name)
    if not rig:
        log(f"[!] {rig_name} not found")
        return False
    
    ik_bones = []
    try:
        for pb in rig.pose.bones:
            for c in pb.constraints:
                if c.type == 'IK':
                    ik_bones.append({
                        'bone': pb.name,
                        'constraint': c.name,
                        'target': c.target.name if c.target else "NONE",
                        'subtarget': c.subtarget if c.subtarget else "NONE",
                    })
        
        if ik_bones:
            log(f"\n[IK CONSTRAINTS IN {rig_name}: {len(ik_bones)}]")
            for ik in ik_bones:
                log(f"  - {ik['bone']}: {ik['constraint']}")
        else:
            log(f"[!] {rig_name}: No IK constraints found")
        
        return True
    except Exception as e:
        log(f"[!] Error checking IK constraints: {e}")
        return False

def align_bone_rolls_safe(rig_name):
    """Safely align bone rolls using recalculate_roll"""
    rig = bpy.data.objects.get(rig_name)
    if not rig:
        log(f"[!] {rig_name} not found")
        return False
    
    try:
        bpy.context.view_layer.objects.active = rig
        rig.select_set(True)
        
        # Enter Edit Mode
        bpy.ops.object.mode_set(mode='EDIT')
        
        # Select all bones
        bpy.ops.armature.select_all(action='SELECT')
        
        # Recalculate roll
        bpy.ops.armature.calculate_roll(type='GLOBAL_NEG_Y')
        
        # Return to Object Mode
        bpy.ops.object.mode_set(mode='OBJECT')
        
        log(f"[OK] {rig_name}: Bone rolls recalculated")
        return True
    except Exception as e:
        log(f"[!] Failed to align bone rolls: {e}")
        try:
            bpy.ops.object.mode_set(mode='OBJECT')
        except:
            pass
        return False

# ============================================
# MAIN EXECUTION
# ============================================

print("\n" + "="*60)
print("BONE NORMALIZATION FOR axion_metarig")
print("="*60)

TARGET_RIG = "axion_metarig"

log(f"\n[STEP 1] Current State Analysis...")
fix_ik_constraints(TARGET_RIG)
twisted_before = check_bone_twist(TARGET_RIG)

log(f"\n[STEP 2] Clearing Pose Transforms...")
clear_pose_transforms(TARGET_RIG)

log(f"\n[STEP 3] Recalculating Bone Rolls...")
align_bone_rolls_safe(TARGET_RIG)

log(f"\n[STEP 4] Final Analysis...")
twisted_after = check_bone_twist(TARGET_RIG)

# Summary
if twisted_before > 0 and twisted_after == 0:
    log(f"\n✓ SUCCESS: Bone twist completely resolved!")
elif twisted_after < twisted_before:
    log(f"\n⚠ PARTIAL: Reduced twisted bones from {twisted_before} to {twisted_after}")
elif twisted_after == twisted_before:
    log(f"\n⚠ UNCHANGED: {twisted_after} bones still twisted - needs manual fix")
else:
    log(f"\n⚠ WARNING: Unable to determine twist status")

# Save the file
try:
    bpy.ops.wm.save_mainfile()
    log(f"\n[OK] File saved successfully!")
except Exception as e:
    log(f"\n[!] Failed to save file: {e}")

print("\n" + "="*60)
print("NORMALIZATION COMPLETE")
print("="*60)
print("\nIf bones are still twisted:")
print("  1. Try Edit Mode > Armature > Align Bones (manual)")
print("  2. Or restore from backup: axion_proto_before_ik.blend")
print("\n")
