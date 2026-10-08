# MENOS — MENU / GAMEPLAY / CONTENT SYSTEM INTEGRATED DEVELOPMENT PLAN

Status: PROPOSAL — 종합 재검토 결과를 기준으로 한 단계적 개발계획. Canon 변경 아님.

## 1. 목적

현재까지 정의한 Content Editor 메뉴, Gameplay Runtime/UI, Settings, VFX/SFX/BGM/Voice 기능을 하나의 제작-실행 파이프라인으로 통합하고, 중복 구현과 범위 확장을 막으면서 실제 콘텐츠 제작자가 처음 Asset을 만들고 Campaign을 플레이하는 지점까지 단계적으로 완성한다.

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
   - SFX/BGM/Voice는 아직 disabled 상태를 유지.

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
- SFX menu remains disabled because the authoring UI is not yet required for the current pilot gate.

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
