import bpy

def debug_arms():
    arm = bpy.data.objects.get('metarig')
    if not arm: return
    
    bpy.context.scene.frame_set(1)
    bpy.context.view_layer.update()
    
    print("\n=== FRAME 1 (CONTACT L) ===")
    h_l = arm.pose.bones['hand_ik.L']
    e_l = arm.pose.bones['elbow_pole.L']
    h_r = arm.pose.bones['hand_ik.R']
    e_r = arm.pose.bones['elbow_pole.R']
    
    print(f"hand_ik.L World: {h_l.matrix.translation}")
    print(f"elbow_pole.L World: {e_l.matrix.translation}")
    print(f"hand_ik.R World: {h_r.matrix.translation}")
    print(f"elbow_pole.R World: {e_r.matrix.translation}")
    
    bpy.context.scene.frame_set(25)
    bpy.context.view_layer.update()
    
    print("\n=== FRAME 25 (CONTACT R) ===")
    print(f"hand_ik.L World: {h_l.matrix.translation}")
    print(f"elbow_pole.L World: {e_l.matrix.translation}")
    print(f"hand_ik.R World: {h_r.matrix.translation}")
    print(f"elbow_pole.R World: {e_r.matrix.translation}")

if __name__ == "__main__":
    debug_arms()
