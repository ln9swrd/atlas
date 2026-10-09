# MENOS Runtime Supplementation Plan

- Status: PROPOSAL — planning only; implementation not authorized by this document
- Date: 2026-10-09
- Project owner: MENOS Runtime (`godot/`)
- Integration references: root `docs/CONTENT_EDITOR_RUNTIME_SEPARATION_PLAN.md`, root `docs/MENOS_MASTER_REFERENCE.md`, root `state/CURRENT_STATE.md`
- Baseline HEAD: `a5aadb04e759ca3cb11029e88720055d735bb1ae`
- Branch: `main`
- Runtime visual / PIE acceptance: reserved for Master

## 1. Purpose

Bring the existing Runtime to the minimum state needed to consume a validated, published content package while preserving the existing gameplay implementation. This is a supplementation plan, not a Runtime rewrite and not a Production approval.

## 2. Canon and scope constraints

- Content Editor and Runtime own and manage their code and project-specific documentation separately.
- Content Editor and Runtime use separate databases.
- The approved short-term content design is one independent JSON authoring source per map and a published Runtime package consisting of filtered SQLite, a manifest, and referenced Assets.
- Supported game modes for this short-term scope are Campaign and Single Play only.
- Runtime owns the title/main screen and gameplay screens and behavior. The Content Editor does not own or execute Runtime screens.
- Keep existing IDs, stage/campaign links, gameplay rules, assets, and current user changes unless a separately approved change requires otherwise.
- No multiplayer implementation is in scope. Existing multiplayer fields must not be silently reinterpreted or bulk-deleted; compatibility handling requires an explicit contract.
- No Commit/Push, destructive cleanup, mass migration, broad refactor, or unrelated editor changes.
- Master will perform the final visual and PIE checks. Automated smoke tests are not PIE acceptance.

## 3. Current evidence

### CONFIRMED

- Runtime entry point is `godot/project.godot` with `res://ui/title_screen.tscn` as the main scene.
- Runtime has existing gameplay, campaign/stage/map, entity catalog, audio, VFX, and voice-related code.
- The Runtime test directory contains 39 GDScript test files. File presence alone does not prove current pass status.
- Runtime repositories currently refer to `res://content/menos.sqlite`; Content Editor repositories refer to `res://data/menos.sqlite`.
- The current map loader stores fixed map documents in SQLite tables and dynamic map documents in the `map_documents` SQLite table. It does not yet implement the approved per-map JSON authoring source contract.
- The current map loader has explicit fixed/legacy path-to-SQLite-table mappings.
- The Content Editor runtime manifest exists but its `assets` list is currently empty.
- A complete, verified publish-to-runtime-package-to-load flow has not been established.
- Existing working tree changes include 13 pre-existing Runtime project/import files plus three root integration documents. They must be preserved.

### UNVERIFIED

- Current headless test pass rate and complete Runtime build status.
- Complete dependency closure for all supported gameplay paths.
- Exact set of Runtime tables and Assets required in a filtered publish package.
- Whether any current Runtime flow depends on multiplayer-only fields.
- Runtime load behavior from a generated package and its manifest.
- Current visual state, menu usability, save/reload behavior, and full Campaign/Single Play PIE acceptance.

## 4. Target acceptance boundary

The Runtime supplementation is ready for Master review when:
1. The existing Runtime remains the game entry point and retains current Campaign and Single Play behavior.
2. Runtime reads a validated published package through an explicit package boundary, without opening or mutating the Content Editor authoring database.
3. Map source JSON is converted into the agreed published SQLite representation without changing existing IDs or gameplay meaning.
4. The manifest and package validation detect missing required data, duplicate/invalid identifiers, unsupported versions, and unresolved required Asset references before gameplay starts.
5. Supported Campaign and Single Play map/stage resolution is covered by focused automated tests.
6. A clean, reproducible Runtime build succeeds.
7. The remaining visual and PIE checks are clearly listed for Master; automated results are not labelled PIE VERIFIED.

