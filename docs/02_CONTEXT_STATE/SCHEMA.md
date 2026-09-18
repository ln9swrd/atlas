# Context & State Schema (documentation level)

## Purpose

Define what Git stores so agents and humans share one context without chat dependency.

## state/ files

| File | Fields (conceptual) |
|------|---------------------|
| `CURRENT_STATE.md` | date, phase, active_goal, blockers, next_one_thing |
| `TASK_MAP.md` | id, task, status |
| `PROJECT_MAP.md` | systems vs projects, legacy paths |
| `CONTEXT_INDEX.md` | always-read list, by-task lists |

## Task metadata (from operations design)

Document-level fields (not requiring code):

- `estimate` — expected effort
- `environment` — e.g. DEV_WORK / DEV_HOME
- `depends_on` — prerequisite task ids
- `status` — planned / active / done / blocked

## Rules

1. Update `CURRENT_STATE.md` when a session ends
2. Commit state changes with docs so history is recoverable
3. Do not treat chat as system of record

## Canonical archive refs

001, 002, 013, 019, 047, 052, 055, 069
