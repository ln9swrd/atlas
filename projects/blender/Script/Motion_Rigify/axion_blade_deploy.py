import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,8,16,24)
POSES=[{}, {"torso":{"rotation":(-4,0,0)},"hand_ik.L":{"location":(-0.15,0,0.1)},"hand_ik.R":{"location":(0.15,0,0.1)}}, {"torso":{"rotation":(-8,0,0)},"hand_ik.L":{"location":(-0.3,0,0.2),"rotation":(-35,0,-18)},"hand_ik.R":{"location":(0.3,0,0.2),"rotation":(-35,0,18)}}, {"hand_ik.L":{"location":(-0.2,0,0.12)},"hand_ik.R":{"location":(0.2,0,0.12)}}]
create_motion("axion_Rigify Blade Deploy",FRAMES,POSES)
