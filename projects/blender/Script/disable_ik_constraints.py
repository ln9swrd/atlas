"""
Disable IK constraints to allow FK animation
"""

import bpy

print("\n" + "="*60)
print("DISABLING IK CONSTRAINTS (FK MODE)")
print("="*60)

rig = bpy.data.objects.get("axion_metarig")
if not rig:
    print("[!] axion_metarig not found")
else:
    disabled = 0
    
    for pb in rig.pose.bones:
        for c in pb.constraints:
            if c.type == 'IK':
                print(f"\n[{pb.name}] {c.name}")
                print(f"  Before: Mute={c.mute}, Influence={c.influence}")
                
                # Disable IK
                c.mute = True
                
                print(f"  After:  Mute={c.mute} ✓")
                disabled += 1
    
    print(f"\n[OK] Disabled {disabled} IK constraints")
    
    # Save
    try:
        bpy.ops.wm.save_mainfile()
        print("[OK] File saved!")
    except Exception as e:
        print(f"[!] Save failed: {e}")

print("\n" + "="*60)
print("Animation should now use FK (Forward Kinematics)")
print("IK control bones can still be used if needed")
print("="*60 + "\n")
