"""
Improved Walk Animation for axion_metarig
Moves root (spine) forward while legs cycle
"""

import bpy
import math
from mathutils import Euler, Vector

def log(msg):
    print(msg)

def create_proper_walk_animation():
    """Create realistic walk animation with root motion"""
    
    rig = bpy.data.objects.get("axion_metarig")
    if not rig:
        log("[!] axion_metarig not found")
        return False
    
    # Find root bone
    root_bone = None
    for b in rig.data.bones:
        if b.name == "spine":
            root_bone = "spine"
            break
    
    if not root_bone:
        log("[!] spine (root) not found")
        return False
    
    log(f"\n[WALK ANIMATION SETUP]")
    log(f"  Root bone: {root_bone}")
    
    # Set to Pose mode
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode='POSE')
    
    # Delete existing Walk_Cycle action
    if "Walk_Cycle" in bpy.data.actions:
        bpy.data.actions.remove(bpy.data.actions["Walk_Cycle"], do_unlink=True)
    
    # Create new action
    walk_action = bpy.data.actions.new("Walk_Cycle_v2")
    rig.animation_data_create()
    rig.animation_data.action = walk_action
    
    cycle_frames = 48
    
    try:
        # ========== WALK CYCLE ==========
        # Frame 0: Right foot forward contact
        log(f"\n[CREATING KEY POSES]")
        set_walk_frame(rig, 0, {
            'root_forward': -2.0,      # Root at start
            'root_height': 0.0,
            
            # Right leg forward (contact)
            'thigh.R': (15, 30, 0),      # Forward
            'shin.R': (-20, 0, 0),       # Knee bent
            'foot.R': (5, 0, 0),
            
            # Left leg back
            'thigh.L': (-5, -30, 0),     # Back
            'shin.L': (5, 0, 0),         # Extended
            'foot.L': (-5, 0, 0),
            
            # Torso lean
            'chest': (5, 0, 0),          # Lean forward
            
            # Arms opposite legs
            'upper_arm.R': (-20, 0, 0),  # Right arm back
            'forearm.R': (15, 0, 0),
            'upper_arm.L': (20, 0, 0),   # Left arm forward
            'forearm.L': (-15, 0, 0),
        })
        log("  Frame 0: Right foot contact")
        
        # Frame 12: Mid cycle - root moving forward
        set_walk_frame(rig, 12, {
            'root_forward': -1.0,       # Moving forward
            'root_height': 0.1,         # Slight lift
            
            'thigh.R': (0, 15, 0),      # Right: mid swing
            'shin.R': (0, 0, 0),        # Knee straight
            'foot.R': (0, 0, 0),
            
            'thigh.L': (-15, -15, 0),   # Left: down
            'shin.L': (-5, 0, 0),       # Knee bent down
            'foot.L': (10, 0, 0),       # Foot preparing to leave ground
            
            'chest': (0, 0, 0),
            
            'upper_arm.R': (0, 0, 0),
            'forearm.R': (0, 0, 0),
            'upper_arm.L': (0, 0, 0),
            'forearm.L': (0, 0, 0),
        })
        log("  Frame 12: Mid cycle")
        
        # Frame 24: Left foot forward contact
        set_walk_frame(rig, 24, {
            'root_forward': 0.0,        # Root fully moved forward
            'root_height': 0.0,         # Back to normal
            
            # Left leg forward (contact)
            'thigh.L': (15, -30, 0),    # Forward
            'shin.L': (-20, 0, 0),      # Knee bent
            'foot.L': (5, 0, 0),
            
            # Right leg back
            'thigh.R': (-5, 30, 0),     # Back
            'shin.R': (5, 0, 0),        # Extended
            'foot.R': (-5, 0, 0),
            
            'chest': (5, 0, 0),         # Lean forward
            
            # Arms switched
            'upper_arm.R': (20, 0, 0),  # Right arm forward
            'forearm.R': (-15, 0, 0),
            'upper_arm.L': (-20, 0, 0), # Left arm back
            'forearm.L': (15, 0, 0),
        })
        log("  Frame 24: Left foot contact")
        
        # Frame 36: Mid cycle - root moving forward again
        set_walk_frame(rig, 36, {
            'root_forward': 1.0,        # Moving forward
            'root_height': 0.1,         # Slight lift
            
            'thigh.L': (0, -15, 0),     # Left: mid swing
            'shin.L': (0, 0, 0),        # Knee straight
            'foot.L': (0, 0, 0),
            
            'thigh.R': (-15, 15, 0),    # Right: down
            'shin.R': (-5, 0, 0),       # Knee bent down
            'foot.R': (10, 0, 0),       # Foot preparing to leave ground
            
            'chest': (0, 0, 0),
            
            'upper_arm.R': (0, 0, 0),
            'forearm.R': (0, 0, 0),
            'upper_arm.L': (0, 0, 0),
            'forearm.L': (0, 0, 0),
        })
        log("  Frame 36: Mid cycle")
        
        # Frame 48: Loop back to start
        set_walk_frame(rig, 48, {
            'root_forward': -2.0,
            'root_height': 0.0,
            'thigh.R': (15, 30, 0),
            'shin.R': (-20, 0, 0),
            'foot.R': (5, 0, 0),
            'thigh.L': (-5, -30, 0),
            'shin.L': (5, 0, 0),
            'foot.L': (-5, 0, 0),
            'chest': (5, 0, 0),
            'upper_arm.R': (-20, 0, 0),
            'forearm.R': (15, 0, 0),
            'upper_arm.L': (20, 0, 0),
            'forearm.L': (-15, 0, 0),
        })
        log("  Frame 48: Cycle complete")
        
        # Return to Object mode
        bpy.ops.object.mode_set(mode='OBJECT')
        
        # Set scene animation range
        bpy.context.scene.frame_start = 0
        bpy.context.scene.frame_end = cycle_frames - 1
        
        log(f"\n[OK] Walk animation created!")
        log(f"  Total frames: {cycle_frames}")
        log(f"  Root motion: 4 units forward per cycle")
        
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

