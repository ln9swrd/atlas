"""
Check axion_rig structure (the generated rig)
"""

import bpy

print("\n" + "="*60)
print("CHECKING axion_rig (Generated Rig)")
print("="*60)

rig = bpy.data.objects.get("axion_rig")
if not rig:
    print("[!] axion_rig not found")
else:
    print(f"\n✅ Found: axion_rig")
    print(f"   Total bones: {len(rig.data.bones)}")
    
    bone_names = [b.name for b in rig.data.bones]
    
    # Check for Rigify structure
    has_def = any('def' in b.lower() for b in bone_names)
    has_mch = any('mch' in b.lower() for b in bone_names)
    has_ik = any('ik' in b.lower() for b in bone_names)
    has_fk = any('fk' in b.lower() for b in bone_names)
    has_ctrl = any('ctrl' in b.lower() for b in bone_names)
    
    print(f"\n[Structure Check]")
    print(f"  DEF bones (deform):      {'✅' if has_def else '❌'}")
    print(f"  MCH bones (mechanism):   {'✅' if has_mch else '❌'}")
    print(f"  IK bones:                {'✅' if has_ik else '❌'}")
    print(f"  FK bones:                {'✅' if has_fk else '❌'}")
    print(f"  CTL bones (control):     {'✅' if has_ctrl else '❌'}")
    
    if has_def and has_mch and has_fk and has_ik:
        print(f"\n🎉 axion_rig is a PROPER RIGIFY RIG!")
        print(f"   This should have full IK/FK capabilities")
    
    # Sample bones
    print(f"\n[Sample Bones]")
    print(f"  First 10: {bone_names[:10]}")
    
    # Check for animation
    if rig.animation_data and rig.animation_data.action:
        print(f"\n[Animation]")
        print(f"  Action: {rig.animation_data.action.name}")
    else:
        print(f"\n[Animation]")
        print(f"  No animation found")

print("\n" + "="*60)
