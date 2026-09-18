import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 5, 10, 16, 24, 32)
POSES = [
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-10, 0, 0), "upper_arm.R": (10, 0, 0)}},
    {"location": (0, 0, -0.1), "rotations": {"spine": (6, 0, 14), "thigh.L": (28, 0, 0), "thigh.R": (-12, 0, 0), "shin.L": (28, 0, 0), "shin.R": (12, 0, 0), "upper_arm.L": (-24, 0, -10), "upper_arm.R": (16, 0, 18)}},
    {"location": (0, 0, -0.18), "rotations": {"spine": (-8, 0, -18), "thigh.L": (12, 0, 0), "thigh.R": (-30, 0, 0), "shin.L": (18, 0, 0), "shin.R": (38, 0, 0), "upper_arm.L": (-12, 0, 22), "upper_arm.R": (28, 0, -18)}},
    {"location": (0, 0, -0.08), "rotations": {"spine": (4, 0, 10), "thigh.L": (22, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-18, 0, -8), "upper_arm.R": (12, 0, 14)}},
    {"rotations": {"spine": (-4, 0, -8), "thigh.L": (20, 0, 0), "thigh.R": (-20, 0, 0), "upper_arm.L": (-10, 0, 0), "upper_arm.R": (10, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-8, 0, 0), "upper_arm.R": (8, 0, 0)}},
]
create_motion("axion_Stagger", FRAMES, POSES)
