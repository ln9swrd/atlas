# Content Editor Map Authoring Contract

Status: implementation of the Master-approved short-term map-source boundary, 2026-10-09.

## Ownership and source of truth

- Content Editor owns editable map JSON files under `data/maps/`, one UTF-8 JSON document per map.
- The filename stem and the document's `map_id` must match exactly. IDs are path-safe and unique.
- `northbridge_sector_01.json` is the authoring source for the former SQLite `map_01` record. It preserves the current active record's 309 objects and data fields.
- `map_02.json` and `map_03.json` are sourced from their existing active SQLite records.
- `map_01_src` is a legacy record, not an active map source. It remains in SQLite and is not migrated or deleted by this change.
- The original `data/content_editor.sqlite` is retained for non-map catalogs and legacy data. Map save/create/delete operations must not mutate SQLite.

## Legacy references

- Existing Stage `map_file: "map_01"` resolves through one adapter to `northbridge_sector_01`.
- `map_02` and `map_03` retain their existing IDs.
- Legacy `res://content/maps/map_01.json` path references resolve to `northbridge_sector_01` during transition.
- Stage records are not mass-rewritten by this change. Deletion of the three canonical maps is blocked.

## Save and validation

- Create refuses invalid IDs, legacy aliases, and existing filenames; it never overwrites on create.
- Save requires the in-document ID to match the target filename and writes through a temporary file with a backup/rollback path.
- Save validates that the temporary JSON can be parsed before replacing the existing file.
- Delete applies only to a selected non-canonical JSON file; callers must check Stage references before invoking it.
- The validator checks JSON object shape, filename/`map_id` agreement, ID validity, case-insensitive duplicate filenames, and supported play modes.
- Supported modes are Campaign and Single Play. The Multiplayer toggle is disabled. Existing Multiplayer metadata is preserved and reported as unsupported; this change does not silently delete it.

## Explicitly out of scope

- Runtime code, Runtime database, Runtime map files, automatic package deployment, stage-record migration, and GUI/PIE acceptance.
- The Runtime must continue to use its own project and data boundary; this Content Editor implementation does not synchronize or modify Runtime files.
