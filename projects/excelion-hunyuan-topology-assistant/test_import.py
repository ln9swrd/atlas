import sys
import os

# Add Hunyuan3D-2.1 path to sys.path for imports
HUNYUAN_ROOT = r"D:\Atlas\projects\Hunyuan3D-2.1"
sys.path.insert(0, HUNYUAN_ROOT)
sys.path.insert(0, os.path.join(HUNYUAN_ROOT, "hy3dshape"))
sys.path.insert(0, os.path.join(HUNYUAN_ROOT, "hy3dpaint"))

print("Python:", sys.version)

try:
    import torch
    print("torch:", torch.__version__)
except Exception as e:
    print("torch import error:", repr(e))

try:
    import trimesh
    print("trimesh:", trimesh.__version__)
except Exception as e:
    print("trimesh import error:", repr(e))

try:
    import hy3dshape
    print("hy3dshape import: PASS")
except Exception as e:
    print("hy3dshape import error:", repr(e))