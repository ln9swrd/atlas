import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,5,10,16,22)
POSES=[{"torso":{"rotation":(-8,0,0)}},{"torso":{"rotation":(-14,0,0)},"hips":{"location":(0,0,0.05)},"hand_ik.L":{"location":(0,0,0.15)},"hand_ik.R":{"location":(0,0,0.15)}},{"torso":{"rotation":(-18,0,0)},"hips":{"location":(0,0,0.1)},"thigh_ik.L":{"location":(0,0,0.12)},"thigh_ik.R":{"location":(0,0,0.12)}},{"torso":{"rotation":(-8,0,0)}},{}]
create_motion("axion_Rigify Dash Forward",FRAMES,POSES)
