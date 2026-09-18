import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 5, 10, 16, 24)
POSES = [
    {"location": (0, 0, 1.0), "rotations": {"spine": (0, 0, 0), "thigh.L": (8, 0, 0), "thigh.R": (-8, 0, 0), "shin.L": (12, 0, 0), "shin.R": (12, 0, 0), "upper_arm.L": (-28, 0, 0), "upper_arm.R": (28, 0, 0)}},
    {"location": (0, 0, 0.4), "rotations": {"spine": (-4, 0, 0), "thigh.L": (22, 0, 0), "thigh.R": (-22, 0, 0), "shin.L": (34, 0, 0), "shin.R": (34, 0, 0), "upper_arm.L": (-38, 0, 0), "upper_arm.R": (38, 0, 0)}},
    {"location": (0, 0, -0.25), "rotations": {"spine": (-12, 0, 0), "thigh.L": (48, 0, 0), "thigh.R": (-48, 0, 0), "shin.L": (78, 0, 0), "shin.R": (78, 0, 0), "upper_arm.L": (-48, 0, 0), "upper_arm.R": (48, 0, 0)}},
    {"location": (0, 0, -0.12), "rotations": {"spine": (-7, 0, 0), "thigh.L": (34, 0, 0), "thigh.R": (-34, 0, 0), "shin.L": (54, 0, 0), "shin.R": (54, 0, 0), "upper_arm.L": (-32, 0, 0), "upper_arm.R": (32, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-10, 0, 0), "upper_arm.R": (10, 0, 0)}},
]
create_motion("axion_Heavy Landing", FRAMES, POSES)
