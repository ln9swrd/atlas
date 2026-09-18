# S2 Dry-run Path List (no migration)

Date: 2026-07-31  
D28 defaults confirmed. **Do not delete or filter-repo yet.**

## Stay in `ln9swrd/atlas`

- `docs/`, `state/`, `tools/`, `atlas-runtime/`
- `AGENTS.md`, `README.md`, `.github/`, `config/`, `scripts/`, `tests/` (platform)
- `core/` platform-relevant (contract, sdk, decision, execution, taskbroker, rules, review engines, …)
- `archive/` (for now)
- `projects/_template/`

## Extract → `ln9swrd/excelion` (future)

- `projects/excelion/**`

## Extract → `ln9swrd/excelion-forge` (future)

- `projects/excelion-forge/**`

## HOLD in atlas (D28) until forge consumes

- `core/tools/blender_*`, `core/tools/ue_*`, `core/tools/visual_perception.py`
- `core/forge/`, `core/connectors/`, `core/vision/`
- `core/review/scorecard_*`, print_settings under core

## Later / small

- `projects/printguard/` — optional own repo
- `projects/coin-s/` — already submodule-oriented

## Local size check (Cline / Master)

```bash
cd /mnt/d/Atlas
du -sh projects/excelion projects/excelion-forge 2>/dev/null
git rev-list --count HEAD -- projects/excelion
git rev-list --count HEAD -- projects/excelion-forge
```

Report numbers before S3.
