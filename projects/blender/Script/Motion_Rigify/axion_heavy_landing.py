import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,5,10,16,24)
POSES=[{"hips":{"location":(0,0,1.0)}},{"hips":{"location":(0,0,0.4)},"torso":{"rotation":(-4,0,0)}},{"hips":{"location":(0,0,-0.25)},"torso":{"rotation":(-12,0,0)},"thigh_ik.L":{"location":(0,0,-0.1)},"thigh_ik.R":{"location":(0,0,-0.1)}},{"hips":{"location":(0,0,-0.12)}},{}]
create_motion("axion_Rigify Heavy Landing",FRAMES,POSES)
