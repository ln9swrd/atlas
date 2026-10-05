# MENOS Game Systems Architecture

> Status: PROPOSED. This document records the current design direction; it is not Canon until explicitly approved by the Master.

## 1. Core Game Experience

MENOS is a single-player super-robot combat game. The primary goal is to make direct robot combat enjoyable and encourage players to return to maps after completing them. A typical battle session is approximately 20 minutes.

The game should support completing the campaign and reaching an ending, while allowing continued play through map selection and replay. Replay motivation should come primarily from combat and varied experiences, not mandatory grinding.

## 2. Design Principles

- Combat is the central experience; management systems support it rather than replace it.
- Robots can grow persistently and retain their progression across maps.
- Robots and towers can take damage during combat; repair should be possible.
- Maps and missions should be independently configurable where practical.
- Items, upgrades, shops, and resources provide choices without making paid purchases mandatory for progression.
- Keep battle-session state separate from persistent player data.

## 3. High-Level System Areas

1. Combat: robots, enemies, towers, damage, destruction, repair, resources, and battle results.
2. Robot progression: profiles, experience, levels, attributes, and skill unlocks.
3. Equipment and items: item definitions, inventory, equipment slots, acquisition, and disposal.
4. Maintenance and upgrades: repair, equipment replacement, and enhancement.
5. Economy and shops: currencies, prices, purchasing, selling, and shop inventory.
6. Maps and missions: map selection, mission rules, enemy composition, waves, spawn points, and rewards.
7. Persistence: profile, robot progression, inventory, currency, unlocks, and completion records.

## 4. Combat System Requirements

- Robot movement, attacks, weapons, and special attacks.
- Enemy movement, target selection, and attacks.
- Damage calculation and durability tracking.
- Separate durability for the player robot and defensive towers.
- Destruction or combat-disabled states where appropriate.
- Repair during battle and/or between battles (exact rules TBD).
- Battle resource acquisition and spending.
- Mission victory, defeat, and result calculation.

Existing combat implementation must be inspected before deciding which requirements need new code.
## 5. Robot Progression

- Maintain a profile for each owned robot.
- Award experience through battle results (award rules TBD).
- Support levels and growth attributes such as attack, defense, and durability.
- Support skill unlocks and equipment effects as separate progression sources.
- Preserve progression when changing maps or missions.
- Calculate effective combat attributes from base specifications, progression, equipment, and upgrades.

Robot definitions (base specifications) should be separate from player-owned robot progression. Exact growth curves, caps, and reset rules are undecided.

## 6. Equipment and Items

- Item definitions with stable IDs, categories, and effects.
- Inventory for owned items.
- Robot equipment slots and compatibility rules.
- Equip and unequip operations.
- Item acquisition from battle rewards and shops.
- Optional item sale or dismantling (proposal; not confirmed).
- Optional item rarity tiers (proposal; not confirmed).

## 7. Maintenance and Upgrades

- Maintenance interface showing robot and equipment condition.
- Repair damaged durability.
- Replace or remove equipment.
- Upgrade equipment or weapons using defined costs and materials.
- Define upgrade outcomes (guaranteed, probabilistic, or other) before implementation.

Repair restores a damaged state; upgrading improves long-term performance. These should remain distinct operations.
## 8. Economy and Shops

- Define currencies and their sources/uses.
- Display shop inventory and prices.
- Validate funds and item eligibility before purchase.
- Support purchases and, if approved, sales.
- Define whether shop stock is fixed, mission-specific, or refreshed.
- Ensure paid items are not mandatory for core gameplay or campaign completion.
## 9. Maps and Missions

Map data describes the combat space; mission data describes objectives and rules. A stage combines the map, mission, enemy setup, spawn configuration, and rewards.

Initial mission examples:
- Annihilation: defeat specified enemies or groups.
- Defense: protect a designated target for a duration or against waves.

Escort and boss battle are possible future mission types, not confirmed requirements.

Required capabilities:
- Select and replay maps.
- Select or configure missions per map, subject to compatibility.
- Configure victory and defeat conditions.
- Configure enemy composition, waves, and spawn points.
- Configure mission rewards.
## 10. Persistence and Runtime State

Persistent player data should include owned robots and their progression, inventory, equipped items, currencies, unlocks, and mission completion records.

