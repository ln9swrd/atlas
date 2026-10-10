# Content Editor Runtime-Aware Editor Development Plan

**Status:** PROPOSAL — investigation-based plan; no implementation or Canon change.
**Date:** 2026-10-10
**Scope:** All Content Editor menus and data editors. This plan is a new cross-editor goal and does not retroactively change the historical scope of the earlier five-menu UI pilot.

## 1. Goal

Every editor must respond to the selected Runtime target. The user must be able to inspect authoring/source content and the selected Runtime's corresponding data, understand the copy/publish state, and deliberately copy/publish content to the intended Runtime without affecting other Runtime targets.

The selected Runtime is a data target, not merely a launch destination. Runtime selection must be available consistently across editor menus.

## 2. Current-State Findings

- **CONFIRMED:** `content_editor.gd` owns the top-level editor navigation and Runtime toolbar. It persists Runtime project-root settings for import/publish workflows.
- **CONFIRMED:** `runtime_targets_manager.gd` registers Runtime project paths and stores a selected Runtime ID in `user://menos_settings.cfg`. Its table checkboxes are publish inclusion settings; they are not evidence of per-editor Runtime data browsing or cloning.
- **CONFIRMED:** `dual_database_compare.gd` displays a read-only comparison between the authoring SQLite database and the selected Runtime database, but its explicit scene-to-table mapping covers only Mission, Faction, Building, Skill, VFX, SFX, BGM, and Voice. This is not a universal per-editor integration.
- **CONFIRMED:** Robot, Unit, and Tower editor scripts load/save authoring catalogs through `ObjectRepository` and `ObjectPersistence`; they do not directly consult the selected Runtime ID.
- **CONFIRMED:** Map authoring uses per-map JSON under the Content Editor's `data/maps/` boundary. The existing map authoring contract explicitly excludes automatic Runtime file synchronization.
- **CONFIRMED:** the Runtime package publisher creates a new filtered package and does not overwrite Runtime source databases/assets. Current publish and package-selection behavior is distinct from an editor-level per-Runtime clone workflow.
- **CONFIRMED:** the current editor inventory includes Map, Stage, Unit, Tower, Building, Robot, Asset Catalog/Image, Faction, Skill, Mission, Campaign, VFX, SFX, Voice, BGM, and settings/validation support. Some menus are views over shared data rather than independent data stores.
- **INFERENCE:** the current Runtime selection is not a universal editor data context. Changing the selected Runtime will not, by itself, redirect most editor reads and writes to that Runtime.

## 3. Target Interaction Contract

### 3.1 Shared Runtime context

- Provide one authoritative selected Runtime ID/path, persisted in the existing user settings unless implementation investigation identifies a concrete blocker.
- Show the active Runtime name and path/status in a consistent top-level location.
- Changing Runtime emits one shared selection-change event. Open editors refresh their Runtime-side view and status from the new context.
- If the Runtime is missing, invalid, disabled, or its data cannot be read, show an explicit unavailable/error state. Never silently fall back to another Runtime.
- Every write/copy/publish confirmation names the target Runtime and destination path.

### 3.2 Source versus Runtime data

- **Source pane:** Content Editor's editable authoring source and its source path.
- **Runtime pane:** selected Runtime's current data/file state, read-only for the initial implementation.
- **Actions:** Compare, Preview Copy/Publish, then explicit Confirm. Show created/updated/skipped/failed records and files.
- A Runtime-side edit mode is not included by implication. Directly editing live Runtime files would require a separate ownership, backup, and rollback decision.
- Runtime A and Runtime B must have independent destinations. Copying to A must not mutate B.
- Save to authoring source, copy/publish to Runtime, and activate/select package are separate operations with separate status reporting.

### 3.3 Data-type rules

- **Map:** compare authoring JSON to the selected Runtime's map files and applicable DB records. Copy the JSON map file and required references/assets as a single validated operation; verify map ID, file identity, references, hashes, and destination result. Do not copy only the database row.
- **Robot / Unit / Tower / Building / Faction / Skill / Mission / Campaign / Stage:** show source record(s) against the corresponding selected Runtime database content; copy/publish only after table/field mapping and reference closure are validated.
- **VFX / SFX / Voice / BGM:** compare definitions and referenced assets. Ensure referenced files and import metadata are present in the destination package.
- **Asset Catalog / Image Editor:** distinguish authoring catalog metadata from actual files. Asset ownership/path migration is not assumed; use the existing package reference validation and stop on unresolved dependencies.
- **Settings, validators, and utility views:** classify whether each is Runtime-content-bearing, authoring-only, or a shared utility. Do not fabricate Runtime panes for authoring-only settings; display a clear reason and applicable validation instead.

### 3.4 Layout

- Standard data editors: shared Runtime selector/status; source content/search/list on the left; selected Runtime content/list/details on the right, with compare/copy status visible.
- **Robot, Unit, Tower:** source and Runtime comparison is vertically stacked (top/bottom), not left/right, as requested by Master. Preserve sufficient room for preview and long forms; test scrolling at baseline and narrower windows.
- **Map:** retain its specialized map canvas/toolbox workflow; add Runtime map selection, file state, and copy/validation controls without forcing the canvas into a generic two-column form.
- Specialized editors such as Image/Asset Catalog may retain their existing workspace if the shared Runtime context and applicable source/Runtime state remain accessible.

