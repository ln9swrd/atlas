# P4 + P1 Cleanup Executed — 2026-08-11

기준: `docs/maintenance/POLICY_HOLD_SURVEY_2026-08-11.md`  
기준 SHA: `c55a7c31f8711aabefa1e1a19b0711d715411f55`  
Master 승인: P4 DELETE · P1 ARCHIVE

## P4 — DELETE

| 경로 | 결과 |
|------|------|
| `core/review/print_settings.yaml` | **deleted** |
| 유지 | `core/config/print_settings.yaml` |

## P1 — ARCHIVE

| From | To |
|------|-----|
| `atlas-runtime/` (root) | removed from active tree |
| pointer | `archive/atlas-runtime-legacy/README.md` |

동반:
- `tools/domain_policy.py`: SYSTEM_ALLOW에서 `atlas-runtime/` 제거
- `tools/check_atlas_runtime.py`: DEPRECATED exit 1

Stub blobs remain in git history.

## 미처리

P2 R5 · P3 Alpha/Beta · core/README print 문구
