"""
Walk Animation Script for axion_metarig
Creates a realistic walk cycle based on the motion reference
"""

import bpy
import math
from mathutils import Euler

def log(msg):
    print(msg)

def create_walk_animation():
    """Create walk animation for axion_metarig"""
    
    rig = bpy.data.objects.get("axion_metarig")
    if not rig:
        log("[!] axion_metarig not found")
        return False
    
    # Set to Pose mode
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode='POSE')
    
    # Create new action for walk cycle
    walk_action = bpy.data.actions.new("Walk_Cycle")
    rig.animation_data_create()
    rig.animation_data.action = walk_action
    
    # Walk cycle parameters
    cycle_frames = 48  # 48 frames for full cycle (2 steps)
    fps = bpy.context.scene.render.fps
    frame_rate = fps
    
    # Define walk cycle phases (in frame positions)
    # Total cycle: 48 frames
    # Phase 1 (0-24): Left leg forward, Right leg back
    # Phase 2 (24-48): Right leg forward, Left leg back
    
    phases = {
        # Left leg: CONTACT (0), DOWN (8), PASSING (16), UP (24)
        'L_contact': 0,
        'L_down': 8,
        'L_passing': 16,
        'L_up': 24,
        # Right leg: CONTACT (24), DOWN (32), PASSING (40), UP (48/0)
        'R_contact': 24,
        'R_down': 32,
        'R_passing': 40,
        'R_up': 8,  # Mirror of L_down
    }
    
    log("\n[WALK ANIMATION SETUP]")
    log(f"  Cycle frames: {cycle_frames}")
    log(f"  Animation action: {walk_action.name}")
    
    # ========== FRAME-BY-FRAME ANIMATION ==========
    
    try:
        # Clear existing keyframes
        for frame in range(cycle_frames):
            bpy.context.scene.frame_set(frame)
        
        # Define animation poses for each frame
        # Frame 0: Left leg contact, right leg passing back
        set_pose_frame(rig, 0, {
            'thigh.L': (10, -30, 0),      # Left: forward
            'shin.L': (-15, 0, 0),         # Knee bent
            'foot.L': (5, 0, 0),          # Foot angle
            
            'thigh.R': (-15, 30, 0),      # Right: back
            'shin.R': (10, 0, 0),         # Knee extended
            'foot.R': (-5, 0, 0),         # Foot angle
            
            'upper_arm.L': (-25, 0, 0),   # Left arm back
            'forearm.L': (20, 0, 0),      # Elbow bent
            
            'upper_arm.R': (25, 0, 0),    # Right arm forward
            'forearm.R': (-20, 0, 0),     # Elbow bent
        })
        
        # Frame 12: Left leg down-passing
        set_pose_frame(rig, 12, {
            'thigh.L': (0, 0, 0),         # Vertical
            'shin.L': (0, 0, 0),          # Straight
            'foot.L': (0, 0, 0),          # Flat
            
            'thigh.R': (-5, 15, 0),       # Right lifting back
            'shin.R': (5, 0, 0),          # Slightly bent
            'foot.R': (-10, 0, 0),        # Foot up
            
            'upper_arm.L': (-10, 0, 0),   # Left arm middle
            'forearm.L': (10, 0, 0),      
            
            'upper_arm.R': (10, 0, 0),    # Right arm middle
            'forearm.R': (-10, 0, 0),
        })
        
        # Frame 24: Right leg contact, left leg passing back
        set_pose_frame(rig, 24, {
            'thigh.L': (-15, -30, 0),     # Left: back
            'shin.L': (10, 0, 0),         # Knee extended
            'foot.L': (-5, 0, 0),         # Foot angle
            
            'thigh.R': (10, 30, 0),       # Right: forward
            'shin.R': (-15, 0, 0),        # Knee bent
            'foot.R': (5, 0, 0),          # Foot angle
            
            'upper_arm.L': (25, 0, 0),    # Left arm forward
            'forearm.L': (-20, 0, 0),     # Elbow bent
            
            'upper_arm.R': (-25, 0, 0),   # Right arm back
            'forearm.R': (20, 0, 0),      # Elbow bent
        })
        
        # Frame 36: Right leg down-passing
        set_pose_frame(rig, 36, {
            'thigh.R': (0, 0, 0),         # Vertical
            'shin.R': (0, 0, 0),          # Straight
            'foot.R': (0, 0, 0),          # Flat
            
            'thigh.L': (-5, -15, 0),      # Left lifting back
            'shin.L': (5, 0, 0),          # Slightly bent
            'foot.L': (10, 0, 0),         # Foot up
            
            'upper_arm.L': (10, 0, 0),    # Left arm middle
            'forearm.L': (-10, 0, 0),
            
            'upper_arm.R': (-10, 0, 0),   # Right arm middle
            'forearm.R': (10, 0, 0),
        })
        
        # Loop back to frame 0 at frame 48
        bpy.context.scene.frame_set(48)
        set_pose_frame(rig, 48, {
            'thigh.L': (10, -30, 0),
            'shin.L': (-15, 0, 0),
            'foot.L': (5, 0, 0),
            'thigh.R': (-15, 30, 0),
            'shin.R': (10, 0, 0),
            'foot.R': (-5, 0, 0),
            'upper_arm.L': (-25, 0, 0),
            'forearm.L': (20, 0, 0),
            'upper_arm.R': (25, 0, 0),
            'forearm.R': (-20, 0, 0),
        })
        
        log(f"\n[OK] Walk animation created!")
        log(f"  Total frames: {cycle_frames}")
        log(f"  Key poses: 0, 12, 24, 36, 48")
        
        # Return to Object mode
        bpy.ops.object.mode_set(mode='OBJECT')
        
        # Set scene animation range
        bpy.context.scene.frame_start = 0
        bpy.context.scene.frame_end = cycle_frames - 1
        
        log(f"\n[OK] Scene animation range: 0 - {cycle_frames - 1} frames")
        
        return True
        
    except Exception as e:
        log(f"[!] Error creating walk animation: {e}")
        try:
            bpy.ops.object.mode_set(mode='OBJECT')
        except:
            pass
        return False

