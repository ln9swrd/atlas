# Excelion Unreal Editor 5.4 — Enhanced Input Assets Creation & CDO Wiring Automation Script
import unreal

def create_or_load_input_action(name, value_type=None):
    package_path = "/Game/Input"
    if not unreal.EditorAssetLibrary.does_directory_exist(package_path):
        unreal.EditorAssetLibrary.make_directory(package_path)
    
    asset_path = f"{package_path}/{name}"
    if unreal.EditorAssetLibrary.does_asset_exist(asset_path):
        unreal.log(f"[Excelion] InputAction already exists: {asset_path}")
        return unreal.EditorAssetLibrary.load_asset(asset_path)
    
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    factory = unreal.InputActionFactory() if hasattr(unreal, "InputActionFactory") else None
    
    ia = asset_tools.create_asset(name, package_path, unreal.InputAction, factory)
    if ia:
        if value_type is not None and hasattr(ia, "set_editor_property"):
            try:
                ia.set_editor_property("value_type", value_type)
            except Exception as e:
                unreal.log_warning(f"[Excelion] Note setting value_type on {name}: {e}")
        unreal.EditorAssetLibrary.save_asset(asset_path)
        unreal.log(f"[Excelion] Successfully created InputAction: {asset_path}")
    else:
        unreal.log_error(f"[Excelion] Failed to create InputAction: {asset_path}")
    return ia

def create_or_load_mapping_context(name):
    package_path = "/Game/Input"
    if not unreal.EditorAssetLibrary.does_directory_exist(package_path):
        unreal.EditorAssetLibrary.make_directory(package_path)
        
    asset_path = f"{package_path}/{name}"
    if unreal.EditorAssetLibrary.does_asset_exist(asset_path):
        unreal.log(f"[Excelion] InputMappingContext already exists: {asset_path}")
        return unreal.EditorAssetLibrary.load_asset(asset_path)
        
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    factory = unreal.InputMappingContextFactory() if hasattr(unreal, "InputMappingContextFactory") else None
    
    imc = asset_tools.create_asset(name, package_path, unreal.InputMappingContext, factory)
    if imc:
        unreal.EditorAssetLibrary.save_asset(asset_path)
        unreal.log(f"[Excelion] Successfully created InputMappingContext: {asset_path}")
    else:
        unreal.log_error(f"[Excelion] Failed to create InputMappingContext: {asset_path}")
    return imc

def wire_input_assets_to_character():
    unreal.log("=== Excelion Enhanced Input Wiring Started ===")
    
    # Value types
    axis2d_type = getattr(unreal, "EInputActionValueType", None)
    if axis2d_type and hasattr(axis2d_type, "AXIS2D"):
        axis2d_val = axis2d_type.AXIS2D
        bool_val = axis2d_type.BOOLEAN
    elif hasattr(unreal, "InputActionValueType"):
        axis2d_val = getattr(unreal.InputActionValueType, "AXIS2D", None)
        bool_val = getattr(unreal.InputActionValueType, "BOOLEAN", None)
    else:
        axis2d_val = None
        bool_val = None

    ia_move = create_or_load_input_action("IA_Move", axis2d_val)
    ia_look = create_or_load_input_action("IA_Look", axis2d_val)
    ia_attack = create_or_load_input_action("IA_Attack", bool_val)
    ia_dash = create_or_load_input_action("IA_Dash", bool_val)
    imc_default = create_or_load_mapping_context("IMC_Default")

    bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
    bp_class_path = f"{bp_path}.BP_ExcelionCharacter_C"
    
    bp_class = unreal.load_object(None, bp_class_path)
    if not bp_class:
        unreal.log_error(f"[Excelion FAIL] BP_ExcelionCharacter class not found at {bp_class_path}")
        return False
        
    cdo = unreal.get_default_object(bp_class)
    if not cdo:
        unreal.log_error(f"[Excelion FAIL] CDO not found for {bp_class.get_name()}")
        return False

    if imc_default:
        cdo.set_editor_property("default_mapping_context", imc_default)
    if ia_move:
        cdo.set_editor_property("move_action", ia_move)
    if ia_look:
        cdo.set_editor_property("look_action", ia_look)
    if ia_attack:
        cdo.set_editor_property("attack_action", ia_attack)
    if ia_dash:
        cdo.set_editor_property("dash_action", ia_dash)

    bp_asset = unreal.EditorAssetLibrary.load_asset(bp_path)
    if bp_asset:
        unreal.EditorAssetLibrary.save_loaded_asset(bp_asset)
    unreal.log(f"[Excelion PASS] All Input Assets wired to BP_ExcelionCharacter CDO!")
    return True

if __name__ == "__main__":
    wire_input_assets_to_character()
