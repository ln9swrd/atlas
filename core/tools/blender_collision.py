import sys
import os

try:
    import bpy
    import mathutils
except ImportError:
    # Allow importing outside Blender for rule_engine syntax/simulation checks
    bpy = None
    mathutils = None

def create_ubx(obj, index_str="00"):
    """
    Creates an oriented bounding box (UBX) collision geometry for the mesh object.
    """
    if not obj or obj.type != 'MESH':
        print(f"Error: Object {obj} is not a valid mesh.")
        return None

    # Get local bounding box coordinates
    bbox = obj.bound_box
    min_x = min(p[0] for p in bbox)
    max_x = max(p[0] for p in bbox)
    min_y = min(p[1] for p in bbox)
    max_y = max(p[1] for p in bbox)
    min_z = min(p[2] for p in bbox)
    max_z = max(p[2] for p in bbox)
    
    size_x = max_x - min_x
    size_y = max_y - min_y
    size_z = max_z - min_z
    
    # Local center
    center_local = mathutils.Vector((
        (min_x + max_x) / 2.0,
        (min_y + max_y) / 2.0,
        (min_z + max_z) / 2.0
    ))
    
    # Create cube primitive
    bpy.ops.mesh.primitive_cube_add(size=1.0)
    box_obj = bpy.context.active_object
    
    # Scale cube to match bounding box dimensions
    box_obj.scale = (size_x, size_y, size_z)
    
    # Position cube relative to object world space transforms
    center_world = obj.matrix_world @ center_local
    box_obj.location = center_world
    box_obj.rotation_euler = obj.rotation_euler
    
    # Name the collision hull: UBX_SM_[AssetName]_[Index]
    box_obj.name = f"UBX_{obj.name}_{index_str}"
    
    # Link to all collections containing original object
    for col in obj.users_collection:
        if col not in box_obj.users_collection:
            col.objects.link(box_obj)
            
    # Unlink from active collection if it's not where original object belongs
    active_col = bpy.context.collection
    if active_col not in obj.users_collection:
        try:
            active_col.objects.unlink(box_obj)
        except Exception:
            pass
            
    # Apply transforms so pivot aligns to (0, 0, 0)
    bpy.ops.object.select_all(action='DESELECT')
    box_obj.select_set(True)
    bpy.context.view_layer.objects.active = box_obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    
    print(f"[SUCCESS] Generated UBX Collision: {box_obj.name}")
    return box_obj

def create_ucx(obj, index_str="00"):
    """
    Creates a convex hull (UCX) collision geometry by duplicating the mesh and applying convex hull.
    """
    if not obj or obj.type != 'MESH':
        print(f"Error: Object {obj} is not a valid mesh.")
        return None

    # Duplicate target object
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    
    bpy.ops.object.duplicate(linked=False)
    ucx_obj = bpy.context.active_object
    
    # Rename to UCX_SM_[AssetName]_[Index]
    ucx_obj.name = f"UCX_{obj.name}_{index_str}"
    
    # Perform Convex Hull operation in Edit Mode
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.convex_hull()
    bpy.ops.object.mode_set(mode='OBJECT')
    
    # Apply transforms so pivot aligns to (0, 0, 0)
    bpy.ops.object.select_all(action='DESELECT')
    ucx_obj.select_set(True)
    bpy.context.view_layer.objects.active = ucx_obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    
    print(f"[SUCCESS] Generated UCX Collision: {ucx_obj.name}")
    return ucx_obj

def create_usp(obj, index_str="00"):
    """
    Creates a sphere (USP) collision geometry for the mesh object.
    """
    if not obj or obj.type != 'MESH':
        print(f"Error: Object {obj} is not a valid mesh.")
        return None

    # Get local bounding box coordinates
    bbox = obj.bound_box
    min_x = min(p[0] for p in bbox)
    max_x = max(p[0] for p in bbox)
    min_y = min(p[1] for p in bbox)
    max_y = max(p[1] for p in bbox)
    min_z = min(p[2] for p in bbox)
    max_z = max(p[2] for p in bbox)
    
    size_x = max_x - min_x
    size_y = max_y - min_y
    size_z = max_z - min_z
    
    # Radius is half of the maximum dimension
    radius = max(size_x, size_y, size_z) / 2.0
    
    # Local center
    center_local = mathutils.Vector((
        (min_x + max_x) / 2.0,
        (min_y + max_y) / 2.0,
        (min_z + max_z) / 2.0
    ))
    
    # Create UV sphere primitive
    bpy.ops.mesh.primitive_uv_sphere_add(radius=radius, segments=16, ring_count=8)
    sphere_obj = bpy.context.active_object
    
    # Position sphere relative to object world space transforms
    center_world = obj.matrix_world @ center_local
    sphere_obj.location = center_world
    sphere_obj.rotation_euler = obj.rotation_euler
    
    # Name the collision hull: USP_SM_[AssetName]_[Index]
    sphere_obj.name = f"USP_{obj.name}_{index_str}"
    
    # Link to all collections containing original object
    for col in obj.users_collection:
        if col not in sphere_obj.users_collection:
            col.objects.link(sphere_obj)
            
    # Unlink from active collection if it's not where original object belongs
    active_col = bpy.context.collection
    if active_col not in obj.users_collection:
        try:
            active_col.objects.unlink(sphere_obj)
        except Exception:
            pass
            
    # Apply transforms so pivot aligns to (0, 0, 0)
    bpy.ops.object.select_all(action='DESELECT')
    sphere_obj.select_set(True)
    bpy.context.view_layer.objects.active = sphere_obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    
    print(f"[SUCCESS] Generated USP Collision: {sphere_obj.name}")
    return sphere_obj

