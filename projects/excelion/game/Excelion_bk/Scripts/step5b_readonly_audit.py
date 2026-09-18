import unreal
import os

anim_path = "/Game/Characters/Player/Axion_Step4F/AXION_Test_InPlace_Anim"
skel_path = "/Game/Characters/Player/Axion_Step4F/SK_Player_Axion_Skeleton"
mesh_path = "/Game/Characters/Player/Axion_Step4F/SK_Player_Axion"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\step5b_audit_results.txt"

def main():
    lines = []
    lines.append("=== STEP 5-B READ-ONLY AUDIT START ===")

    # 1. Existing AnimBP Check
    existing_abp = unreal.EditorAssetLibrary.does_asset_exist("/Game/Characters/Player/Axion_Step4F/ABP_Axion")
    lines.append(f"Existing ABP_Axion Asset Exists: {existing_abp}")

    # 2. Skeleton Audit
    skel = unreal.load_asset(skel_path)
    mesh = unreal.load_asset(mesh_path)
    lines.append(f"SK_Player_Axion_Skeleton Loaded: {skel is not None} ({skel.get_name() if skel else 'None'})")
    lines.append(f"SK_Player_Axion Mesh Loaded: {mesh is not None}")

    # 3. Animation Sequence Audit
    anim = unreal.load_asset(anim_path)
    lines.append(f"AXION_Test_InPlace_Anim Loaded: {anim is not None} ({anim.get_name() if anim else 'None'})")

    if anim and isinstance(anim, unreal.AnimSequence):
        try:
            seq_len = anim.get_play_length() if hasattr(anim, "get_play_length") else "N/A"
            anim_skel = anim.get_editor_property("skeleton")
            lines.append(f"Anim Sequence Length: {seq_len:.4f}s")
            lines.append(f"Anim Connected Skeleton: {anim_skel.get_name() if anim_skel else 'None'}")
            rate = anim.get_editor_property("target_frame_rate") if hasattr(anim, "get_editor_property") else "N/A"
            lines.append(f"Target Frame Rate: {rate}")
        except Exception as e:
            lines.append(f"Anim Sequence details: {e}")

    # 4. Skeleton Hierarchy verification via AnimSequence bone tracks
    if anim:
        try:
            num_tracks = anim.get_num_animation_tracks() if hasattr(anim, "get_num_animation_tracks") else "N/A"
            lines.append(f"Anim Track Count: {num_tracks}")
        except Exception as e:
            lines.append(f"Anim Track query: {e}")

    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

main()
