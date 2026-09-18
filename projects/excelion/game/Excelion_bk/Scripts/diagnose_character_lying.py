# Diagnose why BP_ExcelionCharacter is lying down and why movement is not working
import unreal
import os

bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\character_diag_results.txt"

def main():
    lines = []
    lines.append("=== DIAGNOSE BP_EXCELION_CHARACTER START ===")

    bp = unreal.EditorAssetLibrary.load_asset(bp_path)
    if not bp:
        lines.append(f"ERROR: Could not load BP at {bp_path}")
        write_result(lines)
        return

    char_cls = unreal.load_class(None, f"{bp_path}.BP_ExcelionCharacter_C")
    if not char_cls:
        lines.append("ERROR: Could not load class")
        write_result(lines)
        return

    cdo = unreal.get_default_object(char_cls)
    lines.append(f"CDO Class: {cdo.get_class().get_name()}")

    # 1. Mesh inspection
    mesh = cdo.get_editor_property("mesh")
    if mesh:
        loc = mesh.get_editor_property("relative_location")
        rot = mesh.get_editor_property("relative_rotation")
        scale = mesh.get_editor_property("relative_scale3d")
        sk_asset = mesh.get_skeletal_mesh_asset() if hasattr(mesh, "get_skeletal_mesh_asset") else None
        
        lines.append(f"Mesh Asset: {sk_asset.get_name() if sk_asset else 'None'} ({sk_asset.get_path_name() if sk_asset else 'None'})")
        lines.append(f"Mesh Location: X={loc.x}, Y={loc.y}, Z={loc.z}")
        lines.append(f"Mesh Rotation: Pitch={rot.pitch}, Yaw={rot.yaw}, Roll={rot.roll}")
        lines.append(f"Mesh Scale: {scale.x}, {scale.y}, {scale.z}")
        try:
            lines.append(f"Mesh Collision Profile: {mesh.get_editor_property('collision_profile_name')}")
        except:
            pass

    # 2. Capsule inspection
    capsule = cdo.get_editor_property("capsule_component")
    if capsule:
        c_radius = capsule.get_editor_property("capsule_radius")
        c_half_height = capsule.get_editor_property("capsule_half_height")
        lines.append(f"Capsule Radius: {c_radius}, HalfHeight: {c_half_height}")

    # 3. CharacterMovement inspection
    move = cdo.get_editor_property("character_movement")
    if move:
        max_speed = move.get_editor_property("max_walk_speed")
        orient = move.get_editor_property("b_orient_rotation_to_movement")
        movement_mode = move.get_editor_property("default_land_movement_mode")
        lines.append(f"Movement MaxWalkSpeed: {max_speed}")
        lines.append(f"OrientRotationToMovement: {orient}")
        lines.append(f"DefaultLandMovementMode: {movement_mode}")

    # 4. Input & Controller inspection
    lines.append(f"AutoPossessPlayer: {cdo.get_editor_property('auto_possess_player')}")
    lines.append(f"UseControllerRotationYaw: {cdo.get_editor_property('b_use_controller_rotation_yaw')}")
    
    # Check IMC and actions on CDO
    try:
        lines.append(f"DefaultMappingContext: {cdo.get_editor_property('default_mapping_context')}")
        lines.append(f"MoveAction: {cdo.get_editor_property('move_action')}")
        lines.append(f"LookAction: {cdo.get_editor_property('look_action')}")
        lines.append(f"MoveForwardAction: {cdo.get_editor_property('move_forward_action')}")
        lines.append(f"MoveRightAction: {cdo.get_editor_property('move_right_action')}")
    except Exception as e:
        lines.append(f"Input action inspection note: {e}")

    # 5. Test spawning actor and inspecting runtime properties
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(char_cls, unreal.Vector(0,0,100), unreal.Rotator(0,0,0))
    if actor:
        spawn_rot = actor.get_actor_rotation()
        lines.append(f"Spawned Actor Rotation: Pitch={spawn_rot.pitch}, Yaw={spawn_rot.yaw}, Roll={spawn_rot.roll}")
        m_comp = actor.get_components_by_class(unreal.SkeletalMeshComponent)[0]
        m_rot = m_comp.get_world_rotation()
        lines.append(f"Spawned Mesh World Rotation: Pitch={m_rot.pitch}, Yaw={m_rot.yaw}, Roll={m_rot.roll}")
        m_rel_rot = m_comp.get_relative_rotation()
        lines.append(f"Spawned Mesh Relative Rotation: Pitch={m_rel_rot.pitch}, Yaw={m_rel_rot.yaw}, Roll={m_rel_rot.roll}")
        
        # Check collision enable
        lines.append(f"Spawned Actor Collision Enabled: {actor.get_actor_enable_collision()}")
        lines.append(f"Capsule Simulating Physics: {actor.get_components_by_class(unreal.CapsuleComponent)[0].is_simulating_physics()}")
        lines.append(f"Mesh Simulating Physics: {m_comp.is_simulating_physics()}")
        
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
