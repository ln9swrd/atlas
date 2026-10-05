# MENOS 객체 중심 개발계획

> 작성일: 2026-09-30
> 상태: PROPOSAL — Master 승인 전 기준 계획
> 목적: MENOS의 개발 단위를 시스템 기능이 아니라 게임 객체와 객체 간 조합을 중심으로 재정렬한다.

## 1. 문서의 목적

MENOS의 콘텐츠와 런타임을 객체 중심으로 개발한다.
각 객체는 정의 데이터, Editor, Runtime 소비 경로를 명확히 가진다.
객체를 조합하는 상위 단위는 Encounter, Stage, Campaign으로 분리한다.

이 문서는 구현 완료를 선언하지 않는다. 개발 순서와 책임 경계를 정하기 위한 계획이다.
기존 PoC 구현은 실제 구현 사실로 존중하되 Master Canon과 충돌하면 Canon 전환을 우선한다.

## 2. 기준선

CONFIRMED — 현재 프로젝트에는 다음 Editor/도구가 존재한다.
- Content Editor
- Asset Catalog / Image Editor 계열
- Map Editor
- Stage Editor
- Robot Editor
- Enemy Editor
- Tower Editor
- Content Validator

CONFIRMED — 현재 콘텐츠 데이터에는 Robot, Enemy, Tower, Item, Map, Stage, Campaign 데이터가 존재한다.

CONFIRMED — 현재 Building 전용 데이터/Editor는 확인되지 않았다.

CONFIRMED — Skill, Encounter, Progression, Reward/Economy, Test Scenario 전용 Editor는 현재 기준으로 별도 존재하지 않는다.

UNVERIFIED — 각 기존 Editor의 모든 저장값이 실제 Runtime 소비 경로까지 완전히 연결되었는지는 별도 검증이 필요하다.

## 3. Master Canon과의 관계

Master Canon 기준 전투 객체:
- 플레이어가 직접 조종하는 슈퍼로봇 1기
- AI 아군 유닛
- 고정형 지원 시설/건물
- 일반 적
- 거대 보스

플레이어는 이동, 기본 공격, 타깃, 타깃 전환, 특수공격, 필살기를 직접 사용한다.
RTS식 다수 유닛 지휘와 Tower Defense 중심 조작은 핵심 구조가 아니다.

따라서 객체 Editor도 Commander/Auto-Robot 구현을 중심으로 설계하지 않는다.
## 4. 객체 중심 전체 계층

권장 구조:

Object → Skill/Equipment → Encounter → Stage → Campaign

보다 구체적으로는:

- Actor Object: Robot / Unit / Enemy / Boss
- Building Object: Base / Defense / Support / Production / Resource / Special
- Combat Object: Weapon / Skill / Projectile / Effect
- Item Object: Equipment / Consumable / Reward Item
- Spatial Object: Terrain / Spawn / Objective / Placement Point
- Composition Object: Encounter / Wave / Stage
- Progression Object: Robot Growth / Unlock / Reward / Economy
- Meta Object: Campaign / Mission / Profile

핵심 원칙은 객체 자체의 정의와 객체를 배치·조합하는 데이터를 분리하는 것이다.

## 5. Actor 객체

### 5.1 Robot

현재 Robot Editor를 유지한다.

책임:
- 기본 사양
- 이동 능력
- HP/방어 관련 기본값
- 기본 무장 연결
- 사용 가능한 Skill 연결
- 애니메이션/표현 리소스 연결

분리해야 할 데이터:
- Robot Definition
- Player Robot Profile
- Battle Runtime State

개발 순서:
1. Definition 구조 확정
2. Robot Editor 저장
3. Runtime Loader 연결
4. 직접 조작 Runtime 연결
5. 성장/장비 적용
6. PIE 검증

### 5.2 Unit

AI 아군 유닛은 Robot과 동일한 최상위 객체로 무조건 분리할 필요는 없다.
공통 Actor 데이터가 유효하다면 Unit/Robot/Enemy가 공유할 수 있는 기반을 검토한다.

다만 현재 코드 구조를 확인하기 전 Generic Actor 통합을 확정하지 않는다.
PROPOSAL — 초기에는 별도 Unit Editor를 서둘러 만들지 않고 Enemy/Robot 구조와 중복을 조사한다.
### 5.3 Enemy

현재 Enemy Editor를 유지한다.

책임:
- HP
- 이동
- 공격
- 방어
- 타깃 우선순위
- 보상 기본값
- AI Profile 연결
- 표현 리소스

개발 순서:
1. Enemy Definition
2. Enemy Editor 저장
3. Runtime 소비 연결
4. AI Profile 연결
5. 다양한 Enemy 유형 검증

### 5.4 Boss

Boss는 일반 Enemy의 단순 고HP 변형으로 고정하지 않는다.

필요 후보:
- Phase
- Attack Pattern
- Weak Point
- Special Attack
- Summon
- Enrage
- Death Sequence

PROPOSAL — Boss 규칙이 실제로 확정되는 시점에 Boss Editor를 추가한다.
초기에는 Enemy Definition 확장으로 처리 가능한지 먼저 검토한다.

## 6. Building 객체

Building을 Tower의 상위 개념으로 정의한다.
Tower는 Building의 한 유형으로 취급한다.

Building 공통 데이터:
- ID / 이름
- 소유 진영
- HP / 내구도
- 크기 / footprint
- 배치 가능 여부
- 파괴 가능 여부
- 배치 조건
- 건설 비용
- 연결된 Weapon/Skill
- 시각 Asset
- Runtime Behavior Type
### 6.1 Building 유형

1. Base / Headquarters
2. Defense Building
3. Support Building
4. Production Building
5. Resource Building
6. Special Building

예시:
- Base: 플레이어/적 본진
- Defense: Cannon, Gatling 등
- Support: Repair, Buff, Radar 등
- Production: Unit/Robot 생산 또는 출격 시설
- Resource: 자원 생성/저장 시설
- Special: 특정 미션 전용 시설

현재 확정된 것은 Base와 Tower 계열의 존재 및 Tower의 지원 시설 역할이다.
나머지 유형은 확장 설계 후보이며 실제 요구가 생길 때 추가한다.

### 6.2 Building Editor

PROPOSAL — 기존 Tower Editor를 즉시 폐기하지 않는다.

1단계:
- Building 공통 데이터 구조 조사
- Tower 데이터와 Base 데이터의 중복/차이 확인

2단계:
- Building 공통 모델 정의
- Tower를 Building의 Defense 유형으로 연결

3단계:
- Building Editor 도입 여부 결정
- 필요하면 기존 Tower Editor UI를 Building Editor의 Defense 탭으로 흡수

목표는 Editor 숫자를 늘리는 것이 아니라 Building 전체를 일관되게 관리하는 것이다.
## 7. Combat Object

### 7.1 Weapon

무기 정의는 Robot/Enemy/Tower 내부에 모든 수치를 중복 저장하지 않는 방향을 검토한다.

관리 후보:
- Damage
- Range
- Cooldown
- Projectile
- Target Rule
- Hit Rule
- Damage Type
- VFX/SFX

PROPOSAL — 별도 Weapon Editor는 초기에는 만들지 않고 Skill/Combat Data 구조와 통합 가능성을 먼저 조사한다.

### 7.2 Skill / Ability

MENOS 핵심 전투 기능이므로 별도 Editor 필요성이 높다.

관리 대상:
- Skill ID
- Skill Type
- Activation Input
- Cooldown
- Resource/Gauge Cost
- Range
- Target Rule
- Damage/Effect
- Area/Pierce/Dash 등 동작 유형
- Animation/VFX/SFX
- Unlock Condition
- Finisher Flag

Robot Editor는 Skill 자체를 편집하기보다 어떤 Skill을 사용할 수 있는지 연결하는 역할을 담당한다.

권장 흐름:
Skill Editor → Skill Data → Robot/Enemy/Building 연결 → Runtime Skill System

### 7.3 Projectile / Effect

별도 Editor를 당장 만들지 않는다.

초기에는 Weapon/Skill 데이터에서 Projectile과 Effect 정의를 참조하도록 한다.
시각 효과와 실제 판정이 분리되는 현재 PoC의 문제는 Runtime 검증 단계에서 별도로 다룬다.
## 8. Item / Progression 객체

현재 Item 데이터가 존재하므로 Item Editor 필요성을 검토한다.

### Item Editor

관리 후보:
- Item Definition
- Category
- Equipment Slot
- Base Stat
- Affix Pool
- Compatibility
- Value
- Acquisition Rule

현재 Item 시스템이 이미 Runtime에 연결된 범위가 있으므로 새 Editor 구현 전에 저장/로드/Runtime 소비 경로를 확인한다.

### Progression Editor

관리 후보:
- XP Rule
- Level Curve
- Stat Growth
- Skill Unlock
- Equipment Unlock
- Permanent Upgrade

초기 범위는 Robot 성장으로 제한한다.
장비/경제/강화가 확정되기 전 거대한 통합 Progression Editor를 만들지 않는다.
## 9. Spatial / Map 객체

현재 Map Editor를 유지한다.

Map은 전투 공간을 소유한다.

Map Editor 책임:
- 맵 크기
- 타일/지형
- 장애물
- 건설 가능 영역
- Spawn Point
- Robot Start
- Base 위치
- Objective 위치
- Building 배치 가능 영역

중요한 변경 방향:
Map Editor의 배치 대상은 Tower에 한정하지 않고 Building을 대상으로 한다.

따라서 향후:
Map → Building Instance → Building Definition
형태로 연결한다.

맵 에디터의 범위와 Stage의 전투 규칙을 혼합하지 않는다.
## 10. Encounter 객체

Encounter는 Stage와 Wave 사이의 조합 단위로 제안한다.

역할:
- 적 그룹
- Spawn Rule
- Spawn Timing
- Trigger
- Reinforcement
- Objective 변화
- Boss Entry
- Encounter 종료 조건

예:
Stage 01
 ├─ Encounter 01: 초기 적 습격
 ├─ Encounter 02: 증원
 ├─ Encounter 03: Heavy 집단
 └─ Encounter 04: Boss

PROPOSAL — 현재 Stage Editor가 과도하게 복잡해지기 전에 Encounter를 별도 데이터 단위로 분리한다.

별도 Encounter Editor가 필요한지는 Stage Editor의 실제 복잡도 증가를 관찰한 뒤 결정한다.
Wave와 Encounter를 별도 Editor로 무조건 분리하지 않는다.
## 11. Stage / Mission 객체

현재 Stage Editor를 유지한다.

Stage는 다음을 조합한다.
- Map
- Mission ID
- Encounter/Wave
- Spawn 설정
- Victory Rule
- Defeat Rule
- Reward

Mission은 독립 데이터 객체로 존재하며 목표와 승패 규칙을 소유한다.
Stage는 Mission을 직접 복사하지 않고 Mission ID로 참조한다.
Map은 공간을 소유한다.
Stage는 Map과 Mission 및 Encounter/Wave를 실제 플레이 단위로 조합한다.

### Mission 객체화 — 완료

CONFIRMED:
- MissionDefinition 및 MissionDefinitionLoader를 추가했다.
- content/missions/missions.json을 독립 Mission Catalog로 사용한다.
- Stage JSON은 기존 Mission Dictionary 대신 mission_id를 참조한다.
- StageLoader는 mission_id를 필수값으로 검증하고 실제 Mission 존재 여부를 확인한다.
- StageManager는 현재 Stage의 Mission Definition을 조회할 수 있다.
- Stage Editor는 Mission ID를 편집하고 독립 Mission Catalog에 저장한다.
- Title Screen은 Stage 내부 Mission 데이터가 아니라 Mission Definition을 참조한다.
- Content Validator는 Mission 필수 필드와 Stage → Mission 참조를 검증한다.

검증:
- Godot 4.7.2 headless CODE 검증 PASS
- Stage 01~03의 Mission ID 해석 PASS
- Content Validator PASS
- git diff --check PASS

현재 Mission Runtime의 승패 판정(primary_type, target_id, time_limit)은 별도 작업으로 남긴다.

Stage Editor가 담당하지 않아야 할 것:
- Robot 기본 능력치
- Enemy 기본 능력치
- Building 기본 능력치
- Skill 상세 정의
- 영구 성장 데이터

이 원칙으로 Stage Editor의 비대화를 막는다.

## 12. Campaign 객체

Campaign은 Stage보다 상위 단위다.

관리 후보:
- Mission 순서
- Stage 연결
- Unlock Condition
- Story Event
- Campaign Reward
- Ending
- Free Battle 해금

현재 campaign JSON은 존재하지만 Campaign Editor는 별도 확인되지 않았다.

PROPOSAL — 캠페인 콘텐츠 수량과 이벤트 구조가 확정되는 시점에 Campaign Editor를 추가한다.
## 13. Editor 전체 계획

### 기존 유지
- Content Editor
- Asset Catalog / Image Editor
- Map Editor
- Stage Editor
- Robot Editor
- Enemy Editor
- Tower Editor
- Content Validator

### 우선 추가 검토
- Building Editor
- Skill Editor
- Progression Editor

### 조건부 추가
- Boss Editor
- Encounter Editor
- Item Editor
- Campaign Editor

### 개발 지원 도구
- Balance Lab
- Test Scenario Editor
- Debug/Playtest Tool
- Replay/Combat Analyzer

원칙: 기능마다 별도 프로그램을 만드는 것이 아니라 데이터 책임이 독립적이고 반복 편집 가치가 있을 때만 Editor를 분리한다.
## 14. 객체별 개발 우선순위

P0 — 핵심 전투 객체
1. Robot
2. Enemy
3. Building / Base / Defense
4. Weapon / Basic Attack
5. Skill / Special / Finisher

P1 — 전투 조합 객체
6. Map
7. Encounter / Wave
8. Mission
9. Stage

P1 — 진행 객체
10. Robot Progression
11. Item / Equipment
12. Reward
13. Save/Profile

P2 — 캠페인 객체
14. Campaign
15. Story Event
16. Unlock

P2 — 확장 객체
17. Boss 특수 구조
18. Support / Production / Resource Building
19. Economy / Shop

P3 — 개발/출시 지원
20. Balance Lab
21. Test Scenario
22. Replay Analyzer
23. Localization

## 15. 구현 순서

Phase A — 객체 기반 정리
- 기존 Robot/Enemy/Tower 데이터 구조 조사
- Building 공통 개념 검토
- Actor 공통 구조의 필요성 조사
- 데이터 ID와 참조 규칙 통일
- Content Validator 기준 확장

완료 조건: 각 핵심 객체가 무엇을 소유하고 무엇을 참조하는지 문서로 확정 가능.

### Phase B 조사 갱신 — Robot / Enemy Runtime 연결

STATUS: COMPLETE

