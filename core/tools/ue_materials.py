import sys
import unreal

def validate_ue_materials():
    """
    Validates that:
    1. StaticMesh assets only use Material Instances (MI_...), not raw Materials (M_...).
    2. SkeletalMesh assets only use Material Instances (MI_...), not raw Materials (M_...).
    3. Material Instance Constant assets have a valid parent material interface.
    """
    unreal.log("=== Starting Unreal Engine Material Instance Validation ===")
    
    asset_registry = unreal.AssetRegistryHelpers.get_asset_registry()
    all_assets = asset_registry.get_assets_by_path("/Game", recursive=True)
    
    violations_count = 0
    
    for asset in all_assets:
        package_path = str(asset.package_path)
        asset_name = str(asset.asset_name)
        asset_class = str(asset.asset_class_path.asset_name)
        
        # Skip artist folders/working directory
        if package_path.startswith("/Game/Artists/"):
            continue
            
        # Only validate finalized assets under /Game/Assets/
        if not package_path.startswith("/Game/Assets/"):
            continue

        asset_full_path = f"{package_path}/{asset_name}"
        
        if asset_class == "StaticMesh":
            mesh_obj = unreal.load_asset(asset_full_path)
            if not mesh_obj:
                unreal.log_warning(f"Could not load StaticMesh asset: {asset_full_path}")
                continue
                
            # Check static materials
            static_materials = mesh_obj.static_materials
            for i, static_mat in enumerate(static_materials):
                mat_interface = static_mat.material_interface
                if not mat_interface:
                    unreal.log_warning(f"StaticMesh '{asset_name}' has empty material slot {i}")
                    continue
                
                mat_name = mat_interface.get_name()
                if not mat_name.startswith("MI_"):
                    unreal.log_error(f"Material Violation: StaticMesh '{asset_name}' slot {i} uses raw/non-MI material '{mat_name}'. Must use a Material Instance (MI_...).")
                    violations_count += 1
                    
        elif asset_class == "SkeletalMesh":
            mesh_obj = unreal.load_asset(asset_full_path)
            if not mesh_obj:
                unreal.log_warning(f"Could not load SkeletalMesh asset: {asset_full_path}")
                continue
                
            # Check skeletal materials
            materials = mesh_obj.materials
            for i, skeletal_mat in enumerate(materials):
                mat_interface = skeletal_mat.material_interface
                if not mat_interface:
                    unreal.log_warning(f"SkeletalMesh '{asset_name}' has empty material slot {i}")
                    continue
                    
                mat_name = mat_interface.get_name()
                if not mat_name.startswith("MI_"):
                    unreal.log_error(f"Material Violation: SkeletalMesh '{asset_name}' slot {i} uses raw/non-MI material '{mat_name}'. Must use a Material Instance (MI_...).")
                    violations_count += 1
                    
        elif asset_class == "MaterialInstanceConstant":
            mi_obj = unreal.load_asset(asset_full_path)
            if not mi_obj:
                unreal.log_warning(f"Could not load MaterialInstanceConstant asset: {asset_full_path}")
                continue
                
            # Check if parent is set
            parent = mi_obj.parent
            if not parent:
                unreal.log_error(f"Material Instance Violation: '{asset_name}' has no parent material.")
                violations_count += 1

    unreal.log(f"=== Material Instance Validation Finished: {violations_count} violation(s) found ===")
    return violations_count == 0

if __name__ == "__main__":
    success = validate_ue_materials()
    if not success:
        sys.exit(1)
