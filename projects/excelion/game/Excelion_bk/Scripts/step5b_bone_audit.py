import unreal
import os

skel_path = "/Game/Characters/Player/Axion_Step4F/SK_Player_Axion_Skeleton"
anim_path = "/Game/Characters/Player/Axion_Step4F/AXION_Test_InPlace_Anim"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\step5b_bone_results.txt"

def main():
    lines = []
    lines.append("=== BONE HIERARCHY AUDIT START ===")

    skel = unreal.load_asset(skel_path)
    anim = unreal.load_asset(anim_path)

    if anim:
        try:
            tracks = unreal.AnimationLibrary.get_animation_track_names(anim)
            lines.append(f"Anim Track Count: {len(tracks)}")
            lines.append(f"Root Track Name: {tracks[0] if len(tracks)>0 else 'None'}")
            lines.append("First 15 bone tracks in animation:")
            for i, t in enumerate(tracks[:15]):
                lines.append(f"  Track[{i}]: {t}")
        except Exception as e:
            lines.append(f"get_animation_track_names error: {e}")

    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

main()
