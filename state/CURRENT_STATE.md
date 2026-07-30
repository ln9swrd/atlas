# CURRENT_STATE

ACTIVE_TARGET: Owner local **L-8**  
ACTIVE_BRANCH: `main`  
STATUS: P1–P3 **Done**. D20 Forge path fixed. L-1…L-7 **Done**. Optional G6 only on Git.  
D21: atlas-extension Abandoned. Cline primary.

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

**L-8…L-10** merge, tag, PR (`impl/atlas-extension` → `main`)  
Git 선택 — G6  
Forge — T-1 validation smoke + evidence

## Do not

- Work Forge product under `projects/forge/`
- SERA as project (D19)
- Push divergent rewritten history
