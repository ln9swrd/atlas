# CONTEXT_INDEX — <project-name>

> Open only paths listed here for the current Next item.

## Always

| Path | Why |
|------|-----|
| `projects/<name>/state/CURRENT_STATE.md` | Where this project is |
| `projects/<name>/state/TASK_MAP.md` | Open tasks |
| `docs/process/PROJECT_STATE_SCHEMA.md` | Shared schema |

## By task type

### Default implementation

- `projects/<name>/docs/` (if present)
- Active source paths for the current T-* only

## Forbidden (do not auto-load)

- `archive/`
- `obsidian/`
- `node_modules/`
- Other projects under `projects/` except explicit deps
- Atlas root history dumps

## Token discipline

Load the minimum set for Next one thing only.
