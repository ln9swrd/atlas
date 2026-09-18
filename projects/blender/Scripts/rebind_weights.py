import bpy

def rebind_automatic_weights():
    arm = bpy.data.objects.get('metarig')
    if not arm:
        return
        
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='OBJECT')
    
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
    bound_meshes = []
    
    for mesh in meshes:
        has_armature = False
        for mod in mesh.modifiers:
            if mod.type == 'ARMATURE' and mod.object == arm:
                has_armature = True
                break
                
        if has_armature:
            bound_meshes.append(mesh)
            
    if not bound_meshes:
        print("No meshes found bound to metarig.")
        return
        
    print(f"Found {len(bound_meshes)} meshes to rebind.")
    
    for mesh in bound_meshes:
        print(f"Rebinding weights for: {mesh.name}")
        
        # 1. Clear existing vertex groups (the old twisted weights)
        mesh.vertex_groups.clear()
        
        # 2. Remove old Armature modifier to prevent duplicates
        for mod in mesh.modifiers:
            if mod.type == 'ARMATURE':
                mesh.modifiers.remove(mod)
                
        # 3. Clear existing parent just in case
        old_parent = mesh.parent
        if old_parent:
            mat = mesh.matrix_world.copy()
            mesh.parent = None
            mesh.matrix_world = mat
            
        # 4. Rebind with Automatic Weights
        bpy.ops.object.select_all(action='DESELECT')
        mesh.select_set(True)
        arm.select_set(True)
        bpy.context.view_layer.objects.active = arm
        
        bpy.ops.object.parent_set(type='ARMATURE_AUTO')
        
        # 5. Re-enable Preserve Volume on the new modifier
        for mod in mesh.modifiers:
            if mod.type == 'ARMATURE':
                mod.use_deform_preserve_volume = True

    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("ALL MESHES REBOUND WITH NEW AUTOMATIC WEIGHTS.")

if __name__ == "__main__":
    rebind_automatic_weights()
