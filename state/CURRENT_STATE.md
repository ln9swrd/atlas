# CURRENT_STATE

ACTIVE_TARGET: Owner local **L-8**  
ACTIVE_BRANCH: `main` · `impl/atlas-extension`  
STATUS: P1–P3 **Done**. L-1…L-7 **Done**. Cloud review Git-saved (CA-3 partial). L-8…L-10 **Pending**.  
PLAN: `docs/07_ROADMAP/CLOUD_AI_VSCODE_EXEC_PLAN.md`  
CLOUD_REVIEW: `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md`  
ROLES: `docs/05_AGENTS/ROLE_SPLIT.md` — **Human can run simple commands & shell scripts**

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

**L-8…L-9** — Human shell OK (Cline optional): rebase → packaging untrack → push  
**L-10** — npm/compile if Node available; F5 on dev PC → Human merge PR #3  
Checklist: `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md`  

Then: CA-1 · Forge T-1 · optional G6 Decision 확정

## Do not

- Work Forge product under `projects/forge/`
- SERA as project (D19)
- Push divergent rewritten history
- Force cloud-only models on extension (SPEC)
- Mark L-8…L-10 Done without Evidence
