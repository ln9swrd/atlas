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
- Mission
- Encounter/Wave
- Spawn 설정
- Victory Rule
- Defeat Rule
- Reward

Mission은 목표와 승패 규칙을 소유한다.
Map은 공간을 소유한다.
Stage는 둘을 실제 플레이 단위로 조합한다.

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
Phase B — 핵심 객체 Runtime 연결
- Robot 직접 조종
- Enemy AI
- Building 고정 지원 시설
- Base
- 기본 공격
- Skill
- Finisher

완료 조건: 플레이어 Robot과 Enemy/Building이 동일한 객체 데이터 기반으로 Runtime에서 동작.

Phase C — 전투 조합
- Map
- Building 배치
- Spawn
- Encounter/Wave
- Mission
- Stage

완료 조건: 하나의 Stage가 Map과 객체 정의를 참조해 독립적으로 실행 가능.

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
