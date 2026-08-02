# ParaModel

Parametric mecha model system for Atlas / Excelion.

## Structure

```
projects/paramodel/
├── addon/                 # Blender addon v0.4.1
├── schema/
├── data/mecha|parts/
├── scripts/package_addon.sh
└── dist/                  # generated zip
```

## Status (2026-08-02)

| Item | Status |
|------|--------|
| Slots + placeholders + params | Verified in Blender |
| Mesh import path | Implemented (no mesh assets yet → placeholder) |
| Armature (PM-9) | Code on GitHub main; **local Blender verify pending** |

## Install (중요)

GitHub API로 푸시된 코드가 로컬에 없으면 zip에 반영되지 않습니다.

```bash
cd /mnt/d/Atlas   # or your clone
git pull origin main
bash projects/paramodel/scripts/package_addon.sh
# → dist/paramodel_addon_v0.4.1.zip
```

Blender:
1. Preferences → Add-ons → ParaModel **Remove** (구버전 제거)
2. Install → `paramodel_addon_v0.4.1.zip`
3. 패널 하단 **v0.4.1 — armature fix** 확인
4. **Create Armature** 체크 → Clear All → Load Mecha
5. Outliner에 `ParaModel_Armature` / `armature_brave-001` 확인

## Load 결과 기대

- `ParaModel_Root` / `root_{id}`
- `ParaModel_Slots` / `slot_*`
- `ParaModel_Armature` / `armature_{id}` + bones
- `ParaModel_Parts` / `part_*`

## Registered Units

| ID | Name | Status |
|----|------|--------|
| brave-001 | Brave | concept |
