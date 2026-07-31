# projects/

Domain work lives here. **Atlas DevOS** lives at repo root (`state/`, `docs/`, `AGENTS.md`).

## Map

See **`state/PROJECT_MAP.md`** (authoritative inventory) and **`docs/process/PROJECT_REGISTRY.md`**.

| Folder | Role |
|--------|------|
| `_template/` | New project `state/` template (**only**) |
| `excelion/` | Game / IP (P0) |
| `excelion-forge/` | Forge pipeline (P0, canonical) |
| `printguard/` | Business / pre-print (P2) |
| `coin-s/` | Experiment (submodule, P3) |
| `atlas-extension/` | VS Code extension — **Deprecated (D22)** |

## Archived (not under projects/)

| Path | Role |
|------|------|
| `archive/projects-forge-legacy/` | Was `projects/forge/` (D26) |
| `archive/projects-templates-legacy/` | Was `projects/templates/` (R2) |

## Rules

- No `projects/sera` (D19).
- Shared state for AI modes: `docs/process/PROJECT_STATE_SCHEMA.md`.
- Do not auto-load `archive/` / `obsidian/` into project agent context.
