
# Runtime-Aware Content Editor — Phase 0 Store and Dependency Inventory

**Status:** Phase 0 inventory plus approved Runtime identity/config-isolation slice implemented; broad Runtime-aware editor UI remains unimplemented.
**Decision basis:** Master approved the proposal that Runtime-side panes are read-only, authoring remains the editing source, and per-Runtime copy/publish is explicit. Direct Runtime editing remains out of scope.

## 1. Confirmed common storage architecture

- **CONFIRMED:** `scripts/content_catalog_loader.gd` reads `res://data/content_editor.sqlite` with SQLite opened read-only. Its table resolution maps content paths/tables to SQLite tables; it also resolves ODB primary keys through `odb_registry`.
- **CONFIRMED:** `scripts/object_persistence.gd` writes to the same authoring SQLite DB using transactions. Catalog saves can insert/update/delete rows; document saves require exactly one document row. It includes atomic paired document/catalog writes.
- **CONFIRMED:** `scripts/object_repository.gd` caches Robots, Allied Units, Enemies, and Towers from the authoring loader. It is not Runtime-aware and must be invalidated when its backing context changes.
- **CONFIRMED:** specialized definition repositories for VFX/BGM/SFX/Voice and visual assets cache their definitions independently. At least some use the same fixed authoring DB path or a loader that reads the authoring database.
- **INFERENCE:** changing a selected Runtime ID alone cannot redirect these repositories; a shared Runtime read adapter or per-editor adapter is required. Runtime switching must also invalidate caches and refresh any currently open editor without discarding dirty authoring changes.

## 2. Content family mapping

| Editor / family | Confirmed authoring source | Runtime/package dependency | Runtime-aware read adapter | Copy/publish boundary |
|---|---|---|---|---|
| Map | Per-map JSON in `data/maps/`; map identity/legacy rows also exist in SQLite | Runtime map records/files and referenced object/visual assets | Runtime map-document reader plus file-presence/hash state | Copy JSON and required related records/assets as a validated unit; JSON-only copy is insufficient |
| Stage | SQLite document/catalog tables via ContentCatalogLoader/ObjectPersistence; stage data references map, mission/reward and encounter content | Runtime stage records and target map availability | Runtime DB stage reader and cross-reference resolver | Validate stage IDs, referenced map identity/file, mission/reward/enemy/allied-unit references |
| Campaign | SQLite `campaign` document; references stages and missions | Runtime campaign record and referenced stages/missions | Runtime DB campaign reader | Validate full stage/missions closure before copy |
| Mission | SQLite `missions` catalog | Runtime mission records; Stage/Campaign links | Runtime DB mission reader | Copy records with reference checks; avoid silent ID collisions |
| Reward / Items | SQLite `rewards` / `items` catalogs; editing is partly embedded in Stage or other views | Runtime reward/item records | Runtime DB reader | Must include nested/reference data consistently; editor ownership and standalone UI classification need follow-up |
| Faction | SQLite `factions` catalog; references robots and BGM definitions | Runtime faction records plus referenced Robot/BGM content | Runtime DB reader | Validate references and package inclusion settings |
| Robot | SQLite `robots` catalog via ObjectRepository; asset paths in records | Runtime robot records and referenced sprite/animation files | Runtime DB reader and asset-path resolver | Copy definition plus all required referenced assets |
| Unit / Enemy | SQLite `allied_units` / `enemies` catalogs via ObjectRepository | Runtime unit/enemy records and assets; stage encounters reference IDs | Runtime DB reader and asset-path resolver | Copy definition plus asset dependencies and validate stage references |
| Tower | SQLite `towers` catalog via ObjectRepository | Runtime tower records and referenced visual/projectile assets | Runtime DB reader and asset-path resolver | Copy definition plus assets and validate all referenced paths |
| Building | SQLite-backed content catalog is used by its editor; exact write calls and asset dependencies need a focused follow-up | Runtime building records and referenced visuals | Runtime DB reader | Table/field mapping and asset closure remain to be confirmed |
| Skill | SQLite `skills` catalog | Runtime skill records; other content may reference skills | Runtime DB reader | Validate dependent IDs and referenced assets |
| VFX | SQLite `vfx_definitions` catalog via VFXDefinitionRepository/ObjectPersistence | Runtime VFX definition and sprite/texture assets | Runtime DB reader plus asset status | Copy definition and referenced assets; reject missing dependencies |
| SFX | SQLite `sfx_definitions` catalog via SFXDefinitionRepository/ObjectPersistence | Runtime sound definitions and audio files | Runtime DB reader plus asset status | Copy definition and audio file closure |
| BGM | SQLite `bgm_definitions` catalog via BGMDefinitionRepository/ObjectPersistence | Runtime music definitions and audio files | Runtime DB reader plus asset status | Copy definition and audio file closure; faction/context uniqueness rules must be validated |
| Voice | SQLite `voice_definitions` catalog via VoiceDefinitionRepository/ObjectPersistence | Runtime voice definitions and audio files | Runtime DB reader plus asset status | Copy definition and audio file closure |
| Asset Catalog / Image | SQLite `asset_catalog` and `visual_assets`; image editor can also write files under editor edited-assets roots | Runtime references and actual images; .import sidecars may be relevant | Runtime catalog reader plus filesystem asset resolver | Copy metadata and referenced files together; validate paths, hashes and visual-asset references |
| Settings | Mixed: Content Editor UI preferences in `user://`; some gameplay/runtime settings stored as content documents/tables | Only runtime-owned distributable subset belongs in package; user/save data must not be copied as content | Explicit allowlisted Runtime-settings reader | Must distinguish editor preferences, runtime content settings, and player/save data |
| Validation / Compare / Preview | Read paths across catalogs, map JSON, and SQLite; not a single independently owned content store | Needs selected Runtime context for target-side validation | Shared read-only target adapter | Must report unavailable/incompatible rather than falling back silently to authoring data |

