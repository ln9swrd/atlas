# Content Editor UI Improvement Plan

**Status:** PROPOSAL — 단계적 UI 개선 계획. Canon 변경 아님.
**Date:** 2026-10-09
**Scope:** MENOS Godot Content Editor and its authoring menus. Layout/usability only unless Master separately approves a behavioral change.

## 1. Purpose

Resolve three observed UI problem classes in some Content Editor menus:
- Wasted space that reduces the useful work area.
- Controls or content extending beyond the visible area or becoming inaccessible.
- Poor placement, grouping, sizing, or visual hierarchy that makes common tasks harder.

The goal is a consistent, usable authoring workspace across the existing menus without changing catalog semantics, persistence behavior, validation rules, or gameplay/runtime behavior.

## 2. Scope Lock

**Included**
- Layout measurements, container/anchor/size-flag behavior, minimum sizes, spacing, scrolling, split proportions, field grouping, and action placement.
- Readability and discoverability improvements that preserve current controls and behavior.
- A documented before/after verification pass at the actual application window size.

**Excluded unless separately approved**
- Catalog/schema/data changes; Save/Reload/Delete semantics; validation contract changes.
- New authoring features, menus, asset-generation features, or redesign of gameplay/runtime.
- Broad theme replacement, complete rewrite of all editors, or external UI frameworks.
- Changes to Image Editor multi-file mutation/persistence behavior.

## 3. Baseline and Known Facts

**CONFIRMED**
- The editor implementation includes separate scripts for Asset Catalog, BGM, Building, Campaign, Content Editor shell, Faction, Image, Map, Mission, Robot, SFX, Skill, Stage, Tower, Unit, VFX, and Voice.
- The repository already contains multiple layout patterns: dynamically constructed HBox/VBox/Grid containers, ScrollContainers, fixed minimum widths/heights, and SplitContainers.
- Examples of fixed layout constraints found in code include Asset Catalog details width 400, Image Editor left panel width 420 and source panel width 280, Building list width 260, and Robot sidebar width 250. These are investigation leads, not yet proven defects.
- Existing working tree has unrelated changes. Preserve them and inspect each target diff before and after editing.

**UNVERIFIED**
- Which menus are the worst offenders at the actual Master display resolution.
- Whether controls are clipped, below the fold, too wide, or merely visually unbalanced in each menu.
- The best split ratios and minimum supported window size for each editor.

No menu should be declared defective based on source-code heuristics alone; use a visible baseline and reproducible observation.

## 4. UI Quality Rules

Apply these rules consistently where relevant:

1. **Fit the viewport:** primary actions and essential fields must remain reachable at the agreed minimum window size. Content that can grow vertically must use a ScrollContainer or an equivalent intentional scrolling pattern.
2. **Use space deliberately:** flexible panels should consume remaining space; fixed widths should be reserved for controls that demonstrably need them. Avoid large empty regions caused by hard-coded dimensions.
3. **Keep primary actions discoverable:** Save/Reload/Delete and the menu's main task controls should be grouped predictably and should not disappear below long forms without a deliberate fixed action area.
4. **Group by task:** selection/navigation, preview, editable properties, validation/status, and destructive actions should be visually distinct.
5. **Prefer responsive sizing:** use anchors, size flags, stretch ratios, and sensible minimum sizes rather than screen-specific offsets wherever feasible.
6. **Preserve behavior:** layout changes must not alter signal wiring, selected record identity, data bindings, validation, persistence, or navigation.
7. **Avoid unnecessary uniformity:** Map, Image, and Asset Catalog are specialized workspaces; they may use different layouts when the task requires it, while still following the same accessibility and space-use rules.
8. **No speculative redesign:** retain familiar controls and labels unless a specific usability issue is documented.

## 5. Staged Work Plan

### Phase 0 — Baseline capture and issue inventory

**Method**
- Confirm branch, HEAD, and dirty working tree before touching UI files.
- Open each existing menu in the actual GUI at the current working resolution; record window dimensions and menu state.
- Capture before screenshots where permitted. If a menu cannot be inspected visually, label it UNVERIFIED rather than inferring its appearance.
- Record each issue with menu, screenshot/evidence, symptom, severity, likely layout cause, and a measurable acceptance condition.

