import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 8, 16, 24)
POSES = [
    {"rotations": {"spine": (0, 0, 0), "upper_arm.L": (-8, 0, 0), "upper_arm.R": (8, 0, 0), "forearm.L": (0, 0, 0), "forearm.R": (0, 0, 0)}},
    {"rotations": {"spine": (-4, 0, 0), "upper_arm.L": (-30, 0, -12), "upper_arm.R": (30, 0, 12), "forearm.L": (-35, 0, 0), "forearm.R": (35, 0, 0)}},
    {"rotations": {"spine": (-8, 0, 0), "upper_arm.L": (-48, 0, -18), "upper_arm.R": (48, 0, 18), "forearm.L": (-72, 0, 0), "forearm.R": (72, 0, 0)}},
    {"rotations": {"spine": (-6, 0, 0), "upper_arm.L": (-42, 0, -14), "upper_arm.R": (42, 0, 14), "forearm.L": (-64, 0, 0), "forearm.R": (64, 0, 0)}},
]
create_motion("axion_Blade Deploy", FRAMES, POSES)