**Important:** this is a first-pass classification, not a complete table/schema manifest. Building, Reward/Items, Settings, and exact editor-to-table mappings require further focused verification before any copy adapter is implemented.

## 3. Runtime target and package boundaries

- **CONFIRMED:** the registry tool maintains Runtime project path/enable state and per-Runtime publishable-table inclusion settings. Table settings control package inclusion; they are not a Runtime data browser or clone.
- **CONFIRMED:** publisher builds a new package directory and records hashes/manifest metadata; it does not overwrite Runtime source DB/assets.
- **CONFIRMED:** current package contains a filtered SQLite DB, manifest, copied referenced assets and map documents. Existing Runtime loaders are used in headless smoke checks, but that is not GUI/PIE acceptance.
- **CONFIRMED:** publisher coverage is a reviewed allowlist and the documented reference closure is not every hard-coded scene dependency. A successful package does not prove a full deployable Runtime.
- **INFERENCE:** a per-Runtime copy feature should initially target a generated isolated package for that Runtime, rather than writing directly into its live source DB/files. This is consistent with the approved read-only Runtime pane and minimizes mutation risk.

## 4. Required common interface

Proposed adapter responsibilities (not implemented):

1. `RuntimeContext`: selected target identity, validated project root, DB/map/assets paths, health and selection-changed signal.
2. `RuntimeContentReader`: read-only catalog/document/map queries; never writes to Runtime source DB.
3. `ContentComparisonService`: normalized ID/value comparison and dependency/reference diff.
4. `RuntimePackagePlan`: explicit inclusion list, dependency closure, conflict report, source/target hashes, output path preview.
5. `RuntimePackagePublisher`: reuse/extend existing publisher rather than duplicate its validation and output safeguards.
6. `EditorRuntimeAdapter`: maps each editor's authoring view to the corresponding Runtime family; handles Runtime change events, empty/error state, and unsaved authoring edits.

Switching Runtime must not auto-save or discard authoring edits. If an editor is dirty, the UI must retain the source draft and mark the Runtime comparison stale until the user explicitly refreshes or resolves the draft state.

## 5. Minimum acceptance matrix

