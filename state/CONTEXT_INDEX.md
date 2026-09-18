# CONTEXT_INDEX

> ACTIVE_TARGET = **idle** (closeout 2026-07-31 · maintenance 2026-08-04). 제품 트리 전체 로드 금지.

## Always (Atlas)

| Path | Why |
|------|-----|
| `state/CURRENT_STATE.md` | 지금 타겟 (SoR) |
| `state/TASK_MAP.md` | 열린 작업 (SoR) |
| `docs/06_OPERATIONS/DAILY_LOOP.md` | 세션 루프 |
| `docs/06_OPERATIONS/DECISION_PROCESS.md` | Decision 규율 |
| `docs/06_OPERATIONS/STATE_DISCIPLINE.md` | state SoR 규칙 |
| `docs/06_OPERATIONS/BINARY_ASSET_POLICY.md` | 바이너리 정책 |
| `docs/DECISIONS.md` | D01–D30 SoR |
| `docs/05_AGENTS/ROLE_SPLIT.md` | Master / Cloud / optional local agent |
| `docs/GLOSSARY.md` | 용어 (D30 surface) |
| `AGENTS.md` | 도메인·Evidence |

## Optional (platform hygiene)

| Path | Why |
|------|-----|
| `docs/07_ROADMAP/P3_RUNTIME_INVENTORY.md` | P3 inventory |
| `docs/07_ROADMAP/ATLAS_MIN_SCOPE.md` | Min complete + D30 note |
| `docs/ROADMAP.md` | historical; maintenance banner |

## Tools (필요 시 1개)

- `tools/atlas_status.sh`
- `tools/domain_policy.py` / `tools/check_domain_policy.py`

## Hold — 열지 말 것 (지금)

- product repos (excelion / excelion-forge) — 별도 레포 SoR
- `projects/printguard/**`, `projects/coin-s/**`, `projects/paramodel/**`
- `archive/**`
- `obsidian/`
- `core/tools` blender|ue, `core/forge`, `core/vision` (product-coupled; P3 tag only)

## Token discipline

ACTIVE_TARGET 관련 + Always 표만.
