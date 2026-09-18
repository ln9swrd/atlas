# Excelion Python Editor Automation Script
# Runs inside Unreal Editor Python environment or Python Commandlet.

import unreal

def import_fbx_mesh(fbx_file_path, destination_path, asset_name):
    """Import Skeletal/Static Mesh FBX into specified Content folder."""
    import_task = unreal.AssetImportTask()
    import_task.filename = fbx_file_path
    import_task.destination_path = destination_path
    import_task.destination_name = asset_name
    import_task.replace_existing = True
    import_task.automated = True
    import_task.save = True

    options = unreal.FbxImportUI()
    options.import_mesh = True
    options.import_as_skeletal = True
    options.import_materials = False
    options.import_textures = False

    import_task.options = options
    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([import_task])
    unreal.log(f"Imported asset {asset_name} to {destination_path}")

if __name__ == "__main__":
    unreal.log("Excelion Asset Automation initialized.")
