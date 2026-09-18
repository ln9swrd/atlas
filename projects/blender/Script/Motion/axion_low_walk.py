import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 7, 13, 19, 25, 31)
POSES = [
    {"location": (0, 0, -0.12), "rotations": {"spine": (18, 0, 0), "thigh.L": (34, 0, 0), "thigh.R": (-30, 0, 0), "shin.L": (46, 0, 0), "shin.R": (-6, 0, 0), "upper_arm.L": (-18, 0, 0), "upper_arm.R": (18, 0, 0)}},
    {"location": (0, 0, -0.12), "rotations": {"spine": (18, 0, 0), "thigh.L": (8, 0, 0), "thigh.R": (30, 0, 0), "shin.L": (-6, 0, 0), "shin.R": (46, 0, 0), "upper_arm.L": (18, 0, 0), "upper_arm.R": (-18, 0, 0)}},
    {"location": (0, 0, -0.12), "rotations": {"spine": (18, 0, 0), "thigh.L": (-30, 0, 0), "thigh.R": (34, 0, 0), "shin.L": (-6, 0, 0), "shin.R": (46, 0, 0), "upper_arm.L": (18, 0, 0), "upper_arm.R": (-18, 0, 0)}},
    {"location": (0, 0, -0.12), "rotations": {"spine": (18, 0, 0), "thigh.L": (30, 0, 0), "thigh.R": (8, 0, 0), "shin.L": (46, 0, 0), "shin.R": (-6, 0, 0), "upper_arm.L": (-18, 0, 0), "upper_arm.R": (18, 0, 0)}},
    {"location": (0, 0, -0.12), "rotations": {"spine": (18, 0, 0), "thigh.L": (34, 0, 0), "thigh.R": (-30, 0, 0), "shin.L": (46, 0, 0), "shin.R": (-6, 0, 0), "upper_arm.L": (-18, 0, 0), "upper_arm.R": (18, 0, 0)}},
    {"location": (0, 0, -0.12), "rotations": {"spine": (18, 0, 0), "thigh.L": (8, 0, 0), "thigh.R": (30, 0, 0), "shin.L": (-6, 0, 0), "shin.R": (46, 0, 0), "upper_arm.L": (18, 0, 0), "upper_arm.R": (-18, 0, 0)}},
]
create_motion("axion_Low Walk", FRAMES, POSES)
