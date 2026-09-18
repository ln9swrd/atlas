"""
Check if axion_metarig has proper Rigify IK/FK structure
"""

import bpy

print("\n" + "="*60)
print("RIGIFY STRUCTURE ANALYSIS")
print("="*60)

rig = bpy.data.objects.get("axion_metarig")
if not rig:
    print("[!] axion_metarig not found")
else:
    print(f"\n[BONE STRUCTURE ANALYSIS]")
    print(f"Total bones: {len(rig.data.bones)}\n")
    
    # Check for proper Rigify bone structure
    bone_names = [b.name for b in rig.data.bones]
    
    # Look for IK/FK variants
    arm_variants = []
    leg_variants = []
    
    for name in bone_names:
        lower = name.lower()
        if 'arm' in lower or 'forearm' in lower or 'hand' in lower:
            arm_variants.append(name)
        if 'leg' in lower or 'thigh' in lower or 'shin' in lower or 'foot' in lower:
            leg_variants.append(name)
    
    print("[ARM BONES]")
    for b in sorted(arm_variants):
        print(f"  - {b}")
    
    print("\n[LEG BONES]")
    for b in sorted(leg_variants):
        print(f"  - {b}")
    
    # Check for Rigify's special bones
    print("\n[RIGIFY SPECIAL BONES (should exist)]")
    rigify_patterns = {
        'IK Chain': ['_ik.', '_ik_', '.ik_'],
        'FK Chain': ['_fk.', '_fk_', '.fk_'],
        'DEF (Deform)': ['def_', 'DEF_'],
        'MCH (Mechanism)': ['mch_', 'MCH_'],
        'CTL (Control)': ['ctrl_', 'CTL_', '_ctrl'],
    }
    
    found_patterns = {}
    for pattern_type, patterns in rigify_patterns.items():
        matches = []
        for bone_name in bone_names:
            if any(p in bone_name.lower() for p in patterns):
                matches.append(bone_name)
        
        if matches:
            found_patterns[pattern_type] = matches
            print(f"\n  [{pattern_type}] - Found {len(matches)}")
            for b in matches[:5]:
                print(f"    - {b}")
            if len(matches) > 5:
                print(f"    ... and {len(matches) - 5} more")
        else:
            print(f"\n  [{pattern_type}] - NOT FOUND ❌")
    
    # Final diagnosis
    print("\n" + "="*60)
    print("[DIAGNOSIS]")
    
    if not found_patterns.get('IK Chain') and not found_patterns.get('FK Chain'):
        print("❌ NO PROPER IK/FK STRUCTURE DETECTED")
        print("\nThis is a METARIG or DAMAGED RIG:")
        print("  - Has basic bones (thigh, shin, foot, etc.)")
        print("  - But missing IK/FK chains")
        print("  - IK constraints were added manually (not via Rigify)")
        print("\n✅ SOLUTION:")
        print("  1. Use 'axion_rig' (the generated rig) OR")
        print("  2. Restore from backup and re-run Rigify properly")
    else:
        print("✅ Has IK/FK structure")
        for ptype, bones in found_patterns.items():
            if bones:
                print(f"   - {ptype}: {len(bones)} bones")

print("\n" + "="*60)
