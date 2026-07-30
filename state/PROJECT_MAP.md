# PROJECT_MAP

> Atlas(DevOS) ≠ domain project. Schema: `docs/process/PROJECT_STATE_SCHEMA.md`  
> Updated: 2026-07-30 — inventory of what exists under `projects/`

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
| **excelion** | `projects/excelion/` | active | **P0** | No → add from `_template` | Game/IP. Charter, backlog, nested `projects/exelion_forge/` (legacy nest) |
| **excelion-forge** | `projects/excelion-forge/` | active | **P0** | No → add from `_template` | Canonical Forge pipeline (code + `docs/`). Issue #7 Phase gate |
| **printguard** | `projects/printguard/` | planning | P2 | No | Docs only (`HANDOVER`, `PROJECT_STATUS`) |
| **coin-s** | `projects/coin-s/` | planning / submodule | P3 | Unknown | Git submodule; low Atlas coupling |

## Platform-adjacent (not product IP)

| ID | Path | Status | Priority | Notes |
|----|------|--------|----------|-------|
| **atlas-extension** | `projects/atlas-extension/` | secondary | P1 (after L-5) | VS Code extension; IMP-1 / issue #2. Prefer Cline as primary surface |

## Templates (not projects)

| Path | Role |
|------|------|
| `projects/_template/` | **Canonical** state template (CURRENT / TASK / CONTEXT) |
| `projects/templates/project_template/` | Older charter/backlog template — prefer `_template` for new work |

## Duplicate / clarify later

| Path | Issue |
|------|--------|
| `projects/forge/` | Smaller/older Forge tree vs **excelion-forge** — do not treat as second product without Decision |
| `projects/excelion/projects/exelion_forge/` | Nested stub; prefer `projects/excelion-forge/` as canonical |

## Deprecated

| Name | Rule |
|------|------|
| **SERA (project)** | D19 — no `projects/sera` |

## New project checklist

1. Copy `projects/_template/state/` → `projects/<name>/state/`
2. Register row in this file + `docs/process/PROJECT_REGISTRY.md`
3. Work modes: `cline` | `cloud` | `both` on shared state files only

## Legacy code (Atlas core — not domain apps)

`core/`, `src/`, `atlas-runtime/`, `tools/` — snapshot; no modify without issue.