**Severity**
- **P0:** essential control is clipped/inaccessible; user cannot complete a normal authoring task.
- **P1:** significant space waste or placement causes repeated scrolling, obscures preview/data, or makes key actions hard to find.
- **P2:** spacing, alignment, labels, or grouping are inconsistent but the task remains usable.

**Exit condition:** a ranked issue list based on observed UI, not assumptions. No implementation in this phase.

### Phase 1 — Establish a small layout contract

Define only reusable rules supported by the inventory:
- Standard outer margins and spacing.
- Expected behavior for window resizing and vertical overflow.
- Common placement for title/status and primary actions where menu structure permits.
- Minimum width guidance for navigation, preview, and property panels.
- Scroll behavior for long forms and long item lists.
- SplitContainer defaults and stretch behavior for two-/three-panel editors.

Do not introduce a new shared UI framework just to enforce these rules. Reuse existing helpers only when they materially reduce duplication and risk.

**Exit condition:** a short contract and a prioritized pilot selection approved by evidence.

### Phase 2 — Pilot on the highest-value layout cases

Choose at most two contrasting pilot menus after Phase 0:
- One form/list editor with a long property panel.
- One specialized multi-panel workspace if its observed defects warrant it.

Candidates to inspect first include Building, Robot, Asset Catalog, and Image Editor because their source contains fixed-size or multi-panel layout decisions. This is a candidate list only; visual evidence determines selection.

For each pilot:
1. Record baseline screenshot and exact defect.
2. Change one layout cause at a time.
3. Inspect the focused diff and confirm no persistence/validation logic changed.
4. Run script parse/check and the narrowest relevant smoke test.
5. Reopen the menu and compare before/after at the same resolution and at one narrower window size.
6. Confirm no essential controls are clipped and scrolling/resizing behaves intentionally.

**Exit condition:** at least one proven issue is resolved without regressions; the layout contract is revised only if the pilot provides evidence.

### Phase 3 — Prioritized menu rollout

Roll out in severity order, one menu at a time:
1. P0 inaccessible/clipped controls.
2. P1 major space and placement defects.
3. P2 alignment and consistency issues.

Do not bulk-edit every editor with one replacement. Preserve intentional differences in Map/Image/Catalog workflows. After each menu, run its focused checks and inspect the diff before proceeding.

**Exit condition:** every menu in the approved inventory has a disposition: fixed and verified, acceptable as-is, or explicitly deferred with reason.

### Phase 4 — Cross-menu regression and acceptance

Verify:
- All approved menu routes still open the correct editor.
- No control is clipped at the agreed baseline resolution.
- Long forms and lists are scrollable; scrolling does not hide essential actions permanently.
- Panel resizing does not collapse the primary work area or leave excessive unused space.
- Selection, preview, validation/status, and primary actions remain visible and correctly connected.
- Save/Reload/Delete and data values behave as before for the menus tested.
- Existing smoke tests remain passing; inspect screenshots for visible confirmation.

Automated tests or headless scene loads alone do not establish visual/PIE acceptance.

**Exit condition:** a per-menu result matrix and Master review of the actual GUI.

## 6. Verification and Safety Gates

Before and after each implementation batch:
- Record HEAD, branch, and working-tree state.
- Keep pre-existing changes intact; do not reset, revert, or reformat unrelated files.
- Review git diff --check and the exact diff for every changed UI file.
- Run the relevant Godot --check-only or focused smoke test where available.
- Record CODE/EDITOR/PIE status independently. A headless PASS is not PIE VERIFIED.
- Stop and report if the issue requires changing editor behavior, data contracts, persistence, or shared architecture.

No Commit/Push is included in this plan by itself. At goal completion, classify the diff and follow the project's approved Commit/Push gate; never bundle unrelated changes.

## 7. Reporting Format

For each phase, record:
- **STATUS:** PASS / HOLD / FAIL / UNVERIFIED
- **Menu / issue ID and severity**
- **Observed symptom and evidence**
- **Root cause:** CONFIRMED / HIGH CONFIDENCE / INFERENCE
- **Change made:** exact files and layout behavior
- **Verification:** CODE / BUILD / EDITOR / PIE
- **Regression check and diff result**
- **Deferred items / OUT OF SCOPE**
- **PROPOSAL:** next phase or ACCEPT·STOP

## 8. Success Criteria

