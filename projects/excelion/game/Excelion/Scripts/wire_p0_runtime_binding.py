# Excelion Unreal Editor 5.4 — P0 Runtime Binding CDO Wiring Script
import unreal

def wire_p0_runtime_binding():
    unreal.log("=== P0 Runtime Binding CDO Wiring Started ===")
    
    # 1. Ensure /Game/Data/DA_AXION_Stats exists
    data_dir = "/Game/Data"
    da_path = f"{data_dir}/DA_AXION_Stats"
    
    if not unreal.EditorAssetLibrary.does_directory_exist(data_dir):
        unreal.EditorAssetLibrary.make_directory(data_dir)
        
    da_asset = None
    if unreal.EditorAssetLibrary.does_asset_exist(da_path):
        da_asset = unreal.EditorAssetLibrary.load_asset(da_path)
        unreal.log(f"[P0-RB] Found existing DA_AXION_Stats: {da_path}")
    else:
        factory = unreal.DataAssetFactory()
        factory.set_editor_property('data_asset_class', unreal.ExcelionMechaDataAsset)
        asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
        da_asset = asset_tools.create_asset(
            asset_name="DA_AXION_Stats",
            package_path=data_dir,
            asset_class=unreal.ExcelionMechaDataAsset,
            factory=factory
        )
        if da_asset:
            stats = unreal.ExcelionMechaBaseStats()
            stats.mecha_id = "axion-001"
            stats.category = unreal.ExcelionMechaCategory.PLAYER
            stats.max_hp = 100.0
            stats.attack_power = 25.0
            stats.move_speed = 600.0
            stats.armor = 10.0
            stats.scale = 25.0
            da_asset.set_editor_property('base_stats', stats)
            unreal.EditorAssetLibrary.save_loaded_asset(da_asset)
            unreal.log(f"[P0-RB] Created & saved DA_AXION_Stats: {da_path}")
            
    if not da_asset:
        unreal.log_error(f"[P0-RB FAIL] Could not load or create DA_AXION_Stats asset at {da_path}")
        return False
        
    # 2. Bind DA_AXION_Stats to BP_ExcelionCharacter CDO
    bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
    bp_class_path = f"{bp_path}.BP_ExcelionCharacter_C"
    
    bp_class = unreal.load_object(None, bp_class_path)
    if not bp_class:
        unreal.log_error(f"[P0-RB FAIL] BP_ExcelionCharacter class not found at {bp_class_path}")
        return False
        
    cdo = unreal.get_default_object(bp_class)
    if not cdo:
        unreal.log_error(f"[P0-RB FAIL] Could not get CDO for {bp_class_path}")
        return False

    cdo.set_editor_property("mecha_data_asset", da_asset)
    
    bp_asset = unreal.EditorAssetLibrary.load_asset(bp_path)
    if bp_asset:
        unreal.EditorAssetLibrary.save_loaded_asset(bp_asset)
        
    unreal.log(f"[P0-RB PASS] Successfully bound DA_AXION_Stats to BP_ExcelionCharacter CDO!")
    return True

if __name__ == "__main__":
    wire_p0_runtime_binding()
