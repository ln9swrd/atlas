# Runtime Content Package Publisher

Status: first isolated publishing implementation and headless compatibility smoke passed, 2026-10-09. This is a content-package PoC, not Production deployment approval.

## Invocation

From the repository root (`D:\Atlas\projects\menos`):

```powershell
python content_editor\tools\publish_runtime_package.py --runtime-root D:\Atlas\projects\menos\godot --output D:\Atlas\builds\menos-runtime-package-YYYYMMDD
```

The output path must not already exist. The publisher creates a temporary sibling directory, validates the output, then renames it into place. It never overwrites an existing package. On failure, the temporary output is removed.

Optional inputs:

- `--source-db`: defaults to `content_editor/data/content_editor.sqlite`.
- `--maps-dir`: defaults to `content_editor/data/maps`.
- `--runtime-root`: **required** explicit path to the Runtime project; used only as the source for referenced `res://` assets. The Content Editor no longer infers a sibling Runtime path.

Publisher integration test (PowerShell, from the repository root):

```powershell
$env:MENOS_RUNTIME_ROOT = "D:\Atlas\projects\menos\godot"
python -m unittest content_editor.tests.test_runtime_publisher -v
Remove-Item Env:MENOS_RUNTIME_ROOT
```

The integration test requires the same explicit Runtime root; it does not infer a sibling directory.

## Output layout

- `content/menos.sqlite`: newly constructed filtered SQLite database; Runtime loaders open it read-only.
- `manifest.json`: package/schema versions, source DB hash, published map IDs/source hashes, included tables, database hash, Asset hashes/sizes and compatibility warnings.
- Referenced Runtime Asset files are copied at their Runtime-relative paths (`images/...`, `sound/...`, `assets/...`, `content/editor/...`). Godot `.import` sidecars are editor-generated metadata and are not copied or listed in the package manifest; the manifest hashes only directly consumed content Assets.

## Filtering and compatibility

- The publisher fails closed if the source database table set differs from its reviewed table allowlist.
- `editor`, `player_profile`, and `schema_migrations` are excluded. Player profile/save data remains separate from distributable content. The Runtime title-screen visual settings are projected into a narrow `runtime_settings` table; the full Content Editor settings document is not shipped.
- Runtime content tables and fixed legacy map tables are retained. The published DB also has `map_documents` for the per-map JSON documents.
- `northbridge_sector_01.json` is materialized to `northbridge_sector_01`, legacy `map_01`, and `map_documents` for compatibility. `map_02` and `map_03` remain available through both fixed tables and `map_documents`.
- Only Campaign and Single Play are published as supported map modes. Existing `multiplayer` mode entries are omitted from the published `play_modes` array and reported in `manifest.json`; other source JSON metadata and all authoring inputs remain unchanged.
- Campaign Stage references, Stage map references, Mission/Reward references, referenced `res://` Asset existence, generated DB integrity, output file hashes, and source DB/map hashes are checked.

## Verification and limitations

- Python integration test: `python -m unittest content_editor.tests.test_runtime_publisher -v`.
- Runtime headless smoke exercises the existing Runtime `MapLoader` and `ContentCatalogLoader` against the generated DB using their debug test-path overrides. It verifies the fixed map aliases, canonical map ID, Campaign, Stage and robot catalog, plus loading external PNG, SVG, OGG, and WAV resources. This does not modify the Runtime DB or source Assets.
- The package is a data/Asset directory, not a standalone game build. It has not been copied into `godot/`, and no automatic deployment or replacement of `godot/content/menos.sqlite` occurs.
- Database resource closure covers `res://` references discovered in included database content. It does not package the Runtime executable, scenes/scripts, or every hard-coded scene dependency. Production deployment still requires an explicit integration procedure and broader end-to-end validation.
- GUI acceptance and Master PIE verification are not performed by this publisher.

## Safety

The publisher only reads the authoring database, map JSON, and Runtime source Assets. It writes to a new caller-selected output directory. It never writes to the source database, Runtime database, authoring map files, or Runtime source Assets. No Commit or Push is performed.

## Content Editor UI

See the Target Runtime workflow below for the current Content Editor UI. The CLI remains available for explicit Runtime roots and output paths. Import expects the full Runtime project's content/menos.sqlite; filtered published-package databases are not accepted because their schema differs from the full authoring DB.

## Target Runtime workflow (2026-10-10)

- The Content Editor remembers the selected Runtime project root in its local user://menos_settings.cfg under [runtime] project_root. The current MENOS path is used as the initial default only when it exists and contains both project.godot and content/menos.sqlite.
- RUNTIME DATA > Select Runtime Project... changes the target. Import Runtime Data from Target... previews/imports that target's full content/menos.sqlite. Import from SQLite File... remains available for a one-off explicit source.
- Publish Runtime Package to Target... creates a fresh package under the target project's parent packages/ folder by default. Publish Package to Custom Folder... preserves manual output-location selection.
- After publishing succeeds, the Content Editor invokes the selected Runtime project's scripts/runtime_package_config_cli.gd to write its user://runtime_content_package.json. It then offers to launch the Runtime. An already-running Runtime must be restarted to load the newly selected package.
- This changes only the Runtime's user-data package-selection config. It does not overwrite the Runtime source database/assets. Package activation is not attempted if publishing fails. If the configuration helper fails, the UI reports that the package was published but not selected.
- The UI and headless startup have been checked; Master GUI/PIE acceptance remains NOT VERIFIED.



## Save versus Publish (explicit workflow)

- **Save to Content Editor DB** writes authoring changes to `projects/content_editor/data/content_editor.sqlite` only. It does not write to the Runtime DB or make changes live in Runtime.
- **IMPORT / PUBLISH > Publish Content Editor DB to Runtime Package...** reads the saved Content Editor DB and creates a new filtered package. On successful publish, the selected package is configured for the target Runtime; the user can then launch/restart Runtime to load it.
- Import is the opposite-direction operation: it copies reviewed Runtime source content into the Content Editor authoring database after preview and confirmation. It is not a publish action.

## Runtime target registry storage

- Runtime target registrations and per-target table publication settings are stored in `content_editor/data/runtime_registry.sqlite`, separate from both the Content Editor authoring database (`content_editor.sqlite`) and the Runtime content database (`godot/content/menos.sqlite`).
- On first initialization, `tools/manage_runtime_registry.py` imports only `runtime_targets` and `runtime_table_settings` from the legacy `data/menos.sqlite` when those tables exist and the new registry is empty. A timestamped full-database backup is written under `data/backups/` before migration. The legacy database is opened read-only and is not modified.
- `runtime_registry.sqlite` and `data/backups/` are local state and are excluded from Git. Do not manually delete the legacy database as part of this migration; its other tables are outside this registry change.
