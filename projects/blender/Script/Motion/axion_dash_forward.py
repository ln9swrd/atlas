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
    {"location": (0, 0, 0), "rotations": {"spine": (-8, 0, 0), "thigh.L": (25, 0, 0), "thigh.R": (-25, 0, 0), "shin.L": (-15, 0, 0), "shin.R": (45, 0, 0), "upper_arm.L": (-25, 0, 0), "upper_arm.R": (25, 0, 0)}},
    {"location": (0, 0, 0.03), "rotations": {"spine": (-12, 0, 0), "thigh.L": (45, 0, 0), "thigh.R": (-20, 0, 0), "shin.L": (-25, 0, 0), "shin.R": (68, 0, 0), "upper_arm.L": (-38, 0, 0), "upper_arm.R": (38, 0, 0)}},
    {"location": (0, 0, 0.05), "rotations": {"spine": (-15, 0, 0), "thigh.L": (12, 0, 0), "thigh.R": (-12, 0, 0), "shin.L": (70, 0, 0), "shin.R": (70, 0, 0), "upper_arm.L": (-45, 0, 0), "upper_arm.R": (45, 0, 0)}},
    {"location": (0, 0, 0), "rotations": {"spine": (-8, 0, 0), "thigh.L": (-20, 0, 0), "thigh.R": (45, 0, 0), "shin.L": (68, 0, 0), "shin.R": (-25, 0, 0), "upper_arm.L": (38, 0, 0), "upper_arm.R": (-38, 0, 0)}},
    {"location": (0, 0, 0), "rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "shin.L": (18, 0, 0), "shin.R": (18, 0, 0), "upper_arm.L": (-12, 0, 0), "upper_arm.R": (12, 0, 0)}},
]
create_motion("axion_Dash Forward", FRAMES, POSES)
