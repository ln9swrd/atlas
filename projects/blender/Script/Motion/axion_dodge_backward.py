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
    {"rotations": {"spine": (4, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-12, 0, 0), "upper_arm.R": (12, 0, 0)}},
    {"location": (0, -0.25, 0), "rotations": {"spine": (12, 0, 0), "thigh.L": (-20, 0, 0), "thigh.R": (20, 0, 0), "shin.L": (38, 0, 0), "shin.R": (38, 0, 0), "upper_arm.L": (25, 0, 0), "upper_arm.R": (-25, 0, 0)}},
    {"location": (0, -0.65, 0.04), "rotations": {"spine": (18, 0, 0), "thigh.L": (-35, 0, 0), "thigh.R": (35, 0, 0), "shin.L": (72, 0, 0), "shin.R": (72, 0, 0), "upper_arm.L": (38, 0, 0), "upper_arm.R": (-38, 0, 0)}},
    {"location": (0, -0.25, 0), "rotations": {"spine": (8, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "shin.L": (28, 0, 0), "shin.R": (28, 0, 0), "upper_arm.L": (-18, 0, 0), "upper_arm.R": (18, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-12, 0, 0), "upper_arm.R": (12, 0, 0)}},
]
create_motion("axion_Dodge Backward", FRAMES, POSES)
