import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,5,10,16,22)
POSES=[{}, {"torso":{"rotation":(0,0,18)},"hips":{"location":(0.25,0,0)}}, {"torso":{"rotation":(0,0,30)},"hips":{"location":(0.7,0,0)},"hand_ik.L":{"location":(0.1,0,0)}}, {"torso":{"rotation":(0,0,12)},"hips":{"location":(0.25,0,0)}}, {}]
create_motion("axion_Rigify Dodge Left",FRAMES,POSES)
