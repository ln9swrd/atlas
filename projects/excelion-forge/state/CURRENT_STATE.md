# CURRENT_STATE — excelion-forge

Schema: `docs/process/PROJECT_STATE_SCHEMA.md`  
Atlas map: `state/PROJECT_MAP.md`

ACTIVE_TARGET: Stabilize Blender add-on / rig validation (Evidence-First)  
ACTIVE_MODE: cline  
ACTIVE_BRANCH: n/a until feature branch opened  
STATUS: state seeded 2026-07-30; git reference surveys saved; code exists under `excelion_forge/` + `docs/`

## Next one thing

1. Pick one failing or high-value validation path and record evidence requirement in TASK_MAP T-1

## Recent (2026-07-30)

- Blender 깃 참고 조사 → `state/GIT_REFERENCE_BLENDER.md`
- Unreal 깃 참고 조사 → `state/GIT_REFERENCE_UNREAL.md` (문서 중심, UE 본체 없음)
- 게임 기획 점검은 `projects/excelion/state/DESIGN_REVIEW_2026-07-30.md`

## Blockers

- None for docs/state
- Blender runtime tests need owner local machine

## Do not

- Claim Validate Active Rig fixed without CLI/file evidence (D01)
- Treat SERA as blocking dependency (D19 — use Cline/cloud **mode**)
- Load archive/obsidian into context
- Treat `projects/forge/` as this project
