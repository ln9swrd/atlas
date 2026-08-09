# Visual Perception Removal Plan — Issue #33 (R1)

> Decision: Remove experimental `VisualPerceptionEngine`; keep `DigitalVisionInspector`.  
> **Status: executed on branch `fix/remove-experimental-visual-perception`**

## 1. Removal targets

| Path | Action | Result |
|------|--------|--------|
| `core/tools/visual_perception.py` | Delete | **Deleted** |
| `tests/test_visual_perception.py` | Delete | **Deleted** |

## 2. References (pre-delete verification)

| Location | Role |
|----------|------|
| `core/tools/visual_perception.py` | Module definition |
| `tests/test_visual_perception.py` | Unit guards only |
| Docs: VISUAL_PERCEPTION_REDESIGN, DEPENDENCY_STRATEGY, TESTING_POLICY | Narrative only |

Search: no DecisionEngine / runtime import of VisualPerceptionEngine (removed in PR #25).  
Only import site was the test file itself.

## 3. Impact scope

| Area | Impact |
|------|--------|
| CI default path | Safer / simpler (one fewer test file) |
| DigitalVisionInspector | **Unchanged** |
| Excelion | None |
| Optional vision extra (#32) | Remains design-only · **HOLD** |
| Runtime callers | None outside tests |

## 4. Delete order (executed)

1. Branch `fix/remove-experimental-visual-perception`
2. Delete `tests/test_visual_perception.py`
3. Delete `core/tools/visual_perception.py`
4. Grep residual imports — clean
5. CI `unittest discover -s tests`
6. PR + master approve + merge

## 5. Rollback

- Revert the removal commits, or restore files from git history.

## 6. Non-goals

- Implementing YOLO / torch backend
- Changing DigitalVisionInspector behavior
- Applying `pyproject.toml` vision extra (#32 HOLD)
