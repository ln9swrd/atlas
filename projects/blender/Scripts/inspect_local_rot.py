import bpy
import math
from mathutils import Vector, Euler

arm = bpy.data.objects.get('metarig')
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')

def test_bone_rot(bone_name, rot):
    pb = arm.pose.bones.get(bone_name)
    if not pb: return
    
    # Reset
    pb.rotation_quaternion = (1,0,0,0)
    pb.rotation_euler = (0,0,0)
    bpy.context.view_layer.update()
    
    mat1 = pb.matrix.to_3x3()
    
    # Apply rot
    pb.rotation_mode = 'XYZ'
    pb.rotation_euler = rot
    bpy.context.view_layer.update()
    
    mat2 = pb.matrix.to_3x3()
    
    # To see what happened, let's look at how the World +Z vector transformed
    z_vec = Vector((0,0,1))
    y_vec = Vector((0,1,0))
    
    print(f"Bone: {bone_name}, Rot: {rot}")
    print(f"  World Z axis transformed to: {mat2 @ (mat1.inverted() @ z_vec)}")
    print(f"  World Y axis transformed to: {mat2 @ (mat1.inverted() @ y_vec)}")
    
    # Reset
    pb.rotation_euler = (0,0,0)
    bpy.context.view_layer.update()

print("--- LOCAL ROTATION TEST ---")
test_bone_rot('spine', (math.radians(20), 0, 0)) # Pitch test
test_bone_rot('spine', (0, 0, math.radians(20))) # Twist test

test_bone_rot('foot_ik.L', (math.radians(20), 0, 0))
test_bone_rot('foot_ik.L', (0, math.radians(20), 0))
test_bone_rot('foot_ik.L', (0, 0, math.radians(20)))
