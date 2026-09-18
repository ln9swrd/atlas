# Atlas Testing Policy

> Status: Active · Updated 2026-08-09 (Issue #31 migration)

## CI Target

| Path | CI? | Notes |
|------|-----|-------|
| `tests/` | **Yes** | Primary suite. Discovered by `python -m unittest discover -s tests -p 'test_*.py'` |
| `core/tests/` | No | Deprecated (Issue #31). Pointer only — use `tests/`. |
| Project-local tests (e.g. Excelion JS) | No | Run via project-specific scripts; not part of Atlas CI. |
| Archive tests | No | Historical only. |

## CI Non-Target

- Optional heavy dependencies (cv2, torch, etc.) must not cause import-time failure.
- Legacy / archive modules must not be imported by active tests.
- Unreal / Forge / Visualization (HOLD) tests are out of scope for main CI.

## core/tests Handling

- Deprecated after Issue #31 migration — do not add new tests here.
- All CI-facing tests live under `tests/`.
- `test_forge_scenario.py` lives in `tests/` but is skipped while Forge is HOLD.

## New Test Rules

1. Place unit / integration tests under `tests/` with prefix `test_`.
2. Keep tests free of optional heavy deps at import time (use lazy import or mocks).
3. Prefer pure-function / state-change tests over full browser or Canvas runs.
4. Name files and classes clearly (`test_<module>.py`).

## Optional Dependency Tests

- Use `OptionalDependencyError` (or equivalent) for missing optional packages.
- Guard experimental modules with `NotImplementedError` or clear experimental markers.
- Tests must pass in a minimal environment (`requirements-dev.txt` only).
- Mock optional stacks when verifying error paths.

## Running Locally

```bash
pip install -r requirements-dev.txt
python -m unittest discover -s tests -p 'test_*.py'
```

## Related

- `.github/workflows/ci.yml`
- `requirements-dev.txt`
- Issue #23 (cv2 / optional vision)
- Issue #31 (test consolidation)
