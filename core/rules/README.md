# Rules Layer

The **Rules Layer** defines the standards and constraints for assets, code, and version control to ensure consistency and minimize human decision fatigue.

## 1. Blender Rules
- **Modifier Stack Order**: Generate -> Deform -> Physics -> Render. Ensure all modifiers are named if not applied.
- **Collection Structure**:
  - `export_` prefix for collections containing final exportable meshes.
  - `backup_` prefix for construction assets/non-destructive workflow.
- **Naming Conventions**: `SM_[AssetName]` for static meshes, `SK_[AssetName]` for skeletal meshes.
- **Pivot Policy**: Reset transforms to world origin `(0, 0, 0)` unless a custom pivot offset is explicitly required.
- **Export Settings**: Apply scale (1.0), forward axis: `-Y Forward`, up axis: `Z Up`.

## 2. Unreal Engine Rules
- **Folder Structure**:
  - `/Game/Artists/[ArtistName]/` for working/temp assets.
  - `/Game/Assets/[Category]/` for finalized assets.
- **Blueprint Guidelines**:
  - Always comment major logic blocks.
  - No logic in Event Tick unless absolutely necessary.
  - No hard object references in variables; use soft object references or interfaces.
- **Naming Rules**:
  - Materials: `M_[Name]`
  - Material Instances: `MI_[Name]`
  - Textures: `T_[Name]_[Suffix]` (e.g., `_D` for diffuse, `_N` for normal, `_ORM` for occlusion-roughness-metallic).

## 3. Git Rules
- **Commit Message Format**: `[Category] Description` (e.g., `[asset/mesh] update collision for SM_Tree`).
- **Branching Strategy**:
  - `main` for stable releases.
  - `dev` for active integration.
  - `feature/[name]` for individual tasks.
