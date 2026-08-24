import bpy
import sys
import os

print("\n--- START RIG INSPECTION ---")

try:
    # Look for armature objects
    armatures = [obj for obj in bpy.data.objects if obj.type == 'ARMATURE']
    print(f"Found armatures: {[a.name for a in armatures]}")
    
    target_rig_name = "SuperRobotRig"
    if target_rig_name in bpy.data.objects:
        rig = bpy.data.objects[target_rig_name]
    elif armatures:
        print(f"Rig '{target_rig_name}' not found, falling back to '{armatures[0].name}'")
        rig = armatures[0]
    else:
        print("No armature found in the scene.")
        sys.exit(0)

    print(f"\nInspecting Rig: {rig.name}")
    
    # Check Transform (Location, Rotation, Scale)
    loc = rig.location
    rot = rig.rotation_euler
    scale = rig.scale
    print(f"Location: {loc[:]}")
    print(f"Rotation: {rot[:]}")
    print(f"Scale: {scale[:]}")
    
    if any(abs(v) > 0.001 for v in loc) or any(abs(v) > 0.001 for v in rot) or any(abs(v - 1.0) > 0.001 for v in scale):
        print("WARNING: Transform is not applied! (Location should be 0,0,0, Rotation 0,0,0, Scale 1,1,1)")
        
    # Check bones
    print(f"Total Bones: {len(rig.data.bones)}")
    
    # Check constraints for missing targets
    missing_targets = []
    for bone in rig.pose.bones:
        for constraint in bone.constraints:
            if hasattr(constraint, 'target') and constraint.target is None:
                if constraint.type not in ['LIMIT_LOCATION', 'LIMIT_ROTATION', 'LIMIT_SCALE', 'COPY_TRANSFORMS']:
                    missing_targets.append((bone.name, constraint.name, constraint.type))
            if hasattr(constraint, 'subtarget') and constraint.target is not None:
                if constraint.subtarget == "" or constraint.subtarget not in constraint.target.pose.bones:
                     missing_targets.append((bone.name, f"{constraint.name} (Missing Subtarget: {constraint.subtarget})", constraint.type))
                     
    if missing_targets:
        print("\nWARNING: Missing Constraint Targets:")
        for mt in missing_targets:
            print(f" - Bone '{mt[0]}', Constraint '{mt[1]}' ({mt[2]})")
    else:
        print("No missing constraint targets found.")
        
    print("\nCustom properties on Rig:")
    for key in rig.keys():
        if key not in ['_RNA_UI']:
            print(f" - {key}: {rig[key]}")

    depsgraph = bpy.context.evaluated_depsgraph_get()
    print("\nEvaluated Depsgraph (Check console for dependency cycles).")

except Exception as e:
    print(f"ERROR during inspection: {e}")

print("--- END RIG INSPECTION ---")
sys.exit(0)
