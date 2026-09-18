# Excelion — Verify BP_ExcelionCharacter SKM_Manny_Simple Mesh Proof
import unreal
import os

bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
bp_char_class_path = f"{bp_char_path}.BP_ExcelionCharacter_C"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\verify_manny_mesh_proof_results.txt"

def main():
    lines = []
    lines.append("=== VERIFY MANNY MESH PROOF START ===")

    bp_char_class = unreal.load_object(None, bp_char_class_path)
    if not bp_char_class:
        lines.append(f"[FAIL] Could not load class {bp_char_class_path}")
        write_result(lines)
        return False

    # Spawn actor in editor level library
    spawn_location = unreal.Vector(0, 0, 100)
    spawn_rotation = unreal.Rotator(0, 0, 0)
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, spawn_location, spawn_rotation)
    
    if not actor:
        lines.append("[FAIL] Could not spawn BP_ExcelionCharacter actor")
        write_result(lines)
        return False

    lines.append(f"[PASS] Spawned actor: {actor.get_name()}")

    # Check Mesh component
    mesh_comp = actor.get_components_by_class(unreal.SkeletalMeshComponent)[0] if actor.get_components_by_class(unreal.SkeletalMeshComponent) else None
    if mesh_comp:
        sk_mesh = mesh_comp.get_skeletal_mesh_asset() if hasattr(mesh_comp, "get_skeletal_mesh_asset") else mesh_comp.get_editor_property("skeletal_mesh_asset")
        mesh_name = sk_mesh.get_name() if sk_mesh else "None"
        lines.append(f"[CHECK] SkeletalMesh: {mesh_name}")
        if mesh_name == "SKM_Manny_Simple":
            lines.append("[PASS] SkeletalMesh is correctly SKM_Manny_Simple")
        else:
            lines.append(f"[FAIL] SkeletalMesh is {mesh_name}, expected SKM_Manny_Simple")
    else:
        lines.append("[FAIL] SkeletalMeshComponent not found on spawned actor")

    # Check FallbackVisualMesh component
    static_comps = actor.get_components_by_class(unreal.StaticMeshComponent)
    fallback_comp = None
    for comp in static_comps:
        if comp.get_name() == "FallbackVisualMesh":
            fallback_comp = comp
            break

    if fallback_comp:
        is_vis = fallback_comp.is_visible()
        is_hid = fallback_comp.get_editor_property("hidden_in_game")
        lines.append(f"[CHECK] FallbackVisualMesh Visible: {is_vis}, HiddenInGame: {is_hid}")
        if not is_vis and is_hid:
            lines.append("[PASS] FallbackVisualMesh is hidden (no cube rendering)")
        else:
            lines.append(f"[FAIL] FallbackVisualMesh is visible or not hidden in game")
    else:
        lines.append("[PASS] FallbackVisualMesh not present or already destroyed")

    unreal.EditorLevelLibrary.destroy_actor(actor)
    lines.append("=== VERIFY MANNY MESH PROOF END ===")
    write_result(lines)
    return True

def write_result(lines):
    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

if __name__ == "__main__":
    main()
