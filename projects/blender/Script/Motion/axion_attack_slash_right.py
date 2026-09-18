import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 5, 10, 15, 20)
POSES = [
    {"rotations": {"spine": (0, 0, -12), "upper_arm.R": (35, 0, 35), "forearm.R": (55, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0)}},
    {"rotations": {"spine": (0, 0, -28), "upper_arm.R": (58, 0, 52), "forearm.R": (88, 0, 0), "thigh.L": (12, 0, 0), "thigh.R": (-28, 0, 0)}},
    {"rotations": {"spine": (0, 0, 30), "upper_arm.R": (22, 0, -38), "forearm.R": (18, 0, 0), "thigh.L": (28, 0, 0), "thigh.R": (-8, 0, 0)}},
    {"rotations": {"spine": (0, 0, 10), "upper_arm.R": (12, 0, -12), "forearm.R": (8, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "upper_arm.R": (8, 0, 0), "forearm.R": (0, 0, 0), "upper_arm.L": (-8, 0, 0)}},
]
create_motion("axion_Attack Slash Right", FRAMES, POSES)
