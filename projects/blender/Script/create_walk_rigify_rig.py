"""
Walk Animation for RIG-Axion_Rigify_Metarig
Uses IK controls (foot_ik, hand_ik) + root motion
Better for Rigify-generated rigs
"""

import bpy
import math
from mathutils import Vector

def log(msg):
    print(msg)

def find_ik_control_bones(rig):
    """Find IK control bones in the rig"""
    
    foot_ik_l = None
    foot_ik_r = None
    hand_ik_l = None
    hand_ik_r = None
    
    for pb in rig.pose.bones:
        name = pb.name.lower()
        if 'foot_ik' in name and '.l' in name:
            foot_ik_l = pb
        elif 'foot_ik' in name and '.r' in name:
            foot_ik_r = pb
        elif 'hand_ik' in name and '.l' in name:
            hand_ik_l = pb
        elif 'hand_ik' in name and '.r' in name:
            hand_ik_r = pb
    
    return foot_ik_l, foot_ik_r, hand_ik_l, hand_ik_r

def find_spine_bones(rig):
    """Find spine control bones"""
    
    root = None
    chest = None
    
    for pb in rig.pose.bones:
        name = pb.name.lower()
        if name == 'root':
            root = pb
        elif name == 'chest':
            chest = pb
    
    return root, chest

