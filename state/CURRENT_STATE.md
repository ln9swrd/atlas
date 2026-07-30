# CURRENT_STATE

ACTIVE_TARGET: Owner local **L-8**  
ACTIVE_BRANCH: `main` · `impl/atlas-extension`  
STATUS: P1–P3 **Done**. D20 Forge path fixed. L-1…L-7 **Done**. Optional G6 only on Git.

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

<<<<<<< HEAD
**L-8…L-10** merge, tag, PR (`impl/atlas-extension` → `main`)  
Git 선택 — G6  
Forge — T-1 validation smoke + evidence
=======
**집 PC — L-6** untrack / gitignore 정리 완료  
**L-7** 완료 (rebase 및 state 갱신 완료)  
Git 선택 — G6
>>>>>>> 6507877 (Update state/CURRENT_STATE.md after rebase on L-7)

## Do not

- Work Forge product under `projects/forge/`
- SERA as project (D19)
- Push divergent rewritten history
