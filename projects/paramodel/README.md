# ParaModel

Parametric mecha / unit model system for Atlas / Excelion.

## Design flow

```
Identity → Archetype → Size → Traits → Visual → Body
```

- **Archetype:** humanoid (active); quadruped, multiped, aircraft, vessel (planned)
- **Size:** `sf = size.value / template.reference_value` (humanoid ref = 2.0 m)

See `DESIGN.md`.

## Structure

```
projects/paramodel/
├── addon/                 # Blender addon v0.7.1
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
| Archetype + Size contract | **v0.7.1** |
| Mesh import | v0.7.0 |
| SuperRobotRig | procedural |
| Non-humanoid templates | planned |
| Axis unify / visual mats | open |

## Install

```bash
git pull origin main
bash projects/paramodel/scripts/package_addon.sh
# → dist/paramodel_addon_v0.7.1.zip
```

Blender: Remove old ParaModel → Install zip → panel **v0.7.1 — archetype/size**.

## Registered units

| ID | Archetype | Size | Status |
|----|-----------|------|--------|
| brave-001 | humanoid | height 25 m | concept |
