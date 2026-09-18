# Excelion Unreal Editor 5.4 — C++ Derived Blueprint Auto-Creation Script
# Can be run via Unreal Editor Python Console or '-ExecutePythonScript' commandlet

import unreal

def create_blueprint_asset(asset_name, package_path, parent_class_name, is_widget=False):
    """
    Creates a Blueprint asset derived from the specified C++ parent class.
    """
    if not unreal.EditorAssetLibrary.does_directory_exist(package_path):
        unreal.EditorAssetLibrary.make_directory(package_path)
    
    asset_path = f"{package_path}/{asset_name}"
    
    if unreal.EditorAssetLibrary.does_asset_exist(asset_path):
        unreal.log(f"[Excelion] Blueprint already exists: {asset_path}")
        return unreal.EditorAssetLibrary.load_asset(asset_path)
    
    parent_class = getattr(unreal, parent_class_name, None)
    if not parent_class:
        unreal.log_error(f"[Excelion] Parent C++ class '{parent_class_name}' not found in unreal module.")
        return None
    
    if is_widget:
        factory = unreal.WidgetBlueprintFactory()
        factory.set_editor_property('parent_class', parent_class)
        asset_class = unreal.WidgetBlueprint
    else:
        factory = unreal.BlueprintFactory()
        factory.set_editor_property('parent_class', parent_class)
        asset_class = unreal.Blueprint
    
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    new_bp = asset_tools.create_asset(
        asset_name=asset_name,
        package_path=package_path,
        asset_class=asset_class,
        factory=factory
    )
    
    if new_bp:
        unreal.log(f"[Excelion] Successfully created Blueprint: {asset_path}")
        unreal.EditorAssetLibrary.save_asset(asset_path)
    else:
        unreal.log_error(f"[Excelion] Failed to create Blueprint: {asset_path}")
    
    return new_bp


def main():
    unreal.log("=== Excelion Blueprint Automation Started ===")
    
    bp_specs = [
        ("BP_ExcelionCharacter", "/Game/Blueprints", "ExcelionCharacter", False),
        ("BP_SethBoss", "/Game/Blueprints", "SethBoss", False),
        ("BP_ExcelionEnemy", "/Game/Blueprints", "ExcelionEnemy", False),
        ("BP_PowerEnemy", "/Game/Blueprints", "PowerEnemy", False),
        ("BP_SpeedEnemy", "/Game/Blueprints", "SpeedEnemy", False),
        ("BP_ExcelionGameMode", "/Game/Blueprints", "ExcelionGameMode", False),
        ("WBP_ExcelionHUD", "/Game/Blueprints", "ExcelionHUDWidget", True),
    ]
    
    for name, path, parent, is_wbp in bp_specs:
        create_blueprint_asset(name, path, parent, is_wbp)
        
    unreal.log("=== Excelion Blueprint Automation Completed ===")


if __name__ == "__main__":
    main()
