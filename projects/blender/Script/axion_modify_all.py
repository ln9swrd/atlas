import bpy

def modify_armature_all():
    filepath = r"D:\Atlas\projects\blender\Model\axion.blend"
    
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
                p_bone = arm.edit_bones.get(parent)
                if p_bone:
                    b.parent = p_bone
            b.use_deform = False
            return b
        return arm.edit_bones[name]

    # Create root if not exists
    root_bone = create_bone('root', (0,0,0), (0, 20, 0))

    # Reparent existing roots to 'root'
    for b in arm.edit_bones:
        if not b.parent and b.name != 'root':
            b.parent = root_bone

    # Left Leg IK
    shin_l = arm.edit_bones.get('shin.L')
    if shin_l:
        foot_ik_l = create_bone('foot_ik.L', shin_l.tail, (shin_l.tail[0], shin_l.tail[1]-20, shin_l.tail[2]), 'root')
        knee_pos = shin_l.head
        knee_pole_l = create_bone('knee_pole.L', (knee_pos[0], knee_pos[1]-100, knee_pos[2]), (knee_pos[0], knee_pos[1]-120, knee_pos[2]), 'root')

    # Right Leg IK
    shin_r = arm.edit_bones.get('shin.R')
    if shin_r:
        foot_ik_r = create_bone('foot_ik.R', shin_r.tail, (shin_r.tail[0], shin_r.tail[1]-20, shin_r.tail[2]), 'root')
        knee_pos = shin_r.head
        knee_pole_r = create_bone('knee_pole.R', (knee_pos[0], knee_pos[1]-100, knee_pos[2]), (knee_pos[0], knee_pos[1]-120, knee_pos[2]), 'root')

    # Arms IK
    def setup_arm_ik_edit(side):
        forearm = arm.edit_bones.get(f'forearm.{side}')
        if forearm:
            hand_ik = create_bone(f'hand_ik.{side}', forearm.tail, (forearm.tail[0], forearm.tail[1]-20, forearm.tail[2]), 'root')
            elbow_pos = forearm.head
            elbow_pole = create_bone(f'elbow_pole.{side}', (elbow_pos[0], elbow_pos[1]+100, elbow_pos[2]), (elbow_pos[0], elbow_pos[1]+120, elbow_pos[2]), 'root')

    setup_arm_ik_edit('L')
    setup_arm_ik_edit('R')

    bpy.ops.object.mode_set(mode='POSE')
    
    # Unify Rotation Mode
    for pb in arm_obj.pose.bones:
        pb.rotation_mode = 'QUATERNION'

    # Add Custom Properties to Root
    root_pb = arm_obj.pose.bones.get('root')
    if root_pb:
        switches = ['ik_arm_L', 'ik_arm_R', 'ik_leg_L', 'ik_leg_R']
        for prop in switches:
            if prop not in root_pb:
                root_pb[prop] = 1.0
                try:
                    rna_ui = root_pb.get('_RNA_UI')
                    if rna_ui is None:
                        root_pb['_RNA_UI'] = {}
                        rna_ui = root_pb['_RNA_UI']
                    rna_ui[prop] = {"min": 0.0, "max": 1.0, "soft_min": 0.0, "soft_max": 1.0, "default": 1.0}
                except Exception as e:
                    print(f"RNA_UI error for {prop}: {e}")

    # Setup Constraints and Drivers
    def setup_ik_constraints_and_drivers(target_bone_name, ik_bone_name, pole_bone_name, switch_name, follow_bone_name=None):
        pb = arm_obj.pose.bones.get(target_bone_name)
        if not pb: return
        
        ik_c = pb.constraints.get('IK')
        if not ik_c:
            ik_c = pb.constraints.new('IK')
            ik_c.name = 'IK'
        ik_c.target = arm_obj
        ik_c.subtarget = ik_bone_name
        ik_c.pole_target = arm_obj
        ik_c.pole_subtarget = pole_bone_name
        ik_c.chain_count = 2

        if switch_name and root_pb:
            try:
                driver = ik_c.driver_add("influence").driver
                driver.type = 'AVERAGE'
                if len(driver.variables) == 0:
                    var = driver.variables.new()
                else:
                    var = driver.variables[0]
                var.name = "var"
                var.type = 'SINGLE_PROP'
                target = var.targets[0]
                target.id_type = 'OBJECT'
                target.id = arm_obj
                target.data_path = f'pose.bones["root"]["{switch_name}"]'
            except Exception as e:
                print(f"Driver error: {e}")

        if follow_bone_name:
            fpb = arm_obj.pose.bones.get(follow_bone_name)
            if fpb:
                cr_c = fpb.constraints.get('Copy Rotation')
                if not cr_c:
                    cr_c = fpb.constraints.new('COPY_ROTATION')
                    cr_c.name = 'Copy Rotation'
                cr_c.target = arm_obj
                cr_c.subtarget = ik_bone_name
                cr_c.target_space = 'LOCAL'
                cr_c.owner_space = 'LOCAL'
                
                if switch_name and root_pb:
                    try:
                        cr_driver = cr_c.driver_add("influence").driver
                        cr_driver.type = 'AVERAGE'
                        if len(cr_driver.variables) == 0:
                            var_cr = cr_driver.variables.new()
                        else:
                            var_cr = cr_driver.variables[0]
                        var_cr.name = "var"
                        var_cr.type = 'SINGLE_PROP'
                        target_cr = var_cr.targets[0]
                        target_cr.id_type = 'OBJECT'
                        target_cr.id = arm_obj
                        target_cr.data_path = f'pose.bones["root"]["{switch_name}"]'
                    except Exception as e:
                        print(f"CR Driver error: {e}")

    setup_ik_constraints_and_drivers('forearm.L', 'hand_ik.L', 'elbow_pole.L', 'ik_arm_L', 'hand.L')
    setup_ik_constraints_and_drivers('forearm.R', 'hand_ik.R', 'elbow_pole.R', 'ik_arm_R', 'hand.R')
    setup_ik_constraints_and_drivers('shin.L', 'foot_ik.L', 'knee_pole.L', 'ik_leg_L', 'foot.L')
    setup_ik_constraints_and_drivers('shin.R', 'foot_ik.R', 'knee_pole.R', 'ik_leg_R', 'foot.R')

    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.wm.save_as_mainfile(filepath=filepath)
    print("ALL MODIFICATIONS SUCCESSFUL")

if __name__ == "__main__":
    modify_armature_all()
