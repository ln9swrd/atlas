import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,8,16,24)
POSES=[{"hand_ik.L":{"location":(-0.2,0,0.15)},"hand_ik.R":{"location":(0.2,0,0.15)}},{"torso":{"rotation":(-8,0,0)},"hips":{"location":(0,0,-0.05)},"hand_ik.L":{"location":(-0.35,0,0.35),"rotation":(-68,0,-24)},"hand_ik.R":{"location":(0.35,0,0.35),"rotation":(-68,0,24)}},{"torso":{"rotation":(-10,0,0)},"hips":{"location":(0,0,-0.08)},"hand_ik.L":{"location":(-0.4,0,0.4),"rotation":(-78,0,-26)},"hand_ik.R":{"location":(0.4,0,0.4),"rotation":(-78,0,26)}},{"hand_ik.L":{"location":(-0.2,0,0.15)},"hand_ik.R":{"location":(0.2,0,0.15)}}]
create_motion("axion_Rigify Guard",FRAMES,POSES)
