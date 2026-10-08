# MENOS — MENU / GAMEPLAY / CONTENT SYSTEM INTEGRATED DEVELOPMENT PLAN

Status: PROPOSAL — Content Editor 1차 완성을 우선하는 종합 개발계획. Canon 변경 아님.

## 1. 목적

현재까지 정의한 Content Editor 구현·검증 스펙을 개발계획에 통합하고, 먼저 Content Editor의 1차 완성을 달성한다. 1차 완성은 15개 Authoring 메뉴의 공통 편집/검증/저장/재로드 기준과 핵심 참조·Runtime E2E를 확보하는 것을 의미하며, 미확정 Gameplay 의미론이나 Presentation Production 확장은 자동으로 포함하지 않는다.

핵심 목표는 개별 메뉴의 완성도가 아니라 다음 E2E 경로의 안정성이다.

`Source Asset → Catalog → Game Object → Map → Mission → Stage → Campaign → Runtime Gameplay/UI → Result → Settings/Audio`

## 2. 종합 구조 판정

### CONFIRMED

현재 시스템은 크게 네 계층으로 분리된다.

1. Asset / Content Authoring
   - Catalog
   - VFX
   - 향후 SFX / BGM / Voice
2. Semantic Game Content
   - Faction
   - Robot
   - Unit
   - Tower
   - Building
3. Scenario Assembly
   - Map
   - Mission
   - Stage
   - Campaign
4. Runtime / Player Layer
   - Gameplay
   - Gameplay UI/HUD
   - Settings
   - Audio/Presentation Runtime

이 분리는 유지한다.

### PROPOSAL

개발 순서는 메뉴 화면의 수가 아니라 데이터 의존성과 Runtime 검증 가능성을 기준으로 결정한다.

`기반 → Asset → Semantic Object → Scenario → Runtime → Presentation → Polish`

## 3. 개발 원칙

- 한 단계의 성공 기준을 만족하면 해당 단계는 종료한다.
- 다음 단계는 이전 단계의 Loader/Reference/Runtime 계약이 검증된 후 시작한다.
- Editor Save PASS를 Runtime PASS로 간주하지 않는다.
- Editor Preview와 Runtime Preview를 구분한다.
- UI는 Runtime 권한을 가지지 않는다. UI는 명령/표현 계층이다.
- Catalog는 이미지 원본을 보존하고 Object Editor는 원본 파일을 직접 덮어쓰지 않는다.
- 삭제/ID 변경은 참조 영향 검사를 거친다.
- 외부 Asset은 필수성 검토와 Master 승인 없이는 추가하지 않는다.
- P0 완료 전 P1 기능을 자동 착수하지 않는다.

## 4. Phase 0 — 기준선 / 공통 Authoring Contract

목표: 모든 메뉴가 같은 방식으로 동작할 수 있는 공통 계약을 확정한다.

대상:
- List / Select
- New / Duplicate 정책
- Edit
- Save
- Reload
- Delete / Delete Restriction
- Current ID
- Reference Picker
- Preview
- Validation
- Dirty State
- Unsaved Change Recovery
- Duplicate ID 처리
- Save Failure 처리
- Loader-equivalent validation
- Error message

검증:
- 각 메뉴에서 최소 1개 기존 데이터 Select → Edit → Save → Reload
- 참조 ID가 실제 Loader에서 동일하게 해석되는지 확인

완료 조건:
`Authoring Validation → Reference Validation → Persistence Validation → Loader Validation`이 동일 데이터에 대해 통과.

## 5. Phase 1 — Catalog / Visual Asset Foundation

우선순위: P0 / 최우선

목표: 모든 게임 오브젝트가 동일한 Visual Asset 경로를 사용하도록 만든다.

범위:
- Source Image Browser
- Preview
- Region Selection
- Visual Asset ID
- Crop / Variant
- Anchor / Grid
- Owner / Usage
- Reference-aware Delete
- Save / Reload
- VisualAssetResolver 연계

주요 검증:
`Source Image → Region → Catalog Asset → Robot/Unit/Tower/Building 선택 → Save/Reload → Resolver`

완료 조건:
동일 Catalog Asset이 여러 Consumer에서 재사용되고 Reload 후 동일하게 resolve된다.

## 6. Phase 2 — Semantic Object Editors

순서:
`Faction → Robot → Unit → Tower → Building`

### Faction

목표: 상위 소유/정체성 ID를 만든다.

P0:
- ID
- Name
- Metadata
- Reference validation

### Robot

P0:
- ID / Type / Name
- Faction
- HP / Speed / Damage / Range
- Profile
- Idle / Move / Attack / Hit / Death
- Projectile
- Skill slots
- Preview / Validation

### Unit

P0:
- ID / Type / Name
- HP / Speed / Damage
- Attack Type / Range
- Sprite / Profile / Projectile
- Idle / Move / Attack / Hit / Death

### Tower

P0:
- ID / Type / Name
- Cost / Damage / Range / Target Preference
- Basic / Idle / Attack / Hit / Death
- Projectile
- Upgrade Cost / Level 2 stats

### Building

P0:
- ID / Name / Category / HP
- Visual Asset
- Preview
- Map reference

공통 검증:
`Catalog Asset → Object Editor → Save/Reload → Runtime Resolver`

완료 조건:
각 Object가 실제 Runtime에서 동일 ID와 Visual/Stats로 생성될 수 있다.

## 7. Phase 3 — Scenario Authoring

순서:
`Map → Mission → Stage → Campaign`

### Map

P0:
- Map ID/Name
- Map Size / Origin / Pixel Size
- Background/Tile
- Visual placement
- Goal/Base
- Enemy Spawn/Lane
- Robot Spots
- Tower Slots/Areas
- Gameplay Areas/Points
- Save/Reload

### Mission

P0:
- ID / Title / Briefing
- Type
- Target
- Time Limit
- Validation

### Stage

P0:
- ID / Order / Name
- Map
- Mission
- Reward
- Initial Gold / Base HP
- Allied Units
- Encounters / Waves / Groups
- Enemy / Count / Interval / Lane
- Wave Auto Start Delay / Group Gap

### Campaign

P0:
- Campaign ID / Name
- Ordered Stage List
- Stage Reference Validation

완료 조건:
`Map → Mission → Stage → Campaign`이 Save/Reload 후 동일한 구조로 Loader에서 해석되고 Runtime Stage 진입이 가능하다.

## 8. Phase 4 — Gameplay Runtime Core

목표: Scenario data가 실제 플레이 가능한 상태가 되도록 한다.

P0:
- Stage entry
- READY / RUNNING / GROWTH / VICTORY / DEFEAT
- Map runtime
- Robot control
- Enemy spawn
- Wave progression
- Tower behavior
- Allied Units
- Combat resolution
- Mission resolution
- Reward
- Result state

핵심 계약:
`Intent → Validation → GameplayEvent → Resolution → State Change → Presentation`

완료 조건:
최소 1개 Stage에서 Start → Wave → Combat → Mission → Victory/Defeat가 끝까지 수행된다.

## 9. Phase 5 — Gameplay UI / Interaction

Gameplay Core와 병행 가능하지만 Core authority 계약 확정 후 구현한다.

P0 UI:
- Top Status Bar
- Base HP / Gold
- Stage / Encounter / Wave
- Target Info
- Robot Panel
- HP / Energy / Level / XP
- Action Palette
- Basic / Special / Skill 1–3 / Finisher
- Cooldown / Energy / Locked / Ready
- Auto / Manual
- Combat Log
- Minimap
- Victory / Defeat overlay
- Growth choice
- Inventory

Interaction:
- Robot selection/movement
- Enemy target selection
- Tower selection/build
- Camera pan/zoom/center
- Minimap navigation
- Inventory
- Growth selection

완료 조건:
카메라 이동에도 HUD가 screen-space에 유지되고, UI 상태가 Runtime 상태와 항상 일치하며, 결과 화면이 정상적으로 입력을 차단한다.

## 10. Phase 6 — Settings / Player Persistence

목표: Runtime User Settings를 안정화한다.

P0:
- Language: ko/en
- BGM Volume
- SFX Volume
- Restore Defaults
- Save/Reload
- Restart persistence
- Corrupt/missing key recovery

저장:
`user://menos_settings.cfg`

금지:
- Content SQLite 변경
- Catalog 변경
- Gameplay balance 변경

완료 조건:
설정 변경 → 즉시 Runtime 반영 → 저장 → 재시작 → 동일 설정 복원.

## 11. Phase 7 — Presentation Runtime: VFX → SFX → BGM → Voice

순서는 Runtime 판별력과 의존성 기준이다.

### 7.1 VFX

현재 `impact_explosion` 기반 Runtime adapter/instance가 존재한다.

P0:
- Content Editor 메뉴 활성화
- Definition List/New/Save/Delete/Refresh
- Validator
- Definition → Adapter → Instance → Render
- Combat Event 연계

완료 조건:
실제 Combat Event 하나가 Definition을 거쳐 Runtime VFX를 생성한다.

### 7.2 SFX

