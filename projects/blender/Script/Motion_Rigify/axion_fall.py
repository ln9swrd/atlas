import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,8,16,26,38)
POSES=[{}, {"torso":{"rotation":(10,0,0)},"hips":{"location":(0,0,-0.18)}},{"torso":{"rotation":(28,0,0)},"hips":{"location":(0,0,-0.52)},"hand_ik.L":{"location":(-0.4,0,0.2)},"hand_ik.R":{"location":(0.4,0,0.2)}},{"torso":{"rotation":(70,0,0)},"hips":{"location":(0,-0.15,-0.75)}},{"torso":{"rotation":(90,0,0)},"hips":{"location":(0,-0.2,-0.75)}}]
create_motion("axion_Rigify Fall",FRAMES,POSES)
