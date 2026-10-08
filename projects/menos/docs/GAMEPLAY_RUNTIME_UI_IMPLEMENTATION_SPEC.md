# MENOS — GAMEPLAY RUNTIME + UI IMPLEMENTATION SPEC

## 1. Purpose

게임플레이는 `Stage → Runtime Simulation → Player Interaction → Mission Resolution → Victory/Defeat`를 실제 플레이 화면과 함께 정의하는 Runtime domain이다.

목표는 단순히 전투 코드가 동작하는 것이 아니라 다음 전체 경로를 하나의 계약으로 고정하는 것이다.

`Campaign/Stage Data → Stage Load → Map Runtime → Gameplay State → HUD/Input → Combat/Wave → Mission → Result UI`

Gameplay UI는 별도 데이터 저작 메뉴가 아니라 Runtime presentation/control layer다.

## 2. Current runtime baseline — CONFIRMED

현재 `godot/game_controller.gd`가 다음을 직접 관리한다.

- Run State: READY / RUNNING / GROWTH / VICTORY / DEFEAT
- Stage / Encounter / Wave
- Base HP
- Gold
- Robot runtime state
- Allied Units
- Enemies / Giant
- Towers
- Robot target selection
- Robot movement
- Auto / Manual attack mode
- Basic / Special / Skill 1–3 / Finisher
- Energy / Finisher meter / cooldown
- Inventory / equipment
- Camera pan / edge scroll / zoom / minimap
- Combat log
- Damage / projectile / impact effects
- Mission completion
- Stage reward
- Campaign progression

`StageManager` loads Stage, Mission and Reward references and supplies map, balance, allied units, encounters, waves and gameplay timing.

`StageLoader` validates the required Stage structure before runtime use.

## 3. Gameplay state machine

Canonical runtime states:

`READY → RUNNING → GROWTH → RUNNING → VICTORY`

or

`READY → RUNNING → DEFEAT`

Terminal states:
- VICTORY
- DEFEAT

Rules:

- READY: Stage loaded, map rendered, player can prepare before Wave 1.
- RUNNING: active combat/wave execution.
- GROWTH: player chooses an available robot growth/ability; combat progression is paused for the choice.
- VICTORY: gameplay simulation stops and result UI is shown.
- DEFEAT: gameplay simulation stops and result UI is shown.

A terminal state must not continue spawning enemies or applying normal combat progression.

## 4. Stage-to-runtime contract

Required Stage runtime data:

- Stage ID
- Order
- Name
- Map reference
- Mission reference
- Reward reference
- Initial Gold
- Base HP
- Allied Unit definitions/count/spawn
- Encounters
- Waves
- Enemy Groups
- Enemy Count
- Spawn Interval
- Lane(s)
- Wave Auto Start Delay
- Wave Group Gap

Stage does not contain presentation-only HUD layout.

Gameplay reads Stage data through `StageManager` / `StageLoader`; it must not invent different Stage rules in the UI layer.

## 5. Runtime world / map contract

Gameplay consumes Map data for:

- Map bounds
- Coordinate origin
- Pixel size
- Tiles / background / objects
- Base / Goal
- Enemy spawn/lane points
- Robot spots
- Tower placement slots/areas
- Gameplay areas/points

The Map defines where gameplay can occur.
The Stage defines what occurs there.
The Gameplay runtime executes it.

## 6. Player HUD contract — P0

The current HUD is drawn by `GameController` and must be treated as a first-class Runtime UI contract.

### Top status bar

Must show:
- Base HP
- Gold
- Stage identifier/order
- Encounter number
- Wave number / total waves
- Current run status
- Selected target information when available

### Robot panel

Must show:
- Robot identity
- Active/standby state
- HP / Max HP
- Energy / Max Energy
- Level
- XP / required XP
- Movement/control hints

### Combat action palette

P0 actions:
- Basic Attack
- Special
- Skill 1
- Skill 2
- Skill 3
- Finisher

Each action must show:
- action name
- input/key indicator
- current state: READY / cooldown / ENERGY / LOCKED / OFF
- disabled visual state when unavailable

The UI state must be derived from the same runtime state used by the action executor. UI must never claim READY while the runtime rejects the action.

### Combat mode

Must show and toggle:
- ATTACK AUTO
- ATTACK MANUAL

Current implementation supports click toggle.

### Combat log

Must display recent gameplay events such as:
- wave start/clear
- attack/action results
- mission progress/completion
- tower/build events
- important failure states

The log is presentation only; it must not become authoritative gameplay state.

### Minimap

Must show at minimum:
- Base
- Robot
- Active enemies
- Giant distinction
- Current camera viewport

Minimap click may reposition the camera but must not alter gameplay state.

## 7. World interaction contract — P0

### Robot

Supported interactions:
- click robot to select/deselect
- click world to move when selected
- click robot spot to move when applicable
- target selection
- target cycling

### Enemy

- click enemy to select target
- selected target displayed in HUD
- target range state displayed

### Tower

