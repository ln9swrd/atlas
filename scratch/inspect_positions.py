import bpy
import sys

print("\n--- START POSITION CHECK ---")

try:
    rig = bpy.data.objects.get("SuperRobotRig")
    ctrl_rig = bpy.data.objects.get("Excelion_IK_CTRL")
    
    if rig and ctrl_rig:
        # Check forearm.L head position in World Space (since both scales are 1.0 now, local = world if location is 0)
        # But we must check Edit bones or rest pose bones
        b1 = rig.data.bones.get("forearm.L")
        b2 = ctrl_rig.data.bones.get("CTRL_Hand_IK.L") # This is the target for forearm.L IK
        b_pole = ctrl_rig.data.bones.get("CTRL_Elbow_Pole.L")
        
        if b1 and b2:
            print(f"SuperRobotRig forearm.L head (Rest): {b1.head_local[:]}")
            print(f"SuperRobotRig forearm.L tail (Rest): {b1.tail_local[:]}")
            print(f"Excelion_IK_CTRL CTRL_Hand_IK.L head (Rest): {b2.head_local[:]}")
            if b_pole:
                print(f"Excelion_IK_CTRL CTRL_Elbow_Pole.L head (Rest): {b_pole.head_local[:]}")

except Exception as e:
    print(f"ERROR: {e}")

print("--- END POSITION CHECK ---")
sys.exit(0)
