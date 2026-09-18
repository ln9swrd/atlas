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
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-16, 0, -18), "forearm.L": (-42, 0, 0), "upper_arm.R": (16, 0, 18), "forearm.R": (42, 0, 0)}},
    {"location": (0, 0, -0.05), "rotations": {"spine": (-8, 0, 0), "thigh.L": (30, 0, 0), "thigh.R": (-30, 0, 0), "shin.L": (22, 0, 0), "shin.R": (22, 0, 0), "upper_arm.L": (-28, 0, -24), "forearm.L": (-68, 0, 0), "upper_arm.R": (28, 0, 24), "forearm.R": (68, 0, 0)}},
    {"location": (0, 0, -0.08), "rotations": {"spine": (-10, 0, 0), "thigh.L": (34, 0, 0), "thigh.R": (-34, 0, 0), "shin.L": (28, 0, 0), "shin.R": (28, 0, 0), "upper_arm.L": (-32, 0, -26), "forearm.L": (-78, 0, 0), "upper_arm.R": (32, 0, 26), "forearm.R": (78, 0, 0)}},
    {"rotations": {"spine": (0, 0, 0), "thigh.L": (18, 0, 0), "thigh.R": (-18, 0, 0), "upper_arm.L": (-16, 0, -18), "forearm.L": (-42, 0, 0), "upper_arm.R": (16, 0, 18), "forearm.R": (42, 0, 0)}},
]
create_motion("axion_Guard", FRAMES, POSES)
