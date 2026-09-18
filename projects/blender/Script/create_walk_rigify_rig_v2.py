"""
Walk Animation for RIG-Axion_Rigify_Metarig - V2 (Fixed)
Uses IK controls (foot_ik, hand_ik) + root motion
With proper context and error handling
"""

import bpy
import math

def log(msg):
    print(msg)

def create_walk_animation_rigify_fixed():
    """Create walk animation using IK controls on Rigify rig"""
    
    rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
    if not rig:
        log("[!] RIG-Axion_Rigify_Metarig not found")
        return False
    
    log("\n" + "="*60)
    log("CREATE WALK ANIMATION (RIG-Axion_Rigify_Metarig) - V2")
    log("="*60)
    log(f"\nTarget rig: {rig.name}")
    
    # ===== CRITICAL: Proper context setup =====
    # Make sure rig is selected and active
    for obj in bpy.data.objects:
        obj.select_set(False)
    
    rig.select_set(True)
    bpy.context.view_layer.objects.active = rig
    
    # Enter Pose mode
    try:
        bpy.ops.object.mode_set(mode='POSE')
    except Exception as e:
        log(f"[!] Failed to enter pose mode: {e}")
        return False
    
    # Create or get action
    action_name = "Walk_Cycle_Rigify"
    if action_name in bpy.data.actions:
        bpy.data.actions.remove(bpy.data.actions[action_name], do_unlink=True)
        log(f"  Removed old action: {action_name}")
    
    action = bpy.data.actions.new(action_name)
    log(f"  Created new action: {action.name}")
    
    # Assign action to rig
    if not rig.animation_data:
        rig.animation_data_create()
    rig.animation_data.action = action
    log(f"  Action assigned to rig")
    
    # Set frame range
    bpy.context.scene.frame_start = 0
    bpy.context.scene.frame_end = 47
    bpy.context.scene.frame_current = 0
    
    cycle_frames = 48
    
    try:
        log(f"\n[CREATING WALK CYCLE]")
        
        # Find bones
        root = rig.pose.bones.get("root")
        foot_ik_l = rig.pose.bones.get("foot_ik.L")
        foot_ik_r = rig.pose.bones.get("foot_ik.R")
        chest = rig.pose.bones.get("chest")
        
        if not (root and foot_ik_l and foot_ik_r):
            log("[!] Required bones not found")
            return False
        
        log(f"  Found: root, foot_ik.L, foot_ik.R, chest")
        
        # ===== FRAME 0 =====
        log("  Frame 0: Right foot contact")
        bpy.context.scene.frame_current = 0
        
        root.location.y = -2.0
        root.keyframe_insert("location", frame=0)
        log(f"    ✓ root location")
        
        foot_ik_r.location.y = 1.5
        foot_ik_r.location.x = 0.0
        foot_ik_r.keyframe_insert("location", frame=0)
        log(f"    ✓ foot_ik.R location")
        
        foot_ik_l.location.y = -1.5
        foot_ik_l.location.x = 0.0
        foot_ik_l.keyframe_insert("location", frame=0)
        log(f"    ✓ foot_ik.L location")
        
        if chest:
            chest.rotation_euler.x = math.radians(5)
            chest.keyframe_insert("rotation_euler", frame=0)
            log(f"    ✓ chest rotation")
        
        # ===== FRAME 12 =====
        log("  Frame 12: Mid swing")
        bpy.context.scene.frame_current = 12
        
        root.location.y = -1.0
        root.keyframe_insert("location", frame=12)
        
        foot_ik_r.location.y = 0.0
        foot_ik_r.location.x = 0.0
        foot_ik_r.keyframe_insert("location", frame=12)
        
        foot_ik_l.location.y = -2.0
        foot_ik_l.location.x = 0.0
        foot_ik_l.keyframe_insert("location", frame=12)
        
        if chest:
            chest.rotation_euler.x = 0.0
            chest.keyframe_insert("rotation_euler", frame=12)
        
        # ===== FRAME 24 =====
        log("  Frame 24: Left foot contact")
        bpy.context.scene.frame_current = 24
        
        root.location.y = 0.0
        root.keyframe_insert("location", frame=24)
        
        foot_ik_l.location.y = 1.5
        foot_ik_l.location.x = 0.0
        foot_ik_l.keyframe_insert("location", frame=24)
        
        foot_ik_r.location.y = -1.5
        foot_ik_r.location.x = 0.0
        foot_ik_r.keyframe_insert("location", frame=24)
        
        if chest:
            chest.rotation_euler.x = math.radians(-5)
            chest.keyframe_insert("rotation_euler", frame=24)
        
        # ===== FRAME 36 =====
        log("  Frame 36: Mid swing 2")
        bpy.context.scene.frame_current = 36
        
        root.location.y = 1.0
        root.keyframe_insert("location", frame=36)
        
        foot_ik_l.location.y = 0.0
        foot_ik_l.location.x = 0.0
        foot_ik_l.keyframe_insert("location", frame=36)
        
        foot_ik_r.location.y = -2.0
        foot_ik_r.location.x = 0.0
        foot_ik_r.keyframe_insert("location", frame=36)
        
        if chest:
            chest.rotation_euler.x = 0.0
            chest.keyframe_insert("rotation_euler", frame=36)
        
        # ===== FRAME 48 (Loop) =====
        log("  Frame 48: Cycle complete")
        bpy.context.scene.frame_current = 48
        
        root.location.y = -2.0
        root.keyframe_insert("location", frame=48)
        
        foot_ik_r.location.y = 1.5
        foot_ik_r.location.x = 0.0
        foot_ik_r.keyframe_insert("location", frame=48)
        
        foot_ik_l.location.y = -1.5
        foot_ik_l.location.x = 0.0
        foot_ik_l.keyframe_insert("location", frame=48)
        
        if chest:
            chest.rotation_euler.x = math.radians(5)
            chest.keyframe_insert("rotation_euler", frame=48)
        
        # Return to Object mode
        bpy.ops.object.mode_set(mode='OBJECT')
        log(f"\n  ✓ Exited pose mode")
        
        log(f"\n✅ SUCCESS!")
        log(f"  Action: {action.name}")
        log(f"  Frames: 0-47")
        log(f"  Root motion: 4 units forward")
        
        return True
        
    except Exception as e:
        log(f"\n[!] Error: {e}")
        import traceback
        traceback.print_exc()
        try:
            bpy.ops.object.mode_set(mode='OBJECT')
        except:
            pass
        return False

# ============================================
# MAIN
# ============================================

print("\n" + "="*60)
print("WALK ANIMATION GENERATOR v2")
print("="*60 + "\n")

if create_walk_animation_rigify_fixed():
    try:
        bpy.ops.wm.save_mainfile()
        print("\n✅ File saved!")
    except Exception as e:
        print(f"\n[!] Save failed: {e}")
else:
    print("\n[!] Animation creation failed")

print("\n" + "="*60)
print("RESULT:")
print("  Walk_Cycle_Rigify should now have keyframes")
print("  Open Blender → Timeline → Press SPACEBAR to play")
print("="*60 + "\n")
