# MENOS 전체 구조 재편 개발계획
## 2026-10-04

## 1. 문서 목적

이 문서는 MENOS를 장기적으로 확장 가능한 구조로 재편하기 위한 구현 범위와 목표 구조를 정의한다.

이 문서의 목적은 즉시 기능을 구현하는 것이 아니다.

먼저 다음을 확정한다.

- 무엇을 재편할 것인가
- 각 데이터의 책임은 어디에 둘 것인가
- Editor / Content / Resource / Rule / Runtime / Replay / Release의 경계는 어디인가
- 어떤 순서로 안전하게 이행할 것인가
- 어떤 것은 이번 범위에서 구현하지 않을 것인가

구조 확정 후 각 단계의 실제 구현은 별도 작업으로 진행한다.

---

## 2. 기준선

### CONFIRMED

- 프로젝트: \`D:\\Atlas\\projects\\menos\\godot\`
- Branch: \`main\`
- HEAD: 현재 \`main...upstream/main\` 기준
- Working Tree:
  - \`editor/tower_editor.gd\` 수정 상태
  - 기존 설계/개발계획 문서가 존재
- 기존 주요 데이터:
  - \`content/editor/asset_catalog.json\`
  - \`content/editor/visual_assets.json\`
  - \`content/robots/robots.json\`
- 기존 주요 공통 계층:
  - \`scripts/visual_asset_definition.gd\`
  - \`scripts/visual_asset_resolver.gd\`
- 기존 Robot / Unit / Tower / Catalog / Content Editor는 부분적으로 서로 다른 데이터 접근 및 Preview/Asset 처리 로직을 보유한다.

기존 Working Tree 변경은 본 계획을 이유로 수정하거나 되돌리지 않는다.

---

## 3. 최종 목표 구조

MENOS의 전체 제작/실행 구조를 다음 10개 영역으로 분리한다.

\`\`\`
01 Resource
02 Content
03 Rule
04 Runtime
05 Network
06 Replay
07 Editor
08 Validation
09 Revision / History
10 Release / Recovery
\`\`\`

공통 기반은 다음과 같다.

\`\`\`
Stable ID
Revision
Reference
Dependency
Transaction
Validation
Hash
\`\`\`

---

## 4. Resource 계층

실제 파일과 게임에서 사용하는 논리적 리소스를 분리한다.

\`\`\`
Source Resource
    ↓
Imported Resource
    ↓
Logical Asset
\`\`\`

Resource Registry는 Resource ID, Type, Source Path, Hash, Size, Import Version, Import Settings, Revision, State를 관리한다.

Path는 식별자가 아니다.

Visual Asset은 Resource의 하위 개념으로 둔다. 향후 Audio Asset, Font Asset, VFX Asset, UI Asset, Shader/Material Asset, Animation Asset 확장을 허용한다.

현재 구현 대상은 Visual Asset 중심으로 시작한다.

Resource 상태는 최소 다음을 구분한다.

\`\`\`
Used
Unused
Broken
Missing
Duplicate
Deprecated
Archived
\`\`\`

자동 삭제는 하지 않는다.

---

## 5. Visual Asset 구조

Visual Asset은 Source Resource의 특정 시각적 의미를 표현한다.

\`\`\`
Visual Asset
 ├─ Source Resource
 ├─ Region
 ├─ Frames
 ├─ Columns
 ├─ Rows
 ├─ Frame Order
 ├─ Frame Regions
 ├─ Anchor
 ├─ Render Metadata
 ├─ Team Mask
 └─ Usage
\`\`\`

원칙:

- Uniform Cell과 Non-uniform Cell 모두 지원
- 2행 이상 Sprite Sheet 지원
- Frame별 Region 지원
- Anchor와 Object Position 분리
- Team Color와 Mask Source 분리
- Thumbnail은 Generated Artifact
- Preview는 Runtime과 동일한 Resolver 규칙 사용
- Visual Asset 자체는 Gameplay Rule을 소유하지 않음

---

## 6. Content 계층

Content는 게임에서 무엇인가를 정의한다.

주요 개념:

\`\`\`
Object
Skill
Effect
Technology
Map
Map Object Instance
Visual Asset
\`\`\`

Robot / Unit / Tower는 공통 Object 모델의 전문화된 Editor View 또는 Type으로 구성한다.

Object의 공통 속성과 타입별 속성을 분리한다.

Map Definition과 Map Instance를 분리한다.

Map에 배치된 객체의 현재 HP 등 Runtime State는 Content Definition에 저장하지 않는다.

---

## 7. Skill / Effect / Technology

Skill은 단순 Animation 데이터가 아니다.

\`\`\`
Skill
 ├─ Definition
 ├─ Cost
 ├─ Cooldown
 ├─ Target Rule
 ├─ Effect References
 ├─ Animation Binding
 └─ Gameplay Event Timing
\`\`\`

Effect는 Skill과 분리한다.

\`\`\`
Effect
 ├─ Type
 ├─ Parameters
 ├─ Duration
 ├─ Stack Rule
 ├─ Lifecycle
 └─ Source
\`\`\`

Technology는 Object의 능력치를 직접 복제하지 않고 Modifier / Effect / Requirement와 관계를 갖는다.

---

## 8. Rule 계층

DB는 값을 저장하고 Game Rule은 계산을 담당한다.

\`\`\`
Content Values
      ↓
Game Rule
      ↓
Calculated Result
\`\`\`

임의의 실행식/스크립트를 DB에 저장하는 구조는 기본 설계에서 사용하지 않는다.

Modifier에는 필요에 따라 Operation, Priority, Source, Duration, Stack Rule을 둔다.

---

## 9. Runtime 계층

Content Definition과 Runtime Instance/State를 분리한다.

\`\`\`
Definition
    ↓
Spawn
    ↓
Instance
    ↓
Runtime State
\`\`\`

Runtime State는 Content DB의 권위 데이터가 아니다.

---

## 10. Command / Event / State

Runtime의 기본 흐름:

\`\`\`
Command
    ↓
Rule / Simulation
    ↓
Event
    ↓
State
\`\`\`

Command와 Event를 동일 개념으로 취급하지 않는다.

---

## 11. Simulation

Simulation은 논리 시간(Tick)을 기준으로 동작한다.

\`\`\`
Simulation Tick
    ↓
Command Queue
    ↓
Phase Processing
    ↓
Events
    ↓
State Update
\`\`\`

필요한 경우 Input, Movement, Skill, Collision, Damage, Death, Effect, Cleanup 등의 Phase를 둘 수 있다.

Render Frame과 Simulation Tick은 분리한다.

---

## 12. Animation / Gameplay 연결

Animation이 게임 결과를 직접 결정하지 않도록 한다.

\`\`\`
Gameplay State
      ↓
Animation
\`\`\`

Skill의 Gameplay Timing은 Event/Marker로 연결한다.

예:

\`\`\`
Skill Cast
Frame Marker: Hit
    ↓
Gameplay Event
\`\`\`

Animation Frame 자체를 게임 판정의 유일한 시간 기준으로 사용하지 않는다.

---

## 13. Network

온라인 플레이를 고려할 경우 Server를 권위 시스템으로 둔다.

\`\`\`
Client
   ↓ Command
Server
   ↓ Validate
Simulation
   ↓
Event / State
\`\`\`

클라이언트가 Damage나 최종 결과를 권위 데이터로 보내는 구조는 사용하지 않는다.

Network Version과 Content Version은 분리한다.

---

## 14. Replay

Replay는 화면 녹화가 아니라 Simulation 재현 데이터로 정의한다.

\`\`\`
Replay
 ├─ Replay ID
 ├─ Replay Schema Version
 ├─ Build Version
 ├─ Protocol Version
 ├─ Content Revision
 ├─ Map Revision
 ├─ Random Seed
 ├─ Initial State
 ├─ Command / Event Stream
 ├─ Checkpoints
 └─ State Hash
\`\`\`

목표:

- Match 재생
- Seek
- Pause / Step
- Speed Control
- Debug 재현
- Bug Reproduction
- Regression Test
- 대전 기록 보존

Replay와 Save는 분리한다.

---

## 15. Deterministic Simulation

Replay를 안정적으로 재현하려면 가능한 범위에서 Simulation을 결정론적으로 구성한다.

기록 후보:

\`\`\`
Initial State
Seed
Content Revision
Map Revision
Rule Version
AI Version
Build Version
\`\`\`

Checkpoint에서는 State Hash를 비교할 수 있도록 한다.

---

## 16. Editor 계층

Content Editor를 상위 Host로 유지하되 실제 데이터 소유자가 되지 않도록 한다.

\`\`\`
Content Editor
    ↓
Editor Context
    ↓
Repository / Service
    ↓
Content Model
    ↓
Persistence
\`\`\`

공통 서비스:

\`\`\`
Content Repository
Resource Repository
Visual Asset Resolver
Reference Scanner
Validator
Thumbnail Service
Animation Service
Dependency Service
Revision Service
\`\`\`

Robot / Unit / Tower / Catalog는 이 공통 서비스를 사용한다.

---

## 17. Catalog Editor

Catalog는 데이터 소유자가 아니라 Browser / Picker 역할을 강화한다.

\`\`\`
Search
Filter
Preview
Select
Assign
Dependency View
Impact View
\`\`\`

선택 결과를 Editor 간 공통 Selection Context로 전달한다.

Catalog가 Object/Robot/Unit/Tower별 저장 로직을 직접 소유하지 않는다.

---

## 18. Repository / Persistence

Editor UI에서 직접 JSON/SQLite/FileAccess를 호출하지 않는다.

\`\`\`
Editor
 ↓
Definition / Model
 ↓
Repository
 ↓
Persistence
\`\`\`

저장소 구현은 현재 JSON에서 시작할 수 있지만 장기적으로 SQLite로 이전할 수 있도록 Repository 경계를 먼저 만든다.

SQLite는 Source of Truth를 위한 저장 계층으로 사용하며 Editor가 SQL을 직접 작성하지 않는다.

모든 주요 레코드는 단일 Stable ID를 사용한다. Composite Primary Key를 Content Identity로 사용하지 않는다.

---

## 19. JSON → SQLite 이행

한 번에 전환하지 않는다.

\`\`\`
현재 JSON
   ↓
Repository 추상화
   ↓
정규화된 Model
   ↓
검증
   ↓
SQLite Backend
   ↓
Legacy JSON 제거
\`\`\`

JSON과 SQLite를 동시에 서로 다른 권위 저장소로 장기간 운영하지 않는다.

---

## 20. Validation

Validation은 최소 4단계로 구성한다.

\`\`\`
Resource Validation
Content Validation
Runtime/Build Validation
Release Validation
\`\`\`

주요 검사:

\`\`\`
Missing Resource
Broken Reference
Duplicate ID
Invalid Value
Circular Dependency
Deprecated Reference
Unsupported Version
Unused Resource
Invalid Map
Invalid Visual Asset
\`\`\`

ERROR와 WARNING을 분리한다.

---

## 21. Dependency Graph

기본 방향:

\`\`\`
Source Resource
      ↓
Visual Asset
      ↓
Content Object
      ↓
Map Instance
      ↓
Runtime
\`\`\`

반대 방향 조회도 지원한다.

순환 참조는 Validator가 탐지한다.

---

## 22. Revision / History

Stable ID와 Revision을 분리한다.

\`\`\`
Object ID = 동일 객체의 정체성
Revision = 해당 객체의 특정 변경 버전
\`\`\`

Release된 데이터는 원칙적으로 수정하지 않고 새로운 Revision을 만든다.

삭제된 ID는 재사용하지 않는다.

---

## 23. Transaction / Undo / Recovery

관련 변경은 Transaction으로 묶을 수 있어야 한다.

\`\`\`
Edit
 ↓
Validate
 ↓
Commit
\`\`\`

실패 시 Rollback한다.

Editor Undo/Redo도 Model 변경 단위로 처리한다.

대규모 Batch Edit은 Preview 후 하나의 Transaction으로 Commit한다.

---

## 24. Diff / Impact

중요한 변경에는 다음 기능을 제공한다.

\`\`\`
Before / After Diff
Dependency View
Impact Preview
Revision Compare
\`\`\`

변경 전에 영향 범위를 확인할 수 있도록 한다.

---

## 25. Release

Release는 단순한 파일 복사가 아니다.

\`\`\`
Content Revision
+
Resource Revision
+
Build Configuration
+
Engine Version
+
Importer Version
+
Protocol Version
+
Hashes
      ↓
Release Manifest
      ↓
Runtime Package
\`\`\`

Build 결과는 Source와 분리한다.

---

## 26. Security / Authority

Authoring DB는 제작용 데이터다.

Client에 들어가는 데이터는 신뢰 경계 밖에 둔다.

온라인 게임의 권위 데이터는 Server가 보유한다.

Release Package는 필요에 따라 Manifest와 Hash/Signature로 무결성을 검증한다.

암호화만으로 치팅을 해결하지 않는다.

---

## 27. Save / Player Data

Content DB와 Player Data를 분리한다.

\`\`\`
Content
Player Data
Match Data
Replay Data
Analytics
\`\`\`

는 서로 다른 책임을 갖는다.

---

## 28. Localization

Content의 Stable ID와 표시 문자열을 분리한다.

\`\`\`
Object ID
    ↓
Display Name Key
    ↓
Localization
\`\`\`

언어별 문자열이 Object Identity가 되지 않는다.

---

## 29. Analytics

Analytics는 Content DB나 Replay의 권위 저장소가 아니다.

\`\`\`
Replay / Match Events
        ↓
Analytics Pipeline
\`\`\`

으로 별도 처리한다.

---

## 30. Backup / Recovery

Snapshot은 최소 다음을 함께 보존할 수 있어야 한다.

\`\`\`
Content DB
Source Resources
Schema Version
Content Revision
Build Manifest
Critical Metadata
\`\`\`

Archive와 Backup은 별도 개념으로 유지한다.

---

# 31. 개발 구현 범위

## Phase 0 — 구조 기준선

목적:
현재 프로젝트를 안전하게 재편하기 위한 기준선 확보.

범위:
- HEAD / Branch / Working Tree 기록
- 기존 Editor / JSON / Visual Asset 구조 조사
- 기존 변경 보호
- Migration 대상 목록 작성

완료 조건:
- 기존 구조와 변경 상태가 문서화됨
- Legacy 데이터와 신규 구조의 경계가 명확함

## Phase 1 — 공통 Model / Repository 경계

목적:
Editor가 직접 파일을 관리하는 구조를 제거할 기반 마련.

범위:
- Stable ID 정책
- Definition Model
- Repository Interface
- Validation Interface
- Reference Scanner Interface
- Transaction 경계
- Revision 개념

구현하지 않음:
- SQLite 전체 이전
- Runtime 재작성
- Network
- Replay

## Phase 2 — Resource / Visual Asset 정규화

목적:
현재 Sprite/Asset 문제를 공통 Resource 구조로 통합.

범위:
- Resource Registry
- Source Resource ID
- Visual Asset Model
- Non-uniform Frame
- Multi-row Atlas
- Anchor
- Team Mask
- Thumbnail Service
- Animation Preview Service
- Dependency Graph

검증:
- Robot / Unit / Tower에서 동일 Visual Asset Resolver 사용
- Catalog에서 동일 Asset 선택 흐름 사용

## Phase 3 — Object / Robot / Unit / Tower 통합

목적:
세 Editor의 중복 데이터 구조를 공통 Object Model로 통합.

범위:
- Common Object
- Type-specific Properties
- Stats
- Visual Bindings
- Robot Editor migration
- Unit Editor migration
- Tower Editor migration
- 공통 Save / Load
- 공통 Validation

완료 조건:
- 세 Editor가 동일 Repository/Model을 사용
- 각 Editor가 독립 JSON schema를 만들지 않음

## Phase 4 — Skill / Effect / Technology / Map

목적:
게임 콘텐츠 모델을 확장 가능한 구조로 정리.

범위:
- Skill
- Effect
- Technology
- Modifier
- Map Definition
- Map Instance
- Requirement
- Target Rule
- Gameplay Event Binding

완료 조건:
- Definition과 Runtime State가 분리됨
- 계산 Rule과 Content Value가 분리됨

## Phase 5 — SQLite Backend

목적:
정규화된 Content Model을 안정적인 DB 저장소로 이전.

범위:
- SQLite Schema
- Repository Backend
- Migration Tool
- Transaction
- Reference Integrity
- Revision
- Snapshot
- Backup / Recovery

전제:
Phase 1~4의 Model/Repository 경계가 안정적으로 검증된 후 진행한다.

## Phase 6 — Runtime Simulation

목적:
Content Definition을 실제 게임 실행 구조와 분리 연결.

범위:
- Definition → Instance
- Runtime State
- Command
- Event
- Tick
- Simulation
- Modifier
- Effect Lifecycle
- State Machine

## Phase 7 — Network Authority

목적:
온라인 실행을 고려한 권위 구조 확립.

범위:
- Client Command
- Server Validation
- Server Simulation
- State Synchronization
- Resync
- Protocol Version

## Phase 8 — Replay

목적:
게임 결과를 재현하고 디버깅할 수 있는 기반 확립.

범위:
- Replay Schema
- Initial State
- Command/Event Stream
- Seed
- Content/Map Revision
- Checkpoint
- State Hash
- Seek
- Pause / Step
- Speed Control
- Replay Validation

## Phase 9 — Release / Build / Recovery

목적:
제작 데이터와 실제 배포물을 안전하게 분리.

범위:
- Build Manifest
- Content Revision
- Resource Revision
- Hash
- Package Validation
- Release Lock
- Archive
- Rollback
- Deterministic Build 검증

---

# 32. 구현하지 않는 범위

현재 계획에서는 다음을 구현 대상으로 확정하지 않는다.

- 완전한 Modding 시스템
- 범용 Script Language
- 범용 Visual Node Editor
- 복잡한 Multiplayer Matchmaking
- 대규모 Live Service 운영 시스템
- A/B Test 플랫폼
- Analytics Dashboard
- 외부 Asset 자동 수집 시스템
- 자동 Asset 삭제
- Production 보안 시스템 전체
- 모든 플랫폼별 최적화

필요성이 확인될 때 별도 결정한다.

---

# 33. 이행 원칙

1. 기존 데이터를 먼저 읽고 이해한다.
2. 기존 Working Tree 변경을 보호한다.
3. 신규 Model을 먼저 만들고 Editor를 이동한다.
4. 한 번에 하나의 데이터 경계를 변경한다.
5. Migration 전후 Diff를 확인한다.
6. Legacy와 New Source of Truth를 장기간 병렬 운영하지 않는다.
7. 기존 Asset을 최대한 재사용한다.
8. 성공한 단계에서 자동으로 다음 단계로 넘어가지 않는다.
9. 각 단계마다 최소 검증 후 판정한다.
10. 실패하면 다음 단계로 진행하지 않는다.

---

# 34. 단계별 검증 상태

각 Phase는 다음 기준으로 판정한다.

\`\`\`
CODE VERIFIED
BUILD VERIFIED
EDITOR VERIFIED
PIE VERIFIED
NOT VERIFIED
\`\`\`

자동화 테스트 PASS는 PIE VERIFIED로 간주하지 않는다.

---

# 35. 최종 목표 구조 요약

\`\`\`
                    ┌───────────────┐
                    │ Source        │
                    │ Resources     │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │ Resource      │
                    │ Registry      │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │ Visual Asset  │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │ Content       │
                    │ Object/Skill  │
                    │ Map/Tech      │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │ Game Rules    │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │ Runtime       │
                    │ Command/Event │
                    │ State         │
                    └───────┬───────┘
                       ┌────┴────┐
                       ↓         ↓
                 ┌─────────┐ ┌─────────┐
                 │ Network │ │ Replay  │
                 └─────────┘ └─────────┘
                       │         │
                       └────┬────┘
                            ↓
                    ┌───────────────┐
                    │ Release       │
                    │ Revision      │
                    │ Manifest      │
                    └───────────────┘
\`\`\`

Editor는 전체 구조를 직접 소유하지 않고 다음 공통 계층을 통해 접근한다.

\`\`\`
Content Editor
Catalog
Robot Editor
Unit Editor
Tower Editor
       ↓
Editor Context / Services
       ↓
Repository / Model / Validator
       ↓
Persistence
\`\`\`

---

# 36. 성공 기준

이 재편의 성공은 SQLite로 바꾸는 것 자체가 아니다.

다음 조건을 만족하면 구조 재편의 핵심 목적이 달성된 것으로 판정한다.

- Resource와 Content가 분리된다.
- Visual Asset과 Gameplay Definition이 분리된다.
- Robot / Unit / Tower가 공통 Content Model을 사용한다.
- Map Definition과 Runtime Instance가 분리된다.
- Content Value와 Game Rule이 분리된다.
- Runtime State가 Content DB에 섞이지 않는다.
- Command / Event / State가 분리된다.
- Replay가 Content/Build/Map Revision을 기준으로 재현될 수 있다.
- Editor가 직접 JSON/DB 구조를 소유하지 않는다.
- Resource Dependency를 추적할 수 있다.
- 변경 전 Impact를 확인할 수 있다.
- Revision과 Snapshot으로 과거 상태를 보존할 수 있다.
- Release가 재현 가능한 Content/Resource Revision을 가진다.
- 기존 기능을 무너뜨리지 않고 단계적으로 이행할 수 있다.

---

# 37. 현재 판정

STATUS: PLAN DEFINED

목적:
MENOS의 장기적인 Content / Resource / Editor / Runtime / Replay 구조를 재편하기 위한 구현 범위와 목표 구조 정의.

범위:
구조와 개발계획 수립까지.

변경:
본 계획 수립을 위해 기존 코드 및 데이터는 수정하지 않는다.

검증:
EDITOR / BUILD / PIE는 아직 수행하지 않는다.

미확인:
각 Phase의 실제 구현 난이도와 현재 코드에서 필요한 정확한 Migration 작업량은 별도 조사 대상이다.

OUT OF SCOPE:
본 문서 작성만으로 실제 코드 Migration을 시작하지 않는다.

현실성 판단:
TECHNICALLY POSSIBLE
PRACTICALLY FEASIBLE
RECOMMENDED
BUSINESS VIABLE은 현재 단계에서 판단하지 않음.


# 38. Master 승인 — Object Composition 구조

2026-10-05 Master 승인.

다음 구조를 MENOS Content Model의 Canon으로 채택한다.

```text
Object
 ├─ Robot
 ├─ Unit
 ├─ Tower
 └─ Enemy

Skill
Effect
Item
Technology
Map
Visual Asset
```

Object의 공통 기능은 Composition 기반 Component/Property 구조로 구성한다.
Robot / Unit / Tower / Enemy를 거대한 공통 테이블의 모든 필드를 공유하는 상속 구조로 만들지 않는다.

공통 기능과 타입별 기능의 책임을 분리하며, 사용하지 않는 타입의 속성을 NULL 필드로 무분별하게 확장하지 않는다.

이 결정은 이후 Model / Repository / SQLite Schema / Editor 통합 / Runtime Definition 설계의 기준으로 사용한다.

PROPOSAL이었던 Composition 기반 Object 구조를 Master 승인에 따라 CANON으로 승격한다.
