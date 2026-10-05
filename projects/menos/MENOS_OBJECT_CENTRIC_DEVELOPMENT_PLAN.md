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
