bl_info = {
    "name": "ParaModel",
    "author": "Atlas / Excelion",
    "version": (0, 7, 1),
    "blender": (3, 6, 0),
    "location": "View3D > Sidebar > ParaModel",
    "description": "Parametric mecha loader — archetype/size contract, slots, SuperRobotRig, mesh import",
    "category": "Object",
}

import bpy
from . import operators
from . import panels
from . import props


def register():
    props.register()
    operators.register()
    panels.register()
    print("ParaModel addon registered (v0.7.1)")


def unregister():
    panels.unregister()
    operators.unregister()
    props.unregister()
    print("ParaModel addon unregistered")


if __name__ == "__main__":
    register()
