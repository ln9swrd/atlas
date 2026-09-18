import math

def generate_script():
    script = """import bpy
import math
from mathutils import Vector, Euler

# Frame timings (8 poses + loop)
FRAMES = [1, 7, 13, 19, 25, 31, 37, 43, 49]
ACTION_NAME = "AXION_Walk_Cycle_Final"

def get_poses():
    # Base lateral tracks (from user's frame 0)
    TRACK_FOOT_L = 218.5
    TRACK_FOOT_R = -218.5
    TRACK_KNEE_L = 114.4
    TRACK_KNEE_R = -114.4
    TRACK_HEEL_L_Y = -237.4
    TRACK_HEEL_R_Y = -237.4
    
    TRACK_HAND_L = 30.0
    TRACK_HAND_R = -30.0
    TRACK_ELBOW_L = 80.0
    TRACK_ELBOW_R = -80.0

    p1 = { # 1. CONTACT L
        "root": {"location": (20.0, 15.0, -90.0), "rotation_euler": (0.0, 0.0, 0.0)}, 
        "spine": {"rotation_euler": (math.radians(-5), math.radians(5), 0.0)},
        "foot_ik.L": {"location": (TRACK_FOOT_L, 450.0, 50.0), "rotation_euler": (math.radians(20), 0.0, math.radians(-8))}, 
        "knee_pole.L": {"location": (TRACK_KNEE_L, 600.0, 0.0)}, 
        "heel.02.L": {"location": (450.0, TRACK_HEEL_L_Y, 50.0)}, 
        "foot_ik.R": {"location": (TRACK_FOOT_R, -450.0, 100.0), "rotation_euler": (math.radians(-30), 0.0, math.radians(-8))}, 
        "knee_pole.R": {"location": (TRACK_KNEE_R, -200.0, 0.0)}, 
        "heel.02.R": {"location": (450.0, TRACK_HEEL_R_Y, 100.0)},
        "hand_ik.L": {"location": (TRACK_HAND_L, -300.0, 0.0)}, 
        "elbow_pole.L": {"location": (TRACK_ELBOW_L, 200.0, 0.0)},
        "hand_ik.R": {"location": (TRACK_HAND_R, 300.0, 50.0)}, 
        "elbow_pole.R": {"location": (TRACK_ELBOW_R, -200.0, 0.0)},
    }
    
    p2 = { # 2. DOWN L
        "root": {"location": (40.0, 25.0, -130.0), "rotation_euler": (0.0, 0.0, 0.0)}, 
        "spine": {"rotation_euler": (math.radians(-8), math.radians(5), 0.0)},
        "foot_ik.L": {"location": (TRACK_FOOT_L, 200.0, 0.0), "rotation_euler": (0.0, 0.0, math.radians(-8))}, 
        "knee_pole.L": {"location": (TRACK_KNEE_L, 450.0, 0.0)},
        "heel.02.L": {"location": (200.0, TRACK_HEEL_L_Y, 0.0)},
        "foot_ik.R": {"location": (TRACK_FOOT_R, -400.0, 150.0), "rotation_euler": (math.radians(-40), 0.0, math.radians(-8))}, 
        "knee_pole.R": {"location": (TRACK_KNEE_R, -200.0, 0.0)},
        "heel.02.R": {"location": (400.0, TRACK_HEEL_R_Y, 150.0)},
        "hand_ik.L": {"location": (TRACK_HAND_L, -200.0, -30.0)},
        "elbow_pole.L": {"location": (TRACK_ELBOW_L, 100.0, 0.0)},
        "hand_ik.R": {"location": (TRACK_HAND_R, 200.0, 40.0)},
        "elbow_pole.R": {"location": (TRACK_ELBOW_R, -100.0, 0.0)},
    }
    
    p3 = { # 3. PASSING L
        "root": {"location": (20.0, 15.0, -40.0), "rotation_euler": (0.0, 0.0, 0.0)},
        "spine": {"rotation_euler": (math.radians(-2), 0.0, 0.0)},
        "foot_ik.L": {"location": (TRACK_FOOT_L, 0.0, 0.0), "rotation_euler": (0.0, 0.0, math.radians(-8))},
        "knee_pole.L": {"location": (TRACK_KNEE_L, 250.0, 0.0)},
        "heel.02.L": {"location": (0.0, TRACK_HEEL_L_Y, 0.0)},
        "foot_ik.R": {"location": (TRACK_FOOT_R, 0.0, 300.0), "rotation_euler": (math.radians(-10), 0.0, math.radians(-8))}, 
        "knee_pole.R": {"location": (TRACK_KNEE_R, 200.0, 100.0)},
        "heel.02.R": {"location": (0.0, TRACK_HEEL_R_Y, 300.0)},
        "hand_ik.L": {"location": (TRACK_HAND_L, 0.0, -40.0)}, 
        "elbow_pole.L": {"location": (TRACK_ELBOW_L, 0.0, 0.0)},
        "hand_ik.R": {"location": (TRACK_HAND_R, 0.0, -40.0)},
        "elbow_pole.R": {"location": (TRACK_ELBOW_R, 0.0, 0.0)},
    }
    
    p4 = { # 4. UP L
        "root": {"location": (0.0, 0.0, -20.0), "rotation_euler": (0.0, 0.0, 0.0)}, 
        "spine": {"rotation_euler": (0.0, math.radians(-5), 0.0)},
        "foot_ik.L": {"location": (TRACK_FOOT_L, -250.0, 100.0), "rotation_euler": (math.radians(-20), 0.0, math.radians(-8))}, 
        "knee_pole.L": {"location": (TRACK_KNEE_L, 0.0, 0.0)},
        "heel.02.L": {"location": (-250.0, TRACK_HEEL_L_Y, 100.0)},
        "foot_ik.R": {"location": (TRACK_FOOT_R, 350.0, 200.0), "rotation_euler": (math.radians(10), 0.0, math.radians(-8))}, 
        "knee_pole.R": {"location": (TRACK_KNEE_R, 500.0, 0.0)},
        "heel.02.R": {"location": (-350.0, TRACK_HEEL_R_Y, 200.0)},
        "hand_ik.L": {"location": (TRACK_HAND_L, 200.0, 40.0)}, 
        "elbow_pole.L": {"location": (TRACK_ELBOW_L, -150.0, 0.0)},
        "hand_ik.R": {"location": (TRACK_HAND_R, -200.0, -30.0)}, 
        "elbow_pole.R": {"location": (TRACK_ELBOW_R, 150.0, 0.0)},
    }
    
    def mirror(p):
        p_mir = {}
        # Root mirrors X
        p_mir["root"] = p["root"].copy()
        if "location" in p_mir["root"]:
            loc = p_mir["root"]["location"]
            p_mir["root"]["location"] = (-loc[0], loc[1], loc[2])
            
        # Spine mirrors Twist (Yaw / Y)
        p_mir["spine"] = p["spine"].copy()
        if "rotation_euler" in p_mir["spine"]:
            rot = p_mir["spine"]["rotation_euler"]
            p_mir["spine"]["rotation_euler"] = (rot[0], -rot[1], rot[2])
        
        # SMART MIRROR: Keep own X track, swap Y and Z.
        def mirror_bone(bone_l, bone_r):
            if bone_l in p:
                p_mir[bone_l] = p[bone_l].copy()
                p_mir[bone_l]["location"] = (p[bone_l]["location"][0], p[bone_r]["location"][1], p[bone_r]["location"][2])
                if "rotation_euler" in p[bone_l]:
                    p_mir[bone_l]["rotation_euler"] = p[bone_r]["rotation_euler"]
                    
            if bone_r in p:
                p_mir[bone_r] = p[bone_r].copy()
                p_mir[bone_r]["location"] = (p[bone_r]["location"][0], p[bone_l]["location"][1], p[bone_l]["location"][2])
                if "rotation_euler" in p[bone_r]:
                    p_mir[bone_r]["rotation_euler"] = p[bone_l]["rotation_euler"]

        mirror_bone("foot_ik.L", "foot_ik.R")
        mirror_bone("knee_pole.L", "knee_pole.R")
        mirror_bone("hand_ik.L", "hand_ik.R")
        mirror_bone("elbow_pole.L", "elbow_pole.R")
        
        # Heel is special: Y is lateral track. X is Fwd/Back. Z is Up/Down.
        # Keep own Y, swap X and Z.
        if "heel.02.L" in p and "heel.02.R" in p:
            p_mir["heel.02.L"] = p["heel.02.L"].copy()
            p_mir["heel.02.R"] = p["heel.02.R"].copy()
            
            # Left Heel copies Right Heel's X and Z. But since Right Heel +X is backwards, 
            # and Left Heel +X is forwards, we must NOT invert X during swap!
            # Wait. If Right Heel X is 450 (Backward). We want Left Heel to go Backward.
            # Left Heel +X is Forward. To go Backward, it needs -450.
            # So X MUST BE INVERTED!
            p_mir["heel.02.L"]["location"] = (-p["heel.02.R"]["location"][0], p["heel.02.L"]["location"][1], p["heel.02.R"]["location"][2])
            p_mir["heel.02.R"]["location"] = (-p["heel.02.L"]["location"][0], p["heel.02.R"]["location"][1], p["heel.02.L"]["location"][2])

        return p_mir

    p5 = mirror(p1) # CONTACT R
    p6 = mirror(p2) # DOWN R
    p7 = mirror(p3) # PASSING R
    p8 = mirror(p4) # UP R
    
    return [p1, p2, p3, p4, p5, p6, p7, p8, p1]

def create_walk_cycle():
    arm_obj = bpy.data.objects.get('metarig')
    if not arm_obj:
        return False

    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode='POSE')
    
    # Ensure properties
    root_bone = arm_obj.pose.bones.get("root")
    if root_bone:
        for prop in ['ik_arm_L', 'ik_arm_R', 'ik_leg_L', 'ik_leg_R']:
            if prop in root_bone:
                root_bone[prop] = 1.0

    if arm_obj.animation_data is None:
        arm_obj.animation_data_create()

    action = bpy.data.actions.new(name=ACTION_NAME)
    arm_obj.animation_data.action = action
    
    bpy.context.scene.frame_start = FRAMES[0]
    bpy.context.scene.frame_end = FRAMES[-1]

    poses = get_poses()
    
    for i, frame in enumerate(FRAMES):
        pose_data = poses[i]
        
        # Apply pose
        for bone_name, transform in pose_data.items():
            pb = arm_obj.pose.bones.get(bone_name)
            if not pb: continue
            
            if "location" in transform:
                pb.location = transform["location"]
            if "rotation_euler" in transform:
                pb.rotation_mode = 'XYZ'
                pb.rotation_euler = transform["rotation_euler"]
                
        bpy.context.view_layer.update()
        
        # Keyframe
        for bone_name, transform in pose_data.items():
            pb = arm_obj.pose.bones.get(bone_name)
            if not pb: continue
            if "location" in transform:
                pb.keyframe_insert(data_path="location", frame=frame)
            if "rotation_euler" in transform:
                pb.keyframe_insert(data_path="rotation_euler", frame=frame)

    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("WALK CYCLE CREATION COMPLETE.")
    return True

if __name__ == "__main__":
    create_walk_cycle()
"""
    with open(r'D:\Atlas\projects\blender\Scripts\axion_walk_cycle.py', 'w') as f:
        f.write(script)

if __name__ == "__main__":
    generate_script()