P0:
- SFX Definition
- Audio Asset
- Event Binding
- Volume/Pitch/Bus
- Priority/Concurrency
- Legacy `play_sfx()` 호환

Pilot:
`ROBOT_LASER_FIRE`

완료 조건:
Gameplay Event → SFX Binding → Playback가 실제 실행된다.

### 7.3 BGM

P0:
- STAGE/NORMAL
- COMBAT
- VICTORY
- DEFEAT
- Faction reference
- Loop / Loop Point
- Volume / Bus
- Transition

BOSS와 3 Faction × 5 Context 전체 구성은 검증 후 확장한다.

완료 조건:
Normal → Combat → Victory/Defeat 전환이 동일 Runtime state에서 재현된다.

### 7.4 Voice

P0:
- Dialogue ID
- Voice Profile
- Voice Asset
- Language
- Volume / Bus
- Priority
- State
- Runtime Binding
- Silent Fallback

Dialogue/Subtitle과 Voice Asset은 분리한다.

완료 조건:
Voice Asset이 없더라도 Gameplay가 중단되지 않고, 존재할 경우 올바른 Dialogue ID에 연결된다.

## 12. Phase 8 — Full E2E / Campaign Acceptance

목표: 개별 메뉴가 아니라 실제 제작-플레이 흐름을 검증한다.

### Authoring E2E

`Source Image → Catalog → Robot → Tower → Map → Mission → Stage → Campaign`

### Runtime E2E

`Campaign → Stage 1 → Wave → Enemy Combat → Giant → Mission → Victory → Stage 2`

### Failure E2E

- invalid reference
- missing asset
- invalid action
- Base HP 0
- corrupt settings
- missing audio

### UI E2E

- HUD anchor
- camera interaction
- action availability
- target display
- minimap
- inventory
- result overlay

완료 조건:
핵심 경로에 대해 CODE / BUILD / EDITOR / PIE 상태가 별도로 판정되고 Master가 실제 Runtime 결과를 승인한다.

## 13. Phase 9 — Production Hardening

P0 E2E가 성공한 뒤에만 진행한다.

후보:
- Undo/Redo 강화
- Production Lock
- Advanced Validation Panel
- Reference Inspector
- Template/Duplicate
- Responsive layout
- Controller remapping
- Accessibility
- Display options
- Master/Voice volume
- Advanced VFX/SFX/BGM/Voice
- Performance/LOD
- Hot Reload/Compare
- Localization expansion

이 단계의 기능은 필요성이 검증된 것만 채택한다.

## 14. 기능 우선순위 매트릭스

| Priority | 기능 | 이유 |
|---|---|---|
| P0-A | Common Authoring Contract | 모든 메뉴의 기반 |
| P0-A | Catalog | 모든 Visual Asset의 공급원 |
| P0-A | Robot/Unit/Tower/Building | Runtime 객체 생성의 기반 |
| P0-A | Map/Mission/Stage/Campaign | 플레이 가능한 Scenario 구성 |
| P0-A | Gameplay Core | 실제 실행의 핵심 |
| P0-A | Gameplay UI | 플레이 조작/상태 표시 |
| P0-B | Settings | 사용자 지속 설정 |
| P0-B | VFX | Combat presentation |
| P0-B | SFX | Event feedback |
| P0-B | BGM | State presentation |
| P0-B | Voice | Dialogue presentation |
| P1 | Pause | 현재 요구/Runtime 계약 미확정 |
| P1 | Display/Input/Accessibility | 기본 Runtime 이후 |
| P1 | Advanced media authoring | Core 안정화 이후 |

## 15. 단계별 검증 Gate

각 Phase는 다음 Gate를 통과해야 종료한다.

### Gate A — Authoring
`Edit → Save → Reload → same data`

### Gate B — Reference
`Picker/ID → referenced object resolves`

### Gate C — Persistence
`Save → Repository/SQLite → Reload`

### Gate D — Loader
`Saved data → Loader → Runtime model`

### Gate E — Runtime
`Runtime model → actual behavior`

### Gate F — UI
`Runtime state → UI → user input → same authoritative command`

### Gate G — PIE
`Master observes actual game behavior`

Gate 실패 시 다음 Phase로 자동 진행하지 않는다.

## 16. 병렬화 원칙

병렬 진행은 가능하지만 의존성이 없는 작업만 허용한다.

가능:
- Settings spec/implementation과 Content Editor documentation
- VFX authoring foundation과 Scenario documentation
- UI visual refinement과 non-conflicting validation tooling

불가:
- Loader 계약 확정 전 Object Editor 최종화
- Gameplay authority 확정 전 UI가 combat state를 직접 소유
- VFX/SFX/BGM/Voice definition 계약이 서로 다른 상태에서 통합 Runtime binding
- Campaign UI를 Stage progression 계약 없이 최종 구현

## 17. 현재 상태에서의 우선 실행 순서

1. Common Authoring Contract gap 정리
2. Catalog P0 완성/검증
3. Faction/Robot/Unit/Tower/Building P0 검증
4. Map/Mission/Stage/Campaign P0 연결 검증
5. Gameplay Core P0 E2E
6. Gameplay UI P0 E2E
7. Settings P0 persistence/recovery E2E
8. VFX P0 Runtime acceptance
9. SFX P0 Runtime acceptance
10. BGM P0 Runtime acceptance
11. Voice P0 Runtime acceptance
12. Full Campaign PIE acceptance
13. Production Hardening은 Master 승인 후 필요한 항목만

## 18. 현재 기준선 및 변경 안전성

Review baseline:
- HEAD: `0742d5b0c31cf6909811e9ce31f70c7b7d017caf`
- Branch: `main`
- Existing working changes: preserved
- New document: this file only
- Unrelated `.uid` / SQLite DLL untracked files: untouched

## 20. 실행 진행 기록 — 2026-10-08

### PROGRESS — Phase 0~7 최소 검증 및 P0 보완

현재 실행은 Master 위임 범위 안에서 백그라운드 테스트만 사용했다. 화면 테스트를 Master의 전면 조작으로 수행하지 않았다.

CONFIRMED:
- Godot 4.7.2 headless project scan/editor initialization PASS.
- Map/Catalog authoring smoke PASS.
- Campaign Runtime smoke PASS.
- Combat timing smoke PASS.
- Fixed tower smoke PASS.
- Pilot HUD smoke PASS.
- Content Validation + VFX validation PASS.
- VFX Editor authoring/scene/runtime adapter/runtime instance/preview/key/transform smoke PASS.
- Content Editor VFX entry smoke PASS.

### 수정 사항

1. StageLoader.resolve_stage_path()
   - ODB PK 숫자 Stage reference를 Legacy Stage ID로 resolve하도록 보완.
   - Runtime의 기존 StageManager reference 정책과 일치시킴.

2. ContentValidator
   - Campaign/Stage Catalog의 ODB PK numeric reference를 Legacy ID로 정규화.
   - Stage Mission/Reward numeric reference를 ODB PK resolver로 정규화.
   - Map validation을 Loader normalized schema와 source schema로 분리.
   - Team Mask validation을 Runtime이 실제 지원하는 source/region/frame 크기 기준으로 정렬.

3. VFX Editor smoke test
   - 변경된 Timeline node hierarchy에 맞게 test path 수정.

4. Content Editor VFX menu
   - BtnVFX를 활성화.
   - 기존 _open_vfx_editor() opener 및 vfx_editor.tscn 존재를 background smoke test로 검증.
   - 이 기록 시점에서는 SFX/BGM/Voice가 아직 disabled 상태였다. 이후 구현 진행에서 각 entry가 활성화되었으며, 아래 후속 기록이 현재 상태를 갱신한다.

5. Core Runtime smoke tests
   - StageManager.begin_run("single", "stage_01")를 test fixture 초기화에 추가하여 테스트 시작 시 발생하던 빈 Stage reference 오류를 제거.
   - Runtime product behavior는 변경하지 않음.

### 검증 상태

- CODE VERIFIED: 위 변경 경로 확인.
- BUILD VERIFIED: Godot headless project initialization 및 관련 script execution PASS.
- EDITOR VERIFIED: Map/Catalog/VFX scene 및 Content Editor VFX entry 확인.
- PIE VERIFIED: 아직 Master 실제 Runtime 관찰 승인 전.
- BACKGROUND SCREEN TEST CANON: 유지.

### 복구 완료

VFX authoring smoke test가 발생시킨 SQLite working-tree 변경은 Godot Editor 종료 승인 후 HEAD 기준으로 복구했다.

CONFIRMED:
- `git diff --numstat -- godot/content/menos.sqlite`에 출력 없음.
- `git diff --check` PASS.
- SQLite는 현재 변경 목록에서 제거됨.
- 기존 사용자 변경사항은 유지됨.

### 현재 판정

STATUS — PASS

목적 — 승인된 범위의 P0 기반/Runtime/VFX 백그라운드 검증 및 안전한 working-tree 복구.

판정 — SQLite side effect가 제거되어 해당 HOLD는 해소되었다.

## 22. 실행 진행 기록 — SFX P0 기반

