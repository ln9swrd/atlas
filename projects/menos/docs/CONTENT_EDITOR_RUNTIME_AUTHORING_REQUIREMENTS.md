
## 33. MAP EDITOR 추가 검토 보완사항

MAP EDITOR의 기본 제작 기능은 이미 구현되어 있으므로 본 절은 신규 구현을 의미하지 않는다. 구현 전 요구사항 보완 및 우선순위 판단을 위한 기준이다.

### 33.1 Map Identity / 상태
- Map 내부 ID와 표시용 Name/Display Name을 분리한다.
- ID 변경은 참조 무결성 검증 대상이다.
- Draft / Valid / Invalid / Deprecated 등의 Authoring 상태가 필요한지 추후 결정한다.
- Production 투입 가능 여부와 단순 Editor 저장 가능 여부를 구분한다.

### 33.2 Reference / 영향도 보호
- Map을 사용하는 Stage 목록을 확인할 수 있어야 한다.
- 가능하면 Campaign까지 역추적 가능한 Reference Inspector를 제공한다.
- Map ID 변경, 삭제, Gameplay Element 변경 시 영향받는 참조를 표시한다.
- 사용 중인 Map의 삭제/ID 변경은 검증 또는 확인 절차를 거친다.
- Catalog Asset이 Map에서 사용 중인 경우 Asset 변경/삭제 시 영향도를 확인한다.

### 33.3 Gameplay Element 의미 검증
Map에 Gameplay Element가 존재하는 것과 Runtime에서 실제 소비되는 것은 별개의 문제로 취급한다.
- Runtime 소비 여부
- 필수/선택 여부
- 필수 속성
- 위치/크기/방향 규칙
- 다른 Runtime 데이터와의 연결 규칙
확인되지 않은 Runtime 소비 속성은 임의로 Editor 필드로 추가하지 않는다.

### 33.4 Gameplay Area / Point 규칙
- Gameplay Area가 단순 편집 영역인지 실제 Spawn/Navigation/Collision 등 Runtime 의미를 갖는지 타입별로 정의한다.
- Area와 Point의 좌표, 크기, 방향 및 연결 규칙을 명확히 한다.
- 필수 Gameplay Element와 선택 Gameplay Element를 분리한다.
- Map 밖 배치, 중복 ID, 잘못된 Area 참조 등을 Validation 대상으로 한다.

### 33.5 좌표계 Canon
Map Editor와 Runtime 사이의 좌표계를 명확히 정의한다: Map origin, Tile coordinate, Pixel/world coordinate, Map bounds, Asset footprint, Gameplay Point position, Gameplay Area position/size. 각 데이터의 저장 단위를 명시한다.

### 33.6 Asset / Gameplay 독립성
- Visual Asset 교체가 Gameplay 좌표를 임의로 변경하지 않아야 한다.
- Gameplay 데이터와 시각적 Asset 데이터의 책임을 분리한다.
- Asset 변경/삭제 시 Map 사용처와 영향 범위를 확인한다.
- Layer별 Asset 배치 규칙과 Gameplay Element의 공간 관계를 명확히 한다.

### 33.7 편집 보호 및 생산성 — P1 후보
Redo, Gameplay Element 목록/Inspector, Search/Filter, Duplicate Gameplay Element, Map 전체 Duplicate, Reference Inspector, Validation Panel 및 오류 위치 이동, 명시적 Grid Snap, New Map Wizard, Map Template, Map Preview Thumbnail. 실제 제작 병목이 확인된 경우에만 구현한다.

### 33.8 Save Safety
MAP 저장은 Edit → Validate → Build Definition → Transaction Save → Reload → Verify → Saved 흐름을 Production 기준으로 고려한다. 저장 실패 또는 Reload/Verify 실패 시 기존 정상 데이터가 손상되지 않아야 한다. Preview 성공은 Save Verify 또는 Runtime 검증으로 간주하지 않는다.

### 33.9 변경 영향도 / Lock — P1 후보
Map Lock / Read-only, 사용 중 Map 변경 경고, 변경 영향도 Preview, 변경 전/후 Reference 검사를 후보로 둔다.

### 33.10 Map 복제 / Template
Map 전체 복제는 기존 Map을 보존하면서 변형 Map을 제작하기 위한 생산성 기능이다. Template은 실제 제작 패턴이 확인되기 전에는 구현하지 않는다.

### 33.11 Metadata / Export / Preview
Description, Tags 등의 Metadata는 Runtime 필수 데이터가 아니면 낮은 우선순위로 둔다. 외부 Map Export/Import는 SQLite가 Content Authority인 현재 구조에서는 기본 요구사항으로 보지 않는다. Thumbnail/Preview는 편의 기능으로 분류한다.

### 33.12 Performance / Data 규모
Production Map이 커질 경우 Asset 배치 수, Gameplay Element 수, Map 데이터 크기, Editor Preview 성능, Runtime Load 성능을 검증 대상으로 한다. 문제가 확인되지 않았다면 선제적으로 복잡한 최적화를 구현하지 않는다.

### 33.13 Multiplayer 관련 보류
현재 Map Editor에는 Multiplayer / Third Alliance 데이터 구조가 존재한다. 그러나 해당 기능이 현재 Production Runtime의 실제 소비 대상인지 확인되지 않은 상태에서는 필수 Authoring 요구사항으로 확정하지 않는다.

### 33.14 MAP Editor 검토 최종 분류
P0: Map identity/reference integrity, Map bounds/좌표계, Runtime이 실제 소비하는 Gameplay Element, 필수/선택 Gameplay Element 규칙, Asset/Gameplay reference 검증, Save/Reload/Verify 안전성.
P1: Redo, Validation Panel, Gameplay Element 목록/Inspector, Reference Inspector, Search/Filter, Duplicate, Grid Snap UX, Map Duplicate, 변경 영향도/Lock.
P2 또는 필요성 검증 후: New Map Wizard, Template, Thumbnail/Metadata, Export/Import, 고급 Performance 관리, Multiplayer/Third Alliance Authoring.

본 절은 요구사항 기록이며 구현 승인을 의미하지 않는다.

## MISSION EDITOR — RUNTIME-BASED REQUIREMENT REVIEW (2026-10-07)

### 조사 목적
현재 Godot Runtime이 실제로 소비하는 Mission Definition을 기준으로 Mission Editor의 필수 Authoring 범위를 확정한다. Runtime에 존재하지 않는 가상 Objective 시스템을 Editor에 선행 구현하지 않는다.

### CONFIRMED — 현재 Runtime Mission Definition
현재 Mission Definition의 실사용 필드는 다음과 같다.
- id
- title
- briefing
- primary_type
- target_id
- time_limit

현재 SQLite Mission 데이터도 위 구조를 사용한다.

### CONFIRMED — Runtime Mission Type
1. `clear_encounters`
   - Encounter/Wave 전체 클리어를 통해 Stage 완료.
   - 별도의 Objective 데이터는 사용하지 않는다.
2. `defeat_giant`
   - Giant 처치 시 Mission Clear.
3. `defend_base`
   - `time_limit > 0`인 경우 활성.
   - 지정 시간 동안 Base가 생존하면 Mission Clear.

### CONFIRMED — Victory / Defeat 책임
- Mission은 현재 Mission Type에 따른 Stage 완료 조건을 정의한다.
- Base HP가 0 이하이면 Runtime Defeat.
- Campaign에서는 Mission/Stage 완료 후 다음 Stage로 진행하며 마지막 Stage 완료 시 Campaign Victory.
- Mission 자체에 별도의 Victory Condition 목록이나 Defeat Condition 목록은 없다.

### CONFIRMED — Reward 책임
Reward는 Mission이 아니라 Stage가 소유한다.
- Stage `reward_id`가 Reward를 참조한다.
- Stage Clear 시 Reward를 지급한다.
- Mission Editor에서 별도의 Mission Reward 시스템을 만들지 않는다.

### CONFIRMED — Stage와 Mission 책임 분리
- Mission: 어떤 방식으로 Stage를 완료하는가.
- Stage: Map + Encounter + Wave + Enemy Group을 어떻게 실행하는가.
- Reward: Stage 완료 후 무엇을 지급하는가.

### MISSION EDITOR P0 요구사항
- Mission ID
- Title
- Briefing
- Mission Type
- Mission Type별 필요한 필드만 표시
- `defend_base`의 Time Limit 편집
- Mission Type 유효성 검증
- `defend_base`의 Time Limit > 0 검증
- ID 중복 검증
- 참조 무결성 검증
- 저장 후 Reload/Verify
- Runtime 지원 범위를 벗어난 데이터 저장 방지

### `target_id` 처리
현재 조사한 Runtime 경로에서 `target_id`는 실질적인 Mission 실행 조건으로 소비되지 않는다.
따라서 현재 Editor에서는 필수 Authoring 필드로 취급하지 않는다. 제거/보존 여부는 기존 데이터 호환성을 확인한 뒤 별도 결정한다.

### OUT OF CURRENT RUNTIME SCOPE
현재 Runtime이 지원하지 않는 다음 기능은 Mission Editor에 선행 구현하지 않는다.
- 복수 Objective
- Objective AND/OR
- Objective 진행도
- Objective 순서
- Enemy/Faction별 처치 목표
- 위치 점령 Objective
- 이벤트 기반 Objective
- Mission 자체 Reward
- Mission 자체 Map
- Mission 자체 Victory/Defeat 목록
- Multiplayer Objective
- Objective HUD 데이터

### P1/P2 후보
향후 Runtime에 실제 기능이 추가되는 경우에만 다음을 재검토한다.
- Objective/Condition Definition
- 복수 Victory/Defeat 조건
- Objective 진행도
- 이벤트 기반 조건
- Mission Preview
- Reference Inspector
- 영향 범위 표시
- Batch Validation
- Mission Duplicate/Template
- Version/Migration

### 판정
현재 Runtime 기준 Mission Editor 요구사항은 과도하게 확장할 필요가 없다. Editor는 Runtime이 실제 소비하는 Definition을 정확하게 authoring하는 데 집중한다. 추가 Objective 시스템은 Runtime 설계가 먼저 확정된 뒤 확장한다.

**검증 상태:** CODE VERIFIED / EDITOR VERIFIED / PIE VERIFIED UNVERIFIED
**변경 사항:** 요구사항 문서만 추가. Runtime 코드 변경 없음.


## CAMPAIGN EDITOR — STORY CAMPAIGN AUTHORING REQUIREMENT REVIEW (2026-10-07)

### 목적
Story Mode를 장기적으로 관리할 수 있도록 Campaign Editor를 단순 Stage 목록 편집기에서 Story Campaign 관리 도구로 확장하기 위한 요구사항을 정리한다. 현재 Runtime이 실제로 소비하는 데이터와 향후 Story 구조를 분리한다.

### CONFIRMED — 현재 Runtime Campaign 구조
현재 Campaign Runtime은 다음과 같은 선형 구조를 사용한다.

Campaign → Stage → Map

- Campaign Definition은 Stage ID의 순서 목록을 가진다.
- 첫 Stage부터 순서대로 진행한다.
- Stage 완료 후 다음 Stage를 로드한다.
- 마지막 Stage 완료 시 Campaign Victory.
- Player Progression은 Campaign Definition과 별도로 Stage 해금/완료 상태를 관리한다.
- 현재 Runtime은 Chapter나 Story Event를 소비하지 않는다.

따라서 현재 Campaign Editor의 Chapter/Story 기능은 Runtime 지원 여부를 별도로 검증해야 한다.

### PROPOSAL — Story Campaign 구조
Story Mode의 관리 구조는 다음을 목표 구조로 검토한다.

Campaign → Chapter → Stage → Map

향후 Story Event가 Runtime에 추가되는 경우에만 다음 구조를 확장한다.

Campaign → Chapter → Story Event / Stage → Map

Story Event, Dialogue, Branching 등은 Runtime 설계가 확정되기 전까지 Authoring 필수 기능으로 구현하지 않는다.

### Campaign / Chapter 요구사항
Campaign Editor는 다음을 관리할 수 있어야 한다.

- Campaign ID / Name
- Chapter ID / Number / Title / Description
- Chapter 순서
- Chapter별 Stage 목록과 순서
- Stage Selector를 통한 유효 Stage 참조
- Stage ID와 표시명 구분
- Chapter 대표 Map/Thumbnail 등 선택적 Metadata
- Chapter 및 Stage의 Validity 상태
- Campaign 전체 실행 가능 여부

Chapter 번호와 영구 ID는 분리한다. 순서 변경이 ID 변경을 발생시키면 안 된다.

### Stage 관리 요구사항
- Stage를 자유 텍스트보다 Selector 방식으로 선택한다.
- 선택된 Stage의 ID, Name, Map, Mission, Reward 상태를 확인할 수 있어야 한다.
- 동일 Stage의 중복 등록을 검증한다.
- Stage 순서를 변경할 수 있어야 한다.
- Stage 제거/ID 변경 시 Campaign과 Player Progression에 미치는 영향을 확인한다.
- Stage 자체의 Gameplay Definition과 Campaign의 Story 순서를 분리한다.

### Story Progression과 Gameplay Progression 분리
다음 데이터를 서로 다른 책임으로 관리한다.

- Story Progression: Campaign / Chapter / Story Event 위치
- Gameplay Progression: Stage Unlock / Completion / Current Stage

Campaign Definition을 Player Save 데이터와 혼합하지 않는다.

### Chapter 시작 / 종료
향후 Runtime이 지원하는 경우에만 다음 정보를 정의할 수 있다.

- Chapter Start
- Chapter Final Stage
- Chapter Clear Condition
- Next Chapter Entry Condition

현재 Runtime은 선형 Stage 목록만 소비하므로, Chapter Clear 및 조건부 진입은 아직 Runtime 기능으로 확정하지 않는다.

### Campaign 전체 Validation
한 번의 Validation에서 최소한 다음을 검사한다.

- Campaign ID 유효성
- Chapter ID 중복
- Chapter 순서 유효성
- Chapter 없는 Stage
- 존재하지 않는 Stage
- 중복 Stage
- Stage의 Map/Mission/Reward 참조 유효성
- Stage 자체 Invalid 상태
- 필수 시작 Stage 존재
- Final Stage 존재 또는 현재 Runtime의 마지막 Stage 규칙과 일치
- Story Event 참조 오류가 존재하는 경우 해당 오류
- 순환 참조가 존재하는 확장 구조에서는 Cycle 검사
- Campaign 전체가 실제 Runtime에서 실행 가능한지 여부

### Reference Inspector / Change Impact
Campaign에서 다음 방향으로 참조 관계를 역추적할 수 있어야 한다.

Campaign → Chapter → Stage → Map / Mission / Reward / Asset

다음 변경에는 영향 범위를 표시한다.

- Stage 삭제
- Stage ID 변경
- Stage 순서 변경
- Map 변경
- Mission 변경
- Reward 변경
- Asset 변경

사용 중인 콘텐츠의 삭제나 ID 변경은 무조건 즉시 실행하지 않고 Validation/확인 절차를 거친다.

### 재플레이 / 진행 상태
Authoring 단계에서 다음 정책을 정의할 수 있는 구조를 고려한다.

- 클리어 Stage 재진입
- Chapter 재진입
- Story Event 재생 여부
- 최초 진행과 재플레이의 차이

단, 실제 동작은 Runtime Player Progression이 지원하는 범위까지만 확정한다.

### Campaign Flow Preview
Editor에서 다음과 같은 Story Flow를 시각적으로 확인할 수 있도록 한다.

Chapter 1 → Stage 01 → Stage 02 → Chapter 2 → Stage 03 ...

Preview는 Authoring 구조 확인용이며 Runtime 실행 또는 PIE 검증으로 간주하지 않는다.

### Duplicate / Template
P1 후보:
- Campaign Duplicate
- Chapter Duplicate
- Chapter 내 Stage 구성 Duplicate
- Map/Stage를 실제로 함께 복제할지 선택

복제 후에는 ID 충돌 및 참조 무결성을 다시 검증한다.

### Production Lock / 변경 보호
P1 후보:
- Campaign Lock / Read-only
- 승인된 Campaign의 구조 변경 보호
- 변경 전후 Diff
- Stage 순서 변경 영향 표시
- ID 변경 및 삭제 보호

ID는 단순 문자열 수정으로 취급하지 않는다. 참조하는 Campaign, Chapter, Stage, Player Progression의 영향 범위를 확인한다.

### Localization / Story Metadata
Story 표시명과 설명은 Localization ID를 사용하는 것을 기본으로 검토한다.

선택적 Campaign/Chapter Metadata:
- Description
- Representative Image / Thumbnail
- 주요 등장 세력
- 주요 캐릭터
- 예상 플레이 시간
- Tags

Runtime 필수가 아닌 Metadata는 낮은 우선순위로 둔다.

### 완성도 / 제작 상태
Campaign과 Chapter에 Authoring 상태를 둘 수 있다.

- Draft
- Valid
- Invalid
- Deprecated
- Production Locked

추가로 다음 Gate를 분리할 수 있다.

- Story Ready
- Content Ready
- Runtime Ready

이는 단순 저장 성공과 Production 투입 가능 여부를 구분하기 위한 것이다.

### Campaign Test Run
향후 자동화 검증은 전체 Campaign 경로를 대상으로 할 수 있다.

Campaign Start → Chapter → Stage → Stage Clear → Next Stage → Final Stage → Campaign Victory

자동화 Test PASS는 Runtime 실행 검증이며 PIE VERIFIED와 동일하게 취급하지 않는다.

### P0
- Campaign ID / Name
- Chapter 구조를 수용할 수 있는 Definition 설계
- Chapter → Stage 순서 관리
- 유효 Stage Selector
- Stage 참조 상태 표시
- Campaign 전체 참조 무결성 검증
- Save → Reload → Verify
- 실제 Runtime이 소비하는 Campaign Definition과 Editor 데이터의 일치

### P1
- Story Flow Preview
- Reference Inspector
- Change Impact
- Duplicate / Template
- Search / Filter
- Campaign / Chapter Lock
- Diff / 변경 보호
- Batch Validation
- 제작 상태 표시
- 재플레이 정책 Authoring 지원

### P2
- Story Event Editor
- Dialogue Editor
- Branching Story
- Choice
- Conditional Unlock
- Multiple Ending
- Cutscene / Timeline

### 중요한 경계
Chapter와 Story Event는 서로 다른 기능으로 취급한다.

Chapter는 Campaign의 구조적 그룹화이므로 Runtime이 이를 소비하도록 확장할 수 있지만, Story Event/Dialogue/Branching은 별도의 Story Runtime 시스템이 필요하다.

따라서 Story Event 기능을 Campaign Editor에 선행 구현하지 않는다.

### 판정
현재 Runtime은 선형 Stage Campaign을 사용하므로 즉시 필요한 핵심은 Campaign → Chapter → Stage 구조를 관리할 수 있는 Authoring 설계와 참조 무결성이다.

Chapter/Story 구조가 Runtime에서 실제 소비되는 방식이 확정되기 전까지 Story Event, Branching, Dialogue 등은 구현하지 않는다.

**검증 상태:** CODE VERIFIED / EDITOR VERIFIED / PIE VERIFIED UNVERIFIED
**변경 사항:** 요구사항 문서만 추가. Runtime 코드 변경 없음.


## STAGE EDITOR — ADDITIONAL DEEP PRODUCTION REQUIREMENTS (2026-10-07)

### 33. Stage Execution and Data Ownership

Stage Editor는 전투 실행에 필요한 Stage Definition을 authoring하는 책임을 가진다.

Story 데이터는 Campaign/Chapter/Story Event 계층에서 관리하고, Player Progress와 Runtime State는 Stage Definition에 저장하지 않는다.

구분:
- Stage Definition: 제작자가 정의한 고정 콘텐츠
- Player Progress: 플레이어의 Campaign 진행 상태
- Runtime State: 현재 전투 중 상태

Stage와 Story의 책임이 중복되지 않도록 한다.

### 34. Stage Execution Order Contract

다음 순서를 명시적으로 관리한다.

- Campaign Stage Order
- Stage Order
- Encounter Order
- Wave Order
- Enemy Group Order

각 Order의 의미와 Runtime 적용 우선순위를 정의한다.

### 35. Stage Entry / Exit Contract

향후 Runtime이 지원할 수 있도록 Stage의 시작/종료 데이터 경계를 정의한다.

- Stage 시작 시 초기화되는 데이터
- 이전 Stage에서 전달되는 데이터
- Stage 종료 시 생성되는 결과
- Campaign으로 반환되는 결과

현재 Runtime이 지원하지 않는 항목은 Editor 기능으로 선행 구현하지 않는다.

### 36. Determinism / Reproducibility

Runtime Test와 회귀 검증을 위해 가능한 경우 동일 Stage의 실행을 재현할 수 있어야 한다.

검토 대상:
- Enemy Spawn
- Wave Timing
- AI Randomness
- Target Selection
- Reward Randomness

필요 시 Test Run에서 Random Seed를 고정할 수 있는 구조를 고려한다.

### 37. Time Definition Contract

시간 기반 필드는 동일한 단위를 사용한다.

대상:
- Wave Auto Start Delay
- Wave Group Gap
- Enemy Spawn Interval
- Mission Time Limit

기본 단위는 Runtime 계약에 맞춰 정의하며 Editor에 단위를 명시한다.

### 38. Numeric Range / Precision Validation

숫자 입력은 타입뿐 아니라 의미 범위를 검증한다.

예:
- Base HP > 0
- Initial Gold >= 0
- Enemy Count > 0
- Spawn Interval >= 0
- Wave Delay >= 0
- Group Gap >= 0
- Defend Base Time Limit > 0

시간값과 수치값의 허용 소수점 정밀도도 일관되게 관리한다.

### 39. Null / Default / Explicit Zero

다음 세 상태를 필요한 경우 구분한다.

- Undefined / 미지정
- Default / 기본값 사용
- Explicit Zero / 명시적 0

특히 Stage Gameplay Override에서 Stage 값 미지정과 Stage 값 0을 동일하게 처리하지 않는다.

### 40. Override Precedence

Gameplay 설정의 우선순위를 명시한다.

현재 기준:
Stage Override
→ Global Gameplay Default

향후 Campaign/Chapter 수준의 설정이 추가될 경우 우선순위를 별도로 정의한 후 구현한다.

### 41. Definition Preview

Editor 화면의 입력값과 실제 저장되는 Runtime Definition을 비교할 수 있도록 Definition Preview를 제공하는 것을 P1 후보로 둔다.

Preview에는 최소 다음을 표시할 수 있어야 한다.

- Stage ID
- Map
- Mission
- Reward
- Gameplay Overrides
- Encounter
- Wave
- Enemy Group
- Allied Support

Preview는 Runtime 실행과 동일한 검증 상태로 간주하지 않는다.

### 42. SQLite ODB PK / Logical ID

Authoring UI에서는 Logical ID를 기본 식별자로 사용한다.

Database ODB PK는 내부 참조 및 디버깅 목적으로 확인할 수 있으나 일반 제작자가 직접 입력하거나 수정하지 못하도록 한다.

ID 변경은 Name 변경과 별도의 위험 작업으로 취급한다.

### 43. ID Change Protection

Stage Logical ID 변경 시 다음 참조를 검사한다.

- Stage Catalog
- Campaign
- Chapter
- Player Progression
- 기타 Content Reference

영향 범위를 확인하지 못한 경우 ID 변경을 차단한다.

### 44. Name / ID Separation

Display Name 변경은 일반적인 Authoring 작업으로 허용하되 Logical ID 변경은 참조 무결성 검증을 요구한다.

예:
- Stage Name: 일반 수정
- Stage ID: 영향 분석 후 변경

### 45. Stage Dependency Graph

Stage가 참조하는 전체 Content Dependency를 확인할 수 있는 구조를 P1 후보로 둔다.

예:
Stage
→ Map
→ Gameplay Points / Areas
→ Mission
→ Reward
→ Enemy
→ Allied Unit
→ Visual Assets

이를 통해 변경 영향과 삭제 보호를 지원한다.

### 46. Reverse Usage Lookup

다른 Content를 선택했을 때 해당 Content를 사용하는 Stage를 역조회할 수 있어야 한다.

대상:
- Map
- Mission
- Reward
- Enemy
- Unit
- Asset

이 기능은 삭제 보호 및 Change Impact와 연계한다.

### 47. Production Lock

Stage의 제작 상태를 구분한다.

권장 상태:
- Draft
- Gameplay Valid
- Content Complete
- Runtime Verified
- Production Locked
- Deprecated

Production Locked Stage는 일반 Authoring 작업으로 변경하지 않는다.

### 48. Transactional Save / Recovery

Stage 저장은 다음 순서를 따른다.

Validate
→ Build Definition
→ SQLite Transaction
→ Commit
→ Reload
→ Verify

저장 실패 또는 Migration 실패 시 기존 Definition을 유지하고 부분 저장 상태를 허용하지 않는다.

### 49. Schema Migration Failure

Definition Schema가 변경될 경우 Migration 실패를 명시적으로 처리한다.

Migration 실패 시:
- Save Blocked
- 기존 데이터 유지
- 오류 원인 표시

자동 변환에 실패한 데이터를 조용히 저장하지 않는다.

### 50. Stage Comparison

P2 후보로 Stage Definition 간 비교 기능을 둔다.

비교 대상:
- Map
- Mission
- Reward
- Gameplay Settings
- Encounter
- Wave
- Enemy Groups
- Allied Support

이는 Story Stage 변형 및 Balance 검토에 활용한다.

### 51. Balance Analysis Boundary

문법적 Valid와 Balance Valid를 구분한다.

향후 Balance Analyzer 후보:
- 총 Enemy 수
- 예상 전투 시간
- Enemy HP
- 예상 DPS
- Wave 밀도
- 예상 Gold

Balance Analyzer는 현재 Runtime Contract Validation과 분리하며, Runtime 지원 없이 임의의 난이도 판정을 만들지 않는다.

### 52. Campaign Difficulty Curve

Story Campaign 확장 시 Stage별 난이도뿐 아니라 전체 Campaign의 난이도 곡선을 분석할 수 있도록 확장 가능성을 남긴다.

단, 난이도 지표가 정의되기 전에는 자동 판정을 구현하지 않는다.

### 53. Unused Content Detection

Campaign에서 사용하지 않는 Stage,
Stage에서 사용하지 않는 Encounter,
Runtime에서 참조되지 않는 Asset 등을 탐지하는 기능을 P1/P2 후보로 둔다.

탐지 결과는 삭제 명령이 아니라 경고로 제공한다.

### 54. Regression Test Registration

중요 Stage를 Runtime 회귀 테스트 대상으로 등록할 수 있도록 확장 가능성을 둔다.

예:
- Tutorial Stage
- Standard Combat Stage
- Giant Stage
- Final Stage

자동화 테스트 PASS와 PIE VERIFIED는 별도로 관리한다.

### 55. Final Stage Explicit Definition

현재 Runtime이 Campaign Stage 배열의 마지막 Stage를 최종 Stage로 처리하는 구조이므로, 향후 명시적인 Final Stage 지정이 필요할 경우 이를 지원할 수 있는 구조를 고려한다.

현재 Runtime을 변경하지 않고 요구사항으로만 관리한다.

### 56. Replay / Restart Policy

Story Campaign에서 Stage 재플레이와 Defeat 후 재시작 정책을 별도로 정의해야 한다.

향후 검토 대상:
- 완료 Stage 재플레이 가능 여부
- Reward 재지급 여부
- Player Progress 유지 여부
- Defeat 후 동일 Stage 재시작
- Checkpoint 사용 여부

Runtime 정책이 확정되기 전에는 Editor 기능으로 구현하지 않는다.

### 57. Stage Runtime Contract

Stage가 Runtime에서 실행 가능한 최소 조건을 명시한다.

최소 계약:
- Map 존재
- Mission 존재
- Reward 존재
- Enemy Spawn 존재
- Enemy Reference 유효
- Wave 존재
- Goal 존재
- Victory 조건 존재
- Defeat 조건 존재

Stage Editor Validation은 이 Contract를 기준으로 Runtime 실행 가능성을 검사해야 한다.

### 58. Authoring Completion Gate

Stage의 완료 상태를 단순 Save 성공과 동일하게 취급하지 않는다.

권장 Gate:
1. Definition Valid
2. Reference Valid
3. Runtime Contract Valid
4. SQLite Save
5. Reload
6. Logical Equality Verify
7. Runtime Test
8. Campaign Integration Verify
9. Production Lock

### 59. Priority

P0:
- Stage Runtime Contract
- Reference/ID Integrity
- Numeric/Time Validation
- Null/Default/Override 규칙
- Transactional Save / Reload / Verify
- ID Change Protection

P1:
- Definition Preview
- Dependency Graph
- Reverse Usage Lookup
- Production State
- Regression Registration
- Validation/Runtime Gate UI

P2:
- Stage Comparison
- Balance Analysis
- Campaign Difficulty Curve
- Replay/Restart Authoring UI
- Advanced Migration UI
- Unused Content Dashboard

### 60. Review Judgment

CONFIRMED:
현재 Stage Runtime은 Map, Mission, Reward, Encounter, Wave, Enemy Group, Allied Support 및 Stage Gameplay Override를 소비한다.

PROPOSAL:
Stage Editor의 장기 Production 기준은 Authoring 기능 자체보다 Runtime Contract, Reference Integrity, Dependency/Impact, Transactional Persistence를 중심으로 구성한다.

UNVERIFIED:
Replay 정책, Deterministic Seed, Balance 지표, Stage Entry/Exit 데이터 전달, Final Stage 명시 방식은 현재 Runtime 계약이 충분히 정의되지 않았으므로 구현하지 않는다.

OUT OF SCOPE:
현재 Runtime이 소비하지 않는 Story Event, Branching, 고급 Objective, Balance 자동 판정 등은 Stage Editor에 선행 구현하지 않는다.

Status:
CODE VERIFIED — 관련 Runtime/Loader 구조 기준
EDITOR VERIFIED — 현재 Stage Editor 기준
BUILD VERIFIED — 기존 Windows Release Build
PIE VERIFIED — UNVERIFIED


## FACTION EDITOR — CONTENT ORGANIZATION AND RELATIONSHIP REQUIREMENTS (2026-10-07)

### 61. Faction Responsibility
Faction is the organizational entity for grouping and managing game content by affiliation. It is not merely a color or display label.

Primary managed relationships:
- Faction → Robot
- Faction → Unit
- Faction → Enemy
- Faction → Tower
- Faction → Building

Faction Editor must act as a relationship/registry hub. It must not duplicate the detailed authoring responsibility of those content editors.

### 62. Faction Identity
Required identity data:
- Faction ID
- Display Name
- Description
- Display Color, if retained as authoring/runtime data
- Production State: Draft / Valid / Invalid / Deprecated / Production Lock

Internal ID and display name must remain separate.

### 63. Faction Content Registry
Selecting a Faction should expose its current content composition:
- Robot list and count
- Unit list and count
- Enemy list and count
- Tower list and count
- Building list and count
- Unassigned content where assignment is required
- Invalid references
- Unused content

Each listed content item should be navigable to its owning Editor.

### 64. Bidirectional Relationship Management
The authoring system must support:
- Faction → content lookup
- Content → Faction lookup
- Faction-side reassignment where permitted
- Content Editor-side reassignment
- immediate refresh of both views after a valid change

Faction Editor remains the relationship hub; detailed content properties remain owned by their respective Editors.

### 65. Reference Integrity and Protection
The system must detect:
- content referencing a missing Faction
- content requiring a Faction but having no assignment
- duplicate/ambiguous Faction identity
- invalid Faction references

Deletion or ID changes must show affected content before execution. Referenced Factions must not be silently deleted or renamed.

### 66. Faction Deletion / ID Change Safety
Required behavior:
- show direct references before delete
- show direct references before ID change
- protect referenced Factions from unsafe deletion
- support Deprecated state instead of destructive removal where appropriate
- preserve ODB PK / logical ID distinction
- show change impact before committing a destructive or high-impact operation

### 67. Unassigned Content Management
Content types that require a Faction must be detectable when unassigned.
The rule must be content-type specific; do not assume every content type requires a Faction.

The editor should provide an unassigned-content view for production cleanup.

### 68. Faction Validation
Faction-level validation should report:
- missing references
- invalid references
- required-but-unassigned content
- invalid Faction state
- duplicate IDs
- broken relationship data
- content whose authoring state prevents production readiness

Validation should distinguish Error / Warning / Info and support navigation to the affected content.

### 69. Faction Content Creation
Where supported, creating content from a Faction context should preassign the current Faction.
Example: Faction → Add Robot → faction_id = current Faction

This is an authoring convenience and must not bypass the owning content Editor's validation.

### 70. Faction Duplicate / Template
Future P1/P2 capability:
- duplicate Faction identity
- optionally duplicate selected content
- explicitly define whether Visual Assets are shared or duplicated
- preserve reference integrity during duplication

Do not silently clone dependent content or assets.

### 71. Reverse Usage / Impact Analysis
Faction should provide reverse usage information:
- Faction → Content
- Content → Stage usage
- Content → Campaign/Chapter usage where resolvable

Direct ownership and indirect runtime usage must be distinguished.

### 72. Story / Stage Relationship Boundary
A Stage or Campaign must not automatically become Faction-owned merely because it uses Faction content.
Faction usage should be derived through referenced content unless the Runtime contract explicitly introduces direct Faction references.

### 73. Localization
Faction ID must remain language-independent.
Display Name and Description should be localizable through the existing localization authority when localization is required.

### 74. Faction Color Contract
Current investigation found a data-boundary mismatch: Faction Editor stores color, while the current FactionDefinition does not consume it.
Therefore Faction Color must be explicitly classified as either Runtime-consumed Faction data or Authoring-only metadata.

No Runtime dependency should be introduced without confirming the Runtime contract.

### 75. Production Readiness Summary
Faction Editor should provide a concise readiness summary by content type, including valid/draft/invalid counts, missing/broken references, and overall Faction readiness.

### 76. Faction Filtering
Other content Editors should be able to filter/select content by Faction through selector-based references rather than free-text IDs where practical.

### 77. Faction-to-Story Visibility
P1 capability:
- show where a Faction's content is used in Stages
- show resolvable Campaign/Chapter usage
- distinguish direct Faction references from derived usage

This is an inspection feature, not a new gameplay ownership relationship.

