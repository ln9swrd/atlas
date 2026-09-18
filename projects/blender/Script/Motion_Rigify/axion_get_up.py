import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,10,20,32,44,56)
POSES=[{"torso":{"rotation":(90,0,0)},"hips":{"location":(0,-0.2,-0.75)}},{"torso":{"rotation":(58,0,0)},"hips":{"location":(0,-0.15,-0.55)}},{"torso":{"rotation":(28,0,0)},"hips":{"location":(0,0,-0.25)}},{"torso":{"rotation":(8,0,0)},"hips":{"location":(0,0,-0.08)}},{"torso":{"rotation":(-4,0,0)}},{}]
create_motion("axion_Rigify Get Up",FRAMES,POSES)