- All content-bearing editors resolve the selected Runtime through the same context service.
- Runtime pane is strictly read-only; no code path writes to Runtime source DB/assets.
- Runtime change refreshes current lists/details and clears stale comparison state.
- Invalid path, missing DB/table/map/asset, or schema mismatch yields an explicit unavailable/error state; it never silently displays authoring data as Runtime data.
- Robot/Unit/Tower use top/bottom layout; other standard editors use authoring-left/Runtime-right; Map retains its canvas and adds Runtime map state/copy validation.
- Package preview enumerates records, dependencies, assets, conflicts, source/target hashes and intended output path before write.
- Two different Runtime targets remain isolated; publishing for target A does not change target B's selection or source data.
- Map copy includes the JSON document and required related DB rows/assets, with IDs and hashes verified.
- Package creation, Runtime selection configuration, Runtime load, and Master-confirmed gameplay acceptance are reported separately.

## 6. Remaining HOLD items

1. Complete the exact mapping of all content-bearing editors to tables/documents/files and identify embedded editor-only vs runtime-owned settings.
2. Confirm each Runtime's schema/table compatibility and package root conventions; current publisher only accepts the reviewed schema set.
3. Decide whether the first release supports only generated per-Runtime packages or needs a separate direct file-copy deployment operation. **Recommendation:** generated packages only for the first release.
4. After mapping is complete, produce a focused architecture proposal for RuntimeContext and adapters. No source implementation before that proposal is reviewed.

## 7. Current status

- **CONFIRMED:** common authoring loader/persistence paths, catalog caching pattern, selected Runtime registry, map JSON source, package publisher boundaries.
- **INFERENCE:** selected Runtime changes will not automatically affect every editor until a common context/adapters are implemented.
- **UNVERIFIED:** full schema compatibility across every registered Runtime, complete asset closure, all editor-to-table mappings, and actual GUI/Runtime acceptance.
- **Changes:** this document only. No source code, DB, assets, commits or pushes were changed by this inventory pass.

## 8. Follow-up review — reconcile with the existing MENOS Runtime package implementation (2026-10-10)

This follow-up is based on the existing MENOS separation plan, Runtime package selection contract, Runtime package publisher contract, and current Content Editor entry-point code. It refines the earlier Phase 0 recommendation; it does not authorize source implementation.

### 8.1 Important existing capability

- **CONFIRMED:** Runtime external-package selection already exists. Runtime can load a selected package from an external directory containing manifest.json, content/menos.sqlite, and listed assets; the selected package is treated as read-only.
- **CONFIRMED:** Content Editor already exposes a Runtime Data menu with Import Runtime Data, Publish Runtime Package, Run MENOS Runtime, and Manage Runtime Targets/Tables actions.
- **CONFIRMED:** the publisher already reads the authoring DB and map JSON, resolves referenced Runtime assets from an explicitly selected Runtime root, creates a filtered DB plus manifest and referenced files, verifies hashes, and refuses to overwrite an existing output directory.
- **CONFIRMED:** successful publication can be followed by writing the selected package path into the Runtime's user-data configuration through a helper. An already-running Runtime must be restarted. GUI/PIE acceptance remains Master-owned and is not implied by headless checks.
- **CONFIRMED:** the existing package selection contract fails closed for malformed/missing package selections instead of silently falling back to built-in data.
- **INFERENCE:** the immediate project is not to invent a new package format or a second publisher. It is to make the existing target/package infrastructure observable and usable from every relevant editor, while closing the data-inspection gap.

### 8.2 Corrected first-release implementation boundary

For the first release, prefer the existing package pipeline and avoid direct file-copy deployment:

1. Keep Content Editor DB and map JSON as the authoring source.
2. Use the registered Runtime project as the explicit target and source of referenced runtime assets.
3. Preview package inputs, reference closure, warnings, output path and target identity before publishing.
4. Publish only to a new package directory; never overwrite the Runtime source DB or source assets.
5. Configure the Runtime to select the package only after package validation succeeds.
6. Report package creation, selection-config success, Runtime restart/load and Master gameplay acceptance as separate statuses.

The existing implementation provides much of this pipeline, but the per-editor Runtime read-only browsing/comparison surface and a single shared selection-change event were not established by this review.

### 8.3 Remaining architecture task

