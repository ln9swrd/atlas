# TASK_MAP

## Git-only (G-*)

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| G1–G5 | schema / D19 wording 등 | **Done** | |
| G6 | Decision 초안 #4–#7 | **Draft** | `docs/06_OPERATIONS/G6_DECISION_DRAFTS.md` — 마스터 승인 대기 |

## Owner local (L-*)

| ID | Task | Status | Executor | How |
|----|------|--------|----------|-----|
| L-1…L-7 | setup / rebase 등 | **Done** | | |
| L-8 | rebase impl ← main | **Pending** | 마스터 | `bash scripts/master_l8_l10.sh l8` |
| L-9 | untrack + push | **Pending** | 마스터 | `bash scripts/master_l8_l10.sh l9` |
| L-8+L-9 | batch | **Pending** | 마스터 | `bash scripts/master_l8_l10.sh l8-l9` |
| L-10 npm | compile | **Pending** | 마스터 | `bash scripts/master_l8_l10.sh l10-npm` |
| L-10 F5+merge | smoke + PR #3 | **Pending** | 마스터 | 수동 (MASTER_BATCH.md) |

Script: `scripts/master_l8_l10.sh`  
Guide: `docs/06_OPERATIONS/MASTER_BATCH.md`

## Cloud (CA-*)

| ID | Status | Evidence |
|----|--------|----------|
| CA-1 ACTIVE_MODE both | **Done** | excelion-forge state |
| CA-3 G6+L8 review Git | **Partial** | G6_DRAFTS, L8_L10_CLOUD_REVIEW |
| CA-4 local Evidence | **Pending** | after master_l8_l10.sh |

## IMP-1

Extension issue #2 / PR #3 — open until L-10 merge.
