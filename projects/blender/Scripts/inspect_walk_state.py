import bpy
import math
from mathutils import Vector, Euler

def check_axes_and_state():
    print("=== READ-ONLY BLENDER STATE CHECK ===")
    arm = bpy.data.objects.get('metarig')
    if not arm:
        print("UNVERIFIED: 'metarig' not found.")
        return
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    
    # Check Action
    action = None
    if arm.animation_data and arm.animation_data.action:
        action = arm.animation_data.action
        print(f"Current Action: {action.name}")
        print(f"Frame Range: {action.frame_range[0]} to {action.frame_range[1]}")
    else:
        print("UNVERIFIED: No Action assigned.")
        
    # Check Axes by applying small local translations and measuring world delta
    print("\n=== COORDINATE SYSTEM VERIFICATION ===")
    
    bones_to_test = ['foot_ik.L', 'hand_ik.L', 'knee_pole.L', 'elbow_pole.L']
    
    # Store old poses to restore later
    old_matrices = {}
    for b in bones_to_test:
        pb = arm.pose.bones.get(b)
        if pb:
            old_matrices[b] = pb.matrix_basis.copy()
            
    try:
        for b in bones_to_test:
            pb = arm.pose.bones.get(b)
            if not pb: continue
            
            pb.matrix_basis = pb.bone.matrix_local.inverted() @ pb.bone.matrix_local # Reset to rest
            bpy.context.view_layer.update()
            
            w_origin = pb.matrix.translation.copy()
            
            # Test Local +X
            pb.location = (10, 0, 0)
            bpy.context.view_layer.update()
            w_x = pb.matrix.translation - w_origin
            
            # Test Local +Y
            pb.location = (0, 10, 0)
            bpy.context.view_layer.update()
            w_y = pb.matrix.translation - w_origin
            
            # Test Local +Z
            pb.location = (0, 0, 10)
            bpy.context.view_layer.update()
            w_z = pb.matrix.translation - w_origin
            
            print(f"\n{b} Local Axes Mapping to World:")
            print(f"  Local +X moves -> World {w_x}")
            print(f"  Local +Y moves -> World {w_y}")
            print(f"  Local +Z moves -> World {w_z}")
            
    finally:
        # Restore
        for b, mat in old_matrices.items():
            pb = arm.pose.bones.get(b)
            if pb:
                pb.matrix_basis = mat
        bpy.context.view_layer.update()

    print("\n=== BONE TWIST / IK STATE ===")
    # Check IK constraints
    for pb in arm.pose.bones:
        for c in pb.constraints:
            if c.type == 'IK':
                print(f"{pb.name} IK Constraint: Target={c.target.name if c.target else 'None'}, Pole={c.pole_target.name if c.pole_target else 'None'}, PoleAngle={math.degrees(c.pole_angle):.2f}")

    print("\nSTATE CHECK COMPLETE.")

if __name__ == "__main__":
    check_axes_and_state()