CONFIRMED:
- RobotDefinition이 Robot Runtime의 정적 능력치, progression, energy, visual 정보를 제공한다.
- Robot의 실제 Runtime State는 GameController가 생성하고 관리하며, `get_robot_runtime_stats()`가 Definition과 progression을 조합한다.
- Robot 기본 공격은 `RobotDefinition -> WeaponDefinition -> robot_weapon_definition -> try_basic_attack()` 경로로 소비된다.
- EnemyDefinition은 `combat`, `visuals`, `robot_attack`으로 정적 데이터를 보유한다.
- EnemyRuntimeState는 type/lane/position/hp/timer/boss 상태 등 실행 중 mutable state만 보유한다.
- Enemy AI/공격은 현재 별도 EnemyAI 객체가 아니라 GameController에 구현되어 있으며, 필요한 정적 값은 EnemyDefinition에서 조회한다.
- Enemy의 Giant Robot 공격은 EnemyDefinition의 `robot_attack`에서 파생된 WeaponDefinition을 사용한다.

JUDGMENT:
- 현재 Robot/Enemy 모두 Definition과 Runtime의 기능적 연결은 존재한다.
- `ActorRuntimeState` 공통 상속 구조를 즉시 도입할 필요는 확인되지 않았다.
- GameController의 Definition 참조 집중은 향후 리팩터링 후보이나 현재 Phase B의 목적 달성을 막는 결함으로 판정하지 않는다.
- 기존 Runtime을 보존하면서 Definition 소비 경로를 우선 검증한다.

IMPLEMENTATION RULE:
- JSON 대량 변환 금지.
- Runtime 구조의 일괄 재설계 금지.
- Definition/Editor/Runtime 경계에서 실제 중복 또는 잘못된 소유권이 확인된 경우에만 최소 변경한다.
- 변경 전 baseline 확인, 변경 후 diff 및 최소 검증을 수행한다.

NEXT:
- Tower/Building/Base Runtime 소비 구조 확인.
- Skill/Special/Finisher의 Definition → Runtime 소비 구조 확인.
- 이후 Phase B의 실제 변경 필요 여부를 판정한다.
### Phase C 조사 갱신 — Mission 객체화 및 Runtime 규칙

STATUS: MISSION DATA OBJECTIFICATION COMPLETE / CORE RUNTIME RULES IMPLEMENTED

CONFIRMED:
- Mission을 Stage 내부 Dictionary에서 독립 MissionDefinition으로 승격했다.
- Mission Catalog와 Loader를 추가했다.
- Stage는 mission_id로 Mission을 참조한다.
- StageLoader, StageManager, Stage Editor, Title Screen, Content Validator가 새 참조 구조를 사용한다.
- Stage 01~03의 Mission 참조와 Content Validator가 통과했다.
- `clear_encounters`는 기존처럼 마지막 Encounter/Wave 완료를 Victory로 사용한다.
- `defend_base`는 `time_limit` 동안 Base HP가 0보다 크면 Victory로 판정한다.
- `defend_base`에서는 Encounter/Wave 전체 완료가 조기 Victory를 발생시키지 않고 Mission 시간 제한까지 방어를 계속한다.
- Base HP 0에 의한 DEFEAT가 Mission 시간 완료보다 우선한다.
- Campaign 모드에서도 `defend_base` 완료 후 기존 Stage 전환/최종 Campaign Victory 흐름을 유지한다.
- `target_id`는 현재 승인된 `defend_base` 규칙에서는 사용하지 않는다. 보호 대상은 Stage Base로 고정한다.
- Godot 4.7.2 headless Content Validator PASS.
- Mission Runtime 최소 로직 검증 PASS: defend 활성화, 시간 완료 Victory, Base 파괴 시 Victory 방지.
- `git diff --check` PASS.

PENDING:
- Mission별 Reward 연결
- `defend_base` 실제 Stage 데이터의 PIE 검증

Phase C — 전투 조합
- Map
- Building 배치
- Spawn
- Encounter/Wave
- Mission 객체화 및 Stage 참조
- Mission Runtime 승패 규칙
- Stage

완료 조건: 하나의 Stage가 Map, Mission, Encounter/Wave와 객체 정의를 참조해 독립적으로 실행 가능하며 Mission 데이터가 Stage에 중복 저장되지 않는다.

Phase D — 성장/보상
- Robot Profile
- XP/Level
- Skill Unlock
- Item/Equipment
- Reward
- Save

완료 조건: 전투 결과가 영구 데이터로 안전하게 반영되고 재진입 후 복원됨.

Phase E — 캠페인
- Campaign
- Mission Unlock
- Story Event
- Ending
- Free Battle

완료 조건: 캠페인 전체 흐름과 자유 전투 진입이 객체 참조 구조로 구성됨.
## 16. 데이터 참조 원칙

권장 참조 구조:

Robot Definition
 → Skill IDs
 → Weapon IDs
 → Asset IDs

Enemy Definition
 → Skill/Weapon IDs
 → AI Profile ID
 → Asset IDs

Building Definition
 → Weapon/Skill IDs
 → Building Behavior ID
 → Asset IDs

Map
 → Spatial Instance IDs
 → Building Definition IDs
 → Spawn/Objective IDs

Encounter
 → Enemy Definition IDs
 → Spawn Rules
 → Trigger IDs

Stage
 → Map ID
 → Mission ID
 → Encounter IDs
 → Reward ID

Mission
 → Objective / Victory / Defeat Rules
 → Target ID
 → Time Limit

Campaign
 → Stage IDs
 → Unlock Rules
 → Story Event IDs

이 구조는 객체 정의를 Stage/Map에 복사하지 않는 것을 원칙으로 한다.

## 17. Validator 확장 계획

Content Validator는 객체 중심 구조의 안전망으로 사용한다.

검증 항목:
- ID 중복
- 존재하지 않는 참조
- 잘못된 Asset 경로
- 잘못된 Skill 연결
- Building 유형 불일치
- Map/Stage 호환성
- Encounter 참조 오류
- Mission 참조 오류
- Mission 필수 필드/타입 오류
- Reward 참조 오류
- Campaign Stage 누락
- 필수 필드 누락

Validator는 Runtime 성공을 보장하지 않는다.
데이터 구조 오류를 조기에 찾는 도구로 정의한다.
## 18. 검증 전략

각 객체는 다음 순서로 검증한다.

1. DATA VERIFIED — 정의 데이터가 올바르게 저장/로드됨
2. CODE VERIFIED — Runtime 소비 경로가 실제 코드에 존재함
3. EDITOR VERIFIED — Editor에서 생성/수정/저장이 가능함
4. BUILD VERIFIED — 프로젝트 Build 성공
5. PIE VERIFIED — Master가 실제 Runtime 동작을 확인함

Editor에서 보이는 것만으로 Runtime 연결을 완료로 판정하지 않는다.
자동화 테스트 PASS도 PIE VERIFIED를 대체하지 않는다.

## 19. 최소 구현 원칙

새 객체를 추가할 때 항상 다음 질문을 먼저 한다.

- 이 객체가 실제 게임 플레이에 필요한가?
- 기존 객체의 확장으로 충분한가?
- 독립 Definition이 필요한가?
- 독립 Editor가 반복 작업을 줄이는가?
- Runtime에서 독립 책임이 필요한가?

위 질문에 모두 답할 수 없으면 별도 객체/Editor 생성을 보류한다.

## 20. 특히 피해야 할 구조

- Tower를 모든 Building의 최상위 개념으로 계속 확장
- Stage JSON 안에 모든 객체의 상세 스탯 복사
- Robot Editor에 Skill 상세 로직을 하드코딩
- Enemy Editor에 Boss 전용 규칙을 무제한 추가
- 하나의 Content Editor에 모든 로직을 넣는 거대 Editor
- 데이터와 Runtime 상태를 동일 객체에 저장
- Editor에서 보이는 값만으로 구현 완료 판정

## 21. 개발 의존성

객체 정의 → Runtime 소비 → 조합 데이터 → 진행 데이터 순서를 기본으로 한다.

따라서 Campaign Editor를 먼저 만드는 것보다 핵심 객체와 Stage 구조를 먼저 안정화한다.
Building Editor 역시 실제 Building 공통 구조를 확인한 후 만든다.

## 22. 현재 기준 다음 작업 후보

1. 실제 Robot/Enemy/Tower/Building 관련 코드 READ-ONLY 조사
2. 공통 데이터와 중복 데이터 식별
3. Building 상위 모델의 최소 필드 정의
4. Skill 데이터의 실제 위치와 Runtime 소비 경로 조사
5. Stage/Map/Wave 관계 확인
6. 객체 중심 데이터 참조표 확정

이 문서 자체로 코드 변경을 시작하지 않는다.
Master 승인 후 개별 작업지시로 분해한다.
## 23. 현실성 판단

TECHNICALLY POSSIBLE — 현재 프로젝트가 이미 Robot/Enemy/Tower/Map/Stage 중심 데이터와 Editor를 가지고 있어 확장 기반이 존재한다.

PRACTICALLY FEASIBLE — 기존 Editor를 단계적으로 확장하면서 적용할 수 있다.

PROPOSAL — Building을 상위 개념으로 정리하고 Skill을 독립 콘텐츠로 분리하는 것이 향후 콘텐츠 확장에 유리하다.

UNVERIFIED — Generic Actor 통합, Building의 실제 코드 공통화 가능성, Skill Editor의 정확한 구현 범위는 코드 조사 후 확정한다.

## 24. 승인/변경 규칙

본 문서는 개발 방향 제안이다.
Master 승인 전 Canon으로 승격하지 않는다.

구조 변경은 기존 데이터와 Runtime에 미치는 영향을 확인한 뒤 최소 범위로 수행한다.
삭제/대규모 데이터 변환/기존 Editor 폐기는 별도 승인 대상으로 한다.

## 25. 종료 기준

객체 중심 구조의 목적은 Editor 개수를 늘리는 것이 아니다.

목표는 다음 네 가지다.

- 객체 정의를 한 곳에서 관리한다.
- 객체를 조합하는 단위를 명확하게 한다.
- Runtime이 어떤 데이터를 소비하는지 추적 가능하게 한다.
- 콘텐츠를 추가할 때 기존 코드를 최소 수정한다.

이 조건이 충족되면 추가 Editor 생성은 자동으로 진행하지 않는다.

## 26. 상태 보고

STATUS — PASS / PROPOSAL

목적 — MENOS를 객체 중심 개발 단위로 재구성하고 Editor/데이터/Runtime의 개발 순서를 계획한다.

기준선 — 2026-09-30 프로젝트 파일 구조 및 기존 구현 문서 READ-ONLY 조사.

변경 사항 — 본 계획 문서 신규 작성. 기존 코드/Asset/Scene/Data는 변경하지 않는다.

검증 상태 — EDITOR 구조 READ-ONLY 확인. CODE/BUILD/PIE 신규 검증은 수행하지 않는다.

OUT OF SCOPE — 실제 Building Editor/Skill Editor 구현, 데이터 마이그레이션, Canon 변경, Commit/Push.

다음 단계 — Master 승인 후 객체별 조사 또는 구현 작업을 개별 작업지시로 분리한다.


### Phase C 조사 갱신 — Stage Reward 객체화
STATUS: REWARD DATA/RUNTIME IMPLEMENTATION COMPLETE / PIE PENDING

CONFIRMED:
- Mission Reward와 Enemy combat.reward를 별도 개념으로 분리
- RewardDefinition 및 RewardDefinitionLoader 추가
- Reward Catalog 추가: content/rewards/rewards.json
- Stage에 reward_id 참조 추가
- StageLoader가 reward_id를 필수 참조로 검증하고 RewardDefinition을 resolve
- StageManager가 RewardDefinition 조회 경로 제공
- Stage Editor에서 Reward ID를 표시하고 신규 Reward catalog entry를 생성/저장 가능
- Content Validator가 Reward id/gold/item_ids 및 Stage reward_id 참조를 검증
- 현재 Stage 01~03은 reward_stage_01~03을 참조하며 기본 보상은 gold 0 / item_ids []
- Master 승인으로 PlayerProfileState에 영구 gold 필드 추가
- PlayerProfileState gold가 load/save 직렬화 경로에 포함됨
- Campaign Stage 완료 시 RewardDefinition을 한 번만 지급
- Reward.gold는 PlayerProfileState.gold에 영구 누적
- Reward.item_ids는 기존 Item Catalog의 base_id를 사용해 create_item()으로 생성 후 persistent inventory에 추가
- clear_encounters 완료와 defend_base 완료 모두 동일한 Reward 지급 경로를 사용
- non-campaign 실행에서는 persistent Stage Reward를 지급하지 않음
- Godot 4.7.2 project headless load PASS
- PlayerProfile gold serialize/restore validation PASS
- RewardDefinition load validation PASS
- Content Validator PASS
- git diff --check PASS

PENDING:

- 실제 Stage Reward 값 구성
- PIE 검증


### Phase D 조사 갱신 — Robot Progression / Equipment / Profile
STATUS: READ-ONLY BASELINE CONFIRMED / IMPLEMENTATION HOLD

CONFIRMED:
- RobotProgressionState가 Level, XP, unlocked_abilities를 영구 데이터로 관리한다.
- PlayerProfileState가 RobotProgressionState와 CampaignProgressionState를 포함하며 Gold, Inventory, Equipped Items를 함께 직렬화한다.
- PlayerProfileState.gold는 load/save 경로에 연결되어 있다.
- Item Catalog에는 Weapon / Armor / Core 정의와 Base Stat 및 Prefix/Suffix 생성 규칙이 존재한다.
- ObjectPersistence는 Catalog 저장 후 실제 파일 재읽기 비교까지 수행한다.
- Reward Runtime은 Stage 완료 시 Profile Gold 및 Inventory에 반영되는 경로가 구현되어 있다.

UNVERIFIED:
- XP 증가에 따른 실제 Level-Up 규칙과 Stat Growth의 완성 여부
- Skill Unlock 조건과 Runtime 적용 경로의 완전성
- Equipped Item 능력치가 Robot Runtime에 적용되는 전체 경로
- 실제 게임 재진입을 통한 Profile/Equipment 복원 PIE 검증

JUDGMENT:
- Phase D의 Profile/Reward 저장 기반은 이미 존재한다.
- 현재 확인된 정보만으로 새로운 Progression 시스템을 추가할 필요성은 확인되지 않았다.
- 다음 조사에서는 XP/Level, Skill Unlock, Equipment → Robot Runtime 연결을 READ-ONLY로 확인하고 실제 결함이 확인될 때만 최소 변경한다.

PENDING:
- XP → Level 규칙 확인
- Skill Unlock Runtime 연결 확인
- Equipment Runtime 적용 확인
- PIE 검증


### Phase D 조사 갱신 — Profile Save/Load 안전성
STATUS: PASS / MINIMAL SAFETY FIX APPLIED / PIE PENDING

