import bpy

def reset_rig_and_pole_angles():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    
    # 1. Reset all poses to perfectly match Edit Mode
    bpy.ops.pose.select_all(action='SELECT')
    bpy.ops.pose.loc_clear()
    bpy.ops.pose.rot_clear()
    bpy.ops.pose.scale_clear()
    bpy.ops.pose.select_all(action='DESELECT')
    
    # 2. Reset Pole Angles to 0
    # Since the legs now point DOWN (Z-axis) correctly, the default IK behavior usually expects 0 or 180.
    for bone_name in ['shin.L', 'shin.R', 'forearm.L', 'forearm.R']:
        pb = arm.pose.bones.get(bone_name)
        if not pb: continue
        for c in pb.constraints:
            if c.type == 'IK' and c.pole_target:
                # Setting to 0 so the IK chain evaluates naturally without forced twists
                c.pole_angle = 0.0

    bpy.context.view_layer.update()
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("RESTORED NORMAL POSE MODE (CLEARED POSES, ZEROED POLE ANGLES)")

if __name__ == "__main__":
    reset_rig_and_pole_angles()
