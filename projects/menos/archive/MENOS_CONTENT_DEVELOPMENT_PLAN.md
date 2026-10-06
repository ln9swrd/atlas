# MENOS Content / Gameplay Development Plan

> 작성일: 2026-09-29
> 상태: PROPOSAL — Master 승인 후 순차 실행
> 목적: 현재 구현된 전투와 콘텐츠 에디터를 기반으로, MENOS의 핵심 가치인 슈퍼로봇 전투를 완성하고 콘텐츠 제작/확장이 가능한 구조로 정리한다.

## 1. 개발 원칙

1. 목적 → 최소 요구조건 → 최소 검증 → 판정 → STOP.
2. 한 번에 하나의 작업 단위만 실행한다.
3. 기존 구현과 변경사항을 먼저 조사한다.
4. 확인하지 않은 설계는 임의로 확정하지 않는다.
5. 기존 Asset/Data/전투 규칙은 필요한 경우에만 변경한다.
6. 데이터 편집 기능과 실제 런타임 반영을 구분해 검증한다.
7. Commit / Push는 Master 승인 없이 수행하지 않는다.
8. 성공한 단계는 STOP하고 다음 단계는 Master 지시 후 진행한다.

## 2. 현재 기준선

### CONFIRMED
- Content Editor 안에 맵/적/타워/로봇 관련 편집 기능이 존재한다.
- 적과 타워는 JSON 기반 콘텐츠 편집 구조가 적용되어 있다.
- 로봇 에디터가 추가되었으며 ATLAS-01의 기본 능력치/애니메이션/탄환/특수공격 데이터를 편집할 수 있다.
- Godot 4.7.2 headless editor load가 정상 완료되었다.
- Gameplay UI 개선 STEP 1~5가 코드 수준에서 완료되어 있다.
- MENOS의 핵심 가치는 슈퍼로봇 전투 구현이다.

### UNVERIFIED
- 실제 PIE에서 각 에디터 변경값이 모두 의도대로 표시/동작하는지.
- 현재 모든 콘텐츠 필드가 실제 런타임에서 완전히 데이터 구동되는지.
- 최종 전투 밸런스와 재미.
- 최종 캠페인/성장/저장 구조.

## 3. 개발 로드맵

### Phase A — 콘텐츠 에디터 기반 완성

#### A-1. 로봇 에디터 검증 및 보완
- 목적: 현재 추가된 로봇 에디터가 실제 콘텐츠 제작 도구로 사용할 수 있게 한다.
- 범위: ATLAS-01 데이터 로딩/저장, 애니메이션 경로, 탄환 경로, 특수공격 데이터.
- 성공 조건: 에디터에서 값을 저장하면 JSON에 기록되고 런타임이 해당 데이터를 읽는다.
- 검증: CODE → EDITOR → 가능 시 PIE.
- 상태: 다음 실행 대상.

#### A-2. 적 에디터의 실제 전투 데이터 연결 완성
- 목적: 적 에디터에서 설정한 전투 속성이 실제 적 행동에 반영되도록 한다.
- 범위: 공격력, 공격 쿨다운, 사거리, 공격 타입, 탄환/공격 애니메이션 등 현재 런타임에 존재하는 항목.
- 주의: ‘근접 공격형’의 구체적 공격 규칙은 기존 구현을 조사한 뒤 별도 설계가 필요하면 HOLD한다.
- 성공 조건: 에디터 데이터와 실제 전투 동작이 일치한다.

#### A-3. 타워 에디터의 실제 전투 데이터 연결 완성
- 목적: 타워 콘텐츠 데이터가 실제 공격/투사체 동작을 제어하도록 한다.
- 범위: 공격력, 공격속도, 사거리, 무기 타입, 탄환 애니메이션 등 실제 존재하는 필드.
- 성공 조건: 에디터 저장 → JSON → 런타임 반영.

#### A-4. 공통 콘텐츠 데이터 검증
- 목적: 잘못된 Asset 경로, 누락 필드, 잘못된 수치로 게임이 깨지는 것을 조기에 발견한다.
- 범위: JSON schema/필수 필드/Asset 존재 여부/수치 범위.
- 결과: Content Validator 도구 또는 Content Editor 검증 기능.

### Phase B — 전투 시스템 완성

#### B-1. 적 공격 시스템 정리
- 기본 원거리 공격
- 근접 공격
- 공격 사거리
- 공격 쿨다운
- 공격 애니메이션/피격 피드백
- 목표 판정
- 성공 조건: 서로 다른 공격 타입이 실제 전투에서 안정적으로 동작.

#### B-2. 슈퍼로봇 공격 표현 및 특수공격 데이터화
- 기본 공격
- 범위 공격
- 관통 공격
- 투사체
- 특수공격 VFX 연결
- 목적: 슈퍼로봇 전투의 개성을 데이터로 확장 가능하게 한다.
- 기존 특수공격 규칙을 임의 변경하지 않는다.

#### B-3. 전투 결과/웨이브 흐름 안정화
- 자동 웨이브 시작
- 승리/패배 판정
- 결과 표시
- 재시작/다음 전투 진입
- 성공 조건: 전투 시작부터 종료까지 명확한 루프 완성.

#### B-4. 전투 밸런스는 별도 단계
- 수치 조정은 시스템 구현과 분리한다.
- 실제 PIE 플레이 후 Master가 결정한다.