### PROGRESS

SFX Production Pipeline의 P0 Pilot을 위한 기술 기반을 구현했다.

CONFIRMED:
- SFX Definition schema/class implemented.
- SFX Definition Loader/Repository implemented.
- SFX Runtime Adapter implemented.
- Runtime `play_sfx()` now attempts Definition → Adapter → Playback.
- Existing legacy SFX path remains as fail-safe; gameplay timing/decision logic is not changed.
- Missing SFX Definition/Asset does not stop gameplay.
- Definition/Adapter round-trip and existing Combat/Fixed Tower/HUD smoke paths pass.
- 이 기록은 SFX authoring UI 구현 전의 infrastructure 단계이다. 이후 `SFX Authoring / Validation P0` 진행에서 SFX Editor와 Content Editor SFX entry가 활성화되었다.

### 검증

- CODE VERIFIED — SFX Definition/Loader/Repository/Adapter and GameController binding.
- BUILD VERIFIED — headless Godot script compilation/execution.
- EDITOR VERIFIED — not required for this infrastructure-only step.
- PIE VERIFIED — not established.
- BACKGROUND SCREEN TEST CANON — maintained.

### PROGRESS — ROBOT_LASER_FIRE Pilot

Master 승인 후 외부 Source 조사를 진행했고, CC0로 명시된 Freesound Daleonfire / Laser2를 선택했다. Source provenance는 godot/sound/ATTRIBUTION.md에 기록했다. Source preview를 runtime WAV로 변환하고 Godot import를 완료했다.

CONFIRMED:
- Source page/license: CC0.
- Runtime WAV: 48 kHz, stereo, 16-bit PCM, 0.619729 s.
- ROBOT_LASER_FIRE Definition을 SQLite sfx_definitions에 등록.
- Definition Loader → Repository → Runtime Adapter → AudioStream resolution PASS.
- Existing SFX legacy fallback remains intact.

검증:
- CODE VERIFIED — Definition/Loader/Repository/Adapter/Runtime binding.
- BUILD VERIFIED — headless execution and Godot asset import.
- EDITOR VERIFIED — asset import scan confirmed.
- PIE VERIFIED — not established.

### PROGRESS — SFX Authoring / Validation P0

SFX Editor를 추가하고 Content Editor의 SFX 메뉴를 활성화했다.

CONFIRMED:
- SFX Editor: List / New / Edit / Save / Delete / Refresh / Preview.
- Save validation checks ID, Audio Asset, Volume, Pitch, Bus, concurrency limits and cooldown.
- Save → SQLite → Repository Reload → Delete authoring smoke PASS.
- Content Editor SFX entry smoke PASS.
- Full content validation remains PASS: 0 errors / 0 warnings.
- Existing ROBOT_LASER_FIRE pilot remains resolvable through Definition → Adapter → AudioStream.

검증:
- CODE VERIFIED
- BUILD VERIFIED
- EDITOR VERIFIED — SFX Editor scene and Content Editor entry load successfully.
- PIE VERIFIED — not established.
- BACKGROUND SCREEN TEST CANON — maintained.

### 현재 판정

STATUS — PASS (SFX P0 authoring + technical pilot)

목적 — SFX를 Content Editor에서 실제 Definition으로 authoring하고 Runtime 경계까지 연결.

판정 — P0 authoring/validation/runtime infrastructure와 pilot asset 연결을 충족했다. 남은 것은 Master의 실제 청취/Production Acceptance다.

### PROPOSAL

Master가 ROBOT_LASER_FIRE를 실제 청취하여 Production Acceptance하면, 동일 구조로 필요한 P0 SFX event들을 등록하고 legacy binding을 Definition binding으로 점진 전환한다. Master 청취 승인 전에는 음원 수량과 BGM/Voice 범위를 확대하지 않는다.

## 21. 계획 최종 판정

**STATUS — PASS (계획 수립)**

**CONFIRMED** — 메뉴/기능은 Asset, Semantic Object, Scenario, Runtime, Player Settings, Presentation의 계층으로 분리할 수 있다.

**HIGH CONFIDENCE** — 위 순서가 현재 데이터 의존성과 Runtime 검증 가능성을 기준으로 가장 안전한 개발 순서다.

**UNVERIFIED** — 각 Phase의 실제 구현 소요와 병렬 작업의 정확한 일정은 아직 측정하지 않았다.

**PROPOSAL** — Phase 0~8을 P0 개발선으로 사용하고, Phase 9는 P0 E2E 성공 이후 Master 승인으로 제한한다.

**OUT OF SCOPE** — 일정/인력/예산 추정, 외부 Asset 확보, Production Art 확정, 새로운 gameplay feature 추가.

**NEXT STEP** — Master가 요청할 때 다음 Phase의 구체 작업지시를 작성한다. 성공 후 자동으로 다음 Phase를 시작하지 않는다.

## 23. SFX Production Candidate Expansion — 2026-10-08

### PROGRESS

Master approved continuation after the SFX pilot gate.

CONFIRMED:
- The eight existing gameplay/UI SFX IDs are registered in `sfx_definitions` and resolve through Definition → Repository → Runtime Adapter.
- Four previously unverified local SFX assets were replaced at the Definition binding level with CC0 Kenney Interface Sounds candidates: `UI_CANCEL.ogg`, `UI_ERROR.ogg`, `TOWER_SELECT.ogg`, `TOWER_BUILD.ogg`.
- Source package: Kenney Interface Sounds, OpenGameArt, CC0.
- Source provenance is recorded in `godot/sound/ATTRIBUTION.md`.
- Existing `play_sfx()` gameplay bindings were not structurally changed; legacy fallback remains available.
- Temporary source staging files were removed after import.
- Headless SFX validation and Definition/Adapter smoke tests pass after the asset binding change.

STATUS: PASS — SFX technical/authoring production-candidate stage.

VERIFICATION:
- CODE VERIFIED
- BUILD VERIFIED
- EDITOR VERIFIED
- PIE VERIFIED — not established
- Background screen-test Canon maintained.

PROPOSAL:
- Treat the four Kenney assets as the current P0 Production Candidates, not Canon/final audio.
- Master should perform actual listening/Runtime acceptance before Production Lock.
- If accepted, migrate remaining presentation events only where gameplay currently requires them; do not increase SFX scope merely because the infrastructure exists.
- After SFX acceptance, proceed to BGM P0 definition/runtime pilot. Voice remains after BGM unless a Master-priority change is requested.

## 24. BGM P0 Pilot — 2026-10-08

STATUS: PASS — technical pilot / authoring foundation.

CONFIRMED:
- BGM Definition, Loader, Repository, Runtime Adapter, Controller, Validator implemented.
- SQLite bgm_definitions pilot catalog registered.
- Four Faction 01 contexts registered: NORMAL, COMBAT, VICTORY, DEFEAT.
- CC0 Dark Sci-Fi Audio Pack source provenance recorded.
- Asset import, catalog validation, Definition/Adapter resolution, and runtime controller smoke test pass.

VERIFICATION:
- CODE VERIFIED
- BUILD VERIFIED
- EDITOR VERIFIED
- PIE VERIFIED — not established.

PROPOSAL:
- Keep 4-context P0 minimum; do not expand to 15 tracks until Master accepts the pilot set.
- Boss context remains conditional on Giant/Boss runtime music need.
- After Master listening acceptance, bind BGMController to authoritative gameplay state transitions and then expand only required Faction/Context combinations.



## 25. BGM Runtime Binding Progress — 2026-10-08

### PROGRESS

The approved BGM pilot was connected to the authoritative `GameController` run state without expanding the asset scope.

CONFIRMED:
- `BGMController` is instantiated by `GameController` for the active run.
- Faction is resolved from the Robot Catalog; current pilot fallback is `FACTION_01`.
- Runtime state mapping is state-driven: `RUNNING → COMBAT`, `READY/GROWTH → NORMAL`, `VICTORY → VICTORY`, `DEFEAT → DEFEAT`.
- Stage reset starts NORMAL; wave start selects COMBAT.
- Godot 4.7.2 headless project initialization PASS.
- BGM validation, Definition/Adapter, Runtime Controller, Combat Timing, and Pilot HUD smoke paths PASS.
- `git diff --check` PASS.

VERIFICATION:
- CODE VERIFIED
- BUILD VERIFIED
- EDITOR VERIFIED
- PIE VERIFIED — UNVERIFIED
- Actual audio listening / Production Acceptance — UNVERIFIED

KNOWN WARNING:
- The BGM Runtime Controller smoke test reports ObjectDB/resource cleanup warnings at exit despite a functional PASS. This remains a test-harness cleanup issue and is not classified as a clean zero-warning result.

### PROPOSAL

Keep the four-context pilot as the acceptance target. Do not create the planned 15-track (3 Faction × 5 Context) matrix yet. Crossfade remains a reserved definition field; actual crossfade playback is a later implementation item if required after acceptance.

### DECISION GATE

Master listening / Production Acceptance of the four BGM pilot contexts and, separately, PIE observation of state-driven transitions.