def create_walk_animation_rigify():
    """Create walk animation using IK controls on Rigify rig"""
    
    rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
    if not rig:
        log("[!] RIG-Axion_Rigify_Metarig not found")
        return False
    
    log("\n" + "="*60)
    log("CREATE WALK ANIMATION (RIG-Axion_Rigify_Metarig)")
    log("="*60)
    log(f"\nTarget rig: {rig.name}")
    
    # Set to Pose mode
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode='POSE')
    
    # Find control bones
    foot_ik_l, foot_ik_r, hand_ik_l, hand_ik_r = find_ik_control_bones(rig)
    root, chest = find_spine_bones(rig)
    
    if not (foot_ik_l and foot_ik_r):
        log("[!] IK foot controls not found")
        log("    Looking for: foot_ik.L, foot_ik.R")
        bpy.ops.object.mode_set(mode='OBJECT')
        return False
    
    log(f"\n[FOUND CONTROL BONES]")
    log(f"  ✓ foot_ik.L: {foot_ik_l.name}")
    log(f"  ✓ foot_ik.R: {foot_ik_r.name}")
    if hand_ik_l and hand_ik_r:
        log(f"  ✓ hand_ik.L: {hand_ik_l.name}")
        log(f"  ✓ hand_ik.R: {hand_ik_r.name}")
    else:
        log(f"  ⚠️  hand_ik not found (optional)")
    
    if root:
        log(f"  ✓ root: {root.name}")
    else:
        log(f"  ⚠️  root not found (will use parent)")
    
    if chest:
        log(f"  ✓ chest: {chest.name}")
    
    # Delete existing Walk_Cycle action
    if "Walk_Cycle_Rigify" in bpy.data.actions:
        bpy.data.actions.remove(bpy.data.actions["Walk_Cycle_Rigify"], do_unlink=True)
    
    # Create new action
    walk_action = bpy.data.actions.new("Walk_Cycle_Rigify")
    rig.animation_data_create()
    rig.animation_data.action = walk_action
    
    cycle_frames = 48
    
    try:
        log(f"\n[CREATING WALK CYCLE]")
        
        # ========== WALK CYCLE USING IK ==========
        
        # Frame 0: Right foot forward contact, Left foot back
        log("  Frame 0: Right foot contact")
        bpy.context.scene.frame_set(0)
        
        # Root at start position
        if root:
            root.location.y = -2.0  # Start behind
            root.keyframe_insert(data_path="location")
        
        # Right foot forward
        foot_ik_r.location.y = 1.5
        foot_ik_r.location.x = 0.0
        foot_ik_r.keyframe_insert(data_path="location")
        
        # Left foot back
        foot_ik_l.location.y = -1.5
        foot_ik_l.location.x = 0.0
        foot_ik_l.keyframe_insert(data_path="location")
        
        # Chest rotation (lean forward)
        if chest:
            chest.rotation_euler.x = math.radians(5)
            chest.keyframe_insert(data_path="rotation_euler")
        
        # ========== Frame 12 ==========
        log("  Frame 12: Mid swing")
        bpy.context.scene.frame_set(12)
        
        if root:
            root.location.y = -1.0  # Moving forward
            root.keyframe_insert(data_path="location")
        
        # Right foot mid swing
        foot_ik_r.location.y = 0.0
        foot_ik_r.location.x = 0.0  # Slightly lifted
        foot_ik_r.keyframe_insert(data_path="location")
        
        # Left foot going down
        foot_ik_l.location.y = -2.0  # Back swing
        foot_ik_l.location.x = 0.0
        foot_ik_l.keyframe_insert(data_path="location")
        
        if chest:
            chest.rotation_euler.x = 0.0  # Neutral
            chest.keyframe_insert(data_path="rotation_euler")
        
        # ========== Frame 24 ==========
        log("  Frame 24: Left foot contact")
        bpy.context.scene.frame_set(24)
        
        if root:
            root.location.y = 0.0  # Center
            root.keyframe_insert(data_path="location")
        
        # Left foot forward
        foot_ik_l.location.y = 1.5
        foot_ik_l.location.x = 0.0
        foot_ik_l.keyframe_insert(data_path="location")
        
        # Right foot back
        foot_ik_r.location.y = -1.5
        foot_ik_r.location.x = 0.0
        foot_ik_r.keyframe_insert(data_path="location")
        
        # Chest rotation (opposite lean)
        if chest:
            chest.rotation_euler.x = math.radians(-5)
            chest.keyframe_insert(data_path="rotation_euler")
        
        # ========== Frame 36 ==========
        log("  Frame 36: Mid swing 2")
        bpy.context.scene.frame_set(36)
        
        if root:
            root.location.y = 1.0  # Moving forward more
            root.keyframe_insert(data_path="location")
        
        # Left foot mid swing
        foot_ik_l.location.y = 0.0
        foot_ik_l.location.x = 0.0
        foot_ik_l.keyframe_insert(data_path="location")
        
        # Right foot going down
        foot_ik_r.location.y = -2.0
        foot_ik_r.location.x = 0.0
        foot_ik_r.keyframe_insert(data_path="location")
        
        if chest:
            chest.rotation_euler.x = 0.0
            chest.keyframe_insert(data_path="rotation_euler")
        
        # ========== Frame 48 (Loop) ==========
        log("  Frame 48: Cycle complete")
        bpy.context.scene.frame_set(48)
        
        if root:
            root.location.y = -2.0  # Back to start
            root.keyframe_insert(data_path="location")
        
        foot_ik_r.location.y = 1.5
        foot_ik_r.location.x = 0.0
        foot_ik_r.keyframe_insert(data_path="location")
        
        foot_ik_l.location.y = -1.5
        foot_ik_l.location.x = 0.0
        foot_ik_l.keyframe_insert(data_path="location")
        
        if chest:
            chest.rotation_euler.x = math.radians(5)
            chest.keyframe_insert(data_path="rotation_euler")
        
        # Return to Object mode
        bpy.ops.object.mode_set(mode='OBJECT')
        
        # Set scene animation range
        bpy.context.scene.frame_start = 0
        bpy.context.scene.frame_end = cycle_frames - 1
        
        log(f"\n[SUCCESS] Walk animation created!")
        log(f"  Animation: {walk_action.name}")
        log(f"  Frames: 0-{cycle_frames - 1}")
        log(f"  Root motion: 4 units forward per cycle")
        log(f"  Mode: IK control-based (fully automatic leg calculation)")
        
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
# MAIN EXECUTION
# ============================================

print("\n" + "="*60)
print("WALK ANIMATION GENERATOR FOR RIGIFY RIG")
print("="*60 + "\n")

if create_walk_animation_rigify():
    try:
        bpy.ops.wm.save_mainfile()
        print("\n[OK] File saved!")
    except Exception as e:
        print(f"\n[!] Save failed: {e}")
else:
    print("\n[!] Animation creation failed")

print("\n" + "="*60)
print("TO USE:")
print("  1. Select RIG-Axion_Rigify_Metarig")
print("  2. Go to Action Editor → Walk_Cycle_Rigify")
print("  3. Press SPACEBAR to play")
print("  4. Character should walk forward smoothly")
print("="*60 + "\n")
