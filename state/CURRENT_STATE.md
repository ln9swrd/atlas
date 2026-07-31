# CURRENT_STATE

ACTIVE_TARGET: **G6 승인** 또는 **excelion-forge T-1** (마스터 선택)  
ACTIVE_BRANCH: `main`  
STATUS: **D22 atlas-extension 폐기.** L-8…L-10 / IMP-1 / PR #3 **Abandoned**. Primary surface = Cline (D15).  
G6_DRAFTS: `docs/06_OPERATIONS/G6_DECISION_DRAFTS.md` (승인 대기)  
ROLES: `docs/05_AGENTS/ROLE_SPLIT.md`

## Abandoned (D22)

| Item | Status |
|------|--------|
| `projects/atlas-extension` | 폐기 — 신규 작업 금지 |
| issue #2 / PR #3 | closed not_planned / closed unmerged |
| L-8…L-10 extension batch | **Cancelled** |
| `scripts/master_l8_l10.sh` | extension 전용 — 사용 중단 (보관만) |

## Next (마스터)

1. G6 Decision 초안 승인/수정 → DECISIONS 확정  
2. 또는 `projects/excelion-forge` T-1 validation (Evidence-First)  
3. (선택) main에서 `projects/atlas-extension/node_modules` untrack hygiene only — 기능 작업 아님

## Do not

- atlas-extension 부활 / PR #3 merge
- SERA as project (D19)
- Done without Evidence (D01)
