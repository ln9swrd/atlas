# EX-BRAVE-009 ~ EX-BRAVE-012: Enemy Combat AI & Battle Arena Specification

## 1. EX-BRAVE-009: Enemy Mech Asset & Collision Spec
- **Asset Name**: `SM_Enemy_Mech_01` (UCX_SM_Enemy_Mech_01 simplified collision)
- **Target Polygon Count**: ~14,000 tris
- **Material Slots**: 2 Material Instances (`MI_Enemy_Body`, `MI_Enemy_Glow`)
- **Collision Mesh**: Complex-as-simple fallback with custom convex collision capsules

## 2. EX-BRAVE-010: Enemy Behavior Tree (BT) & AI Perception
- **Controller**: `AIC_Enemy_Mech`
- **Perception Component**: `UAIPerceptionComponent` (Sight Config: SightRadius=1500, LoseSightRadius=2000, PeripheralVisionAngle=90)
- **BT Nodes**: `Root` -> `Selector` -> `Sequence (Attack Player)` / `Sequence (Patrol)`
- **Blackboard Keys**: `TargetActor` (Object), `DistanceToTarget` (Float), `IsAlerted` (Bool)

## 3. EX-BRAVE-011: Weapon Hit Impact & FX Particle System
- **FX System**: Niagara System `NS_Weapon_HitImpact_01`
- **Audio Component**: `SoundCue_Melee_Hit` / `SoundCue_Laser_Impact`
- **Hit Detection**: LineTraceByChannel / OverlapMultiByChannel on Weapon Mesh Socket `SOCKET_Weapon_R`

## 4. EX-BRAVE-012: Prototype Battle Arena Map & Playtest Validation
- **Level Name**: `L_Battle_Arena_01`
- **Lighting Setup**: Directional Light + SkyAtmosphere + ExponentialHeightFog
- **NavMesh Bounds**: `NavMeshBoundsVolume` encompassing 5000x5000 arena bounds
- **Playtest Validation**: AI patrol, player detection, combat loop, and hit impact FX validation complete
