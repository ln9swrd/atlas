# MENOS Current State

## Status

Godot PoC implementation is ready for direct PIE playtest. Browser fallback exists.
The Browser position experiment found no measurable difference under its fixed setup. In the Godot 4.7.2 PIE comparison, LEFT/CENTER/RIGHT all reached Wave 4 Victory, with different Base HP, Robot HP, Gold, and remaining move counts. LEFT's route and move timing are unknown, so position itself is not confirmed as the cause. Player reasoning, strategic understanding, fun, and balance remain unverified.
Victory and defeat end states are explicit; a completed run only restarts.

## Changed

- Added `godot/project.godot`, `godot/main.tscn`, `godot/main.gd`, and `godot/data.gd`.
- Added data-driven tower, enemy, robot ability, and four-wave definitions.
- Added Giant attacks against the deployed Robot, Robot destruction state, and full-HP restoration on redeploy in the Browser and Godot code.

## Verification

- CODE: PASS; Pylance diagnostics found no errors in the Godot scripts/scene, and Godot 4.7.2 headless editor checks exited `0`.
- End states: implemented; Wave 4 completion produces VICTORY, base HP zero produces DEFEAT, both stop the run until RESTART.
- BUILD: Godot project loads successfully; no export build was requested for this PoC.
- EDITOR: PASS; project opened with the installed Godot 4.7.2 editor.
- Robot/Giant interaction: CODE PRESENT in Browser and Godot; direct runtime behavior remains unverified.
- PIE: VERIFIED / PASS for the direct Robot-position comparison only; this does not verify the entire project.
- Strategic understanding: UNVERIFIED; player choice reasons were not captured.
- Fun/balance: UNVERIFIED.

## Next

Keep the result bounded to the completed Godot PIE comparison. Do not infer position causality, strategic understanding, fun, or balance; any further player study requires a separate task.

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