CONFIRMED:
- Campaign Profile은 user://menos_campaign_robot_profile.json에 저장된다.
- PlayerProfileState는 Level / XP / Unlock / Campaign Progress / Gold / Inventory / Equipped Items를 직렬화한다.
- 정상적인 Dictionary Profile은 load_from_data()를 통해 복원된다.
- 저장 파일이 없으면 기본 Profile로 시작한다.
- 기존 Profile의 Inventory가 비어 있을 때만 기본 Weapon / Armor / Core를 생성한다.

ISSUE FOUND:
- 기존 로드 경로는 Profile JSON 파싱 결과가 Dictionary가 아니어도 기본 상태로 계속 진행한 뒤 _save_robot_progression()을 호출하여 손상된 Profile을 기본 Profile로 덮어쓸 가능성이 있었다.

CHANGE:
- JSON 파싱 결과가 Dictionary가 아니면 오류를 기록하고 즉시 로드를 중단하도록 최소 수정했다.
- 정상 Profile의 기존 저장/복원 경로는 변경하지 않았다.

VALIDATION:
- 변경 후 git diff 확인 완료.
- git diff --check PASS.
- PIE 검증은 아직 수행하지 않음.

PENDING:
- 실제 게임 재진입을 통한 정상 Profile 복원 PIE 검증
- 손상 Profile에 대한 보호 동작의 실제 Runtime 검증


### Phase E 조사 갱신 — Campaign Progression Save/Load
STATUS: PASS / READ-ONLY INVESTIGATION COMPLETE / DESIGN HOLD

CONFIRMED:
- CampaignProgressionState는 unlocked_stage_ids와 completed_stage_ids를 분리해 보유한다.
- complete_stage(stage_id, next_stage_id)는 완료 Stage를 기록하고 다음 Stage를 Unlock한다.
- PlayerProfileState.to_data()/load_from_data()가 CampaignProgressionState를 Profile 저장 데이터에 포함한다.
- GameController의 Campaign Stage 완료 경로는 다음 Stage ID를 계산한 뒤 complete_stage()를 호출하고 Profile을 저장한다.
- Stage 01~03의 Campaign 순서는 main_campaign.json의 stage_01 → stage_02 → stage_03으로 정의되어 있다.
- 임시 headless 검증에서 CampaignProgressionState의 완료/Unlock 직렬화·복원과 PlayerProfileState 내 Campaign Progress + Gold 복원이 PASS했다.
- git diff --check PASS.

IMPORTANT FINDINGS:
- CampaignProgressionState의 초기 Stage는 현재 "stage_01"로 하드코딩되어 있다.
- StageManager.begin_run()은 campaign에서 전달된 stage_id가 Unlock 상태인지 검사하지 않는다.
- 현재 Title Screen의 Stage 선택은 Single Play에만 노출되므로 Campaign에서 잠금 Stage를 선택하는 UI 문제는 실제 발생 경로가 아니다.
- 향후 Campaign Stage 선택 UI를 추가할 경우 Unlock 검사와 초기 Stage 식별자를 Campaign 데이터에서 읽는 구조가 필요하다.
- Story Event / Ending / Free Battle 전용 객체나 Catalog는 현재 확인되지 않았다.

JUDGMENT:
- 현재 Campaign의 Stage 순차 진행, 완료/Unlock 상태 저장·복원 기반은 목적에 충분하다.
- 즉시 Campaign Progression 코드를 변경할 필요는 확인되지 않았다.
- Campaign Unlock의 독립 객체화, Story Event, Ending, Free Battle은 새로운 콘텐츠 설계/Canon 판단이 필요하므로 현재 구현을 시작하지 않는다.

VERIFICATION:
- CODE VERIFIED
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: not required for this investigation
- PIE VERIFIED: PENDING

OUT OF SCOPE:
- Campaign Editor 구현
- Mission Unlock 독립 객체 구현
- Story Event / Ending / Free Battle 데이터 설계
- Campaign Stage Select UI 변경


### Phase D 조사 갱신 — XP / Level / Skill Unlock / Equipment Runtime 재개
STATUS: PASS / READ-ONLY INVESTIGATION COMPLETE / PIE PENDING

CONFIRMED:
- RobotProgressionState는 Level / XP / unlocked_abilities를 저장하고 복원한다.
- robots.json의 progression 정의에는 xp_per_level=100, damage_growth=0.05, hp_growth=0.05, range_growth=0.02, speed_growth=0.02가 존재한다.
- GameController.add_robot_xp()는 Campaign에서만 XP를 증가시키며, 레벨별 요구 XP를 계산해 Level을 올리고 Runtime Robot max HP 및 HP를 갱신한다.
- available_robot_growths()는 Skill Catalog의 growth_available=true 항목 중 아직 Unlock되지 않은 Skill을 제공한다.
- choose_robot_growth()는 GROWTH 상태에서 선택된 Skill을 RobotProgressionState에 Unlock하고 READY로 복귀시킨다.
- get_robot_runtime_stats()는 Robot Definition의 기본 스탯에 Level 성장률을 적용하고 Equipped Item의 HP/Damage/Range/Speed 보정을 추가한다.
- PlayerProfileState가 Level / XP / Unlock / Inventory / Equipped Items를 저장하고 _load_robot_progression()이 이를 복원한다.
- 기존 Profile Save/Load 안전성 최소 수정 이후 정상 Dictionary가 아닌 Profile은 즉시 오류 처리하고 기존 데이터 경로를 덮어쓰지 않는다.

JUDGMENT:
- XP → Level → Runtime Stat 연결은 현재 코드상 구현되어 있다.
- Skill Unlock → Runtime 상태 연결도 현재 코드상 구현되어 있다.
- Equipment → Robot Runtime Stat 연결도 구현되어 있다.
- 따라서 새로운 Progression 시스템이나 별도 Equipment Runtime 계층을 추가할 근거는 확인되지 않았다.
- 실제 게임에서 레벨업, 성장 선택, 장비 효과, 재진입 복원을 확인하는 PIE 검증만 남는다.

VERIFICATION:
- CODE VERIFIED
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT REQUIRED FOR THIS READ-ONLY INVESTIGATION
- PIE VERIFIED: PENDING

OUT OF SCOPE:
- 새로운 XP/Level 시스템 설계
- 새로운 Skill Unlock 시스템 설계
- Equipment 시스템 재구축
- 성장 UI 신규 설계
- PIE 자동 실행을 통한 Production 승인


### Phase B 조사 갱신 — Boss 객체 구조
STATUS: PASS / READ-ONLY INVESTIGATION COMPLETE / DESIGN HOLD

CONFIRMED:
- 현재 Enemy Catalog의 giant 항목은 일반 Enemy Definition 데이터로 존재하며 HP, Armor, 공격값, 속도, 보상, Sprite 정보만 가진다.
- Boss 전용 Runtime 상태는 EnemyRuntimeState에 boss_pattern_timer, boss_pattern_index, boss_windup_timer, boss_charge_timer, boss_charge_target, boss_pattern_active로 존재한다.
- GameController.update_giant_boss_attack()가 GIANT의 공격 패턴 3종(CANNON SHOT / CRUSHING BLAST / CHARGE)을 직접 구현한다.
- GIANT 판정은 GameController 여러 Runtime 경로에서 enemy.type == "giant" 조건으로 직접 연결되어 있다.
- 현재 BossDefinition 또는 Boss Catalog는 확인되지 않았다.
- 현재 Boss 전용 Editor도 확인되지 않았다.
- 현재 데이터에서는 Phase / Weak Point / Enrage / Summon / Death Sequence 같은 Boss 전용 정의 필드는 확인되지 않았다.

IMPORTANT FINDING:
- Boss는 이미 Runtime 동작을 갖고 있지만 Boss 규칙의 상당 부분이 GameController에 하드코딩되어 있다.
- 따라서 향후 Boss 콘텐츠를 확장하려면 BossDefinition으로 즉시 리팩터링하기보다, 먼저 Master가 Boss를 독립 객체로 취급할 필요가 있는지 Canon/콘텐츠 요구를 결정해야 한다.

JUDGMENT:
- 현재 GIANT 하나의 동작을 유지하는 목적에는 기존 구조가 동작 가능한 상태다.
- Boss 공통화 또는 BossDefinition 생성은 현재 조사만으로 필수라고 판정할 수 없다.
- Boss Editor 추가는 더더욱 콘텐츠 확장 요구가 확인되기 전에는 보류한다.
- 새로운 Boss 설계가 필요해지는 경우에만 Enemy 확장과 독립 Boss 객체의 비용/효과를 비교한다.

VERIFICATION:
- CODE VERIFIED
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT REQUIRED
- PIE VERIFIED: PENDING

OUT OF SCOPE:
- BossDefinition 신규 생성
- Boss Editor 생성
- GIANT Runtime 리팩터링
- Boss Phase/Weak Point/Enrage/Summon 설계

### Phase A 계획 추가 — 생성 이미지 배경색 → 투명 처리
STATUS: PLANNED / IMPLEMENTATION NOT STARTED

PURPOSE:
- Gemini 등 외부 이미지 생성 도구가 투명 배경 대신 단색/체크무늬 등의 배경을 포함해 생성한 이미지를 MENOS Image Editor에서 직접 정리할 수 있게 한다.

REQUIREMENTS:
- 이미지에서 기준 배경색을 픽셀 선택 또는 색상 선택으로 지정한다.
- 선택 색상과의 Tolerance를 조절할 수 있게 한다.
- 기준 색상 및 허용 범위에 해당하는 픽셀을 Alpha 0으로 변환한다.
- 연결된 배경 영역만 제거하는 방식과 이미지 전체의 유사 색상 제거 방식의 필요성을 검토한다.
- 안티앨리어싱 경계의 유사 색상을 고려한다.
- 처리 전/후 Preview를 제공한다.
- 원본 복구 또는 Undo 경로를 제공한다.
- 일반 이미지뿐 아니라 Sprite Sheet/Frame Asset에도 적용한다.
- 결과가 기존 Visual Asset 및 Runtime Asset 경로와 호환되어야 한다.

MINIMUM ACCEPTANCE:
1. 단색 배경이 포함된 생성 이미지를 Image Editor에서 연다.
2. 배경색을 선택한다.
3. Tolerance를 조절한다.
4. 배경이 투명으로 변하고 캐릭터 본체가 유지되는 것을 Preview에서 확인한다.
5. 결과를 저장하고 기존 Visual Asset 경로에서 정상적으로 사용할 수 있다.

IMPLEMENTATION ORDER:
1. Image Editor의 현재 이미지 로드/저장 경로 READ-ONLY 확인
2. 픽셀 접근 및 Image API 확인
3. 최소 배경 제거 알고리즘 PoC
4. 색상 선택 / Tolerance / Preview 연결
5. Undo/원본 복구 및 안전한 저장 연결
6. Sprite Sheet/Frame 적용 검증
7. Content Validator 및 Runtime Asset 호환성 검증

SAFETY:
- 기존 Asset을 임의로 덮어쓰지 않는다.
- 원본과 처리 결과의 저장 경로를 먼저 확정한다.
- 실제 Asset 변환은 Master 승인 후 수행한다.
- 코드 변경 후 Diff 및 최소 검증을 수행한다.

OUT OF SCOPE:
- AI 기반 자동 배경 제거
- 의미론적 객체 분리
- 그림자/반사광 자동 판별
- 외부 이미지 생성 서비스 연동
- 기존 Asset 일괄 변환

### Phase A 진행 갱신 — Image Editor 배경색 투명화 최소 구현
STATUS: PASS / MINIMUM IMPLEMENTATION COMPLETE / RUNTIME UI PENDING

CONFIRMED:
- Image Editor의 기존 current_image는 Godot Image 객체이며 get_pixel()/set_pixel() 기반의 직접 Pixel 수정이 가능하다.
- 기존 Save + Reconnect 경로가 편집 결과를 PNG로 저장하고 기존 Asset 참조를 재연결할 수 있다.
- Image Editor에 Background Color 선택기, Tolerance 입력, Remove Background Color 동작을 추가했다.
- 현재 알고리즘은 이미지 전체에서 선택 색상과 RGB 거리 기준으로 Tolerance 이내의 불투명 픽셀을 Alpha 0으로 변환한다.
- 처리 결과는 즉시 Preview에 반영되며 저장은 기존 Save + Reconnect를 사용한다.

LIMITATION:
- 현재 구현은 전체 이미지 유사색 제거 방식이다.
- 연결된 배경 영역만 제거하는 Flood Fill 방식은 아직 구현하지 않았다.
- 이미지에서 직접 픽셀을 클릭해 색상을 추출하는 Eyedropper는 아직 구현하지 않았다.
- Tolerance는 RGB Euclidean distance 기준이며 가장자리 Alpha 페더링은 아직 적용하지 않는다.

VALIDATION:
- Godot 4.7.2 headless project/editor load PASS.
- Process exit code 0.
- git diff --check PASS.
- 기존 변경사항과 별개로 Image Editor 변경 Diff 확인 완료.
- CODE VERIFIED
- BUILD VERIFIED
- EDITOR VERIFIED: headless editor load only
- PIE VERIFIED: NOT VERIFIED

NEXT DECISION:
- 최소 테스트 Image를 실제 Image Editor 코드 경로에 주입하여 Background Color / Tolerance UI 생성과 배경 제거 알고리즘을 검증한다.
- 테스트 결과: 4x4 이미지에서 흰색 12픽셀이 Alpha 0으로 제거되고 빨간색 4픽셀은 유지됨.
- Godot 4.7.2 headless validation exit 0.
- 실제 생성 이미지 1장을 대상으로 Runtime Editor에서 시각 결과를 확인하는 PIE/수동 검증은 아직 필요하다.
- 필요한 경우 Eyedropper / Flood Fill / Edge Alpha 개선 여부를 그 결과로 결정한다.


### Phase A 진행 갱신 — 2026-10-05 재개 검증
STATUS: PASS / CODE + BUILD + EDITOR VERIFIED / PIE PENDING

BASELINE:
- HEAD: 1167a88b527ff14ba0285ba81ba39a9ec24fc930
- Branch: main
- Working Tree: clean at investigation start

CONFIRMED:
- Image Editor 배경색 투명화 구현은 현재 HEAD에 포함되어 있다.
- Background Color 선택기, Tolerance(0.00~1.00, 기본 0.08), Remove Background Color 버튼 및 pressed signal 연결이 코드에 존재한다.
- 현재 제거 알고리즘은 전체 이미지의 불투명 픽셀을 대상으로 선택 색상과 RGB Euclidean distance가 Tolerance 이하이면 Alpha 0으로 변환한다.
- 기존 Save + Reconnect 경로는 유지된다.
- Godot 4.7.2에서 res://editor/image_editor.tscn을 headless 실행하여 exit code 0을 확인했다.
- git diff --check PASS.

