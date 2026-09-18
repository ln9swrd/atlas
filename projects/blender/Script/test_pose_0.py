import bpy
import math
from mathutils import Vector, Euler

def reset_and_apply_pose_0():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        print("metarig not found!")
        return False
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    
    # 1. Clear all existing animation data from the armature
    if arm.animation_data:
        arm.animation_data_clear()
        
    # 2. Reset all bones to Rest Pose
    bpy.ops.pose.select_all(action='SELECT')
    bpy.ops.pose.loc_clear()
    bpy.ops.pose.rot_clear()
    bpy.ops.pose.scale_clear()
    bpy.ops.pose.select_all(action='DESELECT')
    
    # Enable IK constraints
    root_bone = arm.pose.bones.get("root")
    if root_bone:
        for prop in ['ik_arm_L', 'ik_arm_R', 'ik_leg_L', 'ik_leg_R']:
            if prop in root_bone:
                root_bone[prop] = 1.0
                
    # 3. Define CONTACT L (Frame 0) based on new leg proportions (Leg Length ~ 1100)
    # Stride length = 900 (Y offset +/- 450)
    # Pelvis drop = 90 (to prevent IK knee popping/locking)
    pose_0 = {
        # Root drops to allow the long legs to reach the stride
        "root": {"location": (0.0, 0.0, -90.0), "rotation_euler": (0.0, 0.0, 0.0)},
        
        # Spine leans forward (-X) and twists towards the forward leg (+Y)
        "spine": {"rotation_euler": (math.radians(-5.0), math.radians(5.0), 0.0)},
        
        # LEFT LEG (Forward)
        # Local +Y is Forward. Local +X is Pitch Up.
        "foot_ik.L": {"location": (0.0, 450.0, 50.0), "rotation_euler": (math.radians(20.0), 0.0, 0.0)},
        # Knee pole must stay in front of the forward knee
        "knee_pole.L": {"location": (0.0, 600.0, 0.0)},
        
        # RIGHT LEG (Backward)
        # Local -Y is Backward. Local -X is Pitch Down.
        "foot_ik.R": {"location": (0.0, -450.0, 100.0), "rotation_euler": (math.radians(-30.0), 0.0, 0.0)},
        # Knee pole stays slightly behind relative to rest pose, but in front of the bent knee
        "knee_pole.R": {"location": (0.0, -200.0, 0.0)},
        
        # LEFT ARM (Backward, opposite to left leg)
        # Local -Y is Backward
        "hand_ik.L": {"location": (0.0, -300.0, 0.0)},
        
        # RIGHT ARM (Forward, opposite to right leg)
        # Local +Y is Forward
        "hand_ik.R": {"location": (0.0, 300.0, 50.0)},
    }
    
    # 4. Apply Pose
    for bone_name, transform in pose_0.items():
        pb = arm.pose.bones.get(bone_name)
        if not pb: continue
        
        if "location" in transform:
            pb.location = transform["location"]
        if "rotation_euler" in transform:
            # All IK controls should be in Euler for easier visual tweaking
            pb.rotation_mode = 'XYZ'
            pb.rotation_euler = transform["rotation_euler"]
            
    bpy.context.view_layer.update()
    
    # Save to file
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("POSE 0 APPLIED SUCCESSFULLY")
    return True

if __name__ == "__main__":
    reset_and_apply_pose_0()
