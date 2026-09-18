# Diagnostic script for player visibility, camera, mesh and movement
# pyrefly: ignore [missing-import]
import unreal
import os

bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
bp_gm_path = "/Game/Blueprints/BP_ExcelionGameMode"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\invisible_diag_results.txt"

def main():
    lines = []
    lines.append("=== INVISIBLE PLAYER DIAGNOSTIC START ===")

    char_cls = unreal.load_class(None, f"{bp_char_path}.BP_ExcelionCharacter_C")
    if not char_cls:
        lines.append("ERROR: BP_ExcelionCharacter_C class not found")
        write_result(lines)
        return

    # 1. Spawn actor in level
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(char_cls, unreal.Vector(0,0,100), unreal.Rotator(0,0,0))
    if not actor:
        lines.append("ERROR: Failed to spawn actor")
        write_result(lines)
        return

    lines.append(f"Spawned Actor: {actor.get_name()}")

    # 2. Check Mesh visibility & properties
    mesh_comp = actor.get_components_by_class(unreal.SkeletalMeshComponent)[0] if actor.get_components_by_class(unreal.SkeletalMeshComponent) else None
    if mesh_comp:
        sk_mesh = mesh_comp.get_skeletal_mesh_asset() if hasattr(mesh_comp, "get_skeletal_mesh_asset") else None
        is_vis = mesh_comp.is_visible()
        is_hid = mesh_comp.get_editor_property("hidden_in_game")
        rel_loc = mesh_comp.get_editor_property("relative_location")
        rel_rot = mesh_comp.get_editor_property("relative_rotation")
        rel_scale = mesh_comp.get_editor_property("relative_scale3d")

        lines.append(f"Mesh Asset Name: {sk_mesh.get_name() if sk_mesh else 'None'}")
        lines.append(f"Mesh Asset Path: {sk_mesh.get_path_name() if sk_mesh else 'None'}")
        lines.append(f"Mesh Component Visible: {is_vis}")
        lines.append(f"Mesh Component HiddenInGame: {is_hid}")
        lines.append(f"Mesh Relative Location: ({rel_loc.x}, {rel_loc.y}, {rel_loc.z})")
        lines.append(f"Mesh Relative Rotation: (Pitch={rel_rot.pitch}, Yaw={rel_rot.yaw}, Roll={rel_rot.roll})")
        lines.append(f"Mesh Relative Scale: ({rel_scale.x}, {rel_scale.y}, {rel_scale.z})")
        
        # Check material slots
        num_mats = mesh_comp.get_num_materials()
        lines.append(f"Mesh Num Materials: {num_mats}")
        for i in range(num_mats):
            mat = mesh_comp.get_material(i)
            lines.append(f"  Material Slot {i}: {mat.get_name() if mat else 'None'}")

    # 3. Check Camera & SpringArm
    cams = actor.get_components_by_class(unreal.CameraComponent)
    arms = actor.get_components_by_class(unreal.SpringArmComponent)
    if arms:
        arm = arms[0]
        arm_len = arm.get_editor_property("target_arm_length")
        socket_offset = arm.get_editor_property("socket_offset")
        target_offset = arm.get_editor_property("target_offset")
        lines.append(f"SpringArm TargetArmLength: {arm_len}")
        lines.append(f"SpringArm SocketOffset: ({socket_offset.x}, {socket_offset.y}, {socket_offset.z})")
        lines.append(f"SpringArm TargetOffset: ({target_offset.x}, {target_offset.y}, {target_offset.z})")

    if cams:
        cam = cams[0]
        lines.append(f"Camera FieldOfView: {cam.get_editor_property('field_of_view')}")
        cam_loc = cam.get_editor_property("relative_location")
        lines.append(f"Camera RelativeLocation: ({cam_loc.x}, {cam_loc.y}, {cam_loc.z})")

    # 4. Check FallbackVisualMesh (StaticMeshComponent)
    sm_comps = actor.get_components_by_class(unreal.StaticMeshComponent)
    for sm in sm_comps:
        sm_name = sm.get_name()
        sm_mesh = sm.static_mesh
        lines.append(f"StaticMeshComp '{sm_name}': Mesh={sm_mesh.get_name() if sm_mesh else 'None'}, Visible={sm.is_visible()}, HiddenInGame={sm.get_editor_property('hidden_in_game')}")

    # 5. Check Movement & Input properties on CDO
    cdo = unreal.get_default_object(char_cls)
    lines.append(f"CDO DefaultMappingContext: {cdo.get_editor_property('default_mapping_context')}")
    lines.append(f"CDO MoveAction: {cdo.get_editor_property('move_action')}")
    lines.append(f"CDO MoveForwardAction: {cdo.get_editor_property('move_forward_action')}")
    lines.append(f"CDO AutoPossessPlayer: {cdo.get_editor_property('auto_possess_player')}")

    unreal.EditorLevelLibrary.destroy_actor(actor)
    write_result(lines)

def write_result(lines):
    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

if __name__ == "__main__":
    main()