## 5. Minimum work sequence

### R0 — Baseline and test-safety audit (READ-ONLY)

- Record HEAD, branch, working tree, and existing modified files.
- Inventory existing Runtime test scripts and identify which ones write to the source DB, generate files, or alter project state.
- Map the entry flow from title screen to Campaign/Single Play, stage selection, map loading, and core gameplay initialization.
- Run no potentially mutating tests until their isolation and cleanup behavior are understood.

Exit: a safe, minimal test subset and the exact Runtime critical path are identified.

### R1 — Runtime content contract and compatibility matrix

- Define the Runtime package boundary: package version, schema version, database location, manifest format, package-relative Asset paths, and read-only guarantees.
- Map current SQLite tables and identifiers to the Runtime dependencies of Campaign and Single Play.
- Define the map JSON schema and stable map ID rules; map existing fixed/dynamic map representations to that schema.
- Define how campaign/stage references resolve map IDs.
- Specify compatibility behavior for legacy map table aliases and existing multiplayer fields; do not silently remove data.
- Keep save-game/profile/user state separate from the published content package.

Exit: the package and map contracts are internally consistent and can be reviewed without code changes.

### R2 — Smallest Runtime package-loading boundary

- Add or adapt only the narrow Runtime loading boundary needed to select a published package.
- Keep the existing default content path working during transition unless a separate migration is approved.
- Ensure the Runtime package is opened read-only; profile/save data remains on its separate persistence path.
- Fail clearly on missing package, incompatible versions, missing required IDs, or unresolved required Assets.
- Avoid broad repository rewrites or changes to gameplay rules.

Exit: a focused test can load a fixture package while proving the authoring DB was not written.

### R3 — Map JSON to published SQLite compatibility

- Implement transformation in the publisher side only after the schema contract is approved.
- Preserve map IDs, stage/campaign links, object IDs, and required Asset references.
- Include only map content reachable by the selected package scope.
- Validate both fixed-map compatibility and dynamic-map behavior using isolated fixtures.
- Keep authoring JSON and publish output separate; never generate the package in-place over the authoring source.

Exit: a representative map can be authored, validated, published, and resolved by Runtime using the same stable ID.

### R4 — Campaign / Single Play regression gate

- Cover title-screen mode selection, stage/map resolution, gameplay startup, victory/defeat state transitions, and required content/Asset lookup.
- Use a small set of safe automated tests first; do not treat test completion as visual acceptance.
- Verify no test or package-generation path changes the authoring DB or unrelated working-tree files.
- Keep multiplayer outside the supported acceptance matrix.

Exit: focused tests pass and the regression report distinguishes CODE, BUILD, and PIE states.

### R5 — Build and Master handoff

- Produce a clean Runtime build using the agreed package fixture.
- Record exact commands, outputs, and failures.
- Provide Master a concise visual/PIE checklist for Campaign and Single Play.
- Stop after the evidence is reported. Do not automatically enter Production rollout or implement follow-up features.

Exit: BUILD VERIFIED if the build succeeds; PIE remains NOT VERIFIED until Master checks it.

## 6. Required change controls

- R0 and R1 are READ-ONLY.
- R2–R4 require implementation approval after the contract is reviewed.
- Any schema migration, authoring data migration, bulk Asset copy, change to gameplay rules, or deletion requires separate approval.
- Before every write phase, re-check HEAD, branch, working tree, and targeted files.
- After any approved edit, inspect the full diff and run `git diff --check`.
- Preserve all unrelated pre-existing modifications. No Commit/Push without explicit authorization.

## 7. R0/R1 READ-ONLY audit findings (2026-10-09)

### CONFIRMED

