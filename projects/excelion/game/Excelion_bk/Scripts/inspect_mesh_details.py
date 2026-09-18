# Detailed inspection of SKM_Manny_Simple vs SK_Player_Axion
import unreal
import os

result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\inspect_mesh_details_results.txt"

def main():
    lines = []
    lines.append("=== INSPECT MESH DETAILS START ===")

    # 1. SKM_Manny_Simple
    manny_path = "/Game/Characters/SKM_Manny_Simple"
    manny = unreal.EditorAssetLibrary.load_asset(manny_path)
    if manny:
        lines.append(f"SKM_Manny_Simple Loaded: True ({manny.get_class().get_name()})")
        skel = manny.get_editor_property("skeleton") if hasattr(manny, "get_editor_property") else None
        lines.append(f"SKM_Manny_Simple Skeleton: {skel.get_name() if skel else 'None'}")
    else:
        lines.append("SKM_Manny_Simple Loaded: False")

    # 2. SK_Player_Axion
    axion_path = "/Game/Characters/Player/Axion_Step4F/SK_Player_Axion"
    axion = unreal.EditorAssetLibrary.load_asset(axion_path)
    if axion:
        lines.append(f"SK_Player_Axion Loaded: True ({axion.get_class().get_name()})")
        skel_ax = axion.get_editor_property("skeleton") if hasattr(axion, "get_editor_property") else None
        lines.append(f"SK_Player_Axion Skeleton: {skel_ax.get_name() if skel_ax else 'None'} ({skel_ax.get_path_name() if skel_ax else 'None'})")
    else:
        lines.append("SK_Player_Axion Loaded: False")

    # 3. Check ABP_Axion
    abp_path = "/Game/Characters/Player/Axion_Step4F/ABP_Axion"
    abp = unreal.EditorAssetLibrary.load_asset(abp_path)
    if abp:
        lines.append(f"ABP_Axion Loaded: True ({abp.get_class().get_name()})")
        abp_cls = unreal.load_class(None, f"{abp_path}.ABP_Axion_C")
        lines.append(f"ABP_Axion_C Class Loaded: {abp_cls is not None}")
    else:
        lines.append("ABP_Axion Loaded: False")

    # 4. Check BP_ExcelionCharacter CDO components and transform
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
    char_cls = unreal.load_class(None, f"{bp_char_path}.BP_ExcelionCharacter_C")
    if char_cls:
        cdo = unreal.get_default_object(char_cls)
        m = cdo.get_editor_property("mesh")
        if m:
            sk = m.get_skeletal_mesh_asset() if hasattr(m, "get_skeletal_mesh_asset") else None
            anim_cls = m.get_editor_property("anim_class")
            rot = m.get_editor_property("relative_rotation")
            loc = m.get_editor_property("relative_location")
            lines.append(f"BP_ExcelionCharacter CDO Mesh Asset: {sk.get_name() if sk else 'None'}")
            lines.append(f"BP_ExcelionCharacter CDO AnimClass: {anim_cls.get_name() if anim_cls else 'None'}")
            lines.append(f"BP_ExcelionCharacter CDO Mesh Loc: ({loc.x}, {loc.y}, {loc.z})")
            lines.append(f"BP_ExcelionCharacter CDO Mesh Rot: (Pitch={rot.pitch}, Yaw={rot.yaw}, Roll={rot.roll})")

    write_result(lines)

def write_result(lines):
    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

if __name__ == "__main__":
    main()