Battle runtime data should include temporary combat durability, active enemies, towers, wave progress, and in-battle resources. Define explicitly which results are transferred to persistent data when a battle ends.

The policy for carrying damage between missions is undecided. Do not assume that damage to a robot or tower automatically persists across maps.

## 11. Required Screens

- Robot management: owned robots, progression, equipment, and condition.
- Inventory/equipment: item inspection and loadout changes.
- Maintenance/upgrade: repair and enhancement.
- Shop: browse, buy, and optionally sell.
- Map/mission selection: select a map and an available mission.
- Combat: real-time battle and status display.
- Battle results: rewards, progression, damage, and replay options.

Screens are a proposed user-facing breakdown; exact navigation and layout remain undecided.
## 12. Suggested Implementation Order

1. Combat foundation: damage, durability, repair, mission outcomes, and battle results.
2. Persistent robot progression: profiles, experience, levels, attributes, and save/load.
3. Equipment: item definitions, inventory, slots, and loadout management.
4. Maintenance and upgrades: repair interface, upgrade rules, and costs.
5. Economy and shops: currency, pricing, purchase, and optional sale.
6. Content expansion: additional mission types and map-specific configurations.

This is a proposed sequence, not an approved implementation plan. Existing code should be inspected before estimating effort or assigning files.

## 13. Data Ownership Boundaries

| Data | Responsibility |
|---|---|
| Map Data | Terrain and combat-space layout |
| Mission Data | Objectives and victory/defeat rules |
| Stage Data | Map/mission composition, enemies, waves, spawns, rewards |
| Robot Definition | Robot base specifications |
| Player Profile | Owned robots and persistent progression |
| Item Definition | Item base properties and effects |
| Inventory | Owned and equipped items |
| Battle Runtime | Temporary battle state and resources |
| Save Data | Persistent player state |

## 14. Open Decisions

- Experience and level curves, caps, and attribute growth.
- Whether robot damage persists between battles or maps.
- Repair timing, cost, and resource source.
- Equipment slots, compatibility, and item rarity.
- Upgrade costs and whether upgrades can fail.
- Currency types and reward formulas.
- Shop stock and refresh rules.
- Mission compatibility rules and reward configuration.
- Save format, versioning, and recovery behavior.

## 15. Status and Verification

- Design status: PROPOSED; not Canon until explicitly approved.
- Code verification: NOT VERIFIED for this proposed architecture.
- Build verification: NOT VERIFIED.
- Editor verification: NOT VERIFIED.
- PIE verification: NOT VERIFIED.
- No gameplay code or assets are changed by this document.

## 16. Current Combat Implementation Audit (2026-09-28)

> Status: CODE VERIFIED by source inspection. This section records observed implementation, not approved future design or Canon.

### 16.1 Runtime Flow

- During wave execution, the robot and towers update their combat logic from the main processing loop.
- Manual robot movement is processed separately from the robot's automated combat update.
- Manual movement can therefore coexist with automated attacks during a running wave.
- Special attacks are player-triggered rather than automatically selected by the robot combat loop.
- While a special attack is active, automated robot movement and basic-attack processing are paused, while manual movement remains available.
- Basic combat processing resumes automatically when the special state ends.
- Robot movement input is also accepted in READY state, while automated combat updates are gated by wave execution.
- Starting manual positioning sets `manual_position`; the inspected movement path does not clear it to resume automatic positioning.

### 16.2 Current ATLAS-01 Combat Parameters

| Parameter | Current value |
|---|---:|
| HP | 220 |
| Movement speed | 125 |
| Basic damage | 28 |
| Basic attack cooldown | 0.65 s |
| Basic attack range | 180 |
| AREA ATTACK damage / radius / cooldown / threshold | 28 / 72 / 6 s / 3 enemies |
| HEAVY PIERCE damage / cooldown | 105 / 7 s |

- Special activation: player-triggered; current input is Space or the Combat sidebar SPECIAL button.
- During a special attack, automated movement, automated basic attack processing, and basic-attack cooldown progression are paused. Manual robot movement remains available.
- After the special state ends, automated/basic combat processing resumes automatically.
- Special duration: 0.5 s in the current Godot implementation. This is a technical PROPOSAL, not final balance or Canon.

The values above are read from `godot/data.gd`. They describe the current prototype configuration, not final balance.

### 16.3 Tower Combat Parameters

