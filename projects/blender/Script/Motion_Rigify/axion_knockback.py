import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,5,11,18,26,34)
POSES=[{}, {"torso":{"rotation":(12,0,0)},"hips":{"location":(0,-0.18,0.05)},"hand_ik.L":{"location":(-0.2,0,0.1)},"hand_ik.R":{"location":(0.2,0,0.1)}},{"torso":{"rotation":(22,0,0)},"hips":{"location":(0,-0.55,0.12)}},{"torso":{"rotation":(30,0,0)},"hips":{"location":(0,-0.82,0.04)},"hand_ik.L":{"location":(-0.3,0,0.2)},"hand_ik.R":{"location":(0.3,0,0.2)}},{"torso":{"rotation":(12,0,0)},"hips":{"location":(0,-0.4,0)}},{}]
create_motion("axion_Rigify Knockback",FRAMES,POSES)
