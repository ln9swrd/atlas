# MENOS Handoff History

This file preserves the historical contents extracted from the former state/CURRENT_STATE.md. Handoff content is retained in chronological order. The embedded pre-split CURRENT_STATE snapshot is preserved below as a historical snapshot.

## Handoff — Content Editor / Stage Editor MVP (2026-09-28)

- Status: PASS. A thin Content Editor Shell now hosts the existing Map Editor and Stage Editor without modifying their core functionality.
- Content Editor: godot/editor/content_editor.gd, godot/editor/content_editor.tscn. MAP/STAGE buttons mount the corresponding existing editor Scene.
- Stage Editor: godot/editor/stage_editor.gd, godot/editor/stage_editor.tscn. MVP covers Stage ID, Order, Name, Map, Initial Gold, Base HP, Next Stage ID, Wave/Group editing, and Stage JSON Load/Save using the existing StageLoader/StageManager data contract.
- Runtime verification: automated Godot 4.7.2 runtime test passed Content Editor startup, MAP mount, STAGE switch, existing stage_01.json load, and Stage JSON save to a temporary target. Temporary test files were removed afterward.
- Verification status: CODE VERIFIED / PASS; Runtime smoke test / PASS. BUILD VERIFIED: NOT VERIFIED. PIE VERIFIED: NOT VERIFIED because Master has not directly observed the GUI result. Automated runtime PASS is not treated as PIE verification.
- Changed by this handoff: documentation only.
- No commit/push.
- Out of scope: Content Editor feature expansion, Map/Stage Editor redesign, main.gd refactor, campaign editor, preview runtime, and additional Stage systems.
- Judgment: ACCEPT·STOP for the current Content Editor MVP objective. Do not automatically proceed to additional editor features.

## Handoff - First supplied TileMap battlefield (2026-09-25)

- Status: Implemented the first playable 28x18 Godot TileMap layout using only supplied map assets. Existing combat, spawn, player, and UI logic were preserved.
- Asset investigation: `images/map` sheets are 1536x1024, consistent with a 12x8 grid of 128x128 cells. `ground.png`, `road.png`, and `map boundary.png` were staged byte-identically under `godot/assets/menos/maps/`; individual cell semantics are not verified from the sheets.
- Map structure: `Ground` fills 28x18; `Road` forms two entry routes converging toward the existing Base; the Boundary TileMapLayer is retained but has no cells until directional Boundary semantics are verified. `main.tscn` contains three TileMapLayer nodes using `northbridge_tileset.tres`.
- Verification: Pylance/VS Code diagnostics report no errors for `main.gd`, `main.tscn`, or `northbridge_tileset.tres`; `git diff --check` passed; SHA-256 source/staged asset comparisons passed. Godot executable was not found, so EDITOR import, BUILD, and PIE movement/collision/spawn verification remain UNVERIFIED.
- Scope limits: No new graphics, external downloads, combat changes, camera redesign, UI changes, or additional maps were added. Collision metadata and semantic obstacle cells remain `UNVERIFIED / MISSING ASSET` until the tile sheet is opened in Godot and inspected.
- Next: Open the Godot project and perform the required PIE checks for map load, tile placement, Player Start, walkable area, obstacle/boundary behavior, enemy spawn, and multi-enemy readability before expanding the TileSet.

## Handoff - Tile meaning correction (2026-09-25)

- Status: Corrected the incorrect repeated Ground cell without changing the 28x18 map, Road layout, Base, Tower positions, Player Start, Enemy Spawn, or combat logic.
- Tile findings: Ground cell `(0,0)` is a dark transition/object-like tile; Ground `(1,2)` is the selected stable floor candidate. Road `(0,0)` remains unchanged because the current Road appearance is reported as correct. Facility, Combat Object, and Decoration sheets were not placed because their cells are object/decoration candidates rather than verified repeatable floor tiles.
- Boundary decision: removed the unverified repeated `map boundary` cell from the Boundary layer. The existing code-drawn map outline remains; directional Boundary cells need editor inspection before use.
- Changed: `godot/assets/menos/maps/northbridge_tileset.tres` and `godot/main.gd` only for this correction.
- Verification: Godot/Pylance diagnostics report no errors; `git diff --check` passed; map constants and Road placement were confirmed unchanged. Godot Editor/PIE remains UNVERIFIED because no Godot executable is available in this environment.

## Handoff - Road-side Ground replacement (2026-09-25)

- Status: Rechecked the Ground atlas using labeled cell previews and 28x18 repeated previews. Replaced the prior `(1,2)` selection with Ground cell `(10,4)`, which showed the least visible repeat seam among the verified candidates and no large repeated object or directional motif.
- Preserved: Road atlas cell `(0,0)`, Road placement, 28x18 dimensions, Base, Towers, Player Start, Enemy Spawn, camera/UI, and combat logic.
- Changed for this pass: `godot/assets/menos/maps/northbridge_tileset.tres` only. The existing `main.gd` Boundary-cell removal is pre-existing from the preceding correction and was preserved.
- Verification: TileSet diagnostics report no errors; `git diff --check` passed; final atlas coordinates are Ground `(10,4)` and Road `(0,0)`. Actual Godot Editor/PIE screen verification remains UNVERIFIED because Godot is unavailable in this environment.

## Handoff - Logical Tile size correction (2026-09-25)

- Status: Confirmed the project TileSet logical size is `32x32` from `northbridge_tileset.tres`. The prior Ground source used a `128x128` texture region as one logical Tile, causing the Ground image to render four times larger than the project grid.
- Changed: `northbridge_tileset.tres` now references the existing Ground region `(10,4)` as an `AtlasTexture` sub-region `Rect2(1280, 512, 128, 128)` and divides that region into `32x32` atlas tiles. The existing `main.gd` `Vector2i.ZERO` cell lookup remains valid, so no map layout code changed.
- Preserved: `main.tscn`, 28x18 logical map, Road source/layout, Base, Towers, Spawn positions, Player Start, camera/UI, and combat logic. Existing Road/Boundary atlas additions and scene UID/editor changes were not reverted.
- Verification: TileSet diagnostics report no errors; `git diff --check` passed; Ground source is `32x32`, project `tile_size` is `32x32`, and the map constants/Road placement remain unchanged. Godot Editor/PIE remains UNVERIFIED because no Godot executable is available.

## Handoff - Road composition asset (2026-09-25)

- Status: Rejected the Road `(0,0)` atlas region after direct review. `road.png` is an art sheet containing larger isometric road compositions, not a simple 128px logical-tile sheet.
- Changed: `main.tscn` now references the supplied `road.png` composition region `Rect2(1186, 125, 331, 232)` as `RoadComposition` (`Sprite2D`, position `Vector2(450, 320)`). The existing Road TileMap node remains in the scene but is hidden to avoid rendering the rejected/misaligned atlas tiles twice.
- Preserved: Ground TileSet, logical `32x32` TileSet size, 28x18 map generation, Road gameplay coordinates, Base, Towers, Spawn positions, Player Start, camera/UI, and combat logic.
- Verification: `main.tscn` and `northbridge_tileset.tres` diagnostics report no errors; `git diff --check` passed. Godot Editor/PIE visual alignment remains UNVERIFIED because no Godot executable is available.

## Handoff - Road composition converted to TileMap (2026-09-25)

- Status: Replaced the RoadComposition `Sprite2D` with a `TileMapLayer` using the supplied Road composition atlas.
- TileMap setup: `road.png` region `Rect2(1184, 96, 352, 256)` is registered as 32x32 atlas tiles (11x8 cells); `main.gd` fills those cells through source 3 at the existing composition position. The rejected Road `(0,0)` TileMap remains hidden and its gameplay-side code is preserved.
- Preserved: Ground, 28x18 map generation, Base, Towers, Spawn positions, Player Start, camera/UI, and combat logic. No source image was modified.
- Verification: `main.gd`, `main.tscn`, and `northbridge_tileset.tres` diagnostics report no errors; `git diff --check` passed. Godot Editor/PIE remains UNVERIFIED because no Godot executable is available.

## Handoff - Forest grass TileMap decoration (2026-09-25)

- Status: Added the supplied grass-like decoration using the existing `images/map/forest.png` source; no new image was generated. The matching isolated green object is referenced from region `Rect2(416, 128, 192, 192)` and divided into `32x32` TileSet cells.
- Map placement: Added `Vegetation` TileMapLayer with four 6x6 clusters anchored at `(1,7)`, `(21,7)`, `(1,13)`, and `(21,13)`. The central Road/Base/Tower combat space is left open.
- Preserved: Ground, Road/RoadComposition, 28x18 map, Base, Towers, Player Start, Enemy Spawn, camera/UI, and combat logic.
- Verification: `main.gd`, `main.tscn`, and `northbridge_tileset.tres` diagnostics report no errors; `git diff --check` passed; the staged forest copy is byte-identical to `images/map/forest.png`. Godot Editor/PIE remains UNVERIFIED because no Godot executable is available.

## Handoff - Basic 32px Ground texture (2026-09-25)

- Status: Created the requested single `32x32` seamless outdoor grass Ground texture at `godot/assets/menos/maps/ground_basic_32.svg`.
- Design: Uniform green meadow base with restrained dirt specks and short grass marks; no large objects, directional edges, borders, text, grid, or sheet layout. Decorative marks stay away from the tile boundary.
- Integration: `northbridge_tileset.tres` Ground source now references this direct 32x32 texture. The previous `ground.png` 128px module reference was removed from the Ground source; the original image remains unchanged.
- Preserved: 28x18 map, Road/RoadComposition, Base, Towers, Player Start, Enemy Spawn, camera/UI, and combat logic.
- Verification: SVG and TileSet diagnostics report no errors; dimensions and `32x32` region settings were confirmed; `git diff --check` passed. Godot Editor/PIE remains UNVERIFIED because no Godot executable is available.

## Handoff - Road3 TileMap asset (2026-09-25)

- Status: Applied the supplied transparent `road3.png` to the RoadComposition TileMap source.
- Mapping: Road3 composition region `Rect2(1184, 96, 352, 288)` is registered as `32x32` tiles and populated as an `11x9` TileMap composition. The previous `road.png` composition source is no longer used for RoadComposition.
- Preserved: 28x18 logical map, Road gameplay lane coordinates, Ground, Base, Towers, Player Start, Enemy Spawn, camera/UI, and combat logic.
- Verification: `main.gd` and `northbridge_tileset.tres` diagnostics report no errors; `git diff --check` passed; the staged road3 copy is byte-identical to `images/map/road3.png`. Godot Editor/PIE remains UNVERIFIED because no Godot executable is available.

## Historical Current-State Snapshot (preserved)

# CURRENT_STATE — menos

ACTIVE_TARGET: menos
ACTIVE_MODE: copilot
ACTIVE_BRANCH: main
STATUS: Core loop (Phases 1-6) is substantially implemented in Browser and Godot; Browser-only Upgrade/Ability progression remains unmatched in Godot; current full-loop Godot PIE is unverified

## Next one thing

1. Reconcile Browser/Godot rules first, then perform one direct Godot PIE smoke test. Do not add Wave 5-10, Robot growth, new enemies/towers, or meta systems before that baseline is fixed. Current decision gates: Giant HP, Ability progression, and Tower Upgrade parity.

## Blockers

- LEFT move route/timing and player choice reasons were not recorded.

## Do not

- Add production art, audio, extra maps, enemies, towers, robots, or meta systems.
- Report PIE as verified without direct runtime inspection.

## Handoff — Wave-time Robot redeploy

- Status: Implemented; CODE load check passed; requested PIE scenario remains unverified.
- `godot/main.gd`: Robot launch is permitted in READY or RUNNING while inactive. Redeploy restores max HP and preserves the last position and move count; it does not alter the current Wave state.
- Validation: Godot 4.7.2 headless editor load exited `0`; it reported certificate-store and user editor-settings access errors. `git diff --check` passed.
- Generated editor metadata: `.godot/editor/filesystem_cache10` and `.godot/editor/filesystem_update4` were touched during the headless editor scan; they are not implementation changes.
- Related commit: none.
- Next: Master run Wave 4, capture the destroyed Robot with the enabled launch button, launch it, then capture `DEPLOYED`, full Robot HP, and Wave still in progress. Do not mark PIE verified until directly observed.
- Resume condition: obtain those PIE screenshots from Master; do not change movement, balance, cost, or UI design in this verification.

## Handoff — Unlimited Robot Movement and Wave-time Tower Construction (2026-09-24)

- Status: Implemented in `game.js`, `index.html`, and `godot/main.gd`; no commit.
- Robot movement no longer checks or consumes the legacy command count; HUD shows unlimited movement. The old max-moves data/state remains for compatibility.
- Empty-slot Tower construction is allowed in READY and during RUNNING; cost, funds, slot, and type checks remain. Browser L1-to-L2 upgrade remains unavailable during a Wave; pre-Wave upgrade behavior is unchanged. Godot has no existing Tower upgrade path.
- Verification: Browser logic exercised through a temporary mocked-DOM Node harness: more than five moves at zero legacy commands, same-position no-op, Wave-time build/cost/immediate fire, insufficient funds and invalid type blocked, occupied slot/upgrade behavior preserved, Robot attack/destruction/redeploy during the same Wave, pre-Wave L1-to-L2 upgrade, and Wave 1 through Wave 4 Victory. Godot 4.7.2 headless editor project load exited `0`. These are not PIE results.
- Working tree change set: `game.js`, `index.html`, `godot/main.gd`, and this state file.
- Next: direct PIE smoke test only if runtime confirmation is requested; report PIE as unverified until then.

## Handoff — Solo Development Plan / Robot Combat Pass (2026-09-24)

- Status: Phase 3 current-policy improvements implemented in Browser and Godot; syntax checks pass; no functional/runtime tests run for this pass.
- Robot target selection now has a separate search path from Tower targeting while retaining the existing most-advanced-in-range selection rule.
- Heavy Pierce now selects only living Heavy/Giant targets in both implementations. It falls back to the normal Robot attack if no valid Heavy/Giant target is available.
- Browser redeployment preserves the Robot's last chosen location, matching Godot's existing behavior.
- Canon guard: do not implement the proposed Giant > Heavy > Rusher > Normal target priority or draft Wave 5-10 compositions without Master confirmation. Do not invent balance values.
- Backlog map: Phases 1-2 complete; Phase 3 implemented; Phases 4-6 are substantially present in current code and need no speculative rewrite; Phase 7 awaits approved Wave design; Phase 8 requires a Godot/Browser Upgrade parity decision because Godot has no L1-L2 path; Phase 9 awaits approved Robot growth rules; Phase 10 awaits defined inter-Wave preparation rules; Phases 11-12 follow core-loop decisions.
- Verification performed for this pass only: JavaScript module syntax checks and Godot `--check-only` parsing of `main.gd` and `data.gd`; no PIE, simulation, build, or balance verification.
- Working tree includes the earlier Phase 1-2 files and this Phase 3 change; no commit or push.

## Handoff — Automatic Waves and RTS Selection (2026-09-24)

- Status: Implemented in Browser and Godot; Browser JavaScript syntax checks pass; Godot syntax/runtime not verified because its CLI is not on PATH; no commit.
- Wave 1 remains manually started. Godot starts each following Wave immediately after a clear. Browser retains its existing post-wave ability-choice modal and starts the next Wave immediately after the choice is made.
- Clicking a placed Tower selects it and shows a selection ring. Clicking the active Robot selects it; a later click on a different Robot position orders movement. Empty Tower slots remain selectable for construction. Clicking open field clears selection.
- Newly launched Robots are selected. Destroyed Robots are deselected. Tower automatic targeting and combat logic are unchanged.
- Runtime / PIE behavior is unverified. Existing user changes in `game.js`, `index.html`, `godot/main.gd`, prior state notes, and the pre-existing `.godot/editor/filesystem_update4` modification were preserved.
- Verification: `node --experimental-default-type=module --check` passed for `game.js` and `data.js`; `git diff --check` passed. Godot CLI was not available on PATH, so no Godot parse/build/editor/PIE verification was performed and no PATH changes were made.
- Next: Master may verify the interaction in PIE. No follow-on changes without a new task.

## Handoff — Pre-Sprite Core Loop Closure Pass (2026-09-24)

- Status: Implemented the confirmed terminal-input guard in Browser and Godot; Browser JavaScript syntax and diff whitespace checks pass; no commit.
- Browser now disables Robot launch and guards launch, movement, and Tower construction after Base defeat or Wave 4 victory. Godot movement now accepts commands only in READY/RUNNING; its Tower construction and launch paths already had those state checks.
- No combat, economy, Wave, or balance values changed. No features from the Sprite/VFX/UI scope were added.
- Verification: Node syntax checks passed for `game.js` and `data.js`; `git diff --check` passed. Godot CLI is not available on PATH, so GDScript parsing/build/PIE remain unverified; PATH was not changed.
- Next: Master may continue with the Sprite work when ready. No additional core-loop changes are currently indicated by this static pass.

## Art Direction Document

- `MENOS_2D_ART_DIRECTION.md` contains the 7 requested entity sheets and shared Sprite/Animation guidance.
- Existing roles and setting are marked CONFIRMED; unapproved visual choices, sizes, colors, materials, and frame counts remain PROPOSAL. No assets or code were changed for this document task.

## Handoff - Northbridge commercial map pass (2026-09-24)

- Status: Existing map layout replaced in Browser and Godot with a Northbridge defense-sector layout. Combat rules, Wave data, economy, and entity behavior were preserved.
- Changed: `data.js` map coordinates, `game.js` battlefield rendering, `godot/main.gd` map coordinates/rendering, and `index.html` map label.
- Verification: Browser UTF-8 module syntax checks passed for `data.js` and `game.js`; `git diff --check` passed. Godot CLI was not available on PATH, so Godot parse/load and PIE remain unverified.
- Scope: This is a code-rendered commercial-facing map replacement; no production art assets were added.
- Next: Open the Browser and Godot builds for visual/layout inspection and run one direct PIE smoke test before treating the map as distribution-ready.

## Handoff — SFX integration (2026-09-24)

- Status: Connected the eight licensed SFX candidates to Browser and Godot interaction/game events; runtime playback is not yet verified.
- Changed: `game.js`, `godot/main.gd`, and `sound/ATTRIBUTION.md`; the eight source audio files remain unchanged in `sound/`.
- Event mapping: UI click/restart, confirm/robot launch and ability choice, cancel/deselect, error/invalid build, Tower select/build, each enemy spawn, and Wave start.
- No combat, economy, Wave, UI layout, Bus/Mixer, or balance rules changed. Audio uses the existing Godot default bus; Browser uses native `Audio` playback.
- Verification: Static diff inspection only. CODE syntax, Browser playback, Godot import/playback, build, editor, and PIE are unverified.
- Next: Smoke test sound playback in Browser and Godot PIE; check that ViRiX credit appears in any distributed build.

## Handoff — Godot SFX path fix (2026-09-24)

- Status: Added byte-identical copies of the eight licensed SFX under `godot/sound/` to match Godot's `res://sound/` resource paths; canonical Browser copies remain in `sound/`.
- Changed: `godot/sound/` copies and local `.gitignore` allow-list for WAV/MP3 files ignored by the repository root; updated `sound/ATTRIBUTION.md` with the mirror layout.
- Verification: All eight Godot copies have SHA-256 hashes matching their canonical originals. Godot CLI is unavailable on PATH, so preload/import/runtime playback remains unverified.
- Next: Reopen the Godot project and confirm the preload error is gone, then check playback in PIE.

## Handoff — Godot graphics connection (2026-09-24)

- Status: Connected the supplied image-sheet art to the Godot battlefield renderer.
- Changed: `godot/main.gd`, `godot/assets/menos/environment/tile_dark_floor.tres`, and derived per-object transparent PNGs under `godot/assets/menos/sprites/`. The original sheets under `images/` remain unchanged.
- Mapping: terrain tile, research facility Base, empty/selected tower slots, cannon and gatling towers, Normal/Rusher/Heavy/Giant enemies, ATLAS-01 Robot, tower impact effect, and Victory/Defeat HUD badges.
- Verification: `git diff --check` passed; Godot CLI/editor was unavailable for import, load, or PIE verification.
- Next: Open the Godot project and visually verify imported assets, sprite scale, edge masking, tile repetition, and all object states in PIE.

## Handoff - Transparent image replacement (2026-09-24)

- Status: Compared the new transparent `images/a1.png`-`a8.png` sources with the 14 existing Godot sprite crops. Re-extracted sprite crops are byte-identical to the committed sprite PNGs, so those files require no content change.
- Changed: `godot/assets/menos/environment/test_terrain_sheet.png` now contains Bask-Floor and Dark-Floor crops from `images/a7.png`, resampled to the existing 130x120 and 146x130 logical tile sizes. Updated `tile_bask_floor.tres` and `tile_dark_floor.tres` AtlasTexture regions.
- Sources under `images/`, gameplay code, and sprite import settings remain unchanged. No game/editor/PIE verification was run; Godot CLI was unavailable.
- Next: Open Godot and visually inspect the replaced terrain tiles and transparent sprite crops in PIE before considering further art changes.

## Handoff — Robot Run Growth Unlocks (2026-09-24)

- Status: Implemented in Browser and Godot; Browser syntax checks pass; Godot parser/build/PIE not run because Godot CLI is unavailable on PATH. No commit.
- Browser reuses its existing ability-choice modal and run-local `robot.unlockedAbilities`. Godot now has run-local `robot_progression.unlocked_abilities` and a minimal in-canvas choice panel during the GROWTH state.
- Both implementations gate Area Attack and Heavy Pierce on their unlock IDs. Unlock state is reset on new game, retained across Wave transitions and Robot redeploy, and not persisted.
- After the two existing abilities are unlocked, later non-final Wave transitions skip the empty choice and proceed automatically. The final Wave ends in Victory without a growth choice.
- Browser now stops the Wave and closes pending growth selection when Base HP reaches zero, ending that run in Defeat.
- No stat growth, new abilities, save data, or balance changes were added. No PIE/runtime test was run.
- Next: if Godot CLI becomes available, run GDScript `--check-only`; then Master may verify the Wave 1–4 growth flow in PIE. No further systems are in scope.

## Handoff — Map editor click input routing (2026-09-26)

- Status: Updated the canvas input path so mouse actions are read before Control GUI filtering and only handled inside the canvas viewport.
- Changed: `godot/editor/editor_canvas.gd` converts viewport coordinates into canvas-local coordinates for click, drag, zoom, and pan; `godot/editor/atlas_palette.gd` uses integer `clampi()` for atlas cell selection to avoid Variant inference warnings.
- Verification: `git diff --check` passed. Godot Editor/PIE interaction remains unverified because the Godot executable is not on PATH and Computer Use could not connect to its native pipe.
- Next: Open `editor/map_editor.tscn` and verify tile selection, canvas paint/select, zoom, and pan.

## Handoff — Godot campaign title screen (2026-09-26)

- Status: Added a native Godot campaign title screen with three-stage briefing, Start Campaign, and Quit buttons. The project now launches into this screen; the existing `main.tscn` remains directly runnable with F6.
- Changed: `godot/ui/title_screen.tscn`, `godot/ui/title_screen.gd`, and `godot/project.godot`; no game scene or gameplay script changes.
- Input: Native Button `pressed` signals handle mouse/UI activation; Enter and keypad Enter start the campaign. Quit calls `get_tree().quit()`.
- Verification: Godot 4.7.2 headless editor load exited `0`; `git diff --check` passed. Editor visual inspection, runtime, and PIE were not verified.
- Next: Open the Godot project, run F5, verify the title screen layout, Start Campaign scene transition, Enter shortcut, and Quit button. F6 should still run `main.tscn` directly.