VERIFICATION:
- CODE VERIFIED
- BUILD VERIFIED: Godot project/editor headless load PASS
- EDITOR VERIFIED: image_editor.tscn headless scene load PASS, exit code 0
- PIE VERIFIED: NOT VERIFIED

UNVERIFIED:
- 실제 Editor 화면에서 배경색 선택 → Tolerance 조절 → 제거 버튼 → Preview 확인의 수동 UI 동작.
- 실제 생성 이미지 1장에 대한 시각적 가장자리 품질.
- 실제 Sprite Sheet/Frame Asset에서의 수동 결과.

JUDGMENT:
- 현재 목적에 필요한 최소 코드 구현과 headless Editor 검증은 충족했다.
- PIE/수동 시각 검증 없이는 Flood Fill, Eyedropper, Edge Alpha 개선 필요성을 판단하지 않는다.
- 추가 코드 변경은 현재 목적 대비 정보가치가 낮으므로 STOP.


### Phase A 진행 갱신 — 2026-10-05 Edge-connected 옵션
STATUS: PASS / CODE + BUILD + EDITOR VERIFIED / PIE PENDING

CONFIRMED:
- 실제 보관 이미지 분석에서 글로벌 색상 제거가 생성 이미지의 큰 영역을 오제거할 수 있음을 확인했다.
- 계획에 있던 Connected-region vs whole-image 요구를 Editor 옵션으로 추가했다.
- Image Editor에 "Edge-connected only" 체크박스를 추가했다.
- 체크 시 선택 색상과 Tolerance 조건을 만족하면서 이미지 가장자리와 4-connected로 연결된 영역만 Alpha 0으로 변경한다.
- 체크 해제 시 기존 글로벌 색상 제거 동작을 그대로 유지한다.
- 기존 Asset 원본 파일은 수정하지 않았다.
- 첫 빌드 검증에서 타입 추론 오류가 발생했으나 명시적 int 타입으로 수정 후 image_editor.tscn headless 실행 exit code 0을 확인했다.
- git diff --check PASS.

VERIFICATION:
- CODE VERIFIED
- BUILD VERIFIED: Godot 4.7.2 image_editor.tscn load PASS
- EDITOR VERIFIED: headless scene load PASS, exit code 0
- PIE VERIFIED: NOT VERIFIED

UNVERIFIED:
- 실제 Editor에서 Edge-connected only 체크 후 버튼을 누르는 UI 동작.
- 실제 결과 이미지의 경계/안티앨리어싱 품질.
- Eyedropper 및 Edge Alpha 보정의 필요성.

JUDGMENT:
- 현재 단계에서 글로벌 제거와 연결영역 제거를 모두 제공하는 것이 기존 동작을 보존하면서 실제 생성 이미지 대응력을 높인다.
- Eyedropper/Edge Alpha는 실제 PIE 결과를 확인하기 전 추가 구현하지 않는다.


### Phase B 조사 갱신 — Tower / Building / Base Runtime 소비 구조
STATUS: PASS / READ-ONLY INVESTIGATION COMPLETE / DESIGN HOLD

CONFIRMED:
- TowerDefinition은 ObjectDefinition을 기반으로 하며 combat, upgrade, visuals를 보유한다.
- TowerRuntimeState는 TowerDefinition을 참조하고 effective_combat을 Runtime 상태로 복사한다.
- TowerRuntimeState는 get_weapon_definition()을 통해 WeaponDefinition을 생성한다.
- GameController는 Tower Catalog를 TowerDefinition으로 로드하고, Map의 pre-placed tower slot 및 런타임 배치에서 TowerRuntimeState를 생성한다.
- update_towers()는 TowerRuntimeState의 WeaponDefinition을 사용해 target을 탐색하고 weapon_fired GameplayEvent를 발생시킨다.
- Tower 업그레이드는 TowerRuntimeState.effective_combat에 적용되며 현재 LV2까지 지원한다.
- Map은 tower_placement_area / tower_placement_point를 통해 Tower 배치 공간을 소유한다.
- Stage는 map_file을 통해 Map을 참조한다.
- Base는 독립 BaseDefinition 또는 BaseRuntimeState가 현재 존재하지 않는다.
- Stage balance의 base_hp가 초기 Base HP를 제공하고 GameController의 base_hp가 mutable Runtime 상태를 보유한다.
- Base 위치는 Map의 goal 데이터로 표현된다.

JUDGMENT:
- Tower의 Definition → Runtime 소비 경로는 현재 기능적으로 존재한다.
- Tower를 즉시 새로운 Building 공통 모델로 이관할 필요는 확인되지 않았다.
- Base는 현재 Stage balance + Map goal + GameController base_hp로 분산되어 있어 Tower와 동일한 Definition 구조가 아니다.
- Tower/Base를 공통 Building Definition으로 통합하면 데이터 소유권과 Runtime 구조를 함께 변경해야 하므로 현재 작업 범위를 넘어선다.
- 따라서 Building 공통 모델은 DESIGN HOLD로 유지한다.

UNVERIFIED:
- 향후 Support/Production/Resource Building이 실제로 필요한 경우 공통 필드의 최소 집합.
- Tower Editor와 향후 Building Editor의 실제 UI 통합 가치.
- Base를 독립 객체로 승격해야 할 Canon 요구.

NEXT CANDIDATE:
- Skill / Special / Finisher Definition → Runtime 소비 구조 READ-ONLY 조사.


### Phase D/B 조사 갱신 — Skill / Special / Finisher Definition → Runtime 소비 구조
STATUS: PASS / READ-ONLY INVESTIGATION COMPLETE / ACCEPT·STOP

CONFIRMED:
- Skill catalog는 res://content/skills/skills.json의 Dictionary 구조이며 SkillDefinitionLoader가 ContentCatalogLoader를 통해 로드한다.
- 현재 SkillDefinition 전용 Runtime class는 존재하지 않는다.
- skills.json에는 base_special, area_attack, heavy_pierce, finisher이 정의되어 있다.
- growth_available=true인 area_attack / heavy_pierce는 RobotProgressionState.unlocked_abilities를 통해 해금 상태가 저장된다.
- gameplay.json의 skill_slots가 슬롯 번호와 Skill ID를 연결한다. 현재 slot 1=area_attack, slot 2=heavy_pierce, slot 3=empty이다.
- GameController는 skill_slots → skills_catalog → RobotProgressionState.has_ability 순서로 Skill을 검증한 뒤 실행한다.
- area execution은 RobotRuntimeState.area를 cooldown으로 사용하고, target_pierce execution은 RobotRuntimeState.pierce를 cooldown으로 사용한다.
- 실행 중에는 RobotRuntimeState.special / special_type으로 현재 Skill/Special 연출 상태를 표현한다.
- 실제 피해 효과는 현재 Skill별 Dictionary effect를 생성해 GameController의 effect 처리 경로에서 소비한다.
- BASE SPECIAL은 skills_catalog의 base_special 데이터를 직접 소비하며 별도 해금 없이 사용한다.
- FINISHER는 skills_catalog의 finisher 데이터를 직접 소비하며 RobotRuntimeState.finisher meter를 사용한다. 충전량은 일반 적/giant 적 처치 시 finisher_definition의 charge 값을 사용한다.
- Content Validator는 Skill ID, growth_available, execution_type, execution_type별 필수 필드, 음수 값, gameplay skill slot 참조를 검증한다.
- Robot Editor는 Robot의 skill1/2/3/special/finisher 시각 Asset을 관리하지만 Skill gameplay 수치 자체를 편집하는 별도 Skill Editor는 현재 존재하지 않는다.

JUDGMENT:
- 현재 Skill 시스템은 Dictionary catalog + RobotProgressionState + RobotRuntimeState의 조합으로 목적에 필요한 소비 경로가 이미 완성되어 있다.
- Skill마다 영속적인 독립 Runtime 객체가 필요하지 않다. 현재 필요한 Runtime 상태는 RobotRuntimeState가 소유하고 있으며 효과 실행은 GameController effect 경로가 담당한다.
- Finisher와 Base Special은 일반 성장 Skill과 실행 방식이 다르지만 현재 데이터 소비 경로 자체는 정상적으로 분리되어 있다.
- 별도 SkillDefinition class 또는 SkillRuntimeState를 지금 도입하면 목적 대비 구조 변경 비용이 크다.
- 별도 Skill Editor도 현재 Canon/요구사항이 없으므로 구현하지 않는다.
- 현재 조사 목적은 충족되었으므로 ACCEPT·STOP.

UNVERIFIED:
- 실제 PIE에서 각 Skill의 시각 Asset과 gameplay effect의 1:1 매핑.
- Skill Editor가 향후 필요할지 여부.
- 향후 Skill execution_type 종류가 증가할 경우 현재 GameController 분기 구조가 충분한지 여부.

OUT OF SCOPE:
- Skill Editor 신규 구현
- SkillDefinition/SkillRuntimeState 신규 class 도입
- execution_type 확장 또는 GameController 구조 개편
- PIE 검증

NEXT CANDIDATE:
- Enemy / Allied Unit / Tower의 공통 ObjectDefinition 소비 규칙과 Validator 기준의 일관성 READ-ONLY 조사.

### Phase E 조사 갱신 — Enemy / Allied Unit / Tower 공통 ObjectDefinition 소비 규칙 및 Validator 일관성
STATUS: PASS / READ-ONLY INVESTIGATION COMPLETE / DESIGN HOLD

BASELINE:
- HEAD: 735b42f01daefa0ef0ff8ad9810620b80fecb2b0
- Branch: main
- Working Tree: clean at investigation start
- Godot: 4.7.2.stable.official.ed1daf0bf

CONFIRMED:
- ObjectDefinition은 id, name, combat, weapon_refs, skill_refs, visual_refs, specialized를 공통 기반으로 제공한다.
- EnemyDefinition, AlliedUnitDefinition, TowerDefinition은 ObjectDefinition을 상속한다.
- AlliedUnitDefinition / EnemyDefinition / TowerDefinition 모두 Catalog Dictionary를 전용 Definition으로 변환하는 from_catalog 경로를 가진다.
- ObjectRepository는 Robot / Allied Unit / Enemy / Tower에 대해 동일한 Repository 진입점을 제공하며 Catalog 로드도 공통 ContentCatalogLoader를 사용한다.
- GameController는 AlliedUnitDefinition / EnemyDefinition / TowerDefinition을 각각 Runtime State 생성 및 전투 처리에 소비한다.
- AlliedUnitRuntimeState와 TowerRuntimeState는 Definition을 보유한다.
- Enemy는 GameController의 enemy_definitions에서 EnemyDefinition을 소비한다.
- 현재 Validator는 ENEMY / ALLIED_UNIT / TOWER / ROBOT Catalog를 공통 _validate_catalog() 함수로 검사하지만 타입별 required field 목록은 개별적으로 하드코딩한다.
- Validator의 Visual Asset 참조 검사는 별도의 공통 _validate_catalog_visual_refs() 경로를 사용한다.
- 현재 EnemyDefinition은 catalog의 attack/robot_attack/visual 값을 전용 Dictionary로 변환한다.
- 현재 AlliedUnitDefinition은 combat/ai/visuals를 분리하고 WeaponDefinition을 생성한다.
- 현재 TowerDefinition은 combat/upgrade/visuals를 분리하지만 현재 catalog에 존재하는 animations/default_image/projectile_frames/sprite_frames 일부는 Definition에서 직접 소비하지 않는다.
- 현재 Allied Unit catalog에는 visuals.default_image / visuals.sprite / visuals.animations 구조가 존재하며, Tower catalog에는 animations/default_image/projectile_anim/sprite_anim 및 frame count 필드가 혼재한다.
- 현재 Enemy catalog에는 sprite_anim 기반 legacy visual field와 enemy 전용 robot attack 값이 함께 존재한다.
- Godot 4.7.2 headless editor project load는 exit code 0으로 확인했다.
- git diff --check PASS.

JUDGMENT:
- 공통 ObjectDefinition + 전용 Definition + ObjectRepository 구조 자체는 현재 Master 승인 Composition Canon과 양립한다.
- 현재 단계에서 Enemy / Allied Unit / Tower의 Definition을 하나의 거대한 공통 Definition으로 합칠 필요는 없다.
- 반면 Visual Asset 소비 필드가 타입별로 완전히 동일한 계약을 사용하고 있지는 않으며, Validator도 Legacy/신규 필드가 혼재된 상태를 허용한다.
- 특히 Tower의 animations/default_image와 기존 sprite_anim/projectile_anim, Allied Unit의 visuals 구조, Enemy의 sprite_anim 구조 사이에는 명시적인 공통 Visual Asset Contract가 아직 확정되지 않았다.
- 이 상태에서 공통 Validator 또는 Definition 구조를 성급하게 통합하면 현재 Asset Migration과 충돌할 가능성이 있다.
- 따라서 현재 목적에서는 구현 변경을 하지 않고 DESIGN HOLD가 타당하다.

UNVERIFIED:
- Tower / Enemy / Allied Unit의 최종 Visual Asset Schema를 하나로 통일할 Canon 요구.
- 각 타입의 legacy visual field 제거 시점.
- 현재 모든 Runtime Render 경로가 VisualAssetResolver를 통해 동일하게 소비되는지에 대한 PIE 검증.
- Validator를 Definition 기반으로 전환할 경우 실제 migration 비용.

OUT OF SCOPE:
- Enemy / Allied Unit / Tower Definition 구조 개편
- Legacy Visual field 일괄 제거
- Validator 공통 Schema 재작성
- SQLite Migration
- PIE 검증

NEXT CANDIDATE:
- Visual Asset Contract의 Enemy / Allied Unit / Tower 실제 소비 경로 READ-ONLY 조사.


### Phase E 조사 갱신 — Visual Asset Contract 실제 소비 경로
STATUS: PASS / READ-ONLY INVESTIGATION COMPLETE / DESIGN HOLD

조사 목적:
- Enemy / Allied Unit / Tower가 현재 Runtime에서 Visual Asset을 실제로 어떻게 소비하는지 확인한다.

기준선:
- 기존 Working Tree 변경은 보존.
- 코드/Asset 변경 없음.
- 조사 범위는 VisualAssetResolver, Definition 변환, GameController Runtime 소비, 관련 Editor 경로.

