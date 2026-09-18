# PR #42 Merge Result — Issue #31 DONE

> 2026-08-09 (KST)

## Result

| Field | Value |
|-------|-------|
| PR | **#42** |
| Title | fix(test): migrate core/tests into tests (Issue #31) |
| Status | **MERGED** |
| HEAD (pre-merge) | `b51900170c6caee68686ad53853dbeaa3c851fc6` |
| Merge SHA | `9033d68971bb44f5dd8d6433869bd2f08d1a8d2b` |
| CI Run | [31301608837](https://github.com/ln9swrd/atlas/actions/runs/31301608837) — **success** |
| Branch | `fix/migrate-core-tests` → `main` |
| Issue | **#31 = DONE** |

## Scope (executed)

- Migrated 13 CI-facing test modules: `core/tests/` → `tests/`
- Fixed `REPO_ROOT` / import paths for `tests/` layout
- `test_forge_scenario.py`: `@unittest.skip` while Forge HOLD
- `core/tests/README.md` deprecation pointer only
- Updated `docs/atlas/TESTING_POLICY.md`

## Out of scope (unchanged)

| Item | Status |
|------|--------|
| #33 VisualPerception removal | **next** (separate PR) |
| #32 pyproject.toml | **HOLD** |
| Excelion / Forge / UE / Visualization | **HOLD** |

## Next

1. #33 — remove experimental `VisualPerceptionEngine` (plan: `docs/atlas/VISUAL_PERCEPTION_REMOVAL_PLAN.md`)
2. #32 — HOLD until product need
3. Excelion — HOLD
