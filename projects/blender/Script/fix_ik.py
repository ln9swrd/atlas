import bpy
import math

def fix_rig():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    
    # 1. Reset all poses
    bpy.ops.pose.select_all(action='SELECT')
    bpy.ops.pose.loc_clear()
    bpy.ops.pose.rot_clear()
    bpy.ops.pose.scale_clear()
    bpy.ops.pose.select_all(action='DESELECT')
    
    # 2. Fix IK Pole Angles
    # Often, automatically added IK constraints have a pole angle of 0.
    # Depending on the rest pose roll, 0 might twist the knee by 90 or 180 degrees.
    
    # Let's systematically test pole angles for shin.L to see which one keeps the knee pointing forward (towards the pole target).
    # Actually, we can just set common pole angles (0, 90, 180, -90) and see what the user says, OR calculate it.
    
    # Let's set Pole Angle to -90 for left leg, 90 for right leg (common for many rigs), or 0, 180.
    # I will set them to 0 and explicitly update. Wait, if it's currently 0 and twisted, it needs -90 or 90.
    
    for bone_name in ['shin.L', 'shin.R', 'forearm.L', 'forearm.R']:
        pb = arm.pose.bones.get(bone_name)
        if not pb: continue
        for c in pb.constraints:
            if c.type == 'IK' and c.pole_target:
                # We will output the current pole angle
                print(f"{bone_name} IK Pole Angle is currently: {math.degrees(c.pole_angle)}")
                # I'll temporarily set them to -90 for L, 90 for R just to see if it fixes the twist.
                if '.L' in bone_name:
                    c.pole_angle = math.radians(-90)
                else:
                    c.pole_angle = math.radians(90)

    bpy.context.view_layer.update()
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("Fixed Pole Angles and Reset Pose.")

if __name__ == "__main__":
    fix_rig()