### Phase C — 맵/스테이지 제작 구조

#### C-1. 맵 에디터 완성
- 지형
- 맵 크기
- 타워 설치 가능 영역
- 로봇 출격 위치
- 적 스폰 위치
- 목표/베이스
- 오브젝트 추가/이동/삭제
- 저장/불러오기

#### C-2. 스테이지 데이터
- 맵
- 웨이브
- 적 구성
- 스폰
- 승패 조건
- 보상
- 맵과 미션의 책임을 분리한다.

#### C-3. 맵/스테이지 로더 검증
- 서로 다른 크기의 맵
- 경계 기반 카메라
- 스폰/AI
- 미니맵
- 성공 조건: 맵 크기와 데이터에 의존하지 않는 하드코딩 제거.

### Phase D — 게임 진행

#### D-1. 맵 선택 / 전투 진입 / 결과 흐름
#### D-2. 캠페인 미션 구조
#### D-3. 승리/패배 후 진행
#### D-4. 자유 전투/재도전

### Phase E — 성장과 저장

#### E-1. 로봇 프로필
#### E-2. 경험치/레벨
#### E-3. 장비/인벤토리
#### E-4. 수리/강화
#### E-5. 영구 저장/불러오기
#### E-6. 보상/경제

구체적인 수치와 성장 곡선은 실제 플레이 테스트 후 확정한다.

### Phase F — 표현 완성

- 공격/피격 VFX
- 사운드
- HUD
- Minimap
- Victory/Defeat 연출
- 최종 로봇/적/환경 Asset
- 성능 및 사용성 검증

현재 Gameplay UI 개선 계획의 STEP 6~10과 연결하되, 별도 목적의 작업을 임의로 합치지 않는다.

### Phase G — 리플레이 및 개발 도구

- 전투 이벤트 기록
- 리플레이
- 전투 분석
- 디버그/검증 도구
- 콘텐츠 검증 도구 확장

## 4. 실행 순서

Master가 순차 진행을 요청할 경우 기본 순서는 다음과 같다.

1. A-1 로봇 에디터 검증 및 보완
2. A-2 적 에디터 실제 전투 데이터 연결
3. A-3 타워 에디터 실제 전투 데이터 연결
4. A-4 콘텐츠 검증
5. B-1 적 공격 시스템
6. B-2 로봇 특수공격 데이터화
7. B-3 전투 결과/웨이브 흐름 안정화
8. C-1 맵 에디터 완성
9. C-2 스테이지 데이터
10. C-3 맵/스테이지 로더 검증
11. D 단계 게임 진행
12. E 단계 성장/저장
13. F 단계 표현 완성
14. G 단계 리플레이/개발 도구

단, 한 단계에서 설계 충돌이나 미확정 사항이 발견되면 다음 단계로 넘어가지 않는다.

## 5. 단계별 완료 기준

각 단계는 다음을 모두 확인해야 완료로 판정한다.

- 목적 달성
- 관련 데이터 경로 확인
- 코드 오류 없음
- 필요한 경우 Editor 확인
- 가능한 경우 PIE 확인
- Diff 확인
- 기존 기능에 대한 의도하지 않은 변경 없음

자동화/Headless 성공은 PIE VERIFIED를 의미하지 않는다.

## 6. 우선순위

P0:
- 콘텐츠 데이터와 런타임 연결
- 적/로봇/타워 공격 시스템
- 전투 시작/종료

P1:
- 맵/스테이지 제작 구조
- 맵 선택/자유 전투
- 저장 및 진행

P2:
- 캠페인
- 성장/장비/경제
- 고급 VFX/UI

P3:
- 리플레이
- 분석/개발 도구
- 최종 아트/출시 준비

## 7. 변경 금지 / HOLD 조건

다음은 별도 판단 없이는 자동 변경하지 않는다.

- 전투 밸런스
- Canon/스토리
- 새로운 외부 Asset
- 기존 Asset 삭제/대체
- 대규모 main.gd 리팩터링
- 새로운 공격 규칙의 임의 결정
- 성장/경제 수치의 임의 확정

다음 상황이면 HOLD:
- 기존 데이터와 충돌
- 실제 공격 규칙이 정의되지 않음
- 필요한 Asset이 없음
- 의도하지 않은 Diff
- PIE 결과가 예상과 다름
- 범위 확장
- 새로운 설계 결정 필요

## 8. 현실성

- TECHNICALLY POSSIBLE
- PRACTICALLY FEASIBLE: 현재 Godot 기반 구조와 기존 에디터를 재사용하는 조건에서 단계적 구현 가능.
- BUSINESS VIABLE: 비용/시장/출시 범위 자료가 없어 본 문서에서는 판단하지 않음.

## 9. 상태

현재 문서는 **PROPOSAL**이다.
Master 승인 전에는 Canon이 아니다.

현재 실행 대상은 **A-1 로봇 에디터 검증 및 보완**이다.
계획 작성 자체로 A-1 구현을 자동 시작하지 않는다.

## Handoff — A-1 Robot Editor Verification (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED
**Purpose** — Verify the current Robot Editor, ATLAS-01 JSON data, and runtime loading path.
**Baseline** — Branch main; HEAD `6bdc0c4c`; working tree clean at verification.