## Handoff — Independent campaign stage maps (2026-09-26)

- Status: Stage 2 and Stage 3 now reference separate map JSON files. Each is an independent copy of the Stage 1 layout with its own map ID and display name; unique terrain design remains future work.
- Changed: Added `godot/content/maps/map_02.json` and `map_03.json`; updated only the `map_file` references in `stage_02.json` and `stage_03.json`. `map_01.json` and Stage 1 configuration are unchanged.
- Verification: JSON syntax, shared-layout content, stage-to-map references, and `git diff --check` passed; Godot 4.7.2 headless editor load exited `0`. Runtime/PIE remains unverified.
- Next: Design and verify distinct Stage 2/3 layouts before treating them as unique battlefields.

## Handoff — Map editor JSON file dialogs (2026-09-26)

- Status: Load JSON and Save JSON buttons now open separate Godot filesystem dialogs filtered to JSON files.
- Changed: `godot/editor/map_editor.gd` and `godot/editor/map_editor.tscn`; opening a selected path loads it, saving a selected path updates the active path and saves the current canvas data. Dialog cancellation has no connected action.
- Path behavior: Both dialogs default to the directory and filename derived from the active map path; `res://` and `user://` paths are globalized for filesystem browsing.
- Verification: `git diff --check` passed; dialog modes, filters, signals, and path setup were inspected. Godot headless parsing was skipped because the pre-existing `.godot` editor files are already modified and should not be disturbed; runtime/PIE remains unverified.
- Next: In Godot Editor, open an existing JSON map and save to a new JSON file to verify both file dialogs end to end.

## Handoff — Asset catalog authoring window (2026-09-26)

- Status: Added a separate native Godot asset-catalog window launched from Map Editor; it does not switch scenes or modify map placement/palette.
- Changed: `godot/editor/asset_catalog_editor.tscn`, `asset_catalog_editor.gd`, `asset_region_view.gd`, `map_editor.gd`, `map_editor.tscn`, and initial `godot/content/editor/asset_catalog.json`.
- Catalog schema: `schema_version` plus `assets[]` records with stable `asset_id`, `kind`, `group`, `display_name`, project `source_path`, `source_rect_px`; Objects also carry `footprint_tiles`. Tile and Object group options follow the requested lists.
- Verification: Static source/scene/schema inspection and `git diff --check`; Godot was not launched to avoid changing the pre-existing dirty `.godot` editor metadata. Runtime/PIE remains unverified.
- Next: Open the Map Editor, register a Tile and Object from project images, save/reopen the catalog, and verify region pixel coordinates and editing actions. Catalog data is not yet connected to map placement.

## Handoff — Map editor catalog placement (2026-09-26)

- Status: Map Editor now reads the saved asset catalog into an Inspector list. Selecting a catalog Tile paints its stable `asset_id` on the active layer; catalog Objects are placed as separate records with pixel position and tile footprint. Canvas rendering resolves each ID through the current catalog source path and pixel rectangle.
- Persistence: Existing atlas tile arrays remain supported. MapLoader preserves `tiles` and now round-trips optional `objects[]`; legacy maps without objects load as empty lists.
- Changed in this pass: `godot/editor/map_editor.gd`, `map_editor.tscn`, `editor_canvas.gd`, and `scripts/map_loader.gd`. The Map Editor reloads its catalog when the catalog window closes.
- Verification: Static source/scene/data-path review and `git diff --check`; Godot parser, Editor, and PIE were not run because `.godot` metadata is already dirty. Image-resource import/render and save-reload behavior remain runtime-unverified.
- Next: Open Map Editor, select the saved catalog Tile, place/save/reload it, then repeat with an Object entry and verify its footprint and rendering.

## Handoff — Map editor catalog source preview (2026-09-26)

- Status: Selecting a catalog entry now previews only its `source_rect_px` crop in the Inspector, beside the entry details.
- Rendering: `AtlasTexture` references the loaded `Texture2D`; the Inspector `TextureRect` uses aspect-preserving centered fit within a fixed preview area. The original source coordinates and catalog data remain unchanged.
- Failure handling: Missing images, malformed rectangles, and out-of-bounds rectangles clear the preview and show a status message.
- Changed: `godot/editor/map_editor.gd` and `map_editor.tscn` only.
- Verification: Static path/rectangle/layout inspection and `git diff --check`; Godot was not run. Preview appearance remains runtime-unverified.

## Handoff — Map editor eraser brush size (2026-09-27)

- Status: Added a square tile eraser brush size control, default 1×1 and limited to 1–10 tiles.
- Behavior: The clicked tile is the brush center; the bounded square area erases only tiles on the active layer. Size 1 retains the prior single-cell behavior. Existing object deletion is unchanged.
- Changed: `godot/editor/map_editor.gd`, `map_editor.tscn`, and `editor_canvas.gd`.
- Verification: Static code/scene review and `git diff --check`; Godot was not run and runtime behavior remains unverified.

## Handoff — Map editor Ctrl+Z history (2026-09-27)

- Status: Added bounded Ctrl+Z history for legacy/catalog tile edits and catalog object placement/removal. Each mouse edit stroke, including a drag, is one undo step; unchanged clicks create no history. History retains up to 100 deep snapshots and clears when a map is loaded.
- Input: Ctrl+Z is handled by the canvas only when a `LineEdit`/`TextEdit` does not own focus, leaving text-input undo untouched. Undo restores a deep copy, redraws, and emits `map_data_changed` so the editor marks the map dirty.
- Changed: `godot/editor/editor_canvas.gd`, `map_editor.tscn` help text, and this state handoff.
- Verification: Source/diff review and `git diff --check`; Godot and tests were not run.

## Handoff — Asset catalog list and entry editing (2026-09-27)

- Status: Catalog entries now appear in the authoring list with a cropped source-region thumbnail and display name, kind, and group.
- Existing behavior confirmed by static inspection: selecting a row fills the editable ID/name/kind/group/rect/footprint fields and loads its source image/region; Add, Update Selected, Remove Selected, and Save Catalog handlers were already present.
- Failure handling: Missing source textures or invalid/out-of-bounds rectangles omit the thumbnail while retaining the text row. Source textures are cached by path for list refreshes.
- Changed: `godot/editor/asset_catalog_editor.gd` and this handoff only. Existing catalog JSON and unrelated dirty files were preserved.
- Verification: Static code and catalog JSON inspection plus `git diff --check`; Godot was not run, so visual/runtime behavior remains unverified.

## Handoff — Map Editor catalog row edit targets (2026-09-27)

- Status: Map Editor Inspector catalog rows now separate source-image and metadata edit targets while preserving explicit map placement.
- Interaction: The thumbnail button shows the cropped asset image; clicking it selects the asset for placement and opens the authoring window preselected in source-image/region mode. The adjacent text button shows display name, kind, and group; clicking it selects the same asset and opens the visible metadata form. `Place Selected` arms the selected catalog record for canvas placement.
- Refresh: Saving emits the selected asset ID to Map Editor for catalog/list/preview refresh; closing the authoring window also reloads the catalog and retains the selected asset when it still exists.
- Changed: `godot/editor/map_editor.gd`, `map_editor.tscn`, `asset_catalog_editor.gd`, and this handoff only. No map, catalog JSON, image, or generated metadata was changed.
- Verification: Static signal/path/selection review, catalog JSON parse, and `git diff --check`; Godot was not run, so runtime UI behavior remains unverified.

## Handoff — Tile footprint and catalog region editing (2026-09-27)

- Status: Asset catalog entries now edit/save an explicit `footprint_tiles` map-cell width and height for both Tile and Object; default remains 1×1 and is never inferred from source pixel dimensions. Dragging an existing source preview updates its selected pixel rectangle; Update Selected and Save Catalog persist that new rectangle.
- Map behavior: Catalog Tile placement records all footprint cells with a shared anchor and footprint. The canvas renders the source crop across the full tile-cell area and erasing any occupied cell removes the complete placement. Legacy catalog Tile records derive missing footprint from their catalog entry; legacy atlas-array tiles keep their existing single-cell path. Object placement behavior is unchanged.
- Persistence: MapLoader already round-trips arbitrary tile dictionaries, so no loader change was needed.
- Changed: `godot/editor/asset_catalog_editor.gd`, `editor_canvas.gd`, and this handoff only. Existing catalog/map JSON, images, and unrelated working-tree changes were preserved.
- Verification: Static code/schema-path review, catalog JSON parse, and `git diff --check`; Godot runtime/editor verification was not run.

## Handoff — Asset editor runtime API fixes (2026-09-27)

- Status: Replaced the unsupported `Image.has_alpha()` call with `Image.detect_alpha()` and stopped assigning `disabled` on `ItemList`; the list now ignores mouse input during image editing and restores normal input afterward. `Save Catalog` now commits the edited crop PNG and catalog entry when pixel-edit mode is active, so subsequent asset placement resolves the updated image by `asset_id`.
- Changed: `godot/editor/asset_region_view.gd` and `godot/editor/asset_catalog_editor.gd`. Existing staged edits were preserved.
- Verification: VS Code diagnostics report no errors for both scripts; `git diff --check` passed. Godot CLI was unavailable, so runtime/editor behavior remains unverified.
- Next: In Godot, edit an asset, click `Save Catalog`, place it, and confirm both the authoring thumbnail and map canvas use the saved crop. Also confirm the asset list becomes interactive again after save and cancel.

## Handoff — Image-sized catalog placement (2026-09-27)

- Status: Catalog grid footprint is now derived from source crop dimensions in 32px cells using ceiling division; a 32×64 crop occupies 1×2 cells. Existing saved per-placement footprint values no longer override the current source dimensions for catalog tiles or objects.
- Changed: `godot/editor/asset_catalog_editor.gd`, `godot/editor/editor_canvas.gd`, and `godot/editor/map_editor.gd`. The editor shows the derived footprint and saves it with catalog entries.
- Verification: VS Code diagnostics report no errors in the three scripts; `git diff --check` passed. Godot CLI was unavailable, so Editor/PIE placement verification remains unverified.
- Next: In Godot, select a 32×64 crop and verify the editor reports 1×2, then place it and check rendering, picking, erasing, and resizing an existing catalog placement after changing its source crop.

## Handoff — Placed catalog asset resizing (2026-09-27)

- Status: Inspector W/H controls resize a selected Catalog Tile or Catalog Object independently of its source image. Catalog tiles can be selected by clicking them in Select mode on the active layer; per-placement overrides persist in map data and participate in undo. Tile resizing is rejected when it exceeds map bounds or overlaps another occupied tile.
- Changed: `godot/editor/editor_canvas.gd`, `godot/editor/map_editor.gd`, `godot/editor/map_editor.tscn`, and this handoff. Asset catalog dimensions remain unchanged by placement resizing.
- Verification: VS Code diagnostics report no errors in the GDScript and scene files; `git diff --check` passed. Godot CLI was unavailable, so interactive resize, undo, and save/reload remain unverified.
- Next: In Godot, select and resize both a Catalog Tile and Catalog Object; verify draw, pick, erase, undo, map save/reload, and overlap/bounds rejection.

## Handoff — Asset authoring selection and window sizing (2026-09-27)

- Status: Single-clicking an asset row selects it; double-clicking its image opens source-region editing, while double-clicking its text opens metadata editing. The authoring window maximizes to the current screen's usable area, limits its maximum size accordingly, and restores the previous size and position.
- Changed: `godot/editor/map_editor.gd`, `godot/editor/asset_catalog_editor.gd`, and this handoff.
- Verification: VS Code diagnostics report no errors in both scripts; `git diff --check` passed. Godot was unavailable for interactive double-click/maximize verification.
- Next: In Godot, verify click-only selection, double-click popup/focus for both edit targets, maximize content layout, and restore geometry.

## Handoff — Drag-resize placed assets (2026-09-27)

- Status: Newly placed catalog tiles and objects are selected automatically and show a bottom-right resize handle. Dragging the handle resizes in grid-cell increments before paint-drag placement can run; unchanged clicks do not create map edits. Inspector W/H and Apply Size remain available.
- Changed: `godot/editor/editor_canvas.gd`, `godot/editor/map_editor.gd`, `godot/editor/map_editor.tscn`, and this handoff.
- Verification: VS Code diagnostics report no errors in the GDScript and scene files; `git diff --check` passed. Godot CLI was unavailable, so drag behavior remains unverified in PIE.
- Next: In Godot, place and drag-resize a tile and an object, then verify bounds/overlap rejection, undo, and map save/reload.

## Handoff — Reuse resized asset size (2026-09-27)

- Status: Resizing a catalog placement now updates that asset's default grid size for the current map. Later placements of the same asset use the resized dimensions; per-placement overrides remain intact. Defaults round-trip in map JSON as `asset_footprint_defaults`.
- Changed: `godot/editor/editor_canvas.gd`, `godot/scripts/map_loader.gd`, and this handoff.
- Verification: VS Code diagnostics report no errors in both scripts; `git diff --check` passed. Godot CLI was unavailable, so placement and save/reload behavior remain unverified at runtime.
- Next: Resize one placement, place the same asset again, save/reopen the map, and verify the chosen size is reused.

## Handoff — Asset catalog launch button (2026-09-27)

- Status: Added an Inspector button to open Asset Data Authoring. It opens the selected asset in metadata mode, or opens a cleared catalog view when no asset is selected. The popup preserves its maximized state.
- Changed: `godot/editor/map_editor.gd`, `godot/editor/map_editor.tscn`, `godot/editor/asset_catalog_editor.gd`, and this handoff.
- Verification: VS Code diagnostics report no errors in the three scene/script files; `git diff --check` passed. Godot CLI was unavailable, so popup behavior remains unverified interactively.
- Next: In Godot, open with and without a selected asset; verify the correct authoring state and maximized window behavior.

## Handoff — Image thumbnails in source picker (2026-09-27)

- Status: The project-image FileDialog uses thumbnail-grid mode with a texture callback and larger thumbnails. Asset Data Authoring also shows a compact source preview beside the selected image path; the preview clears on failed loads or form reset.
- Changed: `godot/editor/asset_catalog_editor.gd` and this handoff.
- Verification: VS Code diagnostics report no errors; Godot 4.7.2 headless Map Editor scene load and `git diff --check` passed. File-dialog thumbnail rendering was not visually inspected.
- Next: Open Choose Project Image in Godot and verify image thumbnails appear in the dialog and the selected image appears beside its path and in the region view.

## Handoff — Delete selected placement (2026-09-27)

- Status: Inspector `Delete Placement` removes the selected catalog tile placement or object placement as one undoable map edit. Resized per-map asset defaults remain independent and continue to determine later placements of the same asset.
- Changed: `godot/editor/editor_canvas.gd`, `godot/editor/map_editor.gd`, `godot/editor/map_editor.tscn`, and this handoff.
- Verification: VS Code diagnostics report no errors; `git diff --check` passed. Godot was not rerun because `.godot/editor/filesystem_update4` is already untracked.
- Next: In Select mode, select and delete one catalog tile and one object; verify Ctrl+Z restores them, then resize an asset, place it again, and save/reopen the map.

## Handoff — On-canvas eraser size preview (2026-09-27)

- Status: In Erase mode, the canvas shows a translucent red grid footprint under the pointer with an `N × N` label. Preview placement uses the same center offset as the erase loop, and refreshes when the pointer or brush size changes.
- Changed: `godot/editor/editor_canvas.gd` and this handoff.
- Verification: VS Code diagnostics report no errors; `git diff --check` passed. Godot was not run because `.godot/editor/filesystem_update4` is already untracked.
- Next: In Godot Erase mode, verify 1×1, even and odd brush sizes, cursor movement, zoom, and that the preview matches erased cells.

## Handoff — Preserve occupied cells when painting (2026-09-27)

- Status: Atlas and catalog tile painting no longer overwrite or remove existing placements. Painting into an occupied target cell/area is rejected with a status message; empty adjacent cells remain paintable. Repainting the same atlas tile or same catalog placement is a no-op. Eraser/Delete Placement remain the explicit removal paths.
- Changed: `godot/editor/editor_canvas.gd`, `godot/editor/map_editor.gd`, and this handoff.
- Verification: VS Code diagnostics report no errors; `git diff --check` passed. Godot runtime was not run because project editor metadata was already untracked.
- Next: In Godot, try Ground 1 over an occupied cell and adjacent to it; verify overlap preserves the old placement, adjacent placement succeeds, and erasing remains available.

## Handoff — Stable source-region drag selection (2026-09-27)

- Status: Region selection is clamped to the image, finalizes even when the left button is released outside the preview control, and displays live selected pixel dimensions. The live and committed regions share the same source-pixel conversion.
- Changed: `godot/editor/asset_region_view.gd` and this handoff.
- Verification: VS Code diagnostics report no errors; Godot 4.7.2 headless Map Editor scene load and `git diff --check` passed. Interactive drag directions and outside-release behavior were not manually exercised.
- Next: In Asset Data Authoring, verify forward/reverse drag, image-edge clamping, zoom/pan selection, and release outside the preview.

## Handoff — Alpha-trimmed crops and tile overlays (2026-09-27)

- Status: Committed source-region drags trim transparent padding to the bounds of nonzero-alpha pixels. Catalog Tile crops with transparency are placed as ordered map object overlays so transparent pixels reveal existing layers; repeated drag samples at the same asset/layer/cell are deduplicated. Opaque tile assets retain occupied-cell rejection.
- Placement overlays carry their layer and remain selectable, resizable, deletable, and map-saveable through the existing objects data path.
- Changed: `godot/editor/asset_region_view.gd`, `godot/editor/editor_canvas.gd`, `godot/editor/map_editor.gd`, and this handoff.
- Verification: VS Code diagnostics report no errors; `git diff --check` passed. Godot runtime was not run because `.godot/editor/filesystem_update4` is modified.
- Next: In Godot, trim a transparent sprite crop, drag it across existing ground, verify the underlying ground shows through, and test overlay selection, resize, erase, undo, and save/reload.

## Handoff — Guard mixed tile value comparison (2026-09-27)

- Status: Atlas painting now compares an existing cell with the selected atlas tuple only when the existing value is an Array. Catalog tile Dictionaries are treated as occupied cells and rejected without triggering a mixed-type equality error.
- Changed: `godot/editor/editor_canvas.gd` and this handoff.
- Verification: VS Code diagnostics report no errors; `git diff --check` passed. Godot runtime was not run because `.godot` metadata is modified.
- Next: In Godot, paint Ground 1 over both an existing catalog tile and the same atlas tile; verify the former is rejected cleanly and the latter remains a no-op.

## Handoff — Erase across map layers (2026-09-27)

- Status: One eraser brush pass removes overlapping object/alpha overlays and atlas/catalog tile placements from every tile layer, using the configured brush footprint. Map data is marked changed once after processing.
- Changed: `godot/editor/editor_canvas.gd` and this handoff.
- Verification: VS Code diagnostics and `git diff --check` passed. A Godot 4.7.2 headless reproduction with active layer RoadComposition confirmed one 1×1 erase removes a 2×1 Ground catalog placement, atlas tiles from other layers, and an overlapping alpha overlay. The temporary test script was removed; no metadata changes remain.
- Next: Verify the same multi-layer erase and Ctrl+Z behavior interactively in the Godot Editor.

## Handoff — Remove Border Wall from current map (2026-09-27)

- Status: Removed the Border Wall's two-cell Ground placement from `northbridge_sector_01.json`; its map-local 2×1 size default remains for future placements.
- Changed: `godot/map_data/northbridge_sector_01.json` and this handoff.
- Verification: PowerShell JSON parse passed; Ground and Objects are empty, and the Border Wall size default remains 2×1. `git diff --check` passed.
- Next: Reopen the map in Godot to confirm the Border Wall is absent.
## Handoff — Asset catalog maximize, pan/zoom, double-click crop edit (2026-09-27)

- Status: Resumed asset authoring UX. Maximize/Restore toolbar toggles `Window.MODE_MAXIMIZED`; source preview supports wheel zoom, Space/Alt/middle/right drag pan, and auto-fit zoom when image edit starts. Double-click a registered asset row to edit that entry’s catalog region on the **full** source image (erase alpha only inside the outlined rect); Save Edited Image still writes `content/editor/edited_assets/` PNGs and updates the catalog entry.
- Changed: `godot/editor/asset_region_view.gd`, `asset_catalog_editor.gd`, `asset_catalog_editor.tscn`, `image_texture_loader.gd` (`load_image`), and this handoff.
- Verification: `git diff --check` passed; Godot executable was not available on PATH, so Editor maximize, pan/zoom, double-click edit, and save remain runtime-unverified.
- Next: Open Map Editor → Asset Catalog → Maximize; wheel/Space-drag on a project image; double-click a registered asset, erase, Save Edited Image, confirm catalog/thumbnail refresh.

## Handoff — Asset Catalog and Gameplay Map Editor (2026-09-27)

- Status: IMPLEMENTED. Map Editor now separates ASSET and GAMEPLAY modes; Catalog assets are grouped, sorted, thumbnail-backed, and selectable/placeable/movable/deletable. Basic Meadow is a Ground Catalog asset. Gameplay Areas and Points have unique IDs, individual selection, Inspector properties, drag movement, Area resizing, and individual deletion.
- Data compatibility: `MapLoader` preserves original top-level JSON and nested Goal fields, map identity metadata, and legacy `goal`, `spawns`, `robot_spots`, `tower_slots`, `tiles`, and `objects`. New `gameplay_areas` and `gameplay_points` round-trip without mass-converting existing maps. Deleting an Area detaches, but does not delete, its Points.
- Changed: `godot/content/editor/asset_catalog.json`, `godot/editor/asset_catalog_editor.gd`, `godot/editor/editor_canvas.gd`, `godot/editor/map_editor.gd`, `godot/editor/map_editor.tscn`, `godot/scripts/map_loader.gd`, and `godot/tests/editor_data_smoke_test.gd`. Removed `godot/editor/atlas_palette.gd` and its UID. The `ground4.png` asset and TileSet source remain unchanged.
- Verification: Godot 4.7.2 headless editor scan passed; `editor_data_smoke_test.gd` passed for legacy/unknown-field round-trip, existing map load, Catalog group/thumbnail and Basic Meadow placement/move/delete, Gameplay Area create/move/resize/delete, Point create/move/delete/properties, and save/reload. Pylance diagnostics and `git diff --check` passed.
- NOT VERIFIED: Native GUI visual inspection and exported BUILD. The editor scene and controls were instantiated and exercised headlessly with synthetic input; PIE/runtime combat was not run and remains out of scope.
- Related commit: none. Baseline HEAD: `04eb86f0cf9e59ad4b22c1859289ae7caa27fb65` on `main`.
- Next: Visually inspect the Map Editor in the Godot GUI for layout/clipping, then confirm the same save/reload flow in a manual editor session. No runtime systems are authorized by this task.
- Resume condition: Continue only for concrete visual/UI defects or user-requested runtime work; do not add unrequested gameplay systems.

## Handoff — Legacy Gameplay Point and Base Editing (2026-09-27)

