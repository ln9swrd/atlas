# Visual Perception Removal Plan — Issue #33 (R1)

> Decision: Remove experimental `VisualPerceptionEngine`; keep `DigitalVisionInspector`.  
> **No deletions in this document cycle.**

## 1. Removal targets

| Path | Action |
|------|--------|
| `core/tools/visual_perception.py` | Delete or move to `archive/` |
| `tests/test_visual_perception.py` | Delete (guards only this module) |

## 2. References (current)

| Location | Role |
|----------|------|
| `core/tools/visual_perception.py` | Module definition |
| `tests/test_visual_perception.py` | Unit guards |
| Docs: VISUAL_PERCEPTION_REDESIGN, DEPENDENCY_STRATEGY, TESTING_POLICY | Narrative only |

Search note: no DecisionEngine import of VisualPerceptionEngine (removed in PR #25).

## 3. Impact scope

| Area | Impact |
|------|--------|
| CI default path | Safer / simpler (one fewer test file) |
| DigitalVisionInspector | **Unchanged** |
| Excelion | None |
| Optional vision extra (#32) | Remains design-only until product need |
| Runtime callers | None known outside tests |

## 4. Delete order (when approved)

1. Branch `fix/remove-experimental-visual-perception`
2. Delete `tests/test_visual_perception.py`
3. Delete or archive `core/tools/visual_perception.py`
4. Grep repo for residual imports; fix docs if needed
5. `python -m unittest discover -s tests -p 'test_*.py'`
6. PR + CI green

## 5. Rollback

- Revert the removal commit, or restore files from git history / archive.

## 6. Non-goals

- Implementing YOLO / torch backend
- Changing DigitalVisionInspector behavior
- Applying `pyproject.toml` vision extra

**Status:** Plan only — implementation blocked pending master approve.
