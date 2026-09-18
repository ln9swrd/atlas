import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,5,10,15,20)
POSES=[{"hand_ik.R":{"location":(0.3,0,0.2),"rotation":(50,0,35)}},{"torso":{"rotation":(0,0,-24)},"hand_ik.R":{"location":(0.45,0,0.3),"rotation":(85,0,50)}},{"torso":{"rotation":(0,0,28)},"hand_ik.R":{"location":(-0.45,0,0.05),"rotation":(20,0,-38)}},{"torso":{"rotation":(0,0,10)},"hand_ik.R":{"location":(-0.15,0,0.08)}},{}]
create_motion("axion_Rigify Attack Slash Right",FRAMES,POSES)