## 4. Phased Work Plan

### Phase 0 — Read-only inventory and data-flow map
1. Enumerate every editor/menu and classify it as DB-backed, JSON/file-backed, asset-backed, mixed, or utility-only.
2. Trace each editor's actual load/save source, tables/files, validation, referenced assets, and shared repository/persistence helpers.
3. Trace Runtime registry path validation, DB schema compatibility, map file layout, asset roots, publisher filters, and current compare behavior.
4. Record per-editor source/destination paths and missing adapter/contract requirements.
5. Do not modify source, databases, Runtime files, or assets.

**Exit:** all menus classified; every content-bearing editor has a verified source path and a proposed Runtime mapping; unresolved mappings explicitly marked UNVERIFIED.

### Phase 1 — Shared Runtime context and read-only inspection
1. Implement a single Runtime context service/API and selection-changed signal.
2. Add consistent Runtime name/path/health display to the main shell and editor context.
3. Adapt each content-bearing editor to read the selected Runtime's corresponding data without writing it.
4. Add missing table/file comparison coverage and explicit unsupported/unavailable states.

**Exit:** switching Runtime changes every applicable Runtime-side view; source data and Runtime data remain unchanged; no silent fallback.

### Phase 2 — Copy/publish preview and transaction contract
1. Define one preview/report schema for record and file operations.
2. Include target path, before/after hashes, row/file counts, references, conflicts, and failure reasons.
3. Validate dependency closure and destination compatibility before writes.
4. Require explicit confirmation; use backup/staging/rollback or create-new-package behavior appropriate to the destination.
5. Prevent copy to an ambiguous, invalid, or currently running destination unless the operation is explicitly safe.

**Exit:** preview is read-only; cancellation causes no writes; failures do not leave a partially accepted destination.

### Phase 3 — Implement data adapters by family
1. Maps and related references/files.
2. DB-backed gameplay content: Robot, Unit, Tower, Building, Faction, Skill, Mission, Campaign, Stage.
3. Audio/VFX definitions and referenced assets.
4. Asset Catalog/Image Editor dependencies.
5. Remaining menus and utility/authoring-only classification.

Implement one family at a time, with per-family tests and diff review. Do not automatically activate packages or overwrite Runtime source databases.

### Phase 4 — UI layout
1. Shared source-left / Runtime-right layout for standard editors.
2. Robot, Unit, Tower top/bottom split.
3. Map specialized workspace integration.
4. Specialized editor exceptions documented with rationale.
5. Verify baseline and narrow window sizes; no clipped essential controls.

### Phase 5 — Verification and Master acceptance
- Unit/smoke tests for context switching, adapter mapping, preview, cancellation, failure rollback, and Runtime isolation.
- Verify that Runtime A operations leave Runtime B unchanged.
- Verify map JSON and dependencies, DB integrity, package manifest/hashes, and unresolved references.
- Confirm authoring source and Runtime source DB hashes are unchanged by read-only preview.
- **CODE VERIFIED / BUILD VERIFIED / EDITOR VERIFIED** recorded separately.
- GUI visual acceptance and **PIE VERIFIED** remain Master-owned; automated tests do not substitute for Master runtime acceptance.

## 5. Safety and Constraints

- Preserve existing working-tree changes; no reset, restore, database replacement, or cleanup of unrelated screenshots/assets.
- Start each implementation phase by recording HEAD, branch, working tree, and affected-file diffs.
- Keep investigation READ-ONLY by default; review diff after each implementation family.
- Do not modify Runtime source DB/assets as a side effect of authoring Save.
- Do not overwrite an existing package; use a new destination or a separately approved safe update protocol.
- No commit/push without explicit approval.
- Stop and report if schema mapping, file ownership, destination behavior, or rollback cannot be established.

## 6. Acceptance Criteria

- Every content-bearing editor responds to Runtime selection using the same shared context.
- Each editor displays the correct selected Runtime's corresponding data or a clear unsupported/unavailable state.
- Copy/publish explicitly targets one Runtime and cannot silently affect another.
- Maps copy the JSON file and validate related data/assets.
- Robot, Unit, Tower use top/bottom source-versus-Runtime layout.
- All other standard editors use source-left / Runtime-right comparison where appropriate.
- Runtime/source boundaries, rollback, hashes, and verification status are reported.
- Master has reviewed the actual GUI and Runtime behavior before acceptance.

## 7. Current Decision Gate

**STATUS: HOLD — planning baseline established; implementation must not begin until Phase 0 inventory is complete.**

The core unresolved design choice is whether Runtime-side panes are strictly read-only and all changes flow through authoring Save + explicit copy/publish, or whether some editors should support direct per-Runtime edits. This plan recommends **read-only Runtime panes with authoring-source edits and explicit per-Runtime copy/publish**, because it preserves ownership boundaries and prevents accidental cross-Runtime mutation.

**PROPOSAL:** approve the read-only Runtime-pane model, then continue with the complete Phase 0 data-flow inventory. No code implementation, package activation, commit, or push is performed by this document.
