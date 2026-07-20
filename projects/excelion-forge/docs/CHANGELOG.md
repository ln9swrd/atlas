# EXCELION FORGE CHANGELOG

> Product : Excelion Forge
> Python Package : excelion_forge
> Status : Active
> Version : v0.2
> Last Updated : 2026-07-03

---

# v0.2

## Added

* Severity filter (ALL / ERROR / WARNING / INFO) for validation results
* Result search by code and message
* **Result sort** by Severity / Rule Name / Location (cache-based, no draw() computation)
* **JSON Export** — full session serialization to UTF-8 JSON with file dialog
* **HTML Report** — styled standalone HTML from session data, severity color-coded table
* Click-to-select: select Object or Bone from a validation result item
* Auto Fix All operator to apply all available fixes in one action
* `display_issues` session cache — filter/search/sort results stored separately from master list
* `rebuild_display_issues()` — rebuild on demand, zero computation in `draw()`
* `core/serializer.py` — Blender-independent JSON serialization
* `core/html_report.py` — Blender-independent HTML generation
* `operators/export.py` — `EFORGE_OT_export_json`, `EFORGE_OT_export_html`
* `tests/blend_samples/generate_samples.py` — Blender script to generate 5 regression .blend files
* `tests/integration/test_blender_validation.py` — headless Blender integration test (per-sample)
* `tests/integration/run_all.py` — run integration tests across all 5 regression samples

## Changed

* `ValidationIssue.location` removed; replaced with `location_type`, `object_name`, `bone_name`
* All validation rules migrated to new structured location model
* `ArmatureTransformRule` message now includes failed field names inline
* `SingleRootBoneRule` MULTIPLE_ROOT_BONES message now lists all root bone names
* `BoneNameRule` DUPLICATE_BONE_NAME message now includes the bone name inline
* Panel `draw()` reads from `display_issues` only — no filtering logic in draw path
* JSON export schema includes `fix_params_json` when `has_fix` is true
* Addon `bl_info` version synced to `(0, 2, 0)`
* Regression sample `invalid_duplicate_bone` uses `MULTIPLE_ROOT_BONES` (Blender 5.x API constraint documented in SPEC)

---

# v0.1

## Added

* Blender addon skeleton
* 3D View Sidebar UI panel
* Active rig validation operator
* Core validation report and issue models
* Object-level rig validation rules
* Unit tests for Sprint 2 object validation behavior
* RuleManager-based validation framework
* Per-rule ValidationResult data model
* Transform and bone name validation rules

## Documentation

* Normalized product and package naming.
* Registered Forge documents in `docs/INDEX.md`.
* Added Sprint 2 object validation test cases.

## Changed

* Split object validation rules into one file per rule class.
* Validation operator now delegates target validation to core rules.
* Operator poll now checks only that Blender supplied an execution context.
* RigValidator now uses RuleManager internally while preserving the existing API.