## Voice P0 Technical Foundation — 2026-10-08

The approved BGM gate was accepted for continuation. Voice P0 technical authoring was then implemented within the existing scope.

CONFIRMED:
- Voice Definition / Loader / Repository / Validator / Runtime Adapter implemented.
- Voice Editor scene implemented with List/New/Refresh/Edit/Save/Delete/Preview.
- Content Editor VOICE entry enabled.
- SQLite voice_definitions catalog created with one Draft pilot definition.
- The pilot has no actual Voice Asset yet; validation emits a warning and Runtime Adapter preserves Silent Fallback.
- Repository Save/Reload/Delete, Runtime Silent Fallback, Voice Editor entry, and Content Editor Voice entry smoke tests PASS.
- No external Voice source was introduced.

VERIFICATION:
- CODE VERIFIED
- BUILD VERIFIED
- EDITOR VERIFIED
- PIE VERIFIED — UNVERIFIED
- Actual Voice listening / Production Acceptance — UNVERIFIED

DECISION GATE:
Master must provide or approve the first actual Voice Asset and its Voice Profile / Dialogue performance. Until then, expanding to multiple characters, languages, or three Faction voice sets is not justified.

PROPOSAL:
- Keep one Dialogue/Voice Profile as the P0 pilot.
- Preserve Silent Fallback so missing Voice never blocks Gameplay.
- Current project has no dedicated Voice audio bus, so the pilot uses Master; add a dedicated Voice bus only when separate Voice volume control becomes required.
- Do not introduce external/generated Voice assets without Master approval of the generation source/tool and production terms.


## Voice P0 Asset Progress — 2026-10-08

### PROGRESS

Master approved continuation at the Voice asset decision gate. The existing single Voice pilot now has a real audio asset and Definition binding.

CONFIRMED:
- `VOICE_PILOT_FACTION_01_ATTACK_01_KO.wav` is present and linked by the SQLite Voice Definition.
- Audio technical inspection: 22.05 kHz, mono, 16-bit PCM, 1.242 s; no clipping detected.
- Voice validation, repository, runtime silent-fallback, editor entry, and Content Editor entry smoke tests all PASS with exit code 0.
- Source/tool evidence is the local Ppaso-TTS repository (`D:\Atlas\_ppaso_voice`), whose repository license is Apache 2.0. The exact generation command/script/prompt was not recovered.

VERIFICATION:
- CODE VERIFIED
- BUILD VERIFIED
- EDITOR VERIFIED
- PIE VERIFIED — UNVERIFIED
- Actual listening / Production Acceptance — UNVERIFIED

### DECISION GATE

Master listening and approval of the actual pilot Voice Asset. Until accepted, do not expand to additional characters, Factions, or languages.

### PROPOSAL

If accepted, the next minimum work is Dialogue/Subtitle runtime linkage and one actual gameplay/dialogue event verification. Record exact script + generation prompt as provenance before creating further Voice assets.


## 26. 2026-10-08 Current Roadmap Reconciliation

STATUS: PASS - P1 Gameplay is implemented, verified, committed, and pushed.

CONFIRMED:
- Campaign 1 Production Acceptance remains approved; do not reopen.
- Gameplay P1 commit 94b53fe3 is pushed to main.
- Settings P0 implementation/E2E is complete; Master PIE observation remains separate.
- Presentation P0 pilot work exists for VFX/SFX/BGM/Voice; additional asset expansion remains gated by Master acceptance.
- Map Editor P0 already contains Undo/Redo, Dirty State, Unsaved Load Guard, Validation, bounds/reference checks, and Required Base protection.
- Map Editor currently has no dedicated New Map / Duplicate Map / Delete Map workflow.

ROADMAP DECISION:
1. Reconcile project state documentation.
2. Complete only low-risk Map Editor P0 authoring gaps that do not change Canon semantics.
3. Stop at the first point requiring a design decision: map identity/ID generation, delete policy, Production Lock semantics, or robot_id meaning.
4. Then establish the Common Authoring Contract before broadening semantic editors.

MAP EDITOR NEXT GATE:
- New Map: requires authoritative Map ID/name generation and initial schema defaults.
- Duplicate Map: requires ID collision/renaming policy.
- Delete Map: requires reference-protection policy and whether deletion is soft/hard.
- Grid Snap UX: can proceed only if existing 32px grid semantics are retained without Canon change.

OUT OF SCOPE:
- Reward Gold economy semantics.
- Campaign 1 feature expansion.
- Production Lock implementation.
- robot_id semantic redesign.
- Additional Voice/BGM/SFX/VFX production expansion before their acceptance gates.

PROPOSAL:
Proceed with state reconciliation now. Then investigate the existing Map data schema and Editor persistence path to determine whether Grid Snap UX can be implemented without a decision. Hold before New/Duplicate/Delete if authoritative identity/deletion semantics are not already defined.


## 27. 2026-10-08 Map Editor P0 Investigation Gate

PROGRESS
- Current Map Editor and MapLoader were inspected READ-ONLY.
- Map persistence is SQLite-backed through a fixed table mapping: map_01, map_01_src, map_02, map_03.
- Save updates exactly one existing document row; the current loader has no generic map creation, duplication, or deletion API.
- Map ID and display name are validated fields and are persisted inside the raw map document, but table identity is also used as the document key.
- The editor already uses a fixed 32px grid throughout placement, selection, resize, gameplay points, and rendering. There is no separate free-position mode requiring a Snap toggle.

CONFIRMED:
- New Map is not a simple UI addition; it requires a canonical map identity/document creation policy and likely persistence schema support.
- Duplicate Map requires a unique map ID/table/document identity policy.
- Delete Map requires reference protection plus a hard-delete/soft-delete decision.
- Grid Snap On/Off is not currently a missing core function; placement is intrinsically cell/grid based at 32px.

DECISION GATE:
A Master/Canon decision is required before implementing Map New/Duplicate/Delete. The current fixed-table persistence model prevents safely adding CRUD semantics without deciding the authoritative map identity and deletion/reference policy.

PROPOSAL:
Do not modify Map Editor CRUD yet. Treat the current 32px grid behavior as sufficient for P0 and move to the Common Authoring Contract only after the map identity/deletion policy is decided. If Master wants Map CRUD next, first define whether maps remain fixed ODB-backed documents or become generic map records with stable IDs and reference-aware deletion.


## 28. 2026-10-08 Map CRUD Implementation Gate

STATUS: PASS — Master approved the recommended Map CRUD policy and implementation proceeded.

CANON/APPROVED POLICY:
- Stable Map ID is the authoritative identity exposed to authoring and runtime references.
- Existing canonical maps remain protected and are not hard-deleted.
- New/Duplicate maps are stored in a generic SQLite `map_documents` table keyed by `map_id`.
- Existing fixed Map tables remain compatible; migration of existing canonical tables is not required.
- Delete is hard-delete for author-created dynamic maps only.
- Delete is blocked when any Stage directly references the Map.
- 32px cell/grid placement remains intrinsic; no Snap On/Off mode is introduced.

IMPLEMENTED:
- MapLoader lists fixed canonical maps plus dynamic map_documents records.
- New Map creates a dynamic record from the existing Map schema defaults with empty authoring content.
- Duplicate Map clones an existing map into a new stable ID/name.
- Dynamic Map Save serializes editor Vector2/Vector2i data back to the established raw JSON schema.
- Delete Map enforces canonical protection and Stage reference protection.
- Map Editor now provides Map selector, New Map, Duplicate, and Delete controls.
- Unsaved changes continue to block map switching/CRUD.

VERIFICATION:
- CODE VERIFIED: PASS — Godot headless editor load/compile.
- MAP_CRUD_SMOKE_PASS.
- MAP_NEW_SMOKE_PASS.
- MAP_DYNAMIC_SAVE_SMOKE_PASS.
- Existing project SQLite was not mutated by these tests; tests used copied databases.
- PIE VERIFIED: NOT VERIFIED.

NEXT DECISION GATE:
- Map CRUD policy is now implemented. Before commit/push, inspect the full diff and determine whether the Common Authoring Contract should be the next implementation area.
- No additional Map CRUD semantics should be added automatically.

PROPOSAL:
Proceed to final diff review and Map Editor P0 regression verification. If PASS, stop at the commit/push approval gate rather than expanding scope.


## 2026-10-08 P0 E2E Decision Gate — Catalog → Object → Runtime

STATUS: HOLD — implementation expansion not authorized until the minimum Object → Runtime Visual E2E is verified.

### Master Decision

Master accepted the following P0 verification policy:

1. Verify one minimum E2E path independently for Robot, Unit, and Tower:
   `Catalog Visual Asset → Object Editor → Save → Reload → Runtime display`
2. Do not require every Object to call `VisualAssetResolver` directly if its actual Runtime consumption path is functionally valid.
3. If a specific Object has a broken Runtime display path, isolate that Object as the implementation target rather than redesigning the common Catalog contract.
4. Building Runtime semantics remain HOLD and are not expanded by this verification.

### CONFIRMED