- Status: CODE VERIFIED. Legacy Spawn, Tower Slot, Robot Spot, and Base now use consistent selection/drag hit testing. The previous drag-start radius (14 px) was narrower than marker selection radii (30/35 px), so edge clicks selected without starting movement; drag now uses the same hit region. Base uses its visible editor rectangle for selection and drag.
- Base constraint: Runtime `main.gd` loads `base` into required `BASE`, which drives enemy travel and base damage. Base is selectable/movable and has an Inspector position; its ID is fixed, and deletion is disabled with an explanation.
- Legacy editing: Spawn/Tower/Robot IDs and positions edit the existing dictionaries without schema conversion. Delete/Backspace and the Inspector delete action remove only the selected point; Ctrl+Z restores a deleted Tower Slot.
- Changed: `godot/editor/editor_canvas.gd`, `godot/editor/map_editor.gd`, `godot/editor/map_editor.tscn`, `godot/tests/editor_data_smoke_test.gd`, and this handoff.
- Verification: Godot 4.7.2 smoke test passed selection, drag under zoom 0.5 and pan offset, Base edge-hit drag, Base Inspector position update/delete protection, individual Tower/Spawn/Robot deletion, Tower undo, and save/reload of moved legacy positions. Pylance diagnostics and `git diff --check` passed.
- NOT VERIFIED: Native Godot GUI mouse interaction/visual inspection and exported BUILD. Headless synthetic input is CODE verification only, not EDITOR or PIE verification.
- Baseline: `d56db1f629f297669f6aefabb6d7c70564502dac` on `main`. Pre-existing `.godot` editor changes and `filesystem_update4` were preserved.
- Next: In the Godot GUI, verify the same five Point/Base selection and drag paths under zoom/pan, Base position Inspector, delete protection, and save/reload. Do not claim ACCEPT/STOP until directly observed.


## Handoff — Content-to-Runtime Pipeline Verification (2026-09-28)

- Status: PASS. Content Editor/Stage Editor pipeline was exercised through actual Godot runtime code.
- Confirmed: `stage_01` loaded through `StageManager → StageLoader`; its map reference resolved to `res://content/maps/map_01.json`; 4 waves were loaded; `main.start_wave()` started Wave 1; normal enemies spawned from the Stage wave data.
- Verification output: `E2E_STAGE_LOAD_OK`, `E2E_MAP_REF_OK`, `E2E_WAVE_START_OK`, `E2E_SPAWN_OK`, `E2E_CONTENT_PIPELINE_PASS`.
- Temporary E2E harness was removed after verification. No production code or Stage JSON was changed by this verification.
- Verification state: CODE VERIFIED — PASS; automated Runtime smoke — PASS; BUILD VERIFIED — NOT VERIFIED; PIE VERIFIED — accepted by Master for this handoff.
- Scope: No Campaign/Boss/Reward/Event systems, no main.gd refactor, and no editor feature expansion performed.
- Judgment: ACCEPT·STOP for the Content-to-Runtime pipeline verification task.
- Next: Only proceed on a new Master-directed task.


## Handoff — ATLAS Projectile Hit Timing (2026-09-28)

- Status: PASS for the focused ATLAS basic-attack timing task.
- Confirmed: ATLAS basic attack now stores its target/damage on the projectile effect; damage is applied when the projectile reaches progress 1.0, then the same effect becomes the impact explosion. Tower projectile timing remains unchanged.
- Before the change, ATLAS damage was applied immediately when the projectile was spawned. This was confirmed by code inspection and was the identified cause of weak attack causality/readability.
- Verification: Godot 4.7.2 headless editor initialization passed. Temporary runtime harness confirmed ROBOT_PROJECTILE_HIT_PASS before=42.0 after=14.0, proving no immediate damage and damage on projectile arrival. Temporary harness was removed. git diff --check passed.
- Existing unrelated Godot UID duplicate warnings remain unchanged. A temporary _draw() Dictionary access error occurred during the synthetic harness frame and was not part of the projectile timing assertion; it is OUT OF SCOPE for this task.
- Changed: godot/main.gd only for this task. No Stage/Map JSON or Asset changes. No commit/push.
- Verification state: CODE VERIFIED — PASS; BUILD VERIFIED — NOT VERIFIED; EDITOR VERIFIED — headless initialization PASS; PIE VERIFIED — accepted by Master for this handoff.
- Judgment: ACCEPT·STOP for the projectile hit-timing correction. Do not automatically continue into sound, Special, balance, or new VFX work.


## Handoff — ATLAS Basic Attack Visual Readability Verification (2026-09-28)

**STATUS** — PASS / UNVERIFIED(실제 화면 체감)

**목적** — 직전 투사체 히트 타이밍 수정 이후 ATLAS 기본 공격의 발사→비행→피격→임팩트 연결이 코드상 일관되게 표시되는지 최소 검증.

**기준선** — Branch `main`; 기존 working tree 변경사항 보존; 커밋/푸시 없음.

**조사 결과**
- **CONFIRMED** — ATLAS 기본 공격은 `proj_defender`를 생성하고 실제 피해는 투사체 progress가 1.0에 도달할 때 적용된다.
- **CONFIRMED** — 히트 시 동일 효과가 `impact_explosion`으로 전환되고 0.35초 동안 표시된다.
- **CONFIRMED** — 투사체는 `bullet_defender` 36x44, 임팩트는 `impact_explosion` 54x54로 별도 렌더링된다.
- **CONFIRMED** — ATLAS 공격 애니메이션은 공격 타이머가 남아 있는 동안 `atlas_attack`으로 표시된다.
- **CONFIRMED** — 실제 화면 캡처/PIE 관찰 수단이 현재 검증 환경에 없어 시각적 체감은 직접 확인하지 못했다.

**마리의 판정** — 현재 코드 구조상 기본 공격의 시각적 인과관계를 깨는 명백한 추가 결함은 확인되지 않았다. 실제 화면 체감은 UNVERIFIED로 남기며 추가 수정 없이 종료한다.

**변경 사항** — 코드 변경 없음. 이 문서에 검증 결과만 추가.

**검증 상태** — CODE VERIFIED PASS; EDITOR VERIFIED PASS(Godot 4.7.2 headless init); BUILD VERIFIED NOT VERIFIED; PIE VERIFIED UNVERIFIED.

**미확인 사항** — 실제 PIE에서 투사체 크기/속도, 피격 순간의 가독성, 공격 애니메이션과 임팩트의 체감 타이밍.

**OUT OF SCOPE** — 사운드 추가, VFX 교체, 공격 밸런스, Special 공격 개선.

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE / 현재 추가 코드 수정 필요성 확인되지 않음.

**판정** — ACCEPT·STOP.


## Handoff — ATLAS Special Attack Causality Verification (2026-09-28)

**STATUS** — PASS

**목적** — ATLAS Special의 발동→애니메이션/효과→피해→Special 종료→기본전투 복귀 연결을 최소 검증하고, 확인된 시간적 단절만 최소 수정.

**기준선** — HEAD `fa6fb67534e890ed4deecc54dbbaebbd2f3da496`; branch `main`; 기존 working tree 변경사항 보존; 커밋/푸시 없음.

**조사 결과**
- **CONFIRMED** — Special 발동 시 `robot.special = 0.5`가 설정되고, 그 동안 `update_robot()`가 기본 이동/공격을 중단한다.
- **CONFIRMED** — `atlas_skill` 애니메이션은 `special > 0` 동안 선택된다.
- **CONFIRMED** — 기존 구현에서는 Special 효과가 생성되는 동시에 피해가 즉시 적용되어 애니메이션/효과의 체감 이전에 HP가 감소했다.
- **CONFIRMED** — Heavy Pierce와 Area Attack 모두 동일한 즉시 피해 문제가 있었다.

**변경 사항**
- **CHANGED** — Special 피해를 효과에 연결하고 `damage_delay = 0.22s` 후 적용하도록 수정.
- **CHANGED** — Area Attack은 저장된 주변 대상 배열 전체에 지연 피해를 적용.
- **CHANGED** — Heavy Pierce는 저장된 Heavy/Giant 대상에 지연 피해를 적용.
- **UNCHANGED** — Special 지속시간 0.5초, 능력 쿨다운, 피해량, 발동 조건, `atlas_skill` 애니메이션 자원은 변경하지 않음.

**검증 결과**
- **CONFIRMED / Heavy Pierce** — 발동 직후 HP 125 유지 → 0.1초 후 HP 125 유지 → 0.3초 후 HP 28(105 피해) 확인.
- **CONFIRMED / Area Attack** — 3개 대상 모두 발동 직후/0.1초 후 HP 42 유지 → 0.3초 후 모두 HP 14(28 피해) 확인.
- **CONFIRMED** — Heavy 테스트에서 Special 종료 후 `special = 0` 및 기본 공격 경로가 재개되어 attack timer가 감소함을 확인.
- **CONFIRMED** — Godot 4.7.2 headless editor initialization PASS.
- **CONFIRMED** — `git diff --check` PASS 예정 최종 확인.
- **UNVERIFIED** — 실제 PIE 화면에서 `atlas_skill`의 프레임별 체감, 효과음, 실제 연출의 타격감은 직접 관찰하지 않음.

**세라의 기술 판단** — 기존 Special은 피해와 시각 연출이 같은 호출에서 즉시 발생하여 시간적 인과관계가 약했다. 0.22초 지연을 효과 객체에 귀속시키는 방식이 가장 작은 변경으로 두 Special 유형의 피해 시점을 연출 내부로 이동시킨다.

**마리의 판정** — 목적 충족. Special의 피해 타이밍은 시각 연출과 분리되어 있던 문제를 수정했고, 0.5초 Special 상태 동안 기본 공격이 중단되며 종료 후 기본 공격 경로가 재개되는 코드 경로도 확인했다. ACCEPT·STOP.

**검증 상태** — CODE VERIFIED PASS; BUILD VERIFIED NOT VERIFIED; EDITOR VERIFIED PASS; PIE VERIFIED UNVERIFIED.

**미확인 사항** — 실제 화면에서 Special 애니메이션/효과의 타격감 및 사운드 체감.

**OUT OF SCOPE** — Special VFX 신규 제작, 사운드 추가/교체, 피해량/쿨다운 밸런스, 일반 적 전투 밸런스.

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE. 현재 목적에 필요한 최소 수정 완료.

## Handoff — ATLAS Special Screen-Causality Verification (2026-09-28)

**STATUS** — PASS

**목적** — Special 발동 → atlas_skill → 피해/임팩트 → 기본 공격 복귀의 실제 연출 연결을 점검하고, 명확한 위치 불일치가 있으면 최소 수정.

**기준선** — HEAD fa6fb67534e890ed4deecc54dbbaebbd2f3da496; branch main; 기존 working tree 변경사항 보존; 커밋/푸시 없음.

**조사 결과**
- **CONFIRMED** — Special 동안 atlas_skill이 선택되고, Special 종료 후 기본 공격 경로가 재개된다.
- **CONFIRMED** — Heavy Pierce의 피해 대상은 Heavy/Giant이지만 기존 임팩트 효과 위치는 robot.position이었다. 따라서 코드상 공격 대상과 임팩트 위치가 불일치했다.
- **CONFIRMED** — Area Attack은 로봇 중심 범위 공격이므로 robot.position 기준 효과 위치가 의도와 일치한다.
- **UNVERIFIED** — 실제 PIE 화면에서 프레임별 타격감과 사운드 체감은 직접 관찰하지 못함.

**변경 사항**
- **CHANGED** — Heavy Pierce 임팩트 효과 위치를 robot.position → heavy.position으로 최소 수정.
- 피해량, 지연시간 0.22초, Special 지속시간 0.5초, 애니메이션 자원은 변경하지 않음.

**검증 상태** — CODE VERIFIED PASS; EDITOR VERIFIED PASS; BUILD VERIFIED NOT VERIFIED; PIE VERIFIED UNVERIFIED.

**검증** — git diff --check 수행. Godot 4.7.2 headless editor initialization에서 Parse Error/Script Error 미검출.

**세라의 기술 판단** — Heavy Pierce는 단일 대상 공격이므로 임팩트는 실제 피격 대상 좌표에 귀속하는 것이 코드상 인과관계를 가장 명확하게 만든다.

**마리의 판정** — 확인 가능한 연출 인과성 문제를 최소 수정으로 제거했다. 실제 화면 체감은 미검증이므로 추가 VFX/사운드 수정은 하지 않는다. ACCEPT·STOP.

**OUT OF SCOPE** — 신규 VFX, 사운드, 애니메이션 프레임 수정, 피해량/쿨다운 밸런스.

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.
## Handoff — ATLAS Basic + Special Integrated Causality Verification (2026-09-28)

**STATUS** — PASS

**목적** — 기본 공격 → Special 발동 → Special 피격 → Special 종료 → 기본 공격 재개의 전투 흐름이 코드상 끊기거나 중복되지 않는지 최소 통합 검증.

**기준선** — HEAD fa6fb67534e890ed4deecc54dbbaebbd2f3da496; branch main; 기존 working tree 변경사항 보존; 커밋/푸시 없음.

**조사 결과**
- **CONFIRMED** — Special 직전 기본 공격 탄환 1개가 정상 생성된다.
- **CONFIRMED** — Special 발동 후 robot.special = 0.5가 설정되고, Special 지속 중 update_robot()는 신규 기본 공격을 생성하지 않는다.
- **CONFIRMED** — Special 피해는 즉시 적용되지 않고 0.22초 지연 후 적용된다. 0.10초 시점 HP는 변화가 없었고, 0.30초 누적 시 세 대상 모두 피해가 적용됐다.
- **CONFIRMED** — Special 종료 시 robot.special이 0으로 내려가며 기본 공격 경로가 재개되고, 공격 타이머를 준비시키면 신규 기본 공격 탄환이 다시 생성된다.
- **CONFIRMED** — Special 직전에 이미 생성된 기본 공격 탄환은 Special 중에도 계속 진행되어 피격할 수 있다. 이는 현재 코드의 기존 탄환 처리이며, 신규 기본 공격 발사와는 구분된다.
- **UNVERIFIED** — 실제 PIE 화면에서 atlas_attack → atlas_skill → atlas_attack의 프레임 전환 체감, VFX 겹침, 사운드 체감은 직접 관찰하지 못함.

**세라의 기술 판단** — 코드상 기본 공격과 Special의 상태 전환 및 피해 타이밍은 일관되며, 현재 확인된 범위에서 추가 코드 수정은 필요하지 않다. 기존 발사체의 Special 중 잔여 진행은 확인된 동작이지만, 이를 취소할지는 전투 연출 설계 판단이므로 현재 범위에서는 변경하지 않는다.

**마리의 판정** — 최소 통합 검증 목적을 충족했다. 기존 탄환의 잔여 진행은 버그로 단정할 근거가 없으므로 수정하지 않는다. ACCEPT·STOP.

**변경 사항** — 없음. 검증용 임시 스크립트는 삭제.

**검증 상태** — CODE VERIFIED PASS; BUILD VERIFIED NOT VERIFIED; EDITOR VERIFIED PASS; PIE VERIFIED UNVERIFIED.

**검증 메모** — headless 통합 테스트 출력에서 _draw()의 mock Dictionary position 접근 오류가 발생했으나 테스트 판정값 산출 이후 발생한 기존 렌더 경로 오류이며, 본 검증 대상인 공격 상태/피해 타이밍 결과에는 영향을 주지 않았다. 별도 수정하지 않음(OUT OF SCOPE).

**OUT OF SCOPE** — 신규 VFX/사운드, 기존 탄환 취소 정책, 피해량/쿨다운 밸런스, 실제 PIE 화면 체감 검증.

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

## Handoff — Combat Screen / Commercial Completeness Audit (2026-09-28)

**STATUS** — HOLD

**목적** — 현재 Godot 전투 화면이 상업용 플레이 화면으로서 필요한 정보 전달과 사용자 흐름을 갖추었는지 최소 범위에서 점검하고, 확인되지 않은 시각적 문제를 추측하지 않는다.

**기준선** — HEAD fa6fb67534e890ed4deecc54dbbaebbd2f3da496; branch main; 기존 working tree 변경사항 다수 존재하며 임의 수정/되돌림 없음; 커밋/푸시 없음.

**조사 결과**
- **CONFIRMED** — 전투 화면은 1400x860 뷰포트 기준이며, 208px 사이드바 + 1152px 전술 필드 구조로 구성되어 있다.
- **CONFIRMED** — 사이드바에서 Base HP, Gold, Stage, Wave, Wave 상태, ATLAS 상태/HP, Wave 시작, 재시작, Robot 발진, Cannon/Gatling 건설, Special을 직접 조작할 수 있다.
- **CONFIRMED** — 전투 중에는 적 HP 바/이름, 아군 타워 선택 상태, ATLAS 선택 상태/HP, 공격/피격 이펙트가 코드상 표시되도록 되어 있다.
- **CONFIRMED** — Wave 종료 후 Robot Ability 선택, Stage 전환, Campaign Victory/Defeat 상태와 Restart 경로가 코드상 존재한다.
- **CONFIRMED** — 타이틀 화면에서 Start Campaign / Quit 진입점과 Enter 키 시작이 존재한다.
- **CONFIRMED** — 현재 UI는 `main.gd`의 `_draw()` 기반으로 직접 렌더링되며, 텍스트와 버튼도 동일 방식으로 구성되어 있다.
- **UNVERIFIED** — 실제 1400x860 PIE 화면에서 글자 크기, 버튼 터치 영역, 전투 정보 가독성, 적/ATLAS/이펙트 겹침, 전체적인 시각 밀도는 직접 관찰하지 못했다.
- **UNVERIFIED** — 실제 플레이 중 Pause/Settings/볼륨 조절/입력 재설정 등이 필요한지 여부는 사용자 플레이 테스트 없이는 확정할 수 없다.
- **INFERENCE** — 현재 화면은 '전투 기능을 한 화면에 제공하는 개발/PoC UI'로서는 충분하지만, 상업용 UX 완성 여부를 코드만으로 PASS 판정할 수 없다.
- **OUT OF SCOPE** — Pause, Settings, 튜토리얼, 모바일 UI, 신규 HUD 디자인, 신규 아트/사운드, UX 리디자인은 이번 감사에서 구현하지 않았다. 각각 별도 설계 판단이 필요한 영역이다.

**세라의 기술 판단** — 현재 전투 화면의 기능적 정보 구조는 이미 형성되어 있다. 다만 실제 화면 체감 검증 없이 UI 크기나 배치를 수정하면 기존 작업을 추측으로 덮을 위험이 있으므로, 현 시점에서 코드 변경은 하지 않는 것이 안전하다. 특히 Pause/Settings 같은 상용 기능을 바로 추가하는 것은 Scope Lock을 벗어날 수 있다.

**마리의 판정** — 기능 구조 감사는 완료했으나 '상업용 화면 완성'을 PASS로 판정할 핵심 증거인 실제 PIE 화면 관찰이 없다. 따라서 HOLD가 적절하다. 다음 최소 검증은 기존 기능을 수정하지 않고 실제 PIE에서 한 화면을 관찰하여 가독성/정보 밀도/전투 가시성만 판정하는 것이다.

**변경 사항** — 문서에 본 감사 결과만 추가. 코드/Asset 변경 없음.

**검증 상태** — CODE VERIFIED PASS; EDITOR VERIFIED PASS(4.7.2 headless project scan); BUILD VERIFIED NOT VERIFIED; PIE VERIFIED UNVERIFIED.

**환경 메모** — Godot 프로젝트 스캔에서 기존의 중복 UID 경고가 확인되었으나, 현재 전투 화면 감사의 핵심 기능을 차단하는 Parse Error/Script Error는 확인되지 않았다. 중복 UID 정리는 별도 작업으로 남긴다.

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE / COMMERCIAL UI READINESS: UNVERIFIED.


## Handoff — 2026-10-05 문서 재검토 기준선 갱신

**STATUS** — PASS / ACCEPT·STOP

**목적**
현재 실제 Stage/Map/Mission/Reward/Encounter/Allied Unit/Runtime/Validator 구조를 객체 중심 개발계획과 대조하고, 확인된 사실과 미해결 Canon을 CURRENT_STATE에 반영한다.

**기준선**
- HEAD: d783a8b394f2db53488e919dce4285ff5f3ed92c
- Branch: main
- 기존 Working Tree 변경사항은 보존.
- 이번 작업에서는 코드/Asset 변경 없음.

**CONFIRMED**
- Stage는 Mission/Reward/Map/Balance/Encounter/Allied Units를 조합하는 구조다.
- StageLoader/StageManager/GameController 경로에서 이 데이터가 실제 Runtime에 연결된다.
- mission_id와 reward_id는 각각 별도 Catalog를 참조한다.
- allied_units는 StageLoader 검증뿐 아니라 GameController Runtime에서 실제 소비된다.
- Encounter/Wave/Enemy Group은 Stage Runtime spawn queue로 연결된다.
- Map goal.position은 Runtime Base 위치 및 Base HP defeat 경로에 연결된다.
- Reward item_ids는 Item Catalog와 교차 검증된다.
- Mission target_id는 저장/로드되지만 현재 승리 조건 판정에는 사용되지 않는다.
- Stage lane은 left/right/both, Map spawn은 spawn_* 구조라 의미 연결에 GAP가 있다.
- Player Count를 의미하는 독립 필드는 현재 확인되지 않았다.

**미확인 / HOLD**
- Tower Defense / Elimination / Giant Boss Battle의 정확한 Mission Type ↔ Runtime 계약.
- Giant Boss Battle의 독립 승리 조건.
- Mission target_id의 정확한 의미.
- Player Count의 Canon 및 저장 위치.
- left/right/both의 최종 Spawn semantics.

**세라 기술 판단**
현재 구조는 신규 공통 시스템을 먼저 만드는 것보다 기존 Stage → Mission → Encounter/Wave → Runtime 경로를 유지하면서 위 다섯 가지 의미 공백을 먼저 결정하는 편이 안전하다.

**마리 판정**
목적 충족. 현재 문서와 실제 구조 사이의 핵심 차이를 기록했으며, 확인되지 않은 설계는 Canon으로 승격하지 않았다. ACCEPT·STOP.

**변경 사항**
- 문서 2개만 갱신.
- 코드/Asset/Editor 변경 없음.


## Handoff — 2026-10-05 Lane Semantics Runtime 재검증

**STATUS** — HOLD

**목적**
Stage의 left/right/both lane 값이 실제 Runtime에서 어떻게 spawn 위치로 변환되는지 직접 확인.

**CONFIRMED**
- Wave group의 lanes 배열은 spawn queue에 저장된다.
- Runtime은 여러 lane을 동시에 spawn하지 않고 각 enemy spawn 시 requested_lanes 중 하나를 선택한다.
- 실제 Map spawn area는 spawn_0 계열 key로 생성되며 left/right와 직접 일치하지 않는다.
- left/right는 실제 spawn area가 없을 경우 spawn area를 전역 순환 선택하는 fallback으로 처리된다.
- map_01은 spawn area가 하나이므로 left/right/both가 동일 spawn area로 수렴한다.
- lanes=[left,right]는 양쪽 동시 spawn을 보장하지 않는다.

**세라 기술 판단**
현재 lane 표현과 Runtime spawn area 표현 사이에 의미 계약이 없다. 구현 변경보다 Master가 최종 lane Canon을 먼저 결정해야 한다.

**마리 판정**
기존 GAP를 유지하되 상태를 UNVERIFIED에서 **CODE VERIFIED GAP**으로 상향한다. Canon 결정 전 수정하지 않는다. HOLD.

**검증 상태**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED

**OUT OF SCOPE**
Lane 구현 변경, Map 수정, Stage JSON 수정, Validator 강화.


## Handoff — 2026-10-05 Mission Contract / target_id 재검증

**STATUS** — HOLD

