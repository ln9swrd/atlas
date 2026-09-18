import bpy
import json


def main():
    rig = bpy.data.objects.get("rig")
    if not rig or rig.type != "ARMATURE" or rig.data.get("rig_id") is None:
        raise RuntimeError("Generated Rigify object 'rig' was not found")

    names = [
        "root", "hips", "torso", "chest", "neck", "head",
        "foot_ik.L", "foot_ik.R", "thigh_ik_target.L", "thigh_ik_target.R",
        "hand_ik.L", "hand_ik.R", "upper_arm_ik_target.L", "upper_arm_ik_target.R",
        "toe_ik.L", "toe_ik.R", "foot_roll.L", "foot_roll.R",
        "thigh_fk.L", "thigh_fk.R", "shin_fk.L", "shin_fk.R",
        "upper_arm_fk.L", "upper_arm_fk.R", "forearm_fk.L", "forearm_fk.R",
    ]
    result = {}
    for name in names:
        bone = rig.pose.bones.get(name)
        if bone:
            result[name] = {
                "location": [round(value, 6) for value in bone.location],
                "rotation_mode": bone.rotation_mode,
                "rotation_euler": [round(value, 6) for value in bone.rotation_euler],
                "custom_properties": {
                    key: bone.get(key) for key in bone.keys()
                },
            }
    print("AXION_CONTROL_REPORT_BEGIN")
    print(json.dumps({
        "rig": rig.name,
        "rig_id": rig.data.get("rig_id"),
        "controls": result,
        "actions": [action.name for action in bpy.data.actions],
    }, indent=2, sort_keys=True, default=str))
    for name in names:
        bone = rig.pose.bones.get(name)
        if bone:
            matrix = rig.matrix_world @ bone.matrix
            print(
                "CONTROL %s head=(%.4f, %.4f, %.4f) basis_loc=(%.4f, %.4f, %.4f)"
                % (
                    name,
                    matrix.translation.x,
                    matrix.translation.y,
                    matrix.translation.z,
                    bone.location.x,
                    bone.location.y,
                    bone.location.z,
                )
            )
    print("AXION_CONTROL_REPORT_END")


main()