**CONFIRMED**
- robot_editor.gd loads and saves res://content/robots/robots.json.
- ATLAS-01 base stats, animation paths, projectile animation, AREA and PIERCE data are represented in the editor and JSON.
- main.gd _load_robot_catalog() reads robot_main from the same JSON and builds runtime robot catalogs.
- Godot 4.7.2 headless editor initialization completed.
- git diff --check passed.
- Existing duplicate image UID warnings remain; they were not modified because they are outside A-1 scope.

**Sera technical judgment**
- The required editor/data/runtime foundation for A-1 exists.
- Multi-robot authoring and new robot combat rules would exceed the minimum A-1 scope.
- No code change is required for A-1.

**Mari verdict**
- A-1 code/data linkage objective is satisfied.
- Interactive editor input/save and PIE behavior remain unverified.

**Changes** — None for A-1.
**Verification** — CODE VERIFIED PASS; BUILD VERIFIED UNVERIFIED; EDITOR VERIFIED UNVERIFIED; PIE VERIFIED UNVERIFIED.
**UNVERIFIED** — Interactive Content Editor save flow and actual PIE reflection of edited values.
**OUT OF SCOPE** — Multi-robot support, new combat rules, progression, asset replacement, balance changes.
**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.
**Decision** — ACCEPT·STOP. Next planned step: A-2 Enemy Editor actual combat-data linkage.

## Handoff — A-2 Enemy Editor Combat Data Linkage (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Connect Enemy Editor combat data to runtime behavior, including the newly approved melee rule.

**Baseline** — Branch main; HEAD `6bdc0c4c` before implementation; working tree contained only the development-plan document.

**CONFIRMED**
- HP, speed, armor, base_damage, reward are already consumed from `enemy_catalog`.
- Giant robot_damage, robot_range, robot_cooldown are already consumed by the Giant-vs-ATLAS attack path.
- Enemy sprite/projectile animation paths are already loaded from enemy JSON.
- Enemy Editor now exposes and saves `melee_cooldown`.
- Runtime now recognizes `melee: true` and uses `radius` as melee attack range.
- A melee enemy targets ATLAS-01, stops moving while ATLAS-01 is within melee range, deals `base_damage`, and repeats using `melee_cooldown`.
- Existing non-melee enemies retain the previous movement/base-breach behavior.

**APPROVED MELEE RULE**
- Target: ATLAS-01.
- Range: enemy `radius`.
- Damage: enemy `base_damage`.
- Cadence: enemy `melee_cooldown`, default 1.0 seconds.
- Movement: stop while in melee range; resume movement when outside range.
- No new melee-specific attack animation/effect rule was introduced.

**Sera technical judgment**
- The approved rule was implemented with a single runtime branch and a dedicated cooldown timer per spawned enemy.
- Existing enemy movement, Giant ranged attack, damage, reward, and base-breach paths remain intact outside the melee condition.

**Mari verdict**
- A-2 objective is satisfied at code/data level.
- Interactive editor operation and PIE behavior remain unverified.

**Changes**
- `godot/editor/enemy_editor.gd`: added melee cooldown editing/loading/saving.
- `godot/main.gd`: added melee attack timer and ATLAS-01 melee attack/movement-stop behavior.

**Verification**
- CODE VERIFIED: PASS — Godot 4.7.2 headless editor initialization completed without reported script errors.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Actual in-editor save interaction, visual attack feedback, and PIE combat behavior.

**OUT OF SCOPE** — Balance tuning, dedicated melee animation/VFX, new targets, tower melee targeting, changes to existing ranged/Giant rules.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP after code validation. Next planned step: A-3.

## Handoff — A-3 Tower Editor Combat Data Linkage (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Verify that Tower Editor data is connected to runtime tower construction, targeting, attack, upgrade, and projectile/sprite presentation.

**Baseline** — Branch main; HEAD `6bdc0c4c`; pre-existing working-tree changes are the A-2 implementation and this plan document.

**CONFIRMED**
- `godot/editor/tower_editor.gd` loads/saves `res://content/towers/towers.json`.
- Runtime `_load_tower_catalog()` reads the same JSON and overlays matching tower types onto `DATA.TOWERS`.
- Construction reads `tower_catalog[type]` for cost and creates the runtime tower with that data.
- Target selection reads the runtime tower's `range` and `preference`.
- Attack reads the runtime tower's `damage` and `cooldown`.
- LV2 upgrade reads `level2.upgrade_cost`, `damage`, `cooldown`, and `range` and writes the upgraded values back to the runtime tower.
- Tower sprite and projectile animation paths are supported by the catalog loader with fallback to existing visual assets.
- The current `towers.json` does not contain `projectile_anim` entries, so current tower projectiles use the existing fallback until an editor save supplies an explicit path; this is already supported by the runtime path and requires no new combat rule.

**Sera technical judgment**
- Tower Editor combat fields already have runtime consumers; no missing combat rule was identified.
- No code change is required for A-3.

**Mari verdict**
- A-3 objective is satisfied at code/data linkage level.
- Interactive editor save behavior and PIE combat reflection remain unverified.

**Changes** — No code changes for A-3.
**Verification** — CODE VERIFIED PASS; BUILD VERIFIED UNVERIFIED; EDITOR VERIFIED UNVERIFIED; PIE VERIFIED UNVERIFIED.
**UNVERIFIED** — Interactive editor operation, saved JSON visual override behavior, and PIE tower combat/upgrade behavior.
**OUT OF SCOPE** — New tower types, new attack rules, balance tuning, asset replacement, tower placement redesign.
**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.
**Decision** — ACCEPT·STOP. Next planned step: A-4 common content data validation.


