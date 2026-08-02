# ParaModel

Parametric mecha model system for Atlas / Excelion.

## Structure

```
projects/paramodel/
├── addon/                 # Blender addon v0.6.0
├── schema/
├── data/mecha|parts/
├── para_model.blend       # reference scene (optional)
├── scripts/package_addon.sh
└── dist/                  # generated zip
```

## Status (2026-08-02)

| Item | Status |
|------|--------|
| Slots + placeholders + params | Verified in Blender |
| Mesh import path | Implemented (no mesh assets yet → placeholder) |
| Armature | **SuperRobotRig** procedural (v0.6.0, no blend dep) |

## Install

```bash
cd /mnt/d/Atlas   # or your clone
git pull origin main
bash projects/paramodel/scripts/package_addon.sh
# → dist/paramodel_addon_v0.6.0.zip
```

Blender:
1. Preferences → Add-ons → ParaModel **Remove**
2. Install → `paramodel_addon_v0.6.0.zip`
3. 패널 하단 **v0.6.0 — SuperRobotRig procedural** 확인
4. **Create Armature** 체크 → Clear All → Load Mecha
5. Outliner에 `ParaModel_Armature` / `SuperRobotRig` 확인

## Load 결과 기대

- `ParaModel_Root` / `root_{id}`
- `ParaModel_Slots` / `slot_*`
- `ParaModel_Armature` / `SuperRobotRig` (Root~toe, wings, fingers)
- `ParaModel_Parts` / `part_*`

## Registered Units

| ID | Name | Status |
|----|------|--------|
| brave-001 | Brave | concept |