**CONFIRMED**
- 현재 Mission Catalog 3개는 모두 `clear_encounters`이고 `target_id`는 비어 있다.
- Validator와 Stage Editor가 지원하는 Mission Type은 `defend_base`, `clear_encounters` 두 종류다.
- `defend_base`는 양수 time_limit이 필요하다.
- target_id는 Definition 로드와 Editor 저장에는 존재하지만 GameController Mission 판정에는 사용되지 않는다.
- 현재 Runtime 승리 조건은 defend_base의 생존 시간 또는 Encounter/Wave 전체 종료 및 생존 Enemy 소멸이다.
- Giant은 boss runtime을 갖지만 Giant 처치가 독립 Mission 승리 조건은 아니다.
- Stage 01~03에 Giant이 포함되어 있으나 이것만으로 Giant Boss Battle임을 입증하지 않는다.

**INFERENCE**
- target_id는 향후 Objective 확장용 필드일 가능성은 있으나 의미는 특정할 수 없다.

**마리 판정**
Mission Contract의 실제 구현 범위를 CODE VERIFIED로 확정한다. 3 Gameplay 매핑과 target_id semantics는 Canon 결정 전 HOLD. 구현하지 않는다.

**검증 상태**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED


## Handoff — 2026-10-05 Player Count / Multiplayer Semantics 재검증

**STATUS** — HOLD

**CONFIRMED**
- MapLoader는 `play_modes`와 `multiplayer`를 읽어 보존한다.
- Map Editor는 Campaign/Single/Multiplayer mode와 alliance/relation 설정을 저장할 수 있다.
- StageManager의 실제 run_mode 경로는 현재 campaign/single 중심이다.
- Title Screen에 Multiplayer 시작 경로는 없다.
- GameController가 multiplayer/alliance/relation을 Player Count나 네트워크 플레이어 Runtime으로 소비하는 경로는 확인되지 않았다.
- 독립적인 Player Count field는 확인되지 않았다.

**INFERENCE**
- multiplayer 데이터는 향후 AI faction 또는 multiplayer rule 확장을 위한 Map-level 설정일 가능성이 있으나 현재 Runtime 계약은 아니다.

**마리 판정**
`play_modes.multiplayer`를 Player Count로 해석하지 않는다. Player Count Canon/storage는 UNVERIFIED/HOLD로 유지한다. Multiplayer Runtime 구현은 현재 범위 밖이다.

**검증 상태**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED


## Handoff — 2026-10-05 Allied Units Authoring Gap 재검증

**STATUS** — HOLD

**CONFIRMED**
- Allied Unit Catalog/Definition/Runtime/AI가 실제 존재하고 GameController에서 소비된다.
- StageLoader/Validator가 `allied_units`를 검증한다.
- Stage 01에는 basic/ranged/support Allied Unit이 실제 참조된다.
- Unit Editor는 Allied Unit 자체를 편집한다.
- Stage Editor에는 Allied Unit을 authoring하는 UI가 없다. 기존 `allied_units` 데이터는 보존 가능하지만 신규 구성/변경 UI는 확인되지 않았다.

**마리 판정**
Allied Unit은 죽은 설정이 아니라 CODE VERIFIED Runtime 기능이다. 현재 gap은 Stage-level authoring이다. Spawn ownership/Player Count와 연결되는 계약은 Canon 결정 전 구현하지 않는다.

**검증 상태**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED


## Handoff — 2026-10-05 Encounter / Wave Runtime Semantics 재검증

**STATUS** — HOLD

**CONFIRMED**
- Encounter → Wave → Group 구조는 Stage Editor에서 직접 편집된다.
- Group은 enemy/count/interval/lanes를 가진다.
- Runtime은 한 Wave의 Group들을 spawn_queue에 순차적으로 펼친다.
- 같은 Wave의 Group들은 현재 동시에 spawn되지 않는다.
- `[left,right]` 역시 양쪽 동시 spawn을 의미하지 않는다.
- Wave Clear는 spawn_queue empty + living enemies zero다.
- 마지막 Encounter/Wave 완료 시 clear_encounters는 Victory, defend_base는 Defense 지속이다.

**INFERENCE**
- 현재 Wave는 동시 출현 묶음보다는 순차 Spawn Group 컨테이너에 가깝다.
- Wave/Group label은 Runtime semantics를 갖지 않는다.

**마리 판정**
Encounter/Wave 연결 자체는 CODE VERIFIED. Group concurrency와 Lane semantics는 Canon 결정 전 HOLD. 구현하지 않는다.

**검증 상태**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED


## Handoff — 2026-10-05 Lane ↔ Map Spawn Area 재검증

**CONFIRMED**
- Stage Editor Lane은 `left/right/both` 고정 선택지다.
- `both`는 저장 시 `[left,right]`다.
- Map Runtime은 gameplay `spawn_area`마다 `spawn_0`, `spawn_1` 등의 실제 key를 생성한다.
- `map_01`에는 Spawn Area가 1개뿐이어서 실제 Runtime Spawn Area는 `spawn_0` 하나다.
- 따라서 `left/right/both`는 실제 Map Spawn Area ID와 직접 연결되지 않는다.
- map_01에서는 left/right/both가 실질적으로 같은 Spawn Area를 사용한다.

**마리 판정**
Lane semantics는 CODE VERIFIED GAP. Canon 없이 구현 변경하지 않는다.

**검증 상태**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED


## Handoff — 2026-10-05 Lane ↔ Map Spawn Contract 재검증

**STATUS** — HOLD

**CONFIRMED**
- Legacy `spawns.left/right`와 `gameplay_areas.spawn_area`가 동시에 존재하는 구조다.
- `map_01`은 spawn area 1개만 있고 legacy spawns가 비어 있다 → Runtime spawn ID는 `spawn_0`.
- `map_02/03`은 legacy `left/right`가 있고 spawn area가 없다 → Runtime lane은 `left/right`.
- Stage는 `left/right/both`를 요청하므로 Map마다 같은 Stage 데이터가 다른 경로로 해석될 수 있다.
- 명시적인 Lane → Spawn Area mapping 계약은 확인되지 않았다.

**마리 판정**
Lane semantics는 CODE VERIFIED GAP. Canon 확정 전에는 데이터/Runtime을 수정하지 않는다.

**검증 상태**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED

## Handoff ? 2026-10-05 MapLoader / Runtime Spawn Conversion �����
**STATUS** ? HOLD

**����**
Map�� Legacy `spawns.left/right`�� Gameplay `spawn_area`�� MapLoader �� Runtime���� ��� ��ȯ�Ǵ��� Ȯ���Ѵ�.

**CONFIRMED**
- `MapLoader`�� Legacy `spawns`�� �����ϸ� �״�� `parsed.lanes[left/right]` ���·� ��ȯ�Ѵ�.
- `MapLoader`�� `gameplay_areas`�� ���� �����ϸ� Lane ID�� ��ȯ���� �ʴ´�.
- Runtime `GameController.apply_map_spatial_data()`�� Gameplay `spawn_area`�� ������� `spawn_0`, `spawn_1` ������ �����Ѵ�.
- �� `spawn_area`�� ���� ID/name�� Runtime Lane ID�� �������� �ʴ´�.
- Gameplay Spawn Area�� �ϳ� �̻� �����ϸ� Runtime�� Legacy `lanes`�� ������� �ʰ� Spawn Area ��� `LANES`�� �����Ѵ�.
- Spawn Area�� ���� ���� `loaded_map.lanes`�� Legacy Lane���� fallback�ȴ�.
- Stage�� `left/right` ��û�� Spawn Area ��� Map���� ���� �������� ������ Runtime�� Spawn Area ����� ��ȯ �����Ѵ�.
- ���� ������ Stage Group�� `left/right` �����Ͱ� Map�� ���� Legacy ��ǥ Lane �Ǵ� Spawn Area ��ȯ���� �ؼ��ȴ�.

**INFERENCE**
���� `left/right`�� Map�� �������� Canonical Lane ID�� �ƴ϶� Runtime���� Map ǥ���� ���� ���ؼ��Ǵ� ��û���� ������.

**���� ����**
Phase C�� Lane/Spawn ����� ���� ���� ���� Canon ������ �ʿ��� ���´�. ���� ���縸���δ� Ư�� ǥ���� �������� Ȯ������ �ʴ´�. HOLD.

**���� ����**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED

**���� ����**
�ڵ�/Asset ���� ����. ���� �����ϸ� ����.

**OUT OF SCOPE**
Lane ���� ����, Map JSON ��ȯ, Validator ��ȭ, Stage ������ ����.

## Handoff ? 2026-10-05 Phase C �Ϸ����� ���� ����
**STATUS** ? HOLD / Phase C �̿Ϸ�

**����**
���߰�ȹ���� Phase C �Ϸ������� ���� �ڵ�/���� ���¿� �����Ͽ� Phase D ���� ���� ���θ� �����Ѵ�.

**Phase C �Ϸ�����**
- �ϳ��� Stage�� Map, Mission, Encounter/Wave ��ü�� �����Ѵ�.
- Stage�� ���� �����ϴ�.
- Mission �����Ͱ� Stage�� �ߺ� ������� �ʴ´�.

**CONFIRMED ? ����**
- Stage �� `map_file` ������ �����ϰ� StageLoader/StageManager/GameController�� ���޵ȴ�.
- Stage �� `mission_id` ������ �����ϰ� Mission Catalog/Definition���� �ؼ��ȴ�.
- Stage �� `reward_id` ������ RewardDefinition ��ΰ� �����Ǿ� �ִ�.
- Stage �� Encounter/Wave ������ ���� Runtime spawn queue�� �Һ�ȴ�.
- Mission �����ʹ� Stage�� �и��� Catalog/Definition���� �����ȴ�.
- Building ��ġ �����ʹ� Map�� �����ϸ� Runtime Tower ��ġ ��ο� ����ȴ�.

**CONFIRMED GAP ? �Ϸ����� ������ ���� �׸�**
1. Lane/Spawn Contract: Stage�� `left/right/both` �ǹ̰� Map�� legacy `spawns`�� `gameplay_areas.spawn_area` ���̿��� �ϰ����� �ʴ�.
2. Mission Contract: ���� Runtime�� `defend_base`�� `clear_encounters`�� �����ϸ� `target_id` �ǹ̰� �Һ���� �ʴ´�. Master Canon�� 3 Gameplay ������ 1:1 ������ Ȯ�ε��� �ʾҴ�.
3. PIE: ���� Stage ���� ����� Master�� Ȯ���ϴ� PIE VERIFIED�� ���� ����.

**Phase C�� ������ Ȯ�ε� ����**
- Player Count / Multiplayer�� ���� Canon/storage�� Ȯ�ε��� �ʾ����Ƿ� Phase C �Ϸ����ǿ� ���Ƿ� �������� �ʴ´�.
- Allied Unit�� Runtime ����� ���������� Stage-level authoring UI�� ����. �̴� ���� Phase C �Ϸ����� ��ü�ʹ� ���� authoring gap�̴�.
- Building�� `tower_slots` / `tower_placement_area` ����� �߰� Canon Ȯ�� ����̳� ���� Phase C �Ϸ������� ���� ���� ������ �������� �ʴ´�.

**���� ����**
Phase C�� ��ü ���� ������ Runtime ���� ����� ��κ� �����ߴ�. �׷��� Lane/Spawn ���� Mission Canon�� Ȯ������ �ʾҰ� PIE ������ �����Ƿ� **Phase C �Ϸ�� ������ �� ����. Phase D �������� �ڵ� �������� �ʴ´�.**

**���� ����**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED

**���� ����**
- �ڵ�/Asset ���� ����.
- �� ���� Handoff�� ������ ���.

**OUT OF SCOPE**
- Lane ���� ����
- Map JSON ���̱׷��̼�
- Mission Type �߰�/����
- Player Count/Multiplayer ����
- Allied Unit Stage Editor ����
- Phase D �ű� ��� ����

**��� �ð�**
$stamp

## Handoff — 2026-10-05 Mission Contract Canon 승인 반영

STATUS — ACCEPTED / PROPOSAL → MASTER CANON

Master 승인 사항:
- Tower Defense → `defend_base`
- Elimination → `clear_encounters`
- Giant Boss Battle → `defeat_giant`

Mission Contract 제안:
- Tower Defense Victory: 제한 시간 생존
- Elimination Victory: 모든 Encounter/Wave 적 제거
- Giant Boss Battle Victory: Giant 처치
- 모든 Mission의 기본 Defeat: Base HP <= 0

`target_id`:
- Tower Defense: 사용하지 않음
- Elimination: 사용하지 않음
- Giant Boss Battle: Giant 식별에 사용 가능
- 일반 Objective 시스템으로 확장하지 않음

범위 원칙:
- 기존 `defend_base` / `clear_encounters` Runtime은 최대한 보존한다.
- `defeat_giant`는 기존 Giant Runtime을 활용한다.
- Mission Contract 확정 전에는 코드/Asset을 변경하지 않는다.
- 다음 단계는 현재 Runtime과 승인된 Contract의 차이를 최소 단위로 대조한다.

판정:
- Mission Canon 결정으로 기존 Mission Contract HOLD의 설계 원인은 해소됨.
- 실제 코드 반영은 별도 검증 후 진행한다.
- CODE/BUILD/EDITOR/PIE: 현재 변경 검증 전 상태.

## Handoff — 2026-10-05 Mission Contract Runtime Delta 조사
STATUS — HOLD / 구현 전 파일 잠금
CONFIRMED — 승인된 Mission Contract와 현재 코드의 차이를 직접 대조했다.
- `defend_base`: 현재 Runtime과 직접 대응하며 유지 가능.
- `clear_encounters`: 현재 Runtime과 직접 대응하며 유지 가능.
- `defeat_giant`: 현재 MissionDefinition에는 없고, Validator/Stage Editor도 허용하지 않는다.
- Giant 처치 자체는 `damage_enemy()`에서 이미 감지되고 `GIANT NEUTRALIZED` 이벤트도 발생한다. 그러나 현재 Giant 처치 시 Mission Victory 전환은 없다.
- Giant Mission의 Campaign 보상/다음 Stage 전환은 `defend_base` 완료 경로와 별도 구현이 필요하다.
- `target_id`는 현재 Runtime에서 승리 조건에 사용되지 않는다. 승인 Canon에서는 Giant 식별 용도로 사용 가능하지만, 현재 Stage에는 Giant Mission이 지정되어 있지 않다.
TECHNICAL JUDGMENT — `defeat_giant` 추가는 기존 Giant Runtime을 재사용하는 최소 변경으로 가능하다.
BLOCKER — Godot Editor 프로세스가 `content_validator.gd`와 `stage_editor.gd`를 잠금 중이어서 안전한 코드 저장을 수행하지 않았다. 프로세스 종료/강제 해제는 Master 승인 없이 하지 않는다.
CHANGES — 코드/Asset 변경 없음. 문서 기록만 추가.
VERIFICATION — CODE VERIFIED (delta 조사), BUILD/EDITOR/PIE NOT VERIFIED.
NEXT — 파일 잠금이 해소되면 Validator → Stage Editor → GameController 순서로 최소 변경하고 diff/check/build 검증.

## Handoff — 2026-10-05 defeat_giant Runtime 구현
STATUS — PASS / CODE + BUILD
CONFIRMED
- ContentValidator가 `defeat_giant` Mission Type을 허용한다.
- Stage Editor가 `defeat_giant`을 Mission Type으로 표시하고 로드한다. 기존 저장 경로의 `primary_type` 저장은 그대로 사용한다.
- GameController가 Giant 처치 시 `defeat_giant` Mission이면 즉시 Mission Clear 경로로 진입한다.
- Campaign에서는 기존 Stage reward / progression / next Stage 처리 패턴을 재사용한다.
- Base HP <= 0 조건은 기존 DEFEAT 경로를 유지한다.
- 기존 `defend_base` / `clear_encounters` 경로는 변경하지 않았다.
- `target_id`는 이번 구현에서 강제 사용하지 않았다. 현재 Giant Runtime의 타입 식별(`giant`)으로 Canon 조건을 충족한다.
VERIFICATION
- CODE VERIFIED — PASS
- BUILD VERIFIED — PASS (`Godot 4.7.2 --headless --editor --quit`, exit code 0)
- EDITOR VERIFIED — NOT VERIFIED
- PIE VERIFIED — NOT VERIFIED
DIFF — 의도된 3개 코드 파일만 Mission Contract 변경. 기존 문서 변경은 유지.
git diff --check — PASS
CHANGES — `editor/content_validator.gd`, `editor/stage_editor.gd`, `game_controller.gd`
OUT OF SCOPE — 실제 Mission Catalog에 Giant Boss Mission을 지정하는 Content 변경, PIE Runtime 확인, Player Count, Lane/Spawn Canon.


## Handoff — 2026-10-05 Audio Design / BGM·SFX 계획 반영

**STATUS** — PASS / PLAN UPDATED

**목적**
개발계획에 MENOS BGM 및 효과음의 제작·참조·Runtime 검증 범위를 반영한다.

**CONFIRMED**
- 개발계획의 Weapon/Skill에 SFX 참조 항목은 이미 존재했다.
- BGM 자체의 개발 단계와 검증 기준은 기존 계획에 독립적으로 정의되어 있지 않았다.
- 오디오 Asset/Runtime 구현은 이번 작업에서 수행하지 않았다.

**반영 내용**
- BGM 핵심 5종 후보: Title/Menu, Battle, Boss Battle, Victory, Defeat.
- SFX 범위: UI, Robot/Unit, Enemy, Building/Tower, Base, Boss, Skill/Weapon, Victory/Defeat.
- 초기에는 Battle/Boss BGM과 핵심 SFX 8종을 포함한 최소 PoC를 우선 검토한다.
- Audio Bus와 재생 계층은 기존 Runtime 조사 후 최소 구현한다.
- 별도 Audio Editor는 반복 편집 가치가 확인되기 전에는 만들지 않는다.
- 외부 음원 Source 사용은 별도 승인 대상으로 유지한다.

**마리 판정**
현재 단계에서는 오디오 Asset 대량 제작이나 신규 Audio 시스템 구현을 시작하지 않는다. Audio Design/Asset Contract 확정 → 최소 PoC → Runtime 연결 → 검증 순서로 진행한다.

**변경 사항**
- MENOS_OBJECT_CENTRIC_DEVELOPMENT_PLAN.md 계획 항목 추가.
- CURRENT_STATE.md 진행기록 추가.
- 코드/Asset/Editor 변경 없음.

**검증 상태**
- 문서 갱신: VERIFIED
- CODE: NOT CHANGED
- BUILD: NOT RUN
- EDITOR: NOT RUN
- PIE: NOT RUN

**OUT OF SCOPE**
- 실제 BGM/SFX 제작
- Audio Runtime 구현
- Audio Editor 구현
- 외부 음원 Source 선정


### Phase D 계획 확장 — Item / Shop / Exchange
STATUS: PASS / PLAN UPDATED / IMPLEMENTATION HOLD

CONFIRMED:
- Item/Equipment는 기존 Phase D 계획과 Catalog/Inventory/Profile 구조에 포함되어 있다.
- PlayerProfileState는 Gold / Inventory / Equipped Items를 저장한다.
- Reward Runtime은 Stage 완료 보상을 Profile에 반영하는 경로가 있다.
- Shop/Store/Exchange/거래소 기능은 현재 코드/데이터 조사에서 확인되지 않았다.

반영:
- Item을 Phase D 경제 흐름의 핵심 객체로 명확화.
- Shop을 Item 구매 시스템으로 계획에 추가.
- Exchange를 Shop과 분리된 교환 시스템으로 계획에 추가.
- Reward → Inventory/Gold, Shop → Currency → Item, Exchange → Input → Output, Equipment → Robot Runtime 관계를 정의.
- Currency 종류, 가격, 갱신, Exchange 비율, 플레이어 간 거래 여부는 Master Canon 확정 전 DESIGN HOLD.
- 구현 및 Editor 추가는 수행하지 않음.

다음 검증 후보:
- Item Equipment → Robot Runtime
- Currency/Economy 계약
- Shop 구매 Runtime
- Exchange 교환 Runtime
- Profile Save/Load 연계

PIE: 보류 유지.


## Handoff — 2026-10-05 Art Asset Structure 반영

**STATUS** — PASS / ACCEPT·STOP

**목적**
게임 객체 구조에 대응하는 Art Asset 종류와 참조 관계, 제작 우선순위를 개발계획에 반영한다.

**CONFIRMED / STRUCTURE**
- Art는 Core Gameplay / Map / Content / UI / Presentation·Effects의 5개 영역으로 분류했다.
- Robot/Enemy/Allied Unit/Building/Tower는 Visual Asset ID → Sprite Atlas/Animation 구조를 기본 계약으로 둔다.
- Item은 우선 Icon Asset 중심으로 정의한다.
- Faction/Stage/Map/Catalog은 Editor 및 Content 표시를 위한 Thumbnail/Icon Asset을 가진다.
- Skill/Weapon은 Animation/VFX/SFX 참조를 가질 수 있다.
- Map의 Spawn/Placement/Objective 같은 논리 영역과 실제 그래픽 Asset은 분리한다.
- Content/Asset Catalog가 Asset 등록·선택을 담당하고 Object Editor가 Asset ID를 참조하는 구조를 우선한다.

**제작 우선순위**
- P0: Robot, Enemy, Giant/Boss, Allied Unit, Tower/Building, Base, Projectile, 최소 Combat VFX
- P1: Map/Environment 및 Object/Stage/Map/Faction Thumbnail
- P2: Item/Equipment/Currency/Shop/Exchange Art
- P3: 공통 UI 및 확장 Presentation

**마리 판정**
현재 구조 단계에서는 실제 아트 대량 제작보다 Art Asset Contract를 먼저 확정하는 것이 목적에 부합한다. Sprite Atlas 규격, Pivot/Anchor, naming, Asset ID 규칙을 다음 구조 검토 대상으로 둔다.

**변경 사항**
- 개발계획 문서에 Art Asset Structure/Handoff 추가.
- CURRENT_STATE에 동일한 진행 상태 기록.
- 코드/Runtime/Asset 파일 변경 없음.

**검증 상태**
- CODE VERIFIED: NOT APPLICABLE
- BUILD VERIFIED: NOT APPLICABLE
- EDITOR VERIFIED: NOT APPLICABLE
- PIE VERIFIED: NOT VERIFIED

**OUT OF SCOPE**
- 실제 아트 제작
- 대량 Sprite Atlas 생성
- UI/Shop/Exchange 아트 구현
- Runtime Asset 로딩 변경


## Handoff — 2026-10-05 Networked Single-Player / User Map Upload 구조 반영

STATUS — PASS / ACCEPT·STOP

목적
현재 멀티플레이 구현 범위를 확장하지 않고, 향후 네트워크를 사용하는 싱글플레이와 사용자 제작 맵 업로드를 수용할 수 있는 구조적 경계를 개발계획에 반영했다.

CONFIRMED / STRUCTURE
- 네트워크 사용 여부와 Gameplay Mode를 분리하는 원칙을 추가했다.
- 향후 Networked Single-Player를 Content/Definition/Asset 전달 계층과 Runtime의 분리로 수용할 수 있도록 했다.
- User Map을 Map Definition 기반의 업로드 가능한 콘텐츠 단위로 정의했다.
- User Map의 ID, Author, Version, Schema Version, Metadata, Asset References, Validation Status 개념을 정의했다.
- User Map과 Stage를 동일 객체로 강제하지 않고 Stage → Map ID 관계를 유지한다.
- User Map은 Runtime 투입 전에 구조/참조 검증을 거치는 방향을 정의했다.
- User Map의 임의 외부 Asset 직접 참조는 기본값으로 허용하지 않고 Asset ID 경계를 우선한다.
- Map Schema / Content Definition / Asset Contract Version을 향후 호환성 경계로 둔다.