### 78. Production Statistics
Faction Editor may expose production statistics such as total content count by type, valid/invalid/draft counts, unassigned count, unused count, and missing asset/reference count. These are authoring aids unless explicitly required by Runtime.

### 79. Recommended Priority
P0:
- Faction identity
- content registry by type
- bidirectional reference visibility
- missing/invalid/unassigned validation
- delete/ID-change protection
- Save → Reload → Verify
- central Validation integration

P1:
- Faction filtering in other Editors
- Reference Inspector
- reverse usage lookup
- change impact view
- readiness statistics
- Add Content from Faction context
- localization support

P2:
- Faction duplication/template
- advanced production dashboards
- Alliance/Hostility relationship system, only after Runtime contract exists

### 80. Runtime Boundary
Current Runtime evidence confirms Faction is referenced by Robot content, but does not establish a complete Faction-based combat relationship system. Alliance/Hostility, automatic targeting rules, faction-wide buffs, and similar combat semantics remain future requirements until Runtime support is confirmed.

### 81. Review Judgment
CONFIRMED: Faction is needed as a content organization and relationship-management entity across Robot/Unit/Enemy/Tower/Building.
CONFIRMED: Faction Editor should provide registry, reference integrity, impact protection and production visibility.
UNVERIFIED: complete Runtime consumption of Faction beyond current content references.
PROPOSAL: implement Faction as an authoring/relationship hub first, without prematurely introducing combat semantics.

Status:
- CODE VERIFIED — current Faction Editor/Repository/Definition and Robot reference inspected
- EDITOR VERIFIED — current Faction authoring structure inspected
- BUILD VERIFIED — prior project build remains valid
- PIE VERIFIED — UNVERIFIED

No Runtime or Editor code change was made by this review.


## ROBOT EDITOR — COMBAT LOADOUT AND COMMAND BEHAVIOR REQUIREMENTS (2026-10-07)

### 82. Robot Responsibility
Robot Editor는 Robot의 정체성, Faction, 기본 전투 스탯, 성장/Energy, Combat Loadout, Command Capability, Visual/Animation Asset 참조를 정의한다. Robot Definition과 Runtime Robot State는 분리한다.

### 83. Combat Loadout
- Basic Attack — 자동 사용
- Skill 1 — 자동 사용
- Skill 2 — 자동 사용
- Skill 3 — 자동 사용
- Special — 수동 발동만
- Finisher — 수동 발동만
각 슬롯은 Skill ID를 참조하며 Skill의 실제 효과/수치는 Skill Editor가 담당한다.

### 84. Skill Usage Policy
Basic Attack와 Skill 1~3은 AUTO, Special과 Finisher는 MANUAL 정책을 갖는다. AUTO/MANUAL은 UI 표시가 아니라 Runtime 행동 규칙의 일부로 취급한다.

### 85. Combat Loadout과 Animation Asset 분리
COMBAT LOADOUT과 ANIMATION ASSETS를 별도 영역으로 관리한다. Skill ID와 Animation Asset ID는 서로 다른 참조이며 데이터를 중복 저장하지 않는다.

### 86. Map Command Behavior
맵/미니맵 클릭 명령은 전투 Skill과 별도의 Command 체계로 관리한다.
- A — Assault (수용된 권고안)
- P — Patrol / Recon
- H — Hold
- M — Move
A/P/H/M은 Skill 슬롯이 아니라 지정된 맵/미니맵 클릭 지점에 대한 행동 명령이다.

### 87. Command ID와 Shortcut Key 분리
예: Key=A, Command ID=assault, Display Name=Assault. 단축키 변경이나 다국어화가 콘텐츠 참조를 깨뜨리지 않아야 한다.

### 88. Command Target Rules
Assault, Patrol/Recon, Hold, Move 각각 허용되는 클릭 대상과 유효성을 정의한다. 메인 맵과 미니맵 입력은 동일한 Runtime 좌표/Gameplay Point 체계로 변환한다.

### 89. Command Execution Rules
각 명령의 지속, 종료, 취소 조건을 정의한다. Move는 도착 시 종료, Hold는 재명령/취소 전 유지, Patrol/Recon과 Assault는 Runtime에서 명시적인 완료 조건을 갖는다.

### 90. Command와 Auto Combat 관계
Command State와 자동 전투 AI의 관계를 명시한다. 예를 들어 Hold 중 자동 공격/Skill 1~3 사용 여부, 이동 중 적 발견 시 추적/공격/무시 여부를 암묵적으로 처리하지 않는다.

### 91. Command Priority / Cancel / Queue
새 명령의 기존 명령 대체 여부, 긴급 명령 우선순위, 취소, 동일 명령 재입력, 큐 지원 여부를 정의한다. 초기 Runtime은 단일 현재 명령 방식으로 구현 가능하다.

### 92. Multi-Robot Command
여러 Robot에 동일 명령을 내릴 수 있는 경우 Formation/Spacing 정책을 별도로 정의한다. 현재 위치와 경로는 Robot Definition에 저장하지 않는다.

### 93. Map Gameplay Integration
가능한 경우 자유 좌표보다 Map Editor의 Gameplay Point/Area를 명령 대상으로 우선 사용한다. Map이 공간 의미를 정의하고 Robot은 명령을 수행한다.

### 94. Command Capability
A/P/H/M을 공통 명령 체계로 두는 것을 기본으로 하며, 특정 Robot의 제한이 실제로 필요할 때만 Capability로 제한한다.

### 95. Runtime State Boundary
Robot Definition에는 현재 명령, 목표, 이동 좌표/경로, 현재 타깃, 쿨다운, Energy, HP, 생존 상태를 저장하지 않는다. 이는 Runtime Robot State가 관리한다.

### 96. Robot Authoring Validation
Robot ID, Faction, Skill 1~3/Special/Finisher 참조, Skill 중복/호환성, Auto/Manual 정책, 기본 전투 수치, Visual Asset, Animation Asset, Command Capability를 검증한다.

### 97. Faction Relationship
Faction은 Robot의 소속을 정의한다. Faction Editor는 Robot 상세 전투 데이터를 중복 편집하지 않고 Faction별 구성/관계를 관리하며 Robot Editor는 유효한 Faction을 선택한다.

### 98. Reference / Change Protection
Robot ID 변경/삭제는 Stage Enemy Group, Allied Support, Faction Registry 및 기타 직접/간접 참조에 영향을 줄 수 있으므로 Reverse Usage와 영향 범위를 확인한 뒤 처리한다.

### 99. Save / Reload / Verify Gate
Edit → Validate → Build Definition → SQLite Save → Reload → Verify → Saved 순서를 Production 기준으로 한다.

### 100. Editor UI Responsibility
Robot Editor는 Identity, Faction, Base Stats, Progression/Energy, Combat Loadout, Command Behavior, Visual Assets, Animation Preview, Validation/Reference Information을 분리 표시한다.

### 101. Runtime Boundary Review
현재 Runtime의 Robot 스탯, Energy, Visual/Animation, Special 관련 소비는 확인되었다. Skill 1~3 자동 사용과 Special/Finisher 수동 발동을 Robot Definition의 명시적인 Loadout/Usage Policy로 완전히 소비하는 경로와 A/P/H/M 전체 Command 시스템은 추가 구현 검증이 필요하다. 따라서 콘텐츠 정의는 수용하되 PIE VERIFIED로 승격하지 않는다.

### 102. Review Judgment
Robot Editor의 핵심 책임은 Robot 정체성/소속, 기본 전투 스탯, 자동/수동 전투 Loadout, Skill 참조, 맵 명령 Capability, Visual/Animation 참조, Runtime 참조 무결성 관리이다. Skill 효과는 Skill Editor, 공간 의미는 Map Editor, 현재 행동 상태는 Runtime이 담당한다.

**Priority**
- P0: Combat Loadout, Skill Reference, Auto/Manual Policy, Faction Reference, Validation, Save→Reload→Verify, Reference Protection
- P1: Command Capability UI, Map Gameplay Point/Area Selector, Reference Inspector, Reverse Usage, Multi-Robot Command
- P2: Command Queue, advanced Formation, advanced Patrol/Assault behavior

**Status:** CODE VERIFIED / EDITOR VERIFIED / BUILD VERIFIED / PIE VERIFIED UNVERIFIED
**변경 사항:** 요구사항 문서만 갱신. Runtime/Editor 코드 변경 없음.


## UNIT / ENEMY EDITOR — FIXED SIX-UNIT FACTION STRUCTURE AND AI-ONLY UNIT REQUIREMENTS (2026-10-07)

### 103 Unit Responsibility and Canon

- Unit은 Faction에 소속된 전투 유닛이다.
- Faction당 Unit 종류는 정확히 6종으로 관리한다.
- Unit에는 성장 시스템을 두지 않는다.
- Unit 레벨, XP, 성장률, 성장 트리, 장비 성장, 진화 시스템은 Unit Definition 범위에서 제외한다.
- 성장의 주체는 Robot이다.
- Unit은 Robot 성장 과정에서 전투 대상 및 진영 전력으로 기능한다.
- Unit은 RTS와 같은 대량 유닛 운용을 목표로 하지 않는다.

### 104 Player Control Boundary

- Unit은 유저가 직접 제어하지 않는다.
- A / P / H / M 등의 Robot 직접 명령 체계를 Unit에 적용하지 않는다.
- Unit 행동은 Runtime AI가 결정한다.
- Unit Editor에는 직접 조작용 Command 설정을 넣지 않는다.
- Robot은 직접 조작 및 성장의 중심이고 Unit은 AI 전투 개체라는 책임 경계를 유지한다.

### 105 Six Unit Role Structure

현재 확정된 5개 역할:

1. 경량 근접
2. 기본 만능 — 근접 + 원거리
3. 지원 / 수리
4. 헤비 근접
5. 공중 / 비행 원거리

- 6번째 역할은 아직 확정하지 않는다.
- 6번째 역할은 기존 5개와 중복되지 않는 실제 전술적 필요를 확인한 후 결정한다.
- Faction당 동일 Role Slot을 중복 등록하지 않는 것을 원칙으로 한다.
- Role ID와 실제 Unit ID는 분리한다.

### 106 Role Definitions

- 경량 근접: 기동, 추격, 근접전 중심.
- 기본 만능: 근접과 원거리 모두 가능하며 어느 한쪽에도 과도하게 특화되지 않은 기준형.
- 지원 / 수리: 아군 유지력과 지원을 담당하며 직접 전투력은 상대적으로 제한한다.
- 헤비 근접: 높은 내구성과 강한 근접전, 전선 유지가 핵심이다.
- 공중 / 비행 원거리: 공중 이동과 원거리 공격을 결합한다.
- 역할은 단순 능력치 차이가 아니라 전투 목적과 행동 방식으로 구분한다.

### 107 Faction Balance Contract

- 모든 Faction은 6개 Unit Role 구조를 공유한다.
- Faction 간 차이는 역할의 구현 방식과 전술에서 만든다.
- 특정 Faction의 Unit이 단순 능력치 우위만으로 구조적 우위를 갖지 않도록 한다.
- 목표는 비대칭적 역할과 전술적 차이를 허용하면서 전체 전투 가치를 비슷하게 유지하는 것이다.
- 1:1 및 Multiplayer에서도 이 원칙을 유지한다.
- 모든 Unit의 수치를 동일하게 만드는 것이 목표는 아니다.

### 108 Unit Role / Unit Definition Separation

- Role은 전투 목적을 정의한다.
- Unit Definition은 실제 Faction 소속 Unit의 개체 정의를 담당한다.
- 예: LIGHT_MELEE는 Role ID이고 unit_excelion_01은 Unit ID이다.
- 같은 Role을 여러 Faction에서 구현할 수 있다.
- 하나의 Faction 안에서는 동일 Role의 중복 등록을 방지한다.

### 109 Unit AI Boundary

Unit은 전략을 결정하는 주체가 아니라 전투 상황에 반응하는 전술 AI로 제한한다.

최소 AI 책임:
- 타깃 탐색
- 이동
- 공격
- 추격
- 지원
- 필요 시 복귀 / 재배치
- 사망 처리

전략적 목표 선정, Campaign 진행, Stage 목표 변경 등은 Unit AI 책임에서 제외한다.

### 110 Role-Based AI Behavior

Role에 따라 기본 행동 우선순위를 정의한다.

- 경량 근접: 적 접근 → 공격 → 제한된 추격 → 복귀
- 기본 만능: 거리와 상황에 따라 근접 / 원거리 공격 선택
- 지원 / 수리: 생존 → 아군 탐색 → 수리 / 지원 → 필요 시 공격
- 헤비 근접: 전선 유지 → 접근 → 공격
- 공중 / 비행 원거리: 이동 자유도와 사거리 우위를 활용한 원거리 공격

AI Profile과 Role은 필요하면 분리할 수 있으며, Role 자체를 복잡한 AI 트리로 만들지 않는다.

### 111 Target and Action Rules

- Unit은 타깃 우선순위를 가져야 한다.
- 지원 Unit은 적 공격보다 아군 지원을 우선할 수 있다.
- 기본 만능 Unit은 근접 / 원거리 전환 조건을 명확히 한다.
- 공중 Unit은 공격 가능한 대상과 이동 가능 영역을 명확히 한다.
- 타깃 상실, 경로 실패, 공격 불가 상황에 대한 복구 상태를 정의한다.
- AI 판단은 과도한 매 프레임 재평가를 피하고 명확한 갱신 주기를 갖는다.

### 112 Activity, Return, Collision Rules

- Unit의 활동 범위와 최대 추격 범위를 정의한다.
- 추격 종료 후 Spawn Point, Assigned Area 등 명시된 기준 위치로 복귀할 수 있어야 한다.
- Unit이 맵 전체를 무제한 추격하는 행동은 허용하지 않는다.
- 같은 진영 Unit 간 이동 충돌 및 전선 정체를 방지한다.
- Robot과 Unit의 이동/충돌 관계를 Map Movement/Blocked 규칙과 일치시킨다.
- 공중 Unit은 지상 Unit과 이동 및 장애물 규칙을 구분한다.

### 113 Stage / Runtime Ownership

- Unit Definition은 무엇인지를 정의한다.
- Stage는 언제, 몇 개, 어디에서 등장하는지를 정의한다.
- Runtime은 실제 생성, 이동, 공격, 사망, 재생성을 실행한다.
- Unit Definition에 Stage별 spawn_count나 전투 배치 데이터를 중복 저장하지 않는다.
- Unit 사망 및 재생성 정책은 Stage/Runtime 책임으로 분리한다.

### 114 Unit Count vs Unit Type Count

- Faction당 6종이라는 종류 제한과 실제 전장 동시 존재 수는 별개의 개념이다.
- Unit Type Count는 Faction authoring 규칙으로 관리한다.
- 실제 Unit 수량은 Stage 또는 Multiplayer 규칙이 관리한다.
- 이 구분을 통해 Unit 종류가 적더라도 대량 RTS 구조로 확장되는 것을 방지한다.

### 115 Support / Repair Contract

- 지원 / 수리 Unit의 지원 대상 범위를 명확히 정의한다.
- Robot을 지원 대상으로 허용할 경우 Robot의 생존성과 전투 밸런스에 미치는 영향을 별도로 검증한다.
- 지원량만으로 필수 Unit이 되지 않도록 전체 전투 가치 기준으로 평가한다.
- 지원 효과와 Robot 성장 시스템을 직접 결합하지 않는다.

### 116 Robot Growth Boundary

- Unit은 성장하지 않는다.
- Unit 처치가 Robot 성장에 기여할 수 있다면 Combat Result가 Growth System으로 전달하는 구조를 사용한다.
- Unit Definition에 XP/Reward를 직접 소유시키지 않는다.
- Unit의 보상 값과 Robot 성장 규칙을 분리한다.

### 117 Campaign / Multiplayer Definition Sharing

- Campaign과 Multiplayer는 기본적으로 동일한 Unit Definition을 공유하는 방향을 권고한다.
- 모드별 능력치 복제는 밸런스와 유지보수 비용을 증가시키므로 기본값으로 허용하지 않는다.
- Multiplayer에서 Robot 성장 상태를 어떻게 처리할지는 별도 PvP 규칙으로 정의한다.

### 118 Unit Editor Authoring Requirements

Unit Editor는 최소 다음을 제공해야 한다.

- Unit ID
- Display Name
- Faction selector
- Role selector
- Combat Stats
- Weapon
- AI Profile / 행동 설정
- Visual Assets
- 참조 상태
- Validation 결과
- Save → Reload → Verify

다음 항목은 Unit Editor에서 제공하지 않는다.

- Unit Level
- Unit XP
- Unit Growth
- Player Command A/P/H/M
- Campaign 진행 데이터
- Stage별 Spawn Count
- Reward 정의의 중복 입력

### 119 Faction Six-Unit Completion Gate

Faction의 Unit 구성 상태를 Faction Editor에서 확인할 수 있어야 한다.

예:
- 5 / 6 → INCOMPLETE
- 6 / 6 → COMPLETE
- 동일 Role 중복 → INVALID
- Faction 미지정 → INVALID

Production Ready 조건에는 다음을 포함한다.

- 6개 Unit Definition 존재
- 6개 유효한 Role
- Faction 참조 정상
- AI 정의 정상
- Combat 정의 정상
- Visual 참조 정상
- Save → Reload → Verify 성공

### 120 Unit Validation and Production Safety

검증 대상:
- Unit ID 중복
- Faction 참조 오류
- Role 중복
- 6종 초과 / 미달
- 필수 Combat 값 누락
- 유효하지 않은 AI 설정
- Visual 참조 오류
- 지원 대상 오류
- 사용되지 않는 Unit
- 삭제 / ID 변경 시 참조 영향

Unit 삭제 및 ID 변경은 Faction, Stage, Campaign, Runtime 참조를 확인한 후 허용해야 한다.

### 121 Complexity Control

Unit 시스템은 다음 방향으로 확장하지 않는다.

- 대량 Unit 생산
- RTS식 전략 AI
- Unit 성장 트리
- Unit 장비 성장
- Unit별 복잡한 스킬 트리
- 플레이어 직접 Unit 명령
- Unit이 Campaign 전략을 결정하는 구조

필요한 전술적 차이는 Role, AI 행동, Combat Stats, Weapon, Map 관계로 표현한다.

### 122 Review Judgment

현재 Unit Canon의 핵심은 다음과 같다.

**Faction당 정확히 6종 → Unit 성장 없음 → 유저 직접 제어 없음 → 제한된 전술 AI → Stage가 등장 구성 관리 → Robot이 성장의 중심 → Faction 간 전체 전투 가치 균형**

현재 확정 역할은 5종이며 6번째는 보류한다.

Status:
- CODE VERIFIED — 현재 Unit/Enemy 구조와 Runtime 경계 확인
- EDITOR VERIFIED — 현재 Unit Editor 구조 확인
- BUILD VERIFIED — 기존 프로젝트 Build 상태 기준
- PIE VERIFIED — UNVERIFIED
- No Runtime code change

## TOWER EDITOR — FACTION / FOUR-TOWER / EMP / UPGRADE REQUIREMENTS (2026-10-07)

### 123. Tower Responsibility
Tower는 Faction 소속의 고정 전투 시설이다. Tower Definition은 Tower가 무엇인지 정의하고, Map은 어디에 설치 가능한지를 정의하며, Stage는 해당 전투에서 어떤 Tower가 사용되는지를 정의한다. Tower는 Robot의 성장 시스템과 분리한다.

### 124. Faction Tower Structure
기본적으로 각 Faction은 정확히 4종의 Tower를 갖는다.
- Ground 대응 Tower 1종
- Air 대응 Tower 1종
- All-purpose Tower 2종
- All-purpose Tower 2종은 EMP/Debuff 계열로 운용한다.
Faction Editor는 Tower 구성 상태를 4/4로 확인할 수 있어야 한다.

### 125. Tower Role / Target / Effect Separation
Tower Role, Target Coverage, Effect, Attack Method를 동일 필드로 취급하지 않는다.
- Role: Ground / Air / All-purpose
- Target Coverage: Ground / Air / Ground+Air 등
- Effect: Damage / EMP / Debuff 등
- Attack Method: Single / Area / Pierce 등
실제 Runtime이 지원하는 조합만 Authoring UI에서 선택할 수 있어야 한다.

### 126. EMP Combat Contract
EMP는 일반 Damage와 별도의 전투 효과로 취급한다. 최소 계약은 EMP 적용량, 지속시간, 적용 대상, 재적용 규칙, 중첩 규칙, 면역/저항 여부, Recovery Delay, Recovery Rate를 정의할 수 있어야 한다.

### 127. Robot / Heavy EMP Recovery Boundary
Robot과 Heavy의 빠른 EMP 회복은 Tower Definition이 아니라 대상의 전투 능력/Runtime State가 소유한다. Tower는 EMP 효과를 발생시키고 대상은 자신의 EMP 상태와 회복 규칙을 관리한다.

### 128. EMP State
필요한 경우 대상 Runtime State에 다음 개념을 분리한다.
- EMP Max
- EMP Current
- EMP Apply
- EMP Disable/Lock
- EMP Recovery Delay
- EMP Recovery Rate
- Full Recovery
EMP 상태는 Definition과 Runtime State를 구분한다.

### 129. EMP Reapplication / Stacking
EMP가 중복 적용될 때의 합산, 최대값 유지, 지속시간 갱신, 중첩 제한 등의 규칙은 명시적인 Runtime 계약으로 정의한다. 현재 구체적인 중첩 정책은 UNDECIDED이며 임의 구현하지 않는다.

### 130. Tower Attack / EMP Cooldown Boundary
일반 공격과 EMP 효과가 동일 공격의 부가 효과인지 별도 발동인지 명확한 Runtime 계약이 필요하다. 현재는 EMP 효과를 일반 Damage와 독립적인 Effect로 모델링할 수 있도록 구조를 열어 둔다.

### 131. Tower Upgrade
Tower는 Upgrade를 가진다. Upgrade는 Tower 설치 비용과 분리한다.
최소 데이터는 Upgrade Cost, 현재 Level, 최대 Level, Upgrade 조건, Upgrade 후 적용 능력치이다.
현재 Runtime에는 Level 2 Upgrade가 존재하므로 기존 Level 2 동작과 호환되어야 한다.

### 132. Upgrade Effect Scope
Upgrade가 변경할 수 있는 항목은 명시적으로 제한한다. 현재 확인된 기본 항목은 Damage, Cooldown, Range이며, EMP 효과/지속시간 등의 강화는 별도 결정이 필요하다.

### 133. Upgrade Runtime Timing
전투 중 Upgrade가 가능한 경우 Upgrade 효과 적용 시점, 공격 중 처리, Cooldown 초기화 여부를 정의해야 한다. 아직 Runtime 계약이 없으면 구현하지 않는다.

### 134. Tower Installation Boundary
Tower Definition과 Map Placement를 분리한다.
- Tower Editor: Tower의 정의
- Map Editor: 설치 가능 위치/Placement Point
- Stage: 전투에서의 사용 구성
지상/공중은 공격 대상 범위와 설치 위치 타입을 혼동하지 않는다.

### 135. Targeting Rules
Target Preference는 자유 문자열보다 Runtime이 지원하는 제한된 Selector/Enum으로 관리한다. 최소한 Ground, Air, Ground+Air 및 실제 지원하는 Target Priority를 구분할 수 있어야 한다.

### 136. Giant Target Compatibility
Giant가 일반 적과 다른 Target Category를 갖는 경우 Tower의 Giant 공격 가능 여부를 명시해야 한다. 현재 Giant Runtime은 존재하지만 Tower별 Giant Target 규칙은 UNVERIFIED이다.

### 137. Faction / Hostility Boundary
Faction은 소속을 나타내며 공격 가능 여부를 자동으로 결정하는 Hostility 시스템과 동일시하지 않는다. Alliance/Hostility가 필요한 경우 별도 Runtime 계약으로 정의한다.

### 138. Tower / Robot Role Boundary
Tower는 전장을 보조하고 통제하는 고정 전력이며 Robot은 성장하고 직접 전투에 개입하는 핵심 전력이다. Tower의 고성능화가 Robot 성장축을 대체하지 않도록 역할을 분리한다.

### 139. Tower Balance
Faction 간 동일 역할 Tower는 단순 공격력만 비교하지 않고 Cost, Damage, Cooldown, Range, EMP 가치, Upgrade 가치를 종합해 비교할 수 있어야 한다. 1:1 및 Multiplayer에서도 Faction 간 총 전투 가치가 과도하게 벌어지지 않도록 한다.

### 140. Tower Usage / Impact Lookup
Tower Editor는 가능하면 Tower가 사용되는 Map, Stage, Campaign 등의 역참조를 확인할 수 있어야 한다. 삭제 또는 ID 변경 시 영향 범위를 확인할 수 있어야 한다.

### 141. Tower ID / Delete Protection
SQLite ODB PK와 논리 ID를 분리한다. 참조 중인 Tower의 ID 변경 또는 삭제는 단순 문자열/행 삭제로 처리하지 않는다. 영향 참조를 확인하고 Production 데이터 손상을 방지한다.

### 142. Tower Production State
Tower는 필요 시 Draft, Valid, Production, Deprecated 등의 상태를 가질 수 있다. Production Lock은 추후 적용하며 현재 구현하지 않는다.

### 143. Tower Balance / Runtime Test
Tower별 최소 검증은 Definition Load, Faction Reference, Combat Values, Target Rule, Upgrade 적용, Visual/Projectile Reference, EMP Effect, Runtime Attack, Upgrade 후 Attack을 대상으로 한다.
Editor Preview는 Runtime 검증을 대체하지 않는다.

### 144. Game Changer Tower
Game Changer급 Tower는 현재 UNDECIDED다. 기본 4종에 억지로 포함하거나 임의 능력을 구현하지 않는다. 향후 추가될 경우 단순 고화력 Tower가 아니라 전장 규칙 또는 전술 구조를 변경하는 별도 범주가 될 가능성을 고려한다.

### 145. Economy Boundary
Tower Build Cost와 Upgrade Cost를 분리한다. 판매, 환급률, 설치 취소 등의 경제 규칙은 현재 요구사항에 포함하지 않으며 실제 Runtime 필요성이 확인될 때 별도 정의한다.

### 146. Visual / Combat Separation
Tower Combat Definition과 Visual Asset/Projectile Animation Reference를 분리한다. Visual Asset은 Catalog/Asset 시스템이 관리하고 Tower Definition은 참조만 보유한다.

### 147. SQLite Authoring Model
JSON을 UI에서 편집하는 것이 목표가 아니다. Editor UI는 semantic authoring interface이며 실제 Content Authority는 SQLite이다.
- Scalar data → SQLite columns
- Faction/Content references → normalized logical IDs / relations
- Upgrade / Effect 등 반복·하위 데이터 → 명시적 child table 또는 relation 구조
- Repository/Loader → SQLite에서 Runtime Definition 생성
JSON은 새로운 Authoring Authority로 추가하지 않는다.

### 148. Tower Authoring UI
Tower Editor는 최소한 Faction Selector, Tower Role, Target Coverage, Combat Values, Effect/EMP, Upgrade, Visual Asset Selector, Validation, Save/Reload/Verify를 제공해야 한다. Raw Dictionary/JSON 편집 UI는 목표가 아니다.

### 149. Four-Tower Completion Gate
Faction별 Tower Production Ready 조건은 최소 다음을 만족해야 한다.
1. Ground Tower 1/1
2. Air Tower 1/1
3. All-purpose Tower 2/2
4. 모든 Tower Faction Reference 유효
5. Combat Definition 유효
6. Upgrade Definition 유효
7. Visual/Projectile Reference 유효
8. SQLite Save → Reload → Verify 성공
9. Runtime Test 통과

### 150. Current Boundary
확정된 것은 Faction 소속, 4종 구조, Ground/Air/All-purpose 역할, All-purpose EMP/Debuff, Robot/Heavy의 빠른 EMP 회복, Tower Upgrade이다. Game Changer Tower의 구체적 설계, EMP 중첩 정책, 판매/환급, 일부 Upgrade 효과 범위는 아직 결정하지 않는다.

### 151. Review Judgment
Tower Editor는 단순 공격력/사거리 편집기가 아니라 Faction 소속의 고정 전투시설 Definition을 관리하는 Authoring UI가 되어야 한다. 핵심 Runtime 계약은 Tower → Effect/EMP → Target Runtime의 경계와 Tower → Upgrade → Runtime State의 경계다. SQLite 전환은 UI를 JSON 편집기로 바꾸는 작업이 아니라 Content 데이터를 SQLite 컬럼/관계로 저장하도록 변경하는 작업이다.

Status: CODE VERIFIED / EDITOR VERIFIED / BUILD VERIFIED / PIE VERIFIED UNVERIFIED
No Runtime code change performed during this review.

## BUILDING EDITOR — FACILITY FUNCTION / BASE / DIMENSION GATE / REPAIR FACTORY REQUIREMENTS (2026-10-07)

### 152. Building Responsibility
Building은 단순 HP/Sprite 객체가 아니라 Runtime Function을 가진 시설이다. 현재 Canon 시설은 Base, Dimension Gate, Repair Factory 3종이다.

### 153. Current Building Canon
- Base: 방어 및 Base HP/Defeat와 연결되는 핵심 시설
- Dimension Gate: Unit/Enemy가 Spawn되는 Spawn Origin
- Repair Factory: Robot을 수리하는 시설
추가 시설은 현재 범위에 포함하지 않는다.

### 154. Building Function Type
Building은 명칭이나 자유 문자열이 아니라 명시적인 Function Type으로 기능을 구분한다.
- BASE
- SPAWN_GATE
- REPAIR_FACTORY
새 Function을 추가할 때 기존 Building 구현을 복제하지 않고 확장 가능한 구조를 유지한다.

### 155. Function / Common Data Separation
Building 공통 데이터와 Function별 데이터를 분리한다. HP, Armor, Position, Rotation, Enabled 등 공통 속성과 Spawn/Repair/Defeat 등의 Function Parameter를 혼합하지 않는다.

### 156. Base Function
Base는 일반 Building HP와 별도로 Runtime의 Base HP 및 Defeat 조건과 연결된다. Stage의 Base HP 설정과 Building Definition의 기본값이 중복되어 서로 다른 값을 발생시키지 않도록 책임을 명확히 한다.

### 157. Dimension Gate Function
Dimension Gate 자체가 Spawn Anchor이다. 별도의 Spawn Point 객체를 중복 생성하지 않는 것을 기본으로 한다.
- Gate/Building ID가 Spawn Anchor 식별자 역할을 할 수 있다.
- Position은 Spawn Origin이다.
- Rotation은 필요 시 Spawn Direction으로 사용할 수 있다.
- Count, Spawn Interval, Wave Order는 Gate가 아니라 Stage/Enemy Group이 소유한다.

### 158. Stage / Gate Relationship
Stage의 Enemy Group은 어떤 Dimension Gate에서 Spawn할지 참조한다. 권장 관계:
Stage → Encounter → Wave → Enemy Group → Dimension Gate
Gate는 Map에 존재하고 여러 Stage에서 재사용될 수 있다.

### 159. Multiple Gate Support
하나의 Map에 여러 Dimension Gate가 존재할 수 있다. 하나의 Wave에서도 여러 Gate를 사용할 수 있어야 한다. Gate 자체에 일회성 사용 상태를 기본으로 부여하지 않는다.

### 160. Gate Active State
Map에 존재하는 Gate와 특정 Stage에서 실제 사용하는 Gate를 구분한다. 사용하지 않는 Gate가 존재하는 것 자체는 오류가 아니다.

### 161. Gate / Lane Separation
Dimension Gate는 실제 Spawn 위치이고 Lane은 이동/전투 경로다. Gate와 Lane을 동일 개념으로 취급하지 않는다.

### 162. Spawn Failure Contract
Gate 주변이 막혔거나 Spawn 공간이 부족한 경우 Runtime은 Spawn 실패를 감지해야 한다. 구체적인 재시도/지연/대체 위치 정책은 아직 UNDECIDED이며 임의 구현하지 않는다.

### 163. Spawn / Wave Completion Boundary
Spawn 예정, Spawn 완료, 전투 중, 사망 상태를 구분한다. Spawn 실패 또는 미생성 상태를 Wave 완료로 잘못 판정하지 않도록 Runtime 계약을 둔다.

### 164. Base / Gate / Robot Start Separation
Dimension Gate의 Enemy/Unit Spawn과 Robot 시작 위치는 별개다.
- Dimension Gate → Spawn Origin
- Robot Position → Robot 시작 위치
- Base → 방어/Defeat 시설

### 165. Repair Factory Function
Repair Factory는 Robot 수리 Function을 제공한다. 수리 기능은 Robot 성장/XP/Level/Stat Growth와 분리한다.

### 166. Repair Target Boundary
현재 Repair Factory의 수리 대상은 Robot을 기본 범위로 한다. Unit 수리 여부는 현재 결정하지 않으며 임의 확장하지 않는다.

### 167. Repair Method — UNDECIDED
다음 항목은 별도 Runtime 계약이 필요하다.
- Factory 접촉 수리 또는 범위 수리
- 자동 또는 수동 수리
- 수리량
- 수리 속도
- 수리 중 이동/공격/스킬 사용
- 수리 취소
- 동시 수리 가능한 Robot 수
현재 구체 규칙은 UNDECIDED이다.

### 168. Repair / Growth Separation
Repair Factory는 HP 회복만 담당하며 Robot의 성장, XP, Level, Stat Growth를 직접 변경하지 않는다.

### 169. Building Collision Boundary
Building이 실제 Collision을 가지는지 Gameplay Anchor인지 기능별로 구분한다. Dimension Gate는 기본적으로 Spawn Anchor로 취급하며 이동 차단 여부는 Map Runtime 규칙으로 결정한다.

### 170. Building Placement
Building 배치 정보는 Definition과 분리한다. Map이 Building의 위치, 회전, 활성 상태 및 설치 가능 조건을 관리한다.

### 171. Building / Map / Stage Boundary
- Building Editor: 시설이 무엇이며 어떤 Function을 제공하는가
- Map Editor: 시설이 어디에 존재하고 어디에 설치되는가
- Stage Editor: 해당 전투에서 어떤 시설/Spawn Gate를 사용하는가
- Runtime: Function을 실제 실행한다

