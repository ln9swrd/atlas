import bpy
import json

def dump_frame_0():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    bpy.context.scene.frame_set(0)
    
    bones = [
        'foot_ik.L', 'foot_ik.R',
        'knee_pole.L', 'knee_pole.R',
        'heel.02.L', 'heel.02.R',
        'hand_ik.L', 'hand_ik.R',
        'elbow_pole.L', 'elbow_pole.R'
    ]
    
    data = {}
    for b in bones:
        pb = arm.pose.bones.get(b)
        if pb:
            loc = pb.location
            data[b] = {"x": loc.x, "y": loc.y, "z": loc.z}
            
    with open(r'D:\Atlas\scratch\frame_0_pose.json', 'w') as f:
        json.dump(data, f, indent=4)
        
if __name__ == "__main__":
    dump_frame_0()
