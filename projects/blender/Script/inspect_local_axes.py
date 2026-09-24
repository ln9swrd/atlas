import bpy
from mathutils import Vector

arm = bpy.data.objects.get('metarig')
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')

def test_bone(bone_name, offset):
    pb = arm.pose.bones.get(bone_name)
    if not pb: return
    
    # Reset
    pb.location = (0,0,0)
    bpy.context.view_layer.update()
    pos1 = pb.matrix.translation.copy()
    
    # Apply offset
    pb.location = offset
    bpy.context.view_layer.update()
    pos2 = pb.matrix.translation.copy()
    
    diff = pos2 - pos1
    print(f"Bone: {bone_name}, Offset: {offset}")
    print(f"  World translation: {diff}")
    
    # Reset
    pb.location = (0,0,0)
    bpy.context.view_layer.update()

print("--- LOCAL AXES TEST ---")
test_bone('root', (100, 0, 0))
test_bone('root', (0, 100, 0))
test_bone('root', (0, 0, 100))

test_bone('foot_ik.L', (100, 0, 0))
test_bone('foot_ik.L', (0, 100, 0))
test_bone('foot_ik.L', (0, 0, 100))

test_bone('knee_pole.L', (0, 100, 0))