## Handoff — A-4 Common Content Data Validation (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Establish a repeatable validation check for Enemy/Tower/Robot content JSON and referenced resources.

**Baseline** — Branch main; HEAD `6bdc0c4c`; pre-existing working-tree changes were the A-2 implementation and this plan document.

**CONFIRMED**
- `enemies.json`, `towers.json`, and `robots.json` are valid JSON objects and contain the expected current catalogs.
- Current catalog IDs are unique within each catalog.
- Current numeric content values contain no negative values.
- All current `res://` resource references in the three catalogs resolve to existing project resources.
- A reusable validator was added at `godot/editor/content_validator.gd` to check required fields, negative numeric values, and `res://` resource references.
- Godot 4.7.2 headless editor initialization completes without reported script errors, and `git diff --check` passes.

**Sera technical judgment**
- The current content set passes the implemented structural/resource checks.
- Optional fields such as enemy `melee`/`melee_cooldown` and tower `projectile_anim` are not required in the existing JSON because the runtime/editor already provide defaults/fallbacks.
- The validator is intended as a structural guard, not as a gameplay balance validator or PIE test.

**Mari verdict**
- A-4 objective is satisfied at the structural validation level.
- Interactive editor save/load and PIE reflection remain unverified.

**Changes**
- Added `godot/editor/content_validator.gd`.
- No content values or existing assets were changed.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS — validator source is present and Godot project headless editor initialization completes without reported script errors.
- DATA VALIDATION: PASS — current three catalogs pass JSON, required-field, non-negative numeric, and resource-reference checks.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Direct interactive execution of the validator script and in-editor/PIE behavior. The `--script` invocation exited cleanly but produced no validator console output, so its standalone execution path is not treated as verified.

**OUT OF SCOPE** — Balance validation, schema migration, content authoring, new content types, asset replacement, combat-rule changes, PIE testing.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP. Next planned step: B-1 enemy attack system.


## Handoff — B-1 Enemy Attack System (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Apply the Master-approved general enemy attack rule and establish data-driven attack type/range/cooldown handling without changing combat balance beyond the minimum content values needed to exercise the system.

**Approved rule**
- General enemies may attack ATLAS-01.
- An attacking enemy stops moving while ATLAS-01 is within attack range.
- Target is ATLAS-01.
- Attack type is data-driven: none, melee, ranged.
- Attack range and attack cooldown are explicit data fields.
- Attack damage uses the existing base_damage.
- Existing Giant special ranged attack remains unchanged.

**CONFIRMED**
- Enemy Editor now exposes attack type, attack range, and attack cooldown.
- Enemy JSON now defines NORMAL/RUSHER/HEAVY as melee attackers and GIANT as ranged while preserving the existing Giant robot-specific damage/range/cooldown fields.
- Runtime spawns a per-enemy attack timer and consumes attack_type, attack_range, and attack_cooldown.
- Melee attackers stop and repeatedly damage ATLAS-01 while in range.
- Generic ranged attack presentation uses the existing threat projectile effect; no new asset was added.
- GIANT continues to use its existing robot_damage/robot_range/robot_cooldown path and is excluded from the new generic branch.
- JSON parsing succeeded for all four enemy entries.
- git diff --check passed.
- Godot 4.7.2 headless editor initialization completed without reported script errors in the latest verification run.

**Sera technical judgment**
- The new attack fields provide the requested separation between attack type, range, and cooldown while retaining backward compatibility with the previously added melee fields.
- Existing base-breach behavior remains the fallback when an enemy is not actively attacking ATLAS-01.
- No new attack balance system, target system, or external asset dependency was introduced.

**Mari verdict**
- B-1 code/data objective is satisfied for the approved attack model.
- Interactive Editor operation, actual combat behavior, attack animation quality, and PIE behavior remain unverified.

**Changes**
- godot/editor/enemy_editor.gd: added attack type/range/cooldown fields and JSON persistence.
- godot/content/enemies/enemies.json: assigned current attack types/ranges/cooldowns for the four existing enemy types.
- godot/main.gd: unified generic enemy attack handling with per-enemy cooldown timer while preserving Giant special attack behavior.
- No new assets created; no commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- DATA VALIDATION: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — In-editor field editing/save, actual runtime attack timing/positioning, visual attack animation quality, and PIE result.

**OUT OF SCOPE** — Balance tuning, new enemy types, new attack rules, new assets, melee VFX/animation design, robot targeting changes, base-defense rule changes.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.


## Handoff — B-2 Super Robot Attack / Special Attack Dataization (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Connect ATLAS-01 basic attack and existing special attacks to the Robot Editor JSON catalog, preserving existing attack behavior and values.

**CONFIRMED**
- `robots.json` contains ATLAS-01 basic combat fields, four sprite references, projectile reference, AREA data, and PIERCE data.
- Robot Editor already loads and saves those fields.
- Runtime already loads `robots.json` into `robot_catalog` and builds robot sprite/projectile catalogs.
- Runtime basic attack, target range, movement speed, HP, command count, AREA damage/radius/cooldown/threshold, and PIERCE damage/cooldown now consume `robot_catalog` instead of the static `DATA.ROBOT` values.
- Existing special ability unlock/selection flow was preserved.
- Existing attack projectile and special effect presentation paths were preserved; no new asset was created.
- Godot 4.7.2 headless editor initialization completed without reported script errors.
- `git diff --check` passed.

