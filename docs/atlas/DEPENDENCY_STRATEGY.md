# Dependency Management Strategy

> Related: Issue #32 · Status: Proposal · 2026-08-09

## 1. Current State

| Artifact | Status |
|----------|--------|
| `requirements-dev.txt` | Exists — `pytest>=8.0` only |
| `requirements.txt` | Absent |
| `pyproject.toml` | Absent |
| `setup.py` / packaging | Absent |
| CI install | `pip install -r requirements-dev.txt` (PR #26) |

Core runtime modules largely use **stdlib only**. Optional vision stack is lazy-loaded.

---

## 2. Package Inventory

### Actually used (runtime paths)

| Category | Packages | Notes |
|----------|----------|-------|
| Stdlib | json, os, typing, unittest, ... | Primary |
| Optional vision | opencv-python, torch, torchvision, Pillow, numpy | Lazy in `visual_perception.py` |
| Dev / test | pytest (declared), unittest (stdlib) | CI uses unittest discover |

### HOLD / non-CI

- Blender / UE tooling scripts — environment-specific, not CI deps
- Excelion — JS/browser; separate from Python deps

---

## 3. Target Layout

Introduce `pyproject.toml` as source of truth; keep thin requirement files for compatibility.

### Draft `pyproject.toml`

```toml
[project]
name = "atlas"
version = "0.0.0"
description = "Atlas DevOS runtime"
requires-python = ">=3.11"
dependencies = []  # core stays stdlib-first

[project.optional-dependencies]
dev = [
  "pytest>=8.0",
]
vision = [
  "opencv-python-headless>=4.8",
  "torch",
  "torchvision",
  "Pillow",
  "numpy",
]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
```

### Compatibility files

```
requirements-dev.txt   → -e .[dev]  or pinned pytest only (short term)
requirements-vision.txt → optional mirror of vision extra (optional)
```

Short term (minimal change): keep `requirements-dev.txt` as-is; add `pyproject.toml` without forcing install of the package itself until ready.

---

## 4. Optional Extras Policy

| Extra | Install | CI default |
|-------|---------|------------|
| (none) | Core + tests | Yes |
| `dev` | pytest, future linters | Yes (via requirements-dev) |
| `vision` | cv2/torch stack | **No** — opt-in only |

Rules:
1. No heavy optional package at **module import** time on CI path.
2. Missing optional deps raise clear errors (`OptionalDependencyError`).
3. Vision tests that need real models stay out of default CI or use mocks.

---

## 5. Migration Plan

### Step 1 — Docs (this PR)
- Publish strategy

### Step 2 — Add `pyproject.toml`
- Empty core deps
- `dev` + `vision` extras
- Do not break existing `pip install -r requirements-dev.txt`

### Step 3 — Align CI
- Option A: keep requirements-dev.txt
- Option B: `pip install ".[dev]"` after packaging metadata is stable

### Step 4 — Document
- Update README install section
- Link from TESTING_POLICY

### Out of scope
- Publishing to PyPI
- Full monorepo workspace for Excelion JS

---

## 6. Risks

| Risk | Mitigation |
|------|------------|
| Accidental torch in CI | Keep vision out of default extra; CI only installs dev |
| Dual source of truth | Prefer pyproject; generate or thin-wrap requirements files |
| Version pin churn | Pin only what CI needs initially |

## Related

- Issue #32
- Issue #23 / PR #25 (optional vision)
- `requirements-dev.txt`
- `.github/workflows/ci.yml`