def set_walk_frame(rig, frame, pose_data):
    """Set pose for specific frame"""
    bpy.context.scene.frame_set(frame)
    
    # Handle root bone location
    if 'root_forward' in pose_data and 'root_height' in pose_data:
        root_bone = rig.pose.bones.get("spine")
        if root_bone:
            # Set root position (forward = Y axis in Blender)
            root_bone.location.y = pose_data['root_forward']
            root_bone.location.z = pose_data['root_height']
            root_bone.keyframe_insert(data_path="location")
    
    # Handle bone rotations
    for bone_name, pose_value in pose_data.items():
        if bone_name in ['root_forward', 'root_height']:
            continue
        
        # Unpack rotation tuple
        try:
            rot_x, rot_y, rot_z = pose_value
        except (TypeError, ValueError):
            continue
        
        bone = rig.pose.bones.get(bone_name)
        if not bone:
            continue
        
        # Convert degrees to radians
        rx = math.radians(rot_x)
        ry = math.radians(rot_y)
        rz = math.radians(rot_z)
        
        # Set rotation
        bone.rotation_euler = Euler((rx, ry, rz), 'XYZ')
        bone.keyframe_insert(data_path="rotation_euler")

# ============================================
# MAIN EXECUTION
# ============================================

print("\n" + "="*60)
print("IMPROVED WALK ANIMATION (v2)")
print("="*60)

if create_proper_walk_animation():
    try:
        bpy.ops.wm.save_mainfile()
        print("\n[OK] File saved successfully!")
    except Exception as e:
        print(f"\n[!] Failed to save: {e}")
else:
    print("\n[!] Animation creation failed")

print("\n" + "="*60)
print("To play the animation:")
print("  1. Press SPACEBAR")
print("  2. Character should walk forward 4 units per cycle")
print("  3. Timeline: 0-47 frames")
print("="*60 + "\n")
