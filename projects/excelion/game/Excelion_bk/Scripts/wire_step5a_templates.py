import unreal
import os

bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
sk_mesh_path = "/Game/Characters/Player/Axion_Step4F/SK_Player_Axion"
tone1_path = "/Game/Characters/Player/Axion_Step4F/Tone_01_Primary"
tone2_path = "/Game/Characters/Player/Axion_Step4F/Tone_02_Secondary"
tone3_path = "/Game/Characters/Player/Axion_Step4F/Tone_03_Accent"

def main():
    lines = []
    lines.append("=== WIRE TEMPLATES START ===")
    
    bp = unreal.load_asset(bp_path)
    sk_mesh = unreal.load_asset(sk_mesh_path)
    tone1 = unreal.load_asset(tone1_path)
    tone2 = unreal.load_asset(tone2_path)
    tone3 = unreal.load_asset(tone3_path)

    lines.append(f"Loaded BP: {bp is not None}")
    lines.append(f"Loaded Assets: Mesh={sk_mesh is not None}, T1={tone1 is not None}, T2={tone2 is not None}, T3={tone3 is not None}")

    # Inspect component templates
    comps = getattr(bp, "component_templates", None) or getattr(bp, "ComponentTemplates", None)
    if comps is None:
        try:
            comps = bp.get_editor_property("component_templates")
        except Exception as e:
            lines.append(f"Error getting component_templates: {e}")

    lines.append(f"Component Templates: {comps}")
    if comps:
        for c in comps:
            c_name = c.get_name()
            c_cls = c.get_class().get_name()
            lines.append(f"  Template: {c_name} ({c_cls})")

            if c_name in ["CharacterMesh0", "MeshComponent", "Mesh"] or isinstance(c, unreal.SkeletalMeshComponent):
                try:
                    if hasattr(c, "set_skeletal_mesh_asset"):
                        c.set_skeletal_mesh_asset(sk_mesh)
                    else:
                        c.set_editor_property("skeletal_mesh_asset", sk_mesh)
                    lines.append(f"    Set SkeletalMeshAsset on {c_name}")
                except Exception as e:
                    lines.append(f"    SkeletalMeshAsset err: {e}")

                try:
                    c.set_material(0, tone1)
                    c.set_material(1, tone2)
                    c.set_material(2, tone3)
                    lines.append(f"    Set materials 0, 1, 2 on {c_name}")
                except Exception as e:
                    lines.append(f"    Set material err: {e}")

                try:
                    c.set_editor_property("override_materials", [tone1, tone2, tone3])
                    lines.append(f"    Set override_materials on {c_name}")
                except Exception as e:
                    lines.append(f"    Override materials err: {e}")

            elif "Fallback" in c_name or isinstance(c, unreal.StaticMeshComponent):
                try:
                    c.set_editor_property("hidden_in_game", True)
                    c.set_editor_property("visible", False)
                    lines.append(f"    Set HiddenInGame=True on {c_name}")
                except Exception as e:
                    lines.append(f"    Fallback set err: {e}")

    # Compile & Save
    try:
        unreal.BlueprintEditorLibrary.compile_blueprint(bp)
        lines.append("Compiled BP")
    except Exception as e:
        lines.append(f"Compile err: {e}")

    saved = unreal.EditorAssetLibrary.save_loaded_asset(bp)
    lines.append(f"Saved BP: {saved}")

    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)

main()
