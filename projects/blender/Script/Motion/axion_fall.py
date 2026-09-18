import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 8, 16, 26, 38)
POSES = [
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-10, 0, 0), "upper_arm.R": (10, 0, 0)}},
    {"location": (0, 0, -0.18), "rotations": {"spine": (10, 0, 0), "thigh.L": (38, 0, 0), "thigh.R": (-38, 0, 0), "shin.L": (62, 0, 0), "shin.R": (62, 0, 0), "upper_arm.L": (35, 0, 0), "upper_arm.R": (-35, 0, 0)}},
    {"location": (0, 0, -0.52), "rotations": {"spine": (28, 0, 0), "thigh.L": (72, 0, 0), "thigh.R": (-72, 0, 0), "shin.L": (88, 0, 0), "shin.R": (88, 0, 0), "upper_arm.L": (58, 0, 0), "upper_arm.R": (-58, 0, 0)}},
    {"location": (0, -0.15, -0.75), "rotations": {"spine": (70, 0, 0), "thigh.L": (88, 0, 0), "thigh.R": (-88, 0, 0), "shin.L": (100, 0, 0), "shin.R": (100, 0, 0), "upper_arm.L": (75, 0, 0), "upper_arm.R": (-75, 0, 0)}},
    {"location": (0, -0.2, -0.75), "rotations": {"spine": (90, 0, 0), "thigh.L": (90, 0, 0), "thigh.R": (-90, 0, 0), "shin.L": (90, 0, 0), "shin.R": (90, 0, 0), "upper_arm.L": (90, 0, 0), "upper_arm.R": (-90, 0, 0)}},
]
create_motion("axion_Fall", FRAMES, POSES)
