# ParaModel

Parametric mecha / unit model system for Atlas / Excelion.

## Design flow

```
Identity → Archetype → Size → Traits → Visual → Body
```

- **Archetype:** humanoid (active); quadruped, multiped, aircraft, vessel (planned)
- **Size:** `sf = size.value / template.reference_value` (humanoid ref = 2.0 m)
- **Working scale:** viewport = sf × working_scale (default **0.01 = 1:100**)

See `DESIGN.md`.

## Structure

```
projects/paramodel/
├── addon/                 # Blender addon v0.7.2
├── schema/
│   ├── mecha-metadata.schema.json
│   ├── base-body-slots.json
│   └── templates/         # humanoid.json, …
├── data/mecha|parts/
├── scripts/package_addon.sh
├── DESIGN.md
└── CHANGELOG.md
```

## Status (2026-08-03)

| Item | Status |
|------|--------|
| Archetype + Size contract | v0.7.1 |
| Working scale 1:100 | **v0.7.2** |
| Mesh import | v0.7.0 |
| SuperRobotRig | procedural |
| Non-humanoid templates | planned |
| Axis unify / visual mats | open |

## Install

```bash
cd /mnt/d/Antigravity/Atlas   # local path
git pull origin main
bash projects/paramodel/scripts/package_addon.sh
# → projects/paramodel/dist/paramodel_addon_v0.7.2.zip
```

Blender: Remove old ParaModel → Install zip → panel **v0.7.2 — working scale 1:100**.

Working Scale 기본값 0.01 → brave-001 키 ≈ **298 mm** (실스케일 25 m의 1/100).

## Registered units

| ID | Archetype | Size | Status |
|----|-----------|------|--------|
| brave-001 | humanoid | height 25 m | concept |
