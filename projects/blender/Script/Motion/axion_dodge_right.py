import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 5, 10, 16, 22)
POSES = [
    {"rotations": {"spine": (0, 0, -8), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-12, 0, 0), "upper_arm.R": (12, 0, 0)}},
    {"location": (-0.35, 0, 0), "rotations": {"spine": (0, 0, -18), "thigh.L": (12, 0, 0), "thigh.R": (-28, 0, 0), "shin.L": (15, 0, 0), "shin.R": (35, 0, 0), "upper_arm.L": (-18, 0, 0), "upper_arm.R": (22, 0, 0)}},
    {"location": (-0.75, 0, 0.02), "rotations": {"spine": (0, 0, -28), "thigh.L": (25, 0, 0), "thigh.R": (-35, 0, 0), "shin.L": (30, 0, 0), "shin.R": (60, 0, 0), "upper_arm.L": (-25, 0, 0), "upper_arm.R": (32, 0, 0)}},
    {"location": (-0.35, 0, 0), "rotations": {"spine": (0, 0, -12), "thigh.L": (28, 0, 0), "thigh.R": (-12, 0, 0), "shin.L": (55, 0, 0), "shin.R": (20, 0, 0), "upper_arm.L": (-30, 0, 0), "upper_arm.R": (18, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-12, 0, 0), "upper_arm.R": (12, 0, 0)}},
]
create_motion("axion_Dodge Right", FRAMES, POSES)
