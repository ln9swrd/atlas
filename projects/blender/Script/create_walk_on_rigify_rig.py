"""
Create Walk Animation on axion_rig (proper Rigify rig)
Uses IK control bones for walk cycle
"""

import bpy
import math
from mathutils import Euler

def log(msg):
    print(msg)

def create_walk_on_rigify_rig():
    """Create walk animation on axion_rig using IK controls"""
    
    rig = bpy.data.objects.get("axion_rig")
    if not rig:
        log("[!] axion_rig not found")
        return False
    
    log("\n[WALK ANIMATION ON axion_rig]")
    log(f"  Rig: {rig.name}")
    log(f"  Bones: {len(rig.data.bones)}")
    
    # Set to Pose mode
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode='POSE')
    
    # Create or get Walk action
    if "Walk_Cycle" in bpy.data.actions:
        walk_action = bpy.data.actions["Walk_Cycle"]
        log(f"  Using existing Walk_Cycle action")
    else:
        walk_action = bpy.data.actions.new("Walk_Cycle")
        log(f"  Created new Walk_Cycle action")
    
    rig.animation_data_create()
    rig.animation_data.action = walk_action
    
    cycle_frames = 48
    
    try:
        # Find root and IK control bones
        root = None
        foot_ik_l = None
        foot_ik_r = None
        
        for pb in rig.pose.bones:
            if pb.name == "root":
                root = pb
            elif "foot" in pb.name.lower() and "ik" in pb.name.lower() and ".l" in pb.name.lower():
                foot_ik_l = pb
            elif "foot" in pb.name.lower() and "ik" in pb.name.lower() and ".r" in pb.name.lower():
                foot_ik_r = pb
        
        if not root:
            log("[!] root bone not found")
            return False
        
        if not (foot_ik_l and foot_ik_r):
            log("[!] IK foot controls not found")
            return False
        
        log(f"  Found: root, foot_ik.L, foot_ik.R")
        
        # ========== WALK CYCLE ==========
        
        # Frame 0: Right foot forward
        bpy.context.scene.frame_set(0)
        root.location.y = -2.0  # Start position
        root.keyframe_insert(data_path="location")
        foot_ik_r.location.y = 1.0  # Right foot forward
        foot_ik_r.keyframe_insert(data_path="location")
        foot_ik_l.location.y = -1.0  # Left foot back
        foot_ik_l.keyframe_insert(data_path="location")
        log("  Frame 0: Right foot forward")
        
        # Frame 12: Mid cycle
        bpy.context.scene.frame_set(12)
        root.location.y = -1.0
        root.keyframe_insert(data_path="location")
        foot_ik_r.location.y = 0.0  # Neutral
        foot_ik_r.keyframe_insert(data_path="location")
        foot_ik_l.location.y = -2.0  # Left swinging
        foot_ik_l.keyframe_insert(data_path="location")
        log("  Frame 12: Mid swing")
        
        # Frame 24: Left foot forward
        bpy.context.scene.frame_set(24)
        root.location.y = 0.0  # Middle
        root.keyframe_insert(data_path="location")
        foot_ik_r.location.y = -1.0  # Right foot back
        foot_ik_r.keyframe_insert(data_path="location")
        foot_ik_l.location.y = 1.0  # Left foot forward
        foot_ik_l.keyframe_insert(data_path="location")
        log("  Frame 24: Left foot forward")
        
        # Frame 36: Mid cycle 2
        bpy.context.scene.frame_set(36)
        root.location.y = 1.0
        root.keyframe_insert(data_path="location")
        foot_ik_r.location.y = -2.0  # Right swinging
        foot_ik_r.keyframe_insert(data_path="location")
        foot_ik_l.location.y = 0.0  # Neutral
        foot_ik_l.keyframe_insert(data_path="location")
        log("  Frame 36: Mid swing")
        
        # Frame 48: Loop back
        bpy.context.scene.frame_set(48)
        root.location.y = -2.0
        root.keyframe_insert(data_path="location")
        foot_ik_r.location.y = 1.0
        foot_ik_r.keyframe_insert(data_path="location")
        foot_ik_l.location.y = -1.0
        foot_ik_l.keyframe_insert(data_path="location")
        log("  Frame 48: Cycle complete")
        
        # Return to Object mode
        bpy.ops.object.mode_set(mode='OBJECT')
        
        # Set scene animation range
        bpy.context.scene.frame_start = 0
        bpy.context.scene.frame_end = cycle_frames - 1
        
        log(f"\n✅ Walk animation created!")
        log(f"   Total frames: {cycle_frames}")
        log(f"   Mode: IK control-based (proper Rigify)")
        
        return True
        
    except Exception as e:
        log(f"[!] Error: {e}")
        import traceback
        traceback.print_exc()
        try:
            bpy.ops.object.mode_set(mode='OBJECT')
        except:
            pass
        return False

# ============================================
# MAIN EXECUTION
# ============================================

print("\n" + "="*60)
print("CREATE WALK ANIMATION ON axion_rig")
print("="*60)

if create_walk_on_rigify_rig():
    try:
        bpy.ops.wm.save_mainfile()
        print("\n[OK] File saved!")
    except Exception as e:
        print(f"\n[!] Save failed: {e}")
else:
    print("\n[!] Animation creation failed")

print("\n" + "="*60)
print("To use:")
print("  1. Select axion_rig (NOT axion_metarig)")
print("  2. Play animation (SPACEBAR)")
print("  3. Mesh should deform correctly with DEF bones")
print("="*60 + "\n")
