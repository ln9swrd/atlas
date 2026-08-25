import bpy
import sys

print("\n--- APPLYING FULL RIGIFY SETUP ---")

try:
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        print("SuperRobotRig not found")
        sys.exit(0)

    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='EDIT')
    
    # 1. Identify IK chains
    ik_roots = ['upper_arm.L', 'upper_arm.R', 'thigh.L', 'thigh.R']
    ik_chain_bones = set()
    
    def walk_connected(ebone):
        ik_chain_bones.add(ebone.name)
        for child in ebone.children:
            if child.use_connect:
                walk_connected(child)
                
    for rname in ik_roots:
        if rname in rig.data.edit_bones:
            walk_connected(rig.data.edit_bones[rname])
            
    bpy.ops.object.mode_set(mode='POSE')
    
    # 2. Assign properties
    for pb in rig.pose.bones:
        # Clear old type
        pb.rigify_type = ""
        
        if pb.name in ik_roots:
            pb.rigify_type = "limbs.simple_tentacle"
            # Optional: set tentacle segments or tweaks if needed, but defaults are fine
            print(f"Set IK Tentacle -> {pb.name}")
        elif pb.name not in ik_chain_bones:
            # If not part of the IK chain, give it a basic FK copy control
            pb.rigify_type = "basic.super_copy"
            # rigify_parameters.make_control is True by default for super_copy
            pb.rigify_parameters.make_control = True
            print(f"Set FK Copy -> {pb.name}")

    bpy.ops.wm.save_mainfile()
    print("Successfully assigned rigify types to the entire armature and saved!")
    
except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)
