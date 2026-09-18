import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
create_motion("axion_Rigify Idle", (1, 31, 61), [{"hips": {"location": (0, 0, 0)}}, {"hips": {"location": (0, 0, 0.02)}}, {"hips": {"location": (0, 0, 0)}}])