Design a narrow RuntimeContext integration around the existing registry and publisher rather than replacing them. It should resolve/validate the selected target, expose DB/map/package health, emit selection changes, and cause active editor adapters to refresh. Runtime readers must remain read-only. Existing source-edit repositories must remain attached to the authoring DB.

Do not silently fall back to authoring data when the target is unavailable. The Runtime pane must show an explicit unavailable/schema-incompatible state. Switching targets must not save or discard dirty authoring edits.

### 8.4 Decision gate

No new package/deployment mode is needed for the first release based on current evidence. The remaining decision is whether the Runtime-side read-only view should be:

- **Option A (recommended):** a shared panel pattern integrated into each content-bearing editor, with family-specific rendering; or
- **Option B:** a central comparison window only, with editors merely refreshing/validating against the selected Runtime.

Option A directly meets the approved left-source/right-target requirement (and top/bottom for Robot/Unit/Tower) but requires more UI integration. Option B is lower-cost but does not fully satisfy the requested editor-by-editor split layout.

**PROPOSAL:** choose Option A as the target UI, implement the shared read-only panel component first, then integrate editor families incrementally. Keep Map's canvas layout specialized. Before implementation, complete a code-level inventory of current DB comparison mappings and the exact editor scenes that need the shared panel.
## 9. Database comparison and editor-scene inventory

- **CONFIRMED:** `dual_database_compare.gd` is a separate read-only comparison window, not a panel embedded in each editor.
- **CONFIRMED:** its current scene mapping has exactly eight entries: Mission/missions, Faction/factions, Building/buildings, Skill/skills, VFX/vfx_definitions, SFX/sfx_definitions, BGM/bgm_definitions, Voice/voice_definitions.
- **CONFIRMED:** Campaign, Stage, Map, Robot, Unit/Enemy, Tower, Asset Catalog/Image, and Settings are not mapped by this comparison window.
- **CONFIRMED:** the comparison window resolves the selected registry entry and reads `<runtime project root>/content/menos.sqlite` read-only. It displays full table rows as JSON and does not perform semantic field-by-field diff, reference closure analysis, or map-file comparison.
- **CONFIRMED:** the main Content Editor scene already has a Runtime toolbar and global Import/Publish/Run/Manage actions. Robot, Unit, and Tower are separate editor scenes; Map has a specialized canvas/toolbox layout.
- **INFERENCE:** current comparison is a useful proof of read-only dual-DB access, but it is not the requested all-editor Runtime-aware workflow. It also targets the Runtime project's built-in DB path, which may differ from the externally selected package actually consumed by Runtime.

### 9.1 New decision gate: what exactly does the Runtime pane represent?

The current architecture distinguishes at least two valid target views:

- **Runtime source view:** inspect `<runtime root>/content/menos.sqlite` and the Runtime project's source assets. This answers what is present in the project before packaging.
- **Active package view (recommended):** inspect the package directory currently configured in the Runtime's `user://runtime_content_package.json`, including its filtered DB, manifest, and packaged assets. This answers what the next Runtime launch is configured to consume. If the Runtime is currently running, the UI still cannot claim it has loaded the latest package without restart/load confirmation.

These views can differ. The existing package-selection config is stored in the Runtime process's Godot user-data context, and the current Runtime Target registry does not itself prove which package is configured or currently loaded. The UI should label the view explicitly and never imply a live-running Runtime state from configuration alone.

**PROPOSAL:** make the default Runtime pane show the active package configured for that selected Runtime, because the user's goal is to inspect the content delivered to Runtime. Provide a separate explicit “Runtime source DB” view only if needed. If the package config is absent or invalid, show that status rather than silently substituting the source DB. Runtime-loaded state remains UNVERIFIED until restart/load evidence is available.

### 9.2 Updated status

- Existing publisher/package-selection path: **CONFIRMED implemented; prior headless checks documented**.
- Existing Runtime DB comparison: **CODE VERIFIED for the eight mapped tables only**; broad per-editor coverage **NOT VERIFIED**.
- Active package path exposed to the editor: **UNVERIFIED**.
- Shared selection-change service and in-editor Runtime panels: **NOT IMPLEMENTED / NOT VERIFIED**.
- No source code or Runtime data changed in this follow-up. The inventory document was extended only.
## 10. Schema and package-view feasibility findings