### 172. Building Function / Runtime Event Separation
Building Definition은 기능과 파라미터를 정의하고 Runtime Event가 실제 발생 시점을 처리한다.
예: Dimension Gate → Spawn Function → Spawn Event → Runtime Spawn

### 173. Building Faction Boundary
Building의 Faction 소속 여부는 Tower와 동일하게 자동 결정하지 않는다. 현재 세 Building 각각의 Faction 소속 규칙은 별도 확정이 필요하며, Dimension Gate는 공통 Map 시설일 가능성을 보존한다.

### 174. Building Visual Separation
Building Function과 Visual Asset을 분리한다. Visual Asset 변경이 Function 변경을 의미하지 않으며 Building Definition은 Visual Asset ID를 참조한다.

### 175. Building Runtime State
모든 Building에 복잡한 Runtime State를 강제하지 않는다. 기능에 필요한 상태만 가진다.
- Base: HP 등
- Dimension Gate: Active/Disabled 등
- Repair Factory: Active/Repairing 등

### 176. Building Validation
최소 검증 항목:
- ID 중복
- Name 누락
- Function 누락/불일치
- Faction 참조 오류(해당 시)
- Visual 참조 오류
- 음수 HP/Armor
- Function별 잘못된 Parameter
- Map Placement 오류
- Spawn Gate 참조 오류

### 177. Building Usage / Impact Lookup
Building Editor는 가능하면 Map → Stage → Campaign 사용처를 역조회할 수 있어야 한다. ID 변경이나 삭제 전에 영향 범위를 확인한다.

### 178. Building ID / Delete Protection
SQLite ODB PK와 Logical ID를 구분한다. 참조 중인 Building의 ID 변경/삭제는 단순 행 삭제로 처리하지 않으며 참조 영향 확인과 보호 절차를 거친다.

### 179. Building Production State
필요 시 Draft → Valid → Production → Deprecated 상태를 사용한다. Production Lock은 추후 적용하며 현재 구현하지 않는다.

### 180. Building Duplicate / Template
유사 시설 제작을 위한 Duplicate/Template을 지원할 수 있다. Visual Asset은 무조건 복제하지 않고 기존 참조를 유지하는 것을 기본으로 한다.

### 181. Building Save Transaction
Authoring 저장은 Validate → SQLite Transaction → Reload → Verify 순서를 기본 Production Gate로 한다. 저장 실패 시 부분 저장된 Definition을 남기지 않는다.

### 182. SQLite Authoring Model
Building Editor는 Raw JSON/Dictionary 편집기가 아니다. JSON→SQLite 전환은 UI를 JSON 편집 UI로 만드는 것이 아니라 Content Authority를 SQLite 컬럼/관계로 옮기는 작업이다.
권장 구조 예:
- building: 공통 Identity/Runtime 공통 속성
- building_function: Function Type 및 Function별 관계/파라미터
- visual reference: Visual Asset ID 관계
- map placement: Map이 소유하는 위치/배치 관계
- stage usage: Stage가 소유하는 사용 관계
Repository/Loader는 SQLite에서 Runtime Definition을 구성한다.

### 183. Building Authoring UI
Building Editor는 최소한 Identity, Function Type, Runtime Parameters, Faction Selector(필요 시), Visual Asset Selector, Validation, Reference/Usage 정보, Save/Reload/Verify를 제공해야 한다. Raw JSON 입력은 사용하지 않는다.

### 184. Building Runtime Smoke Requirements
최소 Runtime Smoke 기준:
- BASE_RUNTIME_SMOKE: Base HP 변화 및 Defeat 연결
- DIMENSION_GATE_RUNTIME_SMOKE: 지정 Gate 위치에서 Spawn
- REPAIR_FACTORY_RUNTIME_SMOKE: Robot HP Recovery
자동화 Smoke PASS는 PIE VERIFIED를 의미하지 않는다.

### 185. Building Completion Gate
Building Production Ready는 최소 다음을 만족한다.
1. 3개 Canon Building Function 정의 유효
2. Function별 Runtime Parameter 유효
3. Map Placement/Reference 유효
4. Visual Reference 유효
5. Stage Spawn Gate Reference 유효
6. SQLite Save → Reload → Verify 성공
7. Building Runtime Smoke 통과
8. 불필요한 추가 Building Function이 구현되지 않음

### 186. Building Runtime Boundary
현재 확정된 Runtime 책임은 Base/Spawn Gate/Repair Factory의 핵심 Function이다. Gate Spawn 실패 복구 정책, Repair 방식, Building Faction 관계, 판매/경제, 파괴 가능성 등은 별도 결정 전까지 UNDECIDED로 유지한다.

### 187. Review Judgment
Building은 HP/Sprite 데이터 편집기가 아니라 Runtime Function을 가진 시설 Authoring Editor가 되어야 한다. 특히 Dimension Gate는 Building 자체가 Spawn Anchor이고, Stage가 Gate를 참조하여 Wave의 Spawn Origin을 결정하는 구조가 적절하다. Repair Factory는 Robot 성장과 분리된 HP Recovery Function으로 유지한다.

Status: CODE VERIFIED / EDITOR VERIFIED / BUILD VERIFIED / PIE VERIFIED UNVERIFIED
No Runtime code change performed during this review.

## BUILDING EDITOR — FACILITY FUNCTION / SPAWN / REPAIR REQUIREMENTS (2026-10-07)

### 152. Building Canon
현재 Building은 Base, Dimension Gate, Repair Factory 3종을 기준으로 한다. 추가 시설은 현재 범위에 포함하지 않는다.

### 153. Building Function
Building은 단순 HP/Sprite 객체가 아니라 Runtime Function을 가진 시설이다.
- Base → Defeat Function
- Dimension Gate → Spawn Function
- Repair Factory → Repair Function
Function Type은 이름이나 임의 문자열로 판단하지 않고 명시적 데이터로 관리한다.

### 154. Building Identity / Visual Separation
Building ID, Name, Function, Runtime Data, Visual Asset을 분리한다. Visual Asset 변경이 Building Function을 변경해서는 안 된다.

### 155. Base Responsibility
Base는 일반 Building HP와 별도로 현재 Runtime의 Base HP → Defeat 조건과 연결되는 특수 시설이다. Stage의 Base HP 설정과 Building Definition의 기본값이 중복되거나 충돌하지 않도록 책임을 명확히 한다.

### 156. Dimension Gate Responsibility
Dimension Gate는 Unit/Enemy Spawn Origin이다. Gate 자체를 Spawn Anchor로 취급하며 별도의 Spawn Point 객체를 중복 생성하지 않는 것을 기본으로 한다.

### 157. Dimension Gate / Stage Boundary
Gate는 어디에서 Spawn하는지를 정의하고 Stage의 Wave/Enemy Group은 무엇을 얼마나 Spawn하는지를 정의한다.
Enemy Group은 필요 시 Dimension Gate를 명시적으로 참조한다.

### 158. Gate / Wave Relationship
한 Wave에서 여러 Dimension Gate를 사용할 수 있어야 한다. 하나의 Gate는 여러 Wave/Stage에서 재사용 가능해야 한다. Gate는 Spawn Count, Spawn Interval, Wave 순서를 소유하지 않는다.

### 159. Gate / Lane Separation
Dimension Gate는 실제 Spawn 위치이고 Lane은 이동/전투 경로이다. Gate와 Lane을 동일 개념으로 취급하지 않는다.

### 160. Gate Activation
Map에 존재하는 Gate와 특정 Stage에서 활성화되는 Gate를 분리한다. 사용하지 않는 Gate가 Map에 존재하는 것을 오류로 처리하지 않는다.

### 161. Gate Position / Direction
Gate는 최소 Position과 필요 시 Rotation/Spawn Direction을 가진다. 별도의 Spawn Area가 실제로 필요해질 때까지 추가하지 않는다.

### 162. Gate Spawn Failure
Gate 주변이 Spawn 불가능한 상태일 경우 Runtime은 Spawn Failure를 감지할 수 있어야 한다. 구체적인 재시도/대체 위치 정책은 Runtime 계약 확정 전까지 UNDECIDED로 둔다.

### 163. Spawn Completion Boundary
Spawn 실패 또는 미처리 Spawn을 Wave 완료로 잘못 판정하지 않도록 Spawn 예정/완료와 전투 종료 상태를 구분한다.

### 164. Repair Factory Responsibility
Repair Factory는 Robot 수리 기능을 제공하는 시설이다. 수리는 Robot 성장/XP/Level/Stat Growth와 분리한다.

### 165. Repair Factory Open Questions
Repair 방식은 아직 UNDECIDED이다.
- Factory 접촉형 / 범위형
- 자동 / 수동
- 동시 수리 가능 수
- 수리량 / 수리 속도
- 이동/공격 중 수리 가능 여부
- 수리 취소 여부
- 비용 여부
구체 구현은 Runtime 계약 확정 후 진행한다.

### 166. Repair Factory / Robot Boundary
Factory는 Repair Effect를 제공하고 Robot Runtime State가 실제 HP 및 수리 상태를 소유한다. Factory가 Robot의 성장 수치나 전투 능력치를 직접 변경하지 않는다.

### 167. Base / Gate / Robot Position Separation
Base, Dimension Gate, Robot Position은 서로 다른 개념이다.
- Base → 방어/패배 시설
- Dimension Gate → Spawn Origin
- Robot Position → Robot 시작 위치

### 168. Building Placement Boundary
Building Definition과 Map Placement를 분리한다. Building Editor는 무엇인지, Map Editor는 어디에 있는지를 관리한다. Stage는 해당 시설이 해당 전투에서 사용되는지를 관리한다.

### 169. Building Collision
Building이 실제 Collision Object인지 Gameplay Anchor인지 기능별로 구분한다. Dimension Gate는 기본적으로 Spawn Anchor이며 이동 차단 여부를 임의로 추가하지 않는다.

### 170. Building Runtime State
Building Runtime State는 기능에 필요한 최소 상태만 가진다.
- Base → HP
- Dimension Gate → Active/Disabled
- Repair Factory → Active/Repairing
필요하지 않은 복잡한 상태는 추가하지 않는다.

### 171. Function Single Responsibility
하나의 Building에 여러 핵심 Function을 임의로 혼합하지 않는다. 새로운 복합 시설이 필요하면 명시적인 Runtime 계약으로 별도 정의한다.

### 172. Function Parameters
Function별 Parameter는 공통 Building 데이터와 분리한다. 예를 들어 Repair Rate는 일반 HP/Armor 필드가 아니라 Repair Function 데이터로 관리한다.

### 173. Runtime Event Boundary
Building Definition은 Function과 설정을 정의하고 Runtime Event는 실제 발생 시점을 처리한다. 예: Dimension Gate → Spawn Function → Spawn Event.

### 174. Building Faction Boundary
Building의 Faction 소속 여부는 Tower와 동일하게 자동 확정하지 않는다. Base/Repair Factory/Dimension Gate 각각의 Faction 관계가 필요할 때 명시적으로 정의한다.

### 175. Building / Hostility Boundary
Faction은 소속이며 공격 가능 여부를 자동 결정하는 Hostility와 동일하지 않다.

### 176. Building Usage / Impact Lookup
Building Editor는 가능하면 Map → Stage → Campaign의 사용처를 역조회할 수 있어야 한다. ID 변경이나 삭제 시 영향 범위를 확인할 수 있어야 한다.

### 177. Building ID / Delete Protection
SQLite ODB PK와 논리 ID를 분리한다. 참조 중인 Building의 ID 변경/삭제는 영향 참조를 확인한 뒤 처리하며 Production 데이터 손상을 방지한다.

### 178. Building Validation
최소 검증 항목:
- ID 중복
- Name 누락
- Function 누락
- Faction 참조 오류
- Visual Asset 참조 오류
- 음수 HP/Armor
- Function별 잘못된 Parameter
- Map 참조 오류
- Spawn Gate 참조 오류

### 179. Building Placement Validation
Map 배치 시 Terrain, 중복 설치, Building 간 겹침, Gameplay Area, Obstacle 등의 충돌 규칙을 Runtime 지원 범위에 맞게 검증한다.

### 180. Building State
필요 시 Draft, Valid, Production, Deprecated 상태를 사용할 수 있다. Production Lock은 별도 구현 결정 전까지 적용하지 않는다.

### 181. Building Preview / Runtime Separation
Editor Preview는 실제 Runtime 기능 검증을 대체하지 않는다.

### 182. Building Runtime Smoke Tests
최소 Runtime 검증은 다음 세 가지를 기준으로 한다.
- Base → HP 감소 → Defeat
- Dimension Gate → 지정 위치 Spawn
- Repair Factory → Robot HP Recovery

### 183. Building Authoring UI
Building Editor는 최소 Identity, Function, Runtime Parameters, Faction(필요 시), Visual Asset Selector, Validation, Save/Reload/Verify를 제공한다. Raw JSON/Dictionary 편집 UI를 Authoring 방식으로 사용하지 않는다.

### 184. SQLite Authoring Model
JSON → SQLite 전환은 UI를 JSON 편집 화면으로 바꾸는 작업이 아니라 Content Data의 저장 모델을 SQLite 컬럼/관계로 변경하는 작업이다.
Building의 Scalar Data는 SQLite columns, 참조는 logical ID/relations, Function별 반복 데이터는 명시적 child table 또는 relation 구조를 사용한다. JSON은 새로운 Authoring Authority로 추가하지 않는다.

### 185. Building Save Gate
Production 저장은 Validate → SQLite Transaction → Reload → Verify 순서를 기본으로 한다. 저장 실패 시 부분 저장 상태를 남기지 않도록 한다.

### 186. Schema Migration Safety
현재 raw JSON 기반 Building 저장 구조가 존재하는 경우 실제 SQLite 컬럼 구조로 전환할 때 Migration 실패 시 원본을 보존하고 작업을 중단한다.

### 187. Building Completion Gate
각 Building Definition은 최소한 Identity, Function, Runtime Parameters, Visual Reference, SQLite Save/Reload/Verify를 통과해야 Runtime Authoring Ready로 판단한다.

### 188. Game Scope Boundary
현재 Canon에는 Base, Dimension Gate, Repair Factory만 포함한다. 추가 Building, 판매/환급, 복합 Function, 상세 Repair Economy 등은 현재 구현 범위에 포함하지 않는다.

### 189. Review Judgment
Building Editor는 시설의 외형을 편집하는 메뉴가 아니라 Runtime Function을 가진 시설 Definition을 관리하는 Authoring UI가 되어야 한다. 핵심 책임은 Building Function, Map Placement, Stage Usage, Runtime State를 분리하는 것이다.

Status: CODE VERIFIED / EDITOR VERIFIED / BUILD VERIFIED / PIE VERIFIED UNVERIFIED
No Runtime code change performed during this review.

## SKILL EDITOR — REVIEW HOLD (2026-10-07)

### 190. Current Boundary
Skill은 Robot이 사용하는 전투 능력이다. Skill Editor의 상세 Authoring 요구사항은 현재 확정하지 않는다.

### 191. Robot Relationship
Skill은 Robot Editor에서 효과를 직접 정의하는 것이 아니라 Skill Definition을 별도로 참조하는 구조를 기본 방향으로 유지한다.
Robot → Skill ID Reference → Skill Definition → Runtime Execution

### 192. Current Robot Skill Slots
현재 Robot에는 Skill 1, Skill 2, Skill 3, Special, Finisher 슬롯이 존재한다. 각 슬롯의 AUTO/MANUAL 실행 정책과 실제 Runtime 동작은 Robot/Combat 계약과 함께 확정한다.

### 193. Review Hold
Skill의 Execution Type, Damage, Radius, Cooldown, Energy Cost, Duration, Growth 여부 등 세부 규칙은 현재 보류한다. 확인되지 않은 Skill Runtime 요구사항을 임의로 Canon으로 승격하지 않는다.

### 194. SQLite Boundary
Skill도 최종적으로 JSON UI 편집이 아니라 SQLite Content Data를 Authoring하는 구조를 따른다. 다만 실제 Skill 컬럼/관계 구조는 상세 Runtime 계약 확정 후 설계한다.

### 195. Revisit Condition
Robot 전투 구조와 Skill 사용 정책이 확정된 후 Skill Editor를 재검토한다. 특히 AUTO/MANUAL, Energy, Cooldown, Execution Type, Effect, Animation Asset의 책임 경계를 함께 확정한다.

Status: HOLD / CODE VERIFIED / EDITOR VERIFIED / BUILD VERIFIED / PIE VERIFIED UNVERIFIED
No Runtime code change performed.

## ASSET / IMAGE RESOURCE EDITOR — IMAGE RESOURCE MANAGEMENT REQUIREMENTS (2026-10-07)

### 196. Responsibility
Catalog/Image Editor의 주 책임은 게임에서 사용하는 이미지 리소스의 등록, 관리, 편집, 분류, 검증, 참조 관계 관리이다. Robot/Unit/Tower/Building 등의 게임 콘텐츠 정의를 직접 소유하지 않는다.

### 197. Resource Hierarchy
관리 계층은 다음을 기본 구조로 한다.
Source Image → Image Resource → Visual Asset → Content Reference → Runtime
Sprite Sheet는 Image Resource의 한 형태이며 Animation은 이를 사용하는 별도 Runtime 정의이다.

### 198. Original Source Protection
원본 이미지는 비파괴적으로 보존한다. 편집/처리 결과는 별도 Resource로 관리하며 원본과 파생 Resource의 관계를 기록한다.

### 199. Asset Identity
파일명, Display Name, Asset ID를 분리한다. Runtime 참조는 파일 경로가 아니라 안정적인 Asset ID를 사용한다. Asset ID 변경은 참조 영향도를 검사한 뒤 허용한다.

### 200. Asset Namespace
Asset ID는 robot.*, unit.*, enemy.*, tower.*, building.*, vfx.*, ui.* 등의 Namespace 규칙을 적용할 수 있어야 하며 중복과 잘못된 명명 규칙을 검증한다.

### 201. Asset Type / Category / Usage
Image Type, Category, Owner, Usage를 분리한다. 예: Category=Robot, Owner=ASURA, Usage=Attack. 검색과 검증에서 각각 독립적으로 사용할 수 있어야 한다.

### 202. Resource Metadata
SQLite에는 Asset ID, Source Path, Resource Type, Region, Grid, Frame, Anchor, Category, Owner, Usage, State, Version 및 필요한 참조 관계를 저장한다. 실제 이미지 파일은 파일 시스템 Resource로 관리한다.

### 203. Asset Reference
Robot/Unit/Enemy/Tower/Building/Map 등 Content Editor는 파일 경로를 직접 저장하지 않고 Asset Selector를 통해 Asset ID를 참조한다.

### 204. Bidirectional Navigation
Asset Editor에서 사용처 Content Editor로 이동할 수 있고, Content Editor에서 참조 Asset Editor로 역방향 이동할 수 있어야 한다.

### 205. Reference / Impact Analysis
Asset 변경, 교체, ID 변경, 삭제 전에 사용처와 영향 범위를 확인한다. Source → Visual Asset → Content → Stage → Campaign 관계를 추적할 수 있어야 한다.

### 206. Safe Replace
사용 중인 Asset은 삭제 후 재생성하지 않고 동일 Asset ID를 유지한 상태에서 Resource만 교체할 수 있어야 한다.

### 207. Delete Protection
삭제는 Reference Check → 삭제 요청 → 확인 → 삭제 순으로 처리한다. 사용 중인 Asset은 직접 삭제하지 않는다. Deprecated 상태를 우선 제공할 수 있다.

### 208. Asset State
최소 Draft / Valid / Invalid / Deprecated / Production Lock 상태를 고려한다. Production Lock 상태에서는 실수에 의한 변경을 방지한다.

### 209. Validation
다음을 자동 검증한다.
- 파일 존재/접근 가능 여부
- 이미지 형식
- 해상도 및 비율
- 투명도
- Sprite Sheet Grid
- Frame 범위/중복/빈 Frame
- Anchor
- Broken Reference
- Duplicate Asset
- Unused Asset
- Invalid Asset
- Runtime 참조 가능 여부

### 210. Sprite Sheet Validation
Sprite Sheet는 이미지 크기와 Grid 일치 여부, Frame 순서, Frame 영역 중복, 빈 Frame, Anchor 편차, Transparent Padding 편차를 검사할 수 있어야 한다.

### 211. Preview Boundary
Source Preview, Asset Preview, Frame Preview, Runtime Preview를 구분한다. Editor Preview가 Runtime 결과를 보장한다고 간주하지 않는다.

### 212. Image Processing
Crop, Flip, Rotate, Trim, Background Removal, Color Replacement, Alpha 및 기타 처리는 원본 비파괴 원칙을 따른다.

### 213. Variant / Mask
Color Variant나 Team Variant가 필요할 경우 원본 복제가 아닌 Variant 관계를 관리한다. Team Alpha 등의 Mask는 Visual Resource와 용도를 명확히 구분한다.

### 214. Orientation / Scale / Pivot
필요한 Runtime 계약이 확정된 경우 Orientation, Source Scale, Runtime Scale, Pivot, Sprite Anchor를 분리하여 관리한다. Pivot과 Anchor를 혼용하지 않는다.

### 215. Resource Separation
Visual, Collision, Hitbox, Selection 등의 Resource가 필요한 경우 각각 독립된 용도로 관리한다. Runtime에서 실제 사용하는 경우에만 추가한다.

### 216. Import / Processing
Source Import 실패를 Missing과 구분하여 Invalid Format, Unsupported, Import Failed, Access Error 등 원인별 상태로 표시할 수 있어야 한다.

### 217. External Change Detection
외부 이미지 편집 프로그램에서 Source가 변경·교체·삭제된 경우 Editor가 변경을 감지하고 재검증할 수 있어야 한다.

### 218. Duplicate Detection
파일명이 달라도 동일 Resource가 존재하는 경우 Duplicate 후보로 표시한다. 자동 삭제하지 않는다.

### 219. Unused Resource
등록되어 있지만 참조되지 않는 Resource를 검색할 수 있어야 한다. Unused는 즉시 삭제가 아니라 Review 대상이다.

### 220. Batch Management
다수 Asset의 등록, 분류, 이름/메타데이터 변경, Sprite Sheet 등록, Validation을 일괄 수행할 수 있는 구조를 고려한다.

### 221. Search / Index
ID, Name, Type, Category, Owner, Usage, State, Used/Unused 등의 조건으로 검색한다. Asset 규모 증가 시 SQLite Index와 Thumbnail Cache를 활용할 수 있다.

### 222. Thumbnail / Performance
대형 Image Resource를 목록에서 반복 로드하지 않도록 Thumbnail Cache와 Lazy Loading을 고려한다.

### 223. Dirty State / Recovery
편집 중 미저장 상태를 표시하고 저장 전 이동/종료 시 보호한다. 가능한 경우 마지막 저장 상태로 복원할 수 있어야 한다.

### 224. Version / Migration
Asset ID 규칙, 폴더 구조, Metadata Schema가 변경될 경우 기존 참조를 안전하게 Migration할 수 있어야 한다. Migration 실패 시 기존 참조를 손상시키지 않는다.

### 225. Runtime Atlas Boundary
Sprite Sheet와 Runtime Texture Atlas는 동일 개념으로 취급하지 않는다. Atlas Packing을 도입할 경우 원본 Asset ID와 Packed Runtime Resource의 관계를 유지한다.

### 226. File Naming / Namespace
파일명 변경과 Asset ID 변경을 분리한다. 파일명 변경은 가능하면 참조 ID에 영향을 주지 않는다.

### 227. Asset Version / Change Log
Resource 교체나 주요 Metadata 변경 시 Version 및 변경 이력을 남길 수 있는 구조를 고려한다.

### 228. Production Snapshot
Production Lock 또는 주요 배포 전 Asset 목록, 참조 상태, Validation 결과를 Snapshot으로 보존할 수 있어야 한다.

### 229. Recovery / Rebinding
Resource 파일이 이동된 경우 동일 Resource를 식별할 수 있는 정보가 있다면 새로운 경로에 Rebind할 수 있는 구조를 고려한다.

### 230. Reserved Resource
현재 참조되지 않지만 제작 예정인 Resource를 Unused와 구분하기 위해 Reserved 상태를 고려한다.

### 231. Asset Lock Scope
개별 Asset뿐 아니라 필요 시 Asset Group 및 전체 Catalog 단위 Lock을 지원할 수 있다.

### 232. Content Editor Boundary
Asset Editor는 이미지 Resource를 정의하고 Content Editor는 이를 참조한다. Asset Editor가 Robot/Unit/Tower/Building의 Gameplay Definition을 중복 정의하지 않는다.

### 233. Runtime Contract
Asset Editor에서 정의 가능한 속성은 Runtime에서 실제 의미가 있는 범위로 제한한다. Authoring-only 속성을 Runtime 속성으로 오인하지 않는다.

### 234. Production Priority
P0:
- Asset ID / Namespace
- Original Source 보호
- SQLite Metadata
- Asset Reference
- 사용처 조회
- Delete Protection
- 기본 Validation
- Save → Reload → Verify

P1:
- State / Production Lock
- Reference Impact
- Safe Replace
- Duplicate / Unused 탐지
- Sprite Sheet Validation
- Batch Management
- Search / Filter
- Bidirectional Navigation
- Dirty State / Recovery

P2:
- Version / Migration
- External Change Detection
- Thumbnail Cache / Lazy Loading
- Runtime Atlas 관리
- Snapshot / Change Log
- Advanced Variant / Mask
- Recovery / Rebinding

### 235. Review Judgment
현재 Image Editor는 이미지 리소스 관리 목적에 맞는 기반 기능을 이미 보유하고 있다. 향후 보완의 핵심은 이미지 편집 기능의 추가보다 Asset Identity, Reference Integrity, Source Protection, Validation, Production Safety를 강화하는 것이다.

Status: PROPOSAL / CODE VERIFIED / EDITOR VERIFIED / BUILD VERIFIED / PIE VERIFIED UNVERIFIED
No Runtime code change performed.

[Reading 56 lines from start (total: 56 lines, 0 remaining)]

## ASSET EDITOR / MAP ASSET CATALOG — CONSOLIDATION AND RESPONSIBILITY REQUIREMENTS (2026-10-07)

### Purpose
Image Editor와 Asset Catalog Editor는 기능 중복을 줄이고 하나의 Asset Editor 체계로 통합하는 방향을 권고한다.

### Responsibility
Asset Editor는 이미지 및 Map 배치 리소스의 Authoring/Management를 담당한다. Map Editor는 Map Asset을 선택하여 실제 Map에 배치한다. Robot/Unit/Tower/Building Gameplay Definition은 각 전용 Editor가 소유한다.

### Resource Hierarchy
Source Image → Visual Asset → Map Asset → Map Placement

Source Image는 원본, Visual Asset은 시각 리소스, Map Asset은 Map에서 배치 가능한 리소스 정의이다.

### Image 기능
Source 등록, Crop/Flip/Rotate/Trim, Background/Alpha 처리, Region, Sprite Sheet, Frame, Anchor, Visual Asset, Preview, Validation을 통합 Asset Editor에서 유지한다.

### Map Asset 기능
Tile/Object, Group, Display Name, Asset ID, Visual Asset Reference, Footprint, Layer, Grid Snap, Rotation/Flip 정책, Occupancy/Placement Rule을 통합 Asset Editor에서 관리한다.

### Data Separation
Image/Visual Asset에는 Source, Region, Frame/Grid, Anchor, Variant/Mask 등 시각 리소스 정보를 둔다. Map Asset에는 Kind, Group, Visual Asset Reference, Footprint, Layer, Placement Rule, Snap Rule, Occupancy Rule을 둔다.

### Map Editor Contract
Map Editor는 이미지 원본이나 파일 경로를 직접 관리하지 않고 Map Asset ID를 참조하여 배치 결과를 Map 데이터로 저장한다.

### Gameplay Boundary
Asset Editor는 Robot/Unit/Tower/Building의 Gameplay Definition을 중복 정의하지 않는다. Damage, Runtime Function 등은 각 전용 Editor의 책임이다.

### Identity / Reuse
Visual Asset ID와 Map Asset ID를 분리한다. 하나의 Visual Asset은 여러 Map Asset에서 재사용할 수 있어야 하며 Map별 배치 규칙은 Map Asset이 소유한다.

### Reference Safety
Visual Asset 또는 Map Asset 변경/삭제 전 사용처를 검사한다. Map Asset 삭제로 기존 Map 배치 데이터가 깨지지 않도록 보호한다. Visual Asset 교체와 Map Asset 의미 변경을 구분한다.

### UI Structure
하나의 Asset Editor 안에서 Source/Images, Visual Assets, Map Assets, Usage/References, Validation 영역을 제공하는 방향을 권고한다. 탭/모드/Split View 등 구현 방식은 후속 설계에서 결정한다.

### Migration
기존 두 Editor의 데이터를 통합 Asset Editor가 읽을 수 있는 Migration 경로를 마련하고 기존 참조를 임의로 변경하지 않는다.

### Production Gate
SQLite Save → Reload → Reference Verify를 Asset Authoring Gate로 사용한다.

### Validation
Missing Source, Missing Visual Asset, Missing Map Asset, Duplicate ID, Broken Reference, Invalid Region, Invalid Frame/Grid, Invalid Footprint, Invalid Placement Rule, Unused Resource, Runtime-incompatible Resource를 통합 검증한다.

### Priority
P0: Editor 책임 통합, Visual Asset/Map Asset 분리, Reference Integrity, Save→Reload→Verify, Map Asset ID 참조.
P1: 통합 UI, Usage/Impact Inspector, Validation Panel, Safe Replace/Delete Protection, Migration, Batch Management.
P2: Version/Snapshot, Advanced Variant/Mask, Atlas Packing, External Change Detection, Asset Recovery.

### Judgment
현재 Image Editor와 Asset Catalog Editor를 각각 확장하기보다 Asset Editor 하나로 통합하고 Source → Visual Asset → Map Asset → Map의 책임 경계를 명확히 하는 방향이 적절하다.

Status: PROPOSAL / CODE VERIFIED / EDITOR VERIFIED / BUILD VERIFIED / PIE VERIFIED UNVERIFIED
No Runtime code change performed.

[executed on device: DESKTOP-8U0R3E5 (48492a68-5961-4a8a-a249-6b0325c03a22)]

## Map Editor — 확장 요구사항 검토 결과

> 본 절은 Map Editor를 실제 게임 맵 제작 도구로 정의하고, 공간 제작·Gameplay 배치·데이터 무결성·Runtime 계약까지 확장 검토한 요구사항이다. 기존 구현을 대체하는 Canon 변경이 아니라 개발 요구사항 후보이며, 우선순위는 후속 구현 계획에서 확정한다.

### 제작 및 편집 기능
41. 마우스/키보드 편집 조작을 표준화한다.
42. 겹친 객체의 선택 우선순위를 정의한다.
43. 선택 객체의 ID, Asset, 위치, 크기, Layer, Rotation, Footprint를 확인할 수 있게 한다.
44. X/Y 좌표를 직접 입력할 수 있게 한다.
45. 키보드로 일정 단위의 정밀 이동을 지원한다.
46. 다중 선택 객체의 정렬과 간격 균등 배치를 지원한다.
47. 임시 Guide/Guideline을 제공한다.
48. 기존 Map을 참조하여 비교·제작할 수 있는 Reference View를 검토한다.
49. 선택 영역을 복제할 수 있게 한다.
50. 좌우/상하 대칭 배치를 지원할 수 있다.
51. 반복되는 맵 구조를 Editor Template/Prefab으로 저장할 수 있게 한다. Runtime Asset과는 분리한다.
52. Asset Footprint가 Map Bounds를 벗어나는지 검사한다.
53. 필수 Gameplay 요소 누락을 Canvas와 Validation Panel에서 표시한다.
54. Stage가 참조하는 Gameplay Point/Area를 Map Editor에서 확인할 수 있게 한다.
55. Map의 Stage 사용처를 확인하고 해당 Stage로 이동할 수 있게 한다.

### 좌표 및 공간 정합성
56. Map Coordinate와 Screen Coordinate를 분리한다.
57. Editor → SQLite → MapLoader → Runtime의 좌표 변환 규칙을 일관되게 유지한다.
58. Editor Camera의 Pan/Zoom 상태가 Map 데이터에 영향을 주지 않도록 한다.
59. Rotation의 0도 기준, 방향, 허용 정밀도를 명확히 한다.
60. Scale의 기준점과 최소/최대값을 정의한다.
61. Flip이 허용될 경우 Runtime에서도 동일하게 재현한다.
62. Layer와 Z-order의 관계를 명확히 한다.
63. Map Asset의 Pivot, Footprint, Visual Offset을 분리한다.

### 배치 및 Gameplay 관계 검증
64. 객체 겹침 허용 여부를 Layer/Type별 규칙으로 정의한다.
65. Gameplay Point와 Area의 포함 관계를 검증한다.
66. 상호 겹침이 금지된 Gameplay Area를 검증한다.
67. Spawn 위치가 실제 사용 가능한 공간인지 검증한다.
68. Blocked Area와 Spawn의 충돌을 오류로 처리한다.
69. Tower Placement가 실제 배치 가능한 공간인지 검증한다.
70. Robot Initial Position이 Map Bounds 밖이거나 Blocked이면 오류로 처리한다.
71. Map Size 축소 시 Bounds 밖으로 밀려나는 객체를 사전에 탐지한다.

### Asset 및 Reference Integrity
72. Map Asset의 Footprint/크기/의미 변경이 기존 Map 배치에 미치는 영향을 탐지한다.
73. Map에서 사용 중인 Map Asset 삭제를 보호한다.
74. Stage가 참조 중인 Map ID 변경을 보호한다.
75. Map Editor가 Wave, Enemy Group, Mission 등 Stage 전투 정의를 소유하지 않도록 책임 경계를 유지한다.
76. Editor에서 입력 가능한 데이터가 Runtime에서 실제 소비되는 데이터인지 확인한다.
77. Guide, Selection State, Editor Camera, Temporary Grid 등 Editor 전용 데이터와 Runtime Map 데이터를 분리한다.

