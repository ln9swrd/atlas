# Excelion Unreal Editor 5.4 — BP_DummyTarget Creation Automation Script
import unreal

def create_dummy_target_blueprint():
    unreal.log("=== Excelion Dummy Target Creation Started ===")
    
    package_path = "/Game/Blueprints"
    asset_name = "BP_DummyTarget"
    
    if not unreal.EditorAssetLibrary.does_directory_exist(package_path):
        unreal.EditorAssetLibrary.make_directory(package_path)
        
    asset_path = f"{package_path}/{asset_name}"
    if unreal.EditorAssetLibrary.does_asset_exist(asset_path):
        unreal.log(f"[Excelion] BP_DummyTarget already exists: {asset_path}")
        return unreal.EditorAssetLibrary.load_asset(asset_path)
        
    parent_class = getattr(unreal, "ExcelionDummyTarget", None)
    if not parent_class:
        unreal.log_error("[Excelion FAIL] Parent C++ class 'ExcelionDummyTarget' not found in unreal module.")
        return None
        
    factory = unreal.BlueprintFactory()
    factory.set_editor_property('parent_class', parent_class)
    
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    new_bp = asset_tools.create_asset(
        asset_name=asset_name,
        package_path=package_path,
        asset_class=unreal.Blueprint,
        factory=factory
    )
    
    if new_bp:
        unreal.log(f"[Excelion PASS] Successfully created BP_DummyTarget derived from C++ ExcelionDummyTarget: {asset_path}")
        unreal.EditorAssetLibrary.save_asset(asset_path)
    else:
        unreal.log_error(f"[Excelion FAIL] Failed to create BP_DummyTarget: {asset_path}")
        
    return new_bp

if __name__ == "__main__":
    create_dummy_target_blueprint()
