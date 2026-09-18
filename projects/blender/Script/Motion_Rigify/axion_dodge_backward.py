import bpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(bpy.data.filepath).parent / "Script" / "Motion_Rigify"))
from axion_rigify_motion_common import create_motion
FRAMES=(1,5,10,16,22)
POSES=[{}, {"torso":{"rotation":(12,0,0)},"hips":{"location":(0,-0.25,0)}}, {"torso":{"rotation":(22,0,0)},"hips":{"location":(0,-0.65,0)}}, {"torso":{"rotation":(8,0,0)},"hips":{"location":(0,-0.25,0)}}, {}]
create_motion("axion_Rigify Dodge Backward",FRAMES,POSES)