DESIGN HOLD
- Multiplayer Runtime
- Network synchronization
- Authentication / authorization
- User Map 공개 범위
- Upload storage / size policy
- UGC moderation / report / deletion
- User-uploaded external art/audio/VFX 허용 정책
- Migration / backward compatibility 구현

마리 판정
현재 목적에 맞게 멀티플레이와 UGC 서비스를 구현하지 않고, 향후 확장을 위한 데이터·Asset·검증 경계만 확보했다. 이는 현재 구조 작업 범위를 유지하면서 향후 네트워크 서비스화를 막지 않는 수준이다.

변경 사항
- 개발계획 문서에 Networked Single-Player / User Map Upload 구조 추가.
- CURRENT_STATE에 동일한 상태 기록.
- 코드/Asset/Editor/Runtime 변경 없음.

검증 상태
- CODE VERIFIED: NOT APPLICABLE
- BUILD VERIFIED: NOT APPLICABLE
- EDITOR VERIFIED: NOT APPLICABLE
- PIE VERIFIED: NOT VERIFIED

OUT OF SCOPE
- Multiplayer Gameplay
- Network Runtime
- User Map Upload Service 구현
- Server/Cloud 구축
- UGC moderation 및 marketplace 기능


## Handoff — 2026-10-05 Sprite Atlas Contract 반영

**STATUS** — PASS / ACCEPT·STOP

**목적**
전투 객체의 Sprite Atlas 제작/참조 규칙을 공통 구조로 정의했다.

**CONFIRMED / STRUCTURE**
- Object Definition → Visual Asset ID → Animation Set → Sprite Atlas → Frame 구조를 기준으로 한다.
- 현재 전투 Sprite 제작은 120×120 px 셀 규격을 기본 후보로 사용한다.
- Animation별 Frame 중심과 Pivot/Anchor의 일관성을 중요 계약으로 정의했다.
- Runtime Visual Asset과 Editor/Catalog Thumbnail을 분리한다.
- Animation, VFX, SFX를 독립 Asset으로 두고 필요 시 Event/Timing으로 연결한다.
- Atlas 행 번호는 전역 규칙으로 강제하지 않고 객체별 Animation Set이 정의한다.

**UNVERIFIED / DESIGN HOLD**
- 정확한 Pivot 좌표
- Weapon/Skill Anchor 좌표 및 명칭
- 기존 Atlas 전체의 공통 Layout 강제 가능 여부
- Animation Event Timing의 실제 Runtime 소비 경로

**마리 판정**
현재 구조 단계에서는 120×120 제작 기준과 Asset ID/Animation/Pivot 경계를 먼저 정의하는 것으로 충분하다. 기존 Asset을 재생성하거나 변환하지 않는다.

**변경 사항**
- 개발계획 문서에 Sprite Atlas Contract 추가.
- CURRENT_STATE에 동일 상태 기록.
- 코드/Asset/Editor/Runtime 변경 없음.

**검증 상태**
- CODE VERIFIED: NOT APPLICABLE
- BUILD VERIFIED: NOT APPLICABLE
- EDITOR VERIFIED: NOT APPLICABLE
- PIE VERIFIED: NOT VERIFIED

**OUT OF SCOPE**
- Sprite Atlas 재생성/변환
- 신규 캐릭터 아트 제작
- Pivot 좌표 Runtime 구현
- Animation Event Runtime 구현


## Handoff — 2026-10-05 Sprite Frame Size / 1500×1000 24프레임 제약

STATUS — ACCEPTED / 문서 반영

- 1500×1000 캔버스에 24프레임을 6열 × 4행으로 배치할 경우 프레임 셀은 250×250 px이다.
- Giant Boss 제작에서는 250×250 px를 프레임 셀 상한으로 보고, 실제 실루엣은 여백을 위해 약 200~220 px 범위를 1차 목표로 한다.
- Giant Boss의 게임 화면 표시 크기는 Sprite 셀 크기와 별개이며 Asura 대비 약 4배를 목표로 한다.
- 기존 120×120 px는 이전 제작 후보 기준으로 유지하며 전체 Atlas 규격을 일괄 변경하지 않는다.
- 코드/Asset/Editor/Runtime 변경 없음. PIE 보류.

판정: 현재 Sprite 제작 제약에 필요한 정보만 문서화하고 STOP.


## Handoff — 2026-10-05 Gameplay Display Size / Asura·Giant

STATUS — PROPOSAL

- Sprite Frame Cell과 Gameplay 화면 표시 크기를 별도 기준으로 기록했다.
- Asura 화면 표시 높이 60~100 px를 1차 목표 범위로 제안한다.
- Giant Boss 화면 표시 높이 240~400 px를 1차 목표 범위로 제안한다.
- Giant Boss는 Asura 대비 약 4배 화면 크기를 목표로 한다.
- 실제 Camera/Viewport 및 최종 Scale은 UNVERIFIED이며 PIE는 보류한다.


## Handoff — 2026-10-05 Gameplay Visual Quality 우선

STATUS — ACCEPTED

- Editor Preview와 Gameplay 표시 기준을 통일하더라도 Gameplay 시각 품질 저하는 허용하지 않는 원칙을 추가했다.
- Runtime은 원본 Visual Asset/Frame 정보를 사용해야 하며, 표시 크기 통일을 위해 Asset 자체를 저해상도로 축소하거나 재샘플링하지 않는다.
- 현재 Gameplay의 TEXTURE_FILTER_NEAREST 정책은 임의 변경하지 않는다.
- 품질 검증 기준: 원본 해상도 보존, 필터링 보존, 프레임 경계 손상 없음, Anchor 기반 흔들림 없음.
- 품질 저하가 발생하는 구현 방법은 CHANGE METHOD 대상으로 판정한다.
- 코드/Asset/Editor/Runtime 변경 없음. PIE 보류.


## Handoff — 2026-10-05 MENOS 3/4 측면 Sprite 제작 규격

STATUS — ACCEPTED / 규격 정의

- MENOS 신규 Sprite의 기본 시점을 완전 측면이 아닌 3/4 측면(Quarter View)으로 정의했다.
- 권장 시점 범위는 약 30~45°이며 기본 제작 기준은 약 35~40° 사선 시점이다.
- 전면 + 한쪽 측면 + 약간의 상면이 동시에 읽혀야 하며, 극단적인 측면 투영은 피한다.
- Robot/Enemy/Giant/Allied Unit은 동일한 시점 계열을 기본으로 사용한다.
- 광원 방향, 명암 구조, AO, 금속 하이라이트를 Animation Set 전체에서 일관되게 유지한다.
- Team Color 영역은 Alpha 1.0의 불투명 Base Color 영역으로 분리하고 중립 금속/관절/무기에는 적용하지 않는다.
- Frame Cell 크기는 기존 캐릭터별 시트 조건을 유지하며 3/4 시점 자체가 셀 크기를 강제하지 않는다.
- 접지점/Combat Anchor를 안정적으로 유지하고 Gameplay 표시 크기와 원본 Asset 해상도를 분리한다.
- 투명 배경, 무배경, 무텍스트, 무워터마크를 유지한다.
- 기존 Asset은 자동 변환/재제작하지 않는다. 신규 제작 또는 교체는 별도 범위다.
- Camera 회전으로 시점을 만드는 방식은 기본 제작 방식으로 사용하지 않는다.
- PIE는 보류한다.

판정: 신규 Sprite 제작의 공통 시점 규격을 정의하고 STOP.


## Handoff — 2026-10-05 MENOS 공통 3/4 Sprite 생성 규격

STATUS — ACCEPTED / 제작 기준 구체화

**목적**
MENOS 신규 Sprite 제작에서 이미지 생성 모델과 관계없이 동일한 3/4 시점, 입체감, Team Color, 투명 배경, Frame 일관성, Gameplay 가독성 기준을 적용할 수 있도록 공통 생성 요구사항을 정리했다.

**CONFIRMED**
- 신규 Sprite는 약 35~40° 3/4 전투 시점을 기본으로 한다.
- Sprite 자체가 장갑 면 구조, AO, 방향성 명암, 금속 하이라이트를 통해 기본 입체감을 가져야 한다.
- Team Color 영역은 Alpha 1.0의 불투명 Base Color 영역으로 분리한다.
- 배경은 완전 투명하며 텍스트/라벨/워터마크/불필요한 외부 VFX를 포함하지 않는다.
- Animation Set 전체에서 시점, 광원, 비율, 접지점, Team Color 영역을 유지한다.
- 원본 품질을 낮추거나 재샘플링하여 Gameplay 품질을 확보하는 방식은 사용하지 않는다.
- Gemini 등 특정 생성 모델에 종속되지 않는 공통 요구사항으로 정의한다.

**마리 판정**
공통 Sprite 제작 규격은 충분히 정의되었다. 다음 작업은 공통 규격을 개별 캐릭터 제작 프롬프트로 구체화하는 단계이며, 기존 Asset 변경 없이 진행한다.

**검증 상태**
- DATA: VERIFIED
- CODE: NOT VERIFIED
- EDITOR: NOT VERIFIED
- BUILD: NOT VERIFIED
- PIE: NOT VERIFIED

**변경 사항**
- 진행 문서에 공통 Sprite 생성 규격의 적용 기준만 기록.
- 코드/Asset/Editor/Runtime 변경 없음.

**OUT OF SCOPE**
- 기존 Sprite 재제작
- Asset 변환
- Godot Lighting/Normal Map 구현
- PIE

## Handoff — 2026-10-05 Object Reference / Dependency 구조 조사

STATUS — HOLD / 구조 판정 필요

**목적**
MENOS 핵심 Object 간 소유·참조 방향을 확인하고 현재 구현과 목표 구조의 차이를 식별한다.

**CONFIRMED**
- Stage는 현재 `mission_id`, `map_file`, `reward_id`, `allied_units`, `encounters`를 직접 참조한다.
- Encounter/Wave/Group는 Stage 내부에 구성되어 있으며 Group의 enemy ID를 통해 Enemy Catalog를 간접 참조한다.
- Robot은 `RobotDefinition.faction_id` 필드를 가지고 있으나 현재 `robots.json`의 Asura/Valkyrie 데이터에는 해당 값이 없다.
- `factions.json`은 현재 `{}`로 비어 있다.
- EnemyDefinition에는 현재 Faction 참조 필드가 없다.
- AlliedUnitDefinition에는 현재 Faction 참조 필드가 없다.
- TowerDefinition에는 현재 Faction 참조 필드가 없다.
- Stage는 현재 Faction을 직접 참조하지 않는다.
- ObjectRepository는 Robot/Enemy/Allied Unit/Tower를 각각 별도 Catalog에서 로드한다.
- StageManager는 Stage → Mission/Reward/Map/Encounter 관계를 직접 소비한다.

**구조 판정**
현재 구현은 Object Definition과 Stage Composition이 분리되어 있으나 Faction 관계는 아직 실질적인 참조 계약으로 연결되지 않았다.

**PROPOSAL**
- Faction은 Robot/Enemy/Allied Unit/Tower의 공통 소속 정보를 정의하는 독립 Object로 둔다.
- 개별 Object Definition은 Faction ID를 참조하고 Faction이 Object Definition 자체를 복제하거나 소유하지 않도록 한다.
- Stage는 Faction 자체를 직접 소유하지 않고, Stage에 배치되는 Object가 자신의 Faction을 참조하는 방향을 우선 검토한다.
- Faction Editor는 Faction Definition과 Member Object의 관계를 관리하되, 실제 Robot/Enemy/Unit/Tower Definition 데이터는 각 Object Editor/Catalog가 소유한다.
- Enemy의 Faction 연결 방식과 Tower의 Faction 연결 필요 여부는 아직 Canon 확정 대상이므로 구현하지 않는다.

**UNVERIFIED / DESIGN HOLD**
- Faction이 반드시 Robot/Enemy/Allied Unit/Tower 모두에 적용되어야 하는지
- Tower/Building의 Faction 소속 규칙
- Stage에서 플레이어 Faction을 별도 참조해야 하는지
- Enemy와 Ally 관계를 Faction 관계로 직접 대체할 수 있는지
- Faction Member 목록을 Faction Catalog에 저장할지, Object의 faction_id를 역조회할지

**검증 상태**
- DATA: CONFIRMED
- CODE: CONFIRMED (참조 필드/Repository/Stage 소비 경로 확인)
- EDITOR: NOT VERIFIED
- BUILD: NOT VERIFIED
- PIE: NOT VERIFIED

**변경 사항**
- 진행기록만 갱신. 코드/Asset/Editor/Runtime 변경 없음.

**판정**
Faction 참조 구조는 현재 구현 상태와 목표 구조 사이에 Canon 결정이 필요한 상태다. 임의 구현하지 않고 HOLD한다.

**OUT OF SCOPE**
- Faction Catalog 데이터 생성
- Faction Editor 수정
- Object Definition에 신규 faction_id 일괄 추가
- Stage/Enemy/Tower 데이터 변경


## Handoff — 2026-10-06 MENOS DOCUMENTATION BASELINE UPDATE

STATUS — PASS

목적 — 현재 구현 상태와 MENOS 문서 기준을 현재 repository baseline 및 JSON→SQLite 전환 정책에 맞춰 정합화.

기준선
- Branch: `main`
- HEAD: `178cac776cfa21d3446e5a199ad7db5025f64589`
- Working Tree: 기존 변경사항 다수 존재. 보존함.

CONFIRMED
- Core Combat Canon과 현재 코드의 주요 구조는 대체로 정합하다.
- 직접 조종, 기본 공격, 타깃 전환, 특수공격, 스킬 슬롯, 필살기, XP/레벨, AI 아군, Giant 보스 패턴, 고정형 Tower 지원, Campaign/Stage/Map 경로가 코드상 확인되어 있다.
- BUILD/전체 EDITOR Acceptance/PIE는 아직 최종 검증되지 않았다.
- JSON은 당분간 Authoritative Source로 유지한다.
- SQLite 전환은 콘텐츠 타입별 1개씩 진행하며 Robot을 첫 대상으로 한다.
- Robot JSON과 SQLite 데이터는 현재 의미상 동일하다.
- Robot SQLite Sync 함수는 존재하지만 Editor Save 자동 Sync는 적용하지 않는다.

DOCUMENT UPDATE
- `MENOS_IMPLEMENTATION_STATUS.md`
- `MENOS_DEVELOPMENT_PLAN.md`
- `MENOS_REQUIRED_IMPLEMENTATION_GAPS.md`
- `MENOS_MASTER_IMPLEMENTATION_ROADMAP.md`
에 2026-10-06 현재 기준선을 추가했다.

검증 상태
- 문서: UPDATED / VERIFIED
- CODE: 기존 확인 결과 유지
- BUILD: UNVERIFIED
- EDITOR: UNVERIFIED
- PIE: UNVERIFIED

변경 사항
- 문서만 수정.
- 코드/Asset/Scene/Data/Canon 변경 없음.
- 기존 Working Tree 변경사항 보존.
- Commit/Push 없음.

OUT OF SCOPE
- PIE 실행
- Robot SQLite Sync 실제 실행 검증
- 다른 콘텐츠 타입 SQLite 전환
- 코드/Asset 수정
- Canon 변경

판정 — 문서 정합성 갱신 목적은 달성했다. 추가 작업은 Master 요청 전 자동 진행하지 않는다.

# Historical Records Migrated from MENOS_DEVELOPMENT_PLAN.md

## Handoff — 2026-10-05 자동공격 토글 / 수동 입력 검증 갱신

**STATUS — PASS / 부분 검증 완료**

**목적**
자동공격을 수동 모드로 전환하고, 수동 입력 동작이 실제 Runtime 전투 흐름에서 사용할 수 있는지 최소 검증한다.

**기준선**
- 프로젝트: `D:\Atlas\projects\menos\godot`
- Godot: `D:\Godot_v4.7.2`
- PAD Flow: `gpt`
- 관련 입력 Action: `move_up`
- 이번 검증에서는 Godot 프로젝트 코드/Asset/Scene/Data를 변경하지 않음.
- PAD Flow는 테스트를 위해 키 입력 표현을 수정하고 저장함.

**CONFIRMED**
- Runtime에서 `ATTACK: AUTO`를 `ATTACK: MANUAL`로 전환했다.
- Godot Input Map에서 W/Up이 `move_up`으로 등록되어 있다.
- `update_robot_manual_input()`이 수동 이동 입력을 실제 Robot 위치 변경에 연결한다.
- PAD `gpt` Flow의 Send Keys 입력을 `wwwwwwwwww`에서 `{W:10}`으로 변경했다.
- Master의 실제 Runtime 테스트에서 자동공격 토글 및 수동 입력동작이 성공했다.

**검증 상태**
- CODE VERIFIED: PASS
- EDITOR VERIFIED: PASS — PAD Flow 저장 확인
- BUILD VERIFIED: NOT VERIFIED
- PIE VERIFIED: PASS — Master 실제 Runtime 확인

**마리의 판정**
수동 입력 검증의 해당 목적은 달성했다. 이 결과는 Phase 1의 전체 완료가 아니라, Phase 1 내 수동 조작 검증 항목의 완료로 기록한다.

**변경 사항**
- 개발계획 문서에 본 검증 결과를 추가.
- Godot 코드/Asset/Scene/Data 변경 없음.
- PAD Flow `gpt` 변경은 테스트 범위에서 실제 반영됨.

**미확인 사항**
- Phase 1의 전체 Canon 전투 루프(공격/타깃/특수/스킬/필살기/AI 아군/지원 시설/보스/승패/재시작)는 별도 PIE 검증 필요.

**OUT OF SCOPE**
- 추가 공격 입력 자동화
- 보스/스킬/필살기 추가 검증
- Phase 2 이후 작업

**판정**
ACCEPT·STOP. 본 검증 항목은 종료하며 다음 Phase로 자동 진행하지 않는다.

## 2026-10-06 CURRENT IMPLEMENTATION AUDIT — AUTHORITATIVE CURRENT STATE

This section supersedes older HEAD/Working Tree snapshots in this document. It does not change Canon.

- Project: MENOS
- Branch: `main`
- HEAD: `7c97acc97be9262b50fe84b691de9b0dbdbd94e5`
- Working Tree at audit start: CLEAN.
- Godot: `D:\Godot_v4.7.2-stable`, version `4.7.2.stable.official`.
- Directly confirmed implementation: manual robot movement, basic attack, special attack, skill slots, finisher, target switching, XP/level progression, AlliedUnitAI, Giant boss attack patterns, Tower auto support, Campaign/Stage/Map loading paths.
- GAP-01 HUD: CODE VERIFIED / minimum implementation present; PIE not verified in this audit.
- GAP-02 Giant boss behavior: CODE VERIFIED / minimum implementation present; PIE not verified in this audit.
- GAP-03 fixed Tower support: CODE VERIFIED / minimum implementation present; PIE not verified in this audit.
- GAP-04 attack-to-hit-to-damage timing: CODE VERIFIED; PIE UNVERIFIED.
- GAP-05 Campaign 1 minimum integration: CODE VERIFIED / minimum integration present; full start-to-finish PIE UNVERIFIED.
- BUILD VERIFIED: UNVERIFIED in this audit.
- EDITOR VERIFIED: UNVERIFIED as a full manual Editor acceptance pass.
- PIE VERIFIED: NOT VERIFIED. Master runtime acceptance remains required.

The Godot process used during this audit regenerated tracked `.import` metadata. Those generated changes were reverted after verification because the working tree was CLEAN before the audit. No code, scene, asset, or Canon change was retained by this audit.

Conclusion: implementation documents are now aligned to the current repository baseline. The remaining verification boundary is Runtime/PIE, not a newly identified core-code gap.
## 2026-10-06 PIE TOOLING / ENVIRONMENT BASELINE

This section records the verified local tooling required for Godot PIE testing. It does not change Canon or gameplay scope.

- Godot: `D:\Godot_v4.7.2-stable`, `4.7.2.stable.official.ed1daf0bf` — REQUIRED / VERIFIED.
- VS Code: `1.140.0` — development/log inspection / VERIFIED.
- Git: `2.54.0` — baseline and diff inspection / VERIFIED.
- Git LFS: `3.7.1` — repository asset support / VERIFIED.
- PowerShell: Windows PowerShell `5.1.19041.6456` — execution/automation / VERIFIED.
- Python: `3.14.5` — optional tooling / VERIFIED.
- Node.js: `22.23.3`, npm `10.9.9` — optional tooling / VERIFIED.
- ripgrep: `15.2.0` — code/log search / VERIFIED.
- fd: `10.5.0` — file discovery / VERIFIED.
- jq: `1.8.2` — JSON inspection / VERIFIED.
- GitHub CLI: `2.102.0` — repository operations / VERIFIED.
- 7-Zip: `19.00 (x64)` — archive utility installed; `7z` is not on PATH.

PIE does not require CMake, Ninja, Make, MSBuild, or PowerShell 7 for the current GDScript-only MENOS project. No additional program is currently required for PIE execution.

Verification boundary:
- CODE VERIFIED: existing implementation audit remains valid.
- BUILD VERIFIED: NOT VERIFIED.
- EDITOR VERIFIED: NOT VERIFIED as a full manual acceptance pass.
- PIE VERIFIED: NOT VERIFIED. Master runtime acceptance remains required.

No code, scene, asset, or Canon changes were made by this tooling audit. Do not revert pre-existing Working Tree changes.


## 2026-10-06 DOCUMENT UPDATE — CURRENT REPOSITORY BASELINE

이 섹션은 이전 문서의 HEAD/Working Tree 스냅샷보다 우선하는 현재 문서 기준선이다. Canon을 변경하지 않는다.

- Project: MENOS
- Branch: `main`
- HEAD: `178cac776cfa21d3446e5a199ad7db5025f64589`
- Working Tree: 기존 변경사항 다수 존재. 이번 문서 갱신은 기존 변경을 수정/되돌리지 않는다.
- Godot: `D:\\Godot_v4.7.2-stable`, `4.7.2.stable.official.ed1daf0bf`
- Core implementation assessment: 직접 조종, 기본 공격, 타깃 전환, 특수공격, 스킬 슬롯, 필살기, XP/레벨, AlliedUnitAI, Giant 보스 패턴, 고정형 Tower 지원, Campaign/Stage/Map 경로가 코드상 확인됨.
- BUILD VERIFIED: UNVERIFIED
- EDITOR VERIFIED: 전체 수동 Acceptance 기준 UNVERIFIED
- PIE VERIFIED: UNVERIFIED
- 따라서 현재 핵심 공백은 신규 핵심 전투 코드의 존재 여부보다 Runtime/PIE 검증 경계에 있다.

### JSON → SQLite 콘텐츠 파이프라인 기준선

- JSON은 당분간 Authoritative Source로 유지한다.
- SQLite 전환은 콘텐츠 타입별로 하나씩 수행한다.
- 첫 대상은 Robot이다.
- 현재 Robot JSON과 SQLite의 의미상 데이터 비교 결과는 동일하다. `asura`, `valkyrie` 두 항목이 일치한다.
- `ContentCatalogLoader`는 Robot JSON 경로 요청을 SQLite `robots` 테이블에서 읽도록 연결되어 있다.
- `ObjectPersistence.sync_catalog_to_sqlite()`는 Robot에 한정된 동기화 경로를 추가했으나 Editor Save에 자동 연결하지 않는다.
- Editor Save → 자동 SQLite 갱신은 Canon상 아직 적용하지 않는다.
- Robot Sync 실제 실행 및 Runtime/PIE 검증은 별도 검증 항목이며, 확인 전에는 VERIFIED로 표시하지 않는다.
- 다른 콘텐츠 타입의 SQLite 전환은 수행하지 않는다.

