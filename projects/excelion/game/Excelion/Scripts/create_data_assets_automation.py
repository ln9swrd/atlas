# Excelion Unreal Editor 5.4 — Mecha Data Asset Auto-Creation Script
import unreal

def create_mecha_data_asset(asset_name, package_path, mecha_id, category_val, max_hp, armor, scale_meters, attack_power):
    if not unreal.EditorAssetLibrary.does_directory_exist(package_path):
        unreal.EditorAssetLibrary.make_directory(package_path)
        
    asset_path = f"{package_path}/{asset_name}"
    if unreal.EditorAssetLibrary.does_asset_exist(asset_path):
        unreal.log(f"[Excelion] Data Asset already exists: {asset_path}")
        return unreal.EditorAssetLibrary.load_asset(asset_path)
        
    factory = unreal.DataAssetFactory()
    factory.set_editor_property('data_asset_class', unreal.ExcelionMechaDataAsset)
    
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    new_asset = asset_tools.create_asset(
        asset_name=asset_name,
        package_path=package_path,
        asset_class=unreal.ExcelionMechaDataAsset,
        factory=factory
    )
    
    if new_asset:
        base_stats = unreal.ExcelionMechaBaseStats()
        base_stats.mecha_id = mecha_id
        base_stats.category = category_val
        base_stats.max_hp = max_hp
        base_stats.armor = armor
        base_stats.scale = scale_meters
        base_stats.attack_power = attack_power
        
        new_asset.set_editor_property('base_stats', base_stats)
        unreal.EditorAssetLibrary.save_loaded_asset(new_asset)
        unreal.log(f"[Excelion] Successfully created & saved Mecha Data Asset: {asset_path}")
    else:
        unreal.log_error(f"[Excelion] Failed to create Mecha Data Asset: {asset_path}")
        
    return new_asset

def main():
    unreal.log("=== Excelion Data Asset Automation Started ===")
    
    create_mecha_data_asset(
        asset_name="DA_AXION_Stats",
        package_path="/Game/Data",
        mecha_id="axion-001",
        category_val=unreal.ExcelionMechaCategory.PLAYER,
        max_hp=100.0,
        armor=10.0,
        scale_meters=25.0,
        attack_power=25.0
    )
    
    create_mecha_data_asset(
        asset_name="DA_SethBoss_Stats",
        package_path="/Game/Data",
        mecha_id="seth-001",
        category_val=unreal.ExcelionMechaCategory.BOSS,
        max_hp=480.0,
        armor=20.0,
        scale_meters=30.0,
        attack_power=55.0
    )
    
    unreal.log("=== Excelion Data Asset Automation Completed ===")

if __name__ == "__main__":
    main()