**Sera technical judgment**
- B-2 was primarily a linkage gap: the Robot Editor/JSON existed, but several runtime combat paths still read the static default catalog.
- The minimum fix was to route those runtime reads through the already-loaded `robot_catalog`; no new combat rule or balance system was introduced.
- Static `DATA.ROBOT` remains the fallback used to initialize the catalog before JSON loading.

**Mari verdict**
- Objective is satisfied at code/data linkage level.
- Actual Robot Editor interaction and PIE combat behavior remain unverified.

**Changes**
- `godot/main.gd`: ATLAS runtime combat/movement/HP/UI references now use `robot_catalog` after JSON load.
- No changes to `robots.json` values.
- No new assets.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Interactive editor save/reload and actual runtime reflection of edited values.

**OUT OF SCOPE** — New special attacks, new attack rules, balance tuning, progression redesign, asset replacement, campaign changes.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.

## Handoff — B-3 Battle Result / Wave Flow Stabilization (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Stabilize battle start/end flow and ensure the previously approved automatic wave start is reflected in the UI, while providing visible/audio battle results using existing assets/sounds.

**CONFIRMED**
- Wave 1 uses the existing automatic start timer; the manual “웨이브 시작” UI button was removed.
- Cleared non-final waves transition to READY and immediately start the next wave through the existing flow.
- Final campaign completion transitions to VICTORY when no next_stage_id remains.
- Base HP reaching zero transitions to DEFEAT and stops the running wave.
- Existing result status assets status_victory.png / status_defeat.png were already present and are now displayed in a screen-centered result overlay.
- Existing ui_confirm / ui_cancel sounds are used for victory/defeat result feedback; no new audio asset was created.
- Godot 4.7.2 headless editor initialization completed without reported script errors.
- git diff --check passed.

**Sera technical judgment**
- The minimum required B-3 change was sufficient: remove the obsolete manual wave-start control, preserve automatic wave flow, and add result presentation/audio without changing combat rules.
- Existing campaign transition behavior was preserved; result overlay is only active in VICTORY/DEFEAT states.

**Mari verdict**
- Objective is satisfied at code level.
- Actual screen presentation, audio playback, and complete campaign transition remain PIE-unverified.

**Changes**
- godot/main.gd: removed the manual wave-start button; added victory/defeat SFX and centered result overlay using existing assets.
- No combat balance changes, new assets, or new wave rules.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Actual visual/audio result behavior in PIE.

**OUT OF SCOPE** — Balance tuning, new result assets/audio, campaign redesign, restart UX redesign.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.
## Handoff — C-1 Map Editor Completion (2026-09-29)

**STATUS** — PASS / EDITOR INTERACTION UNVERIFIED / PIE UNVERIFIED

**Purpose** — Verify whether the current Map Editor supports the required gameplay-element authoring operations without unnecessary redesign.

**CONFIRMED**
- Gameplay mode provides tools for Spawn Area, Tower Placement Area/Point, Robot Position Point, Goal Area, Obstacle Area, Movement Area, and Blocked Area.
- Gameplay Area elements can be created by drag, selected, moved by drag, resized, edited through Inspector, and deleted.
- Gameplay Point elements can be created by click, selected, moved by drag, and edited through Inspector.
- Existing legacy Goal/Spawn/Tower Slot/Robot Spot elements can be selected and repositioned; Base/Goal deletion is blocked because runtime requires it.
- Delete/Backspace removes eligible selected editor objects.
- Ctrl+Z undo support exists.
- Map data changes are signaled for save.
- northbridge_sector_01.json contains gameplay areas/points.
- Godot 4.7.2 headless editor initialization completed without reported script errors.
- git diff --check passed.
- No C-1 code change was required.

**Sera technical judgment**
- The previously identified map-editor gaps are already addressed in the current implementation. Additional changes would be redundant without an interactive editor test demonstrating a specific failure.

**Mari verdict**
- C-1 objective is satisfied at code/data structure level.
- Interactive Editor verification and actual map editing/save/reload remain unverified.
- No justification exists for broad modification at this stage.

**Changes**
- No C-1 code/data changes.
- No asset changes.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Actual mouse interaction, save/reload round-trip, and runtime reflection of edited map data.

**OUT OF SCOPE** — New map authoring rules, terrain redesign, placement UX redesign, campaign changes, asset replacement.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.


## Handoff — C-2 Stage Data (2026-09-29)

**STATUS** — PASS / EDITOR INTERACTION UNVERIFIED / PIE UNVERIFIED

**Purpose** — Verify Stage Editor, stage JSON, StageLoader, StageManager, and runtime consumption are connected without changing stage design or balance.

