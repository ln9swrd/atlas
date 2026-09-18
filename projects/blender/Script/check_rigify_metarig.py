"""
Diagnose RIG-Axion_Rigify_Metarig structure
"""

import bpy

print("\n" + "="*60)
print("DIAGNOSE RIG-Axion_Rigify_Metarig")
print("="*60)

rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
if not rig:
    print("[!] RIG-Axion_Rigify_Metarig not found")
    # Try alternative names
    print("\n[Searching for similar armatures...]")
    for obj in bpy.data.objects:
        if obj.type == 'ARMATURE' and 'Rigify' in obj.name:
            print(f"  Found: {obj.name}")
else:
    print(f"\n✅ Found: RIG-Axion_Rigify_Metarig")
    print(f"   Type: {rig.type}")
    print(f"   Total bones: {len(rig.data.bones)}")
    
    bone_names = [b.name for b in rig.data.bones]
    
    # Check structure
    has_def = any('def' in b.lower() or 'DEF' in b for b in bone_names)
    has_mch = any('mch' in b.lower() or 'MCH' in b for b in bone_names)
    has_ik = any('ik' in b.lower() or 'IK' in b for b in bone_names)
    has_fk = any('fk' in b.lower() or 'FK' in b for b in bone_names)
    has_ctrl = any('ctrl' in b.lower() or 'CTL' in b for b in bone_names)
    
    print(f"\n[Rigify Structure Check]")
    print(f"  DEF (deform):      {'✅' if has_def else '❌'}")
    print(f"  MCH (mechanism):   {'✅' if has_mch else '❌'}")
    print(f"  IK chains:         {'✅' if has_ik else '❌'}")
    print(f"  FK chains:         {'✅' if has_fk else '❌'}")
    print(f"  CTL (control):     {'✅' if has_ctrl else '❌'}")
    
    print(f"\n[Bone List (first 20)]")
    for i, name in enumerate(bone_names[:20]):
        print(f"  {i+1:2d}. {name}")
    
    if len(bone_names) > 20:
        print(f"  ... and {len(bone_names) - 20} more bones")
    
    # Check constraints
    print(f"\n[Constraints on Pose Bones]")
    constraint_count = 0
    for pb in rig.pose.bones:
        if pb.constraints:
            for const in pb.constraints:
                constraint_count += 1
                if constraint_count <= 5:  # Show first 5
                    print(f"  {pb.name}: {const.type}")
    
    if constraint_count == 0:
        print(f"  (none)")
    elif constraint_count > 5:
        print(f"  ... and {constraint_count - 5} more constraints")
    
    # Diagnosis
    print(f"\n[DIAGNOSIS]")
    if has_def and has_mch and has_fk and has_ik:
        print(f"  ✅ PROPER RIGIFY RIG (Generated)")
        print(f"  → Can use for animation!")
    elif has_ik and not has_def and not has_mch:
        print(f"  ⚠️  INCOMPLETE METARIG")
        print(f"  → Missing proper Rigify structure")
        print(f"  → NOT suitable for animation")
    else:
        print(f"  ? UNKNOWN STRUCTURE")

print("\n" + "="*60 + "\n")
