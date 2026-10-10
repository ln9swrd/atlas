# Runtime Package Config Identity

## Purpose

Keep external package selection isolated per Runtime project even when several projects share the same Godot `user://` data directory. This layer reports configured selection only; it does not prove package validity or live Runtime load state.

## Identity rule

1. Start from the absolute project root.
2. Normalize path separators and redundant segments.
3. On Windows, lowercase the normalized path because the filesystem is case-insensitive. On other platforms, preserve case.
4. Compute SHA-256 of the normalized UTF-8 path.
5. Store the selection in `user://runtime_content_package_<sha256>.json`.

Runtime package loading and `runtime_package_config_cli.gd` share `scripts/runtime_package_identity.gd` so they derive the same key. A project moved to a different path receives a different identity and must be revalidated. Symlink/alias paths are not resolved to a physical canonical path; register and invoke a Runtime using one consistent absolute path.

## Read-only query

Run from the target Runtime project context:

```powershell
& 'E:\godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'E:\atlas\projects\menos\godot' --script res://scripts/runtime_package_config_cli.gd -- --show-config
```

The command emits one JSON record with `identity`, `project_root`, `config_path`, `configured`, `package_root`, and `config_state`. `BUILT_IN_CONTENT_CONFIGURED` means no per-Runtime package selection config exists. `PACKAGE_CONFIGURED_FOR_NEXT_LAUNCH` means a parseable path is recorded; it does not certify manifest/hash integrity or that a running process loaded the package. `INVALID_CONFIG` and `UNREADABLE_CONFIG` are reported explicitly. The query does not create or modify a config file.

## Compatibility and safety

- The old `user://runtime_content_package.json` is deliberately not read as a fallback, migrated, overwritten, or deleted.
- Config writes require the existing explicit `--package-root` command; this command writes only the current Runtime identity's config file.
- The query is read-only. Package validation and Runtime loaded-state reporting remain separate concerns.
- Runtime identity is based on project path, not a permanent GUID. A path move changes identity.