### 저장·복구·변경 안전성
78. Map Save는 기존 정상 데이터를 보호하는 Atomic Save를 지향한다.
79. Save 직후 DB에서 Reload하여 메모리 상태와 동일한지 검증한다.
80. Editor Preview와 실제 Runtime Preview의 차이를 명확히 표시한다.
81. Validation Rule 변경을 추적할 수 있는 Rule Version을 장기 요구사항으로 검토한다.
82. Legacy Map Schema에 대한 Migration 경로를 마련한다.
83. 부분 저장 실패 시 기존 정상 Map을 보존하고 복구 가능한 상태를 제공한다.
84. Undo가 데이터 변경 단위까지 일관되게 동작하도록 한다.
85. Save 전/후 Undo의 책임 범위를 명확히 한다.
86. 동일 Map의 동시 편집 충돌 정책을 정의한다.
87. Production Lock 상태의 Map은 Read-only로 보호한다.
88. Dirty Map을 Editor 전환/종료할 때 저장 보호를 제공한다.
89. Validation 실패와 Save 실패를 서로 다른 상태로 관리한다.

### 복제·템플릿·사용처 보호
90. Map Duplicate 시 새로운 ID를 생성한다.
91. Duplicate와 Template의 목적과 동작을 분리한다.
92. Map 삭제 시 사용 중인 Stage와의 영향 관계를 표시하고 보호한다.
93. Map 변경/삭제 전에 Usage 및 Impact를 확인할 수 있게 한다.
94. Map과 Stage의 Valid 상태를 독립적으로 관리한다.
95. Map Validation과 Campaign Validation의 책임을 분리한다.

### Production Readiness
96. Map의 제작 상태를 Draft/Valid/Invalid/Production 등의 상태로 관리하는 방안을 검토한다.
97. Validation 결과를 Error/Warning/Info로 구분한다.
98. Validation 오류를 클릭하면 해당 객체를 Canvas에서 선택할 수 있게 한다.
99. Map 요소가 Runtime에서 어떤 의미로 소비되는지 확인할 수 있게 한다.
100. 최종 제작 상태를 Map VALID → Stage VALID → Campaign VALID → Runtime VERIFIED의 단계로 구분한다.
101. Map Editor Validation PASS는 PIE VERIFIED와 동일하지 않음을 명확히 한다.
102. Runtime 검증 상태는 CODE VERIFIED / EDITOR VERIFIED / BUILD VERIFIED / PIE VERIFIED로 분리한다.

### 우선순위 판단
P0 후보:
- Map 생성 및 기본 편집
- Asset 배치
- Gameplay Point/Area 배치
- 선택/이동/삭제/복제
- Grid/Snap
- Undo/Redo
- Inspector
- Validation
- Save → Reload → Verify
- Reference/ID 무결성
- Runtime 좌표 정합성

P1 후보:
- 다중 선택/정렬
- 영역 복제
- Reference View
- Usage/Impact Inspector
- Production Lock
- Map Duplicate/Template
- Runtime Preview
- 고급 배치 검증
- 자동 복구

P2 후보:
- 대칭/브러시 고급 기능
- Guide
- Map 비교
- Version/Snapshot
- Legacy Migration
- 고급 Template/Prefab
- 동시 편집 대응

### 판정
Map Editor의 핵심 책임은 실제 게임 맵을 제작하는 것이다. 따라서 Map Editor는 단순한 Map 데이터 입력창이 아니라 공간 배치, Gameplay 공간 정의, 배치 검증, 저장/Reload 검증을 담당하는 Level Authoring Tool로 정의한다.

다만 위 항목 전체를 즉시 구현 대상으로 승격하지 않는다. 기존 구현과 대조하여 P0 누락을 먼저 확인하고, 실제 Runtime 소비 경로가 확인되지 않은 기능은 요구사항 후보 또는 UNVERIFIED로 유지한다.

Status: PROPOSAL

## Map Editor — 현재 구현 대조 결과

조사 기준: HEAD 6e9407c8 / main / 기존 Working Tree 유지.
본 조사는 READ-ONLY이며 코드 및 Asset 변경은 수행하지 않았다.

### CONFIRMED — 현재 구현된 핵심 기능
- Map Size 및 32px Grid 기반 좌표 처리
- Canvas Zoom / Pan
- Ground / Vegetation / RoadComposition Layer
- Asset Catalog 검색/선택/미리보기
- Tile / Object 배치
- Fill Ground / Erase
- Asset 이동 / 삭제 / 크기 변경
- Gameplay Mode
- Spawn / Goal / Tower Placement / Robot Position
- Obstacle / Movement / Blocked Area
- Gameplay Area / Gameplay Point
- 선택 객체 Inspector
- Undo
- Map의 Stage 사용처 조회
- SQLite 기반 Map Load / Save
- SQLite Transaction 기반 저장 및 저장 직후 DB 검증

### CONFIRMED — Map Runtime Data 저장 경로
MapLoader는 Map 데이터를 SQLite의 Map 테이블에서 읽고 저장한다. 현재 save_map()은 MapLoader를 통해 SQLite transaction으로 저장하며, 저장 직후 동일 raw_json을 조회하여 저장 결과를 검증한다.
따라서 현재 Content Authority인 SQLite와 Map Editor의 저장 경로는 일치한다.

### P0 누락 또는 부분 구현 후보
1. Redo — Undo는 존재하지만 Redo 구현은 확인되지 않음.
2. 전체 Map Validation Center — 개별 배치 검사는 있으나 Error/Warning/Info를 통합하는 Validation Panel은 부족함.
3. 명시적 Grid/Snap UX — 32px Grid 계산은 존재하지만 Snap On/Off 및 단위 선택 UX는 확인되지 않음.
4. 통합 Map Inspector — 선택 객체 정보는 있으나 Map ID/Name/상태/사용처/참조 영향 등을 통합 관리하는 기능은 부족함.
5. Map Duplicate — 별도 Map 복제 기능은 확인되지 않음.
6. Multi-select — 현재 선택 구조는 단일 선택 중심이며 다중 선택 편집은 부족함.
7. 영역 Copy/Paste — 영역 단위 복제 기능은 확인되지 않음.
8. Dirty State / 저장 보호 — 변경 상태는 내부적으로 추적되지만 명확한 Dirty State 및 Editor 전환/종료 보호 UX는 부족함.
9. Production Lock / Read-only — Production Map 수정 보호 기능은 확인되지 않음.
10. 전체 공간 관계 Validation — Spawn/Goal/Blocked/Tower Slot/Robot Position 등의 관계를 Map 전체 관점에서 검증하는 단계가 부족함.

### NOT CONFIRMED / 후속 조사
- Editor/Runtime 좌표의 모든 변환 경로가 완전히 동일한지
- 실제 Runtime에서 모든 Gameplay Area/Point 타입이 소비되는지
- Rotation / Scale / Flip의 Runtime 재현 범위
- Map Preview와 실제 Runtime 화면의 일치 여부
- Legacy Map Migration 필요성
- 동시 편집 충돌 정책

### 판정
현재 Map Editor는 기본적인 실제 맵 제작 기능을 이미 상당 부분 갖추고 있다. 따라서 다음 구현의 우선순위는 기능을 무작정 추가하는 것이 아니라 P0 후보를 실제 코드 경로와 대조하여 확정하고, 특히 통합 Validation을 중심으로 부족한 부분을 보완하는 것이다.

Status: PROPOSAL

## Map Editor — P0 후보 2차 판정

### CONFIRMED — 현재 UI/코드 기준

- Map Editor는 별도의 New Map 생성 UI를 제공하지 않는다.
- Load/Save UI는 FileDialog와 JSON 필터/타이틀을 사용하고 있으나, 실제 MapLoader의 load/save 권한은 SQLite의 고정 Map table mapping에 연결되어 있다.
- 현재 MapLoader가 직접 매핑하는 Map ID는 map_01, map_01_src, map_02, map_03이다.
- 따라서 현재 구조에서는 임의의 신규 Map ID를 Editor에서 생성하여 SQLite에 신규 document로 저장하는 일반적인 Create Map 경로가 확인되지 않는다.
- Save는 현재 로드된 Map을 대상으로 하며, 신규 Map document 생성보다 기존 Map document 수정에 가까운 구조다.
- Map Editor에는 Load / Save는 있으나 New / Duplicate / Delete Map의 명시적 authoring workflow는 확인되지 않는다.
- Map Editor Scene의 FileDialog가 *.json 필터와 JSON 제목을 사용하지만, 실제 Content Authority는 SQLite이다. 이는 UI 표현과 실제 저장 경로가 불일치하는 상태다.
- Undo는 확인되지만 Redo는 확인되지 않는다.
- 통합 Map Validation 실행 버튼/결과 패널은 확인되지 않는다.
- Multi-select, Map Duplicate, Area Copy/Paste, Production Lock 기능은 확인되지 않는다.

### PARTIAL — 현재 기능으로 충족되는 항목

- Map 생성: 기존 Map의 크기와 배치 데이터를 수정할 수 있으나 신규 Map 생성은 미확인.
- Grid: 32px 기반 Grid 렌더링은 있으나 사용자 제어형 Snap UX는 미확인.
- Inspector: 선택된 배치/Gameplay 요소의 정보 편집은 가능하나 Map 전체 Inspector는 없음.
- Reference: 연결된 Stage 조회는 가능하나 전체 참조 영향 분석은 없음.
- Save verification: SQLite transaction 및 저장 직후 데이터 검증은 구현되어 있음. 다만 Editor의 Save→Reload→semantic validation workflow는 별도 기능으로 확인되지 않음.

### P0 우선순위 재분류 — PROPOSAL

P0-1 — Map 생성/복제/ID 관리
신규 Map을 안전하게 만들고 고유 ID를 부여하는 authoring workflow가 필요하다. 기존 Map 수정과 신규 Map 생성을 명확히 분리해야 한다.

P0-2 — Map Validation Center
Map Size, bounds, asset footprint, Gameplay Area/Point 관계, Spawn/Goal/Blocked/Tower/Robot 배치, Stage reference integrity를 한 곳에서 검증해야 한다.

P0-3 — Undo/Redo
현재 Undo만 확인되므로 Redo를 추가하는 것이 편집 안정성 측면에서 우선이다.

P0-4 — Dirty State / Save Guard
변경 여부를 명확히 표시하고 저장하지 않은 변경이 Load/New/Editor 종료로 유실되지 않도록 보호해야 한다.

P0-5 — Grid/Snap UX
현재 32px Grid를 기반으로 편집하므로 Snap 정책을 명시적으로 제공할 필요가 있다.

P0-6 — SQLite/Editor UI 정합성
JSON FileDialog 표현을 실제 SQLite Content Authority와 일치시키거나, Legacy 호환 목적임을 명확히 표시해야 한다.

### OUT OF SCOPE
이번 단계에서는 위 P0 후보를 구현하지 않았다. 특히 MapLoader의 신규 document 생성 구조 변경, UI 변경, Validation 구현은 Master 승인 전에는 수행하지 않는다.

Status: PROPOSAL

## Canon — 이미지 리소스 생성 프롬프트 관리

### CANON
MENOS의 모든 이미지 리소스는 해당 리소스를 생성하기 위한 이미지 생성 프롬프트를 관리해야 한다.

이 규칙은 로봇, 유닛, 맵, 타일, 배경, UI 이미지, VFX, 아이콘, 애니메이션용 원본 이미지 등 프로젝트에서 이미지 생성 공정이 적용되는 모든 이미지 리소스에 적용한다.

### 요구사항
- 이미지 리소스와 생성 프롬프트의 연결 관계를 유지해야 한다.
- 프롬프트는 단순 메모가 아니라 해당 이미지의 생성 재현을 위한 Authoring 정보로 관리한다.
- 동일 리소스의 수정/재생성 시 기존 프롬프트와 변경 이력을 추적할 수 있어야 한다.
- 참조 이미지, 캐릭터 디자인 기준, 스타일 기준, 생성 모델/도구 등 재현에 필요한 정보가 있는 경우 함께 관리해야 한다.
- Asset Editor / Asset Catalog에서 이미지 리소스의 프롬프트 정보를 조회하고 관리할 수 있어야 한다.
- 프롬프트가 없는 이미지 리소스는 Production-ready 이미지 리소스로 승인하지 않는 것을 기본 정책으로 한다.
- 기존 이미지 리소스에 대해서도 가능한 범위에서 원본 생성 프롬프트를 등록하고, 원본을 확인할 수 없는 경우에는 UNVERIFIED로 명시한다.

### Authoring 책임
Image Source/Prompt → Asset Catalog/Asset Editor → Visual Asset → Runtime

프롬프트 관리는 이미지 파일 자체와 분리된 보조 메모가 아니라 Asset Authoring Metadata의 일부로 취급한다.

### 검증
이미지 리소스의 Production 승인 시 다음을 확인한다.
1. 이미지 Asset 식별자 존재
2. 생성 프롬프트 존재
3. 필요한 경우 참조/생성 조건 존재
4. Asset과 Prompt의 연결 확인
5. 변경 시 Prompt/Asset 관계의 일관성 확인

Status: CANON

## Canon 후속 대조 — Asset Editor의 이미지 생성 Prompt 관리

### CONFIRMED
현재 Asset Catalog Editor는 Asset ID, Display Name, Kind, Group, Source, Pixel Rect, Visual Frames/Columns/Rows, Frame Order, Anchor, Footprint 등을 관리한다.
현재 조사한 Asset Catalog Editor 코드에서는 이미지 생성 Prompt를 저장하거나 편집하는 필드가 확인되지 않았다.

### Canon 적용에 따른 필수 변경 후보 — PROPOSAL
Asset Catalog Editor의 이미지 Asset metadata에 최소한 다음 Prompt Authoring 정보를 관리할 수 있어야 한다.

- Generation Prompt
- Prompt Version / Revision
- Reference Image 또는 Reference Asset 연결
- Generation Tool / Model
- 생성 조건이 필요한 경우 관련 metadata
- Prompt 상태: VERIFIED / UNVERIFIED

Asset Editor는 이미지 파일의 단순 등록/크롭 도구를 넘어, 이미지 생성 원본과 재현 정보를 연결하는 Authoring 도구가 되어야 한다.

### Production Validation
이미지 Asset을 Production 상태로 전환할 때 Prompt metadata가 존재하는지 확인하고, Prompt 원본을 확인할 수 없는 기존 Asset은 UNVERIFIED로 표시한다.

### OUT OF SCOPE
이번 단계에서는 Asset Editor 코드와 SQLite schema를 변경하지 않았다.

## Canon 대조 — Visual Asset Definition / Repository

### CONFIRMED
현재 VisualAssetDefinition은 ID, category, source, region, frames, anchor, owner, usage, team mask, frame region/anchor 등을 Runtime에서 읽고 쓸 수 있는 구조로 정의한다.
현재 Definition에는 이미지 생성 Prompt 또는 Prompt revision/reference/generation tool metadata가 없다.

VisualAssetRepository는 visual_assets Catalog를 로드하여 VisualAssetDefinition으로 변환한다.

### PROPOSAL — Canon 구현을 위한 데이터 계층 요구
이미지 생성 Prompt Canon을 Runtime/Editor Authoring 데이터에 연결하려면 Visual Asset metadata에 다음 계층을 추가하는 방안을 검토한다.

- generation_prompt
- prompt_revision
- generation_references
- generation_model / generation_tool
- generation_conditions
- prompt_status

Prompt는 Runtime 렌더링 기능 자체가 아니라 Asset Authoring/Production validation metadata로 취급한다. 따라서 Runtime 소비 경로에 불필요한 의존성을 만들지 않는 구조를 우선한다.

### 검증 필요
현재 visual_assets Catalog의 실제 SQLite/원본 payload 구조와 Asset Editor 저장 경로를 추가 대조하여, 위 metadata를 어느 Content Authority에 저장할지 결정해야 한다.

### OUT OF SCOPE
이번 단계에서는 Definition, Repository, SQLite schema 또는 Asset Editor를 변경하지 않았다.

## Canon — Image Resource Prompt Sidecar Standard

Master 승인에 따라 모든 이미지 리소스의 생성 Prompt 관리 표준을 확정한다.

- 이미지 생성 Prompt는 이미지와 분리된 Sidecar 파일로 관리한다.
- Production Asset의 공식 Prompt 원본은 이미지와 동일 디렉터리의 `<image>.prompt.md`로 관리한다.
- 이미지와 Prompt는 1:1 대응한다.
- Prompt Sidecar는 Generation Prompt, Negative Prompt, Reference Image/Asset, Generation Tool/Model, Generation Conditions, Prompt Revision, Prompt Status(`VERIFIED`/`UNVERIFIED`)를 관리할 수 있는 Authoring Record다.
- Prompt 전문은 Runtime SQLite Content에 중복 저장하지 않는다. 필요한 경우 Catalog에는 Sidecar 경로, Revision, Status 등 연결·검증 정보만 둔다.
- 원본 Prompt를 확인할 수 없는 기존 Asset은 임의 생성하지 않고 `UNVERIFIED`로 관리한다.
- Production 승인은 Asset ID, Image Source, Prompt Sidecar, Asset↔Prompt 연결, Revision, Status를 검증한다.
- Prompt 변경은 Revision 증가로 취급한다. 전체 이력은 우선 Git history를 사용한다.
- 기존 `docs/*generation_prompt.md` 문서는 참고/역사 자료로 보존하며 Production Asset의 공식 Prompt는 Sidecar 표준을 따른다.

Status: **CANON**
## 조사 결과 — Image Resource / Prompt Sidecar 적용 범위 대조

### 확인일
2026-10-07

### 목적
이미지 생성 Prompt Sidecar Canon을 실제 프로젝트 이미지 리소스에 적용하기 위한 현재 리소스 규모와 Visual Asset 연결 상태를 확인한다.

### CONFIRMED

- `godot/images`에는 현재 이미지 리소스가 155개 존재한다.
- `godot/content/menos.sqlite`의 `visual_assets`는 단일 문서이며 Visual Asset 정의 24개를 포함한다.
- 24개 Visual Asset이 참조하는 Source Image는 5개로 확인되었다.
- 현재 이미지 리소스에 `<image>.prompt.md` 형식의 Prompt Sidecar는 확인되지 않았다.
- 기존 Generation Prompt 문서는 3개 확인되었다.
- 기존 Prompt 문서와 실제 Image Resource 사이의 1:1 Asset↔Prompt 직접 연결은 아직 구축되어 있지 않다.
- 따라서 기존 Prompt 문서의 존재만으로 해당 Image Resource의 Prompt 관리가 완료된 것으로 판단할 수 없다.

### 중요 판정

Prompt Sidecar 적용 대상의 전체 기준은 단순히 `godot/assets` 폴더가 아니라 실제 프로젝트의 Image Resource 집합을 기준으로 조사해야 한다.

현재 확인된 구조:

`godot/images Image Resource → Visual Asset Catalog(SQLite) → Runtime`

Canon 적용 목표 구조:

`Image Resource → <image>.prompt.md → Asset Catalog/Asset Editor의 Sidecar 상태·참조 → Runtime`

Prompt 본문은 Runtime SQLite Content에 중복 저장하지 않는다.

### 다음 조사 대상

155개 Image Resource를 Production/Runtime 사용 여부와 연결 관계에 따라 분류한다.

- Production/Runtime 사용 Asset
- 미사용 또는 Legacy Asset
- 원본 Prompt 확인 가능 Asset
- 원본 Prompt 확인 불가 Asset (`UNVERIFIED`)

### 범위 제한

이번 조사에서는 Image Resource 또는 Asset Catalog의 코드/데이터를 변경하지 않았다. Sidecar 생성, 기존 Prompt 추정·복원, SQLite 스키마 변경은 수행하지 않았다.

### 상태

**PROPOSAL / INVESTIGATION RESULT**

## VFX Editor — 범용 VFX Core + MENOS 통합 설계 제안

### 목적

VFX Editor를 MENOS 전용 기능에 한정하지 않고, 재사용 가능한 범용 2D Game VFX Authoring System으로 설계한다. 단, MENOS가 실제 최초 통합 대상이므로 MENOS Content/Runtime과 연결되는 Integration Layer를 함께 설계한다.

### 핵심 구조

`Generic VFX Core → VFX Editor → Runtime Adapter → MENOS Integration → Runtime`

- **Generic VFX Core**: VFX Definition, Component, Timeline, Parameter, Event, Transform, Attachment, Target, Variant, Override, Validation, Dependency 등 범용 개념을 정의한다.
- **VFX Editor**: 제작, 조합, Timeline 편집, Preview, Debug, Validation, Dependency/Usage 확인을 담당한다.
- **Runtime Adapter**: Godot 등 특정 Runtime의 Sprite, Particle, Shader, Rendering, Pooling 구현으로 변환한다.
- **MENOS Integration**: Skill, Robot, Unit, Tower, Weapon, Projectile, Giant, Stage, UI 등의 게임 Content/Event와 VFX를 연결한다.
- VFX Core는 MENOS의 게임 규칙을 직접 알지 않는다.

### VFX Definition과 Runtime Instance 분리

VFX의 설계 정의와 실제 실행 인스턴스를 분리한다.

- VFX Definition: 재사용 가능한 효과의 원본 정의
- VFX Instance: Runtime에서 특정 시점에 생성된 실행 상태
- Instance에는 위치, 대상, 시작 시간, Runtime Parameter Override 등을 보유할 수 있다.

### VFX Composition

하나의 VFX는 여러 Component를 조합할 수 있어야 한다.

- Sprite
- Particle
- Beam
- Trail
- Ring
- Line
- Shader/Custom Effect

예: Explosion = Flash + Shockwave + Smoke + Debris.

Component는 독립적으로 재사용될 수 있도록 설계한다.

### Timeline / Sequencer

VFX의 중심 Authoring 구조로 Timeline을 사용한다.

- 시작/종료
- 지연
- 동시 실행
- 순차 실행
- Frame/Time Event
- 시간에 따른 Position/Rotation/Scale/Alpha/Parameter 변화
- 다른 VFX Spawn Event
- 외부 Event 전달

단순 FPS/Frame Count만으로 VFX 전체를 표현하지 않는다.

### Transform / Space / Attachment

최소한 다음 공간 개념을 구분한다.

- World
- Local
- Screen
- Attached

또한 Pivot, Anchor, Visual Bounds, Effect Bounds, Spawn Bounds를 분리한다.

Attachment는 Parent의 Position/Rotation/Scale 상속 여부를 개별적으로 제어할 수 있도록 한다.

### Motion / Direction / Target

범용 VFX는 다음 Motion/Direction을 지원할 수 있는 구조로 설계한다.

- 고정 방향
- 이동 방향
- 대상 방향
- 직선/곡선 이동
- 가속/감속
- Target 추적
- Trail
- Beam의 Origin→Target 길이 계산

Target은 특정 게임 객체가 아니라 추상적인 Transform/Position/Direction/Attachment Point 인터페이스로 취급하고, MENOS가 실제 Robot/Unit/Projectile 등을 연결한다.

### Parameters / Overrides / Variants

기본 VFX를 복제하지 않고 호출 시 일부 값만 Override할 수 있어야 한다.

예:

- Scale
- Duration
- Color
- Intensity
- Direction
- Playback Speed

Variant는 Small/Medium/Large, 색상, 팀, 등급, 성능 수준 등의 파생 구성을 표현한다.

### Event / Integration 경계

VFX는 Gameplay Rule을 직접 실행하지 않는다.

`MENOS Event → VFX Reference` 구조로 연결한다.

예:

`GiantDestroyed → Explosion_Heavy`

VFX가 SFX, Voice, Camera를 직접 소유하지 않고 Event를 발생시키거나 공통 Event Bus를 통해 연결하는 구조를 우선한다.

공통 Presentation 구조:

`Game Event Bus → VFX / SFX / BGM / Voice / Camera Effect`

### Material / Rendering

Visual Asset과 Material/Shader를 분리한다.

범용 Rendering 개념을 사용하고 Godot의 구체적인 Rendering 설정은 Runtime Adapter에서 변환한다.

예:

- NORMAL
- ADDITIVE
- MULTIPLY
- SCREEN
- Alpha
- Glow
- Dissolve
- Distortion
- Color Shift
- Mask

### Lifecycle / Concurrency / Interrupt

Runtime 재생 정책을 정의할 수 있어야 한다.

- One-shot / Loop
- Auto Destroy
- Restart
- Ignore
- Queue
- Stack
- Replace
- Merge
- Max Instances
- Per Target Limit
- Global Limit

Runtime Pooling은 Core의 Lifecycle 요구사항과 연결하되 실제 Pool 구현은 Runtime Adapter에 둔다.

### Random / Determinism

Random Position, Rotation, Scale, Color, Delay 등을 지원하되 Replay/Test가 필요한 경우 Deterministic Seed를 사용할 수 있어야 한다.

### Performance

VFX는 대량 생성 가능성이 있으므로 다음 정보를 관리할 수 있는 구조를 고려한다.

- Priority
- Max Instance
- LOD
- Low-End/Mobile Variant
- 화면 밖 처리
- 복잡도 정보
- Pooling
- 생략 가능한 효과의 우선순위

### Preview / Debug

Editor는 단순 재생 Preview를 넘어 다음을 지원하는 방향으로 설계한다.

- Timeline Scrub
- Pause
- Frame/Time Step
- World/Screen/Attached Preview
- Pivot 표시
- Attachment Point 표시
- Bounds 표시
- Parameter 확인
- Runtime과 동일한 Adapter 기반 Preview

Editor Preview와 Production Runtime을 동일시하지 않는다.

### Camera / Audio / UI 경계

VFX가 모든 Presentation 기능을 흡수하지 않도록 책임을 분리한다.

- VFX: 시각적 효과
- SFX: 소리
- Voice: 음성
- BGM: 음악
- Camera: 카메라 효과
- UI: UI 표현
- Gameplay: 게임 규칙

VFX에서 Audio/Camera를 직접 구현하기보다 Event/Reference를 통해 연결한다.

### Import / Authoring / Runtime 데이터 분리

외부 제작 도구의 결과를 바로 Runtime 데이터로 취급하지 않는다.

`Import → Normalize → Asset Registration → VFX Authoring → Validation → Production → Runtime`

Authoring 데이터와 Runtime 소비 데이터의 경계를 유지한다.

### Asset / Prompt / VFX 관계

이미지 리소스와 VFX 정의를 분리한다.

`Image Resource → Visual Asset → VFX Component → VFX Definition → Game Content Reference`

이미지 생성 Prompt는 기존 Canon에 따라 이미지와 동일 디렉터리의 `<image>.prompt.md` Sidecar로 관리한다. Prompt 전문을 VFX Runtime 데이터에 중복 저장하지 않는다.

### Dependency / Usage / Impact

VFX와 관련 Asset의 양방향 의존성을 조회할 수 있어야 한다.

예:

- Image → VFX
- VFX → Skill
- VFX → Robot
- VFX → Stage
- VFX → UI

삭제/변경 전에 Usage와 Impact를 확인할 수 있어야 한다.

미사용 VFX, 미사용 Visual Asset, Orphan Prompt Sidecar, Broken Reference도 탐지 대상으로 한다.

### Production / Validation

VFX 상태는 최소한 Draft / Valid / Production을 구분하는 방향으로 설계한다.

Validation은 다음을 포함할 수 있다.

- Missing Asset
- Broken Reference
- Invalid Timeline
- Circular VFX Reference
- Invalid Parameter
- 과도한 Instance/Particle
- Production Asset 누락
- Prompt Sidecar 누락
- 사용되지 않는 Variant

Validation PASS와 PIE/Runtime 검증은 별개다.

### Version / Schema / Migration

VFX Definition에는 Format/Schema Version을 둘 수 있어야 한다.

구조 변경 시 기존 VFX를 Migration할 수 있는 경로를 확보한다.

Revision 비교는 Timeline, Component, Parameter, Asset Reference 단위까지 추적할 수 있는 방향을 고려한다.

### Fail-safe

Runtime에서 참조 Asset이 없어도 전체 게임 Runtime이 중단되지 않도록 Missing Asset/Invalid VFX에 대한 Fallback 또는 Skip 정책을 정의한다.

### Package

복수의 Image, Visual Asset, Material, Animation 등을 하나의 VFX가 필요로 할 경우 논리적인 VFX Package 단위로 묶을 수 있는 구조를 고려한다.

### 범위 경계

VFX Editor가 MENOS의 게임 규칙을 직접 편집하지 않는다.

- Skill Editor: 어떤 Skill이 어떤 VFX를 사용하는지 정의
- Robot/Unit/Tower Editor: 행동/공격과 VFX 연결
- Stage/Map Editor: 장소/환경 조건과 VFX 연결
- VFX Editor: VFX 자체의 제작과 관리
- Runtime: 실제 실행

### 개발 우선순위 제안

**P0 — Core Authoring**

- VFX Definition
- Component 구조
- Sprite 기반 VFX
- Timeline
- Transform/Anchor/Pivot
- Playback/Loop/One-shot
- Parameter
- Basic Composition
- Preview
- Asset Reference
- 기본 Validation
- Save/Load
- Revision/Schema

**P1 — Production Authoring**

- Particle/Beam/Trail
- Material/Shader
- Attachment/Target
- Event/Trigger
- Variant/Override
- Dependency/Usage
- Production Lock
- Performance 정보
- Deterministic Random
- Runtime Adapter Preview
- Import/Normalize

**P2 — Advanced**

- Advanced Particle/Emitter
- Procedural Effect
- LOD
- Package
- Compare/Diff
- Hot Reload
- 고급 Motion
- 고급 Camera/Presentation Event
- 플랫폼별 Variant

### 판단

이 설계의 목표는 **MENOS에 필요한 VFX Editor를 만들되, VFX 자체는 MENOS에 종속시키지 않는 것**이다.

따라서 최종적인 책임 분리는 다음과 같다.

`Generic VFX Core + VFX Editor + Runtime Adapter + MENOS Integration`

현재 내용은 **PROPOSAL**이며, 아직 Canon이나 구현 계획으로 승격하지 않는다.

### 상태

**PROPOSAL / DESIGN DRAFT**


## VFX Editor — 현재 Runtime 구현 대조

### 조사 목적

앞서 정의한 범용 VFX Core + MENOS Integration 구조가 현재 MENOS Runtime의 VFX 구현과 어느 정도 일치하는지 READ-ONLY로 대조한다.

### CONFIRMED

현재 `godot/game_controller.gd`에는 별도의 Generic VFX Core 또는 VFX Definition/Repository/Editor 계층이 확인되지 않았다.

현재 Runtime 효과는 `effects` 배열에 Dictionary 형태의 효과 상태를 넣고 `_draw()` 계열 코드에서 `type`을 분기하여 직접 그리는 구조다.

확인된 효과 타입/표현에는 다음이 있다.

- `giantHit`
- `impact_explosion`
- `cannon`
- `gatling`
- `robot`
- `area`
- `pierce`
- `proj_defender`
- `proj_threat`

Projectile VFX는 현재 시작점/목표점/진행률을 이용해 선과 원을 직접 그리는 procedural 방식이다.

Impact 계열도 수명과 진행률을 계산하여 원형 Arc를 직접 그린다.

코드에는 현재 다음과 같은 명시적 주석도 존재한다.

- Projectile/hit visuals use procedural VFX only; no impact sprite art.
- Gameplay projectile art is disconnected; keep only procedural VFX.

### 구조적 판정

현재 구현은 **Prototype/Runtime-integrated procedural effect layer**에 가깝고, 앞서 제안한 범용 VFX Authoring System과는 계층적으로 분리되어 있지 않다.

따라서 현재 구현을 즉시 폐기하거나 교체할 필요는 없다.

오히려 다음 Adapter 경계를 두는 것이 안전하다.

`Generic VFX Definition → Godot Runtime Adapter → 현재 effects/draw Runtime`

기존 procedural 효과는 초기 Runtime Adapter 구현 또는 Legacy/Prototype Renderer로 흡수할 수 있다.

### 중요한 결론

현재 Runtime에서 이미 VFX의 핵심 실행 요구사항 일부가 확인된다.

- Lifetime
- Progress
- Position
- Start/Target
- Direction
- Effect Type
- Source/Weapon Type
- Color
- Scale
- Projectile Trail
- Impact Effect

따라서 VFX Core P0를 설계할 때 완전히 추상적인 기능을 먼저 만들기보다, 현재 Runtime이 실제로 소비하는 최소 개념을 기준으로 시작하는 것이 판별력이 높다.

### 미확인

아직 다음은 확인하지 않았다.

- 별도 VFX Editor Scene 존재 여부
- VFX 전용 Repository/Loader 존재 여부
- SQLite에 VFX Content Table 존재 여부
- 현재 effects 데이터가 다른 Script에서 어떻게 생성/소비되는지 전체 경로
- Godot Particle/Shader 기반 VFX의 실제 사용 범위
- 향후 Sprite 기반 VFX Asset 연결 경로

### PROPOSAL

다음 설계 단계에서는 먼저 **VFX Core P0 데이터 모델을 확정하기 전에 현재 Runtime VFX 생성/소비 경로 전체를 READ-ONLY로 추적**한다.

조사 순서:

`Effect 생성 → Effect 상태 저장 → Runtime Update → Renderer → 제거`

그 결과를 기반으로 Generic VFX Core와 Godot Adapter의 최소 경계를 결정한다.

### OUT OF SCOPE

이번 조사에서는 코드, Asset, SQLite, Editor를 변경하지 않았다.

### 상태

**PROPOSAL / INVESTIGATION RESULT**


## VFX Runtime 조사 — 생성 → 상태 → Update → Renderer → 제거

### CONFIRMED

현재 MENOS Runtime의 VFX 생명주기는 `game_controller.gd`의 `effects` 배열을 중심으로 구성되어 있다.

**1. 생성**

Gameplay Event 및 전투 함수에서 효과 Dictionary를 직접 생성한다.

주요 생성 경로:

- `weapon_fired` → `proj_defender`
- Enemy ranged attack → `proj_threat`
- Enemy melee attack → `impact_explosion`
- Damage 처리 → `impact_explosion` 계열
- Giant attack → Giant 관련 effect
- Robot damage → impact effect
- Skill 처리 → `damage_delay` 기반 effect

현재 효과 정의는 별도 VFX ID/Definition을 참조하지 않고 Runtime Dictionary에 직접 기록된다.

**2. 상태**

현재 Dictionary가 Runtime Instance 역할을 동시에 수행한다.

확인된 상태값 예:

- `type`
- `position`
- `start`
- `target`
- `target_enemy`
- `progress`
- `speed`
- `life`
- `max_life`
- `damage`
- `damage_delay`
- `damage_applied`
- `hit_applied`
- `source`
- `weapon`
- `enemy_type`

