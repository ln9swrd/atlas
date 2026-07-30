# projects/

Domain work lives here. **Atlas DevOS** lives at repo root (`state/`, `docs/`, `AGENTS.md`).

## Map

See **`state/PROJECT_MAP.md`** (authoritative inventory) and **`docs/process/PROJECT_REGISTRY.md`**.

| Folder | Role |
|--------|------|
| `_template/` | New project `state/` template |
| `excelion/` | Game / IP (P0) |
| `excelion-forge/` | Forge pipeline (P0, canonical) |
| `printguard/` | Business / pre-print (P2) |
| `coin-s/` | Experiment (submodule, P3) |
| `atlas-extension/` | VS Code extension (platform-adjacent) |
| `forge/` | Legacy/alternate — do not treat as second product yet |
| `templates/` | Older project_template — prefer `_template` |

## Rules

- No `projects/sera` (D19).
- Shared state for AI modes: `docs/process/PROJECT_STATE_SCHEMA.md`.
- Do not auto-load `archive/` / `obsidian/` into project agent context.
