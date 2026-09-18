import bpy

def check_heel_bones():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    print("\n=== HEEL BONE INSPECTION ===")
    for b in arm.pose.bones:
        if 'heel' in b.name.lower():
            print(f"Found Bone: {b.name}")
            print(f"  Parent: {b.parent.name if b.parent else 'None'}")
            print(f"  Constraints:")
            for c in b.constraints:
                print(f"    - {c.name} ({c.type})")
            print(f"  Location: {b.location}")
            
if __name__ == "__main__":
    check_heel_bones()