The short-term goal is complete when:
- The approved menu inventory has a documented disposition.
- All P0 issues are resolved or explicitly held for a Master decision.
- Approved P1 issues are resolved and visually rechecked.
- No essential control is inaccessible at the agreed baseline window size in the verified menus.
- No unintended behavior/data/persistence changes are present in the reviewed diff.
- Master has reviewed the resulting GUI state.

Do not expand to a full visual redesign after these criteria are met.

## 9. Current Decision / Proposal

**PROGRESS — Phase 0 GUI Baseline (2026-10-09, 1920×1080 desktop)**

**STATUS: IN PROGRESS — visible evidence collected for Map, Building, Tower, Robot, and Asset Catalog; remaining menu inventory is incomplete. No UI implementation changes made.**

- **Map — CONFIRMED:** the central map canvas uses most of the available width; the left toolbox/asset browser has its own vertical scroll area and several stacked sections. This is a specialized workspace; do not compress it using generic form-editor rules. Potential follow-up: assess whether the toolbox scroll and bottom action strip remain usable at the target minimum window size.
- **Building — CONFIRMED:** property fields stretch almost the entire window width, while most of the lower half remains unused after the final Sprite Asset field. The visible selection dropdown was blank while status reported “Loaded: buildings”; this may be a data/selection state rather than a layout defect and is **OUT OF SCOPE** for UI-only changes until separately diagnosed. Strong pilot candidate for a compact property column or deliberate two-column composition, but the exact layout should be chosen only after checking related editor patterns.
- **Tower — CONFIRMED:** long property and sprite-animation sections use a vertical scroll bar; required/optional asset status and animation preview appear lower in the same vertical flow. Candidate P1 issue: long-form vertical navigation may make preview/status less discoverable. Verify whether a split/scroll arrangement can improve this without changing behavior.
- **Robot — CONFIRMED:** at 1920×1080 the properties area uses two side-by-side field groups and a large preview panel on the left, but the long sprite-animation/skills form continues below the viewport and requires vertical scrolling. The lower Finisher row is visibly cut off at the bottom edge in the baseline capture. Candidate P0/P1 depends on whether the hidden controls are merely scrollable or inaccessible; current evidence supports P1 for discoverability, not P0.
- **Asset Catalog — CONFIRMED:** a narrow left list/search pane sits beside a large source-image workspace. Before selecting a source image the workspace is mostly an instructional empty state; editing controls and Sprite Sheet Grid/Anchor controls form a dense horizontal toolbar below. This is a specialized workspace and should not be forced into a generic form layout. Verify narrow-window reachability and toolbar overflow before classifying it as defective.
- Screens were inspected through a live GUI capture. Temporary capture path was `godot/_ui_baseline_temp.png`; it is not treated as durable evidence or a project asset.

**Preliminary candidates (not yet final ranked inventory):**
1. **Building — P1 candidate:** property fields stretch across nearly the full window while the lower half is unused; investigate a bounded property column or intentional two-column layout.
2. **Robot — P1 candidate:** dense multi-column properties and long animation/skill form extend below the viewport; investigate scrolling/section grouping while preserving the preview and current field wiring.
3. **Tower — P1 candidate:** long property/animation form with status and preview lower in the same scroll flow.
4. Map and Asset Catalog — specialized workspaces; inspect minimum-window behavior before proposing layout changes.
5. Stage, Mission, Campaign, Faction, Unit, Skill, VFX, SFX, BGM, Voice, Settings, and Language — fresh visual inventory still incomplete; do not infer defects from source dimensions alone.

**Decision gate:** Phase 0 is not complete until the remaining authoring menus are either visually inspected or explicitly marked UNVERIFIED. No implementation should start until the inventory is complete and a maximum of two pilot menus is justified by evidence.

**MASTER SCOPE UPDATE (2026-10-09):** UI improvement scope is restricted to Building, VFX, SFX, BGM, and Voice editors only. Robot, Tower, Map, Asset Catalog, and all other menus are OUT OF SCOPE for this short-term goal. Do not inspect or modify them further under this task.

**PROPOSAL:** Continue Phase 0 only for Building, VFX, SFX, BGM, and Voice. Inspect actual GUI layouts for these five menus, complete the evidence-ranked issue inventory, then choose pilot edits within this scope. Do not edit layouts until the five-menu baseline is sufficient.
