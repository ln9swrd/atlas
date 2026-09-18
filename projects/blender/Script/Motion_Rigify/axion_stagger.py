import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,5,10,16,24,32)
POSES=[{}, {"torso":{"rotation":(6,0,14)},"hips":{"location":(0,0,-0.1)},"hand_ik.L":{"location":(-0.2,0,-0.05)},"hand_ik.R":{"location":(0.2,0,0.05)}},{"torso":{"rotation":(-8,0,-18)},"hips":{"location":(0,0,-0.18)},"hand_ik.L":{"location":(-0.1,0,-0.1)},"hand_ik.R":{"location":(0.1,0,0.12)}},{"torso":{"rotation":(4,0,10)},"hips":{"location":(0,0,-0.08)}},{"torso":{"rotation":(-4,0,-8)}},{}]
create_motion("axion_Rigify Stagger",FRAMES,POSES)