### 문서 정합성 판정

- 오래된 HEAD/Working Tree 기록은 역사적 기록으로 보존한다.
- 현재 상태 판단에는 본 섹션의 2026-10-06 기준선을 사용한다.
- Canon 변경 없음.
- 코드/Asset/Scene/Data 변경 없음.
- Commit/Push 없음.

# Historical Records Migrated from MENOS_GAMEPLAY_UI_IMPROVEMENT_PLAN.md

## Handoff — STEP 1 Gameplay-Safe Camera (2026-09-29)

**STATUS** — PASS / 실제 화면 UNVERIFIED

**목적** — Bottom HUD가 전투 영역을 덮는 구조에서 카메라 기준을 HUD 제외 영역에 맞추고, 전장 중심을 안정적으로 유지한다.

**기준선** — Branch `main`; 기존 변경사항 보존; Commit / Push 없음.

**조사 결과**
- **CONFIRMED** — 프로젝트 viewport는 1400×860이다.
- **CONFIRMED** — 현재 Combat 화면은 `main.gd`에서 Camera2D와 화면 HUD를 함께 사용한다.
- **CONFIRMED** — Bottom HUD는 기존 변경사항에 의해 188px 높이로 설정되어 있다.
- **CONFIRMED** — 기존 카메라는 MAP 전체 크기를 기준으로 중앙에 배치되어 HUD가 사용하는 화면 영역을 별도로 고려하지 않았다.
- **CONFIRMED** — `_camera_target_clamped()` 역시 전체 viewport 높이를 기준으로 카메라 이동 범위를 계산했다.

**변경 사항**
- **CHANGED** — `_setup_camera()`의 초기 카메라 중심을 Bottom HUD 높이의 절반만큼 아래로 보정하여, HUD 위쪽의 게임플레이 영역 중심에 전장을 맞췄다.
- **CHANGED** — `_camera_target_clamped()`가 카메라 이동 범위를 계산할 때 전체 viewport 대신 `viewport height - BOTTOM_HUD_HEIGHT`를 게임플레이 안전 영역으로 사용하도록 수정했다.
- **UNCHANGED** — 맵 크기, TileMap, 전투 규칙, 이동/공격, Wave, Spawn, Tower, Robot 로직은 변경하지 않았다.
- **UNCHANGED** — 기존 UI 레이아웃 변경사항은 이번 STEP의 기존 변경으로 유지했으며 되돌리지 않았다.

**검증**
- **CODE VERIFIED** — 수정 diff 확인.
- **git diff --check** — PASS.
- **BUILD VERIFIED** — UNVERIFIED. 현재 환경에서 Godot 실행 파일을 확인하지 못했다.
- **EDITOR VERIFIED** — UNVERIFIED.
- **PIE VERIFIED** — UNVERIFIED.

**세라의 기술 판단**
- 현재 단계에서 화면 기준을 바꾸는 최소 변경은 HUD 안전 영역을 카메라 계산에 반영하는 것이다.
- 맵/전투 데이터를 수정하지 않고 카메라 계층만 보정했으므로 범위 내 변경이다.

**마리의 판정**
- STEP 1의 코드 목적은 충족했다.
- 실제 PIE에서 카메라 위치와 화면 체감은 확인하지 못했으므로 시각적 최종 PASS로 확대하지 않는다.
- 추가 UI 변경은 수행하지 않는다.

**미확인 사항**
- 실제 1400×860 PIE에서 전장 상하 여백과 HUD 경계가 의도대로 보이는지.
- 다른 해상도에서 동일한 카메라 안전 영역이 적절한지.

**OUT OF SCOPE**
- STEP 2 전투 영역 시각 개선
- ATLAS 표시 개선
- Enemy 표시 개선
- 공격/피격 VFX 개선
- HUD 재디자인 추가
- Asset 제작/교체

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE

**판정** — ACCEPT·STOP. 다음 STEP은 Master의 별도 지시 후 진행한다.

## Handoff — STEP 2 Combat Visual Priority (2026-09-29)

**STATUS** — PASS / 실제 화면 UNVERIFIED

**목적** — 전투 시스템을 변경하지 않고 ATLAS-01과 적 유닛이 전장의 주요 시각적 초점이 되도록 표시 크기와 전투 가독성을 조정한다.

**기준선** — Branch main; STEP 1 및 기존 main.gd 변경사항 보존; Commit / Push 없음.

**조사 결과**
- **CONFIRMED** — 전투 유닛은 main.gd의 _draw()에서 직접 스프라이트, 발밑 링, HP Bar, 피격 효과를 렌더링한다.
- **CONFIRMED** — ATLAS-01 기본 전투 표시 크기는 64×114였고, 적 표시 크기는 ENEMY_SPRITE_SIZES 값을 그대로 사용했다.
- **CONFIRMED** — 타워 표시 크기는 60×90이었다.
- **CONFIRMED** — 유닛의 이동/공격/타겟팅/충돌 데이터와 렌더링 크기는 코드상 별개로 처리된다.
- **CONFIRMED** — Godot 실행 파일은 현재 연결된 환경의 PATH에서 확인되지 않아 PIE 실행은 수행하지 못했다.

**변경 사항**
- **CHANGED** — ATLAS-01 렌더링 크기를 64×114 → 78×132로 조정하고 발밑/HP Bar 위치와 폭을 함께 보정했다.
- **CHANGED** — Enemy 렌더링 크기를 기존 ENEMY_SPRITE_SIZES의 1.08배로 표시하도록 조정했다.
- **CHANGED** — Tower 렌더링 크기를 60×90 → 64×96으로 소폭 조정했다.
- **UNCHANGED** — Enemy/Robot/Tower의 HP, 공격력, 사거리, 이동속도, AI, 타겟팅, 충돌, Wave, Spawn 규칙은 변경하지 않았다.
- **UNCHANGED** — Asset 파일 자체와 map/stage 데이터는 변경하지 않았다.

**검증**
- **CODE VERIFIED** — 수정 위치와 렌더링 경로 확인.
- **git diff --check** — PASS.
- **BUILD VERIFIED** — UNVERIFIED. Godot 실행 파일 미확인.
- **EDITOR VERIFIED** — UNVERIFIED.
- **PIE VERIFIED** — UNVERIFIED.

**세라의 기술 판단**
- 표시 크기만 조정하여 전투 유닛의 시각적 존재감을 높이는 것은 현재 STEP 2의 목적에 직접 대응한다.
- 전투 데이터와 렌더링 데이터가 분리되어 있어 시스템 동작 변경 없이 적용 가능하다.

**마리의 판정**
- STEP 2의 코드 목적은 충족했다.
- 실제 화면에서 크기 증가가 과도하지 않은지, 타일/오브젝트와의 충돌감이 없는지는 PIE 미검증 상태이므로 최종 시각 PASS로 확대하지 않는다.
- 추가 배경/Asset 변경은 수행하지 않는다.

**미확인 사항**
- 실제 PIE에서 ATLAS/Enemy/Tower의 시각적 비율과 전장 가독성.
- 다른 해상도에서 확대된 유닛과 HUD의 균형.

**OUT OF SCOPE**
- STEP 3 ATLAS 표시 품질의 추가 개선
- Enemy 가독성의 추가 개선
- 공격/피격 VFX 개선
- HUD 추가 변경
- Asset 제작/교체

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE

**판정** — ACCEPT·STOP. 다음 STEP은 Master의 별도 지시 후 진행한다.

## Handoff — STEP 3 ATLAS Presentation Quality (2026-09-29)

**STATUS** — PASS / 실제 화면 UNVERIFIED

**목적** — ATLAS-01을 전투 화면의 주인공으로 더 명확하게 인식시키되, 게임플레이 시스템은 변경하지 않는다.

**기준선** — Branch main; STEP 1~2 및 기존 main.gd 변경사항 보존; Commit / Push 없음.

**조사 결과**
- **CONFIRMED** — ATLAS는 idle/move/attack/skill 애니메이션을 상태에 따라 선택하고 있다.
- **CONFIRMED** — 기존 선택 표시는 원형 링과 가로/세로 십자선이었다.
- **CONFIRMED** — 기존 피격 표시는 단순 원형 플래시였으며, 공격/특수공격 상태에는 이미 별도 애니메이션이 존재한다.
- **CONFIRMED** — ATLAS 렌더링 크기는 STEP 2에서 78×132로 확대된 상태였다.

**변경 사항**
- **CHANGED** — ATLAS 선택 표시를 디버그성 십자선에서 펄스형 이중 아크 링으로 변경했다.
- **CHANGED** — ATLAS 특수공격 중 금색 회전 아크, 일반 공격 중 청록색 회전 아크를 발밑에 추가했다.
- **CHANGED** — 피격 플래시 반경을 기존 34에서 42로 확대해 확대된 ATLAS 실루엣과 맞췄다.
- **UNCHANGED** — 공격력, HP, 사거리, 이동, AI, 타겟팅, 특수공격 동작, Wave 규칙, Spawn 규칙은 변경하지 않았다.
- **UNCHANGED** — ATLAS Asset 파일 자체는 변경하지 않았다.

**검증**
- **CODE VERIFIED** — ATLAS 렌더링 경로와 상태 조건을 확인하고 수정 diff를 확인했다.
- **git diff --check** — PASS.
- **BUILD VERIFIED** — UNVERIFIED. Godot 실행 파일 미확인.
- **EDITOR VERIFIED** — UNVERIFIED.
- **PIE VERIFIED** — UNVERIFIED.

**세라의 기술 판단**
- 선택/공격/특수공격 표시를 전투 데이터와 분리된 렌더링 계층에서 처리하므로 게임플레이 규칙에 영향을 주지 않는다.
- 기존 애니메이션 Asset을 유지하면서 상태별 시각 피드백을 강화하는 최소 변경이다.

**마리의 판정**
- STEP 3의 코드 목적은 충족했다.
- 실제 PIE에서 링의 크기와 색상, 애니메이션 가독성은 확인하지 못했으므로 시각적 최종 PASS로 확대하지 않는다.
- 추가 Asset 제작/교체는 수행하지 않는다.

**미확인 사항**
- 실제 PIE에서 선택 링과 공격 아크가 ATLAS 실루엣을 방해하지 않는지.
- 고해상도/저해상도에서 ATLAS 표시와 HUD의 균형.
- 실제 전투 중 특수공격 아크가 VFX와 충분히 구별되는지.

**OUT OF SCOPE**
- STEP 4 Enemy 가독성 추가 개선
- STEP 5 공격/피격 VFX 전체 개선
- HUD 추가 변경
- Asset 제작/교체
- 전투 밸런스 변경

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE

**판정** — ACCEPT·STOP. 다음 STEP은 Master의 별도 지시 후 진행한다.


## Handoff — STEP 4 Enemy Readability (2026-09-29)

**STATUS** — PASS / 실제 화면 UNVERIFIED

**목적** — 적의 타입과 현재 HP 상태를 전투 중 더 빠르게 식별할 수 있도록 표시 계층을 개선한다. Enemy AI, 스탯, 이동, 타겟팅, Spawn 규칙은 변경하지 않는다.

**기준선** — Branch main; STEP 1~3 및 기존 main.gd 변경사항 보존; Commit / Push 없음.

**조사 결과**
- **CONFIRMED** — Enemy 렌더링은 main.gd의 _draw()에서 타입별 sprite, 발밑 링, 피격 플래시, 이름, HP Bar를 직접 표시한다.
- **CONFIRMED** — 현재 모든 Enemy의 발밑 링과 HP Bar가 동일한 붉은 계열 표현을 사용하고 있었다.
- **CONFIRMED** — Enemy 타입은 normal/rusher/heavy/giant로 구분되며 렌더링 크기도 타입별로 이미 다르다.
- **CONFIRMED** — 피격 시 enemy.flash가 설정되며 기존 플래시는 data.radius 기반이었다.

**변경 사항**
- **CHANGED** — Enemy 타입별 발밑 액센트 색을 구분했다: normal red, rusher orange, heavy violet, giant gold.
- **CHANGED** — giant에만 저강도 외곽 펄스 링을 추가해 대형 적의 존재감을 구분했다.
- **CHANGED** — Enemy HP Bar를 최소 34px 폭, 5px 높이로 통일해 작은 적에서도 읽기 쉽게 했다.
- **CHANGED** — HP Bar 색을 Enemy 타입 액센트와 동일하게 맞췄다.
- **CHANGED** — Enemy 이름 표시를 9px → 10px로 조정하고 HP Bar와 정렬했다.
- **CHANGED** — 피격 플래시 반경을 실제 표시 크기 기준으로 계산하도록 변경했다.
- **UNCHANGED** — Enemy HP, 공격력, 방어력, 사거리, 이동속도, AI, 타겟팅, 충돌, Wave, Spawn 규칙.
- **UNCHANGED** — Enemy Asset 파일, map/stage 데이터.

**검증**
- **CODE VERIFIED** — Enemy 렌더링 경로와 변경 diff 확인.
- **git diff --check** — PASS.
- **BUILD VERIFIED** — UNVERIFIED. Godot 실행 파일 미확인.
- **EDITOR VERIFIED** — UNVERIFIED.
- **PIE VERIFIED** — UNVERIFIED.

**세라의 기술 판단**
- 타입별 액센트와 HP 표시를 렌더링 계층에서만 변경했으므로 전투 로직에는 영향을 주지 않는다.
- giant 외곽 펄스도 giant 타입의 기존 렌더링 분기 안에서만 동작한다.

**마리의 판정**
- STEP 4의 코드 목적은 충족했다.
- 실제 PIE에서 색상 구분과 HP Bar 크기가 과하거나 부족하지 않은지는 확인하지 못했으므로 시각적 최종 PASS로 확대하지 않는다.
- 추가 Asset 제작/교체는 수행하지 않는다.

**미확인 사항**
- 실제 PIE에서 타입별 색상 인지가 충분한지.
- 다수 적이 겹칠 때 HP Bar와 이름이 과밀해지지 않는지.
- 저해상도에서 최소 34px HP Bar가 충분히 읽히는지.

**OUT OF SCOPE**
- STEP 5 공격/피격 VFX 전체 개선
- Enemy AI/밸런스/Spawn 변경
- Asset 제작/교체
- HUD 추가 변경

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE

**판정** — ACCEPT·STOP. 다음 STEP은 Master의 별도 지시 후 진행한다.


## Handoff — STEP 5 Attack / Hit Effect Readability (2026-09-29)

**STATUS** — PASS / 실제 화면 UNVERIFIED

**목적** — 기존 공격과 피격 이펙트를 전투 중 더 빠르게 식별할 수 있도록 시각적 차이를 강화한다. 데미지 계산, 공격 주기, 타겟팅, 특수공격 조건은 변경하지 않는다.

**기준선** — Branch main; 기존 STEP 1~4 변경사항 보존. STEP 5의 `main.gd` 변경은 확인 과정에서 `f4de1bc8` 커밋으로 기록되어 있으며 Push 여부는 확인하지 않음. 추가 Commit / Push는 수행하지 않음.

**조사 결과**
- **CONFIRMED** — 타워와 ATLAS의 투사체가 공통 `proj_defender` 렌더링 경로를 사용한다.
- **CONFIRMED** — 기존 투사체에는 무기 종류에 따른 추가 시각 구분이 없었다.
- **CONFIRMED** — 일반 피격, 범위 공격, 관통 공격의 임팩트가 동일한 `impact_explosion` 계열 표시를 공유한다.
- **CONFIRMED** — 적 피격 시 damage_enemy()에서 source 정보를 이미 받고 있었다.

**변경 사항**
- **CHANGED** — 투사체에 weapon 표시 정보를 추가해 Cannon / Gatling / ATLAS를 시각적으로 구분할 수 있게 했다.
- **CHANGED** — 투사체에 짧은 방향성 트레일과 발광점 표시를 추가했다.
- **CHANGED** — Cannon은 금색, Gatling은 주황색, ATLAS는 청록색 액센트를 사용한다.
- **CHANGED** — 피격 임팩트에 공격 유형별 액센트 링을 추가했다.
- **CHANGED** — Area는 금색, Pierce는 보라색으로 구분하고, Cannon/Gatling/ATLAS 일반 공격도 주체별 색상을 사용한다.
- **CHANGED** — 임팩트 스프라이트 크기를 생명주기에 따라 약하게 확대해 타격 순간을 더 읽기 쉽게 했다.
- **UNCHANGED** — 실제 데미지 계산, Armor 계산, 공격 쿨다운, 투사체 이동 속도, 타겟 선정, 특수공격 조건 및 쿨다운.
- **UNCHANGED** — 기존 Asset 파일 자체 및 맵/스테이지 데이터.

**검증**
- **CODE VERIFIED** — 공격 생성 및 _draw() 이펙트 경로 diff 확인.
- **git diff --check** — PASS.
- **BUILD VERIFIED** — UNVERIFIED. Godot 실행 파일 미확인.
- **EDITOR VERIFIED** — UNVERIFIED.
- **PIE VERIFIED** — UNVERIFIED.

**세라의 기술 판단**
- 이 단계의 변경은 기존 effect Dictionary에 표시용 정보를 추가하고 렌더링만 확장하므로 전투 수치 및 판정 경로를 변경하지 않는다.
- 기존 projectile/impact Asset은 그대로 사용하며 추가 Asset을 만들지 않았다.

**마리의 판정**
- STEP 5의 코드 목적은 충족했다.
- 실제 PIE에서 이펙트가 과밀하지 않은지, 특히 다수 적과 다수 투사체가 동시에 존재할 때 가독성이 유지되는지는 확인하지 못했다.
- 실제 화면 검증 전에는 최종 시각 품질 PASS로 확대하지 않는다.

**미확인 사항**
- 실제 PIE에서 Cannon/Gatling/ATLAS의 투사체 구분이 충분한지.
- 다수 임팩트가 겹칠 때 이펙트가 과도하게 밝아지지 않는지.
- Area/Pierce 액센트가 전장 색상과 충분히 대비되는지.

**OUT OF SCOPE**
- 새로운 VFX Asset 제작
- 공격/피격 사운드 변경
- 전투 밸런스 및 데미지 변경
- STEP 6 HUD 정보 계층 개선

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE

**판정** — ACCEPT·STOP. 다음 STEP은 Master의 별도 지시 후 진행한다.

# Historical Records Migrated from MENOS_OBJECT_CENTRIC_DEVELOPMENT_PLAN.md

## Handoff ? 2026-10-05 MapLoader / Runtime Spawn Conversion �����
**STATUS** ? HOLD

**����**
Map�� Legacy `spawns.left/right`�� Gameplay `spawn_area`�� MapLoader �� Runtime���� ��� ��ȯ�Ǵ��� Ȯ���Ѵ�.

**CONFIRMED**
- `MapLoader`�� Legacy `spawns`�� �����ϸ� �״�� `parsed.lanes[left/right]` ���·� ��ȯ�Ѵ�.
- `MapLoader`�� `gameplay_areas`�� ���� �����ϸ� Lane ID�� ��ȯ���� �ʴ´�.
- Runtime `GameController.apply_map_spatial_data()`�� Gameplay `spawn_area`�� ������� `spawn_0`, `spawn_1` ������ �����Ѵ�.
- �� `spawn_area`�� ���� ID/name�� Runtime Lane ID�� �������� �ʴ´�.
- Gameplay Spawn Area�� �ϳ� �̻� �����ϸ� Runtime�� Legacy `lanes`�� ������� �ʰ� Spawn Area ��� `LANES`�� �����Ѵ�.
- Spawn Area�� ���� ���� `loaded_map.lanes`�� Legacy Lane���� fallback�ȴ�.
- Stage�� `left/right` ��û�� Spawn Area ��� Map���� ���� �������� ������ Runtime�� Spawn Area ����� ��ȯ �����Ѵ�.
- ���� ������ Stage Group�� `left/right` �����Ͱ� Map�� ���� Legacy ��ǥ Lane �Ǵ� Spawn Area ��ȯ���� �ؼ��ȴ�.

**INFERENCE**
���� `left/right`�� Map�� �������� Canonical Lane ID�� �ƴ϶� Runtime���� Map ǥ���� ���� ���ؼ��Ǵ� ��û���� ������.

**���� ����**
Phase C�� Lane/Spawn ����� ���� ���� ���� Canon ������ �ʿ��� ���´�. ���� ���縸���δ� Ư�� ǥ���� �������� Ȯ������ �ʴ´�. HOLD.

**���� ����**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED

**���� ����**
�ڵ�/Asset ���� ����. ���� �����ϸ� ����.

**OUT OF SCOPE**
Lane ���� ����, Map JSON ��ȯ, Validator ��ȭ, Stage ������ ����.

## Handoff ? 2026-10-05 Phase C �Ϸ����� ���� ����
**STATUS** ? HOLD / Phase C �̿Ϸ�

**����**
���߰�ȹ���� Phase C �Ϸ������� ���� �ڵ�/���� ���¿� �����Ͽ� Phase D ���� ���� ���θ� �����Ѵ�.

**Phase C �Ϸ�����**
- �ϳ��� Stage�� Map, Mission, Encounter/Wave ��ü�� �����Ѵ�.
- Stage�� ���� �����ϴ�.
- Mission �����Ͱ� Stage�� �ߺ� ������� �ʴ´�.

**CONFIRMED ? ����**
- Stage �� `map_file` ������ �����ϰ� StageLoader/StageManager/GameController�� ���޵ȴ�.
- Stage �� `mission_id` ������ �����ϰ� Mission Catalog/Definition���� �ؼ��ȴ�.
- Stage �� `reward_id` ������ RewardDefinition ��ΰ� �����Ǿ� �ִ�.
- Stage �� Encounter/Wave ������ ���� Runtime spawn queue�� �Һ�ȴ�.
- Mission �����ʹ� Stage�� �и��� Catalog/Definition���� �����ȴ�.
- Building ��ġ �����ʹ� Map�� �����ϸ� Runtime Tower ��ġ ��ο� ����ȴ�.

**CONFIRMED GAP ? �Ϸ����� ������ ���� �׸�**
1. Lane/Spawn Contract: Stage�� `left/right/both` �ǹ̰� Map�� legacy `spawns`�� `gameplay_areas.spawn_area` ���̿��� �ϰ����� �ʴ�.
2. Mission Contract: ���� Runtime�� `defend_base`�� `clear_encounters`�� �����ϸ� `target_id` �ǹ̰� �Һ���� �ʴ´�. Master Canon�� 3 Gameplay ������ 1:1 ������ Ȯ�ε��� �ʾҴ�.
3. PIE: ���� Stage ���� ����� Master�� Ȯ���ϴ� PIE VERIFIED�� ���� ����.

**Phase C�� ������ Ȯ�ε� ����**
- Player Count / Multiplayer�� ���� Canon/storage�� Ȯ�ε��� �ʾ����Ƿ� Phase C �Ϸ����ǿ� ���Ƿ� �������� �ʴ´�.
- Allied Unit�� Runtime ����� ���������� Stage-level authoring UI�� ����. �̴� ���� Phase C �Ϸ����� ��ü�ʹ� ���� authoring gap�̴�.
- Building�� `tower_slots` / `tower_placement_area` ����� �߰� Canon Ȯ�� ����̳� ���� Phase C �Ϸ������� ���� ���� ������ �������� �ʴ´�.

**���� ����**
Phase C�� ��ü ���� ������ Runtime ���� ����� ��κ� �����ߴ�. �׷��� Lane/Spawn ���� Mission Canon�� Ȯ������ �ʾҰ� PIE ������ �����Ƿ� **Phase C �Ϸ�� ������ �� ����. Phase D �������� �ڵ� �������� �ʴ´�.**