**CONFIRMED**
- Stage Editor enumerates `res://content/stages/*.json`, loads through `StageLoader.load_stage_data()`, and can save stage JSON.
- Stage Editor exposes stage ID, order, name, Map, initial gold, base HP, next stage ID, wave labels, enemy groups, counts, intervals, and lanes.
- StageLoader validates required stage fields, referenced `map_file`, balance fields, and waves, then exposes normalized `initial_gold`, `base_hp`, and `waves`.
- StageManager loads the selected stage and provides map file, initial gold, base HP, and waves to runtime.
- `main.gd` consumes StageManager for map loading, reset values, wave data, and `next_stage_id` campaign progression.
- `stage_01.json`, `stage_02.json`, and `stage_03.json` parse successfully.
- All three stage map references resolve to existing `map_01.json`, `map_02.json`, and `map_03.json`.
- Current stages contain four waves each; progression is stage_01 → stage_02 → stage_03 → terminal stage.
- Godot 4.7.2 headless editor initialization completed without reported script errors.
- `git diff --check` passed.

**Sera technical judgment**
- Stage data linkage is already implemented end-to-end. No code or stage-data modification is required for C-2.
- The Editor writes the canonical `balance` object while preserving runtime-compatible normalized fields through `StageLoader`.

**Mari verdict**
- C-2 objective is satisfied at code/data level.
- Actual Editor save/reload interaction and PIE runtime reflection remain unverified.
- Additional changes would expand scope without a demonstrated failure.

**Changes**
- No C-2 code/data changes.
- No asset changes.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Interactive Stage Editor save/reload and actual in-game campaign progression.

**OUT OF SCOPE** — Stage balance tuning, wave redesign, campaign rule changes, new stage creation, asset replacement.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.


## Handoff — C-3 Map/Stage Loader Verification (2026-09-29)

**STATUS** — PASS / RUNTIME EXECUTION UNVERIFIED / PIE UNVERIFIED

**Purpose** — Verify MapLoader and StageLoader/StageManager data flow against the current Stage-referenced Map files without changing map or stage content.

**CONFIRMED**
- `StageManager.get_map_file()` passes the stage-selected `map_file` directly to `MapLoader.load_map_data()` in `main.gd`.
- `MapLoader` parses map identity, size/origin/pixel size, goal/base, legacy spawn/robot/tower fields, tiles, objects, asset footprint defaults, gameplay areas, and gameplay points.
- `main.gd` consumes `gameplay_areas` for spawn and tower-placement areas and `gameplay_points` for gameplay points, with explicit legacy-field fallback handling.
- `map_01.json` is a 60×40 map and contains gameplay spawn/tower areas plus a robot position point; this matches the current C-1 gameplay-data direction.
- `map_02.json` and `map_03.json` are 36×24 maps and contain legacy spawn, robot-spot, tower-slot data plus gameplay area/point data.
- Stage 01/02/03 references resolve to existing Map JSON files.
- Existing `editor_data_smoke_test.gd` provides MapLoader round-trip and Editor interaction coverage, but its current headless invocation completed without emitting its expected PASS marker; therefore it is not counted as execution verification.
- `git diff --check` passed.
- No C-3 code/data/asset changes were made.

**Sera technical judgment**
- The Loader contracts and runtime consumers are structurally aligned with the current Map/Stage data.
- No defect requiring modification was directly confirmed.

**Mari verdict**
- C-3 is accepted at code/data-contract level.
- Actual standalone Loader execution and PIE reflection remain UNVERIFIED because the existing smoke-test invocation produced no PASS marker.
- No code change is justified solely from the inconclusive test invocation.

**Changes**
- No C-3 code/data changes.
- No asset changes.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Successful runtime execution of the Loader smoke test and visual/runtime reflection of each stage map.

**OUT OF SCOPE** — Map redesign, pathfinding changes, tile conversion, stage balance, campaign redesign, asset replacement.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.


## Handoff — D-1 Stage Selection → Combat Entry → Result Flow (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Verify the existing flow from stage selection to combat entry and battle result handling without redesigning campaign rules.

**CONFIRMED**
- Project main scene is `res://ui/title_screen.tscn`, so stage selection is an actual game entry point rather than an editor-only feature.
- `title_screen.gd` exposes STAGE 1/2/3 through `OptionButton` and starts Single Play with the selected `stage_%02d` ID.
- Campaign start explicitly initializes `StageManager` with `campaign / stage_01`.
- `StageManager.begin_run()` stores run mode and selected stage; `main.gd` consumes those values during `_ready()`.
- Single Play loads the selected stage; Campaign loads Stage 1 and resets the campaign session.
- `main.gd` loads the selected stage through `StageManager.load_stage()` → `MapLoader.load_map_data()` and applies the map before `reset_game()`.
- Wave progression is automatic; clearing the final wave of a non-terminal stage loads `next_stage_id`, resets the battle state, and starts the next stage.
- The terminal stage transitions to `RunState.VICTORY`; base destruction transitions to `RunState.DEFEAT`.
- Victory/defeat already display dedicated status imagery and result text, and play existing confirmation/cancel SFX.
- No new map, stage, asset, campaign rule, or combat-balance changes were made.
- `git diff --check` remains the minimum static integrity check; actual PIE remains unavailable/unverified.

**Sera technical judgment**
- The requested D-1 data/scene linkage already exists end-to-end. No implementation change is justified within the current scope.
- Result-state presentation and audio are already connected to the existing `VICTORY` / `DEFEAT` states.

