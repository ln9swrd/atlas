# MENOS

MENOS is a Godot 4.7.2 single-player super-robot combat project. The current Master Canon defines the player as the pilot directly controlling one super robot; AI allies and fixed support facilities assist the player.

## Current project documents

- `MENOS_COMBAT_CANON.md` — Master-approved combat Canon
- `docs/MENOS_MASTER_REFERENCE.md` — consolidated current project reference
- `state/CURRENT_STATE.md` — current implementation and verification state
- `MENOS_WORK_METHOD_COPILOT_WORKER_SERA.md` — project work method
- `docs/MENU_GAMEPLAY_INTEGRATED_DEVELOPMENT_PLAN.md` — integrated development roadmap and chronological progress records
- `docs/CONTENT_EDITOR_IMPLEMENTATION_VERIFICATION_DECISION_MATRIX.md` — Content Editor implementation/verification decision summary
- `docs/SFX_PRODUCTION_PIPELINE.md` — source-agnostic SFX pipeline; actual provenance is recorded separately
- `archive/docs_consolidated_2026-10-07/` — consolidated superseded plans and historical design documents
- `archive/` root-level documents — legacy plans retained in place for traceability
- `docs/archive/` — topic-specific historical proposals and requirements

When documents conflict, use the Canon first, then CURRENT_STATE, then the Master Reference. The integrated development plan is chronological: older HOLD/PROPOSAL entries are historical checkpoints and do not override later dated completion/reconciliation records. Archived documents are historical evidence only; do not infer current status from an old baseline without checking CURRENT_STATE and Git.

## Godot

Open `godot/project.godot` with Godot 4.7.2. Windows Release export and exported EXE headless startup were verified on 2026-10-07.

## Document status rules

- **Canon:** `MENOS_COMBAT_CANON.md` and explicitly Master-approved decisions.
- **Current status:** `state/CURRENT_STATE.md`; dated records are historical unless identified as current.
- **Proposal/plan:** `docs/` design and development plans; a proposal does not become Canon by being implemented or documented.
- **History/archive:** `archive/` and `docs/archive/`; retained for traceability and not an active instruction source.
- Root-level archive plans and `archive/docs_consolidated_2026-10-07/` are both intentionally retained. Do not bulk-move or delete documents as part of consistency cleanup.

## Historical browser PoC

`index.html`, `data.js`, and `game.js` remain in the repository as earlier experimental material. They are not the current gameplay authority.