- Catalog/Visual Asset authoring and Map/Catalog smoke verification are PASS.
- `EDITOR_DATA_SMOKE_TEST_PASS`.
- `FIXED_TOWER_SMOKE_PASS`.
- `CAMPAIGN_RUNTIME_SMOKE_PASS stages=3 giant=true impact_vfx=true`.
- ContentValidator validates Visual Asset references for Enemy, Allied Unit, Tower, and Robot.
- Robot Definition contains an explicit `VisualAssetResolver.resolve()` path.
- Tower/Allied Unit definitions retain Visual Asset IDs/strings, but their actual Runtime visual consumption path has not yet been accepted as common Resolver E2E.

### VERIFICATION

- CODE VERIFIED: Catalog/Object reference and validation infrastructure confirmed.
- BUILD VERIFIED: Relevant headless smoke scripts pass.
- EDITOR VERIFIED: Catalog/Map authoring smoke passes.
- PIE VERIFIED: UNVERIFIED.
- Robot/Unit/Tower Catalog → Runtime Visual E2E: UNVERIFIED.
- Building Runtime semantics: HOLD.

### PROPOSAL

At the next execution opportunity, run only the minimum Robot/Unit/Tower Visual E2E required above. Do not introduce a common Resolver refactor unless the runtime verification demonstrates an actual broken path.

Success criterion: each tested Object can load its Catalog Visual Asset after Save/Reload and display it through its existing Runtime path.

If all three pass, ACCEPT/STOP this gate. If one fails, investigate only that Object's Runtime consumer and report the smallest required change.

## 29. Content Editor 1차 완성 개발계획 — 2026-10-08

### 29.1 목표

**목표: Content Editor의 1차 완성**

Content Editor 15개 Authoring 메뉴를 대상으로 구현과 검증에 필요한 공통 규칙과 메뉴별 최소 Runtime 계약을 하나의 개발선으로 통합한다.

대상:
MAP / STAGE / MISSION / CAMPAIGN / FACTION / ROBOT / UNIT / TOWER / BUILDING / SKILL / CATALOG / VFX / SFX / BGM / VOICE

Settings / Language / Quit은 Content Editor 1차 완성 범위에서 제외하고 Runtime Settings 계획으로 관리한다.

### 29.2 1차 완성의 정의

Content Editor 메뉴 하나의 최소 완료 기준은 다음이다.

Edit → Validate → Save → Reload → Verify

필수 공통 조건:
- Editor entry가 존재한다.
- Definition / Repository / Loader 경로가 확인된다.
- Validation이 존재하고 저장 전 적용된다.
- Save → Reload 후 동일 데이터가 유지된다.
- 참조 ID가 실제 Loader에서 동일하게 해석된다.
- Runtime 소비 메뉴는 최소 1개의 실제 소비 경로를 검증한다.
- Editor Preview PASS는 Save/Loader/Runtime PASS로 승격하지 않는다.
- 자동화/백그라운드 PASS는 PIE VERIFIED로 승격하지 않는다.

### 29.3 P0 공통 Authoring Contract

1. Select / New / Edit / Save / Reload / Delete의 동작을 명확히 한다.
2. Duplicate ID는 저장을 거부한다.
3. 참조 중인 데이터의 삭제는 기본적으로 거부한다.
4. P0에서는 ID 자동 변경과 자동 참조 갱신을 사용하지 않는다.
5. Save/Reload 실패 시 기존 정상 데이터가 손상되지 않아야 한다.
6. Dirty 상태에서 Reload/Close/전환 시 미저장 변경을 명확히 처리한다.
7. 오류는 대상 메뉴와 필드를 식별할 수 있어야 한다.
8. Loader-equivalent validation을 통과한 데이터만 Runtime 소비 단계로 보낸다.

이 공통 계약은 Master 승인에 따라 **CANON**이다. P0 전체 Content Editor 메뉴에 적용한다.

### 29.4 Master 결정이 필요한 항목의 처리 순서

**즉시 결정해야 하는 공통 항목**
- Common Authoring Contract 채택 여부
- ID 변경/삭제/참조 보호 정책
- Localization Default / Fallback 언어

**해당 메뉴 Runtime 검증 직전에 결정**
- Mission target_id 의미
- Unit 6번째 Role
- Robot Command A/P/H/M 및 Skill Runtime 계약
- Tower EMP 중첩/재적용/Upgrade 영향
- Building Repair / Gate / ownership 규칙
- Skill Execution / Effect / Cost / Cooldown / Animation 계약
- Catalog Visual Asset Runtime contract: Source / Region / Frame / Anchor; Scale is owned by Runtime Object / Presentation.

**1차 완성 이후 후순위**
- Campaign Chapter / Story Runtime
- Faction Color의 Runtime 의미
- Production Gate 상태 모델
- Asset Editor 통합 UI 범위
- Wave / Encounter / Enemy Group / Reward 독립 Editor 분리
- Editor UI Localization 전체 적용
- Presentation Production 확장

### 29.5 구현 순서

#### Phase CE-0 — 공통 Authoring 기반

목표: 모든 메뉴의 검증 방법을 동일하게 만든다.

작업:
- 공통 CRUD 동작 점검
- Save / Reload / Dirty / Recovery
- Duplicate ID / Reference 보호
- Validation / Loader-equivalent validation
- 오류 표시 기준

Gate:
동일한 테스트 데이터에 대해 Edit → Validate → Save → Reload → Verify가 재현된다.

#### Phase CE-1 — MAP / CATALOG 기반

MAP:
- 현재 승인된 New / Duplicate / Delete 정책 유지
- Reference protection
- Save → Reload
- Runtime Map Load
- 32px grid semantics 유지

CATALOG:
- Asset registration
- metadata / validation
- Save → Reload
- Robot / Unit / Tower의 Visual Asset 소비 경로 검증

Gate:
- MAP CRUD E2E PASS
- CATALOG → Object → Runtime Visual E2E의 최소 3개 경로(Robot / Unit / Tower) PASS

#### Phase CE-2 — Semantic Object Editor

순서:
FACTION → ROBOT → UNIT → TOWER → BUILDING → SKILL

공통:
- Definition / Reference
- Save / Reload
- Validation
- Runtime 소비 경로

메뉴별 최소 검증:
- Faction: ID / Name / Registry / Reference
- Robot: Faction / Stats / Visual / Skill refs / 최소 Runtime load
- Unit: Faction / Role / Combat / Visual / Spawn/AI
- Tower: Target / Attack / Level 2 / Visual / Runtime
- Building: Base / Gate / Repair 기본 구조
- Skill: 현재 구조와 참조를 먼저 검증하고, Runtime 의미론은 결정 후 최소 구현

Gate:
각 메뉴의 Save → Reload → Runtime 소비 경로가 확인된다. 의미가 미확정인 항목은 HOLD로 남기고 임의 결정하지 않는다.

#### Phase CE-3 — Scenario Editor

순서:
MISSION → STAGE → CAMPAIGN

MAP은 CE-1에서 기반을 제공한다.

검증:
- Mission Type / target / Time Limit
- Stage의 Map / Mission / Wave / Enemy reference
- Campaign Ordered Stage reference
- Save → Reload → Loader

Gate:
MAP → MISSION → STAGE → CAMPAIGN 구조가 Reload 후 동일하게 Loader에서 해석된다.

#### Phase CE-4 — Presentation Authoring P0

대상:
VFX / SFX / BGM / VOICE

범위:
- 기존 P0 Definition / Validator / Editor / Adapter 기반을 검증한다.
- 새 Asset 수량을 목표로 하지 않는다.
- Master Production Acceptance가 필요한 항목은 기술 검증과 분리한다.

Gate:
각 도메인의 P0 technical path가 PASS하고, Production Acceptance 미완료는 별도 상태로 남긴다.

#### Phase CE-5 — Content Editor 통합 E2E

최소 Authoring E2E:
Catalog → Robot → Tower → Map → Mission → Stage → Campaign

보조 경로:
Catalog → Unit
Catalog → Building
Faction → Object reference
Skill → Robot reference

Runtime E2E:
Campaign → Stage → Wave → Combat → Mission → Victory/Defeat

Gate:
- CODE VERIFIED
- BUILD VERIFIED
- EDITOR VERIFIED
- 필요한 메뉴의 Runtime 소비 경로 VERIFIED
- Master의 실제 Runtime 관찰이 필요한 경우 PIE VERIFIED를 별도 판정

### 29.6 1차 완성 판정 기준

**ACCEPT**
- 15개 메뉴의 Editor entry가 존재한다.
- 공통 Authoring Contract가 적용된다.
- Save → Reload와 Reference integrity가 핵심 메뉴에서 재현된다.
- Catalog → Object → Runtime 핵심 Visual E2E가 통과한다.
- Scenario Authoring이 Loader를 통해 Runtime 진입까지 연결된다.
- VFX/SFX/BGM/VOICE P0 technical path의 상태가 명확히 판정된다.

