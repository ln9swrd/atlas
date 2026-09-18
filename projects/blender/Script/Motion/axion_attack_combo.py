import bpy
import sys
from pathlib import Path

motion_dir = Path(bpy.data.filepath).parent / "Script" / "Motion"
if not bpy.data.filepath:
    motion_dir = Path(r"D:\Atlas\projects\blender\Script\Motion")
sys.path.insert(0, str(motion_dir))
from axion_motion_common import create_motion

FRAMES = (1, 6, 12, 18, 24, 30, 36, 42)
POSES = [
    {"rotations": {"spine": (0, 0, 8), "upper_arm.L": (-30, 0, -28), "forearm.L": (-48, 0, 0), "upper_arm.R": (16, 0, 0)}},
    {"rotations": {"spine": (0, 0, -22), "upper_arm.L": (-16, 0, 32), "forearm.L": (-8, 0, 0), "upper_arm.R": (45, 0, 40), "forearm.R": (65, 0, 0)}},
    {"rotations": {"spine": (0, 0, 24), "upper_arm.L": (-48, 0, -42), "forearm.L": (-72, 0, 0), "upper_arm.R": (10, 0, 0)}},
    {"rotations": {"spine": (0, 0, -28), "upper_arm.R": (58, 0, 50), "forearm.R": (82, 0, 0), "upper_arm.L": (-12, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "upper_arm.L": (-24, 0, -18), "forearm.L": (-36, 0, 0), "upper_arm.R": (24, 0, 18), "forearm.R": (36, 0, 0)}},
    {"location": (0, 0, 0.05), "rotations": {"spine": (-12, 0, 0), "thigh.L": (35, 0, 0), "thigh.R": (-35, 0, 0), "upper_arm.L": (-48, 0, -28), "forearm.L": (-80, 0, 0), "upper_arm.R": (48, 0, 28), "forearm.R": (80, 0, 0)}},
    {"location": (0, 0, 0.02), "rotations": {"spine": (8, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-18, 0, 0), "upper_arm.R": (18, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "upper_arm.L": (-8, 0, 0), "upper_arm.R": (8, 0, 0)}},
]
create_motion("axion_Attack Combo", FRAMES, POSES)