- **CONFIRMED:** the authoring DB and current Runtime source DB have the same 31 user tables and column layouts at the time of read-only inspection. This is a snapshot comparison, not a guarantee that every registered Runtime target has the same schema.
- **CONFIRMED:** relevant DB table families include `robots`, `allied_units`, `enemies`, `towers`, `buildings`, `missions`, `campaign`, `stage_catalog`, `stage_01`–`stage_03`, `rewards`, `items`, `factions`, `skills`, `vfx_definitions`, `sfx_definitions`, `bgm_definitions`, `voice_definitions`, `asset_catalog`, `visual_assets`, and `gameplay`. Map content also uses fixed legacy tables and JSON documents.
- **CONFIRMED:** the current Runtime package manifest contains package format/schema versions, source metadata, DB path/hash, map metadata, Asset entries, supported play modes, and warnings. It does not expose a top-level `included_tables` field in the inspected package; the actual included DB tables must be read from the package DB or another authoritative manifest field.
- **CONFIRMED:** `RuntimeContentPackage` validates the selected package manifest, DB hash, and every listed Asset's existence/size/hash. Its DB path is `content/menos.sqlite`. In Runtime, package selection is cached until configuration reload/restart.
- **CONFIRMED:** the package-config helper writes `user://runtime_content_package.json` in the selected Runtime project's own Godot user-data context. The Content Editor cannot reliably infer that user-data path from the project root alone; it must query the helper/Runtime context or invoke a narrow read-only query helper.
- **CONFIRMED:** the current package contract externally resolves only explicitly manifested `content_asset` resources; other Godot resources remain bundled with the Runtime project. Therefore the Runtime pane must distinguish packaged content from built-in/static Runtime resources.
- **INFERENCE:** package-side inspection is technically feasible using a read-only manifest + SQLite reader without starting Runtime. However, discovering which package is configured requires a separate read-only query path, and proving that it has actually loaded requires Runtime-side evidence.

### 10.1 Implications for the shared Runtime panel

1. Resolve selected Runtime target from the registry; validate project root and Runtime DB/package configuration separately.
2. Read the active package root through an explicit query operation in that Runtime's user-data context. The query must not write configuration or launch a gameplay session.
3. If configuration is absent, report `BUILT-IN CONTENT CONFIGURED` rather than silently calling it a package. If malformed, report `INVALID PACKAGE CONFIG`. If valid, validate manifest/DB/assets read-only before exposing data.
4. Show a distinct `Runtime source DB` option for comparison, because package DB and source DB can diverge.
5. Display `Configured for next launch` separately from `Loaded by running Runtime`; the latter remains unknown unless Runtime provides a trustworthy runtime status signal.
6. Read DB content read-only; display unsupported/missing tables as explicit per-family states. For maps, compare both `map_documents`/legacy DB entries and packaged JSON/manifest metadata.
7. Keep package warnings visible (for example unsupported map play modes); a valid hash is integrity evidence, not semantic/gameplay correctness.

### 10.2 Scope and safety

No source code, Runtime configuration, SQLite database, or package was modified by this review. Only this inventory document was extended. Package directories were inspected read-only. No Commit or Push was performed.
## 11. Live configured package: read-only validation result (2026-10-10)

**CONFIRMED:** The actual MENOS user-data config exists at `%APPDATA%/Godot/app_userdata/MENOS/runtime_content_package.json` and points to `D:/Atlas/projects/menos/godot/content/runtime-package-20261009_182643`. This resolves the previously unknown configured package root for the local MENOS project.

Read-only validation of that configured package found:

- Config JSON parses and contains an absolute `package_root`.
- `manifest.json` and `content/menos.sqlite` both exist.
- Manifest format/schema versions are 1/1 and the manifest declares 62 Asset entries and 3 maps.
- Package DB SHA-256 matches the Manifest; SQLite `PRAGMA integrity_check` returns `ok`.
- All 62 referenced files exist.
- **31 of 62 manifest Asset entries fail the manifest size/hash check. All 31 failures are `.import` metadata sidecars; the other 31 entries (SVG/image/audio content) pass.** The observed sidecars are each 40 bytes larger than the manifest's recorded size.
- Manifest also contains a non-fatal `UNSUPPORTED_PLAY_MODE_IGNORED` warning for `northbridge_sector_01` (`multiplayer` metadata is not published).

