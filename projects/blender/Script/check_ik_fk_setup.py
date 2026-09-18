"""
Detailed IK/FK configuration check for RIG-Axion_Rigify_Metarig
"""

import bpy

print("\n" + "="*60)
print("IK/FK CONFIGURATION CHECK")
print("RIG-Axion_Rigify_Metarig")
print("="*60)

rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
if not rig:
    print("[!] RIG-Axion_Rigify_Metarig not found")
else:
    print(f"\n✅ Found: {rig.name}")
    
    # Enter pose mode
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode='POSE')
    
    print(f"\n[IK CONSTRAINTS ANALYSIS]")
    print("Looking for IK constraints on limbs...\n")
    
    ik_found = {}
    for pb in rig.pose.bones:
        for constraint in pb.constraints:
            if constraint.type == 'IK':
                limb_name = pb.name
                target = constraint.target if hasattr(constraint, 'target') else "N/A"
                pole = constraint.pole_target if hasattr(constraint, 'pole_target') else "N/A"
                chain = constraint.chain_count if hasattr(constraint, 'chain_count') else 0
                influence = constraint.influence if hasattr(constraint, 'influence') else 0
                
                if limb_name not in ik_found:
                    ik_found[limb_name] = []
                
                ik_found[limb_name].append({
                    'target': target.name if target else "None",
                    'pole': pole.name if pole else "None",
                    'chain': chain,
                    'influence': influence
                })
    
    if ik_found:
        for limb, constraints in ik_found.items():
            print(f"  {limb}:")
            for c in constraints:
                print(f"    Target: {c['target']}")
                print(f"    Pole: {c['pole']}")
                print(f"    Chain: {c['chain']} bones")
                print(f"    Influence: {c['influence']:.2f}")
    else:
        print("  [!] No IK constraints found")
    
    # FK chain check
    print(f"\n[FK CHAIN ANALYSIS]")
    print("Looking for FK bones...\n")
    
    fk_bones = [b.name for b in rig.data.bones if 'fk' in b.name.lower()]
    if fk_bones:
        print(f"  Found {len(fk_bones)} FK bones:")
        for bone in sorted(fk_bones)[:15]:  # First 15
            print(f"    ✓ {bone}")
        if len(fk_bones) > 15:
            print(f"    ... and {len(fk_bones) - 15} more")
    else:
        print("  [!] No FK bones found")
    
    # Check for IK/FK switching mechanism
    print(f"\n[IK/FK SWITCHING CHECK]")
    
    # Look for custom properties that might control IK/FK
    print("Looking for IK/FK control properties...\n")
    
    switching_found = False
    for pb in rig.pose.bones:
        # Check for custom properties like "IK_FK" or similar
        if "IK_FK" in pb.keys() or "ik_fk" in pb.keys() or "IK" in pb.keys():
            print(f"  {pb.name}:")
            for key in pb.keys():
                if 'ik' in key.lower() or 'fk' in key.lower():
                    print(f"    {key} = {pb[key]}")
                    switching_found = True
    
    if not switching_found:
        print("  [⚠️  ] No explicit IK/FK switching properties found")
        print("         (Constraints may be auto-managed)")
    
    # Check for IK/FK influence controls
    print(f"\n[INFLUENCE CONTROL CHECK]")
    print("Checking constraint influences...\n")
    
    influences = {}
    for pb in rig.pose.bones:
        for constraint in pb.constraints:
            if constraint.type in ['IK', 'COPY_TRANSFORMS', 'COPY_ROTATION']:
                const_type = constraint.type
                influence = constraint.influence
                
                if const_type not in influences:
                    influences[const_type] = []
                influences[const_type].append((pb.name, influence))
    
    for const_type, data in influences.items():
        print(f"  {const_type}:")
        # Show some examples
        for bone_name, inf in data[:5]:
            status = "✅ Active" if inf > 0.5 else "⚠️  Partial" if inf > 0 else "❌ Inactive"
            print(f"    {bone_name}: {inf:.2f} {status}")
        if len(data) > 5:
            print(f"    ... ({len(data) - 5} more)")
    
    # Overall diagnosis
    print(f"\n[DIAGNOSIS]")
    
    has_ik = len(ik_found) > 0
    has_fk = len(fk_bones) > 0
    
    if has_ik and has_fk:
        print(f"  ✅ PROPER IK/FK SETUP")
        print(f"     - IK chains: {len(ik_found)} limbs")
        print(f"     - FK chains: {len(fk_bones)} bones")
        print(f"     → Ready for animation!")
    elif has_ik:
        print(f"  ⚠️  PARTIAL SETUP (IK only)")
        print(f"     - IK chains: {len(ik_found)} limbs")
        print(f"     - FK chains: MISSING")
    elif has_fk:
        print(f"  ⚠️  PARTIAL SETUP (FK only)")
        print(f"     - FK chains: {len(fk_bones)} bones")
        print(f"     - IK chains: MISSING")
    else:
        print(f"  ❌ NO IK/FK SETUP FOUND")
    
    bpy.ops.object.mode_set(mode='OBJECT')

print("\n" + "="*60 + "\n")
