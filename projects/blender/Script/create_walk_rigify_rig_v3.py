"""
Walk Animation for RIG-Axion_Rigify_Metarig - V3 (Direct API)
Uses direct animation curve manipulation instead of keyframe_insert
"""

import bpy
import math

def log(msg):
    print(msg)

def create_walk_animation_direct():
    """Create walk animation using direct curve API"""
    
    rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
    if not rig:
        log("[!] RIG-Axion_Rigify_Metarig not found")
        return False
    
    log("\n" + "="*60)
    log("CREATE WALK ANIMATION (Direct Curve API)")
    log("="*60)
    
    # Delete old action
    action_name = "Walk_Cycle_Rigify"
    if action_name in bpy.data.actions:
        bpy.data.actions.remove(bpy.data.actions[action_name], do_unlink=True)
    
    # Create new action
    action = bpy.data.actions.new(action_name)
    log(f"Created action: {action.name}")
    
    # Assign to rig
    if not rig.animation_data:
        rig.animation_data_create()
    rig.animation_data.action = action
    
    # Animation data
    keyframes = {
        0: {
            'root.location.y': -2.0,
            'foot_ik.R.location.y': 1.5,
            'foot_ik.R.location.x': 0.0,
            'foot_ik.L.location.y': -1.5,
            'foot_ik.L.location.x': 0.0,
            'chest.rotation_euler.x': math.radians(5),
        },
        12: {
            'root.location.y': -1.0,
            'foot_ik.R.location.y': 0.0,
            'foot_ik.R.location.x': 0.0,
            'foot_ik.L.location.y': -2.0,
            'foot_ik.L.location.x': 0.0,
            'chest.rotation_euler.x': 0.0,
        },
        24: {
            'root.location.y': 0.0,
            'foot_ik.L.location.y': 1.5,
            'foot_ik.L.location.x': 0.0,
            'foot_ik.R.location.y': -1.5,
            'foot_ik.R.location.x': 0.0,
            'chest.rotation_euler.x': math.radians(-5),
        },
        36: {
            'root.location.y': 1.0,
            'foot_ik.L.location.y': 0.0,
            'foot_ik.L.location.x': 0.0,
            'foot_ik.R.location.y': -2.0,
            'foot_ik.R.location.x': 0.0,
            'chest.rotation_euler.x': 0.0,
        },
        48: {
            'root.location.y': -2.0,
            'foot_ik.R.location.y': 1.5,
            'foot_ik.R.location.x': 0.0,
            'foot_ik.L.location.y': -1.5,
            'foot_ik.L.location.x': 0.0,
            'chest.rotation_euler.x': math.radians(5),
        },
    }
    
    try:
        log(f"\n[CREATING KEYFRAMES]")
        
        # Create curves and insert keyframes
        curves_created = 0
        total_keyframes = 0
        
        for frame, data in keyframes.items():
            for data_path, value in data.items():
                # Get or create curve
                curve = None
                for fcurve in action.curves:
                    if fcurve.data_path == data_path:
                        curve = fcurve
                        break
                
                if curve is None:
                    curve = action.fcurves.new(data_path, index=0)
                    curves_created += 1
                
                # Add keyframe
                curve.keyframe_points.insert(frame, value, options={'FAST'})
                total_keyframes += 1
        
        log(f"  ✓ Created {curves_created} curves")
        log(f"  ✓ Inserted {total_keyframes} keyframes")
        
        # Set frame range
        bpy.context.scene.frame_start = 0
        bpy.context.scene.frame_end = 47
        
        log(f"\n✅ SUCCESS!")
        log(f"  Curves: {len(action.curves)}")
        log(f"  Total keyframes: {total_keyframes}")
        
        return True
        
    except Exception as e:
        log(f"\n[!] Error: {e}")
        import traceback
        traceback.print_exc()
        return False

# ============================================
# MAIN
# ============================================

print("\n" + "="*60)
print("WALK ANIMATION - DIRECT API v3")
print("="*60 + "\n")

if create_walk_animation_direct():
    try:
        bpy.ops.wm.save_mainfile()
        print("\n✅ File saved!")
    except Exception as e:
        print(f"\n[!] Save failed: {e}")
else:
    print("\n[!] Animation creation failed")

print("\n" + "="*60)
