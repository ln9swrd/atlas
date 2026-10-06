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

## 14. Steam Workshop / User-Created Content (PROPOSAL)

Steam Workshop 연동은 플레이어가 게임 내부 제작 도구로 만든 콘텐츠를 공유하고 다른 사용자가 구독하여 플레이할 수 있도록 하는 확장안이다. 본 항목은 PROPOSAL이며 Canon이 아니다.

### 기본 원칙

- 사용자 제작 콘텐츠는 신뢰할 수 없는 입력으로 취급한다.
- Workshop 등록 자체를 실행 권한으로 간주하지 않는다.
- 기존 게임 규칙과 Catalog Definition을 사용자가 임의로 재정의하지 못하도록 한다.
- **맵 제작은 자유롭게, 게임 규칙은 제한적으로** 제공하는 방향을 우선 제안한다.

### 권장 1차 범위

Workshop 공개 대상은 우선 **Map + Stage**로 제한한다.

Map Editor에서 허용할 후보:
- Terrain / Tile
- Decoration / Object
- Gameplay Area
- Spawn Point / Area
- Base Position
- Robot Start Position
- Tower Placement Area / Point
- 제한된 Wave / Enemy 구성
- 사전 정의된 Mission Type 선택

사용자에게 제공하지 않는 후보:
- Robot / Enemy / Tower 원본 스탯 직접 수정
- 임의 AI 또는 Script
- GDScript / C# 실행
- 임의 파일 경로
- 외부 URL 실행
- DLL / EXE / PowerShell 등 실행 파일
- 임의 Asset 실행 또는 코드 주입

### Reference와 Definition 분리

사용자 콘텐츠는 기존 Catalog의 stable ID를 참조하고 Definition 자체를 복사하지 않는 방향을 권장한다.

허용 예:
```json
{"enemy":"enemy_grunt","count":10}
```

금지 예:
```json
{"enemy":"enemy_grunt","damage":999999,"script":"..."}
```

즉, Workshop 콘텐츠는 "어떤 기존 콘텐츠를 어디에 어떻게 배치할 것인가"를 정의하고, 실제 Robot / Enemy / Tower의 능력치와 실행 로직은 게임의 기존 Definition / Runtime이 소유한다.

### 권장 사용자 제작 구조

내부 Authoring Editor와 사용자용 Workshop Map Editor를 동일 화면/권한으로 취급하지 않는다.

```text
Workshop Map Editor
  ├─ Map
  ├─ Stage
  ├─ Mission
  ├─ Wave
  ├─ Enemy 선택
  ├─ Tower 선택
  ├─ Robot 선택
  ├─ Preview
  ├─ Validate
  └─ Publish
```

### Workshop 처리 흐름

```text
Map/Stage Editor
    ↓
Validate
    ↓
Export
    ↓
Steam Workshop Publish
    ↓
Subscribe / Download
    ↓
Validate Again
    ↓
Map / Stage List
    ↓
Play
```

Steam Workshop API 연동 방식은 구현 단계에서 현재 Steam SDK/플랫폼 요구사항을 확인한 뒤 결정한다. 본 문서는 특정 API 호출 구조를 Canon으로 확정하지 않는다.

### 검증 경계

Workshop 콘텐츠는 최소한 다음을 통과해야 Runtime에 사용한다.
- Schema validation
- 참조 ID 존재 여부
- Map/Stage 호환성
- 파일 경로 및 파일 형식 검증
- 허용되지 않은 Script / Executable / 외부 참조 검출
- 콘텐츠 크기 및 기본 무결성 검증

검증 실패 콘텐츠는 다운로드되었더라도 플레이 가능한 콘텐츠 목록에 노출하지 않는 방향을 권장한다.

## 15. Steam 상점 / 게임 내 거래 경제 확장안

STATUS — PROPOSAL / NOT CANON

Steam을 통한 유료 아이템 판매와 게임 내 거래소는 분리해서 설계한다.

### 권장 1차 경제 구조