- select existing tower
- select tower build type
- place tower only inside valid placement area
- reject invalid placement
- display build feedback

### Camera

Current interactions:
- edge scroll
- middle-mouse drag
- mouse wheel zoom
- minimap navigation
- SPACE center on base

Camera movement must not modify Stage/Map data.

## 8. Input contract

Gameplay input is divided into:

### Movement
- WASD movement
- mouse click movement

### Combat
- Basic Attack
- Special Attack
- Skill Slot 1
- Skill Slot 2
- Skill Slot 3
- Finisher

### Navigation
- target selection/cycling
- camera zoom
- camera drag
- base center
- inventory toggle

### UI
- action buttons
- tower selection/build
- inventory/equipment
- growth selection

Input must resolve through one gameplay input boundary so keyboard and UI activation produce the same gameplay action path.

The screen itself must remain non-authoritative: UI invokes gameplay commands; it does not directly mutate combat rules.

## 9. Combat contract — P0

Runtime must provide deterministic state transitions for:

- Robot attacks
- Tower attacks
- Enemy attacks
- Projectile travel
- Impact
- Damage
- HP reduction
- Enemy death
- Gold reward
- Mission target updates
- Wave completion

A combat event should follow:

`Intent → Validation → GameplayEvent → Runtime Resolution → State Change → Presentation`

Example:

`Robot Attack → target/range/cooldown check → weapon_fired → projectile → impact → damage → enemy death → gold/mission update → VFX/SFX/HUD`

Presentation must not become the source of truth for damage or death.

## 10. Wave contract

Wave execution must follow:

`Encounter → Wave → Enemy Groups → Spawn Timing → Combat → Wave Clear → Next Wave / Encounter / Result`

Each group must define at minimum:
- Enemy ID
- Count
- Spawn interval
- Lane list

Wave-level timing:
- Wave auto-start delay
- Group gap

Wave completion occurs only after all required spawned enemies are resolved according to Stage rules.

The UI displays wave state but does not determine completion.

## 11. Mission contract

Gameplay consumes Mission definition rather than embedding objective rules in HUD.

Current mission types:
- `defend_base`
- `clear_encounters`
- `defeat_giant`

Mission runtime must expose:
- objective type
- target
- elapsed/current progress where applicable
- time limit where applicable
- completion state

Mission completion must trigger the same result pipeline regardless of whether completion came from wave clear, time survival, or Giant defeat.

## 12. Victory / Defeat UI contract — P0

### Victory

Must:
- stop normal combat progression
- prevent further enemy spawning
- show victory state
- show stage/campaign result
- show reward result when available
- provide restart/next progression action according to run mode

### Defeat

Must:
- stop normal combat progression
- prevent further enemy spawning
- show defeat state
- explain base-defense failure where applicable
- provide restart action

Current pilot implementation has a full-screen result overlay and RESTART behavior. Campaign-next UI is a required specification boundary even if its final visual design is not yet implemented.

## 13. Campaign result contract

When running in Campaign mode:

`Stage Victory → Reward → determine next Stage → continue Campaign`

If there is no next Stage:

`Stage Victory → Campaign Victory`

When running Single mode:

`Stage Victory → Stage Result`

Gameplay must not silently treat Single mode as Campaign progression.

## 14. Growth / progression UI contract — P0

When growth becomes available:

- enter GROWTH state
- stop/hold normal combat progression according to runtime rule
- show available abilities
- show name and description
- allow one valid choice
- reject locked/unavailable choices
- apply the choice through the progression system
- return to RUNNING

The UI presents available choices; `GameController` / progression state remains authoritative.

## 15. Inventory UI contract

Current runtime supports inventory toggle with `I` and equipment selection.

P0 requirements:
- open/close state
- inventory grid
- item identity
- item summary/stat display
- click-to-equip
- equipped state
- confirmation/failure feedback

Inventory is a player runtime state and must not modify Content Catalog definitions.

## 16. Runtime presentation contract

Gameplay presentation may include:
- Robot/Unit/Enemy/Tower animation
- HP bars
- damage numbers
- projectiles
- impact VFX
- combat log
- status overlay
- minimap
- HUD
- SFX/BGM/Voice bindings when their runtime systems exist

Presentation must consume runtime state/events rather than independently deciding game outcomes.

## 17. Resolution / viewport contract

The current runtime uses a map area plus a bottom HUD and Camera2D.

The gameplay UI must:
- remain anchored to screen space;
- not drift with world camera movement;
- preserve input hit areas after camera zoom/pan;
- avoid HUD overlap with world interaction;
- keep minimap and action controls screen-relative.

Current implementation explicitly performs UI hit testing before world click handling because the bottom HUD overlaps the world rectangle.

## 18. UI responsiveness contract

P0:
- every interactive element has a visible state;
- disabled actions are visually distinct;
- selected target/tower/robot state is visible;
- cooldown and resource requirements are visible;
- victory/defeat blocks normal gameplay interaction;
- invalid actions produce feedback;
- UI reflects runtime state after every relevant state change.

