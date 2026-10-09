# Runtime Content Package Publisher

Status: first isolated publishing implementation and headless compatibility smoke passed, 2026-10-09. This is a content-package PoC, not Production deployment approval.

## Invocation

From the repository root (`D:\Atlas\projects\menos`):

```powershell
python content_editor\tools\publish_runtime_package.py --runtime-root D:\Atlas\projects\menos\godot --output D:\Atlas\builds\menos-runtime-package-YYYYMMDD
```

The output path must not already exist. The publisher creates a temporary sibling directory, validates the output, then renames it into place. It never overwrites an existing package. On failure, the temporary output is removed.

Optional inputs:

- `--source-db`: defaults to `content_editor/data/menos.sqlite`.
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
- Asset files are copied at their Runtime-relative paths (`images/...`, `sound/...`, `assets/...`, `content/editor/...`). Adjacent `.import` files are included when present.

## Filtering and compatibility

- The publisher fails closed if the source database table set differs from its reviewed table allowlist.
- `editor`, `player_profile`, and `schema_migrations` are excluded. Player profile/save data remains separate from distributable content. The Runtime title-screen visual settings are projected into a narrow `runtime_settings` table; the full Content Editor settings document is not shipped.
- Runtime content tables and fixed legacy map tables are retained. The published DB also has `map_documents` for the per-map JSON documents.
- `northbridge_sector_01.json` is materialized to `northbridge_sector_01`, legacy `map_01`, and `map_documents` for compatibility. `map_02` and `map_03` remain available through both fixed tables and `map_documents`.
- Only Campaign and Single Play are published as supported map modes. Existing `multiplayer` mode entries are omitted from the published `play_modes` array and reported in `manifest.json`; other source JSON metadata and all authoring inputs remain unchanged.
- Campaign Stage references, Stage map references, Mission/Reward references, referenced `res://` Asset existence, generated DB integrity, output file hashes, and source DB/map hashes are checked.

## Verification and limitations

- Python integration test: `python -m unittest content_editor.tests.test_runtime_publisher -v`.
- Runtime headless smoke exercises the existing Runtime `MapLoader` and `ContentCatalogLoader` against the generated DB using their debug test-path overrides. It verifies the fixed map aliases, canonical map ID, Campaign, Stage and robot catalog. This does not modify Runtime code or the Runtime DB.
- The package is a data/Asset directory, not a standalone game build. It has not been copied into `godot/`, and no automatic deployment or replacement of `godot/content/menos.sqlite` occurs.
- Database resource closure covers `res://` references discovered in included database content. It does not package the Runtime executable, scenes/scripts, or every hard-coded scene dependency. Production deployment still requires an explicit integration procedure and broader end-to-end validation.
- GUI acceptance and Master PIE verification are not performed by this publisher.

## Safety

The publisher only reads the authoring database, map JSON, and Runtime source Assets. It writes to a new caller-selected output directory. It never writes to the source database, Runtime database, authoring map files, or Runtime source Assets. No Commit or Push is performed.

## Content Editor UI

Open the Content Editor and use `RUNTIME DATA > Publish Runtime Package`. Select the Runtime project root, then select the parent directory for a new package. After confirmation, the Publisher creates a uniquely timestamped package directory. The output directory must not already exist. This action does not activate the package in Runtime.

Use `RUNTIME DATA > Import Runtime Data` to select the full Runtime project's `content/menos.sqlite`. The Editor previews the source hash, table count, and canonical maps, then asks for confirmation. Apply backs up the current authoring DB and maps before replacement. Filtered published-package databases are not accepted by the first-pass importer because their schema differs from the full authoring DB.