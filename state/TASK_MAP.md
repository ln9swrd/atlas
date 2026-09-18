# TASK_MAP

## Direction (Master 2026-08-04)

**Atlas platform only.** 모든 하위 개별 프로젝트 **중단(HOLD)**.  
이전: Platform closeout Done (2026-07-31). Paramodel side track 진행 중이었으나 전면 hold.  
**Cline 미사용** — surface 제거 완료 (2026-08-04). D15 superseded by D30.

## Closed (platform)

Min · F1–F4 · P0–P3 · R1–R7 · D28 S0–S5 · C1 · C3  
Cline 제거: `.clineignore` 삭제 · `.gitignore` clinerules 제거 · `DAILY_LOOP` 문구 정리 (2026-08-04)  
Doc hygiene 2026-08-04: D15→D30 · ROADMAP maintenance banner · HYG-1

## HOLD — all sub-projects (Master 2026-08-04)

| Scope | Notes |
|-------|--------|
| paramodel (PM-*) | side track 중단. PM-15 및 open 항목 전부 hold |
| printguard | P2 docs — hold |
| makerfac-needs-research | hold |
| blender | hold |
| coin-s | **path absent** (2026-08-11) — do not recreate without Master |
| excelion / excelion-forge | product hold (기존 유지 + 재확인) |

### Paramodel snapshot at halt

Path: `projects/paramodel/` · Addon ~v0.7.4 (main at halt)

| ID | Task | Status at halt |
|----|------|----------------|
| PM-1..PM-8 | Base pipeline + mesh | Done |
| PM-12 | SuperRobotRig procedural | Done |
| PM-13 | Archetype + Size | Done |
| PM-10 | working scale 1:100 | Done |
| PM-14 | Axis unify Z-up | Done |
| PM-15 | Non-humanoid templates | **HOLD** |
| — | real GLB / slot→bone / materials | **HOLD** |

## Open

| ID | Task |
|----|------|
| — | (platform open 없음 — maintenance only) |

## Closed hygiene (2026-08-04)

| ID | Task | Evidence |
|----|------|----------|
| HYG-1 | tracked `__pycache__/` untrack | main tree: `__pycache__` path 없음; `.gitignore` already has `__pycache__/` |
| HYG-2 | D15 supersede / D30 | `docs/DECISIONS.md` commit 5905b3a |
| HYG-3 | ROADMAP maintenance banner | `docs/ROADMAP.md` commit 7d6679f |

## Hold (explicit)

| ID | Task |
|----|------|
| — | ACTIVE_TARGET product / excelion / forge |
| — | paramodel 및 기타 `projects/*` 작업 |
| — | Forge Prototype sprint |
| — | Cline / .clinerules 재도입 |