**Important interpretation:** the package config is set to this directory, but this read-only check does not prove the running Runtime loaded it. More importantly, the current `RuntimeContentPackage` implementation validates every Manifest Asset's size/hash, including `.import` sidecars. Under that code path, the current package is expected to fail validation unless the mismatch is explained by a separate, unobserved behavior. Actual Runtime acceptance was not tested in this read-only pass.

**HOLD:** Do not overwrite or edit the existing package in place. Before any repair, inspect the publisher's handling of `.import` sidecars and determine whether the correct fix is to exclude mutable Godot import metadata from package integrity entries, preserve immutable sidecars, or regenerate a fresh package and select it. A fresh package plus config switch changes the Runtime's next-launch content and therefore requires explicit Master approval. No package/config/database/Asset was modified.
## 12. Root-cause confirmation for `.import` hash drift (2026-10-10)

**CONFIRMED:** `publish_runtime_package.py` explicitly copies each referenced asset's adjacent `.import` file and adds it to `manifest.assets` with role `godot_import_metadata`. The configured package is located under the Runtime project itself: `godot/content/runtime-package-20261009_182643/...`, so those copied files are inside the project's `res://` tree.

A byte-level comparison of the source sidecar and packaged sidecar confirms Godot path rewriting, not random corruption. For `assets/menos/maps/ground_basic_32.svg.import`, the source file records the source project import cache path and `source_file="res://assets/menos/maps/ground_basic_32.svg"`; the packaged sidecar instead records a different `.godot/imported/...` cache hash and `source_file="res://content/runtime-package-20261009_182643/assets/menos/maps/ground_basic_32.svg"`. The packaged sidecar is 40 bytes larger. This is consistent with Godot treating nested package assets as project resources and rewriting their import metadata.

**CONFIRMED:** `RuntimeContentPackage._ensure_loaded()` verifies size and SHA-256 for every Manifest asset entry, regardless of role, so rewritten `.import` entries invalidate package validation. The publisher itself validates files in its temporary output before `os.replace`; that check occurs before any later Godot project scan can rewrite the nested sidecars. Thus publisher-time verification does not protect against post-publication mutation from the editor/import pipeline.

**HIGH CONFIDENCE:** the `.import` sidecars are not required for the current runtime loading path of manifested content assets: `RuntimeContentPackage.load_resource()` loads images from raw files through `Image.load()` and audio through `AudioStream* .load_from_file()`. Non-content/static Godot resources remain bundled and use `ResourceLoader`. This should still be covered by a focused regression test before a code change is accepted.

### 12.1 Fix options (no implementation authorized or performed)

1. **Preferred minimal fix:** stop copying `.import` sidecars as external-package assets, and stop including them in `manifest.assets`. Keep raw content assets under integrity validation. Verify image/audio loading and package smoke tests using a newly generated package in an isolated output directory.
2. Alternative: store generated packages outside the Runtime project's `res://` tree to prevent Godot from scanning/rewriting the sidecars. This is a deployment convention change and does not remove the unnecessary sidecar coupling by itself.
3. Avoid: simply ignore hash/size mismatches for role `godot_import_metadata` while retaining sidecars. That weakens validation without demonstrating a runtime need for these files.

**HOLD:** No Publisher or Runtime code was changed. The currently configured package was not repaired, republished, reselected, or launched. Running a Godot test against this in-project package was deliberately avoided because Godot's import pipeline may itself rewrite the files under investigation. The local Godot executable was identified at `D:\Godot\Godot_v4.7.2-stable_win64.exe`; any future test should use a newly generated package outside the Runtime project's `res://` tree and inspect the working tree/package before and after.

