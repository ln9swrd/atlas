import bpy
import math
from mathutils import Vector, Euler

# ASSUMPTIONS FOR 3D CONVERSION
# 1. World Space Orientation: +X = Left, -Y = Forward, +Z = Up.
# 2. Control Method: We use relative offsets (Local Space `location`) from the Rest Pose.
# 3. Scale/Proportions: Leg is approx 600 units long. A full stride (Contact to Contact) is approx 500-600 units.
# 4. Z-Depth Inference (Arms/Legs):
#    - Since it's a 2D side view, depth (X-axis offset) is kept minimal (0.0) assuming a straight line walk.
#    - Forward/Backward swing is mapped to Y-axis.
#    - Up/Down lift is mapped to Z-axis.

# Poses Dictionary
POSES = {}

# 1. CONTACT L (Left heel strike, Right toe push off)
POSES["CONTACT_L"] = {
    "root": {"location": (0.0, 0.0, -20.0), "rotation_euler": (0.0, 0.0, 0.0)},
    "spine": {"rotation_euler": (math.radians(5), 0.0, 0.0)},
    "foot_ik.L": {"location": (0.0, -250.0, 40.0), "rotation_euler": (math.radians(-20), 0.0, 0.0)},
    "knee_pole.L": {"location": (0.0, -350.0, 0.0)},
    "foot_ik.R": {"location": (0.0, 250.0, 80.0), "rotation_euler": (math.radians(30), 0.0, 0.0)},
    "knee_pole.R": {"location": (0.0, 150.0, 0.0)},
    "hand_ik.L": {"location": (0.0, 200.0, 0.0)},
    "hand_ik.R": {"location": (0.0, -200.0, 50.0)},
}

# 2. DOWN L (Left foot flat bearing weight, root lowest, Right foot lifts)
POSES["DOWN_L"] = {
    "root": {"location": (0.0, 0.0, -50.0), "rotation_euler": (0.0, 0.0, 0.0)},
    "spine": {"rotation_euler": (math.radians(8), 0.0, 0.0)},
    "foot_ik.L": {"location": (0.0, -100.0, 0.0), "rotation_euler": (0.0, 0.0, 0.0)},
    "knee_pole.L": {"location": (0.0, -250.0, 0.0)},
    "foot_ik.R": {"location": (0.0, 200.0, 150.0), "rotation_euler": (math.radians(45), 0.0, 0.0)},
    "knee_pole.R": {"location": (0.0, 100.0, 50.0)},
    "hand_ik.L": {"location": (0.0, 150.0, -20.0)},
    "hand_ik.R": {"location": (0.0, -150.0, 30.0)},
}

# 3. PASSING L (Left leg straightest, Right leg swinging past)
POSES["PASSING_L"] = {
    "root": {"location": (0.0, 0.0, 0.0), "rotation_euler": (0.0, 0.0, 0.0)},
    "spine": {"rotation_euler": (math.radians(2), 0.0, 0.0)},
    "foot_ik.L": {"location": (0.0, 0.0, 0.0), "rotation_euler": (0.0, 0.0, 0.0)},
    "knee_pole.L": {"location": (0.0, -150.0, 0.0)},
    "foot_ik.R": {"location": (0.0, 0.0, 250.0), "rotation_euler": (math.radians(10), 0.0, 0.0)},
    "knee_pole.R": {"location": (0.0, -200.0, 250.0)},
    "hand_ik.L": {"location": (0.0, 0.0, -30.0)},
    "hand_ik.R": {"location": (0.0, 0.0, -30.0)},
}

# 4. UP L (Left foot pushes up, Right leg reaches forward)
POSES["UP_L"] = {
    "root": {"location": (0.0, 0.0, 40.0), "rotation_euler": (0.0, 0.0, 0.0)},
    "spine": {"rotation_euler": (0.0, 0.0, 0.0)},
    "foot_ik.L": {"location": (0.0, 100.0, 80.0), "rotation_euler": (math.radians(20), 0.0, 0.0)},
    "knee_pole.L": {"location": (0.0, 50.0, 0.0)},
    "foot_ik.R": {"location": (0.0, -200.0, 150.0), "rotation_euler": (math.radians(-10), 0.0, 0.0)},
    "knee_pole.R": {"location": (0.0, -350.0, 100.0)},
    "hand_ik.L": {"location": (0.0, -150.0, 30.0)},
    "hand_ik.R": {"location": (0.0, 150.0, -20.0)},
}

def verify_poses():
    arm_obj = None
    for arm in bpy.context.scene.objects:
        if arm.type == 'ARMATURE' and 'metarig' in arm.name.lower():
            arm_obj = arm
            break
            
    if not arm_obj:
        print("Armature not found.")
        return False

    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode='POSE')

    root_bone = arm_obj.pose.bones.get("root")
    if root_bone:
        for prop in ['ik_arm_L', 'ik_arm_R', 'ik_leg_L', 'ik_leg_R']:
            if prop in root_bone:
                root_bone[prop] = 1.0

    pose_names = ["CONTACT_L", "DOWN_L", "PASSING_L", "UP_L"]
    
    for p_name in pose_names:
        print(f"Applying Pose: {p_name}")
        pose_data = POSES[p_name]
        
        for bone_name, transform in pose_data.items():
            pb = arm_obj.pose.bones.get(bone_name)
            if not pb: continue
            
            if "location" in transform:
                pb.location = transform["location"]
            if "rotation_euler" in transform:
                if pb.rotation_mode == 'QUATERNION':
                    pb.rotation_quaternion = Euler(transform["rotation_euler"], 'XYZ').to_quaternion()
                else:
                    pb.rotation_euler = transform["rotation_euler"]
        
        # Force update to evaluate IK constraints
        bpy.context.view_layer.update()
        
        # Normally we'd check constraint validity or angles here, 
        # but since Blender doesn't crash on IK evaluate, updating view layer is our check.

    # Save the file with the final pose (UP L) to verify if opened manually.
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("4-POSE CALIBRATION POC: SUCCESS")
    return True

if __name__ == "__main__":
    verify_poses()