- Baseline remained HEAD `a5aadb04e759ca3cb11029e88720055d735bb1ae`, branch `main`.
- Existing unrelated worktree changes remain present: 13 Runtime project/import files and three root integration documents, plus this new plan. No existing changes were reverted.
- Runtime entry point is `res://ui/title_screen.tscn`. The title-screen script branches between Campaign and Single Play and calls StageLoader/MapLoader before opening the gameplay scene.
- `godot/editor/` contains 28 GDScript files and 17 scenes. No direct references to `res://editor/` were found in the searched Runtime UI/scenes/scripts, but it remains inside the same Godot project and shares its project resources.
- Runtime-side authoring-capable code exists: `godot/scripts/map_loader.gd` includes create/update/delete map paths; `godot/scripts/object_persistence.gd` writes to the Runtime project's SQLite path; multiple definition repositories call ObjectPersistence save methods.
- Most read-only catalog access uses `res://content/menos.sqlite`, but Runtime-project authoring/persistence code opens that same DB writable. Thus “Runtime DB is read-only” is not true for every code path in the `godot/` project.
- `godot/tests/` contains tests that explicitly create/copy/delete SQLite fixtures and profile files. At least `catalog_save_rollback_smoke_test.gd`, `editor_data_smoke_test.gd`, `gameplay_p1_regression_smoke_test.gd`, and `sfx_pilot_registration_smoke_test.gd` have write/cleanup behavior. These must not be run blindly against project data.
- Runtime test file presence does not prove the current tests pass. No tests or build were run during this audit.
- The Runtime project has one visible map JSON under `godot/map_data/northbridge_sector_01.json`; Runtime MapLoader still primarily reads map data from SQLite and has legacy table/path mappings.
- A PowerShell quoting issue prevented the read-only SQLite schema-inspection command from completing. Table-level dependency coverage is therefore still UNVERIFIED; no database was changed.

### HIGH CONFIDENCE / INFERENCE

- The Runtime project currently mixes game-runtime responsibilities with a substantial embedded content-authoring/editor implementation and write-capable repositories.
- This structure is in tension with the approved Canon that Content Editor and Runtime independently own/manage their code, docs, and databases. The embedded editor may be legacy or intentionally retained, but its status has not been confirmed.
- Simply changing the Runtime loader to read-only will not establish the Canon while write-capable authoring repositories remain reachable in the same project. Conversely, deleting or relocating those paths now could break existing tools/tests and would exceed the current read-only phase.

### UNVERIFIED

- Whether `godot/editor/` is still actively used, a legacy implementation, or an intentional temporary bridge.
- The complete table/Asset dependency closure needed by Campaign and Single Play.
- The complete safe subset of tests that can run without altering existing project state.
- End-to-end publishing and Runtime package loading.

## 8. Approved transition: Option A ? isolate in place temporarily

Master approved the minimum transition boundary on 2026-10-09. The embedded `godot/editor/` source remains in the repository for now; no migration or deletion is authorized by this approval.

### Implemented

- `godot/export_presets.cfg`: added `editor/*` to the Windows Desktop export exclusion filter while retaining `content/menos.sqlite` as an explicit included resource.
- `godot/scripts/object_persistence.gd`: database write opens are denied outside the editor. The explicit debug-only test DB override remains available for isolated tests.
- `godot/scripts/map_loader.gd`: map save/create/delete and direct SQLite write paths are denied outside the editor. An explicit debug-only SQLite path override remains available for isolated tests.
- `godot/scripts/building_repository.gd`: write opens are denied outside the editor; schema checks use read-only access outside the editor.
- `godot/scripts/vfx_definition_repository.gd`: schema initialization is replaced by read-only existence checks outside the editor; write opens are denied outside the editor.
- Player profile and settings paths remain under `user://`; no migration was performed.

### Verification

