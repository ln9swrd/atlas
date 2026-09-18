import unreal
import os

result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\step5f_source_results.txt"

def main():
    lines = []
    lines.append("=== STEP 5-F SOURCE ANIMATION INVESTIGATION START ===")

    # 1. Inspect Engine / ControlRig / FeaturePack / Game AnimSequences
    asset_registry = unreal.AssetRegistryHelpers.get_asset_registry()
    top_level_anim_seq = unreal.TopLevelAssetPath("/Script/Engine", "AnimSequence")
    anim_assets = asset_registry.get_assets_by_class(top_level_anim_seq)

    lines.append(f"Total AnimSequence Assets Discovered in UE Project/Engine: {len(anim_assets)}")

    by_category = {
        "Engine": [],
        "Characters": [],
        "ThirdPerson": [],
        "Other": []
    }

    for a in anim_assets:
        pkg = str(a.package_name)
        name = str(a.asset_name)
        info = f"{name} ({pkg})"
        if "/Engine/" in pkg:
            by_category["Engine"].append(info)
        elif "/Characters/" in pkg:
            by_category["Characters"].append(info)
        elif "ThirdPerson" in pkg or "Mannequin" in pkg or "Manny" in pkg:
            by_category["ThirdPerson"].append(info)
        else:
            by_category["Other"].append(info)

    for cat, items in by_category.items():
        lines.append(f"\n--- Category: {cat} (Count: {len(items)}) ---")
        for item in items[:15]:  # print first 15 of each
            lines.append(f"  - {item}")
        if len(items) > 15:
            lines.append(f"  ... and {len(items) - 15} more")

    # 2. Check Skeletons in Engine / Game
    top_level_skel = unreal.TopLevelAssetPath("/Script/Engine", "Skeleton")
    skel_assets = asset_registry.get_assets_by_class(top_level_skel)
    lines.append(f"\n--- Skeleton Assets Count: {len(skel_assets)} ---")
    for s in skel_assets:
        lines.append(f"  - Skeleton: {s.asset_name} ({s.package_name})")

    lines.append("\n==========================================================================")
    lines.append("   STEP 5-F SOURCE ANIMATION INVESTIGATION COMPLETED")
    lines.append("==========================================================================\n")

    write_result(lines)

def write_result(lines):
    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

main()
