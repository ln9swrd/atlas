# RuntimeContext Status Adapter

## Purpose

Expose the selected Runtime's per-project package config and package integrity state to Content Editor without mutating the Runtime registry, config, package, or databases.

## Invocation

The Content Editor comparison view invokes the helper using the selected Runtime ID and the registry database in read-only mode:

```powershell
python tools/runtime_config_status.py --registry-db "data/runtime_registry.sqlite" --selected-runtime-id 2 --userdata-base "$env:APPDATA\Godot\app_userdata"
```

The helper reads only `runtime_id`, `name`, `project_path`, and `enabled` from `runtime_targets` using SQLite `mode=ro`. It derives the Godot user-data folder from `config/name` in the registered Runtime's `project.godot`. Runtime identity is the SHA-256 of the normalized project path (Windows path separators and casing are normalized), matching `RuntimePackageIdentity`. The direct `--project-path` / `--user-data-root` mode remains available for isolated checks.

## Read-only contract

- Does not import or invoke `manage_runtime_registry.py`.
- Does not open or write any SQLite database.
- Opens the selected Runtime config only for reading. Missing config is reported as built-in content configured and is not created.
- Reads the manifest, hashes the configured package database, and verifies manifest-listed asset existence, size, hash, and path containment.
- Never activates a package or claims to know what an already-running Runtime has loaded.

## Output states

`config_state` is one of `BUILT_IN_CONTENT_CONFIGURED`, `PACKAGE_CONFIGURED_FOR_NEXT_LAUNCH`, or `INVALID_CONFIG`. A missing registered project returns `RUNTIME_PROJECT_NOT_FOUND`; an invalid input path returns `INVALID_RUNTIME_PATH`.

`package_state` is one of `NOT_CHECKED`, `PACKAGE_FILES_MISSING`, `MANIFEST_INVALID`, `DATABASE_HASH_MISMATCH`, `PACKAGE_ASSET_MISSING`, `PACKAGE_ASSET_SIZE_MISMATCH`, `PACKAGE_ASSET_HASH_MISMATCH`, or `PACKAGE_INTEGRITY_OK`. Integrity is limited to the manifest-declared DB and assets; it does not assert that the live Runtime has loaded the package.

## Tests

Run `python -m unittest projects.content_editor.tests.test_runtime_config_status -v` from the repository root. The test suite uses temporary fixture directories and does not write to the real Runtime's configuration. It also verifies that selected-Runtime lookup leaves the registry DB byte-for-byte unchanged.

## Out of scope

No UI integration, config writes, legacy config migration, package activation, registry mutation, database edits, commit, or push.