즉 현재 Runtime은 **Definition과 Instance가 분리되지 않은 상태**다.

**3. Update**

매 Frame `effects`를 순회하면서:

- `progress` 증가
- Projectile 도달 판정
- GameplayEvent 생성
- Damage 요청
- `damage_delay` 처리
- `life` 감소

를 수행한다.

중요하게도 현재 Effect Update 코드가 Gameplay Damage Event까지 직접 발생시킨다.

따라서 향후 Generic VFX Core에서는 **시각적 Timeline과 Gameplay 판정/이벤트를 분리할 필요가 있다.**

**4. Renderer**

현재 Renderer는 `_draw()`에서 `effect.type`을 직접 분기한다.

예:

- `giantHit` → Arc
- `impact_explosion` → Arc
- `proj_defender` → Line + Circle
- `proj_threat` → Line + Circle

따라서 현재 Renderer는 VFX Definition을 해석하는 일반 Renderer가 아니라 **Effect Type별 하드코딩 Renderer**다.

**5. 제거**

Update 마지막에서 다음 조건으로 `effects`를 Filter한다.

- Projectile: `progress < 1.0`
- 일반 효과: `life > 0.0`

즉 현재 Lifecycle은 기본적으로:

`Create → Update → Render → Filter/Delete`

구조다.

### 구조적 판정

현재 구현에서 이미 범용 VFX Core로 추출할 수 있는 개념은 충분히 존재한다.

특히:

`Lifetime + Progress + Transform + Target + Parameter + Event`

가 실제 Runtime 요구사항으로 확인된다.

그러나 현재 `progress` 완료가 Damage Event를 직접 발생시키므로, 앞으로는 다음처럼 책임을 분리하는 것이 적절하다.

`VFX Definition → VFX Instance → VFX Runtime`

그리고 Gameplay는:

`Game Event → Gameplay System`

으로 분리한다.

VFX Timeline의 Event는 Gameplay System에 직접 Damage를 주기보다 **추상 Event/Callback을 발생**시키고 MENOS Integration이 이를 해석하도록 하는 방향이 적절하다.

### 핵심 설계 발견

현재 MENOS의 Projectile은 사실상 **Gameplay Projectile + VFX를 하나의 Dictionary로 합친 구조**다.

향후에는 다음 분리가 필요하다.

`Projectile Gameplay State`
+
`Projectile Visual VFX Instance`

이를 분리하면 VFX Editor가 Projectile의 게임 규칙을 소유하지 않으면서도 Projectile Visual을 표현할 수 있다.

### 다음 최소 조사

다음 단계에서는 실제로 `impact_explosion`, `proj_defender`, `proj_threat`, Giant 효과가 어느 Gameplay Event에서 생성되는지와 현재 Skill VFX 경로를 추가로 확인하여 **Gameplay Event ↔ VFX 연결 지점**을 확정한다.

### 상태

**PROPOSAL / INVESTIGATION RESULT**


## VFX Editor — Skill ↔ VFX Integration 조사 결과

### 목적

현재 MENOS Runtime의 Skill 정의와 VFX Runtime 사이의 실제 연결 지점을 확인하고, 향후 범용 VFX Core와 MENOS Integration의 책임 경계를 정의한다.

### CONFIRMED

- `SkillDefinitionLoader`는 SQLite 기반 `skills` Catalog를 로드한다.
- `game_controller.gd`는 `skills_catalog`을 로드하고 Skill Slot의 ODB PK를 Skill ID로 해석한다.
- Skill Runtime 처리는 현재 `game_controller.gd`의 Runtime Effect Dictionary를 사용한다.
- 확인된 Skill Effect 상태에는 `skill_id`, `position`, `damage`, `damage_delay`, `damage_targets`, `target_enemy` 등이 포함된다.
- Skill Effect의 Update 과정에서 `damage_requested` Gameplay Event가 직접 생성되어 `_handle_gameplay_event()`로 전달된다.
- 현재 Skill Definition에서 별도의 VFX Definition/Asset ID를 연결하는 전용 계층은 확인되지 않았다.
- 따라서 현재 구조에서 Skill Gameplay Definition과 VFX Definition은 분리되어 있지 않다.

### 현재 Runtime 구조

현재 구현은 개념적으로 다음과 같다.

`SQLite skills → SkillDefinitionLoader → skills_catalog → GameController Skill Runtime → effects Dictionary → _draw()`

Skill의 시각적 표현은 별도 VFX Definition을 참조하기보다 현재 Runtime Effect의 `type`과 상태값에 의해 결정된다.

### 구조적 판정

향후 범용 VFX Core와 MENOS를 통합할 때 Skill이 VFX 구현을 직접 소유하는 구조는 피한다.

권장 경계:

`Skill Definition`
→ `VFX Trigger / VFX ID`
→ `Generic VFX Definition`
→ `VFX Runtime Adapter`
→ `Godot Renderer`

Skill은 어떤 VFX를 요청할지만 지정하고, Sprite / Particle / Beam / Trail / Timeline / Shader 등의 실제 VFX 구성은 VFX Editor와 VFX Definition이 소유한다.

또한 VFX Runtime은 Damage나 기타 Gameplay 규칙을 직접 결정하지 않는다.

Gameplay 경계는 다음과 같이 분리한다.

`Gameplay Event → Gameplay System`

시각적 표현은:

`Gameplay Event → VFX Trigger → VFX Instance → Renderer`

로 분리한다.

### Projectile / Skill 공통 경계

현재 Projectile과 Skill은 모두 Runtime Effect Dictionary를 통해 Gameplay와 Visual을 함께 처리하고 있다.

향후 구조에서는 다음처럼 분리한다.

`Gameplay State`
+
`VFX Instance`

특히 Projectile은:

`Projectile Gameplay State`
+
`Projectile Visual VFX Instance`

로 분리한다.

Skill 역시:

`Skill Gameplay State`
+
`Skill Visual VFX Instance`

로 분리한다.

이 구조를 사용하면 VFX Editor가 Skill/Projectile의 게임 규칙을 소유하지 않으면서도 해당 행동의 시각적 표현을 재사용할 수 있다.

### VFX Editor 책임

VFX Editor는 다음을 관리한다.

- VFX ID
- VFX Definition
- Visual Components
- Timeline / Sequencer
- Transform / Attachment
- Target / Direction 표현
- Parameter / Override
- Sprite / Particle / Beam / Trail 등의 구성
- Asset 및 Prompt Sidecar 연결
- Preview / Debug 정보
- Version / Revision
- Production Validation 정보

Skill Editor는 Skill Gameplay Definition을 관리하고, 필요한 경우 VFX ID 또는 VFX Trigger만 참조한다.

### UNVERIFIED

- 현재 SQLite `skills` 실제 데이터에 향후 사용할 VFX ID 후보 필드가 존재하는지 전체 데이터 기준으로는 아직 검증하지 않았다.
- 현재 Skill Editor가 VFX 연결 필드를 제공하는지는 별도 확인이 필요하다.
- 현재 Runtime에서 모든 Skill 유형의 시각 효과 경로가 동일한지는 아직 검증하지 않았다.

### OUT OF SCOPE

본 조사에서는 코드, Asset, SQLite 데이터를 변경하지 않는다.

### 상태

**PROPOSAL / INVESTIGATION RESULT**


## VFX Editor — SQLite Skill Catalog 실데이터 검증

### CONFIRMED

현재 `godot/content/menos.sqlite`의 `skills` 테이블을 직접 조회한 결과 4개 Skill Definition이 존재한다.

- `area_attack`
- `base_special`
- `finisher`
- `heavy_pierce`

확인된 주요 필드는 Skill별로 다음 범주다.

- 식별/표시: `id`, `name`
- 성장: `growth_available`
- 실행: `execution_type`
- Gameplay: `damage`, `radius`, `cooldown`, `energy_cost`, `duration`, `threshold`, `meter_max`, `charge_normal`, `charge_boss`
- 설명: `description`

현재 4개 Skill Definition 모두에 `vfx`, `vfx_id`, `effect_id`, `visual_effect` 등 VFX 연결용 전용 필드는 존재하지 않는다.

### CONFIRMED — 현재 Skill → VFX 관계

현재 SQLite 구조만으로는 Skill Definition이 특정 VFX Definition을 직접 참조하지 않는다.

따라서 현재 연결은:

`Skill Definition → Runtime Skill Logic → effects Dictionary → Procedural Renderer`

이며:

`Skill Definition → VFX Definition`

직접 연결은 아직 존재하지 않는다.

### 구조적 판정

VFX 연결을 추가할 경우 기존 Skill Gameplay 데이터에 VFX 구현 데이터를 직접 삽입하기보다 별도의 참조 필드 또는 Integration Mapping을 두는 것이 적절하다.

권장 방향:

`Skill Definition`
→ `VFX Reference / Trigger`
→ `Generic VFX Definition`

단, VFX 시스템 자체가 완성되기 전에는 SQLite Schema 변경을 수행하지 않는다.

### 설계상 중요한 점

현재 Skill 데이터의 `duration`은 Gameplay/Skill 실행 시간이며 VFX Timeline의 전체 재생 시간과 동일하다고 가정해서는 안 된다.

예를 들어:

- Skill Gameplay Duration
- VFX Pre-Charge
- VFX Active
- VFX Impact
- VFX Recovery

는 서로 다른 시간축이 될 수 있다.

따라서 향후 VFX Definition은 Skill의 `duration`을 그대로 재사용하지 않고 독립적인 Timeline/Lifecycle을 가져야 한다.

### UNVERIFIED

- Skill Editor UI에서 VFX 연결을 위한 미래 확장 지점은 아직 확인하지 않았다.
- 모든 Skill의 실제 Runtime 시각 연출이 현재 동일한 procedural 경로를 사용하는지는 추가 검증이 필요하다.

### OUT OF SCOPE

- SQLite Schema 변경
- Skill 데이터 변경
- VFX 데이터 생성
- Runtime 코드 변경

### 상태

**CONFIRMED / INVESTIGATION RESULT**


## VFX Editor — Skill Editor 현재 UI/저장 구조 대조

### CONFIRMED

현재 `godot/editor/skill_editor.gd`는 SQLite `skills` Catalog를 직접 편집한다.

현재 Skill Editor 필드:

- Skill ID
- Name
- Description
- Growth Available
- Execution Type
- Damage
- Radius
- Cooldown
- Energy Cost
- Duration

저장 시 `ObjectPersistence.save_catalog("skills", catalog)`를 통해 SQLite에 기록한다.

현재 Skill Editor에는 다음 VFX 관련 필드가 없다.

- VFX ID
- VFX Trigger
- VFX Timeline
- VFX Variant
- VFX Parameter Override
- Impact VFX
- Charge VFX
- Projectile VFX
- Animation/VFX Binding

### CONFIRMED — Editor 책임 구조

현재 Content Editor는 Skill Editor를 독립 Editor Scene으로 제공한다.

따라서 향후 VFX Integration을 추가할 경우 별도의 VFX Editor를 Content Editor 메뉴에 추가하고, Skill Editor에서는 VFX 구현 자체를 편집하지 않고 참조 관계만 관리하는 구조가 적절하다.

권장:

`Skill Editor`
→ Skill Gameplay Definition
→ VFX Reference / Trigger

`VFX Editor`
→ VFX Definition / Timeline / Visual Components

### 구조적 판정

현재 Skill Editor에 VFX 필드를 즉시 추가하지 않는다.

범용 VFX Core의 Definition/Repository/Editor 구조가 먼저 확정되어야 하며, 그 이후 Skill Editor와의 Integration 필드를 최소 범위로 추가해야 한다.

권장 Integration은 단순 참조부터 시작한다.

- `vfx_id`
- 필요 시 Event별 Trigger Mapping

VFX의 실제 구성 데이터는 Skill Catalog에 복제하지 않는다.

### UNVERIFIED

- VFX Editor 신규 Scene/Repository/SQLite Catalog가 아직 존재하지 않는다.
- Skill Editor와 VFX Editor 사이의 참조 무결성 Validator는 아직 존재하지 않는다.

### OUT OF SCOPE

이번 조사는 UI/코드 구조 확인만 수행했으며 코드나 SQLite Schema를 변경하지 않았다.

### 상태

**CONFIRMED / INVESTIGATION RESULT**


## VFX Integration 조사 — Robot / Unit / Tower / Enemy Visual 구조

### CONFIRMED

현재 Runtime 데이터에는 VFX 전용 Definition은 없지만 일부 Actor/Weapon Definition에 시각 리소스 참조가 이미 존재한다.

Robot:
- `animations`에 attack/death/finisher/hit/idle/move/projectile/skill1/skill2/skill3/special 참조가 존재한다.
- `projectile_anim`은 Robot Projectile Visual Asset/Animation ID를 참조한다.
- 현재 이는 Generic VFX Definition이 아니라 Robot Animation/Projectile Visual 참조다.

Allied Unit:
- `projectile_anim` 컬럼과 `visuals_json`이 존재한다.
- 일부 Unit은 `projectile_anim`으로 이미지 경로를 직접 보유한다.
- 일부 Unit은 projectile 참조가 비어 있다.
- 따라서 Unit의 projectile visual 체계도 현재는 VFX 시스템과 분리된 전용 Definition이 아니다.

Tower:
- Tower Definition에는 `animations`, `projectile_anim`, `projectile_frames`, `sprite_anim`, `sprite_frames` 계열의 시각 참조가 존재한다.
- 현재 `TowerRuntimeState.get_weapon_definition()`은 Tower Definition의 `visuals.projectile_anim`을 Weapon Definition으로 전달한다.

Enemy:
- Enemy Definition은 `sprite_anim`을 보유한다.
- 현재 확인된 값은 `enemy_normal_anim`, `enemy_heavy_anim`, `enemy_rusher_anim`, `enemy_giant_anim`이다.
- 이는 Actor Sprite Animation이며 Generic VFX 참조와는 별개다.

### 구조적 판정

현재 프로젝트에는 이미 다음과 같은 **Visual Reference 계층**이 존재한다.

`Robot/Unit/Tower/Enemy Definition → Animation / Projectile Visual Reference → Runtime`

그러나 이것을 그대로 Generic VFX 시스템으로 승격하면 책임이 섞인다.

구분해야 한다.

- Actor Animation: Robot/Unit/Enemy의 본체 동작
- Projectile Visual: 탄체/투사체 자체의 표현
- VFX: 발사, 궤적, 충돌, 폭발, 빔, 버프, 실드, 환경 효과 등 독립 효과

따라서 향후 통합 방향은 기존 Animation/Projectile 참조를 삭제하는 것이 아니라 VFX Adapter가 기존 Visual Reference를 필요에 따라 연결할 수 있도록 하는 방식이 적절하다.

### PROPOSAL

권장 구조:

`Actor Definition`
→ Actor Animation Reference

`Weapon / Projectile Definition`
→ Projectile Visual Reference
→ Optional VFX Trigger

`Skill Definition`
→ VFX Trigger / VFX Reference

`VFX Definition`
→ Sprite / Particle / Beam / Trail / Timeline / Shader

이렇게 하면 기존 데이터와 신규 Generic VFX 시스템의 마이그레이션 경계가 명확해진다.

### UNVERIFIED

- 현재 Projectile Visual Reference가 실제 Runtime에서 모든 종류에 사용되는 전체 경로
- 기존 Animation/Projectile Asset을 Generic VFX로 자동 변환할 수 있는 범위
- Tower/Unit/Enemy Editor의 해당 Visual Reference 편집 UI 전체

### OUT OF SCOPE

- 기존 Visual Reference 제거
- SQLite Schema 변경
- VFX Catalog 생성
- Runtime Adapter 구현

### 상태

**CONFIRMED / INVESTIGATION RESULT / PROPOSAL**


## VFX Integration 조사 — 기존 Projectile Visual의 실제 Runtime 소비 경로

### CONFIRMED

현재 `projectile_anim`은 데이터 계층에 존재하지만, 현재 `GameController`의 Projectile VFX Renderer가 이를 실제 Sprite로 소비하지 않는다.

확인된 Runtime 경로:

`Weapon/Gameplay Event`
→ `effects Dictionary`
→ `proj_defender / proj_threat`
→ `start / target / progress`
→ `_draw()`
→ procedural line + circle

현재 Renderer에는 다음 명시적 구현이 있다.

- Defender Projectile: 이동 경로를 `draw_line()`으로 표시
- Defender Projectile: 현재 위치를 `draw_circle()`으로 표시
- Threat Projectile: 동일한 procedural 방식
- Impact: `draw_arc()` 기반 procedural effect
- 코드 주석상 Projectile Gameplay Art는 연결되어 있지 않고 procedural VFX만 사용한다.

따라서 현재 `projectile_anim`은 **Authoring/Data Reference로 존재하지만 실제 Projectile VFX Renderer에는 연결되지 않은 상태**다.

### CONFIRMED — 중요한 경계

현재 프로젝트에는 두 개의 서로 다른 Visual 경로가 존재한다.

1. Actor Animation Visual
   - Robot/Unit/Enemy/Tower의 Sprite/Animation
   - 실제 본체 렌더링에 사용

2. Projectile/Impact Procedural VFX
   - Runtime `effects` Dictionary
   - `proj_defender`, `proj_threat`, `impact_explosion`
   - GameController 직접 렌더링
   - 현재 Sprite Asset과 분리

따라서 기존 `projectile_anim`을 단순히 VFX Asset으로 이름만 변경하는 방식은 적절하지 않다.

### 구조적 판정

향후 Generic VFX Adapter는 다음 경계를 가져야 한다.

`Projectile Gameplay State`
→ Projectile Movement / Damage

동시에:

`Projectile Visual Reference 또는 VFX Reference`
→ VFX Runtime Instance
→ VFX Renderer

즉 Projectile의 Gameplay State와 Visual VFX를 분리한다.

기존 procedural Renderer는 초기 Adapter의 Legacy Renderer로 유지할 수 있다.

### PROPOSAL

마이그레이션 우선순위:

1. 현재 procedural Projectile VFX를 Generic VFX Runtime이 표현할 수 있는 최소 Definition으로 모델링
2. 기존 `proj_defender` / `proj_threat`를 Adapter에서 호출
3. 이후 Sprite/Trail/Beam 등의 VFX Definition을 연결
4. 마지막에 기존 GameController 직접 `draw_*()` 구현을 단계적으로 Adapter 뒤로 이동

기존 `projectile_anim` Asset Reference는 이 과정에서 별도 Projectile Visual Reference로 유지한다.

### UNVERIFIED

- 현재 `projectile_anim`이 다른 Runtime 경로에서 간접적으로 소비되는지 여부
- 모든 Projectile 종류가 동일한 procedural Renderer를 사용하는지 여부
- 향후 Generic VFX Adapter가 현재 Renderer를 어느 수준까지 재사용할 수 있는지

### OUT OF SCOPE

- Projectile Renderer 코드 변경
- 기존 Asset 연결 변경
- VFX Definition 생성
- SQLite Schema 변경

### 상태

**CONFIRMED / INVESTIGATION RESULT / PROPOSAL**


## VFX Integration 조사 — Skill / Finisher 실제 Visual 소비 경로

### CONFIRMED

현재 Skill 실행은 별도의 VFX Definition을 호출하지 않는다.

실제 Runtime은 Skill 실행 시 `effects` Dictionary를 직접 생성한다.

Area Skill:
- `type = area`
- `position`
- `life = skill.duration`
- `damage_delay`
- `damage_targets`
- `damage`
- `source = skill_id`

Target Pierce Skill:
- `type = pierce`
- `position`
- `life = skill.duration`
- `damage_delay`
- `target_enemy`
- `damage`
- `source = skill_id`

Finisher:
- `type = area`
- `life = finisher.duration`
- `damage_delay`
- `damage_targets`
- `damage`
- `source = finisher`

Skill Runtime Update는 `damage_delay`가 만료되면 `damage_requested` Gameplay Event를 직접 생성한다.

즉 현재 구조는:

`Skill Definition → Skill Runtime Logic → effects Dictionary → Gameplay Damage Event + Renderer`

이다.

### CONFIRMED — 중요한 분리점

현재 `skill.duration`은 Skill Gameplay State의 실행 시간으로 사용된다.

동시에 같은 값을 `effects.life`에 넣어 Visual Effect의 수명처럼 사용한다.

따라서 현재 Prototype에서는 Gameplay Duration과 Visual Lifetime이 결합되어 있다.

향후 Generic VFX에서는 이를 분리해야 한다.

`Skill Gameplay Duration`
≠
`VFX Timeline Duration`

### 구조적 판정

Skill VFX Integration의 최소 단위는 Skill 자체에 VFX 구현 데이터를 넣는 것이 아니라:

`Skill Definition`
→ `VFX Trigger / VFX Reference`
→ `VFX Instance`

로 두는 것이 적절하다.

Gameplay 처리는 별도로:

`Skill Runtime`
→ `damage_requested`

로 유지한다.

### PROPOSAL

기존 Skill Runtime을 바로 교체하지 않고 Adapter 계층에서 다음을 연결하는 것이 안전하다.

`Skill Activated`
→ Gameplay Skill Runtime

동시에:

`Skill Activated / Skill Impact`
→ VFX Trigger
→ Generic VFX Instance

이 구조라면 Skill의 Damage Timing과 VFX Timeline을 독립적으로 조정할 수 있다.

### UNVERIFIED

- Skill의 현재 `_draw()` 렌더링이 Area/Pierce를 어떤 구체적 형태로 표시하는지 전체 경로
- Skill별 개별 Sprite/Animation Asset이 현재 연결되어 있는지
- Finisher 전용 Visual Asset이 실제 Runtime에 존재하는지

### OUT OF SCOPE

- Skill Runtime 변경
- Skill SQLite 변경
- VFX 연결 필드 추가
- VFX Asset 생성

### 상태

**CONFIRMED / INVESTIGATION RESULT / PROPOSAL**


## VFX Integration 조사 — Skill Actor Animation과 VFX의 경계

### CONFIRMED

Robot Runtime Renderer는 Skill 실행 중 다음 우선순위로 Actor Animation을 선택한다.

1. `special > 0` → `special`
2. `attack > 0.3` → `attack`
3. `area > 5.0` 또는 `pierce > 6.0` → `skill1`
4. 이동 → `move`
5. 그 외 → `idle`

따라서 현재 Skill Runtime의 Visual은 Generic VFX가 아니라 Robot Actor Animation을 직접 소비한다.

특히 현재 Skill 1/2/3 구분이 Runtime Renderer의 개별 VFX 또는 개별 Skill Animation으로 연결되어 있지 않다. Area/Pierce 조건 모두 `skill1` Animation을 선택한다.

Finisher 역시 별도 `finisher` Actor Animation을 선택하는 구조가 아니라 `special` 상태를 통해 `special` Animation을 선택한다.

### CONFIRMED — 현재 시각 경로

현재 Skill의 시각 처리는 사실상 두 계층으로 나뉜다.

`Skill Runtime State`
→ Robot Actor Animation (`skill1` / `special`)

동시에:

`Skill Runtime Effect`
→ procedural `area` / `pierce` VFX

즉 Actor Animation과 VFX가 하나의 시스템으로 통합되어 있지 않다.

### 구조적 판정

향후 Generic VFX System에서는 다음을 명확히 분리해야 한다.

- Actor Animation: 캐릭터의 동작/포즈
- VFX: 공격/충격/범위/에너지/이펙트 시각화
- Gameplay: Damage, Cooldown, Energy, Target 등의 규칙

예:

`Skill`
→ Actor Animation Reference
→ VFX Trigger / VFX Reference
→ Gameplay Execution

각 요소의 Timeline은 독립적으로 관리한다.

### PROPOSAL

Skill Editor에는 실제 VFX 구현을 넣지 않고 최소한의 연결 정보만 보유하는 구조가 적절하다.

예:
- Actor Animation Reference
- VFX Trigger
- VFX ID
- Impact VFX ID
- Optional VFX Parameter Override

VFX Editor가 실제 VFX Definition과 Timeline을 소유한다.

### UNVERIFIED

- Skill 2/3용 Actor Animation Asset이 실제 Robot Catalog에 존재하더라도 현재 Runtime이 선택하는 경로
- Finisher 전용 Actor Animation의 현재 실제 소비 여부
- Skill별 VFX Resource가 별도로 존재하는지

### OUT OF SCOPE

- Skill Animation 선택 로직 수정
- VFX 연결 필드 추가
- Skill Editor UI 변경
- Asset 생성

### 상태

**CONFIRMED / INVESTIGATION RESULT / PROPOSAL**


## VFX Asset Inventory 조사 — 기존 Impact / Skill 이미지 대조

### CONFIRMED

현재 `godot/assets/menos/sprites`에 VFX 성격의 이미지 리소스가 존재한다.

확인된 주요 리소스:
- `impact_blast.png`
- `impact_explosion.png`
- `atlas_skill.png`

현재 `game_controller.gd`에는 `impact_explosion`이 preload된 기록이 있으나, 실제 Effect Renderer는 `impact_explosion.png` Sprite를 렌더링하지 않고 procedural `draw_arc()`를 사용한다.

따라서 이미지 리소스의 존재와 Runtime VFX 소비는 별개의 상태다.

### CONFIRMED — Prompt Sidecar

확인한 3개 이미지에는 현재 다음 1:1 Sidecar가 존재하지 않는다.

- `atlas_skill.png.prompt.md` — 없음
- `impact_blast.png.prompt.md` — 없음
- `impact_explosion.png.prompt.md` — 없음

이는 해당 이미지의 원본 생성 Prompt가 없다는 뜻이 아니라, 현재 프로젝트 파일 구조에서 검증 가능한 Prompt Sidecar가 없다는 뜻이다.

### 구조적 판정

현재 프로젝트에는 이미 VFX 후보 이미지와 procedural VFX 구현이 동시에 존재한다.

즉 현재 상태는:

`VFX Image Resource`
+
`Procedural Runtime VFX`

가 병존하는 Transitional 상태다.

향후 VFX Editor는 이 둘을 임의로 하나로 합치는 것이 아니라, 각각을 명시적인 VFX Component/Renderer Source로 등록할 수 있어야 한다.

예:

`VFX Definition`
→ Sprite Component → `impact_explosion.png`

또는:

`VFX Definition`
→ Procedural/Beam/Trail Component

그리고 모든 생성 이미지 리소스는 기존 Canon에 따라:

`Image`
→ `<image>.prompt.md`
→ Asset Authoring Metadata
→ VFX Definition
→ Runtime

의 추적성을 가져야 한다.

### UNVERIFIED

- `impact_blast.png`의 현재 Runtime 소비 여부
- `impact_explosion.png`가 과거 구현 잔재인지 향후 사용 예정 리소스인지
- `atlas_skill.png`의 실제 Production 사용 범위
- 해당 이미지들의 원본 생성 Prompt 존재 여부

### OUT OF SCOPE

- 이미지 삭제
- 이미지 교체
- Prompt 추정/생성
- VFX Editor 구현
- Runtime Renderer 변경

### 상태

**CONFIRMED / INVESTIGATION RESULT / PROPOSAL**


## VFX Asset Catalog 조사 — 기존 Catalog 등록 여부

### CONFIRMED

현재 SQLite `visual_assets` Catalog는 24개 Visual Asset을 보유하고 있다.

24개 항목은 모두 Robot Animation 계열이다.
- Asura: attack / death / finisher / hit / idle / move / profile / projectile / skill1 / skill2 / skill3 / special
- Valkyrie: 동일 12종

따라서 현재 Catalog에는:
- `impact_blast`
- `impact_explosion`
- `atlas_skill`

에 해당하는 Visual Asset 항목이 없다.

### 구조적 판정

현재 Asset Catalog는 사실상 Robot Visual Authoring에 집중되어 있으며, Generic VFX Resource Catalog로는 아직 확장되지 않은 상태다.

따라서 향후 VFX Editor를 구현할 때 기존 Asset Catalog를 무시하고 별도 이미지 관리 체계를 만드는 것은 적절하지 않다.

권장 경계는:

`Asset Catalog`
→ 공통 Visual Resource / Source Image 관리

`VFX Editor`
→ VFX Definition / Component / Timeline / Trigger 관리

`Runtime Adapter`
→ Godot Runtime 소비

즉 동일한 이미지 Resource를 Asset Catalog와 VFX Editor가 각각 복제 관리하지 않는 구조가 필요하다.

### PROPOSAL

VFX Editor는 이미지 파일 자체를 소유하기보다 Asset Catalog의 Visual Resource를 참조하는 방향이 적절하다.

예:

`Asset Catalog Visual Resource`
→ `VFX Sprite Component`
→ `VFX Definition`
→ Runtime

Prompt Sidecar 역시 Asset Resource의 Authoring Metadata로 유지하고, VFX Definition에서는 해당 Resource를 참조한다.

### UNVERIFIED

- 향후 Generic VFX Resource가 현재 `visual_assets` 단일 Catalog에 통합될지
- 별도 VFX Catalog가 필요한지
- VFX Definition 자체를 SQLite에 저장할지

### OUT OF SCOPE

- Catalog Schema 변경
- VFX Catalog 생성
- 이미지 등록
- VFX Editor 구현

### 상태

**CONFIRMED / INVESTIGATION RESULT / PROPOSAL**


## VFX Definition 저장 계층 조사 — 기존 Content Catalog 패턴 대조

### CONFIRMED

현재 SQLite에는 Content별 Catalog/Definition 저장이 혼재하지만, 주요 Authoring 데이터는 다음 구조를 사용한다.

`Editor → ObjectPersistence / Repository → SQLite Catalog → Loader / Definition → Runtime`

현재 VFX 전용 SQLite 테이블은 존재하지 않는다.

현재 확인된 관련 테이블:
- `visual_assets`: Visual Resource Catalog
- `skills`: Skill Definition Catalog
- `robots`, `towers`, `allied_units`, `enemies`: Actor/Combat Definition
- `stage_catalog`: Stage Catalog

### 마리의 판정

VFX Definition은 Runtime 코드 안의 Dictionary로 계속 유지하기보다, 향후 독립적인 Definition/Repository/Loader 계층으로 분리하는 것이 구조적으로 적절하다.

권장 목표 구조:

`VFX Editor`
→ `VFX Repository`
→ `VFX Definition Catalog`
→ `VFX Definition Loader`
→ `Generic VFX Runtime`
→ `Godot Runtime Adapter`

Visual Resource는 별도로:

`Asset Editor`
→ `Visual Asset Catalog`
→ `VFX Definition의 Visual Resource Reference`

로 연결한다.

따라서 VFX Definition과 Visual Asset은 동일한 데이터가 아니며, 하나의 테이블에 합치는 것보다 분리하는 편이 적절하다.

### PROPOSAL

향후 VFX 저장 모델은 최소한 다음 두 계층으로 분리한다.

1. Visual Resource
   - 이미지/스프라이트 등 실제 리소스
   - Prompt Sidecar 참조
   - Asset Catalog 관리

2. VFX Definition
   - VFX ID
   - Component 구성
   - Timeline
   - Transform/Attachment
   - Trigger
   - Parameters
   - Visual Resource Reference
   - Revision / Status
   - Production Validation 정보

현재 단계에서는 Schema나 SQLite 테이블을 생성하지 않는다.

### UNVERIFIED

- VFX Definition 전용 SQLite Table의 최종 명칭
- VFX Definition JSON 구조
- Generic VFX Core의 실제 Runtime Class 구조
- VFX Editor에서 어떤 필드를 직접 편집할지

### OUT OF SCOPE

- SQLite Schema 변경
- VFX Definition 구현
- VFX Repository/Loader 구현
- VFX Editor 구현

### 상태

**CONFIRMED / PROPOSAL / INVESTIGATION RESULT**


## VFX Definition 최소 데이터 모델 — Runtime 역추출

### CONFIRMED

현재 Runtime Effect Dictionary에서 반복적으로 확인되는 값은 다음과 같다.

Runtime Instance 성격:
- position
- start / target
- target_enemy / target_actor
- progress
- life / max_life
- damage_delay
- damage_applied / hit_applied
- damage
- source / weapon
- speed
- enemy_type

이 값들은 모두 VFX Definition에 그대로 저장해야 하는 값은 아니다.

특히 `damage`, `target_enemy`, `damage_delay`, `damage_applied`는 Gameplay Runtime 상태에 속하며 Generic VFX Definition의 책임으로 가져가면 안 된다.

### 마리의 판정

VFX Definition의 최소 Authoring 데이터는 다음 정도로 제한하는 것이 적절하다.

1. Identity
   - VFX ID
   - Category / Type
   - Revision
   - Status

2. Visual Composition
   - Component 목록
   - Visual Resource Reference
   - Component별 파라미터

3. Timing
   - Timeline / Duration
   - Loop
   - Playback / Completion 정책

4. Transform
   - World / Local / Screen / Attached
   - Anchor / Pivot
   - Scale / Rotation

5. Direction / Target
   - Directional 여부
   - Target Resolver Reference
   - Start / End 또는 Attached 기준

6. Trigger
   - Gameplay Event / Explicit Trigger
   - Trigger 조건 또는 Trigger ID

7. Runtime Policy
   - Priority
   - Concurrency
   - Interrupt
   - Pooling / Performance 정책

8. Authoring Metadata
   - Prompt-linked Visual Resource
   - Revision
   - Production Validation Status

반대로 다음은 VFX Definition에 직접 넣지 않는다.

- 현재 Target Actor 인스턴스
- 현재 HP Damage
- 실제 Gameplay Damage 처리
- Runtime Progress
- Runtime Damage Applied 상태
- Runtime Hit Applied 상태

이 값들은 VFX Instance 또는 Gameplay Runtime의 상태로 분리한다.

### 목표 구조

`VFX Definition`
→ `VFX Instance`
→ `Runtime Adapter`

그리고 Gameplay는 별도로:

`Gameplay Event`
→ `Gameplay System`

필요한 경우:

`Gameplay Event`
→ `VFX Trigger`
→ `VFX Instance`

로 연결한다.

### PROPOSAL

현재 `game_controller.gd`의 procedural effects를 이 최소 모델로 직접 재작성하지 않는다.

먼저 현재 `proj_defender`, `proj_threat`, `impact_explosion`, `giantHit`를 각각 향후 VFX Definition으로 표현할 수 있는지 대조한 뒤 Adapter 경계를 정의하는 것이 안전하다.

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Core 대조 — 기존 Procedural VFX 4종

