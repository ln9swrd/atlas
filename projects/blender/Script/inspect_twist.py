import bpy
import mathutils
import math
import sys

print("\n--- START TWIST INSPECTION ---")

try:
    target_rig_name = "SuperRobotRig"
    if target_rig_name in bpy.data.objects:
        rig = bpy.data.objects[target_rig_name]
    else:
        print(f"Rig '{target_rig_name}' not found.")
        sys.exit(0)

    # 1. Clear all pose transforms to see if rest pose is preserved
    for pb in rig.pose.bones:
        pb.location = (0, 0, 0)
        pb.rotation_quaternion = (1, 0, 0, 0)
        pb.rotation_euler = (0, 0, 0)
        pb.scale = (1, 1, 1)

    # Update view layer to apply constraints
    bpy.context.view_layer.update()
    
    print("\n--- BONES DEVIATING FROM REST POSE (DUE TO CONSTRAINTS/DRIVERS) ---")
    twisted_bones = []
    
    for pb in rig.pose.bones:
        # Get rest pose matrix
        rest_mat = pb.bone.matrix_local
        # Get evaluated pose matrix in armature space
        pose_mat = pb.matrix
        
        # Calculate rotation difference
        diff_mat = rest_mat.inverted() @ pose_mat
        rot_diff = diff_mat.to_euler()
        
        # Convert to degrees
        x_deg = math.degrees(rot_diff.x)
        y_deg = math.degrees(rot_diff.y)
        z_deg = math.degrees(rot_diff.z)
        
        # If rotation differs by more than 1 degree
        if abs(x_deg) > 1.0 or abs(y_deg) > 1.0 or abs(z_deg) > 1.0:
            twisted_bones.append({
                'name': pb.name,
                'diff': (x_deg, y_deg, z_deg),
                'constraints': [c.name + f"({c.type})" for c in pb.constraints]
            })

    # Sort by largest difference
    twisted_bones.sort(key=lambda b: max(abs(b['diff'][0]), abs(b['diff'][1]), abs(b['diff'][2])), reverse=True)
    
    if twisted_bones:
        for b in twisted_bones[:20]: # Show top 20
            print(f"Bone '{b['name']}':")
            print(f"  Twist (X, Y, Z deg): ({b['diff'][0]:.2f}, {b['diff'][1]:.2f}, {b['diff'][2]:.2f})")
            print(f"  Constraints: {b['constraints']}")
    else:
        print("No bones are deviating significantly from rest pose.")

    print("\n--- IK CONSTRAINTS POLE ANGLES ---")
    for pb in rig.pose.bones:
        for c in pb.constraints:
            if c.type == 'KINEMATIC':
                print(f"Bone '{pb.name}' IK:")
                print(f"  Target: {c.target.name if c.target else 'None'} / Subtarget: {c.subtarget}")
                print(f"  Pole Target: {c.pole_target.name if c.pole_target else 'None'} / Subtarget: {c.pole_subtarget}")
                print(f"  Pole Angle: {math.degrees(c.pole_angle):.2f} deg")

    print("\n--- BONE ROLL (REST POSE) ---")
    # Just list some key bones if we can guess them (legs, arms)
    # We will print the roll of bones that have 'arm' or 'leg' or 'knee' or 'elbow' in the name
    for bone in rig.data.bones:
        name_low = bone.name.lower()
        if 'arm' in name_low or 'leg' in name_low or 'knee' in name_low or 'elbow' in name_low:
            print(f"Bone '{bone.name}': Roll = {math.degrees(bone.roll):.2f} deg")

except Exception as e:
    print(f"ERROR: {e}")

print("--- END TWIST INSPECTION ---")
sys.exit(0)