def create_ucp(obj, index_str="00"):
    """
    Creates a capsule (UCP) collision geometry for the mesh object.
    Capsule is modeled as a cylinder capped with two hemispheres.
    """
    if not obj or obj.type != 'MESH':
        print(f"Error: Object {obj} is not a valid mesh.")
        return None

    # Get local bounding box coordinates
    bbox = obj.bound_box
    min_x = min(p[0] for p in bbox)
    max_x = max(p[0] for p in bbox)
    min_y = min(p[1] for p in bbox)
    max_y = max(p[1] for p in bbox)
    min_z = min(p[2] for p in bbox)
    max_z = max(p[2] for p in bbox)
    
    size_x = max_x - min_x
    size_y = max_y - min_y
    size_z = max_z - min_z
    
    # Capsule dimensions along Z axis
    radius = max(size_x, size_y) / 2.0
    height = size_z
    
    # Ensure radius is not larger than half height to avoid invalid shape
    if radius * 2.0 > height:
        radius = height / 2.0
        
    cylinder_height = max(0.0, height - (radius * 2.0))
    
    # Local center
    center_local = mathutils.Vector((
        (min_x + max_x) / 2.0,
        (min_y + max_y) / 2.0,
        (min_z + max_z) / 2.0
    ))
    
    created_objects = []
    
    # Create the cylinder body
    if cylinder_height > 0:
        bpy.ops.mesh.primitive_cylinder_add(radius=radius, depth=cylinder_height, vertices=16)
        cyl_obj = bpy.context.active_object
        created_objects.append(cyl_obj)
        
        # Create top dome
        bpy.ops.mesh.primitive_uv_sphere_add(radius=radius, segments=16, ring_count=8)
        top_sphere = bpy.context.active_object
        top_sphere.location.z = cylinder_height / 2.0
        created_objects.append(top_sphere)
        
        # Create bottom dome
        bpy.ops.mesh.primitive_uv_sphere_add(radius=radius, segments=16, ring_count=8)
        bot_sphere = bpy.context.active_object
        bot_sphere.location.z = -cylinder_height / 2.0
        created_objects.append(bot_sphere)
    else:
        # Just create a sphere
        bpy.ops.mesh.primitive_uv_sphere_add(radius=radius, segments=16, ring_count=8)
        sphere_obj = bpy.context.active_object
        created_objects.append(sphere_obj)
        
    # Deselect all
    bpy.ops.object.select_all(action='DESELECT')
    
    # Select all parts and join them
    for part in created_objects:
        part.select_set(True)
    bpy.context.view_layer.objects.active = created_objects[0]
    bpy.ops.object.join()
    
    capsule_obj = bpy.context.active_object
    
    # Position capsule relative to object world space transforms
    center_world = obj.matrix_world @ center_local
    capsule_obj.location = center_world
    capsule_obj.rotation_euler = obj.rotation_euler
    
    # Name the collision hull: UCP_SM_[AssetName]_[Index]
    capsule_obj.name = f"UCP_{obj.name}_{index_str}"
    
    # Link to all collections containing original object
    for col in obj.users_collection:
        if col not in capsule_obj.users_collection:
            col.objects.link(capsule_obj)
            
    # Unlink from active collection if it's not where original object belongs
    active_col = bpy.context.collection
    if active_col not in obj.users_collection:
        try:
            active_col.objects.unlink(capsule_obj)
        except Exception:
            pass
            
    # Apply transforms so pivot aligns to (0, 0, 0)
    bpy.ops.object.select_all(action='DESELECT')
    capsule_obj.select_set(True)
    bpy.context.view_layer.objects.active = capsule_obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    
    print(f"[SUCCESS] Generated UCP Collision: {capsule_obj.name}")
    return capsule_obj

def run_generator(collision_type="box", index="00"):
    if not bpy:
        print("[INFO] Not running in Blender. Validation simulation pass.")
        return
        
    print(f"=== Starting Auto Collision Generation ({collision_type.upper()}) ===")
    
    selected_objects = [obj for obj in bpy.context.selected_objects if obj.type == 'MESH']
    
    if not selected_objects:
        print("[WARN] No mesh objects selected in Blender. Generating placeholder for active scene meshes.")
        selected_objects = [obj for obj in bpy.data.objects if obj.type == 'MESH' and not (obj.name.startswith("UBX_") or obj.name.startswith("UCX_") or obj.name.startswith("USP_") or obj.name.startswith("UCP_"))]
        
    if not selected_objects:
        print("[ERROR] No suitable meshes found for collision generation.")
        return
        
    for obj in selected_objects:
        print(f"Generating collision for mesh: {obj.name}")
        if collision_type == "box":
            create_ubx(obj, index)
        elif collision_type == "convex":
            create_ucx(obj, index)
        elif collision_type == "sphere":
            create_usp(obj, index)
        elif collision_type == "capsule":
            create_ucp(obj, index)
        else:
            print(f"[ERROR] Unknown collision type: {collision_type}")

    print("=== Auto Collision Generation Finished ===")


if __name__ == "__main__":
    # Parse custom arguments passed after '--'
    col_type = "box"
    col_index = "00"
    
    if "--" in sys.argv:
        args = sys.argv[sys.argv.index("--") + 1:]
        for i, arg in enumerate(args):
            if arg == "--type" and i + 1 < len(args):
                col_type = args[i + 1].lower()
            elif arg == "--index" and i + 1 < len(args):
                col_index = args[i + 1]

    run_generator(col_type, col_index)