### CONFIRMED

현재 Runtime의 대표적인 VFX 표현은 다음 4개 계열로 분류할 수 있다.

1. `proj_defender`
   - Start / Target
   - Progress
   - Direction
   - Projectile body
   - Trail
   - Weapon-based visual parameter

2. `proj_threat`
   - Start / Target
   - Progress
   - Direction
   - Projectile body
   - Trail
   - Enemy-side visual parameter

3. `impact_explosion`
   - Position
   - Lifetime / Progress
   - Scale
   - Color
   - Impact ring

4. `giantHit`
   - Position
   - Fixed ring geometry
   - Boss-specific visual trigger

### 대조 결과

이 4종만으로도 Generic VFX Core가 최소한 다음 Primitive를 지원해야 함을 확인할 수 있다.

- Sprite / Shape
- Line / Trail
- Ring / Arc
- Position
- Start → Target
- Direction
- Scale
- Color / Alpha
- Lifetime
- Progress
- Attached / World 위치 기준
- Parameter Override

특히 Projectile은 단순 Sprite 하나가 아니라 **Body + Trail + Direction + Start/Target + Progress**의 Composition이다.

Impact는 **Ring/Shape + Lifetime + Scale + Alpha** 구조로 일반화할 수 있다.

Giant Hit은 별도의 Giant 전용 Core가 필요한 것이 아니라, Generic Ring/Impact VFX의 특정 Definition으로 표현할 수 있는 후보이다.

### 마리의 판정

현재 Runtime의 4개 계열은 Generic VFX Core 설계의 최소 검증 사례로 충분하다.

따라서 VFX Core에 처음부터 Particle/Shader/Complex Simulation 등을 필수 Primitive로 넣을 필요는 없다.

최소 Core는:

`Shape/Sprite + Trail/Line + Ring + Transform + Timeline + Parameter`

정도로 시작할 수 있다.

향후 Beam, Particle, Shader 등은 확장 Component로 추가한다.

이는 현재 Prototype Runtime을 과도하게 확장하지 않고도 Generic VFX 방향으로 이전할 수 있는 구조다.

### UNVERIFIED

- Sprite Component의 실제 Runtime Adapter 구현 방식
- Particle/Shader Component의 Godot 구현 방식
- Trail의 장기적인 데이터 표현
- 여러 Component를 하나의 Timeline에서 동기화하는 최종 Schema

### OUT OF SCOPE

- Runtime Renderer 변경
- Procedural VFX 이관
- VFX Core 코드 구현
- 기존 VFX Asset 교체

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Timeline ↔ Gameplay Event 경계 조사

### CONFIRMED

현재 Runtime에서 Projectile은 VFX 진행률이 Gameplay 판정 시점을 직접 결정한다.

`progress >= 1.0`
→ `damage_requested`
→ Gameplay 처리

Skill/Area/Pierce 계열은 `damage_delay`가 만료되면
→ `damage_requested`
→ Gameplay 처리

즉 현재 구조에서는 VFX-like Effect가 Gameplay Timing까지 담당한다.

### 마리의 판정

Generic VFX에서는 Timeline과 Gameplay 판정을 분리해야 한다.

권장 구조:

`Gameplay Event`
→ `VFX Trigger`
→ `VFX Instance`
→ Timeline 재생

Gameplay 판정이 필요한 경우:

`Gameplay System`
→ 별도의 Hit / Damage Event

그리고 VFX Timeline은 해당 이벤트를 **발생시키는 주체가 아니라 시각적 재생을 담당**한다.

예를 들어 Projectile은:

`weapon_fired`
→ Gameplay Projectile State 생성
→ VFX Projectile Instance 생성

Projectile 도착:

`Projectile Gameplay State`
→ `damage_requested`

동시에:

`Projectile Gameplay State / Hit Event`
→ `impact VFX Trigger`

로 분리한다.

따라서 VFX Definition의 Timeline에 `damage`, `target`, `damage_delay`를 저장하지 않는다.

### 중요한 결과

현재 `damage_delay`와 `skill.duration`을 VFX Timeline Duration으로 그대로 이전하면 안 된다.

- Gameplay Duration = Gameplay 규칙
- VFX Duration = 시각적 재생 시간

두 값은 우연히 같을 수 있지만 서로 독립적이어야 한다.

### PROPOSAL

향후 VFX Core는 다음 이벤트만 알 수 있도록 제한한다.

- Start
- Marker / Cue
- Complete
- Cancel
- Interrupt

Gameplay 의미의 Damage / HP / Cooldown / Target 판정은 VFX Core가 알지 않는다.

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Trigger 소유권 조사 — Gameplay Event 기반 책임 경계

### CONFIRMED

현재 MENOS에는 공통 `GameplayEvent`가 존재한다.

주요 이벤트:
- `weapon_fired`
- `damage_requested`

이벤트에는:
- type
- source
- source_id
- target
- position
- damage
- payload

등이 존재한다.

현재 `GameController`가 `weapon_fired`를 받아 Projectile Effect를 생성하고, Effect 진행이 완료되면 `damage_requested`를 생성한다.

### 마리의 판정

VFX Trigger의 기본 입력은 개별 Actor가 직접 VFX를 생성하는 방식보다 **Gameplay Event**를 사용하는 것이 적절하다.

권장 구조:

`Gameplay Event`
→ `VFX Trigger Resolver`
→ `VFX ID / Variant`
→ `VFX Instance`

이렇게 하면 Robot / Unit / Tower / Enemy / Skill 각각이 VFX 생성 코드를 중복 보유하지 않는다.

### 책임 분리

**Robot / Unit / Tower / Enemy / Skill**
- Gameplay Definition
- Animation Reference
- 필요한 VFX Reference 또는 Trigger Key

**Gameplay System**
- Gameplay Event 생성
- 실제 Gameplay 판정

**VFX Trigger Resolver**
- Event + Source + Context를 VFX ID/Variant로 변환

**VFX Editor**
- VFX Definition 자체를 관리

**Runtime Adapter**
- VFX Definition을 실제 Godot Node/Draw/Particle/Sprite 등으로 실행

### Trigger와 Reference의 구분

직접적인 상황별 VFX ID를 모든 Gameplay Definition에 과도하게 저장하기보다는 다음 두 단계가 필요하다.

- Trigger Key: `weapon_fire`, `projectile_hit`, `skill_activate`, `skill_impact`, `giant_hit`
- VFX Binding: 특정 Context에서 Trigger Key를 어떤 VFX ID/Variant로 사용할지 결정

예:

`weapon_fired + robot`
→ `weapon_fire`
→ `vfx.projectile.robot`

`damage_requested + giant`
→ `projectile_hit`
→ `vfx.impact.giant`

### PROPOSAL

Trigger Key와 VFX ID를 분리한다.

이를 통해 동일한 Gameplay Event를 여러 VFX Definition이 공유할 수 있고, MENOS뿐 아니라 다른 게임에서도 Generic VFX Core를 재사용할 수 있다.

MENOS Integration 계층만 Context-specific Binding을 담당한다.

### UNVERIFIED

- 최종 Trigger Binding 저장 위치
- Skill/Weapon Definition에 Trigger Key를 저장할지 별도 Binding Catalog로 둘지
- Event Bus가 별도로 필요한지 현재 GameController Dispatcher로 충분한지

### OUT OF SCOPE

- GameplayEvent 수정
- Trigger Resolver 구현
- VFX Binding Schema 구현
- Runtime Adapter 구현

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Trigger Binding 저장 위치 조사

### CONFIRMED

현재 Content는 기능별 Catalog로 분리되어 있다.

예:
- Skill → `skills`
- Robot → `robots`
- Tower → `towers`
- Enemy → `enemies`
- Visual Resource → `visual_assets`

Runtime의 `weapon_fired` Event는 Robot/Tower 양쪽에서 발생하며, 공통 Handler에서 Projectile Runtime으로 연결된다.

따라서 동일한 Trigger Binding을 각 Definition에 직접 복제하면 다음 문제가 생긴다.

- Robot/Tower/Skill마다 동일 Binding 구조가 반복됨
- VFX 변경 시 여러 Definition 수정 필요
- Generic VFX Core와 MENOS Integration의 경계가 흐려짐

### 마리의 판정

**별도 VFX Binding Catalog**를 두는 방향이 가장 적절하다.

권장 구조:

`Gameplay Definition`
→ Event / Trigger Key

`VFX Binding Catalog`
→ Context + Trigger Key → VFX ID / Variant

`VFX Definition Catalog`
→ 실제 VFX 구현

예:

| Context | Trigger Key | VFX ID |
|---|---|---|
| robot | weapon_fire | vfx.projectile.robot |
| tower | weapon_fire | vfx.projectile.tower |
| enemy | weapon_fire | vfx.projectile.enemy |
| any | projectile_hit | vfx.impact.default |
| giant | projectile_hit | vfx.impact.giant |
| skill.area_attack | skill_activate | vfx.skill.area |
| skill.area_attack | skill_impact | vfx.skill.area_impact |

### 예외

항상 Binding Catalog를 거쳐야 하는 것은 아니다.

정말 고유한 VFX Reference가 필요한 경우 Gameplay Definition이 직접 Reference를 가질 수 있다.

다만 이것은 **Override/Explicit Reference**로 취급하고 기본 경로는 Binding Catalog로 유지한다.

### 권장 저장 계층

`skills / robots / towers / enemies`
→ Gameplay Definition

`vfx_bindings`
→ MENOS Integration Binding

`vfx_definitions`
→ Generic VFX Definition

`visual_assets`
→ Visual Resource

Prompt는 기존 Canon에 따라 Visual Resource의 Sidecar로 관리한다.

### PROPOSAL

초기 Generic VFX 시스템에서는 다음 3개를 분리한다.

1. Visual Asset
2. VFX Definition
3. VFX Binding

이를 하나의 Catalog에 합치지 않는다.

특히 VFX Binding은 Generic VFX Core가 아니라 **MENOS Integration 영역**으로 둔다.

### UNVERIFIED

- 최종 SQLite table 명칭
- Binding의 정확한 Context 표현식
- Variant/Override 상속 규칙

### OUT OF SCOPE

- SQLite schema 생성
- VFX Binding Editor 구현
- VFX Definition Editor 구현

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Binding Context 모델 조사

### CONFIRMED

현재 `GameplayEvent`는 이미 최소한의 Context 정보를 가진다.

- `type`
- `source`
- `source_id`
- `target`
- `position`
- `payload`

따라서 VFX Binding을 위해 별도의 복잡한 Runtime Context 객체를 처음부터 만들 필요는 없다.

### 마리의 판정

Binding Context는 **계층적이고 결정적인 매칭**으로 설계하는 것이 적절하다.

권장 우선순위:

1. Event + Source + Source ID
2. Event + Source
3. Event + Context Tag
4. Event 기본값

예:

`weapon_fired + robot + asura`
→ `vfx.projectile.asura`

없으면:

`weapon_fired + robot`
→ `vfx.projectile.robot`

없으면:

`weapon_fired`
→ `vfx.projectile.default`

### Context 표현

Binding에 임의의 코드식 조건식을 넣지 않는다.

초기 모델은 다음처럼 단순한 Key/Value Context를 사용한다.

- event_type
- source_type
- source_id
- context_tags
- priority
- vfx_id
- variant

`context_tags`는 선택적 확장점으로 두되, 초기 Runtime에서 복잡한 Query Language를 만들지 않는다.

### 결정성

동일 Event가 여러 Binding에 일치할 경우 반드시 동일한 결과가 나와야 한다.

따라서 Binding Resolver는:

**Exact Match → Source Match → Tag Match → Default**

순서와 명시적인 Priority 규칙을 사용한다.

동점 Binding은 Production Validation에서 오류로 처리한다.

### Override

VFX Parameter Override는 Binding 단계에서 허용할 수 있다.

예:

`vfx.projectile.default`
+ `color = enemy`
+ `scale = 1.2`

그러나 VFX Definition 자체를 Runtime에서 수정하는 것이 아니라 **Instance Override**로 전달한다.

### PROPOSAL

초기 VFX Binding 모델은 다음 정도로 제한한다.

`event_type + source_type + source_id + tags + priority → vfx_id + variant + overrides`

복잡한 조건식, Script Callback, Expression Language는 초기 범위에서 제외한다.

### UNVERIFIED

- 현재 모든 Gameplay Event가 충분한 source/source_id를 갖는지
- payload를 Context Tag 생성에 사용할 필요가 있는지
- Variant와 Override의 최종 저장 형식

### OUT OF SCOPE

- Resolver 구현
- Binding Schema 구현
- Editor UI 구현
- GameplayEvent 수정

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Transform / Attachment 모델 조사

### CONFIRMED

현재 MENOS Runtime은 전투 Actor와 Effect 위치를 `Vector2` 기반으로 직접 관리한다.

- Robot position
- Enemy position
- Tower position
- Projectile start / target
- Impact position

Actor Sprite는 Actor 위치에 따라 별도 Render Node를 이동한다.

현재 Projectile은 Actor에 Child로 붙는 구조가 아니라 Start/Target 좌표를 가진 독립 Effect로 처리된다.

### 마리의 판정

Generic VFX Core에는 최소 4가지 Transform Space가 필요하다.

1. **World**
   - 월드 좌표에 고정
   - Impact / Explosion / Ground Effect

2. **Attached**
   - 특정 Actor/Node를 따라감
   - Shield / Aura / Buff / Status / Character Effect

3. **Local**
   - Parent Transform 기준 상대 좌표
   - Composite VFX의 Child Component

4. **Screen**
   - Camera/World와 무관한 화면 좌표
   - Combat UI Effect / Screen Flash / HUD Effect

Projectile은 별도의 특수 Space가 아니라:

**World + Start/Target + Direction + Progress**

조합으로 처리한다.

### Anchor / Pivot

VFX Definition에는 최소한 다음 기준이 필요하다.

- Anchor
- Pivot
- Offset
- Rotation
- Scale

특히 Attached VFX에서는 Actor의 중심점과 Effect의 시각적 중심점이 다를 수 있으므로 Offset을 Definition에 둘 수 있어야 한다.

### Attachment

Attached VFX Instance는 다음 상태만 보유한다.

- parent reference
- local offset
- local rotation
- local scale

Parent가 제거되었을 때의 정책은 VFX Instance Lifecycle에서 결정한다.

초기 정책은 명시적으로:

- Follow Parent
- Detach and Continue
- Cancel with Parent

중 하나를 선택할 수 있게 한다.

### Direction

Directional VFX는 Target Actor를 직접 소유하지 않는다.

다음 중 하나를 입력으로 받는다.

- explicit direction
- start → target direction
- parent forward direction

따라서 VFX Core가 Gameplay Target의 의미를 알 필요가 없다.

### PROPOSAL

초기 Generic VFX Transform 모델:

`space + anchor + offset + rotation + scale + direction`

Attachment가 필요한 경우:

`parent_handle + follow_policy`

를 추가한다.

World / Attached / Local / Screen 네 가지 Space를 Core 표준으로 정의한다.

### UNVERIFIED

- 현재 Camera/Canvas UI VFX가 실제로 필요한 범위
- Parent 제거 시 최종 정책
- 2D Rotation/Scale 외 추가 Transform 요구사항

### OUT OF SCOPE

- Runtime Transform Adapter 구현
- Node/CanvasLayer 구조 변경
- 기존 Projectile Renderer 변경

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Component / Timeline 최소 Authoring 모델 조사

### CONFIRMED

현재 Procedural VFX에서 확인되는 시각 구성은 크게 다음으로 분해된다.

- Projectile Body: Circle/Shape
- Projectile Trail: Line
- Impact: Ring/Arc
- Giant Hit: Ring/Arc
- 공통 상태: lifetime / progress / position / scale / color

따라서 현재 Runtime을 Generic VFX로 추상화할 때 하나의 `type`으로 모든 효과를 표현할 필요가 없다.

### 마리의 판정

VFX Definition은 **Composition**을 기본으로 한다.

최소 Component 종류:

- Sprite
- Shape
- Line / Trail
- Ring
- Beam

Particle / Shader / Mesh 등의 고급 Component는 Core 필수 요소가 아니라 Extension으로 둔다.

예:

**Projectile**
- Shape
- Trail
- Direction
- Start/Target
- Timeline

**Impact**
- Ring
- Transform
- Timeline

**Beam**
- Line/Beam
- Start/Target
- Timeline

### Timeline

Timeline은 전체 VFX의 시간축이고 Component는 Timeline Parameter를 읽는다.

최소 Timeline 데이터:

- duration
- loop
- playback
- tracks

Track은 처음부터 범용 Curve Editor까지 만들지 않고 최소한:

- visibility
- opacity
- scale
- rotation
- position offset
- parameter

정도로 시작한다.

각 Track은 시간에 따른 Key를 가진다.

예:

`t=0.0 → scale=0.5`

`t=0.15 → scale=1.0`

`t=0.40 → opacity=0.0`

### Component와 Gameplay의 경계

Component/Timeline은 시각 Parameter만 변경한다.

예:
- alpha
- scale
- rotation
- color
- width
- length
- sprite frame

다음은 Timeline Component가 직접 변경하지 않는다.

- damage
- HP
- target HP
- cooldown
- gameplay state

### PROPOSAL

초기 VFX Definition 구조를 다음처럼 제한한다.

`VFX Definition`
- identity
- transform
- timeline
- components
- parameters
- trigger metadata
- runtime policy
- authoring metadata

`Component`
- type
- resource reference
- local transform
- render parameters
- timeline bindings

복잡한 particle simulation, shader graph, procedural expression은 Extension으로 분리한다.

### UNVERIFIED

- 최종 Key interpolation 방식
- Sprite Frame Track의 정확한 데이터 형식
- Beam/Trail의 길이 계산 방식
- Particle/Shader Extension API

### OUT OF SCOPE

- Timeline Editor 구현
- VFX Renderer 구현
- Sprite/Particle/Shader Adapter 구현

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Variant / Override 모델 조사

### CONFIRMED

현재 Runtime Effect는 Source/Weapon/Enemy Type에 따라 시각 Parameter를 분기한다.

대표적으로 Projectile은 weapon 또는 enemy 계열에 따라 색상과 표현이 달라지고, Impact/Area/Pierce도 Effect Type과 Source에 따라 시각 Parameter가 달라진다.

이는 동일한 VFX 구조를 재사용하면서 일부 Parameter만 변경하는 Variant 요구와 일치한다.

### 마리의 판정

VFX Definition과 Variant/Override를 분리한다.

**VFX Definition**
- 공통 구조
- Component
- Timeline
- 기본 Parameter
- Runtime Policy

**Variant**
- 같은 Definition을 다른 시각 설정으로 재사용
- 색상
- 크기
- 속도
- 길이
- Sprite/Resource 선택
- 일부 Timeline Parameter

**Instance Override**
- 특정 Runtime 호출에서만 일시적으로 변경
- Definition 자체를 변경하지 않음

우선순위는:

`Definition Default → Variant → Binding Override → Runtime Instance Override`

로 고정한다.

### 변경 제한

Override는 허용된 Parameter만 변경할 수 있어야 한다.

예를 들어:

- color: 허용
- scale: 허용
- speed: 허용
- trail_length: 허용
- component 구조 변경: 금지
- Timeline 구조 변경: 금지
- Gameplay damage: 금지
- Gameplay target: 금지

이를 통해 Binding Catalog가 VFX Definition을 복제하지 않고도 Robot/Tower/Enemy/Skill별 차이를 표현할 수 있다.

### Binding과의 관계

VFX Binding Catalog는:

`Trigger Context → VFX ID + Variant + Overrides`

를 결정한다.

따라서 MENOS Integration은 Generic VFX Definition을 수정하지 않는다.

예:

`weapon_fired + robot + asura → vfx.projectile + variant=asura`

`weapon_fired + tower → vfx.projectile + variant=tower`

### PROPOSAL

초기 Variant는 별도 거대한 상속 시스템으로 만들지 않는다.

**Variant = Definition에 대한 제한된 Parameter Set**

으로 정의한다.

Variant 간 상속은 초기 범위에서 제외한다.

또한 Runtime Override는 임의 Dictionary를 허용하지 않고 Definition이 선언한 Exposed Parameter만 허용한다.

### UNVERIFIED

- 현재 Content Catalog의 Variant 상속 사용 여부
- 최종 Parameter Type/Validation Schema
- Runtime Override 전달 방식

### OUT OF SCOPE

- Variant Editor 구현
- Override Runtime 구현
- 기존 Effect Color/Scale Migration

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Lifecycle / Concurrency / Interrupt 모델 조사

### CONFIRMED

현재 Runtime VFX는 단순 Array Lifecycle을 사용한다.

Create → Update → Render → Filter/Delete

Projectile은 도착 시 종료되고, 일반 Effect는 lifetime이 0이 되면 제거된다. Stage Reset 시에는 전체 Effect가 Clear된다.

현재 동일 Type Effect의 동시 실행을 제한하는 별도 Concurrency 정책은 확인되지 않았다.

### 마리의 판정

Generic VFX Core에는 다음 Lifecycle 상태가 필요하다.

- Created
- Playing
- Completed
- Cancelled
- Interrupted

정상 종료는 Completed이고 외부 종료는 Cancelled / Interrupted로 구분한다.

### Concurrency

동일 VFX가 여러 Actor에서 동시에 발생할 수 있으므로 기본값은:

Allow Multiple

로 한다.

필요한 VFX만 Policy를 선언한다.

- Allow Multiple
- Replace Existing
- Ignore New
- Restart Existing

Concurrency Key는 VFX ID 자체가 아니라 필요할 경우:

VFX ID + Context/Owner

로 계산할 수 있게 한다.

예:
- Actor별 Aura → Actor ID 기준
- Global Screen Flash → VFX ID 기준

### Interrupt

Interrupt는 Gameplay 상태를 변경하지 않는다.

VFX Instance의 시각적 Lifecycle만 종료/전환한다.

예:

shield_loop → shield_break

에서 기존 Shield VFX는 Interrupted되고 Break VFX가 새 Instance로 시작한다.

### Parent 종료

Attached VFX는 Parent가 제거될 때 Definition의 Follow Policy를 따른다.

- Cancel with Parent
- Detach and Continue

Follow Parent는 Parent가 살아있는 동안의 일반 동작이며 종료 정책으로 취급하지 않는다.

### Priority

Concurrency와 Priority는 별개다.

Priority는 화면/성능상 어떤 VFX를 유지할지 결정하기 위한 Runtime Policy다.

초기 Priority는 단순 정수/등급으로 충분하며 복잡한 Scheduler는 초기 범위에서 제외한다.

### PROPOSAL

VFX Definition Runtime Policy:

concurrency + interrupt + priority + parent_end_policy

를 최소 정책으로 둔다.

VFX Core는 Gameplay를 중단시키지 않는다.

Gameplay가 VFX를 Trigger할 수 있지만 VFX 종료가 Gameplay Action의 성공/실패를 결정하지 않는다.

### UNVERIFIED

- 실제 Production에서 필요한 동시 VFX 상한
- Pooling 정책
- Priority 충돌 시 최종 eviction 규칙
- VFX 간 직접적인 Parent/Child 관계의 범위

### OUT OF SCOPE

- VFX Pool 구현
- Scheduler 구현
- Runtime Adapter 변경
- 기존 Effect Lifecycle Migration

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Performance / Pooling / LOD 정책 조사

### CONFIRMED

현재 Runtime은 매 Process마다 전체 Effect Array를 순회하고, 종료된 Effect를 Filter로 제거한다.

Rendering은 Effect가 존재할 때마다 GameController의 draw 경로에서 수행된다.

현재 VFX 전용 Pooling, LOD, Visibility Culling 정책은 확인되지 않았다.

### 마리의 판정

Generic VFX Core에서 성능 정책을 Authoring Metadata로 선언할 수 있어야 한다.

최소 항목:

- priority
- pooling
- culling
- lod
- max_instances

다만 초기 Core Runtime에서 모든 정책을 즉시 구현할 필요는 없다.

### Pooling

Pooling은 VFX Definition이 선택적으로 요청한다.

- None
- Optional
- Required

초기 Runtime은 None/Optional부터 지원하고, 반복 생성량이 높은 Projectile/Impact부터 Pooling 대상으로 확장한다.

Pooling은 VFX 시각 상태를 재사용할 뿐 Gameplay State를 재사용하지 않는다.

### LOD

VFX LOD는 Gameplay 결과를 변경하지 않는다.

예:

- Full: Sprite + Trail + Secondary
- Reduced: Sprite + Trail
- Minimal: Shape only
- Hidden: Rendering disabled

Hidden 상태에서도 Gameplay Event는 영향을 받지 않는다.

### Culling

World VFX는 Camera 밖에서 Rendering을 생략할 수 있다.

단, Gameplay를 담당하는 System과 VFX Renderer를 분리하므로 Culling은 VFX Instance의 시각 처리만 중단한다.

### Max Instances

Global VFX 상한 하나만 두기보다 Definition별 Max Instances를 우선한다.

동일 VFX가 너무 많이 발생할 경우 Concurrency Policy와 결합한다.

### PROPOSAL

초기 Performance Policy:

`priority + pooling + culling + lod + max_instances`

로 정의한다.

Runtime 구현 순서는:

1. Lifecycle/Concurrency
2. Culling
3. Max Instances
4. Pooling
5. LOD

로 두는 것이 안전하다.

Pooling과 LOD는 초기 Generic VFX Editor의 필수 Authoring UI가 아니라 Runtime Policy의 선택 항목으로 둔다.

### UNVERIFIED

- 실제 MENOS 전투에서 필요한 최대 동시 VFX 수
- 모바일/저사양 플랫폼 요구사항
- Godot CanvasItem 기반 VFX의 실제 병목
- Particle/Shader VFX의 별도 성능 정책

### OUT OF SCOPE

- Pool 구현
- LOD Renderer 구현
- Culling 시스템 구현
- Performance Benchmark

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Editor UI 요구사항 조사

### CONFIRMED

현재 Content Editor는 기능별 Editor Scene을 분리하고 있으며 Skill Editor는 목록 + 필드 편집 + SQLite 저장 구조를 사용한다.

현재 Asset Catalog Editor는 Visual Resource의 식별자, Source, Frame, Grid, Anchor 등의 Authoring Metadata를 관리한다.

따라서 VFX Editor는 기존 Editor 패턴을 재사용하되 VFX 고유 Authoring 영역을 별도로 가져가는 것이 적절하다.

### 마리의 판정

VFX Editor의 P0 화면은 다음 6개 영역이면 충분하다.

1. VFX List
   - 검색
   - Category
   - Status
   - VFX ID

2. Definition
   - VFX ID
   - Name
   - Category
   - Revision
   - Status
   - Description

3. Components
   - Component 목록
   - Component Type
   - Visual Resource Reference
   - Local Transform
   - Exposed Parameters

4. Timeline
   - Duration
   - Loop
   - Playback
   - Track 목록
   - Key/Marker

5. Transform / Runtime Policy
   - Space
   - Anchor
   - Offset
   - Direction
   - Parent/Attachment
   - Concurrency
   - Priority
   - Culling
   - Max Instances

6. Preview / Validation
   - Preview
   - Trigger Simulation
   - Variant 선택
   - Parameter Override
   - Validation 결과
   - Production readiness

### Asset Prompt 연계

VFX Editor가 Prompt 본문을 복제해 저장하지 않는다.

Visual Resource를 선택하면:

Visual Asset → <image>.prompt.md → Authoring Status

를 조회할 수 있어야 한다.

Prompt가 없는 Resource는 VFX 자체를 자동으로 Invalid 처리하기보다 Prompt Traceability를 UNVERIFIED로 표시한다.

Production-ready 판정에서는 필요한 경우 이를 Validation Error로 승격한다.

### Binding 편집

VFX Editor가 Gameplay Binding을 직접 소유하지 않는다.

Binding은 별도의 VFX Binding Editor/관리 영역으로 분리한다.

VFX Editor에서는 현재 VFX가 어떤 Trigger/Binding에서 사용되는지 Reference/Dependency View 정도만 제공한다.

### PROPOSAL

초기 VFX Editor는 모든 기능을 한 화면에 넣지 않고:

List | Definition | Components | Timeline | Preview/Validation

을 기본 구조로 한다.

Runtime Policy와 Transform은 Definition/Inspector 영역에서 관리한다.

복잡한 Timeline Curve Editor, Particle Editor, Shader Graph Editor는 P0에서 제외한다.

### UNVERIFIED

- 최종 VFX Editor Scene layout
- Timeline UI의 정확한 interaction model
- Preview Renderer의 실제 구현 방식
- Binding Editor를 별도 Scene으로 만들지 여부

### OUT OF SCOPE

- VFX Editor Scene 구현
- VFX Repository/SQLite Schema 구현
- Timeline Runtime 구현
- Preview Renderer 구현

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Production Validation 기준 조사

### CONFIRMED

현재 MENOS에는 공통 Content Validation Runner와 Content Validator가 존재하며 SQLite Catalog의 구조 및 Reference를 검증하는 패턴을 사용한다.

따라서 VFX도 별도 임시 검증 방식보다 기존 Content Validation 체계에 통합하는 것이 적절하다.

### 마리의 판정

VFX Production-ready Validation은 다음 순서로 최소 검증한다.

1. Identity
   - VFX ID 존재
   - ID 중복 없음
   - Revision 존재
   - Status 확인

2. Component
   - Component Type 유효
   - Resource Reference 유효
   - 필수 Parameter 존재
   - Component 구조 손상 없음

3. Visual Resource
   - Asset Reference 존재
   - Source Resource 존재
   - Prompt Sidecar Reference 확인
   - Prompt Status가 필요한 Production 기준을 충족하는지 확인

4. Timeline
   - Duration 유효
   - Track 대상 Component/Parameter 유효
   - Key 시간 범위 유효
   - Loop/Playback 값 유효

5. Transform
   - Space 유효
   - Anchor/Offset 값 유효
   - Attached인 경우 Parent 정책 유효

6. Variant / Override
   - Variant가 존재하는 Definition을 참조
   - Override Parameter가 Exposed Parameter인지 확인
   - 잘못된 Parameter Override 거부

7. Runtime Policy
   - Concurrency 값 유효
   - Priority 유효
   - Max Instances 유효
   - Pooling/LOD/Culling 값 유효

8. Binding / Dependency
   - Binding이 존재하는 경우 VFX ID 유효
   - Variant 유효
   - 순환 Dependency 금지
   - 사용되지 않는 Resource는 Warning

### Error / Warning

**ERROR**
Production 실행 또는 Authoring 구조를 깨뜨리는 문제.

예:
- 없는 VFX ID
- 없는 Visual Resource
- 손상된 Component
- 잘못된 Timeline Reference
- 허용되지 않은 Override

**WARNING**
실행은 가능하지만 Production 추적성 또는 품질에 문제가 있는 경우.

예:
- Prompt Sidecar UNVERIFIED
- 사용되지 않는 VFX
- 사용되지 않는 Visual Resource
- Preview 미검증
- Dependency 정보 부족

### Production Ready

Production-ready는 단순히 Definition이 저장되었다는 의미가 아니다.

최소 조건:

Identity + Component + Resource + Timeline + Transform + Validation

이 모두 유효해야 한다.

Prompt Traceability가 필수인 Resource의 경우 Prompt 상태도 Production 기준에 포함한다.

### PROPOSAL

기존 Content Validator에 VFX 전용 검증을 추가하고, VFX Editor의 Validation 결과는 동일 Validator 결과를 표시한다.

Editor Preview 성공과 Production Validation PASS는 서로 다른 상태로 유지한다.

### UNVERIFIED

- 현재 Validator의 최종 VFX 통합 위치
- VFX Binding Validator의 범위
- Prompt Sidecar를 Validator가 직접 읽을 최종 방식

### OUT OF SCOPE

- Validator 코드 구현
- VFX SQLite Schema 구현
- Production Lock 구현

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Definition Schema / Version / Migration 조사

### CONFIRMED

현재 MENOS Content는 SQLite의 `raw_json`을 중심으로 저장하며 Loader가 Dictionary를 읽는 구조이다.

일부 기존 데이터에는 `version` 필드가 존재하지만, 현재 Generic VFX 전용 Schema Version/Migration 계층은 없다.

따라서 VFX Definition을 처음 설계할 때 Schema Version을 명시하는 것이 안전하다.

### 마리의 판정

VFX Definition에는 Runtime Revision과 별도로 **Schema Version**을 둔다.

구분:

- Schema Version: 데이터 구조 호환성
- Definition Revision: 동일 Schema 안에서 Authoring 변경 이력

예:

`schema_version = 1`
`revision = 7`

Revision 증가가 Schema Migration을 의미하지 않는다.

### 초기 Schema 원칙

P0에서는 단순 정수 Schema Version을 사용한다.

예:

`vfx_schema_version = 1`

Loader는:

1. Version 확인
2. 지원 Version인지 확인
3. 필요하면 Migration
4. Canonical Runtime Definition으로 Normalize
5. Runtime에 전달

순서로 동작한다.

### Migration 원칙

Migration은 저장 데이터 자체를 임의로 수정하지 않고 읽기 시 Canonical Definition으로 변환하는 방식을 우선한다.

예:

`Schema v1 → Loader Migration → Canonical Runtime Definition`

Migration 실패 시 Runtime에서 추측하여 실행하지 않고 Validation/Load Error로 처리한다.

### Backward Compatibility

새 필드를 추가하는 경우 기본값을 정의할 수 있다.

기존 필드를 의미가 달라지도록 변경하는 경우에는 단순 기본값 처리 대신 Schema Version을 증가시킨다.

필드 이름 변경, 구조 변경, Component 타입 변경처럼 의미가 바뀌는 변경은 Migration 대상이다.

### Generic VFX Core와 MENOS Integration 분리

VFX Schema에는 MENOS Gameplay 규칙을 넣지 않는다.

따라서 다음은 Generic VFX Schema 밖에 둔다.

- Robot/Skill/Tower/Enemy ID
- Damage
- HP
- Cooldown
- Gameplay Target
- MENOS-specific Event Rule

이들은 VFX Binding/Integration 계층에서 연결한다.

### PROPOSAL

초기 구조:

`VFX Definition Catalog → Schema Version → Loader Migration → Canonical VFX Definition → Runtime Adapter`

