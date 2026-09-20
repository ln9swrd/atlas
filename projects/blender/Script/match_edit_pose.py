import bpy
from mathutils import Matrix

def make_pose_match_edit():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    
    # 1. Clear all poses
    bpy.ops.pose.select_all(action='SELECT')
    bpy.ops.pose.loc_clear()
    bpy.ops.pose.rot_clear()
    bpy.ops.pose.scale_clear()
    bpy.ops.pose.select_all(action='DESELECT')
    
    # 2. Fix Copy Rotation constraints that cause feet/hands to snap
    for bone in arm.pose.bones:
        for c in bone.constraints:
            if c.type == 'COPY_ROTATION':
                # If the target and owner have different rest orientations, COPY_ROTATION in World Space
                # will cause the bone to snap instantly in Pose Mode.
                # Setting it to Local Space / Local Space allows it to keep its rest pose orientation,
                # and only copy RELATIVE rotations.
                c.target_space = 'LOCAL'
                c.owner_space = 'LOCAL'
                c.mix_mode = 'ADD' # or 'REPLACE' if local/local
                # 'OFFSET' was added in later versions, 'ADD' or 'REPLACE' works with LOCAL/LOCAL.
                # Actually, Local/Local Replace means it exactly copies the local offset. 
                # Since the IK control has 0 local offset in rest pose, the foot will have 0 local offset, staying in rest pose!
                c.mix_mode = 'REPLACE'
                print(f"Fixed COPY_ROTATION on {bone.name}")
                
            elif c.type == 'IK' and c.pole_target:
                # To prevent knee from shifting AT ALL, we calculate the exact pole angle, or 
                # just rely on 0 if it's close.
                pass
                
    # Evaluate
    bpy.context.view_layer.update()
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("Pose Mode should now match Edit Mode.")

if __name__ == "__main__":
    make_pose_match_edit()
