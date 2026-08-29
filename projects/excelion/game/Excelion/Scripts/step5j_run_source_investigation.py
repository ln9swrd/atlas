import unreal
import os

result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\step5j_source_results.txt"

def main():
    lines = []
    lines.append("=== STEP 5-J RUNNING MOTION SOURCE INVESTIGATION START ===")

    asset_registry = unreal.AssetRegistryHelpers.get_asset_registry()
    top_level_anim_seq = unreal.TopLevelAssetPath("/Script/Engine", "AnimSequence")
    anim_assets = asset_registry.get_assets_by_class(top_level_anim_seq)

    lines.append(f"Total AnimSequence Assets Found: {len(anim_assets)}")

    run_candidates = []
    all_anims = []

    for a in anim_assets:
        pkg = str(a.package_name)
        name = str(a.asset_name)
        info = f"{name} ({pkg})"
        all_anims.append(info)
        
        name_lower = name.lower()
        if "run" in name_lower or "jog" in name_lower or "sprint" in name_lower or "fast" in name_lower:
            run_candidates.append(info)

    lines.append(f"\n--- RUN/JOG/SPRINT Candidate Assets Count: {len(run_candidates)} ---")
    for rc in run_candidates:
        lines.append(f"  - Candidate: {rc}")

    lines.append("\n--- All Available AnimSequences ---")
    for item in all_anims:
        lines.append(f"  - {item}")

    lines.append("\n==========================================================================")
    lines.append("   STEP 5-J SOURCE INVESTIGATION COMPLETED")
    lines.append("==========================================================================\n")

    write_result(lines)

def write_result(lines):
    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

main()
