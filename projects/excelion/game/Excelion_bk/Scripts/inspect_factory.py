import unreal
import os

out_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\factory_props.txt"

def main():
    factory = unreal.AnimBlueprintFactory()
    lines = ["=== AnimBlueprintFactory Properties ==="]
    for prop in dir(factory):
        if not prop.startswith("_"):
            try:
                val = getattr(factory, prop)
                lines.append(f"  {prop} = {val}")
            except Exception as e:
                lines.append(f"  {prop} (Err: {e})")

    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

main()
