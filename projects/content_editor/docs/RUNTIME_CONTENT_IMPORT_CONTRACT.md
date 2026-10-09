# Runtime Data Management and Project Boundary Contract — Proposal

Status: Implemented first-pass workflow; import policy and future package-source support remain PROPOSAL, not Canon. Updated 2026-10-10.

## Goal

Keep the MENOS Runtime project free of Content Editor implementation while allowing Content Editor to manage existing Runtime content and publish new Runtime packages.

## Canon constraints

- Content Editor and Runtime databases remain separate files and separate ownership domains.
- Content Editor owns authoring UI, authoring data, map JSON source, validation, preview, and publishing tools.
- Runtime owns gameplay code/scenes, runtime loaders/adapters, runtime-owned settings/save data, and bundled fallback content.
- Publishing creates a new package. It does not overwrite the Runtime source DB or activate a package automatically.
- No commit/push or GUI/PIE acceptance is implied.

## Proposed existing-content workflow

1. Content Editor selects the full Runtime project database `content/menos.sqlite` using the `RUNTIME DATA > Import Runtime Data` UI. Filtered published-package databases are currently rejected because they omit authoring tables; package-source import needs a separately reviewed schema adapter.
2. Import runs read-only against the selected source and first produces a preview report: schema/table compatibility, record counts, source hash, resource references, map records, and conflicts with current authoring data.
3. The user explicitly confirms the import. The tool creates a timestamped backup of the current Content Editor DB and stages a replacement/merge in a temporary DB. It never writes to the Runtime DB.
4. Maps are exported from the selected Runtime DB to per-map JSON using the existing map authoring contract. Unsupported or unmappable rows stop the operation rather than being silently dropped.
5. The staged DB and maps are validated; only a successful validated transaction can replace the authoring state. Existing files are recoverable from backups.
6. The user edits and validates content in Content Editor, then publishes to a new package directory.
7. Runtime package selection remains a separate explicit action.

## Implemented behavior and remaining policy

Recommended initial policy: **replace the authoring content snapshot from the selected Runtime source after preview and explicit confirmation**, while preserving authoring-only data that is not part of the Runtime schema only when a reviewed table/field mapping explicitly allows it. Do not perform an implicit row-by-row merge: it can create ambiguous ID collisions and partial cross-table state.

The importer must reject incompatible schema/table sets, unresolved resource paths, missing map identity, invalid DB integrity, or failed validation. It must not silently discard data.

## Runtime asset boundary audit

- Runtime `game_controller.gd` directly references `res://content/editor/edited_assets/enemy_giant_edit_292534902.png`.
- Both current DB files reference `res://content/editor/edited_assets/range_edit_208771618.png`.
- Content Editor's image editor writes to its own project's `res://content/editor/edited_assets`.
- Therefore `content/editor/edited_assets` is currently a content/asset dependency, not merely a removable editor-code directory. It must not be deleted until the asset ownership/path migration is implemented and both projects' references and package publishing are validated.

## Runtime folder hygiene

- `.godot/`, `build/`, and `builds/` are generated cache/build areas and are already ignored by repository rules (`.godot/`, `build/`, and `projects/menos/godot/builds/`). Do not delete them as part of structural cleanup without checking active build use.
- Root-level temporary screenshots/candidate images are tracked in Git in some cases; do not delete them as presumed disposable files. Classify references and archival value first.
- `.bak` files are ignored/untracked in the repository in the current baseline; preserve until an explicit retention/archive policy is agreed.

## Minimum acceptance

- Runtime has no Content Editor scenes/scripts/translations or direct dependencies on the Content Editor project's filesystem.
- Any retained generated content asset has a documented runtime-owned/package contract and valid references.
- Import is read-only until explicit confirmation, produces backup and preview report, and never writes to Runtime DB.
- Imported content opens and validates in Content Editor; Publisher builds a new package; Runtime headless smoke reads it successfully.
- DB hashes are recorded before/after; source Runtime DB remains unchanged.
- GUI/PIE acceptance remains for Master.

## Current implementation (2026-10-10)

- `tools/import_runtime_content.py` defaults to preview-only. `--apply` is required to write the authoring target.
- The Content Editor top menu has `RUNTIME DATA`, with `Import Runtime Data` and `Publish Runtime Package` actions.
- Import preview validates SQLite integrity, schema table set, and canonical map identities before any writes. It reports source SHA-256 and table counts.
- Apply creates a timestamped backup under `data/backups/runtime_import_<UTC timestamp>/`, stages the Runtime DB, writes the canonical map JSON files, and verifies hashes and map identities. Custom authoring map JSON files are preserved. Runtime DB is opened read-only and never modified.
- The canonical Northbridge map is imported from the Runtime legacy `map_01` table and normalized to `northbridge_sector_01`; this preserves its 309 placed objects. Reading the `northbridge_sector_01` table instead would lose those objects, so the importer deliberately uses the actual Runtime loader's legacy table contract.
- UI import and publish use Python 3 (`python` or Windows `py -3`). UI flow has headless startup verification only; Master visual interaction remains NOT VERIFIED.
- The Content Editor remembers a selected Runtime project root locally. Import defaults to that root’s content/menos.sqlite, while an explicit SQLite-file override remains available. Publish defaults to a timestamped package under the selected Runtime project’s parent packages/ directory, with a custom output-folder option. After a successful publish, the Content Editor writes the package selection into the selected Runtime project’s own user:// config via its headless helper, then offers to launch that Runtime. Runtime source DB/assets are not overwritten.
- Importing a filtered published-package DB, visual asset migration, and cross-version schema migrations are not implemented yet.
