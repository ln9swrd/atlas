import bpy

def check_heel_r_all_axes():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    
    b = 'heel.02.R'
    pb = arm.pose.bones.get(b)
    if not pb: return
    
    old_mat = pb.matrix_basis.copy()
    
    try:
        pb.matrix_basis = pb.bone.matrix_local.inverted() @ pb.bone.matrix_local
        bpy.context.view_layer.update()
        w_origin = pb.matrix.translation.copy()
        
        pb.location = (10, 0, 0)
        bpy.context.view_layer.update()
        print(f"Local +X -> World {pb.matrix.translation - w_origin}")
        
        pb.location = (0, 10, 0)
        bpy.context.view_layer.update()
        print(f"Local +Y -> World {pb.matrix.translation - w_origin}")
        
        pb.location = (0, 0, 10)
        bpy.context.view_layer.update()
        print(f"Local +Z -> World {pb.matrix.translation - w_origin}")
        
    finally:
        pb.matrix_basis = old_mat
        bpy.context.view_layer.update()

if __name__ == "__main__":
    check_heel_r_all_axes()