**Next approval gate:** approve a narrowly scoped Publisher change that omits `.import` sidecars from generated package contents/manifest, plus a regression test proving that a fresh package's manifested content assets pass the Runtime package validator and that image/audio resources still load. Existing configured package and user-data config must remain untouched until a separate package-selection approval.
## 13. Follow-up check before implementation approval (2026-10-10)

An additional read-only check enumerated the current package's manifested content extensions: 16 PNG, 4 WAV, 8 OGG, 2 MP3, and 1 SVG, each paired with a `.import` entry by the current publisher.

**CONFIRMED:** `RuntimeContentPackage.load_resource()` directly loads PNG/JPG/WEBP/BMP/TGA via `Image.load()`, and WAV/OGG/MP3 via their raw-file loaders. The package smoke test already checks PNG, OGG, and WAV, but not MP3 or SVG.

**Important caveat:** SVG is currently manifested as a content asset, but `load_resource()` has no direct raw-SVG branch. It falls through to `ResourceLoader.exists(resource_path)` / `load(resource_path)`, which refers to the Runtime project's bundled `res://` namespace rather than the external package's raw SVG path. Therefore, excluding `.import` sidecars is strongly supported for the raster/audio formats, but the current SVG entry is a separate unresolved compatibility concern and must not be assumed fixed by the sidecar change.

Before the proposed publisher change is accepted, the regression check should at minimum cover PNG, WAV, OGG, and MP3; separately identify whether `ground_basic_32.svg` is actually consumed through the external package path or is only a bundled/static resource. If it must be externally package-loadable, SVG handling needs a narrow, explicit decision (for example, convert/consume the raw SVG through a supported runtime path, or classify it as a bundled resource rather than a package asset). Do not silently expand the change into a general SVG/importer redesign.

No implementation or package operation was performed during this follow-up. The existing configured package and config remain untouched.

## 14. Runtime-specific package config identity ? implementation result (2026-10-10)

**Scope approved by Master:** derive Runtime identity from normalized project path, separate package config per Runtime, and expose a read-only config query. No legacy-config migration, package activation, UI panel integration, commit, or push.

- **CONFIRMED / CODE VERIFIED:** `projects/menos/godot/scripts/runtime_package_identity.gd` normalizes slash direction and redundant path segments; on Windows it also folds path casing, then computes SHA-256 over UTF-8 path text.
- **CONFIRMED / CODE VERIFIED:** Runtime package reads and config CLI writes now use `user://runtime_content_package_<sha256>.json`; the legacy `user://runtime_content_package.json` is not used as a fallback and is not migrated or deleted.
- **CONFIRMED / CODE VERIFIED:** `runtime_package_config_cli.gd --show-config` prints JSON describing Runtime identity, absolute config path, and whether a package is configured. Its read path only opens an existing config for reading; it does not create or write config. The response label `PACKAGE_CONFIGURED_FOR_NEXT_LAUNCH` does not claim package validity or a currently running Runtime's loaded state.
- **CONFIRMED / TEST VERIFIED:** `runtime_package_identity_test.gd` passes checks for SHA-256 length, slash normalization, distinct path isolation, Windows case normalization, and identity-bearing config filename.
- **CONFIRMED / MANUAL READ-ONLY CHECK:** running `--show-config` against `E:/atlas/projects/menos/godot` returned identity `02f4584dfb9d159a0088bcf076f46eef229e9c15a616c1b6ba11acb89a147e38`, config path under `app_userdata/MENOS`, and `BUILT_IN_CONTENT_CONFIGURED`. No per-Runtime config file was created by that query.
- **UNVERIFIED:** the write path was not exercised end-to-end with a valid package because no existing package directory was available on the active `E:` or `D:` project paths. The existing full package config smoke test therefore was not run. Package integrity and actual Runtime loading were not evaluated in this slice.
- **Compatibility note:** changing the project root changes the identity/config filename by design; the prior identity is not automatically linked. A Runtime path change requires re-query/revalidation.
- **Preserved pre-existing changes:** `runtime_content_package.gd` already contained the external SVG-loading change, and `runtime_content_package_smoke_test.gd` already contained the matching SVG assertion. Those changes were not reverted or rewritten as part of this identity task.