```text
Steam Wallet
    ↓
MENOS 게임 내 상점
    ↓
확정 아이템 / 꾸미기 / 게임 내 화폐
```

- 게임사가 Steam 결제를 통해 확정 상품 또는 게임 내 화폐를 판매하는 구조를 우선 검토한다.
- 유료 구매가 핵심 캠페인 진행의 필수 조건이 되지 않도록 한다.
- 가격, 상품 구성, 환불 및 플랫폼 정책은 실제 Steam 연동 단계에서 별도 확인한다.

### 게임 내 거래소

```text
유저 A
  ↓
게임 내 거래소
  ↕
아이템 / 게임 내 화폐
  ↕
유저 B
```

유저 간 거래가 필요할 경우 우선 **게임 내부 화폐 또는 아이템 교환**으로 한정하는 방향을 권장한다.

### 초기 단계에서 제외하는 구조

- 유저 간 직접 현금 결제
- 게임 아이템의 현금 출금 / 환전
- 게임 내 화폐의 현금 환급
- 현금 가치가 직접 연결되는 유저 간 경매 시스템
- 현금 → 확률형 아이템 → 거래소 → 현금 환전 구조

이러한 구조는 Steam 플랫폼 정책 외에도 사기, 도난 결제수단, 환불 악용, 소비자보호, 세금 및 자금 이동 등 별도의 검토가 필요하므로 초기 경제 시스템 범위에서 제외한다.

### 확률형 상품 경계

확률형 상품을 도입할 경우 Steam 정책과 서비스 대상 국가의 관련 법규를 별도로 검토한다. 특히 현금 구매와 유저 간 거래가 결합되는 구조는 별도 법률/플랫폼 정책 검토 없이 확정하지 않는다.

### 경제 시스템의 권장 분리

```text
[Steam 결제]
     ↓
[게임사 상점]
     ↓
[아이템 / 게임 화폐]

[게임 내 거래소]
     ↕
[게임 화폐 / 아이템]

[현금 출금]
     X  초기 범위 제외
```

본 항목은 사업 모델 및 경제 시스템에 대한 PROPOSAL이다. Steam의 구체적인 API/SDK 사용 방식, 상품 유형, 거래 제한, 환불 정책, 국가별 법적 요구사항은 구현 및 서비스 출시 전에 최신 공식 자료를 기준으로 별도 검증한다.

## 16. Open Decisions

- Experience and level curves, caps, and attribute growth.
- Whether robot damage persists between battles or maps.
- Repair timing, cost, and resource source.
- Equipment slots, compatibility, and item rarity.
- Upgrade costs and whether upgrades can fail.
- Currency types and reward formulas.
- Shop stock and refresh rules.
- Mission compatibility rules and reward configuration.
- Save format, versioning, and recovery behavior.
- Whether a player-to-player in-game exchange system is required.
- Which item categories, if any, may be purchased with Steam Wallet.
- Whether paid content is cosmetic, convenience-oriented, or gameplay-affecting.
- Country/platform-specific requirements for paid or tradable content.

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


## 2026-10-06 Gameplay Settings / Content Editor 책임 경계

STATUS — PROPOSAL / NOT CANON

Gameplay/Settings와 Content Editor의 책임을 분리한다.

### Gameplay / Settings

게임 전체가 어떻게 동작하는지를 관리한다.

- Game Rules
- Combat Rules
- Player Control
- Camera
- HUD
- Progression Rules
- Economy Rules
- Shop / Marketplace 정책
- Steam / Workshop / 결제 기능 활성화 정책
- Save / Progression 정책
- Audio 기본 정책
- Accessibility
- Debug / Test 정책

개별 Robot / Enemy / Tower / Skill의 능력치나 개별 Stage 구성은 직접 소유하지 않는다.

### Content Editor

게임 안에 무엇이 존재하고 어떻게 구성되는지를 관리한다.

- Robot
- Enemy
- Tower
- Faction
- Skill / Ability
- Item
- Mission
- Campaign
- Map
- Stage
- Wave / Encounter
- Reward
- Shop Product
- Audio / VFX Reference

