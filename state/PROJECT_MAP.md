# PROJECT_MAP

> Atlas(DevOS) ≠ domain project. Schema: `docs/process/PROJECT_STATE_SCHEMA.md`  
> Updated: 2026-07-30 — P2 state seed for P0 projects

## System (not domain projects)

| Name | Role |
|------|------|
| **Atlas** | DevOS — root `state/`, `docs/`, `AGENTS.md` |
| **Cloud AI (mode)** | Optional mode — not a project (D19) |
| **Kraken** | Layer name only — not a project |
| **Cline / Continue** | Tools — not memory |

## Domain projects (implement / deliver on Atlas)

| ID | Path | Status | Priority | Has `state/`? | Notes |
|----|------|--------|----------|---------------|-------|
| **excelion** | `projects/excelion/` | active | **P0** | **Yes** | Game/IP |
| **excelion-forge** | `projects/excelion-forge/` | active | **P0** | **Yes** | Canonical Forge; issue #7 |
| **printguard** | `projects/printguard/` | planning | P2 | No | Docs only |
| **coin-s** | `projects/coin-s/` | planning / submodule | P3 | Unknown | Submodule |

## Platform-adjacent

| ID | Path | Status | Notes |
|----|------|--------|-------|
| **atlas-extension** | `projects/atlas-extension/` | secondary | IMP-1 / issue #2 |

## Templates

| Path | Role |
|------|------|
| `projects/_template/` | Canonical state template |
| `projects/templates/project_template/` | Older — prefer `_template` |

## Duplicate / clarify later (P3)

| Path | Issue |
|------|--------|
| `projects/forge/` | vs excelion-forge |
| `projects/excelion/projects/exelion_forge/` | Nested stub |

## Deprecated

**SERA (project)** — D19 — no `projects/sera`
