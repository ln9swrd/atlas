# Project Registry

Known **domain** projects on Atlas. Platform = Atlas DevOS (not listed as a deliverable product).

Source of path truth: `state/PROJECT_MAP.md`  
State schema: `docs/process/PROJECT_STATE_SCHEMA.md`  
Updated: 2026-07-30

## Active / planned domain projects

| Name | Path | Status | Type | Priority | state/ | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Excelion (Exelion) | `projects/excelion/` | active | game_ip | **critical** | missing | Main mecha/IP product |
| Excelion Forge | `projects/excelion-forge/` | active | pipeline | **high** | missing | Blender/rig validation pipeline (canonical Forge) |
| PrintGuard | `projects/printguard/` | planning | business | medium | missing | Pre-print QA initiative |
| Coin-S | `projects/coin-s/` | planning | software | low | n/a (submodule) | Analysis experiment |

## Platform-adjacent

| Name | Path | Status | Notes |
| :--- | :--- | :--- | :--- |
| atlas-extension | `projects/atlas-extension/` | secondary | issue #2 / PR #3; secondary to Cline |

## Deprecated

| Name | Status |
| :--- | :--- |
| Sera (project) | **deprecated (D19)** — not implementable as standalone project |

## Not separate products (until Decision)

- `projects/forge/` — clarify vs excelion-forge
- `projects/excelion/projects/exelion_forge/` — nested legacy; use excelion-forge

## Intent

- **Excelion**: ship IP/product experience.
- **Excelion Forge**: asset/rig pipeline tool under Atlas.
- **PrintGuard / Coin-S**: as priority allows.
- **Atlas**: DevOS only — coordinates state, agents, evidence.

## Onboarding a project for Cline / cloud / both

1. Ensure `projects/<name>/state/` from `_template`
2. Set `ACTIVE_MODE` in CURRENT_STATE
3. One Next row in TASK_MAP with assignee `human` | `cline` | `cloud` | `both`
