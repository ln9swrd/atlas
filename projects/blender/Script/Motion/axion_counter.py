import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 6, 12, 18, 26)
POSES = [
    {"rotations": {"spine": (-4, 0, 0), "upper_arm.L": (-28, 0, -18), "forearm.L": (-55, 0, 0), "upper_arm.R": (28, 0, 18), "forearm.R": (55, 0, 0)}},
    {"rotations": {"spine": (0, 0, 18), "upper_arm.L": (-42, 0, -45), "forearm.L": (-72, 0, 0), "thigh.L": (24, 0, 0), "thigh.R": (-24, 0, 0)}},
    {"location": (0, 0, 0.03), "rotations": {"spine": (0, 0, -24), "upper_arm.R": (60, 0, 48), "forearm.R": (88, 0, 0), "thigh.L": (35, 0, 0), "thigh.R": (-35, 0, 0)}},
    {"rotations": {"spine": (0, 0, 8), "upper_arm.R": (32, 0, 22), "forearm.R": (50, 0, 0), "upper_arm.L": (-18, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "upper_arm.L": (-8, 0, 0), "upper_arm.R": (8, 0, 0)}},
]
create_motion("axion_Counter", FRAMES, POSES)
