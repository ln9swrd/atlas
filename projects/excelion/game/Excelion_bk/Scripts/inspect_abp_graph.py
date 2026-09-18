import unreal
import os

abp_path = "/Game/Characters/Player/Axion_Step4F/ABP_Axion"
anim_path = "/Game/Characters/Player/Axion_Step4F/AXION_Test_InPlace_Anim"
out_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\inspect_abp_graph_out.txt"

def main():
    lines = []
    lines.append("=== INSPECT ABP GRAPH START ===")
    
    abp = unreal.load_asset(abp_path)
    anim = unreal.load_asset(anim_path)
    lines.append(f"Loaded ABP: {abp}")

    # Inspect function graphs / anim graphs
    if abp:
        # Check all properties on abp
        for prop in dir(abp):
            if "graph" in prop.lower() or "node" in prop.lower() or "anim" in prop.lower():
                try:
                    val = getattr(abp, prop)
                    if not callable(val):
                        lines.append(f"  abp.{prop} = {val}")
                except Exception:
                    pass

        # Try to inspect AnimGraph nodes or setting default sequence player
        # In UE AnimBlueprint, AnimGraph is accessible via get_editor_property("ubg_graphs") or function_graphs or SCS
        try:
            ubg_graphs = abp.get_editor_property("ubg_graphs") if hasattr(abp, "get_editor_property") else []
            lines.append(f"UBG Graphs Count: {len(ubg_graphs)}")
            for g in ubg_graphs:
                lines.append(f"  Graph: {g.get_name()}")
                if hasattr(g, "get_editor_property"):
                    try:
                        nodes = g.get_editor_property("nodes")
                        lines.append(f"    Nodes Count: {len(nodes)}")
                        for n in nodes:
                            lines.append(f"      Node: {n.get_name()} ({n.get_class().get_name()})")
                    except Exception as e:
                        lines.append(f"    Nodes err: {e}")
        except Exception as e:
            lines.append(f"ubg_graphs err: {e}")

    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

main()