CONFIRMED:
- VisualAssetResolver는 asset id를 VisualAssetRepository에서 조회하고, 조회 실패 시 legacy source를 VisualAssetDefinition으로 감싼다.
- VisualAssetDefinition은 source, region, frames, columns, rows, frame_order, anchor, owner, usage, frame_regions를 공통으로 표현할 수 있다.
- Allied Unit은 Catalog의 `visuals` Dictionary를 AlliedUnitDefinition.visuals로 그대로 전달한다. Runtime의 _load_allied_unit_catalog는 해당 visuals의 default_image를 우선, sprite를 fallback으로 _texture_from_catalog_entry에 전달한다.
- Enemy는 EnemyDefinition.visuals에 `sprite_anim`을 별도 보관하지만 Runtime의 enemy_sprite_catalog 생성은 EnemyDefinition.visuals가 아니라 원본 enemy_catalog의 `sprite_anim`을 직접 읽는다.
- Tower도 TowerDefinition.visuals에 `sprite_anim`과 `projectile_anim`을 보관하지만 Runtime의 tower_sprite_catalog 생성은 TowerDefinition이 아니라 원본 tower_catalog의 `sprite_anim`을 직접 읽는다.
- Robot은 별도 경로에서 Animation 값 → VisualAssetResolver → frame region으로 연결되는 소비 경로가 이미 비교적 직접적으로 구현되어 있다.
- Enemy / Tower의 Runtime Texture 생성은 공통 `_texture_from_catalog_entry`를 사용하고 내부에서 VisualAssetResolver를 호출하므로 Resolver 자체는 사용한다. 그러나 Definition → Runtime의 단일 계약으로 통일되어 있지는 않다.
- Unit Editor는 Enemy를 Unit 목록에 합쳐 보여주기 위해 Enemy의 `sprite_anim`을 `visuals.sprite`와 `visuals.default_image`로 임시 매핑한다. 이는 Editor 호환 계층이며 Enemy Catalog 원본 스키마 자체가 변경된 것은 아니다.
- ContentValidator는 Enemy/Tower에 여전히 `sprite_anim`을 required field로 요구하고 있으며, Visual reference validation도 Enemy/Tower의 legacy field를 기준으로 수행한다.

INFERENCE:
- 현재 시스템은 VisualAssetResolver를 공통 인프라로 사용하지만, ObjectDefinition을 통한 공통 Visual Asset Contract는 아직 완성되지 않았다.
- Allied Unit은 신형 `visuals` 구조에 가장 가깝고, Enemy/Tower는 legacy top-level visual field를 유지한 채 Resolver를 중간에서 사용하는 과도기 구조로 판단된다.
- 따라서 지금 단계에서 세 타입의 Catalog Schema를 강제로 하나로 합치는 것은 Asset Migration 작업과 충돌할 가능성이 높다.

마리의 판정:
- ObjectDefinition 구조를 변경하지 않는다.
- VisualAssetResolver / VisualAssetDefinition도 현재 목적상 재작성하지 않는다.
- 다음 실제 개발 후보는 Enemy/Tower의 legacy visual field를 제거하는 것이 아니라, 먼저 Editor와 Runtime에서 Definition.visuals를 단일 소비 경로로 사용할 수 있는지 검증하는 것이다.
- 이는 Schema Canon을 새로 결정하는 변경이므로 Master 승인 없이 구현하지 않는다.

UNVERIFIED:
- 실제 PIE에서 Enemy / Allied Unit / Tower 각각의 Sprite Sheet frame 및 anchor가 의도대로 표시되는지.
- Enemy/Tower의 Definition.visuals로 전환했을 때 기존 Runtime 동작을 완전히 보존할 수 있는지.
- 최종 Catalog Visual Asset Contract의 Canon.

OUT OF SCOPE:
- Catalog Schema 강제 통합
- legacy field 삭제
- Definition 구조 변경
- Validator 재작성
- PIE 검증

NEXT CANDIDATE:
- Master가 Visual Asset Contract의 통일 방향을 승인하면 최소 1개 타입(Enemy 또는 Tower)을 기준으로 Definition.visuals → Runtime 단일 소비 PoC를 수행한다.

### Phase E 조사 갱신 — Faction과 Alignment 분리 및 Object 진영 소비 경로
STATUS: PASS / READ-ONLY INVESTIGATION COMPLETE / DESIGN HOLD

조사 목적:
- Robot / Unit / Tower / Enemy 모두가 Faction에 소속될 수 있다는 기준을 확인하고, Faction과 적/동맹 Alignment가 기존 코드에서 분리되어 있는지 확인한다.

CONFIRMED:
- ObjectDefinition 현재 공통 필드는 id, name, combat, weapon_refs, skill_refs, visual_refs, specialized이며 faction 필드는 없다.
- AlliedUnitDefinition, TowerDefinition, RobotDefinition, EnemyDefinition 모두 현재 Catalog에서 명시적인 faction 필드를 읽지 않는다.
- Robot에는 color와 team_color Shader 적용 및 Asura용 team_mask 경로가 존재한다. 이는 현재 시각적 팀 표현 경로이지, 공통 Faction 식별자 계약으로 확인되지는 않았다.
- Allied Unit도 Runtime에서 ALLIED_UNIT_COLOR_SHADER에 team_color를 전달하는 경로가 존재한다. 현재 Catalog에는 명시적인 Faction 식별자가 없다.
- Map Editor에는 multiplayer의 alliances와 relations 데이터 구조가 존재하며 enemy, third 등의 전투 관계/세력 구성이 표현된다. 이것은 Object Catalog의 Faction 필드와는 별도 계층이다.
- alignment라는 명시적 Object Definition 필드는 확인되지 않았다.
- Enemy Catalog은 legacy 구조이며 현재 sprite_anim 중심이다. Enemy를 Faction 구조의 기준 구현으로 삼지 않는다.
- Tower Catalog에는 현재 sprite_anim이 있지만 Faction 정보는 없다.
- Robot Catalog에도 현재 Faction 정보는 없으며 Visual은 Animation/Color/Team Mask 경로로 구성되어 있다.

INFERENCE:
- 현재 team_color는 Faction 자체라기보다 Faction에 의해 결정될 수 있는 시각 표현 수단으로 보는 것이 안전하다.
- Faction은 적/동맹(Alignment)과 동일 개념으로 취급하면 안 된다.
- 최종 구조에서는 Robot / Unit / Tower / Enemy 모두 Object의 소속 정보로 Faction을 가질 수 있고, Alignment는 전투 관계로 별도 취급해야 한다.
- Visual Asset 선택/적용은 Object의 Faction을 입력으로 사용할 수 있어야 하며, Faction과 Visual Asset의 관계를 Runtime의 단순 색상 Shader로 한정해서는 안 된다.

마리의 판정:
- 현재 코드에는 공통 Faction Contract가 아직 없다.
- Allied Unit이 신형 Visual 구조의 기준이라는 기존 판단은 유지한다.
- Robot / Unit / Tower / Enemy 모두 Faction을 가질 수 있다는 기준으로 Visual Asset Contract를 설계해야 한다.
- team_color, team_mask, alliances, relations를 곧바로 Faction Canon으로 승격하지 않는다.
- Faction 필드명, 저장 위치, Faction→Visual Asset 선택 규칙은 Master 승인 전까지 DESIGN HOLD로 둔다.

UNVERIFIED:
- 프로젝트에서 최종적으로 사용할 Faction 식별자와 Catalog 저장 위치.
- 하나의 Object가 여러 Faction Visual을 가질 경우의 선택 규칙.
- Faction과 Map의 alliances/relations가 Runtime에서 어떤 방식으로 연결되어야 하는지.

OUT OF SCOPE:
- Faction Schema 구현
- Alignment 시스템 구현
- 기존 Catalog 일괄 migration
- Visual Asset Resolver 재작성
- PIE 검증

NEXT CANDIDATE:
- Faction의 데이터 소유 위치와 Visual Asset 선택 관계에 대한 최소 설계안을 작성하고 Master 승인 여부를 확인한다.


### Phase E 설계 갱신 — Faction 독립 관리와 Object 소속 관리
STATUS: PROPOSAL / DESIGN HOLD

설계 목적:
- Faction을 Robot / Unit / Tower 등의 단순 속성값이 아니라 독립적으로 관리되는 프로젝트 데이터로 정의한다.
- Faction 자체의 관리와 Object의 Faction 소속 관리를 분리한다.
- 적/동맹은 Faction의 속성이 아니라 플레이 중 형성되는 관계(Alignment)로 분리한다.

PROPOSAL:
- Faction은 독립 Catalog/Definition 대상이 된다.
- Faction 자체를 생성·수정·삭제·조회할 수 있는 Faction Editor가 필요하다.
- Robot / Unit / Tower는 각 Object Editor에서 자신이 소속될 Faction을 선택·관리한다.
- Object는 Faction의 정의 정보를 중복 저장하지 않고 Faction 식별자를 통해 소속을 참조한다.
- Faction 자체의 데이터와 Faction에 소속된 Object 목록은 서로 다른 관리 관점으로 취급한다.
- Enemy 역시 구조적으로 Faction에 소속될 수 있으나, 기존 Enemy legacy 구조를 이 설계의 선행 구현 기준으로 삼지 않는다.
- Alignment(적/동맹/중립 등)는 Object 또는 Faction의 고정 소속 정보가 아니라 플레이 시점의 관계 데이터로 별도 관리한다.
- 따라서 Faction Editor는 '진영 자체 관리'를 담당하고, Object Editor는 '진영 소속 관리'를 담당한다.

EDITOR STRUCTURE:
- Faction Editor: Faction 정의와 Faction 자체의 관리
- Robot Editor: Robot의 Faction 소속 선택/표시
- Unit Editor: Unit의 Faction 소속 선택/표시
- Tower Editor: Tower의 Faction 소속 선택/표시
- Enemy Editor: 향후 Faction 소속 지원 대상이 될 수 있으나 기존 legacy 구조와의 충돌 여부를 먼저 확인한다.

INFERENCE:
- Faction Editor와 기존 Catalog Editor의 공통 UI/Repository 패턴을 재사용할 가능성이 높다.
- Faction Editor가 관리하는 데이터와 Object Editor가 참조하는 소속 데이터는 동일 Catalog를 공유하되, 편집 책임은 분리하는 구조가 적절하다.

마리의 판정:
- Faction을 독립 관리 대상으로 개발계획에 반영한다.
- Faction Editor를 별도 개발 대상으로 명시한다.
- Object Editor의 Faction 선택 기능을 별도 작업 대상으로 명시한다.
- Alignment는 Faction Editor에 포함시키지 않고 플레이 관계 계층으로 분리한다.
- 아직 Faction Schema, 저장 경로, 구체 필드명, Editor 구현 방식은 Canon으로 확정하지 않는다.

UNVERIFIED:
- 최종 Faction Catalog 저장 위치와 Schema
- Faction Editor의 기존 Editor Framework 재사용 범위
- Object별 Faction 참조 필드명
- Runtime에서 Faction 관계를 Alignment로 변환/조회하는 구체 경로

OUT OF SCOPE:
- Faction Editor 구현
- Object Editor의 Faction 필드 구현
- Alignment Runtime 구현
- 기존 Catalog migration
- Visual Asset Resolver 변경
- PIE 검증

NEXT CANDIDATE:
- 기존 Editor/Catalog 구조를 조사하여 Faction Editor를 추가할 최소 구현 위치와 공통 컴포넌트 재사용 범위를 결정한다. Master 승인 전에는 구현하지 않는다.


### Phase E 정정 — Content Editor 연결
- Faction Editor는 독립 상위 시스템이 아니라 기존 Content Editor의 하위 콘텐츠 편집기로 연결한다.
- Content Editor가 Faction Catalog의 상위 관리 진입점이 된다.
- Faction Editor는 진영 자체를 관리한다.
- Robot / Unit / Tower / Enemy Editor는 Content Editor가 관리하는 Faction Catalog를 참조하여 Object의 소속을 관리한다.
- Object Editor에 Faction 데이터를 별도로 복제하지 않는다.
- 따라서 향후 Faction Editor 구현은 기존 Content Editor의 Editor 등록/탭/선택 구조를 우선 조사하고 그 체계 안에서 구현한다.


### Phase E 정정 — Content Editor 상단 메뉴 연결
- Faction Editor는 Content Editor의 상단 메뉴에 정식 콘텐츠 항목으로 노출한다.
- Content Editor 상단 메뉴의 Faction 항목을 선택하면 Faction Editor로 진입한다.
- Faction은 기존 Robot / Unit / Tower / Enemy와 동일한 Content Editor 메뉴 계층에서 관리한다.
- Faction Editor는 진영 자체를 관리하고, 각 Object Editor는 Faction 메뉴에서 관리되는 Catalog를 참조하여 소속을 관리한다.
- 실제 메뉴 등록 위치와 UI 구현 방식은 기존 Content Editor 구조 조사 후 결정한다.


### Phase E 조사 갱신 — Content Editor Faction 메뉴 연결 지점
STATUS: PASS / READ-ONLY INVESTIGATION COMPLETE / IMPLEMENTATION HOLD

조사 범위:
- 현재 Content Editor의 상단 메뉴 구성과 Editor Scene 전환 구조를 확인했다.

CONFIRMED:
- Content Editor의 상단 메뉴는 editor/content_editor.tscn의 MainLayout/TopMenu/Buttons 아래 Button 노드들로 구성되어 있다.
- 현재 상단 메뉴에는 맵, 스테이지, 로봇, 유닛, 타워, 카다로그, 종료 버튼이 존재한다.
- Content Editor의 content_editor.gd가 각 상단 버튼의 pressed signal을 연결하고 Editor Scene을 교체하는 중앙 진입점 역할을 한다.
- Robot / Unit / Tower는 각각 별도 Scene 경로 상수와 열기 함수가 이미 존재한다.
- Faction은 현재 메뉴와 Scene 경로에 존재하지 않는다.
- 현재 Content Editor 상단 메뉴에는 별도의 Enemy Editor 버튼이 없다. Enemy는 기존 구조상 Unit Editor 및 기타 legacy 경로와 연관되어 있으므로 이번 Faction 메뉴 추가의 직접 대상에서 분리한다.

INFERENCE:
- Faction Editor는 현재 Content Editor의 상단 메뉴 Button을 하나 추가하고, content_editor.gd에 Faction Scene 경로와 열기 함수를 연결하는 방식이 기존 구조와 가장 직접적으로 일치한다.
- 별도 최상위 Editor 런처를 만들 필요가 없다.
- Faction Editor는 기존 Content Editor의 content_host에 다른 Editor와 동일한 방식으로 인스턴스화하는 것이 적절하다.

마리의 판정:
- Faction의 UI 진입점은 Content Editor 상단 메뉴로 확정 가능한 수준의 근거를 확보했다.
- 구현 위치는 content_editor.tscn + content_editor.gd가 최소 변경 지점이다.
- 아직 Faction Editor Scene 자체와 Faction Catalog Schema가 없으므로 메뉴만 먼저 구현하는 것은 기능 완성으로 간주하지 않는다.
- Faction Editor의 실제 구현은 Faction Catalog/Definition 설계가 확정된 후 진행한다.

UNVERIFIED:
- Faction Editor의 최종 Scene 이름과 Catalog 저장 경로
- Faction Editor가 재사용할 기존 Catalog Editor UI 컴포넌트 범위
- Faction Object 목록을 Faction Editor에서 어떤 형태로 표시할지

