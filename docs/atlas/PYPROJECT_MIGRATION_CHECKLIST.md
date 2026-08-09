# pyproject.toml Migration Checklist — Issue #32

> Source: `pyproject.toml.draft` → applied as `pyproject.toml`  
> DEPENDENCY_STRATEGY.md · **1st implementation PR scope only**

## Checklist

### requirements-dev

- [x] Keep `requirements-dev.txt` working during transition
- [x] Either pin `pytest>=8.0` or switch to `pip install ".[dev]"` — **kept pin**
- [x] CI still installs a minimal dev set

### optional vision

- [x] `vision` extra lists: opencv-python-headless, torch, torchvision, Pillow, numpy
- [x] Not installed in default CI
- [x] Align with R1: after VisualPerception removal, extra deferred (comment in pyproject.toml)

### CI

- [x] `.github/workflows/ci.yml` continues green on ubuntu + Python 3.11 — **no change this PR**
- [x] No accidental install of torch in CI
- [x] unittest discover path unchanged

### editable install

- [x] Decide whether package is installable (`pip install -e .`) — **No for 1st PR**
- [x] If no: document running tests from repo root only (CI + TESTING_POLICY)

### Python version

- [x] `requires-python = ">=3.11"` matches CI
- [x] No 3.12-only syntax without CI matrix update

## 1st implementation (this PR)

1. Add real `pyproject.toml` from draft
2. Leave `requirements-dev.txt` as thin pytest pin
3. Do not change CI command
4. Validate via CI: `pip install -r requirements-dev.txt && unittest discover`

## Out of scope (this PR)

- CI switch to `pip install ".[dev]"`
- editable install / removing sys.path hacks in tests
- Excelion / Forge / vision runtime

**Status:** Implementation PR — await CI + master approve.