Git은 Definition Revision의 변경 이력을 보조하며, Schema Migration 자체를 Git History에 의존하지 않는다.

### UNVERIFIED

- 최종 Schema Version 필드명
- Migration 코드 위치
- SQLite Catalog 단위 Version과 Definition 단위 Version의 최종 관계
- 향후 Component Schema를 별도 Version으로 분리할 필요성

### OUT OF SCOPE

- VFX Schema 구현
- Migration 코드 구현
- SQLite Schema 변경
- 기존 Content Migration

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Dependency / Usage Tracking 조사

### CONFIRMED

현재 MENOS는 Content를 기능별 Catalog로 분리하고 Reference를 통해 연결한다.

확인된 주요 관계:

- Skill → Skill Definition
- Robot → Robot Definition / Animation Reference
- Tower → Tower Definition / Projectile Visual Reference
- Visual Resource → Visual Asset Catalog
- Gameplay Event → Runtime 처리

현재 VFX 전용 Usage/Dependency Graph는 확인되지 않았다.

### 마리의 판정

Generic VFX 시스템은 VFX 자체의 Definition과 이를 사용하는 Integration을 분리하되, Editor에서는 전체 사용 관계를 조회할 수 있어야 한다.

최소 Dependency Graph:

Visual Resource
→ VFX Definition
→ VFX Variant
→ VFX Binding
→ Gameplay Context

예:

impact_explosion.png → vfx.impact.default → variant.giant → projectile_hit + giant

### Usage View

VFX Editor에서 선택한 VFX에 대해 다음을 조회할 수 있어야 한다.

- Used By Binding
- Used By Skill
- Used By Robot
- Used By Tower
- Used By Enemy
- Referenced Visual Resources
- Referenced Variants
- Referenced Child VFX

직접 참조뿐 아니라 Binding을 통한 간접 사용도 표시한다.

### 변경 영향 분석

VFX Definition을 수정하거나 삭제할 때 영향 범위를 먼저 계산한다.

예:

VFX Definition → Binding 3개 → Skill 2개 / Robot 1개

이 경우 Editor는 변경 영향 범위를 표시하고 Production 상태에서는 삭제를 바로 허용하지 않는 방향이 적절하다.

### 삭제 정책

사용 중인 VFX는 일반 Delete를 허용하지 않는다.

권장 상태:

- Unused → Delete 가능
- Used → Delete Blocked
- Legacy → Deprecate 가능
- Deprecated + Unused → Delete 후보

Visual Resource도 동일한 원칙을 적용한다.

### Orphan Detection

다음은 Warning 대상으로 탐지한다.

- VFX Definition이 존재하지만 Binding이 없음
- Visual Resource가 존재하지만 어떤 VFX도 참조하지 않음
- Variant가 존재하지만 사용되지 않음
- Binding이 존재하지만 실제 Gameplay Context와 연결되지 않음

단, unused 자체가 항상 오류는 아니다.

Authoring 중인 Resource일 수 있으므로 Warning으로 분류한다.

### Circular Dependency

VFX Child/Composition이 허용될 경우 순환 참조를 금지한다.

예:

A → B → C → A

는 Production Validation ERROR다.

### PROPOSAL

VFX 시스템에는 별도 Graph DB를 만들지 않는다.

기존 Catalog Reference를 기반으로 Validator가 Dependency Graph를 계산한다.

구조:

Catalog References → Dependency Resolver → Usage Graph → Validation / Impact Analysis

이 방식이 현재 MENOS Content 구조와 가장 잘 맞는다.

### UNVERIFIED

- Child VFX Composition의 최종 허용 깊이
- Binding의 실제 역참조 계산 방식
- Editor에서 Graph를 시각화할 필요성

### OUT OF SCOPE

- Dependency Graph Runtime 구현
- Graph UI 구현
- Delete Guard 구현
- 기존 Asset/VFX 변경

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Preview / Debug 요구사항 조사

### CONFIRMED

현재 Runtime은 VFX에 필요한 핵심 상태를 이미 보유한다.

- Position
- Start / Target
- Direction
- Progress
- Lifetime
- Scale
- Source / Weapon / Effect Type

따라서 Preview 시스템은 실제 Runtime 개념과 동일한 상태를 입력으로 사용하는 것이 적절하다.

### 마리의 판정

VFX Editor Preview는 단순 이미지 미리보기가 아니라 **Definition Runtime Preview**여야 한다.

P0 Preview 입력:

- VFX Definition
- Variant
- Parameter Override
- Start Position
- Target Position
- Direction
- Preview Duration
- Playback Speed

Preview Control:

- Play
- Pause
- Stop
- Restart
- Timeline Scrub
- Loop
- Playback Speed

### Debug Overlay

Debug Mode에서는 다음을 선택적으로 표시한다.

- VFX Instance Bounds
- Anchor / Pivot
- Start / Target
- Direction
- Parent Attachment
- Current Time
- Progress
- Active Components
- Active Variant
- Parameter Values
- Lifecycle State
- Concurrency Key

이 정보는 Authoring/Debug 용이며 Production Runtime UI에는 표시하지 않는다.

### Event Simulation

VFX Trigger가 정의된 경우 Preview에서 Gameplay를 실제 실행하지 않고 Trigger Context만 시뮬레이션한다.

예:

Trigger:
projectile_hit

Context:
source_type=robot
source_id=asura

→ Binding Resolver
→ VFX ID
→ Variant
→ VFX Preview

Damage/HP/Cooldown 등의 Gameplay는 실행하지 않는다.

### Compare

동일 VFX의 Variant 또는 Revision을 비교할 수 있는 Preview 구조를 향후 지원한다.

P0에서는 단일 Preview를 우선하고 Compare는 P1로 둔다.

### Fail-safe

Preview Renderer가 지원하지 않는 Component를 발견하면 해당 Component를 조용히 생략하지 않는다.

Preview 상태에:

UNSUPPORTED COMPONENT

를 표시하고 Validation에서도 확인할 수 있어야 한다.

### PROPOSAL

Preview는 가능한 한 Runtime Adapter와 동일한 VFX Definition 해석 경로를 사용한다.

구조:

VFX Definition
→ Preview Instance
→ Runtime Adapter / Preview Renderer

Preview 전용 별도 Definition 해석 규칙은 만들지 않는다.

### UNVERIFIED

- Preview Renderer와 Runtime Renderer의 실제 코드 공유 범위
- Timeline Scrub의 정확한 구현 방식
- Camera/Screen-space VFX Preview
- Particle/Shader Component Preview

### OUT OF SCOPE

- Preview Renderer 구현
- Debug Overlay 구현
- Compare UI 구현
- Runtime Renderer 변경

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Editor 구현 경계 / 단계화 판정

### CONFIRMED

현재 조사에서 Generic VFX Core, VFX Definition Catalog, VFX Binding Catalog, VFX Editor, Runtime Adapter는 설계 대상으로 정의되었지만 실제 구현은 확인되지 않았다.

현재 Runtime의 Procedural Effect는 별도 Generic VFX 계층 없이 GameController에 직접 존재한다.

### 마리의 판정

지금 단계에서 기존 Runtime을 바로 Generic VFX 구조로 교체하는 것은 범위를 과도하게 확장한다.

구현은 다음 단계로 분리해야 한다.

#### P0 — Authoring Foundation

- VFX Definition Schema
- VFX Definition Loader/Repository
- 기본 VFX Catalog
- VFX Editor List/Definition
- Visual Resource Reference
- Revision/Status
- Validation 기초
- Prompt Sidecar Traceability

#### P1 — Visual Composition

- Component
- Transform
- Timeline
- Basic Parameters
- Variant
- Preview

#### P2 — MENOS Integration

- VFX Binding Catalog
- Trigger Resolver
- Skill/Robot/Tower/Enemy Integration
- Runtime Adapter
- 기존 Procedural Projectile/Impact VFX 연결

#### P3 — Runtime Optimization / Extensions

- Pooling
- Culling
- LOD
- Advanced Particle
- Shader
- Complex Trail/Beam
- Compare/Advanced Debug

### 기존 Runtime 보호 원칙

P0/P1 구현 중에는 현재 Campaign 1 Runtime의 Procedural VFX를 변경하지 않는다.

Generic VFX Core가 최소 기능으로 동작하고 Validation이 통과한 뒤 Adapter를 추가한다.

그 다음 한 종류의 기존 VFX를 Pilot Migration 대상으로 선정하여 검증한다.

Pilot 성공이 전체 VFX Migration 승인을 의미하지 않는다.

### 성공 조건

P0 성공:

- VFX Definition을 저장/로드할 수 있음
- Schema Version과 Revision을 유지
- Visual Resource Reference 가능
- Validation 가능
- Prompt Traceability 확인 가능

P1 성공:

- Component + Timeline을 편집
- Preview 가능
- Variant/Override 가능

P2 성공:

- Trigger Context에서 VFX를 Resolve
- Runtime Adapter를 통해 실제 VFX Instance 생성
- 기존 Gameplay 결과와 시각 효과를 분리

### PROPOSAL

첫 Runtime Pilot은 현재 구조가 단순하고 판별력이 높은 **Projectile VFX**가 적절하다.

단, Master가 Pilot 범위를 승인하기 전에는 기존 Runtime을 변경하지 않는다.

### UNVERIFIED

- 실제 구현 순서와 담당 작업량
- 최종 SQLite Schema
- Generic VFX Core의 실제 Godot Node 구조
- Projectile Pilot의 최종 선정

### OUT OF SCOPE

- 구현 착수
- 기존 Runtime VFX 변경
- Asset 변환
- Commit / Push

### 상태

**PROPOSAL / PLANNING**


## VFX P0 구현 착수 전 최소 결정사항

### CONFIRMED

현재 VFX 조사에서 다음 설계 축은 충분히 정리되었다.

- Generic VFX Definition
- Visual Resource Reference
- Schema Version / Revision
- Component / Timeline
- Transform / Attachment
- Variant / Override
- Runtime Policy
- Validation
- Preview
- Dependency / Usage
- MENOS Binding 분리

반면 실제 구현을 시작하기 위해서는 저장 Schema와 최소 Runtime Definition의 구체적인 형태가 필요하다.

### 마리의 판정

P0 구현 전에 다음 5개만 결정하면 된다.

1. VFX Definition의 최소 필드
2. Catalog 저장 단위
3. Visual Resource Reference 형식
4. Status / Revision 정책
5. Validation 결과 형식

나머지 Particle, Shader, Pooling, LOD, Binding Resolver, Runtime Migration은 P0 이후로 미룬다.

### P0 최소 Definition

Identity:

- id
- name
- category
- schema_version
- revision
- status

Authoring:

- description
- components
- timeline
- transform
- parameters

Resource:

- visual_resource_refs

Runtime Policy:

- priority
- concurrency
- max_instances

Validation/Metadata:

- authoring_status
- production_status

### Catalog

기존 MENOS Content 패턴을 따라 VFX Definition도 하나의 Catalog Document로 시작하는 것이 적절하다.

예:

vfx_definitions

단, 실제 SQLite Table/Document 명칭은 구현 전에 현재 ObjectPersistence/ContentCatalogLoader 패턴과 대조하여 확정한다.

### Visual Resource Reference

VFX Definition에는 이미지 경로나 Prompt 본문을 직접 저장하지 않는다.

Resource ID를 참조한다.

구조:

VFX Definition → Visual Resource ID → Visual Asset Catalog → Source Image

Prompt 추적은:

Source Image → <image>.prompt.md

로 유지한다.

### Status

Authoring Status와 Production Status를 분리한다.

예:

- Draft
- Review
- Validated
- Production
- Deprecated

Production 승격은 Validation PASS가 선행되어야 한다.

### PROPOSAL

P0 구현은 위 최소 Definition만으로 시작하고, 실제 Runtime Renderer는 포함하지 않는다.

먼저 저장/로드/편집/검증을 확립한 후 P1 Component/Timeline Preview로 진행한다.

### UNVERIFIED

- 최종 SQLite 저장 형식
- category enum
- status enum
- Validation 결과 저장 여부
- production_status와 기존 Content Status의 통합 가능성

### OUT OF SCOPE

- P0 코드 구현
- SQLite Schema 변경
- VFX Editor Scene 생성
- Runtime Adapter 구현

### 상태

**PROPOSAL / PLANNING**


## VFX P0 Status / Revision / Validation 정책 대조

### CONFIRMED

현재 MENOS Content는 Catalog 저장과 Validator를 별도 책임으로 사용하는 구조가 존재한다.

VFX에는 아직 전용 Status/Revision/Validation 모델이 구현되어 있지 않다.

### 마리의 판정

VFX P0에서는 기존 Content 구조와 충돌하지 않는 최소 정책을 사용한다.

Status는 단일 Production Lifecycle로 관리한다.

- Draft — 작성 중
- Review — 검토 대기
- Validated — Validation PASS
- Production — Production 승인 상태
- Deprecated — 신규 사용 금지

Production은 단순 저장 상태가 아니라 Validation PASS를 전제로 한다.

Revision은 Authoring 변경 횟수이며 Schema Version과 분리한다.

- schema_version = Definition 구조 호환성
- revision = 해당 VFX의 Authoring 변경 이력

예:

schema_version=1
revision=3

### Validation 결과

Validation 결과 자체를 VFX Definition에 영구 저장하는 것은 P0에서 요구하지 않는다.

Validator가 현재 Definition을 검사하고 결과를 즉시 반환한다.

따라서:

Definition → Validator → Errors / Warnings / PASS

구조로 시작한다.

저장되는 것은 Definition의 status/revision이고, 일시적인 Validation 결과는 실행 결과로 취급한다.

### Production 승격 규칙

다음 조건을 만족해야 Production 후보가 된다.

- ID 유효
- Schema Version 지원
- Component 구조 유효
- Visual Resource Reference 유효
- Timeline 구조 유효
- Transform 구조 유효
- 필수 Parameter 유효
- 참조 대상 존재
- Validation Error = 0

Prompt Sidecar가 없는 경우는 Canon에 따라 Traceability 상태를 별도로 표시한다.

초기 P0에서는 이를 즉시 VFX 실행 오류로 취급하지 않고 UNVERIFIED 경고로 분류할 수 있다. Production 정책 강화 시 Error로 승격 가능하다.

### Revision 변경 규칙

다음 Authoring 변경은 Revision 증가 대상이다.

- Component 추가/삭제/변경
- Timeline 변경
- Visual Resource 변경
- Transform 변경
- Parameter 기본값 변경
- Runtime Policy 변경
- Description/Authoring Metadata의 Production 의미 변경

단순 Preview 실행은 Revision을 변경하지 않는다.

Validation 실행도 Revision을 변경하지 않는다.

### PROPOSAL

P0에서는 Git History를 별도 Revision DB로 만들지 않는다.

Definition의 revision은 Authoring 상태를 명시하고, 실제 상세 변경 이력은 Git History를 사용한다.

### UNVERIFIED

- 기존 Content Editor의 Status 관례와 정확한 통합 가능성
- Production 승인 권한을 Editor에서 제한할지 여부
- Prompt UNVERIFIED의 Production 승격 정책 최종 결정

### OUT OF SCOPE

- Status/Revision 코드 구현
- Validator 코드 변경
- Production Lock 구현
- SQLite Schema 변경

### 상태

**CONFIRMED / PROPOSAL / PLANNING**


## VFX Fail-safe / Missing Resource 정책 조사

### CONFIRMED

현재 Runtime은 Effect Dictionary와 직접 Renderer 분기를 사용하므로 정의 또는 Resource가 없는 경우를 Generic VFX 계층에서 처리하는 별도 Fail-safe가 확인되지 않는다.

### 마리의 판정

Generic VFX Runtime은 Gameplay를 중단시키지 않는 것을 최우선 Fail-safe 원칙으로 한다.

VFX Definition Load 실패:
- VFX Instance 생성하지 않음
- Gameplay Event는 계속 처리
- Validation/Error Log 기록
- Editor에서는 명확한 Error 표시

Visual Resource Load 실패:
- 해당 Component만 비활성화
- 다른 Component는 가능한 경우 계속 재생
- Runtime 전체를 중단하지 않음
- Missing Resource 상태를 Debug/Validation에 표시

VFX Definition 자체가 없거나 손상된 경우에는 임의의 VFX를 선택하지 않는다.

Missing VFX는 다른 VFX로 자동 대체하지 않는다.

### Fallback

Fallback은 Generic Core가 임의로 결정하지 않고 Binding/Integration 계층에서 명시한다.

Trigger → Specific VFX
Specific VFX unavailable → Explicit Fallback VFX
Fallback unavailable → No VFX
Gameplay → 계속 진행

### Editor 정책

Editor Preview에서 Resource가 없으면:
- Missing Resource 표시
- 해당 Component 식별
- Validation Error

Preview 자체는 가능한 다른 Component를 계속 보여줄 수 있다.

### Production Validation

다음은 Error로 취급한다.

- VFX Definition ID 없음
- 필수 Component 없음
- 필수 Resource Reference 없음
- 참조 Resource가 존재하지 않음
- 지원하지 않는 필수 Schema Version
- 순환 Child VFX Dependency

다음은 Warning 후보이다.

- Optional Resource 누락
- Prompt Traceability UNVERIFIED
- Unused VFX
- Preview Renderer 미지원 Optional Component

### PROPOSAL

Fail-safe의 핵심은 Visual Failure must not become Gameplay Failure로 정의한다.

VFX는 Gameplay 결과를 결정하지 않는다.

Gameplay가 VFX의 성공을 요구하는 구조는 만들지 않는다.

### UNVERIFIED

- 실제 Runtime Adapter의 Error Reporting 방식
- Godot Resource Load 실패 시 세부 처리
- 로그 수준 및 Production Logging 정책
- 명시적 Fallback VFX Catalog의 최종 위치

### OUT OF SCOPE

- Runtime Fail-safe 구현
- Fallback Catalog 구현
- Error Logger 변경
- 기존 VFX Migration

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Determinism / Randomness 정책 조사

### CONFIRMED

현재 Runtime의 Projectile/Impact VFX는 Progress, Start/Target, Lifetime, Scale 등의 명시적 상태를 기반으로 렌더링한다.

Generic VFX 설계에서는 아직 Random Seed와 Deterministic Playback 정책이 구현되어 있지 않다.

### 마리의 판정

VFX Randomness는 Gameplay Randomness와 분리한다.

VFX의 Random 값은 다음 범위에서만 사용한다.

- Visual variation
- Rotation variation
- Scale variation
- Spawn offset variation
- Sprite/Variant selection
- Particle/Trail visual variation

VFX Randomness가 Damage, Hit, Target, Cooldown 등의 Gameplay 결과를 결정해서는 안 된다.

### Seed

동일 VFX를 동일 Context에서 재현할 필요가 있는 경우 Seed를 사용할 수 있어야 한다.

권장 구조:

VFX Definition
→ Seed Policy
→ VFX Instance Seed
→ Visual Random Stream

Seed Policy:

- None
- Explicit Seed
- Context Derived Seed

Context Derived Seed는 Gameplay 결과를 변경하지 않고 VFX 재현성만 확보한다.

### Preview

Editor Preview는 기본적으로 Deterministic Preview를 지원하는 것이 적절하다.

동일:

Definition + Variant + Parameters + Seed

이면 가능한 한 동일한 Visual Result를 재현한다.

Random Preview는 별도 옵션으로 제공할 수 있다.

### Network / Replay 경계

VFX는 Gameplay Simulation의 결정론을 책임지지 않는다.

Replay/Network에서 필요한 것은 Gameplay Event와 그 Context이며, VFX는 해당 Event에서 재생된다.

동일한 VFX Seed가 필요하면 Event Context 또는 Binding 단계에서 전달한다.

### PROPOSAL

P0에서는 복잡한 Random System을 구현하지 않는다.

Definition에 Random을 위한 확장 가능성만 남기고, P1/P2에서 실제 Seed/Random Stream을 추가한다.

초기 원칙:

Gameplay RNG ≠ VFX RNG

### UNVERIFIED

- 향후 Replay 기능의 정확한 요구사항
- Multiplayer/Network Runtime 계획
- Godot RandomNumberGenerator 사용 여부
- Particle/Shader의 Deterministic 재현 가능 범위

### OUT OF SCOPE

- Random System 구현
- Replay 구현
- Network 동기화
- Particle/Shader Random 구현

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Import / Package / Export 경계 조사

### CONFIRMED

현재 MENOS Asset/Content 구조는 Runtime Resource와 Catalog Definition을 분리하며, SQLite Catalog가 Content Authority이다.

Prompt는 별도 Sidecar 파일로 관리하도록 Canon이 정해져 있다.

Generic VFX 설계에는 아직 Import/Package/Export 전용 구조가 없다.

### 마리의 판정

VFX Authoring Pipeline은 다음 세 층으로 분리한다.

Source:

- Image
- Prompt Sidecar
- Reference
- External Authoring Source

Authoring:

- Visual Asset
- VFX Definition
- Variant
- Binding
- Validation Metadata

Runtime:

- Imported/Normalized Resource
- Runtime Definition
- Runtime Instance

Import와 Authoring은 동일한 책임으로 취급하지 않는다.

### Import

Import는 Source를 프로젝트가 사용할 수 있는 Visual Resource로 등록/정규화하는 단계이다.

Import 과정에서 원본 Source를 임의로 덮어쓰지 않는다.

가능한 경우:

Source
→ Import/Normalize
→ Visual Asset
→ VFX Definition Reference

Prompt Sidecar는 Source와 함께 보존하며 Asset ID와 연결한다.

### Package

VFX Package는 Runtime 실행에 필요한 참조를 묶는 개념으로 정의한다.

최소 구성 후보:

- VFX Definition
- Referenced Visual Assets
- Variants
- Required Runtime Resources
- Schema Version

Prompt Source는 Authoring Package에 포함할 수 있지만 Runtime Package에 반드시 포함할 필요는 없다.

Prompt는 Runtime 실행 데이터가 아니라 Authoring Metadata이기 때문이다.

### Export

Runtime Export에서는 실제 사용되는 Resource만 포함되어야 한다.

VFX Definition이 참조하는 Visual Resource가 Export 대상에서 누락되지 않도록 Dependency Resolver가 검사해야 한다.

Prompt Sidecar는 Runtime PCK에 필수 데이터로 취급하지 않는다.

### 변경 안전성

Import/Export 과정에서 다음을 금지한다.

- 원본 이미지 자동 덮어쓰기
- Prompt 자동 수정
- 기존 Asset ID 자동 변경
- 기존 VFX Definition 자동 삭제
- Production Resource 자동 변환

변환이 필요한 경우 별도 Output을 생성하고 원본과 연결한다.

### PROPOSAL

P0에서는 별도 VFX Package/Export Tool을 만들지 않는다.

기존 MENOS SQLite Catalog + Godot Export 의존성 구조를 사용한다.

Package/Export 기능은 VFX Definition과 Dependency Graph가 안정된 후 P2/P3에서 추가한다.

### UNVERIFIED

- Godot PCK에서 VFX Dependency가 실제로 누락 없이 포함되는지
- Prompt Sidecar를 Editor Export에서 어떻게 제외할지
- 외부 VFX Package 교환 포맷 필요성
- VFX Package를 독립적으로 배포할 필요성

### OUT OF SCOPE

- Import Tool 구현
- Package Tool 구현
- Export Pipeline 변경
- Asset 변환
- 기존 Resource 이동

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Accessibility / Platform Variant 정책 조사

### CONFIRMED

현재 MENOS Runtime에는 Generic VFX의 Accessibility 또는 Platform Variant 전용 정책이 확인되지 않는다.

기존 VFX 설계에는 Variant와 Runtime Policy가 이미 정의되어 있으므로 Accessibility/Platform 차이를 동일한 Override 체계에 무분별하게 넣지 않는 경계가 필요하다.

### 마리의 판정

Accessibility와 Platform Variant는 목적이 다르다.

Accessibility:

- Flash Intensity
- Screen Flash 감소/비활성
- Excessive Motion 감소
- High Contrast 보조
- Persistent Effect 명확화

Platform Variant:

- Texture/Resource 품질
- Particle Count
- Effect Complexity
- Resolution
- Performance Tier
- LOD 수준

따라서 둘을 별도 정책으로 관리한다.

### Accessibility

Gameplay 의미를 유지하면서 시각 자극만 조정한다.

예:

Full Flash
→ Reduced Flash
→ No Flash

또는:

Full Motion
→ Reduced Motion

Accessibility 설정은 Damage, Hit Timing, Target, Gameplay Duration을 변경하지 않는다.

### Platform Variant

동일한 VFX Definition을 유지하면서 플랫폼/성능 조건에 맞는 Visual Resource 또는 Component Complexity를 선택한다.

예:

Desktop:
Full Particle

Low Tier:
Reduced Particle

Mobile:
Minimal Particle

Platform Variant가 Gameplay 결과를 변경해서는 안 된다.

### Variant 우선순위

권장 해석 순서:

Definition Default
→ Named VFX Variant
→ Platform Variant
→ Accessibility Adjustment
→ Runtime Instance Override

단, 각 단계는 허용된 Parameter만 변경한다.

Component 구조 자체를 Runtime에서 임의 변경하는 기능은 초기 범위에서 제외한다.

### Production Validation

Accessibility/Platform Variant가 존재하는 경우:

- 참조 Resource 유효성
- Override Parameter 유효성
- 지원 플랫폼/설정 조건 유효성
- 기본 Definition과의 호환성

을 검증한다.

Variant가 없다고 Production Error로 보지는 않는다. Default Definition으로 실행 가능하면 된다.

### PROPOSAL

P0에서는 Accessibility/Platform Variant UI를 구현하지 않는다.

P1 이후 Parameter/Variant 시스템이 안정된 뒤 별도 정책 계층으로 추가한다.

### UNVERIFIED

- MENOS 목표 플랫폼
- 실제 Accessibility 옵션 범위
- 저사양 기준
- 플랫폼별 Resource Bundle 정책
- Screen Flash의 실제 적용 범위

### OUT OF SCOPE

- Accessibility 기능 구현
- Platform Variant 구현
- Rendering Quality 설정 변경
- Particle/Shader 최적화

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX Camera / Audio / UI Boundary 정책 조사

### CONFIRMED

현재 Runtime은 World 좌표 기반 Projectile/Impact VFX와 Screen 좌표 기반 UI를 모두 GameController에서 직접 렌더링한다.

Generic VFX 설계에는 Camera, Audio, UI와의 책임 경계가 아직 명시적으로 구현되지 않았다.

### 마리의 판정

VFX Core는 Visual Effect 자체만 책임지고 Camera/Audio/Game UI 시스템의 소유권을 가져가지 않는다.

### Camera Boundary

VFX는 Camera를 직접 제어하지 않는다.

Camera Shake, Zoom, Flash, Post-process 같은 Camera 연출은 별도 Camera/Presentation System이 소유한다.

VFX가 필요한 경우:

VFX Event
→ Presentation Trigger
→ Camera Effect

형태로 연결한다.

VFX Definition 안에 Camera Transform을 직접 변경하는 Gameplay Logic을 넣지 않는다.

### Audio Boundary

VFX Definition은 Sound ID 또는 Audio Trigger를 직접 실행하는 대신 선택적 Presentation Cue를 제공할 수 있다.

구조:

Gameplay Event
→ Presentation Event
→ VFX / Audio

또는:

VFX Marker
→ Presentation Cue
→ Audio System

Audio Asset 자체는 Audio Catalog가 소유한다.

Prompt/Image Asset과 Audio Authoring Metadata를 동일 시스템으로 강제하지 않는다.

### UI Boundary

World VFX와 Screen/UI Effect를 Transform Space로 구분한다.

- World
- Attached
- Local
- Screen

Screen VFX는 UI Canvas/Screen Presentation 영역에서 실행할 수 있지만 UI Layout/Widget의 책임을 침범하지 않는다.

예:

Damage Number
→ UI System

Screen Flash
→ Presentation/VFX Layer

Skill Button
→ UI System

### Camera / Audio / UI와의 공통 경계

공통 Gameplay Event를 직접 소비할 수 있지만 각 Presentation System은 독립적으로 동작한다.

Gameplay Event
→ Presentation Resolver
→ VFX
→ Camera
→ Audio
→ UI

한 시스템의 실패가 다른 Presentation System의 Gameplay 실행을 중단시키지 않는다.

### PROPOSAL

초기 Generic VFX Core에서는 Camera Shake, Audio Playback, UI Widget 생성 기능을 직접 포함하지 않는다.

대신 Marker/Cue와 Presentation Event 연결점만 제공한다.

이 구조가 VFX Core를 범용으로 유지하면서 MENOS 통합을 가능하게 한다.

### UNVERIFIED

- 현재 MENOS Camera System의 독립 구조
- Audio Runtime/Editor의 실제 구현 상태
- UI VFX의 최종 Screen Layer 구조
- Presentation Resolver를 별도 시스템으로 둘지 여부

### OUT OF SCOPE

- Camera System 구현
- Audio System 구현
- UI System 변경
- Screen VFX 구현
- Presentation Resolver 구현

### 상태

**CONFIRMED / INFERENCE / PROPOSAL**


## VFX 전체 조사 종료 판정 / 구현계획 기준선

### 조사 범위

다음 VFX 영역을 조사했다.

- Runtime Effect 구조
- Skill / Finisher 연동
- Robot / Unit / Tower / Enemy Visual 경계
- Projectile / Impact VFX
- VFX Definition
- Generic VFX Core
- Trigger / Binding
- Context Resolver
- Transform / Attachment
- Component / Timeline
- Variant / Override
- Lifecycle / Concurrency / Interrupt
- Performance / Pooling / LOD
- Preview / Debug
- Production Validation
- Schema / Version / Migration
- Dependency / Usage
- Fail-safe / Fallback
- Determinism / Randomness
- Import / Package / Export
- Accessibility / Platform Variant
- Camera / Audio / UI Boundary

### CONFIRMED

현재 MENOS Runtime의 VFX는 Generic VFX System이 아니라 GameController 중심의 Procedural Effect 구조이다.

현재 구조를 즉시 교체할 필요는 없다.

Generic VFX 설계와 기존 Runtime을 Adapter 경계로 분리하는 것이 가장 안전하다.

### 최종 구조 기준선

Authoring:

Image Source
→ Prompt Sidecar
→ Visual Asset Catalog
→ VFX Definition Catalog
→ VFX Variant

MENOS Integration:

Gameplay Definition
→ Gameplay Event
→ VFX Binding Catalog
→ Trigger Resolver
→ VFX ID / Variant / Override

Runtime:

VFX Definition
→ VFX Instance
→ Runtime Adapter
→ Godot Renderer

Presentation Boundary:

Gameplay Event
→ Presentation
→ VFX / Camera / Audio / UI

### 구현 단계

P0 — Authoring Foundation

- VFX Definition Schema
- Catalog / Repository / Loader
- Visual Resource Reference
- Status / Revision
- Basic Validation
- Prompt Traceability

P1 — VFX Authoring

- Components
- Transform
- Timeline
- Parameters
- Variant / Override
- Preview / Debug

P2 — MENOS Integration

- VFX Binding Catalog
- Trigger Resolver
- Gameplay Context
- Runtime Adapter
- Projectile Pilot
- 기존 Procedural VFX 단계적 연결

P3 — Runtime Extension

- Pooling
- Culling
- LOD
- Advanced Particle
- Shader
- Beam / Trail 확장
- Accessibility / Platform Variant
- Package / Export
- Advanced Debug / Compare

### 변경 안전성

P0/P1에서는 현재 Campaign 1 Runtime VFX를 변경하지 않는다.

P2에서도 전체 Migration을 한 번에 수행하지 않는다.

단일 Pilot VFX로 Adapter와 Gameplay/VFX 분리 구조를 검증한 후 다음 대상으로 확장한다.

### 성공 기준

VFX Editor에서 Definition을 생성하고 저장할 수 있다.

Definition을 다시 Load할 수 있다.

Visual Resource를 참조할 수 있다.

Prompt Sidecar Traceability를 확인할 수 있다.

Validation Error를 검출할 수 있다.

Preview에서 Definition을 재생할 수 있다.

MENOS Gameplay Event에서 VFX Binding을 Resolve할 수 있다.

Runtime Adapter가 VFX Instance를 생성할 수 있다.

Gameplay 결과와 VFX 상태가 서로 독립적으로 유지된다.

### 최종 판정

현재 VFX 요구사항 조사는 목적에 충분하다.

추가 조사보다 구현계획 수립이 정보 가치가 높다.

다음 단계는 Master가 요청할 경우 P0 구현계획을 작성한다.

### 상태

**PASS — INVESTIGATION COMPLETE**


## VFX P0 구현계획

### 목적

Generic VFX Authoring Foundation을 구축하기 위한 최소 구현계획을 정의한다.

목표는 Runtime VFX 교체가 아니라 Definition을 안정적으로 생성/저장/로드/검증할 수 있는 기반을 확보하는 것이다.

### 기준선

현재 MENOS Content 구조:

Editor
→ ObjectPersistence
→ SQLite Catalog
→ ContentCatalogLoader / Repository
→ Runtime

현재 VFX 전용 Catalog/Repository/Definition/Editor는 구현되지 않았다.

### P0-1 — Definition Model

신규 최소 Definition 구조를 정의한다.

Identity:
- id
- name
- category
- schema_version
- revision
- status

Authoring:
- description
- components
- timeline
- transform
- parameters

Resource:
- visual_resource_refs

Runtime Policy:
- priority
- concurrency
- max_instances

Gameplay 정보는 Definition에 포함하지 않는다.

### P0-2 — Catalog / Repository / Loader

기존 Content Catalog 패턴을 따른다.

목표 구조:

VFX Editor
→ VFX Repository
→ VFX Definition Catalog
→ VFX Definition Loader

SQLite 저장은 기존 ObjectPersistence / ContentCatalogLoader 패턴을 재사용한다.

최종 SQLite Schema는 구현 전에 기존 저장 패턴을 직접 대조하여 확정한다.

### P0-3 — VFX Editor 최소 UI

최소 기능:

- VFX 목록
- 신규 VFX 생성
- VFX 선택
- ID / Name / Category
- Schema Version / Revision
- Status
- Description
- Visual Resource Reference
- Save
- Reload
- Delete는 초기 Production 보호정책 확정 후 제공

Timeline/Component의 실제 편집 UI는 P1로 미룬다.

