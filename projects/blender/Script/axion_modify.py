import bpy
import math

def modify_armature():
    arm_obj = None
    for arm in bpy.context.scene.objects:
        if arm.type == 'ARMATURE' and 'metarig' in arm.name.lower():
            arm_obj = arm
            break
    if not arm_obj:
        print("Armature not found.")
        return

    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode='EDIT')
    arm = arm_obj.data

    def create_bone(name, head, tail, parent=None):
        if name not in arm.edit_bones:
            b = arm.edit_bones.new(name)
            b.head = head
            b.tail = tail
            if parent:
                b.parent = arm.edit_bones.get(parent)
            b.use_deform = False
            return b
        return arm.edit_bones[name]

    # Create Root
    root_bone = create_bone('root', (0,0,0), (0, 20, 0))

    # Existing roots: spine, Bone
    spine = arm.edit_bones.get('spine')
    if spine and not spine.parent:
        spine.parent = root_bone
    
    other_bone = arm.edit_bones.get('Bone')
    if other_bone and not other_bone.parent and other_bone != root_bone:
        other_bone.parent = root_bone

    # Left Leg IK setup
    shin_l = arm.edit_bones.get('shin.L')
    foot_l = arm.edit_bones.get('foot.L')
    thigh_l = arm.edit_bones.get('thigh.L')
    
    if shin_l and foot_l:
        # Foot IK at the ankle (shin.L tail)
        # Tail slightly forward to visualize
        foot_ik_l = create_bone('foot_ik.L', shin_l.tail, (shin_l.tail[0], shin_l.tail[1]-20, shin_l.tail[2]), 'root')
        
        # Knee Pole at knee
        knee_pos = shin_l.head
        knee_pole_l = create_bone('knee_pole.L', (knee_pos[0], knee_pos[1]-100, knee_pos[2]), (knee_pos[0], knee_pos[1]-120, knee_pos[2]), 'root')
    
    # Right Leg IK setup
    shin_r = arm.edit_bones.get('shin.R')
    foot_r = arm.edit_bones.get('foot.R')
    thigh_r = arm.edit_bones.get('thigh.R')
    
    if shin_r and foot_r:
        foot_ik_r = create_bone('foot_ik.R', shin_r.tail, (shin_r.tail[0], shin_r.tail[1]-20, shin_r.tail[2]), 'root')
        
        knee_pos = shin_r.head
        knee_pole_r = create_bone('knee_pole.R', (knee_pos[0], knee_pos[1]-100, knee_pos[2]), (knee_pos[0], knee_pos[1]-120, knee_pos[2]), 'root')

    bpy.ops.object.mode_set(mode='POSE')

    # Add constraints
    def add_ik(bone_name, target_name, pole_name):
        pb = arm_obj.pose.bones.get(bone_name)
        if not pb: return
        ik = pb.constraints.get('IK')
        if not ik:
            ik = pb.constraints.new('IK')
            ik.name = 'IK'
        ik.target = arm_obj
        ik.subtarget = target_name
        ik.pole_target = arm_obj
        ik.pole_subtarget = pole_name
        ik.chain_count = 2
        # Calculate pole angle would be ideal, but for now we let it default, user can tweak or we use typical -90/90
        # Actually in Blender, default pole angle 0 often twists. We will leave at 0, "최소 수정안"

    def add_copy_rot(bone_name, target_name):
        pb = arm_obj.pose.bones.get(bone_name)
        if not pb: return
        cr = pb.constraints.get('Copy Rotation')
        if not cr:
            cr = pb.constraints.new('COPY_ROTATION')
            cr.name = 'Copy Rotation'
        cr.target = arm_obj
        cr.subtarget = target_name
        cr.target_space = 'LOCAL'
        cr.owner_space = 'LOCAL'

    add_ik('shin.L', 'foot_ik.L', 'knee_pole.L')
    add_copy_rot('foot.L', 'foot_ik.L')
    
    add_ik('shin.R', 'foot_ik.R', 'knee_pole.R')
    add_copy_rot('foot.R', 'foot_ik.R')

    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("MODIFICATION SUCCESSFUL")

if __name__ == "__main__":
    modify_armature()
