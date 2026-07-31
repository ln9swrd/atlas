# CURRENT_STATE

ACTIVE_TARGET: Owner local **L-8**  
ACTIVE_BRANCH: `main` · `impl/atlas-extension`  
STATUS: P1–P3 **Done**. L-1…L-7 **Done**. Cloud review for L-8…L-10 **Git-saved** (CA-3 partial). L-8…L-10 still **Pending** (local Evidence).  
PLAN: `docs/07_ROADMAP/CLOUD_AI_VSCODE_EXEC_PLAN.md`  
CLOUD_REVIEW: `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md` (2026-07-31)

## Forge (D20)

| Role | Path |
|------|------|
| Canonical | `projects/excelion-forge/` |
| Legacy experiment | `projects/forge/` |
| Nested stub | `projects/excelion/projects/exelion_forge/` |

## L-5 checklist (Done)
- Ollama Base URL: http://192.168.219.254:11434 ✅  
- Model: qwen3-coder (current) ✅  
- num_ctx: 32768+ ✅  
- Custom Instructions: AGENTS 핵심 반영 ✅  
- .clinerules: 존재 ✅  
- .clineignore: archive/, obsidian/ 제외 ✅  
- state 루프: 읽기 → 갱신 → commit 가능 ✅  

## Next

**L-8…L-10 (local / Cline)** — 체크리스트: `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md`  
1. rebase 확인  
2. packaging untrack + push `impl/atlas-extension`  
3. F5 smoke → PR #3 merge + tag  

Then: CA-1 (`ACTIVE_MODE`) · Forge T-1 · optional G6 Decision 확정

## Do not

- Work Forge product under `projects/forge/`
- SERA as project (D19)
- Push divergent rewritten history
- Force cloud-only models on extension (SPEC)
- Mark L-8…L-10 Done without local Evidence
