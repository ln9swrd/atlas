# Excelion Unreal Editor 5.4 — UMG HUD Widget Blueprint Auto-Creation Script
import unreal

def create_hud_widget_blueprint():
    package_path = "/Game/UI"
    asset_name = "WBP_ExcelionHUD"
    
    if not unreal.EditorAssetLibrary.does_directory_exist(package_path):
        unreal.EditorAssetLibrary.make_directory(package_path)
        
    asset_path = f"{package_path}/{asset_name}"
    if unreal.EditorAssetLibrary.does_asset_exist(asset_path):
        unreal.log(f"[Excelion] UMG Widget Blueprint already exists: {asset_path}")
        return unreal.EditorAssetLibrary.load_asset(asset_path)
        
    parent_class = getattr(unreal, "ExcelionHUDWidget", None)
    if not parent_class:
        unreal.log_error("[Excelion] Parent C++ class 'ExcelionHUDWidget' not found.")
        return None
        
    factory = unreal.WidgetBlueprintFactory()
    factory.set_editor_property('parent_class', parent_class)
    
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    new_wbp = asset_tools.create_asset(
        asset_name=asset_name,
        package_path=package_path,
        asset_class=unreal.WidgetBlueprint,
        factory=factory
    )
    
    if new_wbp:
        unreal.log(f"[Excelion] Successfully created UMG HUD Widget Blueprint: {asset_path}")
        unreal.EditorAssetLibrary.save_asset(asset_path)
    else:
        unreal.log_error(f"[Excelion] Failed to create UMG HUD Widget Blueprint: {asset_path}")
        
    return new_wbp

if __name__ == "__main__":
    create_hud_widget_blueprint()
