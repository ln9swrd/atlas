# CURRENT_STATE — excelion-forge

Schema: `docs/process/PROJECT_STATE_SCHEMA.md`  
Atlas map: `state/PROJECT_MAP.md`

ACTIVE_TARGET: Stabilize Blender add-on / rig validation (Evidence-First)  
ACTIVE_MODE: both  
ACTIVE_BRANCH: n/a until feature branch opened  
STATUS: state seeded 2026-07-30; ACTIVE_MODE both (CA-1, 2026-07-31); git reference surveys saved; code under `excelion_forge/` + `docs/`

## Next one thing

1. Pick one failing or high-value validation path and record evidence requirement in TASK_MAP T-1

## Recent (2026-07-30 / 07-31)

- Blender 깃 참고 → `state/GIT_REFERENCE_BLENDER.md`
- Unreal 깃 참고 → `state/GIT_REFERENCE_UNREAL.md`
- Pipeline 공개 레포 조사 → `state/GIT_REFERENCE_PIPELINE.md`
- 게임 기획 점검 → `projects/excelion/state/DESIGN_REVIEW_2026-07-30.md`
- ACTIVE_MODE: both (Cloud=설계·리뷰 / Cline=에이전트 / 마스터=승인·쉘)

## Blockers

- None for docs/state
- Blender runtime tests need owner local machine

## Do not

- Claim Validate Active Rig fixed without CLI/file evidence (D01)
- Treat SERA as project (D19 — cloud **mode** only)
- Load archive/obsidian into context
- Treat `projects/forge/` as this project
- Reimplement full Send-to-Unreal / BFUE inside Forge
