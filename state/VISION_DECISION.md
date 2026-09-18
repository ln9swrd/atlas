# Vision Decision — Issue #33

> Date: 2026-08-09 · Source: docs/atlas/VISUAL_PERCEPTION_REDESIGN.md

## Options (this decision frame)

| ID | Choice |
|----|--------|
| **R1** | Remove experimental `VisualPerceptionEngine`; keep `DigitalVisionInspector` only |
| **R2** | Redesign / reimplement vision (facade or real CV backend) |

## Cost / effect

| | R1 Remove | R2 Redesign |
|--|-----------|-------------|
| Effort | S (delete/archive + test adjust) | M–L |
| CI risk | Lowest | Low if optional stays |
| Confusion | Removes YOLO-looking stub | Needs clear protocol |
| Future CV | Greenfield when needed | Extension point if facade |
| Product value now | None lost (stub not production) | Only if real backend ships |

## Decision

**R1 — remove experimental VisualPerception path; retain DigitalVisionInspector.**

### Reasons
1. Engine is experimental + `NotImplementedError` — no production path
2. DigitalVisionInspector already covers digital/screen asset cases in CI
3. Lowest maintenance; aligns with optional-deps discipline
4. Real CV can return later under Issue #32 `vision` extra when product need is proven

### Follow-up (implementation PR, after approve)
1. Archive or delete `core/tools/visual_perception.py`
2. Adjust/remove `tests/test_visual_perception.py`
3. Note in TESTING_POLICY / DEPENDENCY_STRATEGY
4. Do **not** implement YOLO in this cycle

## Start implementation?

**Docs: yes (merge #37).**  
**Code removal: wait for explicit master approve.**
