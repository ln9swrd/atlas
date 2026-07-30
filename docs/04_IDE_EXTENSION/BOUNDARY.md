# Extension ↔ Orchestrator boundary

Issue #2 · branch `impl/atlas-extension`

## Components

```
┌─────────────────────────────┐
│  VS Code Extension          │
│  projects/atlas-extension/  │
│  - extension.ts (activate)  │
│  - sidebarProvider.ts (UI)  │
│  - media/main.js            │
└─────────────┬───────────────┘
              │ spawn(python3 -u tools/atlas_qwen_orchestrator.py, prompt)
              │ env: OLLAMA_HOST, OLLAMA_MODEL, PYTHONUNBUFFERED
              │ cwd: repo root (parent of tools/)
              ▼
┌─────────────────────────────┐
│  Orchestrator (CLI tool)    │
│  tools/atlas_qwen_orchestrator.py
│  - Domain isolation         │
│  - Ollama stream            │
│  - execute_cli / read/write │
└─────────────────────────────┘
```

## Ownership

| Concern | Owner |
|---------|--------|
| Webview UI, settings (`atlas.ollamaHost`, `atlas.model`) | Extension |
| Streaming tokens to panel | Extension (stdout pipe) |
| Domain blacklist (`archive`, `obsidian`, `node_modules`, …) | **Orchestrator** |
| Tool loop (`<action>` JSON) | Orchestrator |
| Canonical state files | Git `state/` (both may *read*; neither is SoR) |

## Rules

1. Extension **must not** reimplement domain isolation for file tools — call orchestrator.
2. Orchestrator **must not** hardcode a single machine path; use `ATLAS_ROOT` or process cwd.
3. `main` receives extension changes only via PR from `impl/atlas-extension`.
4. Camera / vision remain out of scope.

## Known duplication (acceptable short-term)

- Sidebar loads `CURRENT_STATE.md` + `AGENTS.md` for display context.
- Orchestrator `resolve_context()` may also load the same files for the model.
- Prefer tightening later so **one** path owns context assembly (orchestrator preferred).

## Local CLI smoke (without VS Code)

```bash
cd /path/to/atlas   # repo root
export OLLAMA_HOST=http://192.168.219.254:11434
export OLLAMA_MODEL=qwen3:14b
# optional: export ATLAS_ROOT="$(pwd)"
python3 -u tools/atlas_qwen_orchestrator.py "pwd"
```
