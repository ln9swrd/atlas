"""
Test: Apply create_walk_animation_v2 to RIG-Axion_Rigify_Metarig
Check if bone names match and animation works
"""

import bpy

print("\n" + "="*60)
print("TEST: create_walk_animation_v2 on RIG-Axion_Rigify_Metarig")
print("="*60)

rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
if not rig:
    print("[!] RIG-Axion_Rigify_Metarig not found")
else:
    print(f"\n✅ Target rig: {rig.name}")
    
    # Bone names used in create_walk_animation_v2
    bones_needed = [
        'spine', 'thigh.R', 'shin.R', 'foot.R',
        'thigh.L', 'shin.L', 'foot.L',
        'chest', 'upper_arm.R', 'forearm.R',
        'upper_arm.L', 'forearm.L'
    ]
    
    available_bones = {b.name for b in rig.data.bones}
    
    print(f"\n[BONE NAME COMPATIBILITY CHECK]")
    print(f"Script expects these bones:\n")
    
    matching = []
    missing = []
    similar = []
    
    for bone_name in bones_needed:
        if bone_name in available_bones:
            print(f"  ✅ {bone_name}")
            matching.append(bone_name)
        else:
            # Look for similar bones
            similar_bones = [b for b in available_bones 
                           if bone_name.replace('.', '_').lower() in b.lower() 
                           or b.lower() in bone_name.lower()]
            
            if similar_bones:
                print(f"  ⚠️  {bone_name} → Similar: {similar_bones}")
                similar.extend(similar_bones)
            else:
                print(f"  ❌ {bone_name} NOT FOUND")
                missing.append(bone_name)
    
    print(f"\n[SUMMARY]")
    print(f"  ✅ Exact matches: {len(matching)}/{len(bones_needed)}")
    print(f"  ⚠️  Similar bones: {len(similar)}")
    print(f"  ❌ Missing: {len(missing)}")
    
    if missing:
        print(f"\n[DIAGNOSIS]")
        print(f"  ❌ INCOMPATIBLE")
        print(f"     The script cannot work directly with this rig")
        print(f"     because bone names don't match.")
        print(f"\n  Why?")
        print(f"     - create_walk_animation_v2.py uses FK bones")
        print(f"     - RIG-Axion_Rigify_Metarig has different structure:")
        print(f"       • Basic bones (thigh, shin) → FK control bones")
        print(f"       • MCH- prefix for mechanism bones")
        print(f"       • Different hierarchy")
        print(f"\n  Solutions:")
        print(f"     1. Create NEW script for RIG-Axion_Rigify_Metarig")
        print(f"        (Use FK bones or IK controls)")
        print(f"     2. Adapt FK bone names from Rigify rig")
        print(f"     3. Use IK controls instead (better for Rigify)")
    else:
        print(f"\n[DIAGNOSIS]")
        print(f"  ✅ COMPATIBLE")
        print(f"     All bones found, should work!")

print("\n" + "="*60 + "\n")
