import bpy

def check_heel_axes():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    
    bones_to_test = ['heel.02.L', 'heel.02.R']
    old_matrices = {}
    
    print("\n=== HEEL AXES VERIFICATION ===")
    try:
        for b in bones_to_test:
            pb = arm.pose.bones.get(b)
            if not pb: continue
            
            old_matrices[b] = pb.matrix_basis.copy()
            pb.matrix_basis = pb.bone.matrix_local.inverted() @ pb.bone.matrix_local
            bpy.context.view_layer.update()
            
            w_origin = pb.matrix.translation.copy()
            
            pb.location = (10, 0, 0)
            bpy.context.view_layer.update()
            w_x = pb.matrix.translation - w_origin
            
            print(f"\n{b} Local +X moves -> World {w_x}")
            
    finally:
        for b, mat in old_matrices.items():
            pb = arm.pose.bones.get(b)
            if pb:
                pb.matrix_basis = mat
        bpy.context.view_layer.update()

if __name__ == "__main__":
    check_heel_axes()
