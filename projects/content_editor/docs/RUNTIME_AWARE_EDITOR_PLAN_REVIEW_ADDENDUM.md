
## 8. Second-Pass Review — Important Existing Workflow Boundaries

This section records a second-pass code/document review. It does not approve implementation or change Canon.

### 8.1 Runtime import is not Runtime cloning

- **CONFIRMED:** `RUNTIME_CONTENT_IMPORT_CONTRACT.md` states that import reads a full Runtime project DB, previews it, then on explicit apply replaces the Content Editor authoring database and canonical map JSON files after creating a timestamped backup. Custom map JSON files are preserved.
- **CONFIRMED:** the Runtime source DB is opened read-only and is not modified by this import workflow.
- **Implication:** this workflow is an inbound migration/synchronization into the authoring domain, not a per-Runtime copy operation. It must not be reused as the implementation of “copy authoring content to selected Runtime.”
- **Safety requirement:** UI labels must clearly distinguish “Import Runtime Data into Authoring Source” from “Publish/Copy Authoring Content to Runtime.” Preview and confirmation must name the direction and destination.

### 8.2 Package publish already has a distinct activation path

- **CONFIRMED:** the publisher reads authoring DB, authoring map JSON, and Runtime source assets; writes a new caller-selected output directory; and refuses to overwrite an existing output directory.
- **CONFIRMED:** after a successful publish, the UI invokes a Runtime helper to update that Runtime's user-data package-selection configuration, then offers to launch the Runtime. If selection configuration fails, the UI reports that the package was published but not selected.
- **Implication:** publish and package selection are distinct outcomes, even though the current UI workflow can perform them consecutively. The proposed Runtime-aware UI must report at least “package created,” “selected by Runtime,” and “Runtime restarted/loaded” as separate states. A successful package build alone does not prove that the Runtime is using it.

### 8.3 Runtime Registry selection is not yet a universal context service

- **CONFIRMED:** registry selection is persisted using `selected_runtime_id` in `user://menos_settings.cfg`.
- **CONFIRMED:** the DB comparison tool independently reads that setting and resolves the selected Runtime database path.
- **CONFIRMED:** the registry manager stores enabled table settings for publish selection.
- **INFERENCE:** current consumers can independently resolve the selection rather than subscribe to a single context/service. This creates a risk that future or already-open editors will not refresh consistently when selection changes.
- **Requirement:** one shared service must own selected Runtime resolution, path validation, health/status, and a selection-changed signal. Editor adapters must not each implement their own registry lookup.

### 8.4 Data stores are mixed; the current classification needs code-level completion

- **CONFIRMED:** Robot, Unit, and Tower scripts call shared catalog repository/persistence helpers; the Runtime selector is not directly used by those editor scripts in the reviewed code.
- **CONFIRMED:** Map authoring is JSON-file-based and the map contract excludes automatic Runtime synchronization.
- **CONFIRMED:** the current DB comparison scene mapping covers only a subset of editors. It does not by itself prove full schema compatibility or complete reference coverage.
- **UNVERIFIED:** full table-to-editor mapping, actual Runtime schema versions, all referenced asset roots, and whether each menu is authoring-only or Runtime-content-bearing. Phase 0 must finish this inventory before implementation.

### 8.5 Required workflow/state model

Do not collapse the following into a single “synced” indicator:

1. Source saved.
2. Target Runtime resolved and readable.
3. Differences computed.
4. Copy/publish preview validated.
5. Copy/package generated.
6. Runtime package selection updated, if applicable.
7. Runtime restarted and confirmed to load the selected package.
8. Runtime-side content behavior accepted.

Each state needs its own result. Later states cannot be inferred from earlier success.

### 8.6 Refined decision gate

Before implementation, Master must decide the intended ownership model:

- **Recommended baseline:** Runtime panes are read-only; edits occur in authoring source; an explicit copy/publish operation creates an isolated per-Runtime result. Import from Runtime into authoring remains a separate, explicitly destructive-to-authoring workflow protected by preview and backup.
- **Alternative:** selected Runtime can be edited directly. This requires a separate policy for backups, concurrent Runtime execution, schema compatibility, rollback, source-of-truth conflicts, and whether changes can be imported back to authoring.

**PROPOSAL:** retain the read-only Runtime pane and authoring-source ownership model for the first release. Treat direct Runtime editing as out of scope until separately approved. Continue READ-ONLY inventory and do not implement adapters or UI until every content-bearing editor's source/destination mapping and copy boundary is documented.
