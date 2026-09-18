import bpy
print(\
Blender:\, bpy.app.version_string)
print()
armatures = [o for o in bpy.context.scene.objects if o.type == 'MESH']
for obj in armatures:
    if 'meta' in obj.name.lower():
        print('Metarig:', obj.name)
        bpy.ops.object.mode_set(mode='EDIT')
        for bone in obj.data.bones:
            tag = ' [FACE]' if any(k in bone.name.lower() for k in ['face','eye','lip','jaw','mouth','tongue']) else ''
            print('  ', bone.name + tag)
bpy.ops.object.mode_set(mode='OBJECT')
