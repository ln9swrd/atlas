import bpy
import sys

print("\n--- TENTACLE PROPERTIES ---")

try:
    rig = bpy.data.objects.get("SuperRobotRig")
    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='POSE')
    
    pb = rig.pose.bones.get('upper_arm.L')
    if pb and hasattr(pb, 'rigify_parameters'):
        params = pb.rigify_parameters
        print("Parameters for upper_arm.L:")
        for k in params.keys():
            if not k.startswith('_'):
                val = getattr(params, k, None)
                print(f"  {k}: {val}")
        
except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)
