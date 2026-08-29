import unreal

bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
sk_mesh_path = "/Game/Characters/Player/Axion_Step4F/SK_Player_Axion"
tone1_path = "/Game/Characters/Player/Axion_Step4F/Tone_01_Primary"
tone2_path = "/Game/Characters/Player/Axion_Step4F/Tone_02_Secondary"
tone3_path = "/Game/Characters/Player/Axion_Step4F/Tone_03_Accent"

def main():
    bp = unreal.load_asset(bp_path)
    sk_mesh = unreal.load_asset(sk_mesh_path)
    tone1 = unreal.load_asset(tone1_path)
    tone2 = unreal.load_asset(tone2_path)
    tone3 = unreal.load_asset(tone3_path)

    print(f"BP: {bp}, SK_Mesh: {sk_mesh}")

    char_cls = unreal.load_class(None, f"{bp_path}.BP_ExcelionCharacter_C")
    cdo = unreal.get_default_object(char_cls)

    mesh_comp = cdo.get_editor_property("mesh")
    print(f"Mesh Comp: {mesh_comp}")

    # Test setting SkeletalMesh property
    try:
        mesh_comp.set_editor_property("SkeletalMesh", sk_mesh)
        print("Successfully set_editor_property('SkeletalMesh', sk_mesh)")
    except Exception as e:
        print(f"Error set_editor_property('SkeletalMesh'): {e}")

    try:
        mesh_comp.set_editor_property("OverrideMaterials", [tone1, tone2, tone3])
        print("Successfully set_editor_property('OverrideMaterials', [tone1, tone2, tone3])")
    except Exception as e:
        print(f"Error set_editor_property('OverrideMaterials'): {e}")

    # Set FallbackVisualMesh hidden
    try:
        fb_comp = cdo.get_editor_property("fallback_visual_mesh")
        fb_comp.set_editor_property("Visibility", False)
        fb_comp.set_editor_property("HiddenInGame", True)
        print("Successfully set FallbackVisualMesh Visibility=False, HiddenInGame=True")
    except Exception as e:
        print(f"Error FallbackVisualMesh: {e}")

    unreal.BlueprintEditorLibrary.compile_blueprint(bp)
    unreal.EditorAssetLibrary.save_loaded_asset(bp)
    print("Blueprint compiled and saved.")

    # Readback
    cdo_new = unreal.get_default_object(unreal.load_class(None, f"{bp_path}.BP_ExcelionCharacter_C"))
    m = cdo_new.get_editor_property("mesh")
    print(f"Readback SkeletalMesh: {m.get_editor_property('SkeletalMesh')}")
    print(f"Readback OverrideMaterials: {m.get_editor_property('OverrideMaterials')}")

main()
