import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,7,13,19,25,31)
POSES=[{"torso":{"rotation":(18,0,0)},"hips":{"location":(0,0,-0.12)}},{"torso":{"rotation":(18,0,0)},"hips":{"location":(0,0,-0.12)},"foot_ik.L":{"location":(0,0.12,0)},"hand_ik.R":{"location":(0,0.08,0)}},{"torso":{"rotation":(18,0,0)},"hips":{"location":(0,0,-0.12)},"foot_ik.R":{"location":(0,0.12,0)},"hand_ik.L":{"location":(0,0.08,0)}},{"torso":{"rotation":(18,0,0)},"hips":{"location":(0,0,-0.12)}},{"torso":{"rotation":(18,0,0)},"hips":{"location":(0,0,-0.12)},"foot_ik.L":{"location":(0,0.12,0)}},{"torso":{"rotation":(18,0,0)},"hips":{"location":(0,0,-0.12)},"foot_ik.R":{"location":(0,0.12,0)}}]
create_motion("axion_Rigify Low Walk",FRAMES,POSES)
