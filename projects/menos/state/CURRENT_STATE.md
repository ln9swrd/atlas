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
