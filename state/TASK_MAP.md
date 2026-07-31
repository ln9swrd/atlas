# TASK_MAP

## Git-only (G-*)

| ID | Task | Status |
|----|------|--------|
| G1–G5 | Plan, schema, template, #5, Sera wording | **Done** |
| G6 | (선택) Open Q #4·#6·#7 초안 | **Pending** — draft in `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md` |

## Domain (P-*)

| ID | Task | Status |
|----|------|--------|
| P1 | Domain inventory | **Done** |
| P2 | excelion + excelion-forge state seed | **Done** |
| P3 | forge vs excelion-forge Decision | **Done** — **D20** |

## Owner local (L-*)

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| L-1…L-5 | Ollama + Cline | **Done** | |
| L-3 | .clinerules 배치 | **Done** | |
| L-4 | Cline 작업 루프 검증 | **Done** | |
| L-5 | Cline 보완 마무리 점검 | **Done** | |
| L-6 | untrack / gitignore 정리 | **Done** | |
| L-7 | rebase (impl/atlas-extension) | **Done** | |
| L-8…L-10 | merge, tag, PR | **Pending** | Checklist: `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md` |

## Cloud AI + VS Code (CA-*)

Plan: `docs/07_ROADMAP/CLOUD_AI_VSCODE_EXEC_PLAN.md`

| ID | Task | Status | Assignee | Evidence |
|----|------|--------|----------|----------|
| CA-1 | 프로젝트 ACTIVE_MODE 설정 (cloud / both) | **Pending** | human | |
| CA-2 | TASK_MAP assignee 컬럼 사용 | **Pending** | human | |
| CA-3 | Cloud 결과 → PR 또는 명시적 Git 반영 | **Partial** | cloud | `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md` |
| CA-4 | Cline 실행 + Evidence 기록 | **Pending** | cline | L-8…L-10 local |
| CA-5 | 세션 끝 state 갱신 + commit | **Pending** | both | |

## Implementation

| ID | Task | Status |
|----|------|--------|
| IMP-1 | Extension | Open — issue #2 |

### Decision

- D20: Canonical Forge = `projects/excelion-forge/` only.
- D19: SERA project abandoned.
- D15: Primary work surface = Cline + local Ollama; Cloud AI = mode only.
