import unreal

def validate_unreal_assets():
    """
    Validates Unreal Engine assets against Project Atlas Rules:
    - Path check: Finalized assets must be under /Game/Assets/[Category]/
    - Naming convention check:
      - StaticMesh: SM_ prefix
      - SkeletalMesh: SK_ prefix
      - Material: M_ prefix
      - MaterialInstanceConstant: MI_ prefix
      - Texture2D: T_ prefix, and appropriate suffix (_D, _N, _ORM, etc.)
    """
    unreal.log("=== Starting Unreal Engine Asset Validation ===")
    
    asset_registry = unreal.AssetRegistryHelpers.get_asset_registry()
    
    # Get all assets in the project (under /Game)
    all_assets = asset_registry.get_assets_by_path("/Game", recursive=True)
    
    violations_count = 0
    
    for asset in all_assets:
        package_path = str(asset.package_path)
        asset_name = str(asset.asset_name)
        asset_class = str(asset.asset_class_path.asset_name)  # e.g., 'StaticMesh', 'Texture2D'
        
        # Skip engine-defined / developer temp folders if not validating them
        if package_path.startswith("/Game/Artists/"):
            # Artists temp folders are allowed to have any naming for working assets
            continue
            
        # Ensure finalized assets are under /Game/Assets/
        if not package_path.startswith("/Game/Assets/"):
            unreal.log_warning(f"Path Violation: Asset '{asset_name}' ({asset_class}) is located outside /Game/Assets/ -> Path: {package_path}")
            violations_count += 1
            
        # Check naming rules based on asset class
        name_error = False
        expected_format = ""
        
        if asset_class == "StaticMesh":
            if not asset_name.startswith("SM_"):
                name_error = True
                expected_format = "SM_[AssetName]"
        elif asset_class == "SkeletalMesh":
            if not asset_name.startswith("SK_"):
                name_error = True
                expected_format = "SK_[AssetName]"
        elif asset_class == "Material":
            if not asset_name.startswith("M_"):
                name_error = True
                expected_format = "M_[AssetName]"
        elif asset_class == "MaterialInstanceConstant":
            if not asset_name.startswith("MI_"):
                name_error = True
                expected_format = "MI_[AssetName]"
        elif asset_class == "Texture2D":
            if not asset_name.startswith("T_"):
                name_error = True
                expected_format = "T_[AssetName]_[Suffix] (e.g. T_Brick_D)"
            else:
                # Suffix check
                valid_suffixes = ["_D", "_N", "_ORM", "_M", "_R", "_E", "_H"]
                has_suffix = any(asset_name.endswith(suf) for suf in valid_suffixes)
                if not has_suffix:
                    unreal.log_warning(f"Texture Suffix Warning: '{asset_name}' does not end with a recognized suffix ({valid_suffixes})")
                    violations_count += 1
                    
        if name_error:
            unreal.log_error(f"Naming Violation: '{asset_name}' ({asset_class}) does not match pattern '{expected_format}'")
            violations_count += 1
            
    unreal.log(f"=== Validation Finished: {violations_count} violation(s) found ===")
    return violations_count == 0

if __name__ == "__main__":
    validate_unreal_assets()
