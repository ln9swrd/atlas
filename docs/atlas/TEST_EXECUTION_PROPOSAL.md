# Test Execution Consolidation Proposal

> Related: Issue #31 · Status: Proposal · 2026-08-09

## 1. Current Structure

### `tests/` (CI-included)

Discovered by:

```bash
python -m unittest discover -s tests -p 'test_*.py'
```

| File | Purpose |
|------|---------|
| `test_architecture.py` | Architecture / layout checks |
| `test_atlas_runner.py` | Runner / decision path integration |
| `test_cognitive_engine.py` | Cognitive engine |
| `test_context_resolver.py` | Context resolution |
| `test_contracts.py` | Contract validation |
| `test_digital_vision.py` | DigitalVisionInspector (no cv2) |
| `test_domain_policy.py` | Domain policy |
| `test_environment_registry.py` | Environment registry |
| `test_goal_registry.py` | Goal registry |
| `test_runtime_context.py` | Runtime context |
| `test_visual_perception.py` | Optional/experimental vision guards |

**Count:** 11 files · **CI:** Yes · **Runtime:** ~47 tests (PASS)

### `core/tests/` (CI-excluded)

Not discovered by current CI workflow.

| File | Purpose |
|------|---------|
| `test_atlas_runner_audit.py` | Runner audit |
| `test_decision_engine.py` | Decision engine unit |
| `test_decision_logging.py` | Decision logging |
| `test_decision_metadata.py` | Decision metadata |
| `test_decision_registry.py` | Decision registry |
| `test_end_to_end_workflow.py` | E2E workflow |
| `test_forge_scenario.py` | Forge scenario (HOLD-related) |
| `test_memory_hierarchy.py` | Memory hierarchy |
| `test_priority_engine.py` | Priority engine |
| `test_runtime_features.py` | Runtime features |
| `test_task_broker.py` | Task broker |
| `test_task_queue.py` | Task queue |
| `test_task_registry.py` | Task registry |

**Count:** 13 files · **CI:** No

### Policy note

`docs/atlas/TESTING_POLICY.md` currently states `core/tests/` is empty. That is **incorrect** as of main HEAD. Policy must be updated after this consolidation decision.

---

## 2. Problems

1. **Split brain** — CI only sees half of the suite; core decision/task coverage lives outside CI.
2. **Policy drift** — TESTING_POLICY claims `core/tests` is empty.
3. **Discovery ambiguity** — Contributors may put tests in either tree.
4. **Forge HOLD leakage** — `core/tests/test_forge_scenario.py` may pull HOLD-area assumptions into local runs.

---

## 3. Recommended Integration Plan

**Canonical root:** `tests/` only for CI.

| Action | Detail |
|--------|--------|
| Keep | All current `tests/*` as-is |
| Move | Non-HOLD modules from `core/tests/` → `tests/` (or `tests/core/`) |
| Exclude or gate | Forge-related tests until Forge is ACTIVE |
| Update | CI remains single discover path on `tests/` |
| Update | TESTING_POLICY.md to match reality |

Optional layout after move:

```
tests/
  test_*.py              # existing
  core/                  # optional subpackage for former core/tests
    test_decision_*.py
    ...
```

If using a subdirectory, CI must either:
- discover recursively, or
- add a second discover step for `tests/core`.

Prefer **flat `tests/`** for minimal CI change.

---

## 4. Phased Migration

### Phase A (docs only — this proposal)
- Publish structure inventory
- Correct TESTING_POLICY narrative in a follow-up PR

### Phase B (low risk)
1. Move pure unit tests from `core/tests/` that have no HOLD deps into `tests/`
2. Run full suite locally + CI
3. Delete empty leftovers under `core/tests/` or leave a README pointing to `tests/`

### Phase C (gated)
- `test_forge_scenario.py`: keep out of CI while Forge is HOLD, or mark skip
- E2E tests: ensure no optional heavy imports at module level

### Phase D
- Remove `core/tests/` directory once empty
- Single source of truth documented in TESTING_POLICY

---

## 5. CI Impact

| Change | Impact |
|--------|--------|
| Stay on `discover -s tests` | Zero workflow change |
| Add moved tests | Longer CI time (expected modest) |
| Accidentally include Forge tests | Risk of false failures → gate with skip/HOLD |
| Dual discover (`tests` + `core/tests`) | Avoid; increases complexity |

**Recommendation:** Do **not** point CI at `core/tests` permanently. Migrate inward to `tests/`.

---

## 6. Decision Request

Approve Phase B move list, then implement in a follow-up code PR (not this docs PR).

## Related

- Issue #31
- `docs/atlas/TESTING_POLICY.md`
- `.github/workflows/ci.yml`
