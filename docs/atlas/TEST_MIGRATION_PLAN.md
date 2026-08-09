# Test Migration Plan — Issue #31

> Decision: 안 B (`core/tests` → `tests`) · **No moves in this document cycle**

## 1. Move targets

From `core/tests/` → `tests/` (flat preferred):

| Source | Dest (proposed) | HOLD gate? |
|--------|-----------------|------------|
| `test_atlas_runner_audit.py` | `tests/test_atlas_runner_audit.py` | No |
| `test_decision_engine.py` | `tests/test_decision_engine.py` | No |
| `test_decision_logging.py` | `tests/test_decision_logging.py` | No |
| `test_decision_metadata.py` | `tests/test_decision_metadata.py` | No |
| `test_decision_registry.py` | `tests/test_decision_registry.py` | No |
| `test_end_to_end_workflow.py` | `tests/test_end_to_end_workflow.py` | Review |
| `test_memory_hierarchy.py` | `tests/test_memory_hierarchy.py` | No |
| `test_priority_engine.py` | `tests/test_priority_engine.py` | No |
| `test_runtime_features.py` | `tests/test_runtime_features.py` | No |
| `test_task_broker.py` | `tests/test_task_broker.py` | No |
| `test_task_queue.py` | `tests/test_task_queue.py` | No |
| `test_task_registry.py` | `tests/test_task_registry.py` | No |
| `test_forge_scenario.py` | keep out of CI or `skip` while Forge HOLD | **Yes** |

Name collisions: none expected with existing `tests/test_*.py`.

## 2. Import impact

- Tests already import `core.*` with repo root on `sys.path` or package layout.
- Moving file location does not change module under test.
- Watch for relative path hacks (`os.path.join(..., "..")`) — re-check after move.
- `test_atlas_runner.py` (already in `tests/`) may overlap thematically with audit test — run both; no merge required.

## 3. CI impact

Current:

```bash
python -m unittest discover -s tests -p 'test_*.py'
```

After move: **same command** discovers new files automatically.  
No workflow change required if flat `tests/` is used.

Do **not** add a second discover on `core/tests`.

## 4. Likely failure modes

| Risk | Mitigation |
|------|------------|
| Forge scenario fails or imports HOLD paths | `@unittest.skip` or exclude from move until ACTIVE |
| E2E assumes local files/state | Run isolated; mock external IO |
| Path-dependent config loads | Fix to package-relative paths |
| Longer CI | Acceptable; still pure Python |

## 5. Rollback

1. Revert migration commit(s)
2. Or `git mv` files back to `core/tests/`
3. CI discover path unchanged → rollback is file-only

## 6. Execution order (when approved)

1. Branch `fix/migrate-core-tests`
2. Move non-HOLD tests
3. Gate/skip forge test
4. Local + CI unittest
5. Update TESTING_POLICY (`core/tests` status)
6. Remove empty `core/tests` or add README pointer

**Status:** Plan only — implementation blocked pending master approve.
