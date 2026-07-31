# PROJECT_MAP

> Schema: `docs/process/PROJECT_STATE_SCHEMA.md` · D20 Forge paths  
> Updated: 2026-07-31 (F3 path hygiene + physical archive)

## System (not domain projects)

| Name | Role |
|------|------|
| **Atlas** | DevOS |
| **Cloud AI (mode)** | Mode only (D19) |
| **Kraken** | Layer name only — **no** `projects/kraken/` (D24) |
| **Cline / Continue** | Tools |

## Domain projects

| ID | Path | Status | Priority | state/ | Notes |
|----|------|--------|----------|--------|-------|
| **excelion** | `projects/excelion/` | hold | P0 | Yes | Game/IP — product hold until ACTIVE_TARGET |
| **excelion-forge** | `projects/excelion-forge/` | hold | P0 | Yes | **Canonical Forge (D20/D26)** |
| **printguard** | `projects/printguard/` | planning | P2 | No | Docs only |
| **coin-s** | `projects/coin-s/` | planning | P3 | — | Submodule |

## Platform-adjacent

| ID | Path | Notes |
|----|------|-------|
| atlas-extension | `projects/atlas-extension/` | **Deprecated (D22)** — do not revive |

## Legacy / non-product (D20 / D26)

| Path | Role | F3 |
|------|------|-----|
| `archive/projects-forge-legacy/` | Was `projects/forge/` (App-host experiment). **Not** product Forge. | **Physical move Done** 2026-07-31 |
| Nested excelion forge stubs | Ignore / cleanup candidate (R3) | — |
| `projects/templates/` | Prefer `_template`; cleanup candidate (R2) | — |

## Templates

`projects/_template/` — use for new project state.

## Deprecated

SERA project — D19.

## F3 Evidence (2026-07-31)

| Decision | Result |
|----------|--------|
| D24 Kraken | **N/A** — no `projects/kraken/`; no `tools/kraken/` code to move |
| D25 Sprint knowledge | **OK** — no SPRINT-009–029 Open in TASK_MAP |
| D26 Forge paths | **Done** — canonical = excelion-forge; forge → `archive/projects-forge-legacy` |
