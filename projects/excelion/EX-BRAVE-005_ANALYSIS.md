# EX-BRAVE-005 ~ EX-BRAVE-008: Brave Combat & Action Specification

## 1. EX-BRAVE-005: Primary Weapon (Rifle/Sword) Asset Spec
- **Asset Name**: `SM_Brave_RifleSword_01`
- **Target Polygon Count**: ~12,000 tris
- **Material Slots**: 2 Material Instances (`MI_Brave_Weapon_Main`, `MI_Brave_Weapon_Emissive`)
- **UV Layout**: Single 2048x2048 Texture Atlas, Texel Density > 10.24 px/cm
- **Naming Rule**: Conforms to `SM_` prefix rule and Atlas pre-flight check

## 2. EX-BRAVE-006: Joint Rigging & Motion Clips
- **Skeleton Structure**: `root` -> `pelvis` -> `spine_01` -> `spine_02` -> `clavicle_r/l` -> `upperarm_r/l` -> `hand_r/l` -> `SOCKET_Weapon_R`
- **Motion Clips**:
  - `Anim_Brave_Idle_Combat` (60 frames, looping)
  - `Anim_Brave_Run_Forward` (30 frames, looping)
  - `Anim_Brave_Attack_Light_01` (45 frames, root motion optional)
  - `Anim_Brave_Attack_Heavy_01` (60 frames, impact frame at F28)

## 3. EX-BRAVE-007: Unreal Animation Blueprint (ABP) & Sockets
- **ABP Target**: `ABP_Brave_Character`
- **State Machine**: `Locomotion` (Idle <-> Run) -> `Combat_Attacks` (Layered Blend per Bone)
- **Sockets**: `SOCKET_Weapon_R` attached to `hand_r` bone (Offset: X=0, Y=5, Z=0, Rot: 0, 90, 0)

## 4. EX-BRAVE-008: Action Camera & Test Map Validation
- **Camera Boom**: `SpringArmComponent` (TargetArmLength = 350, SocketOffset = (0, 40, 20), EnableCameraLag = True)
- **Test Map**: `L_Brave_Combat_TestMap`
- **Verification Rule**: Atlas pre-flight & Platform review engine pass