OUT OF SCOPE:
- Content Editor 메뉴 실제 수정
- Faction Editor Scene 생성
- Faction Catalog 구현
- Object Editor Faction 필드 구현
- Alignment Runtime 구현
- PIE 검증

NEXT CANDIDATE:
- 기존 Catalog Editor의 목록/상세/등록/삭제 패턴을 조사하여 Faction Editor의 최소 화면과 Object 소속 목록 표시 방식을 결정한다.


### Phase E 조사 갱신 — Faction Editor 최소 UI 설계
STATUS: PASS / DESIGN PROPOSAL / IMPLEMENTATION HOLD

CONFIRMED:
- 기존 Asset Catalog Editor는 목록, 검색, 선택, 상세 편집, 추가/수정/삭제, 저장의 공통 Editor 패턴을 제공한다.
- 목록에는 ID, 이름/이미지, 사용 여부를 표시하는 구조가 이미 존재한다.
- Visual Asset은 별도 Repository를 연동하면서 Catalog UI 패턴을 사용한다.

PROPOSAL:
- Faction Editor는 Asset Catalog Editor를 그대로 복제하지 않고 기존 Catalog Editor의 목록/상세/저장 패턴만 재사용한다.
- 최소 화면은 다음으로 구성한다.
  1. Faction 목록: ID / 이름 / 사용 여부
  2. Faction 상세: ID / 이름 / 설명 및 확정된 Faction 메타데이터
  3. 작업 버튼: 추가 / 수정 / 삭제 / 저장
- Faction 선택 후 Object 소속 현황을 표시하는 영역은 향후 faction_id 계약이 확정되면 추가한다.

UNVERIFIED:
- Faction의 최종 Schema와 필드
- Faction Catalog 저장 경로
- Faction 대표 이미지/색상 등의 메타데이터 필요 여부
- Object별 Faction 소속 현황 표시 방식

판정:
- 현재 단계에서 Faction Editor의 UI 구현을 시작하지 않는다.
- 다음 설계 단계는 기존 Object Catalog의 데이터 저장 패턴을 조사하여 FactionDefinition / FactionRepository / Faction Catalog의 최소 계약을 확정하는 것이다.

### Phase E 설계 갱신 — Faction 최소 데이터 계약
STATUS: PASS / DESIGN PROPOSAL / IMPLEMENTATION HOLD

조사 결과:
- 현재 ObjectRepository는 Object 종류별 JSON Catalog를 별도 경로로 관리하고 ContentCatalogLoader로 Dictionary Catalog를 읽는다.
- 각 Object Definition은 별도 클래스로 변환된다. 공통 ObjectDefinition을 사용하되 Robot/Unit/Tower/Enemy의 전문 데이터는 각각 분리되어 있다.
- ObjectPersistence는 Dictionary Catalog를 JSON으로 저장하고 저장 직후 파일 내용을 재검증한다.
- 따라서 Faction도 기존 Object Catalog에 억지로 포함시키기보다 독립 Catalog + 독립 Definition + 독립 Repository를 두는 것이 현재 구조와 일치한다.

PROPOSAL — 최소 Faction 계약:
- Catalog 경로 후보: res://content/factions/factions.json
- Catalog 형태: 최상위 Dictionary, key는 faction_id, value는 Faction 데이터 Dictionary
- 최소 필드 후보: id: String, name: String
- FactionDefinition은 ObjectDefinition을 상속하지 않는 독립 RefCounted Definition을 우선 제안한다. Faction은 Robot/Unit/Tower/Enemy 같은 Object가 아니기 때문이다.
- FactionRepository는 load/reload, get_faction(faction_id), list_factions(), exists(faction_id)를 제공하는 구조를 제안한다.
- Faction Catalog 저장은 ObjectPersistence.save_catalog()를 재사용한다.

설계 원칙:
- Faction은 Object Catalog의 한 종류가 아니다.
- Object의 faction_id는 Faction Catalog의 ID를 참조하는 관계 데이터로 취급한다.
- Alignment는 Faction Definition의 필드로 넣지 않는다. Faction 간 전투 관계는 별도 개념으로 유지한다.
- team_color / team_mask / map alliances / relations를 Faction 필드로 승격하지 않는다.

UNVERIFIED:
- name 외에 description, display_name, color, icon 등의 Faction 메타데이터가 실제 필요할지
- Faction ID의 최종 naming convention
- faction_id를 어떤 Object Catalog부터 적용할지

판정:
- Faction의 최소 기술 계약은 독립 Catalog + Definition + Repository로 잡을 수 있다.
- Master 승인 없이 코드/Asset 생성은 하지 않는다.
- 다음 단계에서는 현재 Object Editor들이 Catalog를 읽고 저장하는 실제 패턴을 조사하여 faction_id를 연결할 최소 변경 지점을 확인한다.


### Phase E 실행 — Robot Faction 1차 연결
STATUS: PASS / CODE VERIFIED / BUILD-LIKE SCRIPT LOAD VERIFIED

Master가 1차 적용 대상으로 Robot을 지정함.

실제 변경:
- `godot/scripts/faction_definition.gd` 추가 — 최소 `id`, `name` Definition
- `godot/scripts/faction_repository.gd` 추가 — 독립 Faction Catalog 로드 및 조회
- `godot/content/factions/factions.json` 추가 — 현재 빈 Catalog `{}`
- `godot/editor/robot_editor.gd` — Faction 선택 UI, 로드/저장 연결, 신규 Robot 기본 빈 faction_id
- `godot/scripts/robot_definition.gd` — faction_id 전달

검증:
- 최초 Headless Editor 로드에서 FactionRepository의 `load()` 이름 충돌을 확인하고 `load_catalog()`로 수정함.
- 수정 후 Headless Editor 로드에서 FactionDefinition / FactionRepository / RobotDefinition / RobotEditor 등록 완료.
- 최종 Headless Editor 로드에서 추가 Parse Error는 확인되지 않음.
- `git diff --check`는 기존 계획 문서의 CRLF 경고 외 오류 없음.

LIMITATION / UNVERIFIED:
- factions.json이 비어 있어 실제 Faction 선택값을 Robot에 지정하는 데이터 검증은 아직 불가.
- Robot Editor 실제 화면 조작은 아직 수행하지 않음.
- PIE VERIFIED 아님.
- Faction Editor는 아직 구현하지 않음.

판정:
- Robot이 독립 Faction Catalog를 참조할 최소 코드 경로는 성립했다.
- 임의 Faction을 생성하지 않아 Canon을 추가하지 않았다.
- 다음 단계는 자동 진행하지 않는다.


### Gameplay Scope Lock — 2026-10-05
Master 결정에 따라 MENOS의 Gameplay는 다음 3개만 대상으로 한다.
1. Tower Defense
2. LoL 스타일 섬멸전
3. 거대 보스전

운영 원칙:
- Faction은 세 Gameplay 모두에서 Object의 소속/정체성을 표현한다.
- Faction과 Alignment는 분리한다.
- 위 3개와 직접 관계없는 Gameplay Mode/Rule은 현재 범위에서 추가하지 않는다.
- 이 결정은 Gameplay Scope이며 기존 Object/Faction Canon을 임의로 변경하지 않는다.


### Gameplay Scope 기반 조사 — Tower / Skill / Weapon
STATUS: READ-ONLY INVESTIGATION COMPLETE / NO CODE CHANGE

BASELINE:
- HEAD: 735b42f01daefa0ef0ff8ad9810620b80fecb2b0
- Branch: main
- Working Tree: 기존 변경사항 유지 상태에서 조사
- git diff --check: 기존 plan 문서의 LF→CRLF warning 외 오류 없음

CONFIRMED — Tower:
- TowerDefinition이 ObjectDefinition을 상속하며 combat / upgrade / visuals를 별도 보유한다.
- TowerRepository 역할은 현재 ObjectRepository 내부의 tower catalog 경로로 수행된다.
- TowerRuntimeState가 TowerDefinition을 참조하고 effective_combat을 생성한다.
- TowerRuntimeState.get_weapon_definition()이 현재 Tower의 combat 값을 WeaponDefinition으로 변환한다.
- GameController.update_towers()가 TowerRuntimeState의 WeaponDefinition으로 자동 타깃/공격을 수행한다.
- Tower 배치/업그레이드 Runtime 경로가 GameController에 존재한다.

CONFIRMED — Skill:
- 독립 Skill Catalog `content/skills/skills.json`과 SkillDefinitionLoader가 존재한다.
- 현재 Skill Definition은 별도 RefCounted Definition 객체가 아니라 Dictionary로 직접 소비된다.
- GameController가 Skill Catalog를 로드하고 base_special / finisher / 성장 Skill을 직접 참조한다.
- Robot Skill 실행, 성장 선택, Finisher 실행이 GameController에 직접 구현되어 있다.

CONFIRMED — Weapon:
- WeaponDefinition은 독립 RefCounted Definition으로 존재한다.
- Robot / Enemy / Allied Unit / Tower Runtime이 각각 자신의 데이터에서 WeaponDefinition을 생성한다.
- 현재 Weapon은 독립 Catalog보다 Actor/Runtime 데이터에서 파생되는 구조다.

IMPORTANT FINDING:
- Tower Defense에 필요한 최소 Tower Runtime 기반은 이미 존재한다. 현재 즉시 Building 공통 모델이나 별도 Weapon Editor를 추가해야 할 근거는 없다.
- Skill은 Catalog는 독립되어 있으나 Definition 객체화 없이 GameController가 Dictionary를 직접 소비한다. 이는 향후 Skill 확장 시 조사 대상이지만 현재 3 Gameplay Scope를 충족시키는 데 즉시 결함으로 판정하지 않는다.
- 현재 Tower Catalog의 실제 항목은 `rail`이며 GameController의 일부 시각/표현 경로에는 `cannon` / `gatling` 고정 분기가 남아 있다. 이것은 현재 조사에서 확인된 구조적 불일치 가능성이며, 실제 Runtime 영향은 아직 검증하지 않았다.

JUDGMENT:
- Tower Defense 핵심 기반은 이미 존재한다.
- LoL 스타일 섬멸전은 Robot/Unit/Enemy + Weapon/Skill Runtime 기반을 활용할 수 있다.
- 거대 보스전은 기존 GIANT Runtime 기반이 있으나 Boss 공통화는 별도 Canon/콘텐츠 요구가 있을 때 판단한다.
- 다음 구현은 새 공통 시스템을 만드는 것보다 현재 3 Gameplay에서 실제로 막히는 Runtime/Editor 연결을 하나씩 확인하는 방식이 적절하다.

VERIFICATION:
- CODE VERIFIED — 위 구조 직접 확인
- BUILD VERIFIED — 이번 조사에서는 수행하지 않음
- EDITOR VERIFIED — 이번 조사에서는 수행하지 않음
- PIE VERIFIED — 미수행

OUT OF SCOPE:
- Building 공통 Definition 신규 구현
- SkillDefinition 신규 구현
- Weapon Editor 신규 구현
- Tower Catalog 일괄 수정
- Gameplay Mode 추가


### Gameplay Mode 구조 점검 — 2026-10-05
STATUS: HOLD / DESIGN-CANON 필요

CONFIRMED:
- 현재 StageManager의 runtime mode는 기본값 `campaign`이며 `begin_run(mode, stage_id)`로 문자열을 전달한다.
- GameController는 `campaign` / `single`을 여러 경로에서 특별 취급한다.
- `map_01.json`의 `play_modes`에는 현재 `campaign`, `single`, `multiplayer`가 기록되어 있다.
- MissionDefinition의 `primary_type`은 현재 `clear_encounters` 중심이며, 코드에는 `defend_base` 판정이 존재한다.
- Giant Boss Runtime은 `enemy.type == "giant"` 조건으로 별도 공격 패턴을 실행한다.

판정:
- Master가 Gameplay를 3개(Tower Defense / LoL 스타일 섬멸전 / 거대 보스전)로 고정했으므로, 현재 `campaign / single / multiplayer`라는 기존 mode 명칭을 그대로 새 Gameplay Canon으로 승격하면 안 된다.
- `multiplayer`는 현재 Master가 확정한 3 Gameplay 중 하나가 아니므로 Gameplay Mode Canon으로 사용하지 않는다.
- 기존 코드의 campaign/single은 Legacy/현재 Runtime 진입 방식일 가능성이 있으나, 실제 대체 명칭과 stage 진입 구조는 아직 결정되지 않았다.

HOLD 사유:
- 3 Gameplay를 기존 Stage/Run 구조에 어떤 식으로 매핑할지 Master의 Canon 결정이 필요하다.
- 특히 `Tower Defense`, `Elimination`, `Giant Boss Battle`을 run_mode 문자열로 직접 만들지, Stage가 gameplay_type을 가지게 할지 아직 결정하지 않았다.

OUT OF SCOPE:
- 기존 mode 문자열 임의 변경
- multiplayer 제거/구현
- Stage Catalog 구조 개편
- Gameplay Mode Editor 구현


## Mission 구조 조사 — 2026-10-05

STATUS — 조사 완료 / 다음 설계 판단 대기

- Master가 확정한 세 가지는 Gameplay Mode가 아니라 Mission의 종류다.
  - Tower Defense
  - Elimination
  - Giant Boss Battle
- 현재 구조는 Stage가 `mission_id`로 Mission을 참조한다: Stage → Mission → Runtime.
- `MissionDefinition.primary_type`이 현재 Mission 종류를 표현하는 필드다.
- 현재 구현된 Mission type은 `defend_base`, `clear_encounters` 두 가지뿐이다.
- Stage Editor와 Validator도 위 두 값을 하드코딩하고 있다.
- Runtime에서 `defend_base`는 실제 제한시간 방어 판정까지 연결되어 있다. `clear_encounters`는 Encounter/Wave 전체 종료를 기본 클리어 조건으로 사용한다.
- Giant Boss Runtime은 별도로 존재하지만 현재 Mission type과 직접 연결된 구조라는 증거는 확인하지 못했다.
- Elimination에 해당하는 독립 Mission type 및 전용 승리 조건은 현재 확인되지 않았다.

판정:
- Mission을 현재 세 Gameplay 종류로 재정의하는 방향은 기존 Stage → Mission 구조와 자연스럽게 맞는다.
- 다만 기존 `defend_base` / `clear_encounters`를 즉시 삭제하거나 새 문자열로 일괄 치환하면 Runtime 호환성 변경이 발생한다.
- 다음 구현 전에 각 Mission type의 최소 판정 조건을 Master Canon으로 확정해야 한다.
- 특히 Giant Boss Battle의 승리 조건과 Elimination의 승리/패배 조건은 현재 코드에서 독립적인 Mission 계약으로 확인되지 않았다.

