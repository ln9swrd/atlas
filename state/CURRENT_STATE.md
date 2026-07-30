# CURRENT_STATE

ACTIVE_TARGET: Owner local **L-1**  
ACTIVE_BRANCH: `main` · `impl/atlas-extension`  
STATUS: P1–P3 **Done**. D20 Forge path fixed. Optional G6 only on Git.

## Forge (D20)

| Role | Path |
|------|------|
| Canonical | `projects/excelion-forge/` |
| Legacy experiment | `projects/forge/` |
| Nested stub | `projects/excelion/projects/exelion_forge/` |

## L-5 checklist
- Ollama Base URL: http://192.168.219.254:11434 ✅  
- Model: qwen3-coder (current) ✅  
- num_ctx: 32768+ ✅  
- Custom Instructions: AGENTS 핵심 반영 ✅  
- .clinerules: 존재 ✅  
- .clineignore: archive/, obsidian/ 제외 ✅  
- state 루프: 읽기 → 갱신 → commit 가능 ✅  

## Next

**집 PC — L-5** Cline 보완 마무리 점검 완료  
**L-6…L-10** 대기 중 (업데이트 필요)  
Git 선택 — G6

## Do not

- Work Forge product under `projects/forge/`
- SERA as project (D19)
