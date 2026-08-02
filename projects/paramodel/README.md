# ParaModel

Parametric mecha model system for Atlas / Excelion.

## Structure

```
projects/paramodel/
├── addon/                 # Blender addon v0.7.0
├── schema/
├── data/mecha|parts/
├── para_model.blend       # reference scene (optional)
├── scripts/package_addon.sh
└── dist/                  # generated zip
```

## Status (2026-08-02)

| Item | Status |
|------|--------|
|Slots + placeholders + params | Verified in Blender |
| Mesh import | **v0.7.0** — glb/gltf/obj/fbx/blend via `part.mesh` |
| Armature | **SuperRobotRig** procedural (no blend dep) |

## Mesh resolution

1. `part.mesh` path relative to `data/parts/` (e.g. `meshes/arm_basic_01.glb`)
2. Auto-fallback: `data/parts/meshes/{part_id}.{glb|gltf|obj|fbx|blend}`
3. If missing or import fails → placeholder cube

## Install

```bash
cd /mnt/d/Atlas   # or your clone
git pull origin main
bash projects/paramodel/scripts/package_addon.sh
# → dist/paramodel_addon_v0.7.0.zip
```

Blender:
1. Preferences → Add-ons → ParaModel **Remove**
2. Install → `paramodel_addon_v0.7.0.zip`
3. 패널 하단 **v0.7.0 — mesh import** 확인
4. **Prefer Mesh File** 체크 → Clear All → Load Mecha
5. Outliner: `part_*` 에 mesh source 확인 (`paramodel_mesh_source`)

## Load 결과 기대

- `ParaModel_Root` / `root_{id}`
- `ParaModel_Slots` / `slot_*`
- `ParaModel_Armature` / `SuperRobotRig`
- `ParaModel_Parts` / `part_{slot}_{part_id}` (mesh 또는 placeholder)

## Registered Units

| ID | Name | Status |
|----|------|--------|
| brave-001 | Brave | concept |
