import unreal
import os

abp_path = "/Game/Characters/Player/Axion_Step4F/ABP_Axion"
anim_path = "/Game/Characters/Player/Axion_Step4F/AXION_Test_InPlace_Anim"
out_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\populate_abp_out.txt"

def main():
    lines = []
    lines.append("=== POPULATE ABP GRAPH START ===")
    
    abp = unreal.load_asset(abp_path)
    anim = unreal.load_asset(anim_path)

    lines.append(f"ABP: {abp}")
    lines.append(f"Anim: {anim}")

    # Inspect abp methods for graph manipulation
    for prop in dir(abp):
        if not prop.startswith("_"):
            try:
                val = getattr(abp, prop)
                if not callable(val):
                    lines.append(f"  abp.{prop} = {val}")
            except Exception:
                pass

    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

main()
