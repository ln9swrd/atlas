import bpy
import math
from mathutils import Vector, Euler

# POSE_01: CONTACT L
# Assumptions for 2D -> 3D conversion:
# - Z represents Up/Down (World) or relative to Root. 
# - Y represents Forward/Backward.
# - X represents Left/Right.
# - Values are approximate based on 2D visual analysis of "CONTACT L" pose.
# - Leg length is approx 600 units (based on foot_ik default Z=-627).
# - Left leg is forward (Contact), Right leg is backward.
# - Left arm is backward, Right arm is forward.

POSE_01 = {
    # root stays roughly at origin, maybe dips slightly
    "root": {
        "location": (0.0, 0.0, -20.0),
        "rotation_euler": (0.0, 0.0, 0.0)
    },
    "spine": {
        "rotation_euler": (math.radians(5), 0.0, 0.0) # slight forward tilt
    },
    "foot_ik.L": {
        # Left foot forward, Y is positive forward? In blender Y is usually back or forward. Let's assume -Y is forward for standard characters.
        # Actually in inspection, thigh.L head was Y=-72, tail Y=-521. So -Y is DOWN?
        # Let's check thigh head: [86, -72, 22]. tail: [86, -521, 176]. Wait, Z goes UP. Y is Forward/Backward.
        # Let's use relative offsets from default pose.
        # Since foot_ik is parented to root, its pose location is relative to its REST position.
        # In Pose mode, location = (0,0,0) means it stays at its Edit Mode position.
        "location": (0.0, -300.0, 50.0), # Forward 300 units, slightly up for heel strike
        "rotation_euler": (math.radians(-20), 0.0, 0.0) # Pitch up (heel down, toe up)
    },
    "knee_pole.L": {
        "location": (0.0, -350.0, 0.0) # Move pole forward to keep knee straight
    },
    "foot_ik.R": {
        "location": (0.0, 300.0, 80.0), # Backward 300 units, up 80 units (push off)
        "rotation_euler": (math.radians(30), 0.0, 0.0) # Pitch down (toe touching)
    },
    "knee_pole.R": {
        "location": (0.0, 200.0, 0.0)
    },
    "hand_ik.L": {
        # Left arm swings BACK (opposite to left leg)
        "location": (0.0, 200.0, 0.0)
    },
    "elbow_pole.L": {
        "location": (0.0, 250.0, 0.0)
    },
    "hand_ik.R": {
        # Right arm swings FORWARD
        "location": (0.0, -250.0, 100.0) # Forward and slightly up
    },
    "elbow_pole.R": {
        "location": (0.0, -300.0, 50.0)
    }
}

def apply_pose(pose_data):
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

    # Ensure IK properties are set to 1.0 (IK enabled)
    root_bone = arm_obj.pose.bones.get("root")
    if root_bone:
        for prop in ['ik_arm_L', 'ik_arm_R', 'ik_leg_L', 'ik_leg_R']:
            if prop in root_bone:
                root_bone[prop] = 1.0

    for bone_name, transform in pose_data.items():
        pb = arm_obj.pose.bones.get(bone_name)
        if not pb:
            print(f"Bone {bone_name} not found in pose.")
            continue
        
        # Set location
        if "location" in transform:
            # The pose location is an offset from the rest pose
            pb.location = transform["location"]
            
        # Set rotation (converting euler to quaternion if needed)
        if "rotation_euler" in transform:
            if pb.rotation_mode == 'QUATERNION':
                eul = Euler(transform["rotation_euler"], 'XYZ')
                pb.rotation_quaternion = eul.to_quaternion()
            else:
                pb.rotation_euler = transform["rotation_euler"]
                
    # Update scene
    bpy.context.view_layer.update()
    
    # Save the file to verify visually if needed
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("Pose applied and saved successfully.")
    return True

if __name__ == "__main__":
    success = apply_pose(POSE_01)
    if success:
        print("CALIBRATION POC: SUCCESS")
    else:
        print("CALIBRATION POC: FAILED")
