import bpy

def inspect_skin_twisting():
    print("\n=== SKIN TWISTING DIAGNOSTICS ===")
    arm = bpy.data.objects.get('metarig')
    if not arm:
        print("Armature not found!")
        return

    # 1. Check if control bones are deforming the mesh
    print("\n1. CHECKING CONTROL BONES DEFORM FLAG:")
    control_bones = [
        'root', 
        'foot_ik.L', 'foot_ik.R', 'knee_pole.L', 'knee_pole.R',
        'hand_ik.L', 'hand_ik.R', 'elbow_pole.L', 'elbow_pole.R'
    ]
    
    deforming_controls = []
    for b_name in control_bones:
        bone = arm.data.bones.get(b_name)
        if bone:
            if bone.use_deform:
                deforming_controls.append(b_name)
                print(f"  [WARNING] Control bone '{b_name}' has use_deform=True! This will warp the mesh.")
            else:
                print(f"  [OK] '{b_name}' use_deform=False")
                
    if not deforming_controls:
        print("  All control bones correctly have use_deform=False.")

    # 2. Check Armature Modifiers on Meshes
    print("\n2. CHECKING MESH ARMATURE MODIFIERS:")
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
    bound_meshes = []
    for mesh in meshes:
        for mod in mesh.modifiers:
            if mod.type == 'ARMATURE' and mod.object == arm:
                bound_meshes.append(mesh.name)
                print(f"  Mesh '{mesh.name}' has Armature modifier.")
                if not mod.use_deform_preserve_volume:
                    print(f"  [WARNING] Mesh '{mesh.name}' does NOT have 'Preserve Volume' enabled. Joints will collapse/twist.")
                else:
                    print(f"  [OK] Mesh '{mesh.name}' has 'Preserve Volume' enabled.")
                
    if not bound_meshes:
        print("  [WARNING] No meshes found bound to this armature!")

    # 3. Check for unexpected twisting bones (like B-Bone segments)
    print("\n3. CHECKING B-BONE SEGMENTS:")
    for b_name in ['thigh.L', 'shin.L', 'thigh.R', 'shin.R']:
        bone = arm.data.bones.get(b_name)
        if bone and bone.bbone_segments > 1:
            print(f"  [INFO] '{b_name}' has {bone.bbone_segments} B-Bone segments.")
            
    print("=== DIAGNOSTICS COMPLETE ===")

if __name__ == "__main__":
    inspect_skin_twisting()
