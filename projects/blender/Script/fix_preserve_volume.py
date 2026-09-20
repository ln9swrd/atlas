import bpy

def fix_preserve_volume():
    fixed_count = 0
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
    
    for mesh in meshes:
        for mod in mesh.modifiers:
            if mod.type == 'ARMATURE':
                if not mod.use_deform_preserve_volume:
                    mod.use_deform_preserve_volume = True
                    fixed_count += 1
                    
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print(f"Fixed {fixed_count} Armature Modifiers (Enabled Preserve Volume).")

if __name__ == "__main__":
    fix_preserve_volume()
