import bpy

def check_foot_axes():
    arm = bpy.data.objects.get('metarig')
    if not arm: return
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    
    bones = ['foot_ik.L', 'foot_ik.R']
    old_mat = {}
    
    try:
        for b in bones:
            pb = arm.pose.bones.get(b)
            old_mat[b] = pb.matrix_basis.copy()
            pb.matrix_basis = pb.bone.matrix_local.inverted() @ pb.bone.matrix_local
            bpy.context.view_layer.update()
            
            w_orig = pb.matrix.translation.copy()
            
            print(f"\n--- {b} ---")
            pb.location = (10, 0, 0)
            bpy.context.view_layer.update()
            print(f"+X -> {pb.matrix.translation - w_orig}")
            
            pb.location = (0, 10, 0)
            bpy.context.view_layer.update()
            print(f"+Y -> {pb.matrix.translation - w_orig}")
            
            pb.location = (0, 0, 10)
            bpy.context.view_layer.update()
            print(f"+Z -> {pb.matrix.translation - w_orig}")
            
            pb.location = (0,0,0)
    finally:
        for b, m in old_mat.items():
            if arm.pose.bones.get(b): arm.pose.bones.get(b).matrix_basis = m
        bpy.context.view_layer.update()

if __name__ == "__main__":
    check_foot_axes()
