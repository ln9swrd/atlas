# CONTEXT_INDEX

> Platform hardening (P2). 제품 트리 전체 로드 금지.

## Always (Atlas)

| Path | Why |
|------|-----|
| `state/CURRENT_STATE.md` | 지금 타겟 |
| `state/TASK_MAP.md` | 열린 작업 |
| `docs/07_ROADMAP/ATLAS_PLATFORM_PLAN.md` | 플랫폼 계획 |
| `docs/07_ROADMAP/D23_VERIFY_CWD_JAIL_DESIGN.md` | P2-1 draft |
| `docs/07_ROADMAP/ATLAS_MIN_SCOPE.md` | 최소 구현 (완료) |
| `AGENTS.md` | 도메인·Evidence |
| `docs/DECISIONS.md` | D01–D26 |
| `docs/06_OPERATIONS/DAILY_LOOP.md` | 세션 루프 |
| `docs/05_AGENTS/ROLE_SPLIT.md` | Master/Cline/Cloud |

## Tools (필요 시 1개)

- `tools/domain_policy.py` / `tools/check_domain_policy.py`
- `tools/INVENTORY.md` · `tools/DOMAIN_BLACKLIST.md`

## Hold — 열지 말 것 (지금)

- `projects/excelion*/**`, `projects/printguard/**`, `projects/coin-s/**`
- `projects/atlas-extension/**` (D22)
- `projects/forge/**` (legacy; D26 deferred)
- `archive/`, `obsidian/`
- `core/`, `atlas-runtime/` 대규모 탐색 (P3 전; P2-1 구현 시에만 해당 파일)

## Token discipline

ACTIVE_TARGET 관련 + Always 표만. summary 000–086 덤프 금지.
