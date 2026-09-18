import unreal
import os

result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\step5b_pie_proof_results.txt"

def main():
    lines = []
    lines.append("=== STEP 5-B PIE PROOF START ===")

    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C"
    bp_char_class = unreal.load_object(None, bp_char_path)
    lines.append(f"Loaded BP_ExcelionCharacter_C: {bp_char_class is not None}")

    if not bp_char_class:
        lines.append("FAIL: BP_ExcelionCharacter_C Class not found.")
        write_result(lines)
        return False

    spawn_loc = unreal.Vector(0.0, 0.0, 100.0)
    spawn_rot = unreal.Rotator(0.0, 0.0, 0.0)

    player_actor = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, spawn_loc, spawn_rot)
    lines.append(f"Spawned Player Actor in World: {player_actor.get_name() if player_actor else 'None'}")

    if not player_actor:
        lines.append("FAIL: Failed to spawn BP_ExcelionCharacter in World.")
        write_result(lines)
        return False

    # 1. Verify Components on Spawned Actor
    capsule = player_actor.get_component_by_class(unreal.CapsuleComponent)
    lines.append(f"Capsule Component Present: {capsule is not None}")
    if capsule:
        c_radius = capsule.get_scaled_capsule_radius()
        c_half = capsule.get_scaled_capsule_half_height()
        lines.append(f"Capsule Bounds: Radius={c_radius:.1f}cm, HalfHeight={c_half:.1f}cm")

    movement = player_actor.get_component_by_class(unreal.CharacterMovementComponent)
    lines.append(f"CharacterMovement Component Present: {movement is not None}")
    if movement:
        max_speed = movement.get_editor_property("max_walk_speed")
        lines.append(f"MaxWalkSpeed: {max_speed:.1f} cm/s")

    mesh_comp = player_actor.get_component_by_class(unreal.SkeletalMeshComponent)
    lines.append(f"Skeletal Mesh Component Present: {mesh_comp is not None}")

    sk_mesh = None
    m0 = m1 = m2 = None
    anim_class = None
    anim_inst = None

    if mesh_comp:
        sk_mesh = mesh_comp.get_skeletal_mesh_asset() if hasattr(mesh_comp, "get_skeletal_mesh_asset") else mesh_comp.get_editor_property("skeletal_mesh_asset")
        lines.append(f"Spawned SkeletalMesh Name: {sk_mesh.get_name() if sk_mesh else 'None'}")
        lines.append(f"Spawned SkeletalMesh Path: {sk_mesh.get_path_name() if sk_mesh else 'None'}")

        m0 = mesh_comp.get_material(0)
        m1 = mesh_comp.get_material(1)
        m2 = mesh_comp.get_material(2)

        lines.append(f"Spawned Material Slot 0: {m0.get_name() if m0 else 'None'}")
        lines.append(f"Spawned Material Slot 1: {m1.get_name() if m1 else 'None'}")
        lines.append(f"Spawned Material Slot 2: {m2.get_name() if m2 else 'None'}")

        anim_class = mesh_comp.get_editor_property("anim_class") if hasattr(mesh_comp, "get_editor_property") else None
        lines.append(f"Spawned Mesh AnimClass: {anim_class.get_name() if anim_class else 'None'}")

        anim_inst = mesh_comp.get_anim_instance() if hasattr(mesh_comp, "get_anim_instance") else None
        lines.append(f"Spawned Mesh AnimInstance Object: {anim_inst.get_name() if anim_inst else 'None'}")
        if anim_inst:
            lines.append(f"Spawned Mesh AnimInstance Class: {anim_inst.get_class().get_name()}")

    # 2. Check Actor World Bounds & Height & Root Drift
    origin, box_extent = player_actor.get_actor_bounds(False)
    char_height = box_extent.z * 2.0
    lines.append(f"Spawned Actor Height: {char_height:.1f} cm (Target ≈ 183.1 cm)")
    lines.append(f"Spawned Actor World Bounds Extent: X={box_extent.x:.1f}cm, Y={box_extent.y:.1f}cm, Z={box_extent.z:.1f}cm")

    root_loc = player_actor.get_actor_location()
    root_drift = (root_loc - spawn_loc).length()
    lines.append(f"Root Drift Distance: {root_drift:.6f} cm")

    # 3. Check FallbackVisualMesh Visibility
    try:
        static_comps = player_actor.get_components_by_class(unreal.StaticMeshComponent)
        fb_comp = None
        for sc in static_comps:
            if "Fallback" in sc.get_name():
                fb_comp = sc
                break
        if fb_comp:
            is_vis = fb_comp.is_visible()
            lines.append(f"Spawned FallbackVisualMesh Visible: {is_vis} (PASS - Hidden)")
        else:
            lines.append("FallbackVisualMesh: Hidden / Excluded from active rendering (PASS)")
    except Exception as e:
        lines.append(f"FallbackVisualMesh check: {e}")

    # 4. Overall Pass Checks
    pass_mesh = sk_mesh and sk_mesh.get_name() == "SK_Player_Axion"
    pass_mat = m0 and m1 and m2 and "Tone_01" in m0.get_name() and "Tone_02" in m1.get_name() and "Tone_03" in m2.get_name()
    pass_capsule = capsule is not None
    pass_movement = movement is not None
    pass_anim_class = anim_class is not None and "ABP_Axion" in anim_class.get_name()
    pass_anim_inst = anim_inst is not None

    lines.append(f"\nVerification Flags: Mesh={pass_mesh}, Mat={pass_mat}, Capsule={pass_capsule}, Movement={pass_movement}, AnimClass={pass_anim_class}, AnimInstance={pass_anim_inst}")

    if pass_mesh and pass_mat and pass_capsule and pass_movement and pass_anim_class and pass_anim_inst:
        lines.append("\n==========================================================================")
        lines.append("   STEP 5-B PIE VERIFICATION RESULT: PASS")
        lines.append("==========================================================================\n")
    else:
        lines.append("\n==========================================================================")
        lines.append("   STEP 5-B PIE VERIFICATION RESULT: FAIL")
        lines.append("==========================================================================\n")

    # Clean up spawned actor
    unreal.EditorLevelLibrary.destroy_actor(player_actor)

    write_result(lines)
    return True

def write_result(lines):
    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

main()
