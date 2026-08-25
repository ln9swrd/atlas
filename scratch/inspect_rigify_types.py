import bpy
import sys

print("\n--- AVAILABLE RIGIFY TYPES ---")

try:
    import rigify
    from rigify import utils
    from rigify.utils import rig
    
    # Try getting them from rigify module
    if hasattr(rigify, 'rig_lists'):
        print(f"Rig types: {list(rigify.rig_lists.rigs.keys())}")
    else:
        # Another way
        import imp
        try:
            from rigify.generate import rig_lists
            print(f"Rig types: {list(rig_lists.rigs.keys())}")
        except Exception as e:
            print(f"Could not load rig_lists: {e}")
            
except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)