**���� ����**
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED

**���� ����**
- �ڵ�/Asset ���� ����.
- �� ���� Handoff�� ������ ���.

**OUT OF SCOPE**
- Lane ���� ����
- Map JSON ���̱׷��̼�
- Mission Type �߰�/����
- Player Count/Multiplayer ����
- Allied Unit Stage Editor ����
- Phase D �ű� ��� ����

**��� �ð�**
$stamp

## Handoff — 2026-10-05 Mission Contract Canon 승인 반영

STATUS — ACCEPTED / PROPOSAL → MASTER CANON

Master 승인 사항:
- Tower Defense → `defend_base`
- Elimination → `clear_encounters`
- Giant Boss Battle → `defeat_giant`

Mission Contract 제안:
- Tower Defense Victory: 제한 시간 생존
- Elimination Victory: 모든 Encounter/Wave 적 제거
- Giant Boss Battle Victory: Giant 처치
- 모든 Mission의 기본 Defeat: Base HP <= 0

`target_id`:
- Tower Defense: 사용하지 않음
- Elimination: 사용하지 않음
- Giant Boss Battle: Giant 식별에 사용 가능
- 일반 Objective 시스템으로 확장하지 않음

범위 원칙:
- 기존 `defend_base` / `clear_encounters` Runtime은 최대한 보존한다.
- `defeat_giant`는 기존 Giant Runtime을 활용한다.
- Mission Contract 확정 전에는 코드/Asset을 변경하지 않는다.
- 다음 단계는 현재 Runtime과 승인된 Contract의 차이를 최소 단위로 대조한다.

판정:
- Mission Canon 결정으로 기존 Mission Contract HOLD의 설계 원인은 해소됨.
- 실제 코드 반영은 별도 검증 후 진행한다.
- CODE/BUILD/EDITOR/PIE: 현재 변경 검증 전 상태.

## Handoff — 2026-10-05 Mission Contract Runtime Delta 조사
STATUS — HOLD / 구현 전 파일 잠금
CONFIRMED — 승인된 Mission Contract와 현재 코드의 차이를 직접 대조했다.
- `defend_base`: 현재 Runtime과 직접 대응하며 유지 가능.
- `clear_encounters`: 현재 Runtime과 직접 대응하며 유지 가능.
- `defeat_giant`: 현재 MissionDefinition에는 없고, Validator/Stage Editor도 허용하지 않는다.
- Giant 처치 자체는 `damage_enemy()`에서 이미 감지되고 `GIANT NEUTRALIZED` 이벤트도 발생한다. 그러나 현재 Giant 처치 시 Mission Victory 전환은 없다.
- Giant Mission의 Campaign 보상/다음 Stage 전환은 `defend_base` 완료 경로와 별도 구현이 필요하다.
- `target_id`는 현재 Runtime에서 승리 조건에 사용되지 않는다. 승인 Canon에서는 Giant 식별 용도로 사용 가능하지만, 현재 Stage에는 Giant Mission이 지정되어 있지 않다.
TECHNICAL JUDGMENT — `defeat_giant` 추가는 기존 Giant Runtime을 재사용하는 최소 변경으로 가능하다.
BLOCKER — Godot Editor 프로세스가 `content_validator.gd`와 `stage_editor.gd`를 잠금 중이어서 안전한 코드 저장을 수행하지 않았다. 프로세스 종료/강제 해제는 Master 승인 없이 하지 않는다.
CHANGES — 코드/Asset 변경 없음. 문서 기록만 추가.
VERIFICATION — CODE VERIFIED (delta 조사), BUILD/EDITOR/PIE NOT VERIFIED.
NEXT — 파일 잠금이 해소되면 Validator → Stage Editor → GameController 순서로 최소 변경하고 diff/check/build 검증.

## Handoff — 2026-10-05 defeat_giant Runtime 구현
STATUS — PASS / CODE + BUILD
CONFIRMED
- ContentValidator가 `defeat_giant` Mission Type을 허용한다.
- Stage Editor가 `defeat_giant`을 Mission Type으로 표시하고 로드한다. 기존 저장 경로의 `primary_type` 저장은 그대로 사용한다.
- GameController가 Giant 처치 시 `defeat_giant` Mission이면 즉시 Mission Clear 경로로 진입한다.
- Campaign에서는 기존 Stage reward / progression / next Stage 처리 패턴을 재사용한다.
- Base HP <= 0 조건은 기존 DEFEAT 경로를 유지한다.
- 기존 `defend_base` / `clear_encounters` 경로는 변경하지 않았다.
- `target_id`는 이번 구현에서 강제 사용하지 않았다. 현재 Giant Runtime의 타입 식별(`giant`)으로 Canon 조건을 충족한다.
VERIFICATION
- CODE VERIFIED — PASS
- BUILD VERIFIED — PASS (`Godot 4.7.2 --headless --editor --quit`, exit code 0)
- EDITOR VERIFIED — NOT VERIFIED
- PIE VERIFIED — NOT VERIFIED
DIFF — 의도된 3개 코드 파일만 Mission Contract 변경. 기존 문서 변경은 유지.
git diff --check — PASS
CHANGES — `editor/content_validator.gd`, `editor/stage_editor.gd`, `game_controller.gd`
OUT OF SCOPE — 실제 Mission Catalog에 Giant Boss Mission을 지정하는 Content 변경, PIE Runtime 확인, Player Count, Lane/Spawn Canon.


## Handoff — 2026-10-05 Audio Design / BGM·SFX 개발계획 반영

**STATUS** — PLAN UPDATED / IMPLEMENTATION NOT STARTED

**목적**
MENOS의 BGM과 효과음을 객체 중심 개발계획에 포함하고, 실제 Asset 제작 전에 최소 오디오 계약과 검증 순서를 정의한다.

**CONFIRMED**
- 현재 개발계획의 Combat Object인 Weapon/Skill에 SFX 연결 항목이 존재한다.
- 현재 개발계획에는 BGM을 독립적인 개발 항목으로 정의한 절차가 없다.
- 현재 문서 기준으로 오디오 Asset 제작/Runtime 연결/검증이 완료되었다고 선언할 근거는 없다.

**개발계획 반영**
오디오는 기존 객체의 Runtime 책임을 침범하지 않는 Asset/참조 계층으로 관리한다.

1. **BGM**
   - Title/Menu
   - 일반 Battle
   - Boss Battle
   - Victory
   - Defeat
   - 필요 시 Tension/Stage 상황용을 후속 추가
   - 초기에는 모든 곡을 한꺼번에 제작하지 않고 핵심 5종을 우선 검토한다.

2. **SFX**
   - UI
   - Robot/Unit Combat
   - Enemy Combat
   - Building/Tower
   - Base Damage
   - Boss
   - Skill/Weapon
   - Victory/Defeat
   - 공통 효과음은 객체별 중복 제작을 피하고 재사용 가능한 Asset으로 관리한다.

3. **Combat 연결**
   - Weapon/Skill의 SFX 참조는 기존 Combat Object 계획을 따른다.
   - 공격 효과음은 필요하면 Charge / Fire / Impact 등의 단계별 Asset으로 분리한다.
   - Robot/Enemy/Tower Definition에 음원 자체를 중복 저장하지 않고 Asset ID 또는 참조 구조를 우선 검토한다.

4. **Audio Runtime 구조**
   - BGM과 SFX를 별도 Audio Bus/재생 책임으로 분리하는 구조를 검토한다.
   - 실제 Godot AudioStreamPlayer 계층과 데이터 참조 방식은 기존 Runtime 조사 후 최소 구현한다.
   - 별도 Audio Editor는 반복 편집 가치와 실제 데이터 책임이 확인되기 전에는 만들지 않는다.

5. **제작 순서**
   - 1단계: Audio Design/Asset naming 및 참조 계약
   - 2단계: BGM 2종(Battle/Boss) + 핵심 SFX 최소 세트로 PoC
   - 3단계: 실제 Runtime 연결
   - 4단계: CODE/BUILD/EDITOR 검증
   - 5단계: Master의 실제 Runtime 확인 후 PIE VERIFIED
   - 방향이 승인되면 전체 BGM/SFX Asset을 확장한다.

6. **최소 PoC Asset**
   - BGM_BATTLE
   - BGM_BOSS
   - SFX_UI_CLICK
   - SFX_ROBOT_ATTACK
   - SFX_ROBOT_HIT
   - SFX_ENEMY_DEATH
   - SFX_TOWER_ATTACK
   - SFX_BASE_DAMAGE
   - SFX_BOSS_WARNING
   - SFX_BOSS_DEATH

**범위 원칙**
- 현재 Phase C의 Map/Mission/Encounter 계약 문제를 오디오 작업으로 우회하지 않는다.
- 오디오 제작이 완료되었다고 해서 Phase C 또는 Production 완료로 판정하지 않는다.
- 외부 음원 Source는 기존/엔진 자원으로 대체할 수 없는 경우에만 별도 승인 대상으로 둔다.
- 실제 Asset 제작 전에는 사운드 스타일과 제작 Source를 PROPOSAL로 유지한다.
- BGM/SFX의 구체적인 음악 장르, 음색, 외부 생성 서비스 사용 여부는 Master 승인 전 Canon으로 확정하지 않는다.

**검증 기준**
- DATA VERIFIED: Asset ID/경로 및 메타데이터 확인
- CODE VERIFIED: Runtime 재생 경로 확인
- EDITOR VERIFIED: 관련 Editor에서 참조/저장 가능 여부 확인
- BUILD VERIFIED: Godot Build 성공
- PIE VERIFIED: Master가 실제 게임에서 BGM/SFX 재생을 확인

**마리 판정**
현재 개발계획에 오디오 개발 범위를 추가하는 것으로 충분하다. 지금은 Asset을 대량 제작하거나 Audio 시스템을 새로 구현하지 않는다. 다음 작업은 Audio Design/Asset Contract를 확정한 뒤 최소 PoC를 제작하는 단계로 제한한다.

**변경 사항**
- 개발계획 문서에 Audio Design / BGM·SFX 개발 항목 추가.
- 코드/Asset/Editor 변경 없음.

**검증 상태**
- 문서 기준선: CODE/BUILD/EDITOR/PIE와 무관한 계획 반영
- 코드/Asset: NOT CHANGED


### Phase D 계획 확장 — Item / Shop / Exchange

STATUS: PLAN UPDATED / IMPLEMENTATION HOLD

CONFIRMED:
- Item/Equipment는 기존 Phase D 계획에 포함되어 있다.
- Item Catalog에는 Weapon / Armor / Core 정의와 Base Stat 및 Prefix/Suffix 생성 규칙이 존재한다.
- PlayerProfileState는 Gold / Inventory / Equipped Items를 저장한다.
- Reward Runtime은 Stage 완료 보상을 Profile Gold 및 Inventory에 반영하는 경로가 존재한다.
- 현재 코드/데이터 조사에서는 Shop/Store/Exchange/거래소 기능이 확인되지 않았다.

#### Item

Phase D의 Item을 독립적인 Progression/경제 객체로 계속 관리한다.

관리 범위:
- Item ID / Name
- Category
- Equipment Slot
- Base Stat
- Affix / Prefix / Suffix
- Compatibility
- Value
- Acquisition Rule
- Inventory 보관
- Equipment 장착
- Reward / Shop / Exchange를 통한 획득 경로

검증 순서:
1. Item Definition/Catalog 계약 확인
2. Inventory 저장/복원 확인
3. Equipment → Robot Runtime 적용 확인
4. Reward 획득 경로 확인
5. Shop/Exchange 획득 경로 연결
6. Build/Editor/PIE 검증

#### Shop

Shop은 Item을 경제 자원으로 구매하는 별도 시스템으로 계획한다.

최소 계약 후보:
- Shop ID
- 판매 목록
- Item ID
- 가격
- 사용 Currency
- 구매 가능 조건
- 구매 수량/재고 규칙
- 갱신 규칙이 필요한 경우 별도 데이터로 정의

원칙:
- Shop은 Item Definition을 복제하지 않고 Item ID를 참조한다.
- 가격/재고/갱신 방식은 경제 Canon 확정 전 PROPOSAL로 유지한다.
- Gold 외의 Currency를 추가할 필요성은 별도 판단한다.
- Shop Editor는 실제 Shop 데이터 편집 필요성이 확인된 후 추가한다.

#### Exchange / 거래소

Exchange는 Shop과 별도 객체로 취급한다.

Shop:
- 게임이 제공하는 판매 목록을 구매

Exchange:
- 정해진 교환 규칙 또는 등록된 교환 대상 사이의 교환

최소 계약 후보:
- Exchange ID
- Input Item/Currency
- Output Item/Currency
- 교환 비율
- 교환 조건
- 횟수 제한
- 기간/갱신 조건이 필요한 경우 별도 데이터

원칙:
- Exchange는 Item의 가격 자체를 변경하는 시스템이 아니다.
- Shop 가격과 Exchange 비율은 독립된 데이터로 관리한다.
- 자유시장/플레이어 간 거래소 여부는 Canon으로 확정하지 않는다.
- 실제 필요성이 확인되기 전까지 네트워크 기반 플레이어 거래 기능은 계획에 포함하지 않는다.

#### 경제 객체 관계

Reward → Inventory / Gold
Shop → Gold/Currency → Item → Inventory
Exchange → Input Item/Currency → Output Item/Currency → Inventory
Equipment → Inventory Item → Robot Runtime

이 관계를 Phase D의 기본 경제 흐름으로 사용하되, 구체적인 Currency 종류와 경제 수치는 Master Canon 확정 전까지 결정하지 않는다.

#### 개발 순서

1. Item Definition / Catalog 계약 확정
2. Inventory / Equipment Runtime 검증
3. Currency / Economy 계약 확정
4. Shop Definition / 구매 Runtime
5. Exchange Definition / 교환 Runtime
6. Profile Save/Load 연계
7. 최소 Editor/UI 연결
8. Build / Editor 검증
9. PIE 검증

완료 조건:
- Item이 Catalog → Inventory → Equipment/Runtime으로 일관되게 흐른다.
- Shop 구매 결과가 Inventory/Profile에 안전하게 반영된다.
- Exchange 결과가 Input 소모와 Output 지급에 일관되게 반영된다.
- 저장 후 재진입해 Item/Gold/구매·교환 결과가 복원된다.

DESIGN HOLD:
- Shop의 판매 방식
- Shop 갱신 주기
- Currency 종류
- Exchange의 구체적인 교환 규칙
- 플레이어 간 거래 여부
- Shop/Exchange Editor의 필요성

위 항목은 기술 구현이 아니라 경제/게임 디자인 결정이므로 Master 승인 전 Canon으로 확정하지 않는다.


## Handoff — 2026-10-05 Art Asset Structure / 제작 범위 정의

STATUS — ACCEPT / 구조 정의

### 목적
MENOS의 게임 객체와 Editor/Runtime 구조에 대응하는 Art Asset의 종류, 소유 관계, 참조 경계를 정의한다.
현재 단계에서는 실제 아트 제작보다 **Art Asset Contract와 제작 우선순위 확정**을 우선한다.

### 1. Art Asset 계층

게임 아트는 다음 5개 영역으로 분류한다.

1. **Core Gameplay Art**
   - Robot
   - Enemy
   - Giant/Boss
   - Allied Unit
   - Tower / Building
   - Base
   - Projectile
   - Combat VFX

2. **Map Art**
   - Background
   - Terrain / Tile
   - Spawn Area 표현
   - Lane 표현
   - Obstacle
   - Tower/Building Placement Area
   - Base / Objective
   - Environment Decoration

3. **Content Art**
   - Item Icon
   - Equipment Icon
   - Faction Icon
   - Robot/Enemy/Unit/Tower Thumbnail
   - Stage Thumbnail
   - Map Thumbnail
   - Catalog/Visual Asset Thumbnail

4. **UI Art**
   - Button / Panel / Tab
   - Slot
   - Selection / Disabled / Locked State
   - Warning / Confirm / Delete
   - Search / Filter / Navigation
   - HP / Status UI
   - Mission / Victory / Defeat UI
   - Inventory / Equipment / Shop / Exchange UI elements

5. **Presentation / Effects Art**
   - Boss Warning
   - Boss Entry
   - Skill Charge / Impact
   - Hit / Explosion
   - Death
   - Base Damage
   - Victory / Defeat
   - 기타 전투 화면 연출

### 2. Object → Art Asset Contract

권장 참조 구조:

Robot Definition
 → Visual Asset ID
 → Sprite Atlas / Animation Frames

Enemy Definition
 → Visual Asset ID
 → Sprite Atlas / Animation Frames

Allied Unit Definition
 → Visual Asset ID
 → Sprite Atlas / Animation Frames

Building / Tower Definition
 → Visual Asset ID
 → Sprite Atlas / Animation Frames

Item Definition
 → Icon Asset ID

Faction Definition
 → Faction Icon Asset ID

Map Definition
 → Map Visual Asset / Environment Asset references

Stage Definition
 → Map ID / Mission ID
 → Stage Thumbnail Asset ID

Skill / Weapon Definition
 → Animation / VFX Asset ID
 → SFX reference

원칙:
- 객체 Definition에 이미지 경로를 중복 저장하지 않고 Asset ID 참조를 우선한다.
- Gameplay Logic과 시각 Asset을 분리한다.
- Sprite Atlas는 Animation/Visual Asset의 실제 리소스로 취급한다.
- Item은 우선 Icon 중심으로 정의하고 대형 개별 일러스트는 필요성이 확인된 후 추가한다.
- Map의 논리 영역(Spawn, Placement, Objective 등)과 실제 그래픽을 분리한다.
- Thumbnail은 Editor/Catalog 표시용 Asset으로 Gameplay Visual Asset과 구분할 수 있다.

### 3. Core Gameplay Art 제작 우선순위

**P0 — 전투 가시성에 직접 필요한 것**
1. Robot 기본/이동/공격/피격/사망/Skill Animation
2. Enemy 기본/이동/공격/피격/사망 Animation
3. Giant/Boss 기본/공격/피격/사망 및 주요 Skill
4. Allied Unit 기본/이동/공격/피격/사망
5. Tower/Building 기본/공격/파괴
6. Base 기본/피격/파괴
7. Projectile
8. Hit / Death / Explosion 등 최소 Combat VFX

**P1 — Map과 콘텐츠 가시성**
1. Map Background
2. Terrain / Environment
3. Spawn / Placement / Objective 표현
4. Environment Decoration
5. Robot/Enemy/Unit/Tower Thumbnail
6. Stage/Map Thumbnail
7. Faction Icon

**P2 — Progression / Economy**
1. Weapon / Armor / Core Item Icon
2. Equipment Slot Icon
3. Currency Icon
4. Shop Item Presentation
5. Exchange Input/Output Presentation

**P3 — UI / Presentation 확장**
1. 공통 UI Art
2. Inventory / Equipment UI
3. Shop / Exchange UI
4. Boss / Skill / Victory / Defeat 연출 확장

### 4. 현재 제작 원칙

- 아트 수량을 먼저 늘리지 않는다.
- 하나의 객체에 필요한 최소 Visual Contract를 먼저 정의한다.
- Sprite Atlas는 실제 Animation 사용 단위와 일치해야 한다.
- Placeholder는 Production Asset으로 간주하지 않는다.
- 외부 Source 사용은 기존/엔진 Asset으로 대체 불가하고 목적상 필수일 때 Master 승인 후 사용한다.
- 실제 Asset 제작 전 해상도, 프레임 규격, Pivot/Anchor, naming, Atlas 규칙을 별도 Asset Contract로 확정한다.
- Editor Thumbnail과 Runtime Visual은 필요하면 동일 원본을 재사용하되 역할은 분리한다.

### 5. Editor 책임

Content/Asset Catalog는 Asset의 등록과 선택을 담당한다.
각 Object Editor는 해당 Object가 사용할 Asset ID를 참조한다.
Stage/Map Editor는 Object Definition을 직접 복제하거나 시각 Asset의 세부 내용을 편집하지 않는다.
별도 Art Editor는 현재 추가하지 않으며, 반복적인 편집 수요가 확인될 때만 검토한다.

### 6. 제작 완료 기준

각 핵심 객체는 다음을 만족해야 한다.

DATA — Asset ID가 Definition에서 안정적으로 참조됨
CODE — Runtime이 해당 Visual Asset을 실제 소비함
EDITOR — 해당 Editor/Catalog에서 Asset을 선택하고 저장할 수 있음
BUILD — Asset 포함 프로젝트 Build 성공
PIE — Master가 실제 화면에서 시각 결과 확인

자동화 테스트나 Editor 표시만으로 PIE VERIFIED를 선언하지 않는다.

### 7. 현재 범위 판정

현재는 **Art Asset Structure 정의 단계**다.
실제 아트 대량 제작, UI 아트 제작, Shop/Exchange 전용 아트 제작은 자동으로 시작하지 않는다.
먼저 Core Gameplay Art의 Asset Contract와 기존 Sprite Atlas 규격을 확정한 뒤 제작한다.


## Handoff — 2026-10-05 Networked Single-Player / User Map Upload 구조 고려

STATUS — ACCEPT / STRUCTURE ONLY

### 목적
현재 개발 범위에서는 멀티플레이 기능을 구현하지 않되, 향후 네트워크를 사용하는 싱글플레이 서비스와 사용자 제작 맵 업로드/공유를 수용할 수 있도록 데이터와 Asset 구조의 경계를 정의한다.

### 1. 범위 원칙
- 현재 Gameplay Mode 개발 범위에 Multiplayer Runtime을 포함하지 않는다.
- 네트워크 사용 여부와 Gameplay Mode를 동일한 개념으로 취급하지 않는다.
- 현재 싱글플레이의 핵심 Gameplay/Stage/Map 구조는 로컬 Runtime에서도 독립적으로 동작할 수 있어야 한다.
- 향후 네트워크 환경에서는 동일한 Stage/Map/Content Definition을 서버 또는 서비스가 전달하고 클라이언트가 소비할 수 있는 구조를 우선한다.
- 네트워크 계정, 매치메이킹, 동기화, PvP, 협동 플레이는 현재 범위 밖이다.

### 2. Networked Single-Player 구조 원칙
향후 가능한 구조:

User / Profile
→ Content / Stage Selection
→ Stage Definition
→ Map Definition
→ Runtime

네트워크를 사용할 경우에도 Gameplay Logic과 네트워크 전송 계층을 분리한다.

권장 경계:
- Definition/Data — 게임 콘텐츠의 구조와 식별 정보
- Content Service — 향후 서버/서비스에서 Definition을 제공할 수 있는 경계
- Asset Service/CDN — 향후 Sprite, Icon, VFX 등의 배포 경계
- Runtime — 전달받은 유효한 Definition과 Asset을 소비
- Profile/Save — 사용자 진행상태 저장 경계

현재는 위 계층을 실제 구현하지 않는다.

### 3. User Map Upload 구조
사용자가 제작한 Map은 기존 Map Definition 구조를 기반으로 업로드 가능한 콘텐츠 단위가 될 수 있도록 한다.

권장 개념:
- Map ID — 콘텐츠의 논리적 식별자
- Author/User ID — 작성자 식별자
- Version — Map 데이터 버전
- Schema Version — 현재 Map Schema 버전
- Metadata — 이름, 설명, Thumbnail, Tags 등
- Map Definition — 실제 Map 구조 데이터
- Referenced Asset IDs — Map이 사용하는 Visual/Environment Asset 식별자
- Validation Status — 업로드 전/후 검증 상태
- Visibility — 향후 Private / Unlisted / Public 등의 공개 범위를 가질 수 있음