**HOLD**
- 핵심 Runtime 의미가 결정되지 않은 경우.
- ID / Delete / Reference 정책이 확정되지 않은 경우.
- 기존 데이터 손상 가능성이 발견된 경우.
- 검증 결과가 예상과 다른 경우.

**STOP**
- 1차 완성 기준을 충족하면 추가 Editor 기능을 자동으로 확장하지 않는다.

### 29.7 1차 완성 이후로 명시적으로 미루는 것

- Story / Dialogue 선행 구현
- Production Lock 전체 구현
- Undo/Redo 고도화
- Template / Advanced Duplicate
- 전체 Presentation Asset expansion
- 3 Faction × 5 BGM 전체 제작
- 다국어 Voice expansion
- 새로운 Gameplay feature

필요성이 실제 검증으로 확인된 항목만 Master 승인 후 재개한다.

### 29.8 현재 Gate

현재 문서 기준 다음 작업은 **CE-0 공통 Authoring 기반과 CE-1 MAP/CATALOG 검증**이다.

Common Authoring Contract / ID 변경·삭제·참조 보호 정책은 Master 승인에 따라 **CANON**이다. Localization 기준은 별도 결정 전까지 UNRESOLVED로 유지한다.

현재 확인된 별도 HOLD:
- Robot / Unit / Tower Catalog → Runtime Visual E2E 미검증
- Building Runtime semantics
- Mission target_id 최종 의미
- Unit 6번째 Role
- Robot Command/Skill Runtime contract
- Tower EMP rules
- Skill Runtime contract

### 29.9 기준 문서

이 개발계획의 Content Editor 1차 완성 범위와 우선순위는 다음 문서를 함께 참조한다.

- docs/CONTENT_EDITOR_IMPLEMENTATION_VERIFICATION_DECISION_MATRIX.md — 현재 결정사항/검증 기준 요약
- docs/MENOS_MASTER_REFERENCE.md — 프로젝트 Master Reference
- docs/BGM_PRODUCTION_PIPELINE.md
- docs/SFX_PRODUCTION_PIPELINE.md
- docs/VOICE_PRODUCTION_PIPELINE.md

역사 문서는 docs/archive/content-editor/에 보존하며 현재 개발 기준으로 사용하지 않는다.

### 29.10 판정

**STATUS — PASS (개발계획 업데이트)**

**CONFIRMED** — Content Editor 15개 메뉴의 구현/검증 기준과 공통 Authoring Contract 후보를 별도 결정 매트릭스로 정리했다.

**PROPOSAL** — 위 CE-0~CE-5 순서로 Content Editor 1차 완성을 우선한다.

**UNVERIFIED** — 일부 메뉴의 실제 Runtime 소비와 PIE 상태.

**OUT OF SCOPE** — Commit/Push, 새 Gameplay feature, Production Asset 대량 확장.

**다음 Gate** — 승인된 Common Authoring Contract / ID 정책을 CE-0 구현에 적용하고 CE-1 MAP/CATALOG 검증으로 진행한다. 추가 Canon 변경은 Master 승인 없이 수행하지 않는다.

## 30. 2026-10-08 CE-0 실행 감사 — Common Authoring Contract 적용성

### PROGRESS

CE-0 진입을 위해 현재 Editor 구현을 READ-ONLY로 대조했다.

### CONFIRMED

- Content Editor는 15개 메뉴 Scene routing을 보유한다.
- `_set_active_button_for_scene()`에는 SFX/VOICE 분기가 누락되어 있었다.
- SFX/VOICE 메뉴 자체의 opener는 존재하며, active-state 누락은 별도 UI 회귀 문제로 확인되었다.
- ContentValidator는 Loader-equivalent validation의 기반을 이미 제공한다.
- 여러 Editor가 SQLite/ObjectPersistence를 직접 호출하는 현재 구조가 존재한다.
- 현재 일부 Editor는 저장과 동시에 데이터를 영구 반영하며, 공통 Dirty → Save → Reload 계약이 통일되어 있지 않다.
- 일부 Editor에는 현재 Canon과 충돌하는 ID 변경/삭제 동작이 존재한다.
- 특히 Catalog/Image Editor의 Visual Asset ID rename 및 삭제 경로가 확인되었다.
- Faction, Mission, Skill, Tower, Unit, Stage 등에도 직접 delete/save 경로가 존재한다.
- 참조 중 삭제를 공통적으로 차단하는 단일 reference-protection 계층은 현재 확인되지 않았다.
- Godot 실행 파일의 현재 알려진 경로에서는 headless Build/Runtime 재검증을 수행하지 못했다. 따라서 이번 단계의 BUILD/PIE 상태는 NOT VERIFIED이다.

### CODE CHANGE

Content Editor의 scene 복귀 경로에서 누락된 SFX/VOICE active-state 분기를 추가했다.

변경 파일:
- `godot/editor/content_editor.gd`

### VERIFICATION

- `git diff --check`: PASS
- 코드 변경 Diff: 의도한 2개 active-state 분기만 포함
- CODE VERIFIED: 부분 PASS — 변경 경로 확인
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED

### DECISION GATE

공통 Canon을 실제 기존 Editor에 적용하려면 다음 구현 설계가 필요하다.

1. **Reference Protection 구현 위치**
   - 메뉴별 개별 검사로 분산할지
   - 공통 Reference/Usage 검사 계층으로 통합할지

2. **Save/Reload/Dirty 경계**
   - 현재의 즉시 SQLite 저장 구조를 유지하면서 Dirty/Recovery를 추가할지
   - Editor-local working copy를 두고 명시적 Save에서만 영구 반영할지

이는 단순 버그 수정이 아니라 15개 Editor의 공통 Authoring architecture에 영향을 주므로, 여기서 임의 설계하지 않고 HOLD한다.

### PROPOSAL

**공통 Reference/Usage 검사 계층 + Editor-local working copy**를 기본 방향으로 검토하는 것이 가장 안전합니다. 각 Editor는 편집 중 데이터를 메모리에서 보유하고, Validate → Save 시에만 Persistence를 호출하며, Delete는 공통 Usage 검사 결과가 비어 있을 때만 허용하는 구조입니다. 다만 기존 Editor별 Persistence 차이가 있으므로 실제 구현 전 최소 2개 대표 Editor(MAP/CATALOG)로 PoC하여 회귀 범위를 측정하는 것이 적절합니다.

성공 기준은 기존 데이터 손상 없이 Edit → Validate → Save → Reload → Verify와 참조 중 Delete 거부를 동일하게 재현하는 것입니다.

### 30.1 CE-0 PoC 결과

**CONFIRMED**
- MAP Editor는 이미 `current_map_data + map_dirty` 형태의 Editor-local working copy를 사용하고 있습니다.
- MAP의 Load/New/Duplicate/Delete는 dirty 상태에서 차단합니다.
- MAP Delete는 Stage reference를 검사하여 참조 중 삭제를 거부합니다.
- MAP Save는 이번 CE-0 적용으로 Loader 저장 전 `validate_map()`을 통과하도록 변경했습니다.
- MAP Save As는 기존 Map ID 변경으로 해석될 수 있으므로 Canon에 따라 다른 ID로의 Save As를 차단하도록 변경했습니다.
- Catalog Editor도 `entries`를 메모리에서 편집한 후 명시적 Save에서 catalog persistence를 수행하는 구조를 이미 갖고 있습니다.
- Catalog의 Visual Asset은 별도 `visual_assets` persistence를 사용하며, 현재 Visual Asset Save/Update/Delete 일부가 즉시 별도 저장소에 반영됩니다.
- 따라서 Catalog 전체에 Editor-local working copy 계약을 완전히 적용하려면 Catalog와 Visual Asset의 두 persistence 경계를 하나의 Save transaction으로 다루는 추가 설계가 필요합니다.

**VERIFICATION**
- MAP 변경 Diff는 의도한 validation-before-save 및 ID 변경 차단만 포함합니다.
- `git diff --check`: PASS
- 실제 Godot Build/Editor/PIE: NOT VERIFIED

**DECISION GATE**
Catalog의 일반 Asset Catalog와 Visual Asset Catalog가 서로 다른 persistence 경계를 가지므로, 이를 하나의 Save transaction으로 묶는 방법은 현재 단계에서 추가 설계가 필요합니다. 데이터 손상 방지를 위해 이 부분은 임의 구현하지 않고 HOLD합니다.

### 30.1 PoC 결과 — CATALOG Reference Protection

**CONFIRMED**
- CATALOG Editor에는 이미 content 경로를 순회하여 Visual Asset ID의 사용처를 수집하는 `usage_cache`가 존재한다.
- 따라서 별도의 전역 DB Reference Scanner를 즉시 추가하지 않고 기존 Usage Cache를 Canon의 Delete/ID 변경 보호에 연결할 수 있다.
- Visual Asset ID 변경 시 참조가 존재하면 변경을 거부하도록 구현했다.
- Visual Asset 삭제 시 참조가 존재하면 삭제를 거부하도록 구현했다.
- MAP Editor는 이미 `map_dirty`를 사용하여 미저장 상태에서 Load를 차단하고 Save 후 Dirty를 해제하는 working-copy 패턴을 보유한다.

