import bpy
import json
import sys

def get_armature():
    armatures = [obj for obj in bpy.context.scene.objects if obj.type == 'ARMATURE']
    if not armatures:
        return None
    # Prioritize 'metarig' if it exists, as mentioned by the user
    for arm in armatures:
        if 'metarig' in arm.name.lower():
            return arm
    return armatures[0]

def inspect_armature():
    arm_obj = get_armature()
    if not arm_obj:
        print("No armature found in the scene.")
        return

    arm = arm_obj.data
    
    print(f"==================================================")
    print(f"ARMATURE NAME: {arm_obj.name}")
    print(f"BONE COUNT: {len(arm.bones)}")
    
    # Find Root Bone
    roots = [b for b in arm.bones if not b.parent]
    print(f"ROOT BONES: {[b.name for b in roots]}")
    
    # Users (Mesh)
    meshes = []
    for obj in bpy.context.scene.objects:
        if obj.type == 'MESH':
            for mod in obj.modifiers:
                if mod.type == 'ARMATURE' and mod.object == arm_obj:
                    meshes.append(obj.name)
    print(f"MESH USERS: {meshes}")
    
    # Animation Data
    anim_data = arm_obj.animation_data
    if anim_data and anim_data.action:
        print(f"ANIMATION DATA: {anim_data.action.name}")
    else:
        print("ANIMATION DATA: None")

    print(f"\n--- BONES HIERARCHY & INFO ---")
    
    for bone in arm.bones:
        parent_name = bone.parent.name if bone.parent else "None"
        children_names = [c.name for c in bone.children]
        
        # Pose bone for constraints and rotation mode
        pose_bone = arm_obj.pose.bones.get(bone.name)
        rot_mode = pose_bone.rotation_mode if pose_bone else "N/A"
        
        constraints = []
        if pose_bone:
            for c in pose_bone.constraints:
                c_info = f"{c.name}({c.type})"
                if c.type == 'IK':
                    target = c.target.name if c.target else "None"
                    subtarget = c.subtarget if hasattr(c, 'subtarget') else "None"
                    pole = c.pole_target.name if c.pole_target else "None"
                    pole_sub = c.pole_subtarget if hasattr(c, 'pole_subtarget') else "None"
                    c_info += f" Target: {target}:{subtarget}, Pole: {pole}:{pole_sub}"
                constraints.append(c_info)
        
        print(f"\nBone: {bone.name}")
        print(f"  Parent: {parent_name}")
        print(f"  Children: {children_names}")
        print(f"  Head: {list(bone.head)}")
        print(f"  Tail: {list(bone.tail)}")
        print(f"  Length: {bone.length}")
        print(f"  Rotation Mode: {rot_mode}")
        if constraints:
            print(f"  Constraints: {constraints}")
        else:
            print(f"  Constraints: None")

if __name__ == "__main__":
    inspect_armature()
    print("\n--- INSPECTION COMPLETE ---")
