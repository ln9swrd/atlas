import bpy

def fix_foot_weights():
    # Fix the rigid weights for the 'Foot' mesh
    foot_obj = bpy.data.objects.get('Foot')
    if not foot_obj:
        print("Mesh 'Foot' not found!")
        return
        
    bpy.context.view_layer.objects.active = foot_obj
    bpy.ops.object.mode_set(mode='OBJECT')
    
    # Clear all vertex groups
    foot_obj.vertex_groups.clear()
    
    # Create groups for foot.L and foot.R
    vg_l = foot_obj.vertex_groups.new(name="foot.L")
    vg_r = foot_obj.vertex_groups.new(name="foot.R")
    
    # Iterate through vertices. Since X > 0 is Left in Blender (usually),
    # we assign vertices based on their local X coordinate.
    for v in foot_obj.data.vertices:
        if v.co.x > 0.01:
            vg_l.add([v.index], 1.0, 'REPLACE')
        elif v.co.x < -0.01:
            vg_r.add([v.index], 1.0, 'REPLACE')
            
    print("Rigid weights applied to 'Foot' mesh.")
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)

if __name__ == "__main__":
    fix_foot_weights()