**Mari verdict**
- D-1 is accepted at code/data linkage level.
- Interactive title-screen selection, actual scene transition, multi-stage progression, and final result presentation remain PIE UNVERIFIED.
- Existing result overlay text says `RESTART TO PLAY AGAIN`, but no separate result-screen transition was introduced; this is not treated as a defect because result-screen navigation was outside the approved D-1 minimum and no runtime failure was directly confirmed.

**Changes**
- No D-1 code/data/asset changes.
- Added this handoff record only.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Actual interactive stage selection, scene transition, full multi-stage runtime progression, and result overlay/audio during PIE.

**OUT OF SCOPE** — Campaign redesign, new progression rules, result-screen navigation redesign, balance changes, growth/economy systems.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.


## Handoff — D-2 Campaign Data Authority (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Make res://content/campaign/main_campaign.json the authoritative stage sequence for Campaign mode.

**CONFIRMED**
- main_campaign.json defines the campaign stage sequence as stage_01 → stage_02 → stage_03.
- Before D-2, runtime campaign progression instead read each stage's next_stage_id, duplicating the sequence definition.
- StageManager now loads main_campaign.json when a run begins and stores the ordered stage IDs.
- StageManager.get_next_campaign_stage_id() resolves the next stage from the campaign sequence by current stage ID.
- main.gd now uses the campaign sequence for Campaign mode.
- Single Play retains the existing stage-local next_stage_id behavior.
- Stage JSON wave/map/combat data was not changed.
- No assets, balance values, or campaign content were changed.
- git diff --check passed.
- Godot 4.7.2 headless editor initialization passed.

**Sera technical judgment**
- The minimum implementation is complete: campaign ordering is now data-driven from the existing campaign definition file while Single Play behavior remains unchanged.
- No new campaign loader resource or duplicated stage-order data was introduced.

**Mari verdict**
- D-2 objective is satisfied at code/data-contract level.
- main_campaign.json is now the runtime authority for Campaign stage ordering.
- PIE verification of actual multi-stage progression remains unavailable/unverified.

**Changes**
- Modified godot/scripts/stage_manager.gd to load and resolve campaign stage order.
- Modified godot/main.gd to use the campaign sequence during Campaign mode.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Actual in-game Campaign completion and transition across all three stages during PIE.

**OUT OF SCOPE** — Campaign content redesign, stage balance, growth/economy, save/progression persistence, result-screen redesign.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.


## Handoff — Boss Robot Editor Linkage (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Allow the current GIANT boss content to be maintained from Robot Editor without replacing its Enemy-specific data.

**CONFIRMED**
- Current GIANT is the existing final-wave boss-like enemy; no separate boss data structure existed.
- Robot Editor now exposes the existing `boss_giant` entry alongside ATLAS-01.
- `boss_giant` is marked with `role: boss` and retains GIANT's current HP, speed, damage, cooldown, range, and visual references.
- `enemies.json` links GIANT to `boss_giant` through `robot_editor_id`.
- Runtime loads boss-linked values from `robots.json`; Enemy data continues to own armor, reward, attack type, radius, and other enemy-specific fields.
- Boss ID is locked in Robot Editor to preserve the runtime linkage.
- Existing GIANT combat behavior was not otherwise redesigned.
- Robot and enemy JSON parse successfully; the boss sprite reference exists.
- Godot 4.7.2 headless editor initialization passed and `git diff --check` passed.

**Sera technical judgment**
- The minimum data linkage is implemented without duplicating boss combat rules or creating a second boss runtime system.

**Mari verdict**
- The requested current-boss Robot Editor management path is satisfied at code/data level.
- Actual Robot Editor interaction and in-game reflection remain PIE/interactive-editor UNVERIFIED.

**Changes**
- Modified `godot/editor/robot_editor.gd`.
- Added `boss_giant` to `godot/content/robots/robots.json`.
- Added the GIANT → Robot Editor linkage in `godot/content/enemies/enemies.json`.
- Modified `godot/main.gd` to consume boss-linked robot data.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Actual editor save/reload and PIE confirmation that changed boss values appear in combat.

**OUT OF SCOPE** — New boss types, new boss attack patterns, boss phase systems, balance changes, new assets.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.


## Handoff — D-3 Victory/Defeat Flow Stabilization (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Ensure Victory/Defeat result state has a functional restart path within the existing battle scene.

**CONFIRMED**
- Victory and Defeat states already existed and blocked further wave processing.
- Existing result overlay and restart_campaign() function were present.
- A concrete linkage defect was found: the restart UI action was drawn but handle_click() did not dispatch that action to restart_campaign().
- handle_click() now invokes restart_campaign() when the existing restart action is clicked during VICTORY or DEFEAT.
- Restart returns the session to stage_01, reloads its map, resets battle state, and does not introduce a new progression rule.
- Godot 4.7.2 headless editor initialization passed.
- git diff --check passed.

**Sera technical judgment**
- D-3 minimum functional gap found and corrected without redesigning the result system.

**Mari verdict**
- D-3 objective is satisfied at code level: result states now have an existing, reachable restart path.
- Actual click behavior, result audio, and full multi-stage runtime progression remain PIE UNVERIFIED.

**Changes**
- Modified godot/main.gd only for the restart action dispatch.
- No new assets or balance changes.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Actual interactive restart click and end-to-end Victory/Defeat runtime behavior.

**OUT OF SCOPE** — Result-screen redesign, campaign redesign, balance, growth/economy.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.


