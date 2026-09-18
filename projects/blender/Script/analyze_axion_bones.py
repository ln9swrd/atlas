"""
Analyze axion_metarig bone structure for walk animation
"""

import bpy

print("\n" + "="*60)
print("AXION_METARIG BONE STRUCTURE")
print("="*60)

rig = bpy.data.objects.get("axion_metarig")
if not rig:
    print("[!] axion_metarig not found")
else:
    print(f"\nTotal bones: {len(rig.data.bones)}\n")
    
    # Organize bones by category
    categories = {
        'Spine/Core': [],
        'Left Arm': [],
        'Right Arm': [],
        'Left Leg': [],
        'Right Leg': [],
        'IK Controls': [],
        'Other': []
    }
    
    for bone in rig.data.bones:
        name = bone.name.lower()
        
        if any(x in name for x in ['spine', 'chest', 'shoulder', 'torso', 'body', 'armature']):
            categories['Spine/Core'].append(bone.name)
        elif '.l' in name or '_l' in name:
            if any(x in name for x in ['arm', 'hand', 'shoulder', 'palm', 'finger', 'thumb']):
                categories['Left Arm'].append(bone.name)
            else:
                categories['Left Leg'].append(bone.name)
        elif '.r' in name or '_r' in name:
            if any(x in name for x in ['arm', 'hand', 'shoulder', 'palm', 'finger', 'thumb']):
                categories['Right Arm'].append(bone.name)
            else:
                categories['Right Leg'].append(bone.name)
        elif any(x in name for x in ['ik', 'pole', 'ctrl', 'control']):
            categories['IK Controls'].append(bone.name)
        else:
            categories['Other'].append(bone.name)
    
    for category, bones in categories.items():
        if bones:
            print(f"[{category}]")
            for b in sorted(bones):
                print(f"  - {b}")
            print()

print("="*60)
