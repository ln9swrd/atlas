# Phase 4 Closeout — 2026-08-09

## Tech-debt issues (implementation)

| Issue | Title | PR | Merge SHA | Status |
|-------|-------|-----|-----------|--------|
| #31 | consolidate test execution strategy | #42 | `9033d68971bb44f5dd8d6433869bd2f08d1a8d2b` | **DONE** |
| #33 | VisualPerception R1 removal | #44 | `46d59a3e9bd0df252a09874a6c5403dc67fe487f` | **DONE** |
| #32 | pyproject.toml (minimal) | #45 | `5d6d7c20fecfa29edae22367dfa8986e9e0bb891` | **DONE** |

Supporting state PR: #43 (record #31) Merge SHA `5f945b73318f767754acd3cd8f309e38f8b94ce6`

## Explicit HOLD

| Scope | Notes |
|-------|--------|
| Excelion | product HOLD |
| Forge / UE / Visualization | HOLD |
| CI → `pip install ".[dev]"` | deferred |
| editable install / path-hack cleanup | deferred |
| vision extra install in CI | never (opt-in only) |

## Phase 4 result

- Platform tech-debt trio **#31 / #33 / #32** closed under gated PRs
- No Excelion runtime work this phase
- ACTIVE_TARGET remains **idle** (platform)

## Next (not started)

1. Re-audit residual tech debt (path hacks, dual requirements, docs only)
2. Master direction before any new implementation
