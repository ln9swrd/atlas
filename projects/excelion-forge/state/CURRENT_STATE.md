# CURRENT_STATE — excelion-forge

Schema: `docs/process/PROJECT_STATE_SCHEMA.md`  
Atlas map: `state/PROJECT_MAP.md`

ACTIVE_TARGET: Stabilize Blender add-on / rig validation (Evidence-First)  
ACTIVE_MODE: cline  
ACTIVE_BRANCH: n/a until feature branch opened  
STATUS: state seeded 2026-07-30; code exists under `excelion_forge/` + `docs/`

## Next one thing

1. Pick one failing or high-value validation path and record evidence requirement in TASK_MAP T-1

## Blockers

- None for docs/state
- Blender runtime tests need owner local machine

## Do not

- Claim Validate Active Rig fixed without CLI/file evidence (D01)
- Treat SERA as blocking dependency (D19 — use Cline/cloud **mode**)
- Load archive/obsidian into context
- Treat `projects/forge/` as this project
