import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 5, 11, 18, 26, 34)
POSES = [
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-10, 0, 0), "upper_arm.R": (10, 0, 0)}},
    {"location": (0, -0.18, 0.05), "rotations": {"spine": (12, 0, 0), "thigh.L": (28, 0, 0), "thigh.R": (-28, 0, 0), "shin.L": (42, 0, 0), "shin.R": (42, 0, 0), "upper_arm.L": (35, 0, 0), "upper_arm.R": (-35, 0, 0)}},
    {"location": (0, -0.55, 0.12), "rotations": {"spine": (22, 0, 0), "thigh.L": (-18, 0, 0), "thigh.R": (18, 0, 0), "shin.L": (60, 0, 0), "shin.R": (60, 0, 0), "upper_arm.L": (58, 0, 0), "upper_arm.R": (-58, 0, 0)}},
    {"location": (0, -0.82, 0.04), "rotations": {"spine": (30, 0, 0), "thigh.L": (-35, 0, 0), "thigh.R": (35, 0, 0), "shin.L": (72, 0, 0), "shin.R": (72, 0, 0), "upper_arm.L": (72, 0, 0), "upper_arm.R": (-72, 0, 0)}},
    {"location": (0, -0.4, 0), "rotations": {"spine": (12, 0, 0), "thigh.L": (24, 0, 0), "thigh.R": (-24, 0, 0), "upper_arm.L": (30, 0, 0), "upper_arm.R": (-30, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-8, 0, 0), "upper_arm.R": (8, 0, 0)}},
]
create_motion("axion_Knockback", FRAMES, POSES)
