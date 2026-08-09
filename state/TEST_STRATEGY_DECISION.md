# Test Strategy Decision — Issue #31

> Date: 2026-08-09 · Source: docs/atlas/TEST_EXECUTION_PROPOSAL.md

## Options

| 안 | Description |
|----|-------------|
| A | Keep `core/tests`; expand CI to discover both |
| B | Move `core/tests` → `tests` (single CI root) |
| C | Status quo (CI only `tests/`) |

## Decision

**안 B — integrate into `tests/`**

### Reasons
1. Single discovery path matches CI and TESTING_POLICY intent
2. Avoids permanent dual-root complexity
3. Surfaces currently unrun decision/task coverage in CI
4. Forge-related tests can be skipped while HOLD

### Non-goals this cycle
- Immediate file moves (requires follow-up implementation PR after #35 merge)
- Expanding CI to `core/tests` without migration (안 A rejected)

## Implementation gate

| Step | Action |
|------|--------|
| 1 | Merge PR #35 |
| 2 | Correct TESTING_POLICY (`core/tests` not empty) |
| 3 | Code PR: move non-HOLD tests; skip/gate forge scenario |
| 4 | Confirm unittest count + CI green |
| 5 | Remove empty `core/tests` or leave pointer README |

## Start implementation?

**Docs: yes (merge #35).**  
**Code migration: wait for explicit master approve after #35 merge.**