검증 상태:
- CODE VERIFIED — MissionDefinition / Stage Editor / Validator / GameController 경로 직접 확인.
- BUILD VERIFIED — 이번 조사에서는 수행하지 않음.
- EDITOR VERIFIED — 실제 UI 조작은 수행하지 않음.
- PIE VERIFIED — 수행하지 않음.


## 2026-10-05 문서 재검토 및 현재 기준선 갱신

STATUS: ACCEPT·STOP / READ-ONLY REVIEW
목적: 기존 객체 중심 개발계획을 현재 실제 코드·콘텐츠 구조와 대조하고, 이미 확인된 Runtime/Editor/Validator 사실을 계획에 반영한다. 신규 구현은 수행하지 않는다.

### 현재 기준선
- HEAD: d783a8b394f2db53488e919dce4285ff5f3ed92c
- Branch: main
- Working Tree: 본 문서 갱신 전 기존 변경사항 존재. 기존 변경은 보존한다.

### CONFIRMED — Stage / Mission / Reward 구조
- Stage JSON은 stage_id, order, name, map_file, balance, mission_id, reward_id, encounters, allied_units를 사용한다.
- StageLoader와 StageManager를 통해 Map / Mission / Reward / Balance / Encounter가 Runtime으로 전달된다.
- Stage Editor Save는 Stage JSON과 Mission/Reward Catalog 참조를 함께 다룬다.
- Map 선택은 map_file 참조를 변경하며 Map Gameplay 데이터를 Stage에 복사하지 않는다.
- Mission과 Reward는 별도 Definition/Catalog를 유지하는 현재 구조가 객체 중심 계획과 일치한다.
- 현재 Mission Type UI는 defend_base, clear_encounters를 사용한다.
- Mission target_id는 저장/로드/편집되지만 현재 GameController의 승리 조건 판정에는 사용되지 않는다. 의미는 UNVERIFIED이며 Canon화하지 않는다.

### CONFIRMED — Runtime Mission
- defend_base: 지정된 방어 시간까지 생존하는 경로가 구현되어 있다.
- clear_encounters: 마지막 Encounter/Wave 종료 및 생존 적 소멸을 기준으로 완료하는 경로가 구현되어 있다.
- Base/HQ HP가 0 이하이면 Mission Type과 관계없이 DEFEAT가 발생한다.
- Giant은 별도 전투/HP/보상/Finisher Runtime이 있으나 Giant 처치가 독립적인 Mission 승리 조건으로 연결되었다는 근거는 확인되지 않았다.
- 따라서 Master Canon의 Tower Defense / Elimination / Giant Boss Battle과 현재 Runtime Mission Type은 아직 1:1 대응이 아니다.
- Giant Boss Battle의 독립 승리 계약은 HOLD이며 임의 구현하지 않는다.

### CONFIRMED — Allied Units
- StageLoader가 allied_units를 검증한다.
- GameController가 Stage의 Allied Units를 실제 Runtime 상태로 생성하고 배치/AI/렌더 경로에서 소비한다.
- 따라서 Allied Units는 dead configuration이 아니다.
- 현재 Stage Editor에는 Allied Units authoring UI가 없다. 이는 authoring gap이며 즉시 구현하지 않는다.

### CONFIRMED — Player Count / Play Mode
- Map의 play_modes와 StageManager의 campaign / single / multiplayer는 존재하지만 Player Count를 의미한다고 확인되지 않았다.
- 현재 코드에서 독립적인 player_count Canon/storage field는 확인되지 않았다.
- multiplayer를 Player Count 또는 Master의 3개 Gameplay Canon으로 임의 해석하지 않는다.
- Player Count의 Canon/storage 위치는 HOLD / UNVERIFIED.

### CONFIRMED — Encounter / Wave
- Stage Editor에서 Encounter, Wave, Enemy Group을 편집할 수 있다.
- StageLoader가 구조/타입을 검증하고 ContentValidator가 Enemy ID를 Enemy Catalog와 교차 검증한다.
- GameController가 Encounter/Wave를 spawn queue로 확장하여 Runtime에서 소비한다.
- 현재 구조는 Stage → Encounter → Wave → Enemy Group → Enemy Object의 조합 구조로 계획과 일치한다.

### CONFIRMED — Map Goal / Base
- MapLoader가 Map의 goal.position을 Runtime BASE 위치로 연결한다.
- Enemy가 Base에 도달하면 base_damage만큼 Base HP를 감소시키고 HP 0 이하에서 DEFEAT가 발생한다.
- gameplay_areas.goal_area는 별도 공간 데이터로 존재하지만 GameController의 실제 패배 판정은 goal.position 기반이다.
- 두 표현의 의미 중복 가능성은 존재하지만 현재 목적에 필요한 구조 변경 근거는 부족하다.

### CONFIRMED — Stage Cross-Reference Validator
- Stage mission_id → Mission Catalog 검증.
- Stage reward_id → Reward Catalog 검증.
- Stage map_file → 파일 존재 및 Map 구조 검증.
- Allied Unit ID/count/spawn을 검증.
- Encounter/Wave Enemy ID/count/interval/lanes 컨테이너를 검증.
- Map의 goal/spawn/robot spots/tower slots/tiles/objects/gameplay containers를 기본 검증한다.
- Reward item_ids는 실제 Item Catalog와 교차 검증된다.

### CONFIRMED GAP — Lane Semantics
- Stage Editor의 lane 값은 left, right, both를 사용한다.
- Map의 spawn area는 spawn_0, spawn_1 같은 ID를 사용한다.
- Runtime은 left/right를 동일한 의미의 spawn-area ID로 직접 연결하지 않으며 fallback 경로가 존재한다.
- both에 대한 전용 동시/분산 spawn 의미도 확인되지 않았다.
- 특히 map_01.json은 spawn area가 하나이므로 Stage 01의 left/right/both가 실제로 같은 spawn으로 수렴할 수 있다.
- 이는 Validator의 구조 검증과 Runtime 의미 검증 사이의 GAP이다.
- Canon 결정 전 코드 수정 금지. HOLD.

### CONFIRMED — Tower / Skill / Weapon
- TowerDefinition은 ObjectDefinition을 기반으로 combat/upgrade/visual 정보를 가진다.
- TowerRuntimeState가 Definition을 참조하고 WeaponDefinition을 통해 공격 Runtime을 구성한다.
- Skill Catalog는 별도로 존재하며 GameController가 Skill 데이터를 직접 소비한다.
- WeaponDefinition은 독립 Definition 객체지만 현재 별도 Weapon Catalog/Editor 중심 구조는 확인되지 않는다.
- 현재 3 Gameplay Scope를 위해 즉시 Building/Skill/Weapon 공통 시스템을 새로 만드는 것은 필요하지 않다.

### 계획 판정
- 객체 중심 방향 자체는 현재 코드 구조와 충돌하지 않는다.
- Stage / Mission / Reward / Encounter / Wave / Map / Actor / Tower의 분리 경계는 유지한다.
- 현재 가장 중요한 미해결 Canon은 Mission Type의 3 Gameplay 매핑, Mission target 의미, Player Count, lane semantics이다.
- 이 네 항목은 구현으로 선행 해결하지 않고 Master Canon 결정 또는 추가 검증 후 처리한다.
- 현재 목적은 문서 기준선 갱신이며 신규 Runtime/Editor 구현은 하지 않는다.

### Verification
- CODE VERIFIED: 위 구조/경로를 기존 코드 조사 결과와 대조.
- BUILD VERIFIED: 이번 문서 재검토에서는 실행하지 않음.
- EDITOR VERIFIED: 이번 문서 재검토에서는 UI 조작하지 않음.
- PIE VERIFIED: 이번 문서 재검토에서는 수행하지 않음.

### OUT OF SCOPE
- Mission Type 코드 전환
- Giant Boss 승리 조건 구현
- Player Count 구현
- Lane semantics 변경
- Allied Unit Editor 구현
- Building/Weapon/Skill 공통 시스템 신규 구현
- Stage/Map/Content Editor 대규모 개편


## 2026-10-05 Lane Semantics Runtime 재검증

STATUS: CONFIRMED GAP / IMPLEMENTATION HOLD
목적: Stage lane 값(left/right/both)이 실제 Runtime spawn 선택에서 어떤 의미로 해석되는지 직접 코드 경로로 재검증한다.

### CONFIRMED
- Stage Wave Enemy Group은 lanes 배열을 spawn_queue entry에 그대로 저장한다.
- Runtime spawn_enemies()는 requested_lanes 중 하나를 선택하며, 여러 lane 값을 동시에 생성하는 분기 구조는 없다.
- requested_lane이 실제 SPAWN_AREAS key와 일치하면 해당 spawn area를 사용할 수 있다.
- requested_lane이 left/right이고 실제 spawn area key가 없으면 SPAWN_AREAS의 key를 전역 순서로 순환 선택한다.
- map_01의 실제 spawn area는 spawn_area 타입에서 생성되는 spawn_0 계열 key이며, left/right key가 아니다.
- 따라서 map_01에서 left와 right는 각각 고유한 좌/우 spawn area를 의미하지 않는다.
- lanes=[left,right]는 두 lane에서 동시 spawn한다는 의미가 아니다. 적 spawn마다 left 또는 right 요청값을 순차적으로 선택한 뒤, 현재 map의 spawn area fallback을 사용한다.
- 특히 map_01에는 spawn area가 하나뿐이므로 left/right/both가 실질적으로 같은 spawn area로 수렴한다.
- Validator는 lanes가 Array인지와 기본 값 형식만 확인하며 left/right/both의 Map spawn area 대응 또는 동시/분산 semantics를 검증하지 않는다.

### 판정
- 기존 문서의 "Lane Semantics GAP"는 단순 설계 미확인 상태가 아니라 현재 Runtime 구현에서도 의미가 완전히 보장되지 않는 것으로 확인되었다.
- 다만 최종적으로 lane을 좌/우 추상명으로 유지할지, Map의 실제 spawn area ID를 참조하게 할지는 Master Canon 결정이 필요하다.
- Canon 결정 전 Runtime/Validator를 수정하지 않는다.

### Verification
- CODE VERIFIED: GameController spawn_queue → spawn_enemies 경로 직접 확인.
- BUILD VERIFIED: 이번 조사에서는 실행하지 않음.
- EDITOR VERIFIED: 이번 조사에서는 UI 조작하지 않음.
- PIE VERIFIED: 미수행.

### OUT OF SCOPE
- Lane semantics 구현 변경
- Map spawn area 추가/삭제
- Stage JSON 수정
- Validator 강화


## 2026-10-05 Mission Contract / target_id 재검증

STATUS: CODE VERIFIED / HOLD
목적: Mission Type과 target_id가 현재 콘텐츠 및 Runtime에서 실제 어떤 계약을 갖는지 재검증한다.

### CONFIRMED
- Mission Catalog에는 mission_stage_01~03이 존재하며 현재 세 Mission 모두 primary_type=`clear_encounters`, target_id=``, time_limit=0이다.
- Stage 01~03은 각각 해당 Mission ID를 참조한다.
- ContentValidator가 허용하는 primary_type은 현재 `defend_base`, `clear_encounters` 두 종류뿐이다.
- `defend_base`는 time_limit > 0을 요구한다.
- Stage Editor도 현재 동일한 두 Mission Type만 선택 가능하다.
- MissionDefinition은 target_id를 정상적으로 로드한다.
- Stage Editor는 target_id를 저장한다.
- 그러나 GameController 전체 Mission 판정 경로에서 target_id를 읽어 승리 조건을 결정하는 코드는 확인되지 않았다.
- GameController의 현재 승리 경로는 defend_base의 time_limit 또는 모든 Encounter/Wave 및 생존 Enemy 소멸을 기준으로 한다.
- Giant은 별도의 boss attack/pattern/runtime state를 가지고 있으나 giant 처치 여부를 Mission 승리 조건으로 연결하는 target_id 기반 판정은 없다.
- Stage 01~03의 실제 Encounter에는 giant이 포함되지만, 이것만으로 해당 Stage가 Giant Boss Battle이라는 사실을 의미하지 않는다.

### INFERENCE
- 현재 target_id는 미래 Mission Objective 확장을 위한 저장 필드일 가능성은 있으나, 그 의미를 Enemy ID/Giant ID/Encounter ID 등으로 특정할 직접 근거는 없다.
- 현재 실제 구현 기준으로는 target_id가 Mission Contract의 실행 변수로 기능하지 않는다.

### 판정
- `target_id` 의미는 계속 HOLD / UNVERIFIED로 유지한다.
- 현재 Mission Type의 Runtime 계약은 사실상 `defend_base`와 `clear_encounters` 두 종류다.
- Master Canon의 Tower Defense / Elimination / Giant Boss Battle을 현재 두 타입에 임의 매핑하지 않는다.
- 특히 Stage에 giant이 포함된다는 이유만으로 Giant Boss Battle로 판정하지 않는다.
- Mission 시스템을 확장하려면 먼저 Master가 3 Gameplay의 승리 조건과 target semantics를 결정해야 한다.

### Verification
- CODE VERIFIED: MissionDefinition / ContentValidator / Stage Editor / GameController / Stage 01~03 직접 대조.
- BUILD VERIFIED: 미수행.
- EDITOR VERIFIED: 미수행.
- PIE VERIFIED: 미수행.

### OUT OF SCOPE
- Mission Type 추가
- target_id 의미 확정
- Giant Boss Victory 구현
- Stage 01~03 Mission 데이터 변경


## 2026-10-05 Player Count / Multiplayer Semantics 재검증

STATUS: CODE VERIFIED GAP / HOLD
목적: 현재 `play_modes`와 `multiplayer` 데이터가 Player Count 또는 실제 Multiplayer Runtime을 의미하는지 직접 코드 경로로 확인한다.

### CONFIRMED
- MapLoader는 Map JSON의 `play_modes`와 `multiplayer` Dictionary를 읽어 보존한다.
- Map Editor는 `campaign`, `single`, `multiplayer` 세 play mode를 편집할 수 있다.
- Map Editor의 Multiplayer 설정은 alliance 목록, alliance controller, relation, third alliance enabled 등을 저장할 수 있다.
- 현재 Map의 multiplayer alliance controller 값은 `ai`이며, 구조상 Alliance/Relation 설정을 표현한다.
- StageManager의 `run_mode`는 현재 `campaign`과 `single` 실행 흐름에서 사용된다.
- Title Screen에는 Campaign과 Single Play 진입만 존재하며 Multiplayer 실행 경로는 확인되지 않았다.
- GameController에서 Map의 `multiplayer`, alliance, relation 데이터를 실제 Player Count 또는 네트워크 플레이어 생성/소유권 판정에 사용하는 Runtime 경로는 확인되지 않았다.
- 프로젝트 전체에서 독립적인 `player_count`, `playerCount`, 또는 동등한 Player Count 저장 필드는 확인되지 않았다.
- 따라서 `play_modes.multiplayer`는 현재 Player Count가 아니다.
- 현재 `multiplayer` 데이터는 Map Editor/MapLoader 수준에서 보존되는 설정 데이터이며, 실제 Multiplayer Runtime 계약이 구현되었다고 볼 수 없다.