## Handoff — D-4 Free Battle / Retry (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Make Single Play operate as a standalone selected-stage battle and allow retry of that selected stage.

**CONFIRMED**
- Title Screen already exposes Single Play with Stage 1–3 selection.
- Single Play starts StageManager with run_mode="single" and the selected stage ID.
- Before this change, final-wave handling for non-campaign mode still fell back to the stage's next_stage_id, causing Single Play to continue into another stage.
- The non-campaign branch now explicitly ends progression after the selected stage by clearing next_stage_id.
- Existing campaign progression remains driven by the authoritative campaign sequence.
- Existing result restart action now uses restart_run(); campaign restart returns to Stage 1, while Single Play restarts the selected stage.
- No new assets, balance rules, or content data were added.
- Godot 4.7.2 headless editor initialization passed.
- git diff --check passed.

**Sera technical judgment**
- D-4 minimum separation between campaign progression and selected-stage free battle is implemented.

**Mari verdict**
- Objective satisfied at code level: Single Play is now a standalone selected-stage run and retry preserves its selected stage.
- Actual title-screen selection, final-wave stop, and retry behavior remain PIE UNVERIFIED.

**Changes**
- Modified godot/main.gd only.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Interactive Single Play selection and end-to-end runtime retry.

**OUT OF SCOPE** — New game modes, progression rewards, balance, save system.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.

---

# Handoff — E-1 Robot XP / Level / Campaign Persistence

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Implement the approved minimum ATLAS-01 growth foundation: enemy-kill XP, immediate combat level-up, level-based stat growth, and permanent campaign persistence.

**CONFIRMED**
- XP is awarded on enemy defeat using the existing enemy reward value; no new enemy XP balance table was introduced.
- XP threshold is 100 × current level.
- Level-up occurs immediately when the threshold is reached, including during a running wave.
- Level-up increases HP by 5%, damage by 5%, range by 2%, and speed by 2% per level above Lv.1.
- Runtime targeting, movement, attack damage, and HP display consume the level-adjusted runtime stats.
- Campaign progression is saved to user://menos_campaign_robot_profile.json and restored on campaign entry.
- Single Play does not write or restore the campaign growth profile.
- Existing AREA / PIERCE progression scaffolding is preserved; this step does not redesign its selection rules.
- Godot 4.7.2 headless editor initialization completed without reported parse errors.
- git diff --check passed.

**Sera technical judgment**
- E-1 minimum XP/level/persistence implementation is complete without adding new assets or changing enemy/tower balance data.

**Mari verdict**
- Objective is satisfied at code level. Immediate level-up and persistent campaign progression are now connected to actual enemy defeat events.
- AREA / PIERCE remain existing growth-choice infrastructure and are not expanded in this step.

**Changes**
- Modified godot/main.gd only for E-1.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Actual in-game XP accumulation, level-up timing, save/reload persistence, and visual stat changes require PIE verification.

**OUT OF SCOPE** — XP balance tuning, additional growth choices, equipment/inventory, repair/enhance, rewards/economy.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.


## Handoff — E-2 Diablo-style Equipment / Inventory Foundation (2026-09-29)

**STATUS** — PASS / PIE UNVERIFIED

**Purpose** — Add the minimum Diablo II-inspired equipment/inventory foundation: persistent items, equipment slots, grid inventory, and randomized affixes, without copying game-specific content.

**CONFIRMED**
- Added `godot/content/items/items.json` with Weapon, Armor, and Core item bases.
- Items have inventory footprint metadata, base stats, prefix/suffix pools, and randomized affix values when generated.
- Campaign robot profile now persists inventory and equipped item IDs together with XP/level data.
- First campaign profile with no inventory receives one generated item for each supported equipment slot and equips them.
- ATLAS runtime HP, damage, range, and speed now consume equipped item modifiers in addition to E-1 level growth.
- Inventory is displayed as a 6×4 grid and opened/closed with `I`.
- Clicking an inventory item equips it into its matching slot.
- Equipment panel displays the current Weapon / Armor / Core items.
- No enemy/tower balance values, new combat rules, or external assets were added.
- Godot 4.7.2 headless editor initialization completed without reported parse errors.
- `git diff --check` passed.
- Godot-generated `.godot` metadata changes were restored; no unintended editor metadata remains in the working tree.

**Sera technical judgment**
- E-2 minimum equipment/inventory foundation is implemented and connected to ATLAS runtime stats.
- The implementation is intentionally smaller than a full Diablo-like loot system; item acquisition/drop/reward rules remain separate.

**Mari verdict**
- Objective satisfied at code/data level for the equipment/inventory foundation.
- The Diablo-inspired direction is represented by grid inventory, slot-based equipment, and random affixes while avoiding direct game-content copying.

**Changes**
- Modified `godot/main.gd`.
- Added `godot/content/items/items.json`.
- No commit/push performed.

**Verification**
- CODE VERIFIED: PASS.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: UNVERIFIED.
- PIE VERIFIED: UNVERIFIED.

**UNVERIFIED** — Actual inventory interaction, equip replacement behavior, save/reload persistence, and in-game stat changes require PIE verification.

**OUT OF SCOPE** — Monster loot tables/drop rates, item rarity tiers, item selling, repair costs, enhancement/crafting, item comparison tooltips, drag-and-drop placement, and economy balance.

**Reality** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

**Decision** — ACCEPT·STOP.