Exact responsive breakpoints are UNVERIFIED and must be finalized only after target display/resolution requirements are fixed.

## 19. Pause contract

A dedicated pause state/menu is not confirmed in the current runtime inventory.

Therefore:

**UNVERIFIED / HOLD**

Before implementing Pause, define:
- pause trigger
- simulation freeze semantics
- input blocking
- audio behavior
- Resume
- Restart
- Settings access
- Quit/Return behavior
- unsaved progression behavior

Do not infer pause behavior from the existence of Settings.

## 20. Audio contract

Gameplay events should eventually bind through:

`Gameplay Event → SFX/BGM/Voice Binding → Audio Runtime`

Current confirmed SFX path uses `game_controller.gd` mappings and `play_sfx()` with BGM/SFX Settings volume applied through `SettingsManager`.

Dedicated SFX/BGM/Voice authoring/runtime layers are separately specified and must not be duplicated inside Gameplay.

## 21. Error / recovery contract

Runtime failures must be non-destructive.

Examples:
- invalid Stage reference → fail Stage load before combat
- invalid Map → fail Stage load or use explicitly approved safe fallback
- missing visual asset → report and use only approved fallback behavior
- missing SFX → gameplay continues
- invalid skill reference → skill unavailable, other gameplay continues
- invalid tower placement → no state change
- invalid action due to cooldown/energy/range → no gameplay mutation

A failed presentation operation must not create a false gameplay success.

## 22. Data authority boundaries

| Domain | Authority |
|---|---|
| Stage structure | Stage data / StageLoader |
| Map spatial data | Map data / MapLoader |
| Mission objective | Mission definition |
| Robot stats | Robot definition + runtime state |
| Unit stats | Unit definition + runtime state |
| Tower stats | Tower definition + runtime state |
| Enemy stats | Enemy definition + runtime state |
| Player progression | Player runtime/progression state |
| User settings | SettingsManager |
| HUD presentation | Gameplay UI |
| Combat outcome | Gameplay runtime |
| Audio asset definition | SFX/BGM/Voice runtime domains |

## 23. Minimum E2E gameplay acceptance

### A. Stage entry

`Campaign/Single → Stage selection → StageLoader → Map/Mission/Reward resolved → READY`

### B. Wave

`READY → start Wave → enemy groups spawn → combat → Wave Clear → next Wave`

### C. Player combat

`Select target → Basic/Skill action → validation → GameplayEvent → damage → enemy HP update → death/reward`

### D. Giant

`Giant spawn → target → combat → Giant defeat → defeat_giant mission completion → VICTORY`

### E. Defeat

`Base HP reaches 0 → stop wave → DEFEAT overlay → restart available`

### F. Campaign

`Stage Victory → reward → next Stage → READY`

### G. UI integrity

Verify:
- HUD remains screen anchored while camera moves/zooms
- action states match runtime availability
- minimap follows world state
- target information matches selected enemy
- result overlay blocks normal combat input

## 24. Verification status

**CODE VERIFIED**
- GameController runtime state and combat paths exist.
- StageManager/StageLoader data path exists.
- P0 HUD drawing/input paths exist.
- Combat timing and pilot HUD smoke tests exist.

**BUILD VERIFIED**
- Not re-run in this review.

**EDITOR VERIFIED**
- Main scene and runtime scene structure inspected.

**PIE VERIFIED**
- Not established by this documentation review.

**UNVERIFIED**
- Dedicated Pause implementation.
- Full Campaign Stage-to-Stage UI flow.
- Full reward-result UI.
- Final responsive layout across target resolutions.
- Full keyboard/controller remapping contract.
- Full runtime audio binding for future BGM/Voice systems.

## 25. Implementation gate

Gameplay P0 is implementation-ready when:

1. Runtime state machine is fixed.
2. Stage/Map/Mission authority boundaries are fixed.
3. P0 HUD elements and states are fixed.
4. Input actions map to authoritative runtime commands.
5. Wave/combat/mission/result transitions are fixed.
6. Victory/Defeat behavior is fixed.
7. Campaign vs Single result behavior is fixed.
8. Error/recovery rules are fixed.
9. P0 E2E tests pass.
10. PIE acceptance confirms the complete start-to-finish flow.

## 26. Review judgment

**CONFIRMED** — The project already has a substantial playable runtime foundation, including Stage loading, combat, waves, robot control, towers, mission resolution, HUD, minimap, inventory and result overlays.

**PARTIAL** — The existing code implements more gameplay/UI behavior than the formal specification previously documented. The missing specification boundary was primarily the explicit UI contract, input/state contract, result/progression contract, failure/recovery rules, and E2E acceptance criteria.

**UNVERIFIED** — Pause, final campaign result UI, responsive resolution behavior, and complete PIE start-to-finish acceptance.

**PROPOSAL** — Treat the HUD and Runtime UI as part of the Gameplay specification, but keep gameplay authority in runtime state and definitions. Do not move gameplay rules into UI scripts merely to simplify implementation.

**STATUS — CONTINUE** for specification completion only. No gameplay code changes are included in this review.
