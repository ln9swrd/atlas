# projects/

Domain work lives here. **Atlas DevOS** lives at repo root (`state/`, `docs/`, `AGENTS.md`).

## Map

See **`state/PROJECT_MAP.md`**.

| Folder | Role |
|--------|------|
| `_template/` | New project `state/` template (**only**) |
| `excelion/` | Game / IP (P0) |
| `excelion-forge/` | Forge pipeline (P0, canonical) |
| `printguard/` | Business / pre-print (P2) |
| `coin-s/` | Experiment (submodule, P3) |

## Archived (not under projects/)

| Path | Role |
|------|------|
| `archive/projects-forge-legacy/` | Was forge (D26) |
| `archive/projects-templates-legacy/` | Was templates (R2) |
| `archive/excelion-exelion_forge-stub/` | Nested stub (R3) |
| `archive/projects-atlas-extension-legacy/` | VS Code extension (D22/R4) |

## Rules

- No `projects/sera` (D19).
- Do not auto-load `archive/` / `obsidian/` into agent context.