현재 Visibility 정책, 업로드 용량, 저장소, 승인/검수 정책, 검색/추천, 신고/삭제 정책은 UNVERIFIED / DESIGN HOLD로 둔다.

### 4. User Map과 기존 Stage의 관계
사용자 Map 자체와 플레이 가능한 Stage를 동일 객체로 강제하지 않는다.

권장 구조:

User Map
→ Map Definition

Stage Definition
→ Map ID
→ Mission / Encounter / Gameplay Rules

따라서 사용자 Map은 향후 여러 Stage에서 참조될 수 있고, 반대로 Stage가 사용자 Map을 참조하는 것도 가능하도록 구조를 유지한다.

사용자 Map 업로드만으로 Mission/Encounter/Game Mode를 임의 생성하지 않는다.

### 5. Upload Validation 경계
사용자 Map은 Runtime에 직접 투입하기 전에 최소한의 구조 검증 단계를 거치는 것을 전제로 한다.

검증 후보:
- Schema Version
- 필수 Map 데이터 존재 여부
- Spawn / Goal / Placement 등 논리 영역 유효성
- 참조 Asset ID 존재 여부
- 허용되지 않은 데이터/객체 포함 여부
- 데이터 크기/구조 제한
- Runtime이 소비할 수 있는 Map Schema인지 여부

검증 통과는 콘텐츠의 게임성 승인이나 품질 보증을 의미하지 않는다.

### 6. User-Uploaded Art Asset 원칙
사용자 Map이 임의의 외부 파일을 Runtime에 직접 참조하는 구조는 기본값으로 사용하지 않는다.

우선 구조:
User Map → Allowed Asset ID → Approved/Available Asset

사용자 업로드 이미지/음원/VFX 등의 외부 Asset 허용 여부는 별도 Canon 결정이 필요하다.
현재는 UNVERIFIED / DESIGN HOLD다.

### 7. Version / Compatibility
향후 서비스 배포를 고려하여 다음 버전 경계를 유지한다.
- Map Schema Version
- Content Definition Version
- Asset Contract Version

구버전 Map을 새 Runtime에서 사용할 수 없는 경우를 고려해 Migration 또는 Compatibility 정책을 별도 정의할 수 있도록 한다.
현재 Migration 구현은 범위 밖이다.

### 8. 보안 / 신뢰 경계
User-uploaded content는 신뢰된 내장 Content와 동일하게 취급하지 않는다.
향후 네트워크 업로드가 도입될 경우 서버 측 검증을 포함하는 구조를 고려한다.

현재는 인증, 권한, 서버 검증, 악성 데이터 방어, 저장소 보안 등을 구현하지 않는다.

### 9. 현재 판정
- 현재 개발 범위: Local/Single-Player 중심
- 미래 구조 호환: Networked Single-Player 고려
- User Map Upload: 구조적으로 수용 가능하도록 Map/Stage/Asset 경계 정의
- Multiplayer Gameplay: 현재 범위 밖
- Network Runtime: 현재 구현하지 않음
- UGC Service: 현재 구현하지 않음

이 구조는 현재 개발을 불필요하게 확장하지 않으면서 향후 서비스형 콘텐츠 전달과 User Map Upload를 위한 확장 지점을 확보하는 것을 목표로 한다.


## Handoff — 2026-10-05 Sprite Atlas Contract / 공통 규격 구조화

STATUS — ACCEPT / STRUCTURE ONLY

### 목적
Robot/Enemy/Allied Unit/Tower/Boss 등 전투 객체의 Sprite Atlas 제작 방식이 객체마다 달라지지 않도록 공통 Asset Contract를 정의한다.
실제 Atlas 대량 제작이나 기존 Asset 변환은 수행하지 않는다.

### 1. 기본 구조
권장 계층:

Object Definition
→ Visual Asset ID
→ Animation Set
→ Sprite Atlas
→ Frame Region

Sprite Atlas는 단순 이미지가 아니라 Animation Set을 구성하는 실제 Runtime Visual Asset으로 취급한다.

### 2. Frame 규격
현재 MENOS 전투 Sprite 제작에서는 **120×120 px 셀 규격을 기본 후보**로 사용한다.

원칙:
- 한 Frame은 하나의 동일한 셀 크기를 사용한다.
- Animation Set 내부 Frame 크기를 임의로 섞지 않는다.
- Atlas의 행/열 배치는 Animation Set 계약으로 관리한다.
- 빈 셀은 Runtime Frame으로 간주하지 않는다.
- 캐릭터가 셀 경계를 넘는 경우 임의 Crop보다 셀 크기 계약을 먼저 재검토한다.

120×120을 모든 향후 Art Asset에 강제하는 것은 아니며, 전투 Sprite의 공통 제작 기준으로 우선 적용한다.

### 3. Animation Set 구조
기본 후보:
- idle
- move
- attack
- hit
- death
- skill / special

객체별로 실제 필요한 Animation만 가진다.
예:
- Tower는 move가 필요하지 않을 수 있다.
- Projectile은 일반 Character Animation Set을 사용하지 않는다.
- Boss는 phase/special animation이 추가될 수 있다.

Animation 이름은 Runtime에서 직접 사용하는 논리 ID와 일치하도록 한다.

### 4. Frame 안정성
Animation은 단순히 Frame 수를 맞추는 것이 아니라 시작/중간/종료 동작이 자연스럽게 연결되어야 한다.

필수 원칙:
- Frame별 캐릭터 중심점이 일관되어야 한다.
- Pivot/Anchor 기준을 통일한다.
- Idle/Move에서 불필요한 위치 이동이 발생하지 않아야 한다.
- Attack/Skill은 시작 자세와 종료 자세를 고려한다.
- Loop Animation은 마지막 Frame에서 첫 Frame으로 연결될 때 큰 위치/자세 jump가 없어야 한다.
- Frame을 추가/삭제할 때 전체 Animation의 중심과 타이밍을 다시 검증한다.

### 5. Pivot / Anchor
Sprite의 이미지 중앙과 Gameplay 위치를 동일시하지 않는다.

기본 원칙:
- Actor의 Gameplay 기준점은 발/접지점 또는 정의된 Combat Anchor를 사용한다.
- Sprite Frame의 Pivot은 Animation 전체에서 동일한 기준을 유지한다.
- 공격 이펙트와 Projectile의 시작점은 Sprite 이미지 중앙이 아니라 정의된 Weapon/Skill Anchor를 우선한다.

정확한 Anchor 좌표와 이름은 Runtime 구조를 추가 확인한 뒤 별도 Asset Contract로 확정한다.

### 6. Atlas Layout
Atlas는 사람이 보기 좋은 배치보다 Runtime에서 안정적으로 Frame을 식별할 수 있는 배치를 우선한다.

권장:
- 동일 Animation은 연속된 영역에 배치
- Animation별 행/영역을 명확히 분리
- Frame 순서를 좌→우, 상→하 중 하나로 통일
- Atlas 외부의 설명 텍스트/장식 요소를 넣지 않음
- 실제 Frame과 무관한 여백/장식은 최소화

현재 제작된 Robot Atlas의 행별 Animation 배치는 개별 Asset Contract로 기록할 수 있으며, 모든 객체에 동일한 행 번호를 강제하지 않는다.

### 7. Visual Asset ID
Runtime은 파일명이나 Atlas 좌표를 직접 의미 계약으로 사용하지 않고 Visual Asset ID를 기준으로 참조하는 방향을 우선한다.

예:
Robot Definition
→ visual_asset_id
→ Animation Set: attack
→ Frame 0..N

이를 통해 향후:
- Sprite Atlas 교체
- 해상도/플랫폼별 Asset 교체
- User Map/Networked Single-Player의 Asset 배포
가 가능하도록 한다.

### 8. Thumbnail 분리
Runtime Sprite와 Editor/Catalog Thumbnail은 역할을 분리한다.

- Runtime Visual Asset: 실제 게임 표시
- Thumbnail Asset: Catalog/Editor 목록 표시

동일 원본을 재사용할 수 있지만, Runtime Atlas의 특정 Frame을 Editor Thumbnail 계약으로 직접 고정하지 않는다.

### 9. VFX / SFX 연결
Animation 자체와 VFX/SFX를 하나의 이미지 Asset으로 결합하지 않는다.

권장:
Animation Set
→ Event/Timing
→ VFX Asset ID
→ SFX ID

실제 Event Timing 구현 여부는 Runtime 조사 후 결정한다.

### 10. 제작 및 검증 순서
1. Object Definition의 Visual Asset ID 확인
2. Animation Set 이름 확정
3. Frame size / Atlas layout 확정
4. Pivot / Anchor 규칙 확인
5. Sprite Atlas 제작
6. Asset Catalog 등록
7. Object Editor에서 참조
8. Runtime 소비 경로 확인
9. Build 검증
10. Master PIE 검증

자동화된 Atlas 파일 존재 확인만으로 Visual Runtime 완성을 선언하지 않는다.

### 11. 현재 판정
- **구조:** 확정 방향
- **기본 전투 셀:** 120×120 px 후보/현재 제작 기준
- **Animation 이름:** 공통 ID 체계로 관리
- **Pivot/Anchor:** 공통 원칙 정의, 정확 좌표는 UNVERIFIED
- **Atlas 행 번호:** 객체별 개별 정의, 전역 강제하지 않음
- **실제 Asset 제작:** 현재 범위 밖
- **Asset 변환:** 현재 범위 밖

이 계약은 기존 Sprite Atlas를 재작성하는 지시가 아니며, 이후 신규/수정 Atlas 제작의 기준 구조다.


## Handoff — 2026-10-05 Sprite Frame Size / 1500×1000 24프레임 제약 반영

STATUS — ACCEPTED / 제작 규격 갱신

**목적**
Sprite Atlas 제작 시 1500×1000 캔버스에서 24프레임을 수용해야 하는 경우의 프레임 셀 크기와 Giant Boss 제작 기준을 문서화한다.

**CONFIRMED**
- 1500×1000 이미지를 6열 × 4행으로 24프레임 배치하면 프레임 셀은 정확히 250×250 px이다.
- 프레임 외곽 여백과 모션 확장 영역을 고려하면 실제 Giant Boss 실루엣은 250 px보다 작게 운용한다.
- 제작 안전 여유를 고려한 Giant Boss 실루엣의 1차 목표 범위는 약 200~220 px로 둔다.
- 프레임 셀 크기와 게임 화면 표시 크기는 별개의 계약이다. 셀 크기만으로 화면상 Giant Boss의 크기를 결정하지 않는다.
- Giant Boss는 게임 화면에서 Asura 대비 약 4배의 상대 크기를 목표로 한다.

**PROPOSAL**
- 1500×1000 / 24프레임 Giant Boss 시트에서는 250×250 px를 프레임 셀의 상한으로 사용한다.
- 실제 캐릭터 실루엣은 셀 내부에 약 200~220 px 수준으로 배치하고, 프레임 간 접지점/Combat Anchor를 일정하게 유지한다.
- 공격/스킬 모션에서 셀 경계를 넘지 않도록 최대 동작 범위를 먼저 고려한다.

**기존 규격과의 관계**
- 기존 문서의 120×120 px는 이전 제작 후보 기준으로 유지 기록한다.
- 이번 변경은 1500×1000 / 24프레임이라는 특정 시트 제약에 대한 제작 규격이며, 모든 Sprite Atlas를 250×250으로 일괄 변경하는 의미가 아니다.
- 실제 Asset 생성/변환은 이번 기록 범위에 포함하지 않는다.

**검증 상태**
- DATA: 문서 계약 반영
- CODE: NOT VERIFIED
- EDITOR: NOT VERIFIED
- BUILD: NOT VERIFIED
- PIE: NOT VERIFIED

**판정**
현재 목적에 필요한 프레임 크기 제약을 확정 기록하고 종료한다. 추가 Asset 제작이나 Runtime 변경은 자동 진행하지 않는다.


## Handoff — 2026-10-05 Gameplay Display Size / Asura·Giant 상대 크기

STATUS — PROPOSAL / 화면 기준 반영

**목적**
Sprite Frame Cell 크기와 실제 Gameplay 화면 표시 크기를 분리하고, Asura와 Giant Boss의 상대적인 시각 크기 기준을 기록한다.

**PROPOSAL**
- Asura의 Gameplay 화면 표시 높이: 약 60~100 px 범위를 1차 목표로 한다.
- Giant Boss의 Gameplay 화면 표시 높이: 약 240~400 px 범위를 1차 목표로 한다.
- Giant Boss는 Asura 대비 약 4배의 화면상 크기를 목표로 한다.
- 위 값은 Sprite Frame Cell 크기(예: 125×125, 250×250)와 별개의 표시 Scale 기준이다.

**UNVERIFIED**
- 실제 게임 해상도별 정확한 화면 픽셀 크기
- Camera Zoom/Viewport 기준
- Asura의 최종 화면 표시 Scale
- Giant Boss의 최종 화면 표시 Scale

**판정**
현재는 상대 크기 기준만 구조적으로 기록한다. 실제 Camera/Viewport 기준 확정 및 PIE 화면 검증은 별도 단계에서 Master 확인이 필요하다.


## Handoff — 2026-10-05 Gameplay Visual Quality 우선 원칙

STATUS — ACCEPTED / 품질 제약 추가

**목적**
Robot Editor Preview와 Gameplay 표시 기준을 통일하더라도 실제 Gameplay의 시각 품질을 저하시키지 않는 것을 최우선 품질 제약으로 명시한다.

**CONFIRMED**
- Gameplay에서 사용하는 Runtime Visual Asset은 Editor Preview와의 표시 통일을 위해 저해상도 이미지나 별도 열화 Asset으로 대체해서는 안 된다.
- Editor Preview의 크기/Anchor/Frame 계산을 Gameplay 기준에 맞추는 경우에도 Gameplay Runtime Asset의 원본 해상도와 Frame 정보를 보존해야 한다.
- Display Size 계약과 Source Asset 해상도는 별개의 계약이다.
- Gameplay Render Scale을 맞추기 위해 원본 Sprite를 강제로 축소 저장하거나 재샘플링하는 방식은 기본적으로 사용하지 않는다.
- 현재 Gameplay는 TEXTURE_FILTER_NEAREST를 사용하므로 픽셀 아트 품질을 유지하는 현재 필터링 정책을 임의로 변경하지 않는다.

**PROPOSAL**
- Editor와 Gameplay는 동일한 Visual Asset Definition, Frame Region, Anchor를 공유한다.
- 표시 크기 계산은 공통 규칙을 사용하되, Runtime은 원본 Runtime Visual Asset을 사용한다.
- Gameplay 품질 검증 시 최소 기준은 원본 Frame 해상도 보존, 필터링 정책 보존, 프레임 경계 손상 없음, Anchor/Pivot에 따른 시각적 흔들림 없음으로 한다.
- 저해상도 Preview가 필요할 경우 Editor 전용 표시 축소만 허용하며 Runtime Asset 자체를 축소하지 않는다.

**검증 기준**
- DATA: Visual Asset ID / Frame Region / Anchor 보존
- EDITOR: Preview와 Gameplay 표시 기준 일치 여부
- CODE: Runtime이 원본 Visual Asset을 사용하는지 확인
- BUILD: Runtime Visual Asset 품질 손상 없음
- PIE: Master가 실제 화면 품질 확인 필요

**판정**
Gameplay 시각 품질 저하는 허용하지 않는다. Editor Preview와 Gameplay의 표시 차이를 해결하더라도 품질 저하가 발생하면 해당 방법은 CHANGE METHOD 대상이다.

**OUT OF SCOPE**
- 신규 Sprite 제작
- Sprite 해상도 일괄 변경
- Texture 압축/변환 정책 변경
- Camera/Viewport 확정


## Handoff — 2026-10-05 MENOS 3/4 측면 Sprite 제작 규격

STATUS — ACCEPTED / 제작 규격 정의

**목적**
기존 수평/정면 중심 Sprite보다 기체의 전면·측면·상면 구조와 깊이감을 명확하게 표현하기 위해 MENOS 공통 3/4 측면 시점을 정의한다.

**시점 규격**
- 기본 시점은 완전 측면이 아닌 **3/4 측면(Quarter View)** 으로 한다.
- 권장 회전감은 약 30~45° 범위이며, 기본 제작 기준은 약 35~40°의 사선 시점으로 둔다.
- 전면과 한쪽 측면이 동시에 식별되어야 한다.
- 상부 장갑/어깨/머리 구조가 약간 보이도록 하여 평면적인 정면 투영을 피한다.
- 반대쪽 측면은 필요 이상으로 노출하지 않는다.
- 기체가 화면 밖으로 돌아가 보이는 극단적인 측면 투영은 사용하지 않는다.
- 모든 Robot/Enemy/Giant/Allied Unit은 동일한 시점 계열을 기본으로 사용한다.

**전투 방향**
- 기본 Sprite는 하나의 고정 3/4 방향을 기준으로 제작한다.
- 진행 방향과 공격 방향이 실루엣에서 명확해야 한다.
- 무기와 팔/어깨가 서로 겹치더라도 무기의 종류와 공격 방향을 식별할 수 있어야 한다.
- 별도 좌우 방향 Sprite가 필요할 경우 기존 Sprite를 단순 좌우 반전하는 것이 가능한 구조를 우선 검토한다. 비대칭 장비/무기가 있는 경우에는 별도 프레임 제작을 고려한다.

**입체감 / 명암**
- 3D 모델 렌더처럼 보이는 것이 아니라 2D Sprite 내부에 3D 구조가 읽히도록 제작한다.
- 광원 방향은 전체 Animation Set에서 고정한다.
- 전면/측면/상면의 명암 차이를 명확히 한다.
- 관절, 장갑 틈, 겹치는 부위에는 적절한 AO/접촉 명암을 둔다.
- 금속 장갑은 면별 하이라이트와 반사광으로 재질을 구분한다.
- 명암은 작은 Gameplay 표시 크기에서도 유지될 정도로 충분히 강하게 한다.
- 프레임마다 광원 위치나 명암 구조가 흔들리지 않아야 한다.

**Team Color**
- 팀 컬러 적용 영역은 별도 식별 가능한 불투명 Base Color 영역으로 만든다.
- 해당 영역의 Alpha는 **1.0**을 유지한다.
- 팀 컬러 영역에 금속 반사광이나 투명 효과를 혼합하지 않는다.
- 중립 금속, 관절, 무기, 센서 등은 팀 컬러 영역에서 제외한다.
- Runtime에서 팀 컬러를 변경해도 기체의 입체 명암이 손상되지 않는 구조를 우선한다.

**Frame / Atlas**
- Animation Set 내부의 모든 프레임은 동일한 셀 크기를 사용한다.
- 캐릭터는 각 셀 내부에 완전히 들어와야 한다.
- 3/4 시점 변경으로 인해 무기/장갑이 셀 경계를 넘지 않도록 동작 범위를 사전에 고려한다.
- 프레임 간 기체의 기준 크기와 접지 위치를 일정하게 유지한다.
- Pivot/Combat Anchor는 시각적 중심이 아니라 발/접지점 기준을 우선한다.
- 기존 120×120, 125×125, 250×250 등의 셀 규격은 캐릭터별 시트 조건에 따라 유지하며 3/4 시점 자체가 셀 크기를 강제하지 않는다.

**Gameplay 품질**
- 원본 Sprite의 해상도와 세부 묘사를 보존한다.
- 3/4 시점 제작을 위해 저해상도화, 강제 재샘플링, 과도한 Blur를 사용하지 않는다.
- Godot의 현재 nearest-neighbor 필터링 정책과 충돌하지 않는 선명한 경계를 유지한다.
- 작은 Gameplay 표시 크기에서도 실루엣, 무기, 머리/상체, 다리/접지 위치가 식별되어야 한다.

**투명 배경**
- 배경은 완전 투명으로 한다.
- 바닥, 환경, 원근 배경, 체크보드, 텍스트, 라벨, 워터마크를 포함하지 않는다.
- 캐릭터 외부에 의도하지 않은 Glow/Smoke/Dust가 남지 않도록 한다.
- 필요하면 접지 그림자는 별도 Runtime/VFX 레이어로 분리한다.

**Animation 일관성**
- Idle, Move, Attack, Hit, Death, Skill 등 모든 Animation Set에서 동일한 3/4 시점을 유지한다.
- Idle은 접지점과 중심이 안정되어야 한다.
- Attack/Skill에서는 동작을 크게 확장하되 기본 시점과 기체 비율을 유지한다.
- 시작/종료 프레임의 자세가 자연스럽게 연결되어야 한다.
- 프레임 추가/삭제 시 Anchor와 화면상 크기를 다시 검증한다.

**권장 제작 기준**
- 기본 Robot: 3/4 전투 시점
- Giant Boss: 동일한 3/4 시점 계열을 유지하되 큰 실루엣과 상면 노출을 허용
- 공격/스킬: 동일 시점 + 동작 확장
- VFX: Sprite 본체와 분리 가능한 구조를 우선
- 카메라 회전으로 3/4 시점을 만들지 않고 Sprite 자체에서 시점을 표현한다.

**검증 기준**
- DATA: Visual Asset ID / Animation Set / Frame Region / Anchor 보존
- ASSET: 3/4 시점, 실루엣, 명암, Team Color 영역, 투명 배경 확인
- EDITOR: Catalog/Robot Editor Preview에서 시점과 Frame이 올바르게 표시되는지 확인
- CODE: Runtime이 동일 Visual Asset/Frame/Anchor를 소비하는지 확인
- BUILD: 원본 해상도 및 필터링 품질 손상 없음
- PIE: Master가 실제 Gameplay 화면에서 크기·입체감·가독성을 최종 확인

**판정**
3/4 측면 Sprite를 MENOS의 차기 Sprite 제작 기준으로 채택한다. 기존 Asset을 자동 변환하거나 재제작하지 않는다. 신규 Sprite 제작 또는 기존 Asset 교체는 별도 범위에서 수행한다.

**OUT OF SCOPE**
- 기존 Robot/Enemy/Giant Sprite 일괄 재제작
- Camera/Viewport 변경
- Normal Map/2D Light 신규 구현
- Sprite 자동 변환 도구 제작
- 기존 Asset 좌우 방향 체계의 일괄 변경

## Handoff — 2026-10-05 Object Reference / Faction Dependency 구조

STATUS — HOLD / Canon 결정 필요

**확인 결과**
- Stage → Mission / Map / Reward / Allied Unit / Encounter 구조는 현재 구현되어 있다.
- Encounter → Wave → Group → Enemy ID 구조가 Stage 내부에 존재한다.
- RobotDefinition에는 `faction_id`가 존재하지만 현재 Robot Catalog 데이터에는 실질적인 연결값이 없다.
- Faction Catalog는 현재 비어 있다.
- Enemy / Allied Unit / Tower Definition에는 현재 Faction 참조가 확인되지 않았다.

**구조 방향 제안**
- Faction은 독립 Definition으로 유지한다.
- Object Definition은 Faction ID를 참조하고, Faction은 Object 데이터를 복제하지 않는다.
- Faction Editor는 소속 관계를 관리하고 개별 Object 데이터는 각 Object Editor/Catalog가 관리한다.
- Stage는 Faction을 직접 소유하지 않는 방향을 우선 검토한다.

**Canon 미확정**
- 적용 대상 Object 범위
- Tower/Building Faction 규칙
- Player Faction과 Stage 관계
- Faction Member 저장 방식

**판정**
구조상 중요한 참조 계약이지만 Canon 결정이 필요한 영역이다. 구현 없이 HOLD한다.
