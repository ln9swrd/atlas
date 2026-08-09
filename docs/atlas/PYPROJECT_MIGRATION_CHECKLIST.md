# pyproject.toml Migration Checklist — Issue #32

> Source draft: `pyproject.toml.draft` (if present on branch) / DEPENDENCY_STRATEGY.md  
> **Do not apply to main until approved.**

## Checklist

### requirements-dev

- [ ] Keep `requirements-dev.txt` working during transition
- [ ] Either pin `pytest>=8.0` or switch to `pip install ".[dev]"`
- [ ] CI still installs a minimal dev set

### optional vision

- [ ] `vision` extra lists: opencv-python-headless, torch, torchvision, Pillow, numpy
- [ ] Not installed in default CI
- [ ] Align with R1: after VisualPerception removal, extra may be deferred

### CI

- [ ] `.github/workflows/ci.yml` continues green on ubuntu + Python 3.11
- [ ] No accidental install of torch in CI
- [ ] unittest discover path unchanged

### editable install

- [ ] Decide whether package is installable (`pip install -e .`)
- [ ] If yes: verify `core` importable without path hacks
- [ ] If no: document running tests from repo root only

### Python version

- [ ] `requires-python = ">=3.11"` matches CI
- [ ] No 3.12-only syntax without CI matrix update

## Recommended first implementation PR (later)

1. Add real `pyproject.toml` from draft
2. Leave `requirements-dev.txt` as thin pytest pin
3. Do not change CI command yet
4. Validate locally: `pip install -r requirements-dev.txt && unittest discover`

**Status:** Checklist only — application blocked.
