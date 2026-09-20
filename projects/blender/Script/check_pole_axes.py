import bpy

def check_pole_axes():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    
    bones = ['knee_pole.L', 'knee_pole.R', 'elbow_pole.L', 'elbow_pole.R']
    old_matrices = {}
    
    try:
        for b in bones:
            pb = arm.pose.bones.get(b)
            if not pb: continue
            
            old_matrices[b] = pb.matrix_basis.copy()
            pb.matrix_basis = pb.bone.matrix_local.inverted() @ pb.bone.matrix_local
            bpy.context.view_layer.update()
            w_origin = pb.matrix.translation.copy()
            
            print(f"\n--- {b} ---")
            pb.location = (10, 0, 0)
            bpy.context.view_layer.update()
            print(f"+X -> {pb.matrix.translation - w_origin}")
            
            pb.location = (0, 10, 0)
            bpy.context.view_layer.update()
            print(f"+Y -> {pb.matrix.translation - w_origin}")
            
            pb.location = (0, 0, 10)
            bpy.context.view_layer.update()
            print(f"+Z -> {pb.matrix.translation - w_origin}")
            
            pb.location = (0, 0, 0) # reset for next
            
    finally:
        for b, mat in old_matrices.items():
            pb = arm.pose.bones.get(b)
            if pb: pb.matrix_basis = mat
        bpy.context.view_layer.update()

if __name__ == "__main__":
    check_pole_axes()
