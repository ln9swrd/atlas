import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 10, 20, 32, 44, 56)
POSES = [
    {"location": (0, -0.2, -0.75), "rotations": {"spine": (90, 0, 0), "thigh.L": (90, 0, 0), "thigh.R": (-90, 0, 0), "shin.L": (90, 0, 0), "shin.R": (90, 0, 0), "upper_arm.L": (90, 0, 0), "upper_arm.R": (-90, 0, 0)}},
    {"location": (0, -0.15, -0.55), "rotations": {"spine": (58, 0, 0), "thigh.L": (74, 0, 0), "thigh.R": (-74, 0, 0), "shin.L": (78, 0, 0), "shin.R": (78, 0, 0), "upper_arm.L": (64, 0, 0), "upper_arm.R": (-64, 0, 0)}},
    {"location": (0, 0, -0.25), "rotations": {"spine": (28, 0, 0), "thigh.L": (52, 0, 0), "thigh.R": (-52, 0, 0), "shin.L": (72, 0, 0), "shin.R": (72, 0, 0), "upper_arm.L": (42, 0, 0), "upper_arm.R": (-42, 0, 0)}},
    {"location": (0, 0, -0.08), "rotations": {"spine": (8, 0, 0), "thigh.L": (35, 0, 0), "thigh.R": (-35, 0, 0), "shin.L": (38, 0, 0), "shin.R": (38, 0, 0), "upper_arm.L": (-18, 0, 0), "upper_arm.R": (18, 0, 0)}},
    {"location": (0, 0, 0), "rotations": {"spine": (-4, 0, 0), "thigh.L": (22, 0, 0), "thigh.R": (-22, 0, 0), "shin.L": (22, 0, 0), "shin.R": (22, 0, 0), "upper_arm.L": (-12, 0, 0), "upper_arm.R": (12, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-8, 0, 0), "upper_arm.R": (8, 0, 0)}},
]
create_motion("axion_Get Up", FRAMES, POSES)
