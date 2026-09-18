"""
Diagnose axion_metarig.001 structure
"""

import bpy

print("\n" + "="*60)
print("DIAGNOSE axion_metarig.001")
print("="*60)

metarig = bpy.data.objects.get("axion_metarig.001")
if not metarig:
    print("[!] axion_metarig.001 not found")
else:
    print(f"\n✅ Found: axion_metarig.001")
    print(f"   Type: {metarig.type}")
    print(f"   Total bones: {len(metarig.data.bones)}")
    
    bone_names = [b.name for b in metarig.data.bones]
    
    # Check structure
    has_def = any('def' in b.lower() for b in bone_names)
    has_mch = any('mch' in b.lower() for b in bone_names)
    has_ik = any('ik' in b.lower() for b in bone_names)
    has_fk = any('fk' in b.lower() for b in bone_names)
    
    print(f"\n[Rigify Structure Check]")
    print(f"  DEF (deform):      {'✅' if has_def else '❌'}")
    print(f"  MCH (mechanism):   {'✅' if has_mch else '❌'}")
    print(f"  IK chains:         {'✅' if has_ik else '❌'}")
    print(f"  FK chains:         {'✅' if has_fk else '❌'}")
    
    print(f"\n[Bone List (first 20)]")
    for i, name in enumerate(bone_names[:20]):
        print(f"  {i+1:2d}. {name}")
    
    # Check constraints
    print(f"\n[Constraints on Pose Bones]")
    constraint_count = 0
    for pb in metarig.pose.bones:
        if pb.constraints:
            for const in pb.constraints:
                constraint_count += 1
                print(f"  {pb.name}: {const.type}")
    
    if constraint_count == 0:
        print(f"  (none)")
    
    # Diagnosis
    print(f"\n[DIAGNOSIS]")
    if has_def and has_mch and has_fk and has_ik:
        print(f"  ✅ PROPER RIGIFY RIG (Generated)")
        print(f"  → Can use for animation")
    elif has_ik and not has_def and not has_mch:
        print(f"  ⚠️  INCOMPLETE METARIG")
        print(f"  → Has manual IK constraints")
        print(f"  → Missing proper Rigify structure")
        print(f"  → NOT suitable for animation (like axion_metarig)")
    else:
        print(f"  ? UNKNOWN STRUCTURE")

print("\n" + "="*60 + "\n")