| Tower | Damage | Cooldown | Range | Target preference | Cost |
|---|---:|---:|---:|---|---:|
| CANNON | 42 | 1.35 s | 155 | heavy | 55 |
| GATLING | 9 | 0.23 s | 145 | fast | 35 |

Level 2 values are configured separately in `godot/data.gd`. Tower attacks are automated; upgrades change damage, cooldown, and range.

### 16.4 Enemy Combat Parameters

| Enemy | HP | Speed | Armor | Base damage | Reward |
|---|---:|---:|---:|---:|---:|
| NORMAL | 42 | 25 | 0 | 8 | 12 |
| RUSHER | 27 | 55 | 0 | 6 | 10 |
| HEAVY | 125 | 14 | 8 | 18 | 28 |
| GIANT | 620 | 7 | 18 | 45 | 90 |

GIANT additionally has robot damage 20, robot range 120, and robot attack cooldown 2 seconds. These are current data values, not final balance.

### 16.5 Combat Presentation and Timing

- Robot attack animation selection is driven by the current attack timer; movement and skill animations are selected through separate state checks.
- The current Godot implementation uses a dedicated skill animation state while a special attack is active.
- The current special-state duration is 0.5 s; this is an implementation proposal and has not been PIE-validated or balance-approved.
- Projectile effects are visually interpolated between a start and target position.
- Source inspection indicates that projectile visuals and damage timing are not synchronized as a travel-time hit: damage is applied separately from the visual projectile's arrival.
- The inspected implementation does not establish a dedicated player-controlled attack direction or aim flow.

### 16.6 Implications for Action Combat

- The current prototype provides movement, automated attacks, cooldowns, enemy durability, and visual combat effects.
- It does not yet provide a player-triggered basic attack, explicit dodge action, or combo system in the inspected combat flow.
- If action-style combat is pursued, attack input, hit timing, attack direction, and enemy hit reaction require explicit design and validation.
- These are technical considerations only; this audit does not approve or prescribe a particular combat design.

### 16.7 Verification Boundary

- Source/code path: VERIFIED by inspection.
- Build: NOT RUN as part of this documentation task.
- Editor and runtime behavior: NOT VERIFIED in this task.
- PIE: NOT VERIFIED by this audit; no runtime result is asserted.
- Files changed by this task: this document only. No gameplay code, assets, or project settings were changed.

## 13. Gameplay Definition 정합성 갱신 — 2026-10-05

STATUS: CURRENT DESIGN REFERENCE / Master 최신 결정 반영

기존의 Map = 공간 / Mission = 규칙 / Stage = 조합 구분을 유지하되, 실제 구현 조사 결과를 반영하여 Map이 일부 Gameplay 환경 정의를 소유한다는 점을 명시한다.

### Map
Map은 단순 전투 배경이 아니라 재사용 가능한 전장 및 Gameplay 환경을 정의한다.

현재 확인된 Map Gameplay 데이터:
- Spawn Area
- Movement Area
- Blocked Area
- Obstacle Area
- Tower Placement Area / Point
- Goal Area
- Robot Position Point

### Stage
Stage는 선택한 Map 위에서 실제 플레이 구성을 정의하는 중심 단위다.

Stage는 현재 다음을 연결한다.
- Map
- Mission
- Encounter / Wave / Spawn
- Stage Balance
- Reward

### Mission
현재 Master가 확정한 Mission Type 범위는 다음 세 가지다.
- Tower Defense
- Elimination / LoL 스타일 섬멸전
- Giant Boss Battle

이들은 Run Mode가 아니라 Mission Type이다.

### Run Mode / Player Count
기존 campaign / single / multiplayer 데이터는 현재 코드에 존재하지만 Mission Type과 동일한 개념으로 해석하지 않는다.
Player Count(1인/2인 등)의 최종 소유 위치와 Run Mode의 정확한 의미는 UNVERIFIED이며 별도 설계가 필요하다.

### 책임 경계
Map = 맵에 종속되고 재사용 가능한 Gameplay 환경
Stage = 특정 Map에서 수행할 실제 Gameplay 구성
Mission = 목표/승패 의미
Runtime = 위 정의의 실행

이 섹션은 기존 문서의 제안 내용을 최신 조사 결과에 맞춰 보정한 현재 기준이다. 기존 역사적 계획은 소급 삭제하지 않는다.
