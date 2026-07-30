# CURRENT_STATE

ACTIVE_TARGET: Owner local **L-1** (primary) · optional Git **G5/G6**  
ACTIVE_BRANCH: `main` (docs/state) · `impl/atlas-extension` (extension)  
ACTIVE_PHASE: 필수 Git G1–G4 완료 · 로컬 Cline 경로 대기  
STATUS: G1–G4 **Done**. 선택 G5·G6. 집 PC = **L-1**.

## Decision (2026-07-30)

| Choice | Rationale |
|--------|-----------|
| Primary agent = **Cline** (fallback **Roo**) | Matches agent + tools need |
| Continue = optional only | 메인 에이전트 아님 |
| Do **not** fork Cline/Continue | num_ctx·settings·rules로 대응 |
| Custom extension | Secondary; issue #2 / PR #3 |
| **프로젝트 SERA 폐기 (D19)** | 클라우드 AI는 모드만 |
| Project state schema + template (G2–G3) | `PROJECT_STATE_SCHEMA` + `_template/state/` |
| issue #5 (G4) | 프로젝트 SERA Q 종료; Kraken·legacy 문구만 잔여 |

## Scope agreement

| Area | Status |
|------|--------|
| Domain Isolation | Done |
| Docs rebuild RB-* | Done except RB-F2 tag + local untrack |
| Analysis follow-up AF-* / D19 | **Done** |
| Git-only G1–G4 | **Done** |
| Git-only G5–G6 | Optional |
| Owner local L-1…L-5 | **Pending** |
| Extension L-6…L-10 / PR #3 | Pending after L-5 |
| Camera / vision | Out of scope |

## Next

**집 PC (권장)**  
1. **L-1** Ollama `num_ctx` ≥ 32768  
2. L-2…L-5 Cline  

**Git 선택**  
- G5 잔여 Sera=project 문구  
- G6 Open Q #4·#6·#7 초안  

Full tables: `state/TASK_MAP.md`

## Verified milestones (repo)

- G2 schema, G3 template, G4 issue #5 rewrite
- Ollama host 기록: `http://192.168.219.254:11434`
- exact dup removed; Issues #4–#7
- Issue #2, `impl/atlas-extension`, draft PR #3

## Fixed requirements (charter)

1. VS Code + **local LLM** (Cline/Roo + Ollama preferred)
2. **Git** as source of state (`state/`)
3. Code + screen + images; **camera = 0**

## Blockers

- None blocking L-1

## Do not

- Auto-approve all Cline write/terminal on local models
- Dump `archive/` or `obsidian/` into agent context
- Land extension features on `main` without PR from `impl/atlas-extension`
- Treat SERA as a project (D19)
- Expand Runtime/Plugin/Knowledge without new issues
