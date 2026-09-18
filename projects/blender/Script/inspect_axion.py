import bpy
import json
import os


def describe_armature(obj):
    data = obj.data
    pose_bones = [bone.name for bone in obj.pose.bones]
    rigify_props = {
        key: data.get(key)
        for key in data.keys()
        if "rig" in key.lower() or "rigify" in key.lower()
    }
    object_props = {
        key: obj.get(key)
        for key in obj.keys()
        if "rig" in key.lower() or "rigify" in key.lower()
    }
    return {
        "name": obj.name,
        "data_name": data.name,
        "library": obj.library.filepath if obj.library else None,
        "parent": obj.parent.name if obj.parent else None,
        "bone_count": len(data.bones),
        "pose_bones": pose_bones,
        "data_rigify_properties": rigify_props,
        "object_rigify_properties": object_props,
        "animation_data_action": (
            obj.animation_data.action.name
            if obj.animation_data and obj.animation_data.action
            else None
        ),
        "animation_data_nla_tracks": (
            [track.name for track in obj.animation_data.nla_tracks]
            if obj.animation_data
            else []
        ),
    }


def main():
    rig = bpy.data.objects.get("rig")
    control_names = [
        "root", "hips", "torso", "chest", "neck", "head",
        "foot_ik.L", "foot_ik.R", "thigh_ik_target.L", "thigh_ik_target.R",
        "hand_ik.L", "hand_ik.R", "upper_arm_ik_target.L", "upper_arm_ik_target.R",
        "toe_ik.L", "toe_ik.R", "foot_roll.L", "foot_roll.R",
        "thigh_fk.L", "thigh_fk.R", "shin_fk.L", "shin_fk.R",
        "upper_arm_fk.L", "upper_arm_fk.R", "forearm_fk.L", "forearm_fk.R",
    ]
    control_state = {}
    if rig:
        for name in control_names:
            bone = rig.pose.bones.get(name)
            if bone:
                control_state[name] = {
                    "location": list(bone.location),
                    "rotation_mode": bone.rotation_mode,
                    "rotation_euler": list(bone.rotation_euler),
                    "rotation_quaternion": list(bone.rotation_quaternion),
                    "scale": list(bone.scale),
                    "custom_properties": {
                        key: bone.get(key) for key in bone.keys()
                    },
                    "constraints": [
                        {
                            "name": constraint.name,
                            "type": constraint.type,
                            "target": constraint.target.name
                            if constraint.target else None,
                            "subtarget": constraint.subtarget,
                        }
                        for constraint in bone.constraints
                    ],
                }
    result = {
        "filepath": bpy.data.filepath,
        "file_exists": os.path.exists(bpy.data.filepath),
        "is_saved": bool(bpy.data.filepath),
        "scene": bpy.context.scene.name if bpy.context.scene else None,
        "fps": bpy.context.scene.render.fps if bpy.context.scene else None,
        "armatures": [
            describe_armature(obj)
            for obj in bpy.data.objects
            if obj.type == "ARMATURE"
        ],
        "actions": [
            {
                "name": action.name,
                "frame_range": list(action.frame_range),
                "users": action.users,
                "is_asset": action.asset_data is not None,
            }
            for action in bpy.data.actions
        ],
        "active_object": bpy.context.view_layer.objects.active.name
        if bpy.context.view_layer.objects.active
        else None,
        "selected_objects": [obj.name for obj in bpy.context.selected_objects],
        "control_state": control_state,
    }
    print("AXION_READ_ONLY_REPORT_BEGIN")
    print(json.dumps(result, indent=2, sort_keys=True, default=str))
    print("AXION_READ_ONLY_REPORT_END")


main()