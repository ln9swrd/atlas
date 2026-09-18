import bpy

def modify_armature_arms():
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

    # Arm IK
    def setup_arm_ik_edit(side):
        forearm = arm.edit_bones.get(f'forearm.{side}')
        hand = arm.edit_bones.get(f'hand.{side}')
        if forearm and hand:
            # Hand IK at the wrist (forearm tail)
            hand_ik = create_bone(f'hand_ik.{side}', forearm.tail, (forearm.tail[0], forearm.tail[1]-20, forearm.tail[2]), 'root')
            
            # Elbow pole at elbow (forearm head)
            elbow_pos = forearm.head
            # Offset backward for elbow (assuming Y is forward/backward, Z is up)
            # Actually, standard T-pose elbow bends backwards, so pole should go backwards (-Y)
            elbow_pole = create_bone(f'elbow_pole.{side}', (elbow_pos[0], elbow_pos[1]+100, elbow_pos[2]), (elbow_pos[0], elbow_pos[1]+120, elbow_pos[2]), 'root')

    setup_arm_ik_edit('L')
    setup_arm_ik_edit('R')

    bpy.ops.object.mode_set(mode='POSE')
    
    # 1. Unify Rotation Mode
    for pb in arm_obj.pose.bones:
        pb.rotation_mode = 'QUATERNION'

    # 2. Add Custom Properties to Root
    root_pb = arm_obj.pose.bones.get('root')
    if not root_pb:
        print("Root bone not found for custom properties.")
        return

    switches = ['ik_arm_L', 'ik_arm_R', 'ik_leg_L', 'ik_leg_R']
    for prop in switches:
        if prop not in root_pb:
            root_pb[prop] = 1.0
            
            # Setup UI for custom property
            try:
                # Needed to set min/max/default in modern Blender
                rna_ui = root_pb.get('_RNA_UI')
                if rna_ui is None:
                    root_pb['_RNA_UI'] = {}
                    rna_ui = root_pb['_RNA_UI']
                rna_ui[prop] = {"min": 0.0, "max": 1.0, "soft_min": 0.0, "soft_max": 1.0, "default": 1.0}
            except Exception as e:
                print(f"Could not set RNA_UI for {prop}: {e}")

    # Helper to add constraints and drivers
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

        # Add Driver to IK Influence
        driver = ik_c.driver_add("influence").driver
        driver.type = 'AVERAGE'
        var = driver.variables.new()
        var.name = "var"
        var.type = 'SINGLE_PROP'
        target = var.targets[0]
        target.id_type = 'OBJECT'
        target.id = arm_obj
        target.data_path = f'pose.bones["root"]["{switch_name}"]'

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
                
                cr_driver = cr_c.driver_add("influence").driver
                cr_driver.type = 'AVERAGE'
                var_cr = cr_driver.variables.new()
                var_cr.name = "var"
                var_cr.type = 'SINGLE_PROP'
                target_cr = var_cr.targets[0]
                target_cr.id_type = 'OBJECT'
                target_cr.id = arm_obj
                target_cr.data_path = f'pose.bones["root"]["{switch_name}"]'

    # Arm IK Constraints
    setup_ik_constraints_and_drivers('forearm.L', 'hand_ik.L', 'elbow_pole.L', 'ik_arm_L', 'hand.L')
    setup_ik_constraints_and_drivers('forearm.R', 'hand_ik.R', 'elbow_pole.R', 'ik_arm_R', 'hand.R')
    
    # Leg IK Drivers (constraints already exist, this updates/re-applies them and adds drivers)
    setup_ik_constraints_and_drivers('shin.L', 'foot_ik.L', 'knee_pole.L', 'ik_leg_L', 'foot.L')
    setup_ik_constraints_and_drivers('shin.R', 'foot_ik.R', 'knee_pole.R', 'ik_leg_R', 'foot.R')

    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("ARMS AND DRIVERS MODIFICATION SUCCESSFUL")

if __name__ == "__main__":
    modify_armature_arms()
