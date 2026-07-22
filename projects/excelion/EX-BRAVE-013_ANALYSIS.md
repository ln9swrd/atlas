# EX-BRAVE-013 ~ EX-BRAVE-016: Excelion Alpha Prototype Integration Specification

## 1. EX-BRAVE-013: Player HUD & Mech Status UMG Blueprint
- **Widget Blueprint**: `WBP_Brave_HUD`
- **UI Elements**:
  - `ProgressBar_Health`: Mech Hull Integrity (0.0 ~ 1.0)
  - `ProgressBar_Boost`: Thruster Energy Gauge (0.0 ~ 1.0)
  - `TextBlock_Ammo`: Primary Weapon Ammo Counter (Current / Max)
  - `Image_Reticle`: Dynamic Aiming Crosshair with Hit Reaction Animation

## 2. EX-BRAVE-014: Audio Sound Cue & Spatial SFX Attenuation
- **Sound Attenuation**: `ATT_Spatial_3D` (Inner Radius: 400, Falloff Distance: 3500, Distance Algorithm: Logarithmic)
- **Sound Cues**:
  - `SC_Brave_Footstep_Mech`
  - `SC_Brave_Thruster_Loop`
  - `SC_Brave_Weapon_Fire`
  - `SC_Brave_Impact_Explosion`

## 3. EX-BRAVE-015: Post-Processing & Cinematic Lighting Polish
- **Post Process Volume**: `PPV_Alpha_Global` (Unbound = True)
  - Motion Blur: Amount = 0.3
  - Bloom: Method = Standard/Convolution, Intensity = 0.75
  - Color Grading: Contrast = 1.1, Saturation = 1.05
- **Lighting**: High-tech Sci-Fi Mecha Hangar & Desert Battle Arena Atmosphere

## 4. EX-BRAVE-016: Alpha Standalone Build & Pre-flight Final Review
- **Target Target Platform**: Windows (x86_64)
- **Build Configuration**: Shipping / Development Standalone
- **Pre-flight & Review Engine**: Atlas DevOS Rule Check 100% Pass, Scorecard generated