### P0-4 — Visual Resource / Prompt Traceability

VFX Editor에서 Visual Resource ID를 선택할 수 있어야 한다.

Resource 선택 시 다음 상태를 표시한다.

- Visual Asset ID
- Source Image
- Prompt Sidecar 경로
- Prompt Status
- Traceability 상태

Prompt 본문을 VFX Definition에 복제하지 않는다.

### P0-5 — Validation

P0 Validator 최소 검사:

- ID 존재
- ID 중복
- Schema Version 지원
- Status 유효
- Visual Resource Reference 유효
- 필수 구조 존재
- Production 상태에서 Validation Error = 0

Validation 결과는 저장하지 않고 실행 결과로 제공한다.

### P0-6 — Definition Migration Boundary

Loader 단계에서:

Stored Definition
→ Schema Version Check
→ Migration
→ Canonical Definition
→ Editor/Runtime Consumer

구조를 확보한다.

P0에서는 schema_version=1만 지원하고 Migration Framework의 경계만 만든다.

### P0-7 — 테스트

최소 테스트:

1. 빈 Catalog Load
2. 신규 Definition 생성
3. Save
4. Reload
5. Definition 값 보존
6. Visual Resource Reference 보존
7. Revision 보존
8. Validation Error 검출
9. 잘못된 Resource Reference 검출
10. Schema Version 검출

Editor Smoke Test와 Data Smoke Test를 분리한다.

### 변경 제한

P0에서는 다음을 변경하지 않는다.

- GameController VFX Runtime
- Projectile Renderer
- Impact Renderer
- Skill Runtime
- GameplayEvent
- Robot/Tower/Enemy Definition
- Existing Visual Assets
- Existing SQLite Catalog Data

신규 VFX Catalog/Definition 기반만 추가한다.

### 성공 조건

다음이 모두 충족되면 P0 종료:

- VFX Definition 생성 가능
- SQLite 저장/로드 가능
- Editor에서 수정 가능
- Visual Resource Reference 가능
- Prompt Traceability 표시 가능
- Validation 실행 가능
- Schema Version 경계 존재
- 기존 Campaign 1 Runtime 변경 없음
- 기존 Content Catalog Regression 없음

### 구현 순서

P0-1 Definition
→ P0-2 Catalog/Repository/Loader
→ P0-3 Editor
→ P0-4 Resource Traceability
→ P0-5 Validation
→ P0-6 Migration Boundary
→ P0-7 Smoke Test

각 단계 성공 후 다음 단계로 이동하며, 실패 시 HOLD한다.

### PROPOSAL

P0 첫 구현은 VFX Runtime Adapter가 아닌 Authoring/Data Layer부터 시작한다.

현재 조사 결과와 기존 MENOS Content 구조를 가장 적게 침범하면서 VFX Editor의 실제 기반을 검증할 수 있는 경로이다.

### 상태

**PROPOSAL — IMPLEMENTATION PLAN**


## VFX P0-1 Definition Model 기준선 조사 결과

### CONFIRMED

기존 MENOS Definition 계층은 Godot RefCounted 기반의 명시적 Definition 클래스를 사용한다.

확인된 패턴:

- VisualAssetDefinition
- ObjectDefinition
- RobotDefinition
- TowerDefinition
- EnemyDefinition
- AlliedUnitDefinition
- Skill 관련 Dictionary Catalog

VisualAssetDefinition은 from_dict() / to_dict()를 사용하여 SQLite의 Dictionary Catalog와 Definition 객체 사이를 변환한다.

### 마리의 판정

VFX Definition도 기존 패턴을 따르는 것이 가장 안전하다.

권장:

VFXDefinition extends RefCounted

그리고:

from_dict(data)
to_dict()

를 제공한다.

VFX Definition은 ObjectDefinition을 상속하지 않는다.

VFX는 Robot/Unit/Tower 같은 Gameplay Object가 아니며, Generic Visual Runtime Definition이기 때문이다.

### P0 필드 기준

Identity:
- id: String
- name: String
- category: String
- schema_version: int
- revision: int
- status: String

Authoring:
- description: String
- components: Array
- timeline: Dictionary
- transform: Dictionary
- parameters: Dictionary

Resource:
- visual_resource_refs: Array

Runtime Policy:
- priority: int
- concurrency: String
- max_instances: int

### Serialization

to_dict()는 저장용 Dictionary를 반환한다.

from_dict()는 저장된 Dictionary를 Canonical Definition으로 정규화한다.

입력에 누락된 선택 필드는 기본값을 사용한다.

필수 필드가 없거나 타입이 잘못된 경우 Validator가 오류로 판정한다.

Definition이 저장 과정에서 임의로 데이터를 보정하여 Production 상태로 승격해서는 안 된다.

### Schema Version

초기:

schema_version = 1

Loader는 Definition을 읽을 때 Schema Version을 먼저 확인한다.

지원하지 않는 Version은 자동 추측하지 않고 Load/Validation Error로 처리한다.

### Revision

revision은 Authoring Revision이다.

새 Definition은 revision = 1에서 시작하는 방안을 제안한다.

Definition 변경 시 Revision 증가 규칙은 앞서 정의한 정책을 따른다.

### Status

초기 상태:

Draft

Production Lifecycle:

Draft → Review → Validated → Production → Deprecated

Status 변경과 Validation은 별도 책임이다.

### Gameplay Boundary

다음 필드는 VFX Definition에 포함하지 않는다.

- damage
- target actor
- HP
- cooldown
- gameplay duration
- hit result
- gameplay RNG
- GameplayEvent 객체

이들은 Gameplay System 또는 Runtime Instance가 소유한다.

### PROPOSAL

P0-1에서는 실제 파일/코드를 즉시 생성하지 않고 위 Definition 계약을 먼저 기준선으로 확정한 뒤 P0-2 Catalog 저장 구조로 진행한다.

### UNVERIFIED

- 최종 category 값 목록
- 최종 concurrency enum
- max_instances 기본값
- Parameter 타입 표현 방식
- Component/Timeline 상세 Schema

### OUT OF SCOPE

- VFXDefinition 코드 생성
- SQLite Schema 변경
- Runtime Adapter
- Component/Timeline Editor 구현

### 상태

**CONFIRMED / PROPOSAL — P0-1 BASELINE**


## VFX P0-2 Catalog / Repository / Loader 저장 구조 조사 결과

### CONFIRMED

현재 MENOS의 Content 저장은 SQLite를 단일 권한 저장소로 사용한다.

ContentCatalogLoader는 Catalog Path를 SQLite Table로 매핑한다.

ObjectPersistence는 동일한 Path를 SQLite Table로 매핑하여 저장한다.

VisualAssetRepository는 다음 구조를 사용한다.

VisualAssetRepository
→ ContentCatalogLoader.load_dictionary_catalog("visual_assets")
→ VisualAssetDefinition.from_dict()

따라서 VFX도 기존 구조를 그대로 재사용할 수 있다.

### Catalog 저장 단위 판정

현재 구조에서는 별도의 VFX 전용 데이터베이스가 필요하지 않다.

권장 Catalog:

vfx_definitions

형태의 단일 Catalog Document/Table을 사용한다.

Catalog 내부는:

VFX ID → VFX Definition Dictionary

구조로 한다.

예:
- vfx.projectile.default
- vfx.impact.default
- vfx.skill.area

실제 Production ID는 구현 단계에서 확정한다.

### 권장 Runtime 구조

VFXDefinitionLoader
→ ContentCatalogLoader.load_dictionary_catalog("vfx_definitions")
→ VFXDefinition.from_dict()

VFXDefinitionRepository
→ Loader
→ Cache
→ get_definition(id)
→ exists(id)
→ list(category)

VisualAssetRepository와 동일한 Repository 패턴을 따른다.

### 저장 구조

Editor:

VFX Editor
→ VFXDefinitionRepository / ObjectPersistence
→ vfx_definitions
→ SQLite raw_json

Runtime:

vfx_definitions
→ ContentCatalogLoader
→ VFXDefinitionLoader
→ VFXDefinition

Prompt Body는 SQLite에 저장하지 않는다.

Visual Resource Reference만 VFX Definition에 저장한다.

Prompt는 기존 Canon에 따라 Resource Sidecar에 존재한다.

### 기존 구조와의 차이

Visual Assets는 현재 1개의 Catalog Document가 visual_assets Table에 저장되어 있다.

VFX도 동일한 single-document Catalog 방식을 우선 사용한다.

따라서 P0에서 새로운 SQLite Column이나 별도 Normalized VFX Table을 만들 필요가 없다.

### SQLite Schema 판단

현재 ObjectPersistence의 single-document 경로는:

Table
→ 단일 row
→ raw_json

을 전제로 한다.

따라서 P0 VFX Catalog도 이 방식을 사용하는 것이 변경 위험이 가장 낮다.

단, 실제 vfx_definitions Table 생성은 구현 단계에서 Database Migration/초기화 경로를 직접 확인한 뒤 수행한다.

### Repository 책임

VFXDefinitionRepository는 다음만 담당한다.

- Catalog Load
- Cache
- Reload
- Definition 조회
- 존재 여부
- Category별 목록

Repository가 담당하지 않는 것:

- Editor UI
- Validation
- Runtime Rendering
- Gameplay Binding
- Prompt Body 관리
- Runtime Instance

### Loader 책임

VFXDefinitionLoader는:

Catalog Dictionary
→ Schema Version 확인
→ Migration Boundary
→ VFXDefinition.from_dict()
→ Canonical Definition

의 경계를 담당한다.

P0에서는 schema_version=1을 지원한다.

### 저장 안전성

P0 구현 시 기존 ObjectPersistence.save_catalog()를 우선 재사용한다.

저장 후 SQLite 재조회로 raw_json이 실제 저장값과 일치하는지 확인한다.

기존 MENOS 저장 방식의 transactional verification을 유지한다.

### PROPOSAL

P0 Catalog 구조:

VFX Editor
→ ObjectPersistence.save_catalog("vfx_definitions", catalog)
→ SQLite vfx_definitions
→ ContentCatalogLoader
→ VFXDefinitionLoader
→ VFXDefinitionRepository

로 확정하는 것을 제안한다.

별도 VFX DB, 별도 파일 기반 JSON 권한 저장, Prompt Body SQLite 저장은 사용하지 않는다.

### UNVERIFIED

- 현재 Database 생성/Migration 코드의 정확한 위치
- 신규 vfx_definitions Table 자동 생성 지원 여부
- 초기 Empty Catalog row 생성 방법
- Export PCK에 신규 Table이 포함되는 기존 빌드 경로의 자동 처리 여부

### OUT OF SCOPE

- SQLite Table 생성
- VFXDefinition 코드 생성
- Repository 코드 생성
- Editor 구현
- Runtime Adapter

### 상태

**CONFIRMED / PROPOSAL — P0-2 BASELINE**


## VFX P0-2 실제 구현 결과

### 변경 사항

P0-2 기준에 따라 다음 Authoring/Data Layer를 실제 구현했다.

- godot/scripts/vfx_definition.gd
- godot/scripts/vfx_definition_loader.gd
- godot/scripts/vfx_definition_repository.gd
- godot/tests/vfx_p0_catalog_smoke_test.gd

SQLite에 vfx_definitions single-document table을 추가했다.

Schema:

vfx_definitions
- document_id TEXT PRIMARY KEY
- raw_json TEXT NOT NULL

초기 document_id는 vfx_definitions이며 raw_json은 빈 Catalog 상태이다.

### Runtime 영향 제한

이번 구현은 Generic VFX Definition의 저장/로드 계층만 추가했다.

변경하지 않은 영역:

- GameController VFX Runtime
- Projectile Renderer
- Impact Renderer
- Skill Runtime
- GameplayEvent
- Robot/Tower/Enemy Definition
- 기존 Visual Assets

따라서 기존 Campaign Runtime 경로와 분리되어 있다.

### 검증

VFX P0 Catalog Smoke:

VFX_P0_CATALOG_SMOKE_PASS

검증 내용:

- Schema 생성
- Definition 생성
- Save
- SQLite Catalog 저장
- Reload
- Visual Resource Reference 보존
- Schema Version 보존
- Delete/Cleanup

Campaign Runtime Regression:

CAMPAIGN_RUNTIME_SMOKE_PASS stages=3 giant=true

기존 Campaign 1 Runtime 경로가 계속 PASS임을 확인했다.

Headless 종료 시 ObjectDB/resource leak warning이 있었으나 Campaign Smoke 자체는 PASS했다. 이번 VFX Catalog 추가와 직접 관련된 오류로 확인되지는 않았다.

### 중요한 구현 판단

Godot Headless에서 신규 class_name 전역 등록에 의존하면 새 Definition/Repository 스크립트가 즉시 서로를 해석하지 못하는 문제가 확인됐다.

따라서 신규 VFX Data Layer 내부 참조는 preload 기반으로 구성했다.

이는 기존 Runtime의 전역 ClassName 구조를 변경하지 않으면서 P0 Data Layer를 안정적으로 로드하기 위한 구현 판단이다.

### 상태

**CODE VERIFIED — PASS**

**DATA SMOKE VERIFIED — PASS**

**CAMPAIGN REGRESSION VERIFIED — PASS**

**PIE VERIFIED — NOT VERIFIED**

### 미확인

- VFX Editor UI
- VFX Definition Validation Runner
- Prompt Sidecar 자동 검사
- Component/Timeline 실제 편집
- VFX Binding Catalog
- Runtime Adapter

### 다음 결정 지점

P0-2 Data Layer는 목적을 충족했다.

다음 P0 단계는 VFX Editor 구현이지만, Editor UI를 만들기 전에 Validation을 기존 Content Validation 체계에 통합할지 독립 VFX Validator로 둘지 결정이 필요하다.

이 지점은 설계 선택이므로 Master 결정이 필요하다.

### 상태

**DECISION REQUIRED — VFX P0 VALIDATION ARCHITECTURE**


## VFX P0 Validation 통합 구현

### 결정

Master 승인에 따라 기존 ContentValidator에 VFX Validation을 통합한다.

별도 Validation Runner를 만들지 않는다.

### 구현 범위

기존 ContentValidator의 _run()에 VFX Definition Catalog 검증을 추가한다.

검증 대상:

- VFX Catalog 존재/구조
- VFX ID
- schema_version
- revision
- status
- category
- components
- timeline
- transform
- parameters
- visual_resource_refs
- priority
- concurrency
- max_instances
- Visual Asset Reference 존재 여부
- Production 상태의 기본 필수조건

Prompt Sidecar의 실제 파일 검증은 다음 단계에서 별도 Authoring Traceability 검사로 확장한다.

### 오류 원칙

VFX Definition이 Runtime에서 해석 불가능한 경우 ERROR.

Prompt Traceability가 아직 확인되지 않은 경우 P0에서는 WARNING 후보로 취급한다.

Validation은 Definition을 수정하거나 자동 보정하지 않는다.

### 구현 후 검증

ContentValidator 전체 실행과 VFX Catalog Smoke를 각각 실행한다.

Campaign Runtime Regression도 재실행한다.

### 상태

**PROPOSAL ACCEPTED — IMPLEMENT**


## VFX P0 Validation 통합 검증 결과

### CONFIRMED

VFX 전용 Validator는 정상 동작했다.

결과:

VFX_VALIDATOR_RESULT errors=0 warnings=0
VFX_VALIDATOR_SMOKE_PASS

현재 vfx_definitions Catalog의 Definition, Schema Version, Status, Resource Reference 등의 P0 검사가 통과한다.

### ContentValidator 통합 결과

기존 ContentValidator에 VFX Validator 호출을 통합한 뒤 전체 Validator를 실행했다.

결과:

CONTENT_VALIDATION_VFX_RESULT valid=false errors=35 warnings=0

VFX 관련 신규 오류는 발생하지 않았다.

그러나 기존 ContentValidator 전체 검증에서 다음 기존 데이터/검증 불일치가 확인되었다.

- Campaign Stage ID가 14.0 / 15.0 / 16.0으로 해석됨
- Stage Mission/Reward ID가 17.0 / 21.0 등으로 해석됨
- Map Validator가 현재 Map Schema와 맞지 않는 필드를 요구함
- 기존 Visual Asset team mask size 오류

일부 오류는 현재 프로젝트의 기존 저장 데이터와 Validator의 기대 Schema가 불일치하는 것으로 보인다.

### 판정

VFX Validator 자체는 목적을 달성했다.

그러나 통합된 전체 ContentValidator가 PASS하지 않았으므로 P0 Validation 통합을 최종 PASS로 승격하지 않는다.

기존 오류를 VFX 작업 범위에서 임의 수정하지 않는다.

이는 Atlas Scope Lock에 따라 OUT OF SCOPE로 유지한다.

### 현재 상태

**VFX_VALIDATOR — CODE VERIFIED / PASS**

**CONTENT VALIDATOR INTEGRATION — CODE VERIFIED / REGRESSION BLOCKED**

**PIE — NOT VERIFIED**

### HOLD 사유

다음 P0 단계인 VFX Editor 구현으로 즉시 넘어가면 전체 Content Validation Regression 상태를 확인하지 않은 채 범위를 확장하게 된다.

현재 확인된 기존 Validator 오류가 VFX 통합 이전에도 존재했는지 독립 기준선 확인이 필요하다.

### Master 결정 지점

다음 중 하나가 필요하다.

1. 기존 ContentValidator 오류를 별도 작업으로 분리하고 VFX P0을 계속 진행
2. 기존 ContentValidator 기준선부터 별도로 복구/정합화한 뒤 VFX P0을 계속 진행

마리의 제안은 **1번**이다.

기존 Validator 오류는 VFX 목적과 직접 관계가 없으므로 별도 Scope로 분리하고, VFX 전용 Validator는 PASS 상태로 유지하는 것이 적절하다.

### 상태

**HOLD — DECISION REQUIRED**


## VFX P0 Validation 분리 기준 확정

Master 승인에 따라 기존 ContentValidator의 비-VFX 오류는 별도 Scope로 분리한다.

현재 VFX P0 기준은 다음 두 검증으로 유지한다.

- VFX Catalog Smoke: PASS
- VFX Validator Smoke: PASS

전체 ContentValidator의 기존 오류는 수정하지 않는다.

### 현재 검증

- VFX_P0_CATALOG_SMOKE_PASS
- VFX_VALIDATOR_SMOKE_PASS
- CAMPAIGN_RUNTIME_SMOKE_PASS stages=3 giant=true

Campaign Runtime 종료 시 기존 ObjectDB/resource leak warning이 출력되지만 exit code 0이며 Campaign smoke 자체는 PASS이다.

### 상태

**VFX P0 VALIDATION — ACCEPTED / PASS**

다음 단계는 VFX Editor 구현이며, 별도 Master 결정이 필요한 설계가 발견될 때까지 권한 위임 범위에서 계속 진행한다.

## VFX P0 Editor 실제 구현 결과

Master 권한 위임에 따라 별도 설계 결정 없이 구현 가능한 P0 Editor 범위를 진행했다.

### 구현

추가:
- godot/editor/vfx_editor.gd
- godot/editor/vfx_editor.tscn

통합:
- Content Editor의 기존 VFX 메뉴를 활성화
- BtnVFX → VFX Editor Scene 연결
- Active Editor 상태 처리 추가

VFX Editor P0 기능:
- VFX Definition 목록
- New / Refresh
- VFX ID
- Name
- Category
- Revision
- Status
- Description
- Components JSON Array
- Visual Resource IDs JSON Array
- Runtime Priority
- Concurrency
- Max Instances
- Save / Delete
- 기본 Definition Validation
- Visual Asset Reference 존재 검사

저장 경로는 기존 P0 Data Layer를 그대로 사용한다.

VFX Editor → VFXDefinitionRepository → ObjectPersistence → SQLite vfx_definitions

### 검증

- VFX_EDITOR_SCENE_PASS
- CONTENT_EDITOR_VFX_PASS
- VFX_P0_CATALOG_SMOKE_PASS
- VFX_VALIDATOR_SMOKE_PASS
- CAMPAIGN_RUNTIME_SMOKE_PASS stages=3 giant=true

### 범위 판정

현재 구현은 P0 Authoring Foundation에 해당한다.

아직 구현하지 않은 항목:
- Component 전용 Editor UI
- Timeline Editor
- Transform/Attachment Editor
- Variant/Override Editor
- VFX Preview Renderer
- VFX Binding Editor
- Runtime Adapter
- Prompt Sidecar 자동 검증/편집 UI

이는 P1/P2 범위이며 현재 단계에서 임의 확장하지 않는다.

### 검증 상태

CODE VERIFIED — PASS
EDITOR SCENE VERIFIED — PASS
DATA VERIFIED — PASS
RUNTIME REGRESSION VERIFIED — PASS
PIE — NOT VERIFIED

### 현재 다음 결정 지점

P0 Editor Foundation은 목적에 충분한 상태다.

다음 단계는 P1 Visual Composition으로,
Component → Timeline → Transform → Preview
중 하나의 실제 Editor 구현을 시작하게 된다.

이 단계부터 Timeline/Component의 구체적인 Authoring UX와 저장 Schema를 확정해야 하므로 Master 결정이 필요한 지점이다.

HOLD — DECISION REQUIRED
## VFX P1 Component + Timeline 구현 결과

Master 승인 및 권한 위임에 따라 P1의 첫 구현 단계를 진행했다.

### 구현 범위

VFX Editor가 다음을 실제 Authoring할 수 있도록 확장했다.
- Component 목록
- Component Type
- Component Visual Resource Reference
- Component 추가/삭제
- Timeline Duration
- Timeline Loop
- Timeline Playback: Once / Loop / Ping Pong
- Timeline Tracks 기본 배열 저장
- 기존 Definition / Revision / Status / Runtime Policy 저장 유지

저장 Schema는 기존 components / timeline Dictionary 구조를 유지하며 확장했다. 별도 DB나 JSON 권위를 추가하지 않았다.

### Validator 확장

VFX Validator가 다음을 검사한다.
- Component가 Dictionary인지
- Component Type 존재
- Timeline Duration > 0
- Timeline Playback 유효성
- Timeline Tracks가 Array인지

### 검증

- VFX Editor Scene: PASS
- VFX Editor Authoring Save/Reload: PASS
- VFX Validator: PASS, errors=0, warnings=0
- VFX P0 Catalog: PASS
- Campaign Runtime Regression: PASS, stages=3, giant=true

Campaign Runtime의 기존 종료 시 ObjectDB/resource leak warning은 계속 존재하지만 이번 변경과 직접 관련된 실패는 확인되지 않았다.

### 범위 판정

P1의 Component + Timeline 최소 Authoring 목적은 달성했다.

아직 구현하지 않은 항목:
- Transform / Attachment Authoring
- Timeline Track/Key 편집
- Parameter Authoring
- Variant / Override
- Runtime Preview
- Binding Catalog
- Runtime Adapter
- Prompt Sidecar 자동 편집/검증

다음 단계에서 Timeline Track/Key와 Transform을 동시에 구체화하면 Preview까지 이어지는 실제 VFX Authoring 흐름을 만들 수 있다.

STATUS — PASS
검증 상태 — CODE VERIFIED / EDITOR SCENE VERIFIED / DATA VERIFIED / RUNTIME REGRESSION VERIFIED / PIE NOT VERIFIED
다음 결정 지점 — Transform/Attachment와 Timeline Track/Key의 구체적인 저장 모델을 확정해야 함.
HOLD — DECISION REQUIRED
## VFX P1 Transform + Timeline Track 구현 결과

Master 승인 및 권한 위임에 따라 P1의 다음 단계까지 진행했다.

### 구현

- Transform Space: World / Attached / Local / Screen
- Anchor
- Offset X/Y
- Rotation
- Scale
- Timeline Track
- Track Property
- Track Start / End
- Track 추가 / 삭제
- Timeline Track의 keys 배열 기반 저장 구조
- Definition Save / Reload

Transform 저장 구조:
space + anchor + offset{x,y} + rotation + scale

Timeline Track 저장 구조:
property + start + end + keys[]

Track은 현재 시각 파라미터 영역만 대상으로 하며 Gameplay 상태를 참조하지 않는다.

### 검증

- `VFX_EDITOR_TRANSFORM_AUTHORING_PASS`
- `VFX_VALIDATOR_SMOKE_PASS`
- `CAMPAIGN_RUNTIME_SMOKE_PASS stages=3 giant=true`

중간에 Scene 경로 변경으로 발생한 Node lookup 오류는 수정했으며 최종 Authoring Smoke Test는 PASS했다.

Campaign Runtime에는 기존 ObjectDB 11건 / Resource 2건 종료 경고가 남아 있으나 Runtime Smoke 자체는 PASS했다.

### 판정

P1의 Transform 및 Timeline Track 기본 Authoring 목적은 충족했다.

다음 단계는 실제 Key Authoring과 Runtime Preview다. Key의 value 타입과 interpolation/easing 모델을 확정해야 하므로 이 지점은 임의 확장하지 않는다.

### 상태

STATUS — PASS
CODE VERIFIED — PASS
EDITOR SCENE VERIFIED — PASS
DATA VERIFIED — PASS
RUNTIME REGRESSION VERIFIED — PASS
PIE VERIFIED — NOT VERIFIED

### 마리 제안

다음은 Key Authoring을 먼저 구현하고, Key 값은 Variant가 아닌 Timeline Track의 시각 파라미터 값으로 한정하는 것이 적절하다.
초기 interpolation은 Linear / Step / Ease In / Ease Out 정도로 제한하고, Preview는 동일한 Definition 해석 경로를 사용하도록 구성하는 것을 제안한다.

HOLD — KEY VALUE / INTERPOLATION MODEL DECISION REQUIRED
## VFX P1 Timeline Key Authoring 구현 결과

Master 승인 및 권한 위임에 따라 Timeline Key Authoring까지 진행했다.

### 확정·구현된 최소 Key 모델

- `time`: Track 내부 시간
- `value`: 시각 파라미터 값
- `interpolation`: linear / step / ease_in / ease_out

Key는 반드시 Track의 start/end 범위 안에 있어야 한다.
Key는 Gameplay 상태, damage, HP, cooldown, target result를 저장하지 않는다.

Editor에서 Key 추가/삭제/선택 및 Save/Reload가 가능하다.
Track별 `keys[]` 배열에 저장한다.

### Validator

다음 조건을 추가 검증한다.
- tracks가 Array
- track이 Dictionary
- keys가 Array
- key가 Dictionary
- key time이 Track 범위 내
- key value가 비어 있지 않음
- interpolation이 허용 목록 내

### 검증

- `VFX_KEY_AUTHORING_PASS`
- `VFX_VALIDATOR_SMOKE_PASS` errors=0 warnings=0
- `VFX_P0_CATALOG_SMOKE_PASS`
- `CAMPAIGN_RUNTIME_SMOKE_PASS stages=3 giant=true`

Campaign Runtime 기존 종료 경고: ObjectDB 11건 / Resource 2건. Smoke PASS는 유지됨.

### 판정

Timeline Key Authoring의 최소 목적은 충족했다.

다음 단계는 Runtime Preview이다. Preview는 실제 렌더링과 Definition 해석을 연결해야 하며, 현재 Runtime VFX Renderer와 Generic VFX Definition 사이의 Adapter 경계를 구현해야 한다.

이는 기존 Combat Runtime에 직접 영향을 줄 수 있으므로 다음 단계부터는 Runtime Adapter의 구체적인 책임 범위를 결정해야 한다.

### 상태

STATUS — PASS
CODE VERIFIED — PASS
EDITOR SCENE VERIFIED — PASS
DATA VERIFIED — PASS
RUNTIME REGRESSION VERIFIED — PASS
PIE VERIFIED — NOT VERIFIED

### 마리 제안

Preview를 먼저 별도 Editor Preview Renderer로 구현하되, 실제 Runtime Gameplay 코드와 분리하고 동일한 VFX Definition 해석 함수를 공유하는 방향을 권고한다.
첫 Preview 대상은 Sprite / Shape / Ring / Line·Trail 중 현재 Definition 모델로 표현 가능한 최소 Component부터 시작하는 것이 적절하다.

HOLD — RUNTIME ADAPTER / PREVIEW BOUNDARY DECISION REQUIRED## VFX Runtime Adapter P1 구현 결과

Master 승인 및 권한 위임에 따라 VFX Definition과 Preview 사이의 공통 해석 계층을 구현했다.

### 구현

- godot/scripts/vfx_runtime_adapter.gd
- Definition을 Runtime-independent Visual Command로 해석
- Lifecycle: configure / play / stop / restart / seek / tick
- duration / progress / completion
- Timeline track 평가
- opacity / scale / rotation / position_offset
- Component command: sprite / shape / ring / line / trail / beam
- 미지원 Component는 unsupported command로 명시

### Preview 통합

VFX Editor Preview가 자체 Timeline 해석을 사용하지 않고 VFXRuntimeAdapter를 통해 동일한 Definition 해석 경로를 사용하도록 변경했다.

현재 구조:
VFX Definition → VFXRuntimeAdapter → Preview Renderer

Preview Renderer는 여전히 Editor 전용 procedural renderer이며 실제 Gameplay Runtime renderer와는 분리되어 있다.

### 검증

- VFX_RUNTIME_ADAPTER_SMOKE_PASS
- VFX_PREVIEW_AUTHORING_PASS
- VFX_VALIDATOR_SMOKE_PASS errors=0 warnings=0
- CAMPAIGN_RUNTIME_SMOKE_PASS stages=3 giant=true
- Campaign 종료 시 기존 ObjectDB 12건 / Resource 2건 leak warning 유지

### 변경 안전성

이번 Adapter 변경은 game_controller.gd의 실제 Combat VFX 실행 경로를 수정하지 않았다.
기존 Runtime VFX는 현재 구조 그대로 보호되었다.

### 다음 Runtime 구조 후보

VFX Definition → VFXRuntimeAdapter → Godot Runtime Renderer

Gameplay Event / Binding은 별도 계층으로 연결한다.

기존 Combat Runtime의 procedural VFX를 Adapter로 연결하는 단계에서는 Runtime Instance 경계를 결정해야 한다.

### 마리 제안

권고 구조:
Gameplay Event → VFX Binding → VFX Definition → VFX Runtime Instance → VFXRuntimeAdapter → Godot Renderer

기존 effects의 Gameplay damage / projectile arrival / hit 판정은 VFX에서 분리한다.

이는 Canon 승격이 아니며 PROPOSAL이다.

### 상태

STATUS — PASS / HOLD
CODE VERIFIED — PASS
EDITOR VERIFIED — PASS
RUNTIME REGRESSION VERIFIED — PASS
PIE VERIFIED — NOT VERIFIED

HOLD — 기존 Combat Runtime과 Generic VFX Runtime Instance의 통합 경계 결정 필요## VFX Runtime Integration P2 — Impact Pilot 구현 결과

Master 승인에 따라 Runtime Instance 분리안(제안 3)을 실제 Pilot으로 구현했다.

### 구현

- VFXRuntimeInstance 추가
- Gameplay `effects`와 별도의 `vfx_instances` Runtime 상태 추가
- effect 생성 경로를 `_append_effect()`로 중앙화
- `impact_explosion` 생성 시 Gameplay effect와 독립적인 VFX Runtime Instance 생성
- VFX Instance는 자체 Lifecycle / Timeline / Position을 보유
- Gameplay effect가 먼저 종료되어도 VFX Instance는 Definition Timeline에 따라 계속 실행 가능
- 기존 Projectile / Skill / Giant 등 다른 effect는 Legacy Renderer 경로를 유지

### Pilot Definition

- VFX ID: `impact_explosion`
- category: `combat`
- status: `Validated`
- component: `ring`
- duration: `0.35s`
- opacity / scale Timeline 포함
- concurrency: `allow_multiple`
- max_instances: `32`

SQLite VFX Definition Catalog에 등록했다.

### Runtime 경계

현재 실제 Runtime 구조:
Gameplay effect → `_append_effect()` → Gameplay effects
　　　　　　　　　　　　　　└→ impact_explosion → VFX Definition → VFX Runtime Instance → VFXRuntimeAdapter → Renderer

즉, Gameplay damage / hit 판정과 Pilot VFX의 lifecycle은 분리되었다.

### 검증

- `VFX_RUNTIME_INSTANCE_SMOKE_PASS`
- `VFX_RUNTIME_ADAPTER_SMOKE_PASS`
- `VFX_VALIDATOR_SMOKE_PASS errors=0 warnings=0`
- `VFX_P0_CATALOG_SMOKE_PASS`
- `VFX_PREVIEW_AUTHORING_PASS`
- `CAMPAIGN_RUNTIME_SMOKE_PASS stages=3 giant=true impact_vfx=true`

Campaign 종료 경고: ObjectDB 11건 / Resource 2건. Exit code 0 및 Smoke PASS.

### 변경 안전성

- 기존 Projectile / Skill / Giant Runtime의 Gameplay 판정은 변경하지 않았다.
- `impact_explosion`의 기존 procedural draw만 Generic VFX Runtime Instance로 이동했다.
- 실제 PIE는 아직 수행하지 않았다.

### 판정

Runtime Instance 분리 구조의 최소 Pilot 목적을 충족했다.

다음 단계는 나머지 Runtime VFX 중 어떤 것을 Generic VFX Definition으로 승격할지 분류하는 단계다.

현재는 모든 effect를 자동 이관하지 않았다. 특히 Projectile은 Gameplay arrival / damage timing과 강하게 결합되어 있어 별도 Binding/Instance 분리가 필요하다.

### 마리 제안

다음 우선순위는 Projectile VFX다.

권고 순서:
1. `proj_defender`
2. `proj_threat`
3. `giantHit`
4. `area` / `pierce`
5. cannon / gatling / robot 계열

Projectile은 VFX 이동과 Gameplay arrival을 동시에 변경하지 말고, 먼저 VFX Instance만 병렬 생성·렌더링한 뒤 기존 projectile effect를 검증하고 제거하는 2단계 방식이 안전하다.

이는 PROPOSAL이며 Canon이 아니다.

### 상태

STATUS — PASS / HOLD
CODE VERIFIED — PASS
BUILD VERIFIED — NOT RUN
EDITOR VERIFIED — PASS
RUNTIME REGRESSION VERIFIED — PASS
PIE VERIFIED — NOT VERIFIED

HOLD — 다음 Runtime Migration 대상 결정 필요