### INFERENCE
- `multiplayer.alliances` / `relations`는 향후 AI faction 또는 multiplayer rules 확장을 위한 Map-level 설정으로 보인다.
- 그러나 현재 구조만으로 실제 인간 Player 수, 팀 수, Controller ownership을 특정할 수 없다.

### 판정
- Player Count Canon/storage는 **UNVERIFIED / HOLD**.
- `campaign/single/multiplayer`는 Player Count가 아니라 현재 확인 가능한 실행/Map capability mode로 취급한다.
- `multiplayer`가 존재한다는 이유만으로 2P/3P/다인 플레이를 지원한다고 문서화하지 않는다.
- Player Count를 추가하려면 Player identity, controller ownership, team/alliance membership, spawn ownership 중 최소 계약을 먼저 정의해야 한다.
- 현재 목적에서는 구현하지 않는다.

### Verification
- CODE VERIFIED: MapLoader / Map Editor / StageManager / Title Screen / GameController 소비 경로 대조.
- BUILD VERIFIED: 미수행.
- EDITOR VERIFIED: 코드 경로 조사만 수행.
- PIE VERIFIED: 미수행.

### OUT OF SCOPE
- Multiplayer Runtime 구현
- Network layer 추가
- Player Count field 추가
- Alliance/Relation semantics 변경
- Title Screen Multiplayer UI 추가


## 2026-10-05 Allied Units Authoring Gap 재검증

STATUS: CODE VERIFIED GAP / HOLD
목적: Allied Unit이 실제 Runtime 자산인지와 Stage Editor에서 Stage 배치/구성 authoring이 가능한지 분리 검증한다.

### CONFIRMED
- Allied Unit에는 별도 Catalog(`content/allied_units/allied_units.json`), `AlliedUnitDefinition`, `AlliedUnitRuntimeState`, `AlliedUnitAI`가 존재한다.
- GameController는 Allied Unit Catalog를 로드하고 Stage의 `allied_units`를 읽어 Runtime State를 생성하며 Render/AI/공격/회복/피해 처리를 수행한다.
- StageLoader와 ContentValidator는 Stage의 `allied_units`를 검증한다.
- Stage 01에는 `basic`, `ranged`, `support`를 각각 count=1, spawn=`robot`으로 참조하는 실제 데이터가 존재한다.
- 별도 `Unit Editor`가 존재하며 Allied Unit Catalog의 개별 Unit 능력치/AI/Visual/Animation 등을 편집할 수 있다.
- 그러나 Stage Editor에는 `allied_units`를 추가/삭제/수량/ID/spawn point 등을 authoring하는 UI와 저장 로직이 없다.
- Stage Editor는 기존 `allied_units` 필드를 Stage JSON에 보존할 수 있지만, 현재 UI를 통해 새 Allied Unit 구성을 만들거나 변경할 수 있다는 근거는 확인되지 않았다.

### 판정
- Allied Unit 자체는 **CODE VERIFIED / Runtime active**이다.
- 문제는 Runtime 구현 부재가 아니라 **Stage-level authoring gap**이다.
- 현재 범위에서는 Editor 구현을 임의 추가하지 않는다. 필요한 authoring 계약(배치 의미, spawn ownership, count, spawn point)을 Master Canon으로 먼저 확정할 필요가 있는지 확인한다.
- 특히 `spawn=robot`은 현재 Validator/Runtime에서 허용되는 spawn reference지만, 향후 여러 Player/Alliance 또는 다수 robot spawn point를 정의하는 Canon과는 별개로 취급한다.

### Verification
- CODE VERIFIED: PASS
- BUILD VERIFIED: 미수행
- EDITOR VERIFIED: 코드 구조상 authoring UI 부재 확인. 실제 Editor 실행은 미수행.
- PIE VERIFIED: 미수행

### OUT OF SCOPE
- Allied Unit Editor 신규 기능 구현
- Stage Editor Allied Unit UI 구현
- Spawn ownership / Player Count semantics 결정
- Allied Unit Catalog 데이터 변경


## 2026-10-05 Encounter / Wave Runtime Semantics 재검증

STATUS: CODE VERIFIED GAP / HOLD
목적: Encounter/Wave/Group 데이터 구조가 Editor에서 authoring되는 방식과 실제 Runtime spawn/clear semantics가 일치하는지 확인한다.

### CONFIRMED
- Stage Editor는 Encounter → Wave → Group 구조를 직접 authoring한다.
- Group은 `[enemy_id, count, interval, lanes]` 4요소 구조다.
- StageLoader/ContentValidator는 Encounter/Wave/Group의 구조, Enemy ID, count, interval, lanes 컨테이너를 검증한다.
- StageManager는 Encounter별 Wave 배열을 그대로 GameController에 제공한다.
- GameController의 `start_wave()`는 한 Wave의 모든 Group을 하나의 `spawn_queue`로 펼친다.
- 같은 Wave 안의 Group들은 병렬 실행되지 않는다. 첫 Group의 모든 count를 interval로 배치한 뒤 `wave_group_gap`을 더하고 다음 Group을 배치한다.
- 따라서 여러 Group을 같은 Wave에 넣었다고 해서 서로 다른 적군 그룹이 동시에 출현한다는 의미는 아니다.
- `lanes`가 여러 값이어도 개별 enemy spawn 시 하나의 requested lane만 선택한다. 따라서 `[left,right]`는 현재 Runtime에서 양쪽 동시 생성 계약이 아니다.
- Wave Clear는 spawn_queue가 비고 살아 있는 Enemy가 없을 때 발생한다.
- Encounter Clear는 해당 Encounter의 마지막 Wave가 Clear된 뒤 다음 Encounter로 넘어가는 Runtime 상태 전환이다.
- 마지막 Encounter/Wave 종료 후 `clear_encounters` Mission이면 Victory로 진행한다.
- `defend_base` Mission이면 마지막 Wave 종료가 Victory가 아니라 Defense 지속으로 이어진다.
- Wave/Group에 별도 start time, concurrent group flag, spawn phase, encounter objective 등의 필드는 없다.

### INFERENCE
- 현재 `Wave`는 의미상 "동시 출현 묶음"이라기보다 "순차적으로 실행되는 여러 Spawn Group의 컨테이너"에 가깝다.
- Stage 01의 `NORMAL / BOTH LANES`, `RUSHER / NORTH PRESSURE` 같은 label은 현재 Runtime이 별도 의미를 해석하지 않는 표시용 텍스트다.
- 동일 Wave 안의 다중 Group을 동시 압박으로 의도했다면 현재 데이터 구조와 Runtime은 그 의도를 보장하지 않는다.

### 판정
- Encounter/Wave 기본 구조와 Editor/Runtime 연결은 **CODE VERIFIED**.
- 그러나 Group 동시성 및 Lane semantics는 Canon과 구현 의미가 일치하는지 **HOLD**.
- 기존 데이터의 label을 Gameplay Canon으로 승격하지 않는다.
- 현재 목적에서는 Runtime/Schema를 수정하지 않는다.

### Verification
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED

### OUT OF SCOPE
- Wave concurrency schema 추가
- Spawn timing schema 변경
- Lane semantics 구현 변경
- Stage 01~03 Wave 데이터 변경


## 2026-10-05 Lane ↔ Map Spawn Area 재검증

### CONFIRMED
- Stage Editor의 Lane 선택지는 고정 `left / right / both`다.
- Stage Editor에서 `both`는 저장 시 `lanes=["left","right"]`로 변환된다.
- Map Runtime은 `gameplay_areas[].type == "spawn_area"`를 발견할 때 실제 Runtime lane ID를 `spawn_0`, `spawn_1` 등의 형태로 생성한다.
- `map_01.json`에는 `spawn_area`가 1개뿐이다. 따라서 Runtime의 실제 Spawn Area key는 `spawn_0` 하나다.
- `map_01.json`에는 legacy `spawns` 데이터가 별도로 확인되지 않으며, 현재 Runtime은 gameplay spawn area를 기준으로 `SPAWN_AREAS`/`LANES`를 구성한다.
- 따라서 Stage의 `left`, `right`, `both`는 현재 Map의 실제 Spawn Area ID와 직접 연결되어 있지 않다.
- Runtime에서 `left/right` 요청은 실제 `SPAWN_AREAS`가 존재할 경우 사용 가능한 Spawn Area key를 순환 선택한다. Spawn Area가 하나뿐인 `map_01`에서는 left/right가 모두 `spawn_0`으로 귀결된다.
- `both`는 Runtime에서 별도 의미로 처리되지 않는다. `[left,right]`의 두 값을 순서대로 하나씩 선택할 뿐이며, map_01에서는 결과적으로 동일한 `spawn_0`을 반복 사용한다.

### 판정
현재 Lane 데이터와 Map Spawn Area 모델 사이에 **CODE VERIFIED semantic gap**이 있다.
Stage Editor의 `left/right/both`를 실제 Map Spawn Area 선택으로 간주하면 안 된다.
특히 map_01의 1개 Spawn Area에서는 좌/우 분리 Spawn이 실제로 존재하지 않는다.

### HOLD
Canon 결정 전 다음을 구현하지 않는다.
1. left/right를 특정 Map Spawn Area에 강제 매핑
2. Map에 Spawn Area를 추가/분리
3. `both`의 동시 Spawn semantics 구현
4. Stage schema를 실제 spawn ID 기반으로 변경

### OUT OF SCOPE
기존 Stage 01~03의 lane 데이터 수정 및 Map geometry 수정.


## 2026-10-05 Lane ↔ Map Spawn Contract 재검증

STATUS: CODE VERIFIED GAP / HOLD

### CONFIRMED
- MapLoader는 legacy `spawns`를 `lanes`로 읽는다.
- GameController는 `gameplay_areas[].type == spawn_area`를 발견하면 이를 `spawn_0`, `spawn_1` 등의 Runtime ID로 변환한다.
- 즉 `gameplay_areas.spawn_area`의 ID/name 자체는 `left`/`right` lane ID로 보존되지 않는다.
- `map_01.json`은 현재 `spawns={}`이고 `spawn_area`는 1개다. 따라서 Runtime에는 사실상 `spawn_0` 하나가 생성된다.
- `stage_01.json`은 `left/right`를 lanes로 요청한다. 현재 `spawn_0`만 존재하므로 Runtime의 fallback/cycling 경로가 개입한다.
- `map_02.json`, `map_03.json`은 `spawns.left/right`를 보유하지만 `spawn_area` gameplay area는 없다. 따라서 이 두 맵은 `left/right`가 직접 Runtime lane으로 사용된다.
- 따라서 동일한 Stage Group의 `[left,right]`가 어떤 Map을 참조하느냐에 따라 전혀 다른 Runtime 경로를 거친다.
- Map Editor에는 Spawn Area authoring 도구가 존재하지만, 현재 저장 구조에는 legacy `spawns`와 `gameplay_areas.spawn_area`가 공존할 수 있다.

### INFERENCE
현재 프로젝트에는 두 개의 Spawn 표현이 공존한다.
1. Legacy named spawn: `spawns.left/right`
2. Gameplay Spawn Area: `gameplay_areas`의 `spawn_area`

둘 사이에 `left/right ↔ spawn area` 명시적 매핑 계약은 확인되지 않았다.

따라서 현재 Lane semantics의 핵심 문제는 단순히 Stage Group의 `lanes` 값이 아니라 **Map의 Spawn 표현 방식이 통일되어 있지 않다는 것**이다.

### 마리 판정
- Lane → Spawn mapping은 **CODE VERIFIED GAP**.
- `left/right/both`의 Canon을 먼저 확정하고 Map spawn representation을 하나의 계약으로 정리해야 한다.
- 지금 Stage 데이터나 Map 데이터를 수정하면 기존 동작/의도를 임의로 바꿀 위험이 있으므로 구현하지 않는다.

### Verification
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED

### OUT OF SCOPE
- Map JSON 정규화
- Spawn Area ID 체계 변경
- Stage lane 데이터 변경
- Runtime spawn algorithm 변경


## 2026-10-05 Enemy Lane / Path Runtime Semantics 재검증

STATUS: CODE VERIFIED GAP / HOLD

### CONFIRMED
- EnemyRuntimeState는 `lane`, `position`, `start_position`을 저장한다.
- Enemy 이동은 별도 Path/Route/Waypoint 데이터가 아니라 `start_position → BASE` 직선 보간으로 계산된다.
- 매 Tick `position.x`를 speed만큼 증가시키고, `(position.x - start.x) / (BASE.x - start.x)`를 progress로 계산한 뒤 `position.y = lerp(start.y, BASE.y, progress)`로 결정한다.
- 따라서 Lane은 이동 경로 자체가 아니라 **Spawn 시작점 선택에 사용되는 상태값**이다.
- Spawn Area가 있는 경우 시작 위치는 Area 내부의 랜덤 위치이며, 이후 이동은 해당 위치에서 Base까지의 직선 보간이다.
- Map의 `movement_area`, `blocked_area`, `obstacle_area`는 현재 확인된 Enemy 이동 계산에 직접 사용되지 않는다.
- Goal Area 역시 Enemy 도달 판정의 직접 기준이 아니며, 실제 도달 판정은 `BASE.x - 25` 기준이다.
- 따라서 현재 Runtime에는 Lane별 Path, Waypoint, Nav/Movement Corridor, Goal Area 기반 이동 계약이 없다.

### INFERENCE
- 현재 `left/right`라는 명칭은 전술적 Lane이라기보다 Spawn 출발 위치를 구분하는 레거시 개념에 가깝다.
- Master가 의도한 Lane을 실제 전투 경로로 사용하려면 현재 구조만으로는 부족하다.
- 특히 Map Editor에서 Movement/Blocked/Obstacle Area를 authoring할 수 있다는 사실만으로 Enemy Pathing에 사용된다고 판단하면 안 된다.

### 마리 판정
- Spawn semantics와 Movement semantics를 분리해야 한다.
- 현재 목적에서 Pathfinding/Waypoint/Navigation 구현을 추가할 근거는 없다.
- Lane Canon을 확정하기 전에는 이동 시스템을 수정하지 않는다.

### Verification
- CODE VERIFIED: PASS
- BUILD VERIFIED: NOT VERIFIED
- EDITOR VERIFIED: NOT VERIFIED
- PIE VERIFIED: NOT VERIFIED

### OUT OF SCOPE
- Pathfinding 구현
- Waypoint/Route schema 추가
- Navigation 시스템 추가
- Movement Area/Obstacle Area Runtime 연결

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
