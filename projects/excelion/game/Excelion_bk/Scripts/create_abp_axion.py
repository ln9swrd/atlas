import unreal
import os

skel_path = "/Game/Characters/Player/Axion_Step4F/SK_Player_Axion_Skeleton"
anim_path = "/Game/Characters/Player/Axion_Step4F/AXION_Test_InPlace_Anim"
bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
abp_package = "/Game/Characters/Player/Axion_Step4F"
abp_name = "ABP_Axion"
abp_path = f"{abp_package}/{abp_name}"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\step5b_creation_results.txt"

def main():
    lines = []
    lines.append("=== STEP 5-B CREATION START ===")

    # 1. Load Skeleton & Anim
    skel = unreal.load_asset(skel_path)
    anim = unreal.load_asset(anim_path)

    lines.append(f"Loaded Skeleton: {skel is not None}")
    lines.append(f"Loaded Anim Sequence: {anim is not None}")

    if not (skel and anim):
        lines.append("ERROR: Failed to load Skeleton or AnimSequence.")
        write_result(lines)
        return False

    # 2. Check if ABP_Axion already exists, delete or load
    if unreal.EditorAssetLibrary.does_asset_exist(abp_path):
        lines.append(f"Asset {abp_path} already exists. Loading existing...")
        abp = unreal.load_asset(abp_path)
    else:
        lines.append(f"Creating new AnimBlueprint at {abp_path}...")
        factory = unreal.AnimBlueprintFactory()
        factory.set_editor_property("target_skeleton", skel)
        factory.set_editor_property("parent_class", unreal.AnimInstance.static_class())

        asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
        abp = asset_tools.create_asset(asset_name=abp_name, package_path=abp_package, asset_class=unreal.AnimBlueprint, factory=factory)
        lines.append(f"Created AnimBlueprint: {abp is not None}")

    if not abp:
        lines.append("ERROR: AnimBlueprint creation failed.")
        write_result(lines)
        return False

    # 3. Verify ABP target skeleton
    try:
        ts = abp.get_editor_property("target_skeleton")
        lines.append(f"ABP Target Skeleton: {ts.get_name() if ts else 'None'}")
    except Exception as e:
        lines.append(f"ABP target_skeleton query: {e}")

    # 4. Compile & Save AnimBP
    try:
        unreal.BlueprintEditorLibrary.compile_blueprint(abp)
        lines.append("Compiled ABP_Axion successfully.")
    except Exception as e:
        lines.append(f"compile_blueprint error: {e}")

    saved_abp = unreal.EditorAssetLibrary.save_loaded_asset(abp)
    lines.append(f"save_loaded_asset(abp) result: {saved_abp}")

    # 5. Wire ABP_Axion to BP_ExcelionCharacter AnimClass
    bp = unreal.load_asset(bp_path)
    lines.append(f"Loaded BP_ExcelionCharacter: {bp is not None}")

    if bp:
        abp_generated_class = unreal.load_class(None, f"{abp_path}.ABP_Axion_C")
        lines.append(f"Loaded ABP_Axion_C Generated Class: {abp_generated_class is not None}")

        if abp_generated_class:
            char_cls = unreal.load_class(None, f"{bp_path}.BP_ExcelionCharacter_C")
            cdo = unreal.get_default_object(char_cls)

            mesh_comp = cdo.get_editor_property("mesh") if cdo else None
            lines.append(f"Character Mesh Component: {mesh_comp is not None}")

            if mesh_comp:
                try:
                    mesh_comp.set_editor_property("AnimationMode", unreal.AnimationMode.ANIM_BLUEPRINT)
                    lines.append("Set AnimationMode = ANIM_BLUEPRINT")
                except Exception as e:
                    lines.append(f"AnimationMode set error: {e}")

                try:
                    mesh_comp.set_editor_property("AnimClass", abp_generated_class)
                    lines.append("Set AnimClass = ABP_Axion_C")
                except Exception as e:
                    lines.append(f"AnimClass set error: {e}")

                try:
                    mesh_comp.set_anim_instance_class(abp_generated_class)
                    lines.append("Executed set_anim_instance_class(abp_generated_class)")
                except Exception as e:
                    lines.append(f"set_anim_instance_class error: {e}")

            # Also set template on BP ComponentTemplates
            comps = getattr(bp, "component_templates", None) or getattr(bp, "ComponentTemplates", None)
            if comps:
                for c in comps:
                    if c.get_name() in ["CharacterMesh0", "MeshComponent", "Mesh"] or isinstance(c, unreal.SkeletalMeshComponent):
                        try:
                            c.set_editor_property("AnimationMode", unreal.AnimationMode.ANIM_BLUEPRINT)
                            c.set_editor_property("AnimClass", abp_generated_class)
                            lines.append(f"Set AnimClass on template {c.get_name()}")
                        except Exception as e:
                            lines.append(f"Template AnimClass set error: {e}")

            # Compile & Save BP_ExcelionCharacter
            unreal.BlueprintEditorLibrary.compile_blueprint(bp)
            saved_bp = unreal.EditorAssetLibrary.save_loaded_asset(bp)
            lines.append(f"Saved BP_ExcelionCharacter result: {saved_bp}")

    write_result(lines)
    return True

def write_result(lines):
    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

main()
