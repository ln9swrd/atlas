# Runtime External Content Package Selection

Status: implementation and isolated headless verification passed on 2026-10-10. This is a package-selection mechanism, not Production rollout approval.

## Purpose and boundary

Runtime can read a selected content package from a directory outside the Godot project. The built-in `godot/content/menos.sqlite` and source Assets are not overwritten. Content Editor continues to own authoring JSON and its own database; Runtime consumes only the filtered generated package.

The selected package is read-only from Runtime. Player profiles/settings remain under `user://` and are not part of the content package.

## Selecting a package

Create this file in the MENOS Godot user-data directory:

`user://runtime_content_package.json`

Its contents must be JSON with an absolute filesystem path:

```json
{
  "package_root": "D:/Atlas/builds/menos-runtime-package-YYYYMMDD"
}
```

On Windows, forward slashes are accepted. `package_root` must point to the package directory that contains `manifest.json`, `content/menos.sqlite`, and the copied asset folders. Do not point it to the `content` subdirectory.

The config is intentionally separate from the project files and is not committed. To return to the built-in content, remove `runtime_content_package.json` and restart Runtime. The project does not currently include a GUI package picker.

## Validation and failure behavior

- If the selection config is absent, Runtime uses its built-in `res://content/menos.sqlite` and project Assets as before.
- If a selection config exists but is malformed, uses a relative path, has an unsupported package format, or points to an invalid package, the package is rejected. Runtime does not silently fall back to the built-in DB.
- `manifest.json` format version, database path, database SHA-256, and each manifest Asset's existence, size and SHA-256 are checked.
- `MapLoader` and `ContentCatalogLoader` use the same selected package database. The publisher projects only the Runtime title-screen visual settings into `runtime_settings`; the full Content Editor `editor` table remains excluded.
- Runtime content texture and audio adapters resolve packaged files under the selected package root. Current external file loaders support PNG/JPG/JPEG/WebP/BMP/TGA images and OGG/WAV/MP3 audio. Other resource types continue through the built-in Godot resource path and are not claimed as externally overrideable.
- Only paths explicitly listed as `content_asset` in the manifest are resolved to external package files. Unlisted built-in Runtime resources remain project-owned.

## Tests

Run from `D:\Atlas\projects\menos` after generating a package to a fresh temporary output directory:

```powershell
python -m unittest content_editor.tests.test_runtime_publisher -v
& 'D:\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe' --headless --path godot --script res://tests/runtime_content_package_smoke_test.gd -- --package-root 'D:\path\to\package'
& 'D:\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe' --headless --path godot --script res://tests/runtime_content_package_config_test.gd -- --package-root 'D:\path\to\package'
```

The tests exercise the selected DB through existing map/catalog loaders and load an external package PNG, OGG and WAV. The config test temporarily writes `user://runtime_content_package.json`, then restores its original bytes or removes the temporary file.

## Limitations

- This is a loose directory package. It does not include the game executable, scenes/scripts, or every hard-coded Runtime dependency.
- Only image/audio resources listed in the manifest are loaded from the package root. Shader/material/scene resources and static `preload()` dependencies remain bundled Runtime resources.
- No automatic deployment, package download/update, rollback UI, or package picker is implemented.
- Windows Desktop Release export completed successfully. The exported executable was run headlessly with a valid selected package: exit code 0, no Runtime/package/SQL errors.
- The same exported executable was run with a configured but missing package root. Runtime rejected the missing manifest and did not attempt to open/fall back to `res://content/menos.sqlite`; the fail-closed check passed. The test selection config was restored/removed afterward.
- `runtime_content_package_config_test.gd` also covers invalid package selection and verifies that map aliases, map data, and catalog data are not served from the built-in DB.
- These are headless release-startup checks, not Master PIE/visual acceptance.

## Content Editor integration (2026-10-10)

The Content Editor now invokes scripts/runtime_package_config_cli.gd using the selected Runtime project's Godot executable in headless script mode. The helper writes user://runtime_content_package.json in the Runtime project's own user-data context, so the Content Editor does not guess or hard-code the Runtime's AppData path. The selected package root must be an absolute path containing manifest.json and content/menos.sqlite.

After publishing and package selection succeed, the Content Editor offers to launch the selected Runtime. Runtime source DB/assets are not overwritten. Existing running instances must be restarted. GUI/PIE acceptance remains with Master and is NOT VERIFIED by headless checks.
