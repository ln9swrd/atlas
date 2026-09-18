# Excelion C++ Class-to-Blueprint Automation Generator
# Executes inside Unreal Editor Python Environment or via Commandlet

import unreal

def create_blueprint_from_cpp(cpp_class_name, destination_folder, bp_name):
    """Creates a Blueprint subclassing from a native C++ class."""
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    factory = unreal.BlueprintFactory()
    
    # Try finding native class
    native_class = unreal.find_class(cpp_class_name)
    if not native_class:
        unreal.log_warning(f"Could not find class {cpp_class_name}. Make sure C++ module is loaded.")
        return None

    factory.set_editor_property("parent_class", native_class)
    
    created_bp = asset_tools.create_asset(
        asset_name=bp_name,
        package_path=destination_folder,
        asset_class=unreal.Blueprint,
        factory=factory
    )
    if created_bp:
        unreal.log(f"Successfully generated Blueprint {bp_name} in {destination_folder}")
    return created_bp

if __name__ == "__main__":
    unreal.log("Excelion Blueprint Automation Initialized.")
    # Target Blueprint Generations:
    # create_blueprint_from_cpp("ExcelionCharacter", "/Game/Excelion/Blueprints/Player", "BP_ExcelionCharacter")
    # create_blueprint_from_cpp("SethBoss", "/Game/Excelion/Blueprints/Boss", "BP_SethBoss")
