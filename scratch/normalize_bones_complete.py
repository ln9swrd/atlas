"""
Complete Bone Normalization Script for axion_proto.blend
Fixes: Bone Roll, Unapplied Transforms, IK Constraints
"""

import bpy
import sys
import math
from mathutils import Euler

def log(msg):
    print(msg)

def apply_all_transforms(obj):
    """Apply all transforms to object"""
    try:
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        return True
    except Exception as e:
        log(f"  [!] Failed to apply transforms to {obj.name}: {e}")
        return False

def align_bone_rolls():
    """Align bone rolls in Edit Mode"""
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        log("[!] SuperRobotRig not found")
        return False
    
    try:
        bpy.context.view_layer.objects.active = rig
        rig.select_set(True)
        bpy.ops.object.mode_set(mode='EDIT')
        
        # Select all bones
        for eb in rig.data.edit_bones:
            eb.select = True
        
        # Align bones
        bpy.ops.armature.align()
        
        bpy.ops.object.mode_set(mode='OBJECT')
        log("[OK] Bone rolls aligned successfully")
        return True
    except Exception as e:
        log(f"[!] Failed to align bone rolls: {e}")
        try:
            bpy.ops.object.mode_set(mode='OBJECT')
        except:
            pass
        return False

def clear_pose_transforms():
    """Clear all pose mode transforms (reset to rest pose)"""
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        return False
    
    try:
        for pb in rig.pose.bones:
            pb.location = (0, 0, 0)
            pb.rotation_quaternion = (1, 0, 0, 0)
            pb.scale = (1, 1, 1)
        
        bpy.context.view_layer.update()
        log("[OK] Pose transforms cleared (reset to rest pose)")
        return True
    except Exception as e:
        log(f"[!] Failed to clear pose transforms: {e}")
        return False

def fix_ik_constraints():
    """Review and fix IK constraints"""
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
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
                        'pole_target': c.pole_target.name if c.pole_target else "NONE",
                        'pole_subtarget': c.pole_subtarget if c.pole_subtarget else "NONE",
                        'chain_count': c.chain_count
                    })
        
        if ik_bones:
            log(f"\n[IK CONSTRAINTS FOUND: {len(ik_bones)}]")
            for ik in ik_bones:
                log(f"  Bone: {ik['bone']}")
                log(f"    Constraint: {ik['constraint']}")
                log(f"    Target: {ik['target']}/{ik['subtarget']}")
                log(f"    Pole: {ik['pole_target']}/{ik['pole_subtarget']}")
                log(f"    Chain: {ik['chain_count']}")
        else:
            log("[!] No IK constraints found - IK may need to be re-applied")
        
        return True
    except Exception as e:
        log(f"[!] Error checking IK constraints: {e}")
        return False

def check_rigify_types():
    """Check and display rigify types"""
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        return False
    
    types_found = {}
    try:
        for pb in rig.pose.bones:
            rtype = getattr(pb, 'rigify_type', "")
            if rtype:
                if rtype not in types_found:
                    types_found[rtype] = []
                types_found[rtype].append(pb.name)
        
        if types_found:
            log("\n[RIGIFY TYPES FOUND]")
            for rtype, bones in types_found.items():
                log(f"  {rtype}: {len(bones)} bones")
                if len(bones) <= 3:
                    for b in bones:
                        log(f"    - {b}")
        else:
            log("[!] No rigify types found")
        
        return True
    except Exception as e:
        log(f"[!] Error checking rigify types: {e}")
        return False

def check_bone_twist():
    """Check for bones deviating from rest pose"""
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        return
    
    try:
        log("\n[BONE TWIST ANALYSIS]")
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
        else:
            log("  [OK] No significant bone twist detected")
    except Exception as e:
        log(f"[!] Error in twist analysis: {e}")

def check_armature_transforms():
    """Check if armature has unapplied transforms"""
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        return False
    
    try:
        loc = rig.location[:]
        rot = rig.rotation_euler[:]
        scl = rig.scale[:]
        
        log("\n[ARMATURE TRANSFORMS]")
        log(f"  Location: {loc}")
        log(f"  Rotation: {rot}")
        log(f"  Scale: {scl}")
        
        has_unapplied = (
            any(abs(v) > 0.001 for v in loc) or 
            any(abs(v) > 0.001 for v in rot) or 
            any(abs(v - 1.0) > 0.001 for v in scl)
        )
        
        if has_unapplied:
            log("  [!] UNAPPLIED TRANSFORMS DETECTED - will apply them")
            apply_all_transforms(rig)
        else:
            log("  [OK] Transforms are clean")
        
        return True
    except Exception as e:
        log(f"[!] Error checking transforms: {e}")
        return False

# ============================================
# MAIN EXECUTION
# ============================================

print("\n" + "="*60)
print("BONE NORMALIZATION SCRIPT FOR axion_proto.blend")
print("="*60)

log("\n[STEP 1] Checking Armature Transforms...")
check_armature_transforms()

log("\n[STEP 2] Analyzing Current State...")
check_rigify_types()
fix_ik_constraints()
check_bone_twist()

log("\n[STEP 3] Clearing Pose Transforms...")
clear_pose_transforms()

log("\n[STEP 4] Aligning Bone Rolls...")
align_bone_rolls()

log("\n[STEP 5] Final Analysis...")
check_bone_twist()

# Save the file
try:
    bpy.ops.wm.save_mainfile()
    log("\n[OK] File saved successfully!")
except Exception as e:
    log(f"\n[!] Failed to save file: {e}")

print("\n" + "="*60)
print("NORMALIZATION COMPLETE")
print("="*60)
print("\nNext steps:")
print("  1. Open the file in Blender to verify visually")
print("  2. If bones still appear twisted, check Bone Roll in Edit Mode")
print("  3. Consider re-generating Rigify rig if IK constraints are broken")
print("\n")

sys.exit(0)
