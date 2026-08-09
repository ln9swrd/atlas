# Visual Perception Redesign Proposal

> Related: Issue #33 · Status: Proposal · 2026-08-09

## 1. Current Structure

### A. `core/tools/visual_perception.py` — VisualPerceptionEngine

| Aspect | State |
|--------|-------|
| Role | Camera / YOLO-style detection facade |
| Deps | cv2, torch, torchvision, Pillow, numpy (lazy) |
| Model load | **NotImplementedError** — experimental |
| CI | Safe via optional deps + unit guards |
| Production | **No** |

### B. `core/vision/digital_vision_inspector.py` — DigitalVisionInspector

| Aspect | State |
|--------|-------|
| Role | Digital screen / asset / viewport analysis |
| Camera | Explicitly **excluded** |
| Deps | stdlib only (json, os) |
| Implementation | Heuristic / stub metadata (not real VLM inference) |
| Tests | `tests/test_digital_vision.py` (CI) |

### C. Config

- `core/vision/vision_config.json` — digital-screen-only mode

---

## 2. Relationship

```
DecisionEngine ──(visual_data dict only)──► callers
        │
        ├── does NOT import VisualPerceptionEngine (cleaned in PR #25)
        │
DigitalVisionInspector ── digital assets / viewport buffers
VisualPerceptionEngine ── experimental hardware/YOLO path (blocked)
```

They are **parallel**, not layered:
- DigitalVisionInspector = Atlas “see the IDE / renders / files”
- VisualPerceptionEngine = unfinished “see the world via camera/YOLO”

No shared interface today.

---

## 3. Removal Option (VisualPerceptionEngine)

**When to remove**
- No ACTIVE product path needs camera YOLO
- Maintenance cost > value of the stub

**If removed**
1. Delete or archive `core/tools/visual_perception.py`
2. Keep `tests/test_visual_perception.py` only if a thin interface remains; else delete
3. Document in TESTING_POLICY / dependency strategy
4. Leave DigitalVisionInspector as the sole vision surface

**Cost of keeping experimental stub**
- Low runtime cost (lazy + NotImplementedError)
- Ongoing confusion (“looks like YOLO but isn’t”)
- Extra tests and docs surface

---

## 4. Redesign Options

### Option R1 — Single Vision Facade (recommended direction)

```
core/vision/
  protocol.py          # VisionBackend protocol
  digital_inspector.py # current DigitalVisionInspector
  optional_cv.py       # future real CV backend (optional deps)
```

- One protocol: `analyze(input) -> VisionResult`
- Digital backend default (stdlib)
- CV/YOLO backend optional extra; never import on CI default path

### Option R2 — Delete experimental, keep digital only

- Fastest cleanup
- Revisit YOLO only when product need is proven

### Option R3 — Implement real YOLO under optional extra

- Requires weights strategy, CI policy, GPU optional path
- **Not recommended** until DigitalVision path is product-proven

---

## 5. Maintenance Cost Analysis

| Item | Keep experimental | R2 Delete | R1 Facade |
|------|-------------------|-----------|-----------|
| CI risk | Low (already guarded) | Lowest | Low |
| Contributor confusion | Medium | Low | Low–Medium |
| Future CV work | Stub exists | Greenfield | Clear extension point |
| Doc burden | Medium | Low | Medium once |

**Recommendation:** Prefer **R2 short-term** or **R1 if** a second backend is planned within one quarter. Do not invest in real YOLO until DigitalVisionInspector delivers real value beyond stubs.

---

## 6. Proposed Next Steps

1. Decide R1 vs R2 (Issue #33 comment / owner decision)
2. If R2: small PR to remove/archive experimental module + adjust tests
3. If R1: introduce protocol without implementing torch path
4. Align with Issue #32 vision extra (only if CV backend retained)

## Out of scope

- Excelion
- Forge / UE / Visualization HOLD work
- Shipping production YOLO weights in-repo

## Related

- Issue #33
- PR #25 / #27 (optional + experimental guards)
- `core/vision/digital_vision_inspector.py`
- `core/tools/visual_perception.py`
