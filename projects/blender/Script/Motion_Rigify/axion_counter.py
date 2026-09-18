import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,6,12,18,26)
POSES=[{"hand_ik.L":{"location":(-0.3,0,0.2)},"hand_ik.R":{"location":(0.3,0,0.2)}},{"torso":{"rotation":(0,0,18)},"hand_ik.L":{"location":(-0.45,0,0.3),"rotation":(-72,0,-45)}},{"torso":{"rotation":(0,0,-24)},"hand_ik.R":{"location":(0.5,0,0.25),"rotation":(85,0,45)},"hips":{"location":(0,0,0.03)}},{"torso":{"rotation":(0,0,8)},"hand_ik.R":{"location":(0.3,0,0.12)}},{}]
create_motion("axion_Rigify Counter",FRAMES,POSES)
