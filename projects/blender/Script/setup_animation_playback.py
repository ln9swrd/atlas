"""
Auto-setup: Set action visible and frame range for playback
"""

import bpy

print("\n" + "="*60)
print("SETUP: Prepare animation for playback")
print("="*60)

rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
if rig:
    print(f"\n✅ Found: {rig.name}")
    
    # Find and set the action
    if "Walk_Cycle_Rigify" in bpy.data.actions:
        action = bpy.data.actions["Walk_Cycle_Rigify"]
        print(f"✅ Found action: {action.name}")
        
        # Assign to rig if not already
        if not rig.animation_data:
            rig.animation_data_create()
        
        rig.animation_data.action = action
        print(f"✅ Action assigned to rig")
        
        # Set frame range to animation
        bpy.context.scene.frame_start = 0
        bpy.context.scene.frame_end = 47
        bpy.context.scene.frame_current = 0
        
        print(f"\n[FRAME RANGE]")
        print(f"  Start: {bpy.context.scene.frame_start}")
        print(f"  End: {bpy.context.scene.frame_end}")
        
        # Select rig
        for obj in bpy.data.objects:
            obj.select_set(False)
        rig.select_set(True)
        bpy.context.view_layer.objects.active = rig
        
        print(f"\n✅ RIG-Axion_Rigify_Metarig selected")
        print(f"✅ Walk_Cycle_Rigify ready to play")
        
        # Save
        bpy.ops.wm.save_mainfile()
        print(f"\n✅ File saved!")
        
    else:
        print(f"[!] Walk_Cycle_Rigify not found")
else:
    print(f"[!] RIG-Axion_Rigify_Metarig not found")

print("\n" + "="*60)
print("TO PLAY ANIMATION:")
print("  1. In Timeline view")
print("  2. Press SPACEBAR")
print("  3. Character walks forward!")
print("="*60 + "\n")
