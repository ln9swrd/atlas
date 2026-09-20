import bpy
import math

def read_frame_1():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    
    # Go to frame 1
    bpy.context.scene.frame_set(1)
    bpy.context.view_layer.update()
    
    bones_to_read = [
        'root', 'spine', 
        'foot_ik.L', 'foot_ik.R', 'knee_pole.L', 'knee_pole.R',
        'hand_ik.L', 'hand_ik.R', 'elbow_pole.L', 'elbow_pole.R'
    ]
    
    print("\n=== USER MODIFIED FRAME 1 DATA ===")
    for b_name in bones_to_read:
        pb = arm.pose.bones.get(b_name)
        if not pb: continue
        
        loc = pb.location
        if pb.rotation_mode == 'QUATERNION':
            rot = pb.rotation_quaternion.to_euler()
        else:
            rot = pb.rotation_euler
            
        rot_deg = (math.degrees(rot.x), math.degrees(rot.y), math.degrees(rot.z))
        
        print(f"\"{b_name}\": {{\"location\": ({loc.x:.2f}, {loc.y:.2f}, {loc.z:.2f}), \"rotation_euler\": (math.radians({rot_deg[0]:.2f}), math.radians({rot_deg[1]:.2f}), math.radians({rot_deg[2]:.2f}))}},")

if __name__ == "__main__":
    read_frame_1()