**CODE CHANGE**
- `godot/editor/asset_catalog_editor.gd`
  - Visual Asset ID rename: 참조 중이면 거부
  - Visual Asset delete: 참조 중이면 거부

**UNVERIFIED**
- 실제 Editor에서 참조 중 Visual Asset을 Rename/Delete했을 때 UI가 기대대로 차단되는지
- CATALOG 전체의 Save → Reload → Verify가 실제 Runtime/Editor에서 재현되는지
- Visual Asset의 현재 즉시 Persistence 경로를 working-copy + 명시적 Save 구조로 전환할 때의 영향 범위

### 30.2 DECISION GATE

CATALOG에는 일반 Asset Catalog와 Visual Asset Catalog가 서로 다른 Persistence 경로를 사용한다. 일반 Asset은 명시적 Save를 사용하지만 Visual Asset의 New/Update/Rename/Delete 일부는 현재 즉시 Persistence한다.

따라서 **working-copy Canon을 Visual Asset까지 일관되게 적용할지**, 또는 기존 Visual Asset 즉시 저장을 유지하면서 Dirty/Recovery 계약만 보강할지를 여기서 결정해야 한다.

기존 즉시 Persistence 경로를 폐기하고 Visual Asset까지 working-copy + 명시적 Save 모델로 통일했습니다.

**IMPLEMENTED / VERIFIED**
- Visual Asset의 New/Update/Rename/Delete를 즉시 Persistence하지 않고 Editor working copy에 반영하도록 변경했습니다.
- 변경 시 `catalog_dirty`를 설정하고 Reload는 Dirty 상태에서 차단합니다.
- 일반 Catalog와 Visual Asset은 명시적 Save에서 하나의 SQLite transaction으로 저장합니다.
- 두 persistence 단계 중 하나라도 실패하거나 저장 후 read-back 검증이 실패하면 ROLLBACK합니다.
- Save 성공 후 Repository/Resolver를 reload하고 Dirty를 해제합니다.
- Visual Asset Rename/Delete의 참조 보호를 유지합니다.
- Godot 4.7.2 headless Editor 초기화와 smoke test를 통과했습니다.

**VERIFICATION UPDATE**
- Catalog Editor scene을 실제 Godot process에서 instantiate하여 Visual Asset New → Dirty → Rename → Dirty → Reload 차단 → Close 차단 → Save → Reload → Delete → Save → Reload → Close 흐름을 자동 E2E 검증했습니다.
- `CATALOG_AUTHORING_E2E_PASS` 및 exit code 0을 확인했습니다.
- 이는 Editor authoring-path 검증이며 Master의 실제 화면 확인을 의미하지 않으므로 PIE VERIFIED로 승격하지 않습니다.
- Save 실패를 의도적으로 주입하여 ROLLBACK을 확인하는 failure-injection 테스트는 아직 수행하지 않았습니다.

### 30.3 ROBOT Authoring Contract PoC

**IMPLEMENTED / VERIFIED**
- ROBOT Editor에 Editor-local working copy와 `robot_dirty`를 적용했습니다.
- Robot Property 변경은 Dirty로 표시되며 명시적 SAVE 전에는 Persistence하지 않습니다.
- Dirty 상태에서 RELOAD와 다른 Robot 선택을 차단합니다.
- New Robot은 working copy에만 추가하고 SAVE에서 전체 Robot Catalog를 transaction으로 저장합니다.
- Delete Robot은 working copy에서만 삭제하고 SAVE에서 Persistence합니다.
- P0 Robot ID 변경은 계속 금지합니다.
- Robot Catalog 저장 시 삭제된 Robot의 `odb_registry` mapping도 동일 transaction에서 제거하도록 Persistence를 보강했습니다.
- Save 성공 후 Repository reload를 수행하여 저장 결과를 다시 읽습니다.
- 빈 Visual Asset 경로를 Preview에서 load하지 않도록 최소 방어를 추가했습니다.

**VERIFICATION UPDATE**
- 실제 Godot process에서 Robot Editor를 instantiate하여 Property Edit → Dirty → Reload 차단 → Save → New → Dirty → Save → ODB mapping 확인 → Delete → Dirty → Save → ODB mapping 제거 흐름을 E2E 검증했습니다.
- `ROBOT_AUTHORING_E2E_PASS` 및 exit code 0을 확인했습니다.
- 테스트 중 실제 SQLite는 임시 백업 후 원상복구했습니다.
- `git diff --check`: PASS
- Godot 4.7.2 headless Editor initialization: PASS
- 자동 E2E는 PIE VERIFIED가 아닙니다.

**REMAINING ISSUE — HOLD CANDIDATE**
- ROBOT Editor의 `GENERATE MASK` 기능은 Robot working copy가 아니라 Visual Asset Catalog를 직접 Persistence하는 별도 cross-editor 경로를 사용합니다.
- 이는 일반 Robot Property Authoring Contract와 다른 persistence 경계를 만듭니다.
- 해당 기능을 Robot working copy에 포함할지, 또는 Visual Asset 변경은 Catalog Editor에서만 수행하도록 분리할지 결정이 필요합니다.

**PROPOSAL**
- Robot/Unit/Tower/Building의 일반 Property Authoring은 현재 PoC 패턴을 유지합니다.
- `GENERATE MASK` 같은 cross-editor Visual Asset mutation은 Robot Editor의 일반 Save transaction에 억지로 포함하지 않고, Catalog Editor 소유 작업으로 분리하는 방향을 권고합니다.
- Master 결정 전에는 이 cross-editor 경계를 추가 변경하지 않습니다.

### 30.4 UNIT Authoring Contract PoC

**IMPLEMENTED / VERIFIED**
- UNIT Editor에 Editor-local working copy와 `unit_dirty`를 적용했습니다.
- Allied Unit과 Enemy Catalog를 동일 working copy에서 편집하되 기존 source 경계를 유지합니다.
- Property/Visual Asset 변경은 Dirty로만 반영하고 명시적 SAVE 전에는 Persistence하지 않습니다.
- Dirty 상태 RELOAD와 다른 Unit 선택을 차단합니다.
- New/Delete는 working copy에서 staging한 후 SAVE에서 Persistence합니다.
- Image Editor의 pending Asset assignment가 더 이상 즉시 SAVE하지 않고 working copy에 반영됩니다.
- Enemy 저장 시 기존 `visuals`와 legacy runtime field 변환을 유지합니다.

**VERIFICATION UPDATE**
- 실제 Godot process에서 Property Edit → Dirty → Reload 차단 → Save → New → Save → Delete → Save를 E2E 검증했습니다.
- `UNIT_AUTHORING_E2E_PASS` 및 exit code 0 확인.
- 테스트 SQLite는 임시 백업 후 원상복구했습니다.
- `git diff --check`: PASS
- Godot 4.7.2 headless Editor initialization: PASS
- 자동 E2E는 PIE VERIFIED가 아닙니다.

### 30.5 TOWER Authoring Contract PoC

**IMPLEMENTED / VERIFIED**
- TOWER Editor에 Editor-local working copy와 `tower_dirty`를 적용했습니다.
- Property/Visual Asset 변경은 명시적 SAVE 전까지 Persistence하지 않습니다.
- Dirty 상태 RELOAD와 다른 Tower 선택을 차단합니다.
- New/Delete는 working copy에서 staging 후 SAVE합니다.
- Visual Asset 선택 및 region 정보도 working copy에만 반영합니다.

**VERIFICATION UPDATE**
- 실제 Godot process에서 Property Edit → Dirty → Reload 차단 → Save → New → Save → Delete → Save를 E2E 검증했습니다.
- `TOWER_AUTHORING_E2E_PASS` 및 exit code 0 확인.
- 테스트 SQLite는 임시 백업 후 원상복구했습니다.
- `git diff --check`: PASS
- Godot 4.7.2 headless Editor initialization: PASS
- 자동 E2E는 PIE VERIFIED가 아닙니다.

### 30.6 BUILDING Authoring Contract PoC

**IMPLEMENTED / VERIFIED**
- BUILDING Editor에 Editor-local working copy와 `building_dirty`를 적용했습니다.
- 기존 `BuildingRepository` 기반 SQLite 구조를 유지하면서 New/Edit/Delete를 working copy에서 staging합니다.
- New Building은 임시 working-copy ID를 사용하고 SAVE 시 실제 ODB PK를 transaction으로 생성합니다.
- Delete는 working copy에서 먼저 제거하고 SAVE 시 `buildings`와 `odb_registry`를 transaction으로 함께 삭제합니다.
- Dirty 상태 RELOAD와 다른 Building 선택을 차단합니다.
- Building Repository의 New/Delete persistence transaction을 보강했습니다.

**VERIFICATION UPDATE**
- 실제 Godot process에서 빈 Building Catalog에서도 New → Property Edit → Dirty → Reload 차단 → Save → Reload 확인 → Edit → Save → Delete → Save 흐름을 E2E 검증했습니다.
- `BUILDING_AUTHORING_E2E_PASS` 및 exit code 0 확인.
- 테스트 SQLite는 임시 백업 후 원상복구했습니다.
- `git diff --check`: PASS
- Godot 4.7.2 headless Editor initialization: PASS
- 자동 E2E는 PIE VERIFIED가 아닙니다.

