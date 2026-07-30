# CURRENT_STATE

ACTIVE_TARGET: Owner local **L-1** (primary) · optional Git **G6**  
ACTIVE_BRANCH: `main` (docs/state) · `impl/atlas-extension` (extension)  
ACTIVE_PHASE: G1–G5 완료 · 로컬 Cline 경로 대기  
STATUS: G1–G5 **Done**. 선택 G6. 집 PC = **L-1**.

## Decision (2026-07-30)

| Choice | Rationale |
|--------|-----------|
| Primary agent = **Cline** (fallback **Roo**) | Matches agent + tools need |
| Continue = optional only | 메인 에이전트 아님 |
| **프로젝트 SERA 폐기 (D19)** + G5 운영 문서 정리 | 클라우드 AI는 모드만 |
| Project state schema + template (G2–G3) | `PROJECT_STATE_SCHEMA` + `_template/state/` |

## Scope agreement

| Area | Status |
|------|--------|
| Git-only G1–G5 | **Done** |
| Git-only G6 | Optional |
| Owner local L-1…L-5 | **Pending** |
| Extension L-6…L-10 / PR #3 | Pending after L-5 |
| Camera / vision | Out of scope |

## Next

**집 PC (권장)** — **L-1** Ollama `num_ctx` ≥ 32768  
**Git 선택** — G6 Open Q #4·#6·#7 초안  

Full tables: `state/TASK_MAP.md`

## Verified milestones (repo)

- G5: VISION, ENVIRONMENTS, 05_AGENTS, AGENT_REGISTRY, ATLAS_GIT_REBUILD_PLAN
- G2–G4 schema/template/issue #5
- Historical alpha freeze / ADR_001 / ROADMAP may still mention SERA as **legacy** wording — not active project guidance

## Fixed requirements (charter)

1. VS Code + **local LLM** (Cline/Roo + Ollama preferred)
2. **Git** as source of state (`state/`)
3. Code + screen + images; **camera = 0**

## Do not

- Treat SERA as a project (D19)
- Auto-approve all Cline write/terminal on local models
- Dump `archive/` or `obsidian/` into agent context
