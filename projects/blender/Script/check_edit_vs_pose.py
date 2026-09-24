import bpy

def check_bones():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    bpy.context.view_layer.objects.active = arm
    
    # 1. READ EDIT MODE (REST POSE) BONES
    bpy.ops.object.mode_set(mode='EDIT')
    print("\n=== EDIT MODE BONES (REST POSE) ===")
    edit_data = {}
    for bone_name in ['thigh.L', 'shin.L', 'foot.L', 'foot_ik.L', 'knee_pole.L', 'hand_ik.L', 'elbow_pole.L']:
        eb = arm.data.edit_bones.get(bone_name)
        if eb:
            edit_data[bone_name] = {'head': eb.head.copy(), 'tail': eb.tail.copy(), 'roll': eb.roll}
            print(f"{bone_name}: Head={eb.head}, Tail={eb.tail}, Roll={eb.roll}")
        else:
            print(f"{bone_name} not found in Edit mode!")
            
    # 2. READ POSE MODE BONES (EVALUATED POSE WITH CONSTRAINTS)
    bpy.ops.object.mode_set(mode='POSE')
    
    # Reset pose just to be sure
    bpy.ops.pose.select_all(action='SELECT')
    bpy.ops.pose.loc_clear()
    bpy.ops.pose.rot_clear()
    bpy.ops.pose.scale_clear()
    bpy.ops.pose.select_all(action='DESELECT')
    bpy.context.view_layer.update()
    
    print("\n=== POSE MODE BONES (CLEARED POSE, CONSTRAINTS ACTIVE) ===")
    for bone_name in ['thigh.L', 'shin.L', 'foot.L', 'foot_ik.L', 'knee_pole.L', 'hand_ik.L', 'elbow_pole.L']:
        pb = arm.pose.bones.get(bone_name)
        if pb:
            # Get world matrix position
            head_world = (arm.matrix_world @ pb.matrix).translation
            print(f"{bone_name} World Pos: {head_world}")
            
            if pb.constraints:
                for c in pb.constraints:
                    print(f"  Constraint: {c.type}, Influence: {c.influence}")
                    if c.type == 'IK':
                        if c.pole_target:
                            print(f"  IK Pole Angle: {c.pole_angle}")
        else:
            print(f"{bone_name} not found in Pose mode!")

if __name__ == "__main__":
    check_bones()