def set_pose_frame(rig, frame, bone_rotations):
    """Set pose for specific frame with keyframes"""
    bpy.context.scene.frame_set(frame)
    
    for bone_name, (rot_x, rot_y, rot_z) in bone_rotations.items():
        bone = rig.pose.bones.get(bone_name)
        if not bone:
            continue
        
        # Convert degrees to radians
        rx = math.radians(rot_x)
        ry = math.radians(rot_y)
        rz = math.radians(rot_z)
        
        # Set rotation using Euler angles (XYZ)
        bone.rotation_euler = Euler((rx, ry, rz), 'XYZ')
        
        # Insert keyframe for rotation
        bone.keyframe_insert(data_path="rotation_euler")

# ============================================
# MAIN EXECUTION
# ============================================

print("\n" + "="*60)
print("WALK ANIMATION CREATOR FOR axion_metarig")
print("="*60)

if create_walk_animation():
    # Save the file
    try:
        bpy.ops.wm.save_mainfile()
        print("\n[OK] File saved successfully!")
    except Exception as e:
        print(f"\n[!] Failed to save file: {e}")
else:
    print("\n[!] Animation creation failed")

print("\n" + "="*60)
print("SETUP COMPLETE")
print("="*60)
print("\nTo see the animation:")
print("  1. Press SPACEBAR to play animation")
print("  2. Check Dope Sheet / Action Editor")
print("  3. Timeline shows animation frames")
print("\nTo adjust animation:")
print("  1. Select rig > Pose Mode")
print("  2. Edit individual bones in each frame")
print("  3. Insert/Update keyframes (I key)")
print("\n")
