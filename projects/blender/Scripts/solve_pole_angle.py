import bpy
import math
from mathutils import Matrix, Vector

def find_best_pole_angle():
    arm = bpy.data.objects.get('metarig')
    if not arm: return
    
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='EDIT')
    
    # Store Edit Mode (Rest Pose) bone matrices
    edit_matrices = {}
    for bone_name in ['thigh.L', 'shin.L', 'thigh.R', 'shin.R', 'upper_arm.L', 'forearm.L', 'upper_arm.R', 'forearm.R']:
        eb = arm.data.edit_bones.get(bone_name)
        if eb:
            edit_matrices[bone_name] = eb.matrix.copy()
            
    bpy.ops.object.mode_set(mode='POSE')
    
    # Clear poses
    bpy.ops.pose.select_all(action='SELECT')
    bpy.ops.pose.loc_clear()
    bpy.ops.pose.rot_clear()
    bpy.ops.pose.scale_clear()
    
    ik_bones = {
        'shin.L': 'thigh.L',
        'shin.R': 'thigh.R',
        'forearm.L': 'upper_arm.L',
        'forearm.R': 'upper_arm.R'
    }
    
    for bone_name, parent_name in ik_bones.items():
        pb = arm.pose.bones.get(bone_name)
        if not pb: continue
        
        ik_c = None
        for c in pb.constraints:
            if c.type == 'IK' and c.pole_target:
                ik_c = c
                break
                
        if not ik_c: continue
        
        # We need to find the pole_angle that minimizes the difference between Edit Mode matrix and Pose Mode matrix
        best_angle = 0
        min_error = float('inf')
        
        edit_mat_child = edit_matrices[bone_name]
        edit_mat_parent = edit_matrices[parent_name]
        
        # Test angles from -180 to 180
        for i in range(-180, 180, 5):
            angle = math.radians(i)
            ik_c.pole_angle = angle
            bpy.context.view_layer.update()
            
            pb_parent = arm.pose.bones.get(parent_name)
            
            # Get Pose Mode matrices (world space relative to armature, which is bone.matrix)
            pose_mat_child = pb.matrix
            pose_mat_parent = pb_parent.matrix
            
            # Compare basis (rotation vectors)
            diff_child = sum((pose_mat_child.to_3x3()[j] - edit_mat_child.to_3x3()[j]).length for j in range(3))
            diff_parent = sum((pose_mat_parent.to_3x3()[j] - edit_mat_parent.to_3x3()[j]).length for j in range(3))
            
            total_error = diff_child + diff_parent
            
            if total_error < min_error:
                min_error = total_error
                best_angle = angle
                
        # Set the best angle
        ik_c.pole_angle = best_angle
        print(f"Optimal Pole Angle for {bone_name}: {math.degrees(best_angle)} degrees (Error: {min_error})")

    bpy.context.view_layer.update()
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("Automatic Pole Angle Calibration Complete.")

if __name__ == "__main__":
    find_best_pole_angle()
