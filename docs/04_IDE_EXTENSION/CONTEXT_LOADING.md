# Context Loading (extension behavior — design only)

## Default pack

1. `state/CURRENT_STATE.md`
2. `state/TASK_MAP.md`
3. `state/CONTEXT_INDEX.md`
4. User-selected paths from CONTEXT_INDEX tables

## Rules

- Never auto-load entire `archive/` or full summary 000–086
- Prefer diffs and single files over whole tree dumps
- After session: human or process updates `state/` and commits

## Local LLM

- Configure base URL to local host / LAN Ollama (or equivalent)
- Model choice is environment-specific; not hardcoded in this spec