- **CODE VERIFIED:** Godot 4.7.2 headless editor import/parse completed with no script/compile errors after the changes.
- **BUILD VERIFIED:** Windows Desktop release export completed. The export log included `res://content/menos.sqlite` and contained zero `res://editor/` resources.
- **TEST VERIFIED:** `catalog_save_rollback_smoke_test.gd` reported `CATALOG_SAVE_ROLLBACK_PASS`; `editor_data_smoke_test.gd` reported `EDITOR_DATA_SMOKE_TEST_PASS`.
- **PIE VERIFIED:** NOT VERIFIED. The exported game was not launched. Master retains final visual/Runtime verification.
- The export log still showed resources under `res://tests/`. Excluding tests from shipping is not part of this approved change and remains OUT OF SCOPE.
- No database contents were intentionally changed; no project assets were moved or deleted. No commit/push was performed.

### Remaining boundary limits

- This is a transition safeguard, not full source ownership separation. The legacy `godot/editor/` implementation remains in source and can operate when the project is run in the editor.
- The write guards were source-checked and the project was exported, but an exported Runtime attempt to mutate the content DB was not executed. That behavior remains UNVERIFIED until a non-PIE isolated check is approved or performed safely.
- End-to-end publish/package generation, package manifest validation, and the final Campaign/Single Play runtime check remain pending. No implementation of the Publisher was included.

**STATUS:** PASS for the approved source/export boundary; HOLD for end-to-end publish and Master Runtime validation.

**Marie's proposal:** stop here. Before any broader change, Master should decide whether to authorize a separate follow-up for (1) an isolated exported-build write-denial check and (2) excluding test resources from the shipping export. Do not move or delete `godot/editor/` without a separate decision.


## 9. Approved follow-up: external Runtime content package root (2026-10-10)

**STATUS: PASS for selected-directory package loading in headless tests; HOLD for exported-build and Master PIE acceptance.** Master selected Option A: Runtime consumes a selected package from a separate package root.

### Implemented
- Added `godot/scripts/runtime_content_package.gd` as a package-selection/validation helper. The selection file is `user://runtime_content_package.json` with an absolute `package_root` pointing to a directory containing `manifest.json`, `content/menos.sqlite`, and package assets.
- If the config is absent, Runtime continues using its built-in database and resources. If the config exists but the package is invalid, the package is rejected and loaders do not silently fall back to the built-in DB.
- Package validation checks format version, expected database path, database SHA-256, and each manifest asset's existence, size and SHA-256.
- `ContentCatalogLoader` and `MapLoader` use the same selected package DB.
- Runtime BGM/SFX/Voice adapters and the dynamic texture loads in `game_controller.gd` route supported external package resources through the helper. Supported external formats: PNG/JPG/JPEG/WebP/BMP/TGA, OGG/WAV/MP3. The Publisher projects the title-screen settings subset into `runtime_settings` so Runtime does not require the excluded Content Editor `editor` table.
- Added `godot/docs/runtime_content_package_selection.md`, `godot/tests/runtime_content_package_smoke_test.gd`, and `godot/tests/runtime_content_package_config_test.gd`.

### Verification
- Godot 4.7.2 headless editor scan/import and script class registration: **PASS**.
- Publisher Python integration test: **PASS**.
- Runtime package smoke: **PASS** for manifest/hash validation, package DB path, map aliases, canonical map ID, robot catalog, external PNG texture, external OGG stream and external WAV stream.
- Config integration test: **PASS** for `user://runtime_content_package.json` selecting the external root and directing both MapLoader and ContentCatalogLoader to the selected DB. The test restored/removed its temporary config; no user package config remains.
- Generated package and temporary artifacts were removed after successful tests. Runtime source DB and authoring DB were not intentionally modified. A Windows Release export and headless execution with the selected package returned exit code 0 and logged zero `ERROR`, script or SQL errors. No GUI/PIE, deployment, commit or push.

