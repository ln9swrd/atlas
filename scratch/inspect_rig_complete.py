import bpy
import math
import sys

print("\n=== COMPLETE RIG DIAGNOSTIC REPORT ===")

def check_transforms():
    print("\n[1] ARMATURE TRANSFORMS CHECK")
    for obj in bpy.data.objects:
        if obj.type == 'ARMATURE':
            loc = obj.location[:]
            rot = obj.rotation_euler[:]
            scl = obj.scale[:]
            if any(abs(v) > 0.001 for v in loc) or any(abs(v) > 0.001 for v in rot) or any(abs(v - 1.0) > 0.001 for v in scl):
                print(f"  [!] {obj.name} has UNAPPLIED transforms!")
                print(f"      Loc: {loc}, Rot: {rot}, Scl: {scl}")
            else:
                print(f"  [OK] {obj.name} transforms are clean (0,0,0 and 1,1,1).")

def check_constraints_and_ik():
    print("\n[2] CONSTRAINTS AND IK CHECK")
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        print("  SuperRobotRig not found!")
        return

    missing_count = 0
    for pb in rig.pose.bones:
        for c in pb.constraints:
            if hasattr(c, 'target') and c.target is None:
                if c.type not in ['LIMIT_LOCATION', 'LIMIT_ROTATION', 'LIMIT_SCALE']:
                    print(f"  [!] Bone '{pb.name}' has constraint '{c.name}' with MISSING TARGET.")
                    missing_count += 1
            elif hasattr(c, 'subtarget') and c.target is not None:
                if c.subtarget and c.subtarget not in c.target.pose.bones:
                    print(f"  [!] Bone '{pb.name}' constraint '{c.name}' has INVALID SUBTARGET: {c.subtarget}")
                    missing_count += 1

            if c.type == 'IK':
                print(f"  [IK] '{pb.name}': Target={c.target.name if c.target else 'None'}/{c.subtarget}, Pole={c.pole_target.name if c.pole_target else 'None'}/{c.pole_subtarget}, Angle={math.degrees(c.pole_angle):.1f}deg, Chain={c.chain_count}")
    if missing_count == 0:
        print("  [OK] No missing targets found.")

def check_bone_twist():
    print("\n[3] BONE TWIST (POSE VS REST) CHECK")
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig: return
    
    # Clear transforms
    for pb in rig.pose.bones:
        pb.location = (0, 0, 0)
        pb.rotation_quaternion = (1, 0, 0, 0)
        pb.rotation_euler = (0, 0, 0)
        pb.scale = (1, 1, 1)

    bpy.context.view_layer.update()

    twisted = []
    for pb in rig.pose.bones:
        rest_mat = pb.bone.matrix_local
        pose_mat = pb.matrix
        diff_mat = rest_mat.inverted() @ pose_mat
        rot_diff = diff_mat.to_euler()
        x, y, z = [math.degrees(v) for v in rot_diff]
        max_diff = max(abs(x), abs(y), abs(z))
        if max_diff > 1.0:
            twisted.append({'name': pb.name, 'diff': (x,y,z), 'max': max_diff})

    twisted.sort(key=lambda x: x['max'], reverse=True)
    if twisted:
        print("  [!] Bones severely deviating from rest pose without user input:")
        for t in twisted[:10]:
            print(f"      - {t['name']}: {t['diff'][0]:.1f}, {t['diff'][1]:.1f}, {t['diff'][2]:.1f} deg")
    else:
        print("  [OK] No significant twist detected. Rest pose matches Pose mode.")

def check_rest_positions():
    print("\n[4] REST POSITION ALIGNMENT CHECK")
    rig = bpy.data.objects.get("SuperRobotRig")
    ctrl = bpy.data.objects.get("Excelion_IK_CTRL")
    if not rig or not ctrl:
        print("  Missing rig or ctrl rig.")
        return
    
    pairs = [
        ("forearm.L", "CTRL_Hand_IK.L", "tail", "head"),
        ("forearm.R", "CTRL_Hand_IK.R", "tail", "head"),
    ]
    for r_bname, c_bname, r_part, c_part in pairs:
        r_bone = rig.data.bones.get(r_bname)
        c_bone = ctrl.data.bones.get(c_bname)
        if r_bone and c_bone:
            r_pos = r_bone.tail_local if r_part == "tail" else r_bone.head_local
            c_pos = c_bone.tail_local if c_part == "tail" else c_bone.head_local
            dist = (r_pos - c_pos).length
            print(f"  Distance {r_bname}({r_part}) to {c_bname}({c_part}): {dist:.3f}")
            if dist > 1.0:
                print(f"      [!] Position mismatch! Rig: {r_pos[:]}, Ctrl: {c_pos[:]}")
            else:
                print("      [OK] Aligned.")

try:
    check_transforms()
    check_constraints_and_ik()
    check_rest_positions()
    check_bone_twist()
except Exception as e:
    print(f"ERROR: {e}")

print("=======================================\n")
sys.exit(0)
