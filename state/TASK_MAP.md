# TASK_MAP

> Documentation rebuild track is closed except optional local tag. Implementation work uses issue + branch.
> **Owner local** rows are actions only the human can run on their machine (no GitHub API).
> **Git-only (G-*)** rows can be done via GitHub without home PC.

## Docs rebuild (RB-*)

| ID | Task | Status |
|----|------|--------|
| RB-A | Tag / branch for rebuild | Done |
| RB-B | Isolate summary under `archive/` | **Done** (`archive/summary/` 000–086) |
| RB-C | `docs/00`–`07` skeleton + specs | Done |
| RB-D | `state/` CURRENT / CONTEXT / TASK / PROJECT | Done |
| RB-E | README charter for 3 requirements | Done |
| RB-F | Merge to `main` | **Done** (PR #1) |
| RB-F2 | Tag `atlas-docs-rebuild-v1` | **Pending — owner local** |
| RB-G | Bulk path move summary → `archive/summary/` | **Done** |
| RB-H | Clean root / ignore tracked junk | Policy Done (`.gitignore`); **untrack still owner local** |

## Analysis follow-up (2026-07-30)

| ID | Task | Status |
|----|------|--------|
| AF-1 … AF-7 | Decisions, glossary, dups, issues, D19 | **Done** |

## Git-only plan (G-*)

| ID | Task | Status |
|----|------|--------|
| G1–G5 | State plan, schema, template, #5, Sera wording | **Done** |
| G6 | (선택) Open Q #4·#6·#7 문서 초안 | **Pending** |

## Domain projects (P-*)

| ID | Task | Status |
|----|------|--------|
| P1 | 도메인 프로젝트 인벤토리 → PROJECT_MAP / REGISTRY / `projects/README` | **Done** |
| P2 | (선택) `excelion` + `excelion-forge`에 `_template` state/ 시드 | **Pending** |
| P3 | (선택) `projects/forge` vs `excelion-forge` 관계 Decision | **Pending** |

## Implementation (repo)

| ID | Task | Status |
|----|------|--------|
| IMP-1 | Extension formal track | **Open** — issue #2 · `impl/atlas-extension` · PR #3 |
| — | Camera / vision | **Out of scope** |

## Owner local TODO (must do on your PC)

| ID | Task | Status |
|----|------|--------|
| L-1 … L-5 | Ollama + Cline 스모크 | Pending |
| L-6 … L-10 | untrack, merge, tag, PR #3 | Pending |

### Decision (owner)

- Primary surface: Cline + Ollama; extension secondary.
- 프로젝트 SERA 폐기 (D19).
- Domain P0: **excelion**, **excelion-forge** (`state/PROJECT_MAP.md`).

## Out of scope

- Forking Cline/Continue at scale
- Camera / vision pipeline
- Full AI Runtime without new issues
