# Agent Registry

This registry captures the primary agents / roles in Atlas and their responsibilities.

Updated: 2026-07-30 (G5 / D19)

## Agents / roles

| Agent | Role | Domain | Input | Output | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Marie | Systems architect and reviewer | architecture | requirements | design | conceptual |
| Antigravity | Implementation engine | implementation | design | code | conceptual |
| Forge | 3D specialist | production | concept | mesh_asset | domain project |
| Cline + Ollama | Primary local work surface | execution | Git state | file/CLI evidence | **active** |
| Cloud AI (mode) | Optional design/review | analysis | same state files | suggestions/PR | mode only |
| ~~Sera~~ | Design and planning specialist | — | — | — | **deprecated as project/agent product (D19)** |

## Responsibility Model

- Atlas coordinates the operating system and execution flow.
- Cline executes against Git `state/` (Evidence-First).
- Cloud AI may assist design/review in `cloud` or `both` mode — not a registry project.
- Forge handles production-oriented asset work (Excelion Forge).
- Marie / Antigravity remain conceptual labels unless promoted by Decision.