### 책임 경계 예시

Robot HP = 220은 Content Definition이다.
Combat Rules의 피해 계산 방식은 Gameplay Rule이다.

Shop Product A와 가격은 Content Definition이고, Shop Enabled 및 거래 정책은 Gameplay/Settings가 관리한다.

이 경계를 유지하여 동일 데이터를 Gameplay/Settings와 Content Editor에서 중복 관리하지 않는다. 최종 데이터 스키마와 Editor UI 범위는 Master 결정 및 실제 코드/DB 조사 후 확정한다.


## 2026-10-06 다국어 지원 / Localization 책임 경계

STATUS — CANON / Master 결정 반영

MENOS는 다국어를 지원한다. 기본 언어는 English이며, 사용자가 언어를 선택하면 게임 UI와 콘텐츠 텍스트가 선택 언어에 대응해야 한다.

### 데이터 분리

- Gameplay / Settings: Default Language, Selected Language, Fallback 정책 및 언어 선택 상태
- Localization Data: 실제 번역 문자열
- Content Definition: 번역 문장 자체가 아니라 Localization String ID 참조
- Content Editor UI: Localization String ID를 사용하여 현재 선택 언어로 표시
- Runtime UI: 동일한 Localization Data를 사용하여 현재 선택 언어로 표시

동일 문자열을 Editor 코드, Runtime 코드, Content 데이터에 중복 저장하지 않는다.

### Editor 다국어

현재 영어로 고정된 Content Editor UI도 다국어 지원 대상이다.

버튼, 메뉴, 필드명, 검증 오류, 상태 메시지 등은 직접 문자열을 하드코딩하지 않고 Localization String ID를 사용한다.

예:
- editor.save
- editor.cancel
- editor.validate
- editor.field.hp
- editor.validation.invalid_id

따라서 사용자가 Korean을 선택하면 Editor UI도 Korean으로 대응하고, English를 선택하면 English로 대응한다.

Editor 전용 문자열과 Runtime 전용 문자열은 namespace 또는 데이터 영역으로 구분하되, 공통 문자열은 중복 번역하지 않는다.

### Content 예시

Robot Definition:
name_key = robot.atlas_01.name

Localization Data:
robot.atlas_01.name -> en / ko / ja / ...

이 구조를 통해 Content Editor와 Runtime이 동일한 콘텐츠를 서로 다른 언어로 표시할 수 있도록 한다.

## 2026-10-06 Settings / Audio 책임 및 적용 현황

STATUS — PROPOSAL / 현재 구현 반영

메인 화면의 Settings는 게임 전역 설정을 담당한다.

현재 반영된 설정 후보:
- BGM Volume
- SFX Volume
- Language

Audio 설정은 Gameplay/Settings가 소유하며 개별 Content Definition이 직접 관리하지 않는다.

현재 구현 방향:
- BGM과 SFX를 별도 Audio Bus로 분리
- BGM/SFX 볼륨을 0..1 범위로 저장
- `user://menos_settings.cfg`에 사용자 설정을 저장
- 게임 시작 시 저장값을 불러와 AudioServer에 적용
- SFX 재생 경로는 SFX Bus를 사용
- Language 선택도 동일한 사용자 설정 영역에서 저장

검증 상태:
- CODE VERIFIED — 설정 저장/로드 및 Audio Bus 적용 코드 경로 확인
- BUILD VERIFIED — 이번 문서 갱신에서 재검증하지 않음
- EDITOR VERIFIED — 설정 Scene/리소스 로드 확인
- PIE VERIFIED — 실제 Runtime에서 슬라이더 변경 후 청취 결과는 미확인

## 2026-10-06 Content Editor 메뉴 반응성 조사

STATUS — HOLD / 조사 완료, 구조 변경 전

증상:
Content Editor 상단 메뉴를 클릭할 때 화면 전환 반응이 느리게 느껴진다.