**PROPOSAL**
- ROBOT/UNIT/TOWER/BUILDING의 일반 Authoring Contract를 공통 기준 구현으로 유지합니다.
- 다음 단계는 나머지 Content Editor의 동일 Contract 적용 여부를 조사하되, 각 메뉴의 Persistence 경계가 다르면 먼저 READ-ONLY로 schema/reference를 확인합니다.
- 공통 Contract의 failure-injection rollback 검증과 Master 실제 화면 검증(PIE)은 별도 검증 단계로 남깁니다.

### 30.7 STAGE Persistence Boundary ? IMPLEMENTED / VERIFIED

**CONFIRMED**
- `MISSION Editor` is the sole Mission mutation owner.
- STAGE Editor may change the Mission reference ID, but Mission definition fields are read-only and STAGE SAVE no longer mutates the `missions` Catalog.
- `STAGE Editor` remains the Reward mutation owner; no separate REWARD Editor is introduced in the current scope.
- STAGE SAVE prepares the Reward Catalog and persists the Stage document + Reward Catalog through `ObjectPersistence.save_catalog_pair_atomic()` in one SQLite transaction.
- Mission reference existence is validated before persistence.
- The approved ownership boundary is therefore: MISSION Editor ? Mission persistence; STAGE Editor ? Stage + Reward persistence/reference.

**VERIFICATION**
- `godot/editor/stage_editor.gd` parses successfully with Godot 4.7.2 `--check-only`.
- `git diff --check`: PASS.
- Existing `stage_01`~`stage_03` Mission/Reward references were inspected directly in SQLite.
- PIE / GUI Save?Reload?Runtime verification remains NOT VERIFIED.

**PROPOSAL**
- Keep the current Stage + Reward atomic boundary as the implementation contract.
- Do not create a separate REWARD Editor unless a later authoring requirement demonstrates independent Reward lifecycle needs.
- Failure-injection rollback and Master visual acceptance remain separate verification gates.

## PROGRESS — GUI Verification Method 2026-10-08

- 듀얼 모니터/대형 이미지 환경을 고려하여 GUI 검증 방법을 mss + 축소 캡처 + pyautogui 입력 방식으로 확정하였다.
- winapp CLI는 창/DPI/물리 좌표 진단용 보조 도구로 유지한다.
- pywinauto는 Godot 내부 UI Control 접근에 유효하지 않아 제거하였다.
- 최소 GUI E2E: ROBOT → UNIT → TOWER Editor 진입 및 RELOAD 동작을 실제 화면에서 확인하였다.
- GUI Editor 검증 PASS는 PIE VERIFIED와 동일하지 않으며, 실제 Runtime acceptance는 별도 Gate로 유지한다.

## PROGRESS - TOWER Animation Asset Contract 2026-10-09

**CONFIRMED**
- TOWER Runtime consumes sprite_anim for the placed-tower visual path.
- idle / attack / hit / death are not currently consumed by the Tower Runtime path.
- The previous Editor validation required idle and attack without a current Runtime contract.

**MASTER DECISION**
- sprite_anim: Required.
- idle / attack / hit / death: Optional.
- projectile_anim: Optional.
- State-specific animation becomes Required only after an explicit corresponding Tower Runtime consumption contract is established.

**Implementation**
- TOWER Editor validation updated to match this contract.
- Existing Visual Asset Resolver validation fix remains in place.
- No Tower Runtime, Catalog Asset, or semantic Asset ID migration was performed.

**Verification**
- Code Diff: PASS.
- git diff --check: PASS.
- Editor/Runtime full re-verification after this policy change: NOT VERIFIED.

**Scope**
- This resolves the current TOWER Editor Required/Optional policy only.
- Tower Semantic Visual Asset ID Canon remains a separate future decision.


## PROGRESS - Unit/Tower Visual Asset P0 E2E Gate 2026-10-09

**STATUS - PASS**

**CONFIRMED**
- UNIT: `unit.basic.default` was changed through the GUI to `robot.asura.profile`, then SAVE -> RELOAD persisted the new `default_image` value in SQLite.
- A fresh Runtime process loaded the changed Unit catalog and displayed the changed Visual Asset path in the gameplay screen.
- UNIT was restored through the GUI to `unit.basic.default`, then SAVE -> RELOAD was verified in SQLite.
- TOWER: `towers.rail.sprite_anim` was changed through the GUI to `robot.asura.profile`, then SAVE -> RELOAD persisted the new value in SQLite.
- A fresh Runtime process loaded the changed Tower catalog and displayed the changed Sprite Asset at Tower runtime positions.
- TOWER was restored through the GUI to `tower.rail.default`, then SAVE -> RELOAD was verified in SQLite.
- Runtime code path was independently confirmed: Unit consumes `default_image` first and Tower consumes `sprite_anim`, both through `VisualAssetResolver`.

**VERIFICATION**
- CODE VERIFIED: PASS
- DATA / PERSISTENCE VERIFIED: PASS
- EDITOR VERIFIED: PASS - actual GUI edit, SAVE, RELOAD and restoration performed for Unit and Tower.
- RUNTIME VISUAL DISPLAY: PASS - fresh Runtime screen observation performed for Unit and Tower.
- PIE VERIFIED: NOT VERIFIED - automated/remote Runtime observation remains distinct from Master final PIE acceptance.

**SCOPE**
- This closes the minimum representative Unit/Tower Visual Asset E2E gate.
- No expansion to every Unit/Tower Visual Asset was performed.
- No new image Asset was generated.

## 29. 2026-10-09 Roadmap State Reconciliation

STATUS: PASS - Map CRUD implementation status reconciled with the current code/state records.

CONFIRMED:
- Sections 26/27 record the earlier Map CRUD investigation state and are retained as historical development records.
- Section 28 and the current implementation supersede the earlier "CRUD not implemented" roadmap state.
- `map_editor.gd` contains New Map, Duplicate Map, and Delete Map workflows.
- `map_loader.gd` provides dynamic `map_documents` persistence for author-created maps while preserving canonical fixed-map compatibility.
- New/Duplicate/Delete CRUD smoke verification passes on a copied SQLite database.
- Existing 32px grid behavior is intrinsic; no separate Snap toggle is required for the current P0 contract.
- Current `state/CURRENT_STATE.md` already records the approved Map CRUD policy and final Map Editor regression review.

VERIFICATION:
- CODE VERIFIED: PASS.
- MAP_CRUD_SMOKE_PASS: PASS.
- EDITOR_DATA_SMOKE_TEST_PASS: PASS.
- Production `godot/content/menos.sqlite` was not modified by the Map CRUD smoke verification.
- PIE VERIFIED: NOT VERIFIED.

ROADMAP DECISION:
- Do not reopen Map CRUD or add further Map semantics automatically.
- The next Map-related action is only the already-recorded Master Commit/Push gate; implementation is otherwise ACCEPT/STOP.
- For broader development, proceed to the next explicitly approved Common Authoring Contract / P0 gate rather than repeating Map CRUD investigation.

PROPOSAL:
Treat the integrated plan as reconciled at this point. No further Map Editor implementation should begin unless Master requests a new Map requirement.


## 30.8 2026-10-09 ROBOT Team Mask Ownership Boundary

**STATUS: PASS — Master-approved A boundary implemented.**

**CONFIRMED:**
- ROBOT Editor no longer generates or persists Team Mask PNG / Visual Asset Catalog data directly.
- ROBOT GENERATE MASK now routes through the existing Image Editor entry path for the selected Profile Visual Asset.
- The existing Image Editor owns the Team Mask generation action and its Visual Asset Catalog persistence path.
- The existing ImageEditorState / request_image_editor routing is reused; no new cross-editor persistence API was introduced.
- Robot working-copy SAVE remains responsible only for Robot authoring data.

**VERIFICATION:**
- robot_editor.gd --check-only: PASS.
- image_editor.gd --check-only: PASS.
- git diff --check: PASS.
- Headless Editor route E2E: MASK_ROUTE_PASS:robot.asura.profile.
- CODE VERIFIED: PASS.
- EDITOR ROUTING VERIFIED: PASS.
- PIE VERIFIED: NOT VERIFIED.

**IMPLEMENTATION:**
- godot/editor/robot_editor.gd
  - GENERATE MASK button routes to _open_profile_team_mask_editor().
  - Removed Robot-local Team Mask generation and direct Visual Asset persistence helpers.
  - Reuses _open_image_editor_for_target("default_image") so the semantic Profile Visual Asset ID is preserved.

**PROPOSAL:**
- Keep Team Mask ownership under the Image/Catalog Editor boundary.
- Do not add Robot + Visual Asset cross-catalog transactions unless a later requirement explicitly requires them.
- Treat this scope as ACCEPT·STOP pending Master Commit/Push approval.
