# CURRENT_STATE

ACTIVE_TARGET: (1) Git-only **G3** template 또는 (2) Owner local **L-1** Ollama  
ACTIVE_BRANCH: `main` (docs/state) · `impl/atlas-extension` (extension)  
ACTIVE_PHASE: 프로젝트 state 스키마 고정 후 템플릿 · 로컬 에이전트 대기  
STATUS: G1–G2 **Done**. 다음 Git = G3. 집 PC = L-1.

## Decision (2026-07-30)

| Choice | Rationale |
|--------|-----------|
| Primary agent = **Cline** (fallback **Roo**) | Matches agent + tools need |
| Continue = optional only | 메인 에이전트 아님 |
| Do **not** fork Cline/Continue | num_ctx·settings·rules로 대응 |
| Custom extension | Secondary; issue #2 / PR #3 |
| **프로젝트 SERA 폐기 (D19)** | 클라우드 AI는 모드만, 프로젝트 아님 |
| Project state schema (G2) | `docs/process/PROJECT_STATE_SCHEMA.md` |

## Scope agreement

| Area | Status |
|------|--------|
| Domain Isolation | Done |
| Docs rebuild RB-* | Done except RB-F2 tag + local untrack |
| Analysis follow-up AF-* / D19 | **Done** |
| Git-only G1–G2 | **Done** |
| Git-only G3–G6 | Pending — see `state/TASK_MAP.md` |
| Owner local L-1…L-5 | **Pending** |
| Extension L-6…L-10 / PR #3 | Pending after L-5 |
| Camera / vision | Out of scope |

## Next

**Git**  
1. **G3** `projects/_template/state/` (CURRENT / TASK / CONTEXT)  
2. G4 issue #5 정리  

**집 PC**  
1. **L-1** Ollama `num_ctx` ≥ 32768  
2. L-2…L-5 Cline  

Full tables: `state/TASK_MAP.md`

## Verified milestones (repo)

- `docs/process/PROJECT_STATE_SCHEMA.md` (G2)
- Ollama host 기록: `http://192.168.219.254:11434`
- exact dup 061/062/063/065/066 removed
- Issues #4–#7; #5 noted D19
- Issue #2, `impl/atlas-extension`, draft PR #3

## Fixed requirements (charter)

1. VS Code + **local LLM** (Cline/Roo + Ollama preferred)
2. **Git** as source of state (`state/`)
3. Code + screen + images; **camera = 0**

## Blockers

- None blocking L-1 or G3

## Do not

- Auto-approve all Cline write/terminal on local models
- Dump `archive/` or `obsidian/` into agent context
- Land extension features on `main` without PR from `impl/atlas-extension`
- Treat SERA as a project (D19)
- Expand Runtime/Plugin/Knowledge without new issues