CONFIRMED:
- 메뉴 클릭 시 `content_editor.gd`의 `_load_editor()`가 호출되어 선택된 Editor Scene을 다시 로드한다.
- 기존 child Editor는 `queue_free()` 처리된다.
- 선택된 Scene은 `load(scene_path)` 후 instantiate/add_child하는 구조다.
- 새 Editor의 `_ready()`에서 Catalog 로드, 파일 탐색, 이미지 탐색, UI 구성 등의 동기 작업이 수행되는 Editor가 존재한다.
- Map/Stage/Faction/Skill/Unit/Tower 등 일부 Editor는 초기화 시 별도의 데이터 로드 또는 UI 구축을 수행한다.

HIGH CONFIDENCE:
- 메뉴 클릭마다 Editor를 파괴하고 다시 생성하는 구조와 child `_ready()`의 동기 초기화가 체감 지연의 주요 원인일 가능성이 높다.

UNVERIFIED:
- Editor별 실제 전환 시간(ms)
- 특정 Catalog/File/Image scan이 전체 지연에서 차지하는 비율
- 가장 느린 단일 Editor
- 캐시/비동기 로딩으로 개선했을 때의 실제 체감 개선량

판정:
현재는 구조 변경보다 Editor별 전환 시간을 계측하는 것이 최소 검증이다. 계측 결과 없이 캐싱/비동기화/사전 로드 구조를 확정하지 않는다.


## 2026-10-06 VFX / Content Editor 책임 및 구현 방향

STATUS — PROPOSAL / NOT CANON

VFX는 Content Editor에서 관리하는 콘텐츠 정의로 취급하되, VFX의 실제 Asset 제작 방식과 Runtime 실행 방식은 분리한다.

권장 구조:
```text
Content Editor
  ↓
VFX Editor
  ↓
VFX Catalog
  ↓
Runtime VFX System
```

VFX Editor는 개별 VFX를 ODB PK 기반으로 정의하고 관리한다. Name/Title은 변경 가능한 표시 속성이며 식별자로 사용하지 않는다.

VFX 정의 후보:
- ODB PK
- Name
- Category
- Duration
- Position / Scale / Rotation
- Sprite / Texture Reference
- Particle 설정
- Shader 설정
- Animation 설정
- Light 설정
- Sound Reference
- Layer / Z-order
- Runtime 재생 조건

Godot은 GPUParticles2D/CPUParticles2D, Shader, AnimationPlayer, AnimatedSprite2D, Line2D, Polygon2D, Light2D 등의 VFX 제작 시스템을 제공하지만, 완성된 폭발/화염/전기/피격 등의 VFX Asset Library를 기본 제공하는 것은 아니다.

따라서 VFX는 Texture/Sprite + Particle + Shader + Animation 등의 조합으로 구성할 수 있으며, 실제 Asset 제작과 VFX 데이터 정의를 동일 작업으로 취급하지 않는다.

PROPOSAL — VFX 데이터는 JSON/SQLite 등의 데이터 정의로 관리하고 Runtime에서 해당 정의를 실행하는 구조를 우선 검토한다. Robot/Skill/Building 등은 VFX ODB PK를 참조하고 특정 Scene에 직접 종속되지 않는 방향을 권장한다.

현재는 VFX Schema와 Runtime 소비 경로를 먼저 조사해야 한다. VFX Editor 구현 및 Building의 VFX 필드 추가는 해당 구조 확정 전까지 범위를 확장하지 않는다.


## 2026-10-06 SFX / Content Editor 책임 및 구현 방향

STATUS — PROPOSAL / NOT CANON

SFX는 Content Editor에서 관리하는 독립 콘텐츠 유형으로 취급하되, 전역 Audio 정책과 Runtime 재생 규칙은 분리한다.

권장 구조:
```text
Content Editor
  ↓
SFX Editor
  ↓
SFX Catalog
  ↓
Runtime Audio System
  ↓
SFX Bus
```

SFX Editor는 개별 SFX를 ODB PK 기반으로 정의하고 관리한다. Name/Title은 변경 가능한 표시 속성이며 식별자로 사용하지 않는다.

