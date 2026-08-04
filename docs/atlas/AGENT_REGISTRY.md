# Agent Registry

This registry captures the primary agents / roles in Atlas and their responsibilities.

Updated: 2026-08-04 (D30)

## Agents / roles

| Agent | Role | Domain | Input | Output | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Marie | Systems architect and reviewer | architecture | requirements | design | conceptual |
| Antigravity | Implementation engine | implementation | design | code | conceptual |
| Forge | 3D specialist | production | concept | mesh_asset | domain project (HOLD) |
| ~~Cline + Ollama~~ | Was primary local work surface | execution | Git state | file/CLI evidence | **inactive (D30)** |
| Cloud AI (mode) | Design/review + authorized Git edits | analysis | same state files | docs/commits | **active mode** |
| Local agent | Optional multi-step tools if Master enables | execution | Git state | Evidence | optional only |
| ~~Sera~~ | Design and planning specialist | — | — | — | **deprecated as project/agent product (D19)** |

## Responsibility Model

- Atlas coordinates the operating system and execution flow.
- **Master** owns Done / ACTIVE_TARGET / Decision final (D21).
- **Cloud AI** assists design/review and may edit Git when authorized.
- **Cline** is not primary (D30). Do not reintroduce without Master.
- Forge handles production-oriented asset work when product is not HOLD.
- Marie / Antigravity remain conceptual labels unless promoted by Decision.