**Next decision gate:** determine whether this identity/config-query foundation is sufficient to proceed to the read-only Runtime status adapter consumed by Content Editor, or whether Master wants the config writer tested with a generated package fixture first.


## 15. READ-ONLY RuntimeContext status adapter ? implementation result (2026-10-10)

**Approved scope:** query the selected Runtime's per-project package configuration without mutating registry/configuration; distinguish config and package validation states. This is a data adapter only; no UI panel integration or package activation.

- **CONFIRMED / CODE VERIFIED:** `projects/content_editor/tools/runtime_config_status.py` is a standalone read-only adapter. It does not import or invoke `manage_runtime_registry.py`, and it opens no SQLite database. The caller supplies the registered Runtime path and the matching Godot `app_userdata/<project-name>` directory.
- **CONFIRMED / CODE VERIFIED:** Runtime identity is derived using the same Windows path normalization and SHA-256 rule as `runtime_package_identity.gd`. It resolves the per-Runtime config file, validates JSON and absolute package root, then checks the package manifest, database SHA-256, and each manifest asset's path containment, existence, byte size, and SHA-256.
- **CONFIRMED / TEST VERIFIED:** seven unit tests pass: absent config does not create files; valid package DB hash; missing package files; malformed config; DB hash mismatch; asset hash mismatch; and different Runtime paths produce different identities/config paths.
- **CONFIRMED / READ-ONLY QUERY:** selected Runtime ID 2 (`MENOS Runtime`, `E:\atlas\projects\menos\godot`) returned `BUILT_IN_CONTENT_CONFIGURED` and `package_state=NOT_CHECKED`, because no Runtime-specific config exists. The query did not create a config.
- **State semantics:** `PACKAGE_CONFIGURED_FOR_NEXT_LAUNCH` describes stored configuration, not the active state of an already running Runtime. `PACKAGE_INTEGRITY_OK` verifies the manifest-declared database and assets only. Missing or malformed inputs produce distinct failure states.
- **UNVERIFIED:** the adapter has not yet been connected to a Content Editor window or menu. Running Runtime process state is not inspected.

**Next decision gate:** integrate this adapter into a read-only Runtime status panel or section in the existing Runtime-aware comparison UI. The next slice should remain display-only and show selected Runtime identity, config path, configured package path, and integrity state; activation and settings writes remain out of scope.


## 16. RuntimeContext read-only UI integration ? implementation result (2026-10-10)

**Approved scope:** display selected Runtime identity, config location, configured package path, and integrity status in the existing dual-database comparison window. No activation or settings writes.

- **CONFIRMED / CODE VERIFIED:** `editor/dual_database_compare.gd` now displays a `RuntimeContext (read-only)` section above the independent DB comparison. Refresh reruns the status query and refreshes both views.
- **CONFIRMED / READ-ONLY SAFETY:** the view invokes `tools/runtime_config_status.py` with the selected Runtime ID. The helper reads `runtime_targets` via SQLite `mode=ro`; the previous call to `manage_runtime_registry.py list` has been removed from this view because that command enters a connection path that may migrate or write registry tables.
- **CONFIRMED / TEST VERIFIED:** nine unit tests pass, including selected Runtime resolution from a temporary registry DB, byte-for-byte verification that the registry is unchanged, and distinct failure reporting for a missing selected target.
- **CONFIRMED / PARSE CHECK:** Godot 4.7.2 headless editor scan exited 0. Existing invalid-UID fallback warnings were emitted for Northbridge tileset resources; these are unrelated to this task and were not changed.
- **CONFIRMED / LIVE READ-ONLY QUERY:** Runtime ID 2 resolves to `E:\atlas\projects\menos\godot`, identity `02f4584dfb9d159a0088bcf076f46eef229e9c15a616c1b6ba11acb89a147e38`, config state `BUILT_IN_CONTENT_CONFIGURED`, and package state `NOT_CHECKED`. No Runtime config was created.
- **UNVERIFIED:** actual window appearance and refresh behavior have not been inspected interactively. No PIE/Runtime launch test was performed.

**Decision gate:** UI integration is implemented. Recommend stop here and have Master inspect the comparison window during the planned focused UI/PIE pass. Any future activation workflow should be a separate approved slice.