SFX 정의 후보:
- ODB PK
- Name / Title
- Category
- Audio Asset Reference
- Volume
- Pitch
- Pitch Random Range
- Loop 여부
- 2D / 3D 재생 유형
- 거리 감쇠 설정
- 재생 우선순위
- 동시 재생 제한

책임 경계:
- Gameplay / Settings: SFX 전체 볼륨, SFX Bus, 음소거 및 전역 Audio 정책
- SFX Content: 어떤 소리가 존재하는지, Audio Asset과 개별 재생 특성
- Gameplay: 어떤 게임 이벤트에서 어떤 SFX ODB PK를 재생하는지

예:
```text
Robot Attack
    ↓
Gameplay Event: robot.attack
    ↓
SFX ODB PK
    ↓
SFX Catalog
    ↓
Audio Asset
    ↓
SFX Bus
```

Robot/Enemy/Tower/Building/Skill 등의 Content Definition에 Audio 파일명을 직접 저장하지 않고 SFX ODB PK를 참조하는 방향을 권장한다. 이는 Name/Title 변경과 Asset 경로 변경이 콘텐츠 참조를 깨뜨리지 않도록 하는 현재 ODB PK Canon과 일치한다.

PROPOSAL — SFX 데이터는 JSON/SQLite 등의 데이터 정의로 관리하고 Runtime Audio System이 해당 정의를 실행하는 데이터 기반 구조를 우선 검토한다.

현재는 SFX Schema와 기존 Audio 재생 경로를 먼저 조사해야 하며, SFX Editor 구현 및 기존 Content에 SFX 필드 추가는 Schema 확정 전까지 범위를 확장하지 않는다.


## 2026-10-06 BGM / Content Editor 책임 및 구현 방향

STATUS — PROPOSAL / NOT CANON

BGM은 SFX와 동일하게 Content Editor에서 관리하는 독립 콘텐츠 유형으로 취급하되, 전역 Audio 정책과 Runtime 재생 규칙은 분리한다.

권장 구조:
```text
Content Editor
  ↓
BGM Editor
  ↓
BGM Catalog
  ↓
Runtime Audio System
  ↓
BGM Bus
```

BGM Editor는 BGM을 ODB PK 기반으로 정의하고 관리한다. Name/Title은 변경 가능한 표시 속성이며 식별자로 사용하지 않는다.

BGM 정의 후보:
- ODB PK
- Name / Title
- Category (Main Menu / Campaign / Battle / Boss / Victory / Defeat 등)
- Audio Asset Reference
- Volume
- Pitch
- Loop 여부
- Fade In / Fade Out
- 재생 우선순위
- Transition 방식

책임 경계:
- Gameplay / Settings: 전체 BGM Volume, BGM Bus, 음소거 등 전역 Audio 정책
- BGM Content: 어떤 음악이 존재하는지, Audio Asset과 개별 재생 특성
- Gameplay Runtime: 현재 게임 상황에 어떤 BGM ODB PK를 재생할지 결정
- Runtime Audio System: 실제 재생, Loop, Fade, Transition 처리

예:
```text
Campaign Battle
    ↓
BGM ODB PK
    ↓
BGM Catalog
    ↓
Audio Asset
    ↓
BGM Bus
```

Robot/Enemy/Tower/Building/Skill/Mission/Campaign 등의 Content Definition에 Audio 파일명을 직접 저장하지 않고 BGM ODB PK를 참조하는 방향을 권장한다. 이는 Name/Title 변경과 Asset 경로 변경이 콘텐츠 참조를 깨뜨리지 않도록 하는 현재 ODB PK Canon과 일치한다.

PROPOSAL — BGM 데이터는 JSON/SQLite 등의 데이터 정의로 관리하고 Runtime Audio System이 해당 정의를 실행하는 데이터 기반 구조를 우선 검토한다.

현재는 BGM Schema와 기존 Audio 재생 경로를 먼저 조사해야 하며, BGM Editor 구현 및 기존 Content에 BGM 필드 추가는 Schema 확정 전까지 범위를 확장하지 않는다.
