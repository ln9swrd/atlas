# PROJECT_MAP

## System layers (not projects)

| Layer | Role |
|-------|------|
| **Atlas** | DevOS — knowledge, state, verification, coordination |
| **Cloud AI (mode)** | Optional cloud-side design/analysis — **not a project** (legacy name SERA retired as project, D19) |
| **Kraken** | Local execution assistance (layer, not project) |
| **Cline / Continue** | Tool execution (not memory) |

## Domain projects (apps on Atlas)

| Project | Role | Docs target |
|---------|------|-------------|
| Excelion / Exelion | Game / IP | `projects/excelion/docs/` |
| Excelion Forge | Parametric asset pipeline | `projects/excelion-forge/docs/` |
| PrintGuard | Pre-print QA (business) | `projects/printguard/docs/` |
| Coin-S | Analysis experiment | `projects/coin-s/docs/` |

**Deprecated as project:** SERA — do not add `projects/sera`. Historical docs remain under `archive/` / `obsidian/`.

## Legacy code locations (snapshot — do not modify in rebuild)

- `core/`, `src/`, `atlas-runtime/`, `tools/`, `atlas_runner.py`

Treat as historical implementation snapshot until a separate implementation branch.