### Limitations
- This is directory-based content DB + image/audio override support. It does not package/replace static scenes, scripts, shaders/materials, or every hard-coded Runtime dependency.
- The selected package is a read-only content source. No package picker UI, update/rollback flow, automatic copying, or replacement of `godot/content/menos.sqlite` was added.
- Windows Release export and headless startup with a selected external package are **BUILD VERIFIED / HEADLESS RUNTIME VERIFIED**. Master visual/PIE acceptance remains **NOT VERIFIED**.

**Judgment: ACCEPT?STOP for the selected external package-root PoC.** Next decision gate: whether to authorize a Windows Release export check of the package selector and its read-only failure behavior, or defer exported-build validation until Master performs the planned Runtime acceptance.


## 10. Approved project boundary cleanup ? embedded editor removed (2026-10-10)

**STATUS: PASS for source ownership cleanup and targeted tests; HOLD for full migrated editor test-suite acceptance.** Master approved removing the duplicate Content Editor implementation from the Runtime project and making the Publisher's Runtime source path explicit.

### Changes
- Removed the clean legacy `godot/editor/` tree (editor UI, editor scripts, validators and local helpers). The Runtime entry scene remains `res://ui/title_screen.tscn`; Runtime gameplay code and Runtime-owned scripts are unchanged by this deletion.
- Moved 16 tests that directly exercised `res://editor/*` out of `godot/tests/` into `content_editor/tests/`, preserving their contents and `.uid` files. These tests are now owned by the standalone Content Editor project. Their full suite is not yet accepted as passing; run only after checking for destructive test behavior.
- `content_editor/tools/publish_runtime_package.py` now requires an explicit `--runtime-root`. It no longer assumes that a sibling `godot/` directory exists. The path is used only as the source of referenced `res://` data Assets for package generation.
- Updated Publisher usage docs to show the explicit path. No database migration, Asset relocation, or cross-project source synchronization was added.

### Boundaries
- `godot/project.godot` continues to launch only `res://ui/title_screen.tscn` and has no Content Editor autoload or startup reference.
- `content_editor/project.godot` continues to launch only `res://editor/content_editor.tscn`; it does not launch or load Runtime scenes. The Publisher is an explicit, one-way data/Asset packaging tool and is not part of the Content Editor startup graph.
- Content Editor image preview and editing remain inside `content_editor/`; its `res://editor/image_editor_state.gd` is a local helper, not a dependency on `godot/editor/`.
- The read-only Runtime asset manifest remains a Content Editor-owned input document. Runtime data paths are consumed only when the user explicitly runs the Publisher with `--runtime-root`.

### Verification status
- Baseline before change: HEAD `a5aadb04e759ca3cb11029e88720055d735bb1ae`, branch `main`. No pre-existing changes existed under `godot/editor/`; the removal therefore did not discard local edits.
- Publisher CLI `--help`: PASS; `--runtime-root` is required. Omitting it returns an argparse error.
- Publisher Python integration test with explicit `MENOS_RUNTIME_ROOT`: PASS.
- Content Editor `map_authoring_contract_test.gd`: PASS.
- Windows Desktop Release export: PASS (exit code 0, executable produced). Export log had zero `res://editor/` resources and no script/parse/load errors.
- Exported Runtime headless startup: PASS (exit code 0, no script/parse/load errors).
- Both authoring and Runtime SQLite hashes remained `B681FFF79513E9E0C65481A1ABE750937CAA77970BF1FDB85422CD451449E2A8`.
- Runtime source/tests contain no `res://editor/` or `editor_ui.*` references. Content Editor operational code/tests no longer infer a sibling Runtime directory.
- `git diff --check`: PASS after final review.
- Full migrated Content Editor smoke-test set and Master PIE/visual acceptance: NOT VERIFIED. The moved legacy suite was not run wholesale because some tests may write fixtures or project data.
- No Commit/Push; no GUI/PIE.

**Judgment: ACCEPT?STOP for the approved project boundary cleanup.** Do not automatically repair or expand legacy smoke tests that prove destructive or unrelated behavior.
