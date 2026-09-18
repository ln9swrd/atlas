import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,6,12,18,24,30,36,42)
POSES=[{"hand_ik.L":{"location":(-0.3,0,0.2),"rotation":(-45,0,-30)}},{"torso":{"rotation":(0,0,-22)},"hand_ik.R":{"location":(0.4,0,0.25),"rotation":(70,0,45)}},{"torso":{"rotation":(0,0,24)},"hand_ik.L":{"location":(0.4,0,0.05),"rotation":(-70,0,42)}},{"torso":{"rotation":(0,0,-28)},"hand_ik.R":{"location":(-0.4,0,0.05),"rotation":(70,0,-45)}},{"torso":{"rotation":(0,0,0)},"hand_ik.L":{"location":(-0.25,0,0.12)},"hand_ik.R":{"location":(0.25,0,0.12)}},{"torso":{"rotation":(-12,0,0)},"hips":{"location":(0,0,0.05)},"hand_ik.L":{"location":(-0.35,0,0.25)},"hand_ik.R":{"location":(0.35,0,0.25)}},{"hips":{"location":(0,0,0.02)}},{}]
create_motion("axion_Rigify Attack Combo",FRAMES,POSES)
