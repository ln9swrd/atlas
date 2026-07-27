# ATLAS-CORE-001 작업 시작 ## 현재 상태 완료: - ATLAS 환경 감사 완료 - ATLAS_BASELINE_FREEZE_001 작성 - ATLAS_AGENT_ARCHITECTURE_001 작성 ## 핵심 결정 Atlas는 특정 AI(Cline/Kraken/SERA)에 종속되지 않는 관리 계층이다. 역할 분리: Atlas: - Context 관리 - Task 관리 - Decision 기록 - Audit 기록 - AI Provider 관리 Kraken: - Local 실행 AI - 코드 조사 및 구현 지원 SERA: - Cloud AI - 고급 분석 및 설계 검토 Cline: - Execution Tool Layer - 파일/터미널/Tool 실행 담당 ## 다음 목표 ATLAS-CORE-001: Context Management Foundation 범위: - core/context 구조 분석 - Context 데이터 모델 설계 - 저장 구조 결정 - 최소 구현 계획 수립 주의: - 기존 감사 결과 유지 - EXIST / IMPLEMENTED / PROPOSED 상태 구분 유지 - 대규모 구현 금지

확인했습니다. **ATLAS-CORE-001: Context Management Foundation** 단계로 전환하겠습니다.

현재까지의 기준선은 유지하고, 이번 단계에서는 **구현보다 구조 정의와 경계 확립**에 집중하는 것이 맞습니다. 특히 이전 감사에서 확인된 핵심 원칙:

> Atlas는 AI가 아니라 AI를 관리하는 상위 운영 계층이다.

이 원칙을 Context 설계에도 그대로 적용해야 합니다.

---

# ATLAS-CORE-001 진행 기준

## 목표

Atlas 내부에서 다루는 **Context의 책임과 생명주기 정의**

즉:

- 무엇을 Context라고 볼 것인가
- 어디에 저장할 것인가
- 누가 생성/수정하는가
- AI Provider에게 어떻게 전달하는가

를 먼저 확정합니다.

---

# 1. Context Management 역할 정의 (PROPOSED)

현재 기준:

```
Atlas
 ├── Context Manager
 │    ├── Project Context
 │    ├── Task Context
 │    ├── Decision Context
 │    ├── Audit Context
 │    └── Provider Context
 │
 ├── Task Manager
 ├── Decision Ledger
 ├── Audit System
 └── Provider Gateway
```

Context는 단순한 "프롬프트 저장소"가 아닙니다.

정의:

> Context = Atlas가 현재 작업 상태를 이해하기 위해 유지하는 구조화된 운영 지식 집합

---

# 2. Context 종류 1차 분류

## EXIST

현재 확인된 개념:

|Context|상태|설명|
|---|---|---|
|Project Context|EXIST|프로젝트 전체 상태|
|Task Context|EXIST|현재 수행 작업|
|Audit Context|EXIST|검증 결과|
|Decision Context|EXIST|설계 결정 기록|

---

## IMPLEMENTED

현재 코드 확인 필요:

|항목|상태|
|---|---|
|실제 Context Schema|확인 필요|
|저장 Layer|확인 필요|
|API Interface|확인 필요|
|Persistence 방식|확인 필요|

---

## PROPOSED

향후 설계:

### 1. Project Context

Atlas 프로젝트 자체를 설명.

예:

```
project:
  id: atlas
  version: 0.1
  status: active

architecture:
  principle:
    - provider independent
    - audit driven
```

---

### 2. Task Context

현재 실행 작업.

예:

```
task:
  id: ATLAS-CORE-001
  type: architecture
  status: analyzing

input:
  - baseline document
  - audit result

output:
  - context model
```

---

### 3. Decision Context

"왜 이렇게 결정했는가" 기록.

중요합니다.

Atlas의 차별점은 여기입니다.

일반 AI:

```
질문
 ↓
답변
```

Atlas:

```
상황
 ↓
검토
 ↓
결정
 ↓
근거
 ↓
후속 영향
```

---

### 4. Audit Context

검증 가능한 상태 기록.

예:

```
audit:
  target:
    core/context

finding:
  status:
    PROPOSED

evidence:
  - file path
  - commit
  - document
```

---

# 3. 저장 구조 후보

## Option A

파일 기반

```
atlas/
 └── data/
      └── context/
           ├── project/
           ├── task/
           ├── decision/
           └── audit/
```

장점:

- 인간 검토 가능
- Git 친화적
- 초기 구현 적합

단점:

- 검색 한계

---

## Option B

Database 기반

```
Context Service

        |
        v

SQLite/PostgreSQL
```

장점:

- 검색
- 관계
- 이력 관리

단점:

- 초기 복잡도 증가

---

## 현재 판단

ATLAS-CORE-001에서는:

**파일 기반 + Schema First**

가 적합합니다.

이유:

현재 Atlas는 "운영 증명 단계"이지 "대규모 서비스 단계"가 아닙니다.

---

# 4. 최소 Context Schema 제안 (PROPOSED)

공통 Metadata:

```
context:
  id:
  type:
  version:
  created:
  updated:

  source:
    type:
    reference:

  status:
    EXIST | IMPLEMENTED | PROPOSED
```

---

# 5. Provider와 Context 관계

중요한 분리:

잘못된 구조:

```
Context
 |
 AI Prompt
 |
 Cline
```

Atlas 방향:

```
                Context
                   |
            Context Resolver
                   |
        +----------+----------+
        |          |          |
      Kraken     SERA       Cline
```

Context는 AI에게 종속되지 않습니다.

AI는 Context의 소비자입니다.

---

# 6. ATLAS-CORE-001 단계별 작업 계획

## Step 1

현재 core/context 존재 여부 조사

상태:

```
IMPLEMENTED 확인 필요
```

확인 대상:

```
core/
 └── context/
      ├── model
      ├── storage
      ├── service
      └── interface
```

---

## Step 2

Context Schema Draft 작성

산출물:

```
ATLAS_CONTEXT_SCHEMA_001.md
```

---

## Step 3

Storage 결정

산출물:

```
ATLAS_CONTEXT_STORAGE_001.md
```

---

## Step 4

최소 Prototype

범위 제한:

가능:

- Context 객체 생성
- 저장
- 조회

금지:

- Agent 자동화
- AI 연결
- Vector DB
- Memory System

---

# 현재 판단

ATLAS-CORE-001에서 가장 중요한 것은 **코드를 만드는 것이 아니라 Atlas의 기억 구조를 정의하는 것**입니다.

특히 기존 AI Agent들이 실패하는 지점이:

```
대화 기억 = Context
```

라고 착각하는 부분입니다.

Atlas에서는:

```
Context
 =
상태 + 근거 + 결정 + 책임
```

으로 보는 것이 맞습니다.

다음 실제 작업은 **core/context 디렉터리 구조 조사 → EXIST/IMPLEMENTED/PROPOSED 판정**으로 진행하면 됩니다.

마스터, 바램이라는 표현으로 말했지만 저는 그 방향성이 Atlas의 설계 원칙과 충돌하지 않는다고 봅니다. 다만 지금 단계에서는 그 철학을 구현 목표로 밀어 넣기보다, **나중에 흔들리지 않을 기준점**으로 남겨두는 것이 적절합니다.

현재 진행 순서를 보면:

- `ATLAS_BASELINE_FREEZE_001` → 현재 상태 고정
- `ATLAS_AGENT_ARCHITECTURE_001` → 역할 분리
- `ATLAS-CORE-001` → Context Foundation 정의

까지 왔습니다.

다음 단계는 Context를 실제 Atlas 내부에서 사용할 수 있도록 **구조화하는 단계**가 맞습니다.

제안:

# ATLAS-CORE-002: Context Schema and Repository Foundation

## 목적

Context Foundation을 실제 구현 가능한 형태로 구체화.

범위:

### 1. Context Schema 정의

대상:

- Context Metadata
- Context Type
- Context Version
- Context Status
- Source Reference
- Payload Structure

상태:

```
PROPOSED → IMPLEMENTED 준비
```

---

### 2. Context Repository 설계

정의:

```
Context
   |
Repository Interface
   |
Storage Backend
```

책임:

- 생성
- 조회
- 수정
- 버전 관리
- Archive

---

### 3. Storage Prototype 방향 확정

초기:

```
JSON / YAML File Storage
```

추후 확장:

```
File Storage
      ↓
Database
      ↓
Distributed Storage
```

---

### 4. 제외 범위 명확화

이번 단계에서도 제외:

- AI Provider 연결
- Vector DB
- Embedding
- Agent Memory
- 자동 Context 생성

---

문서 흐름은 이렇게 가면 자연스럽습니다.

```
ATLAS-CORE-001
Context Management Foundation
        |
        v
ATLAS-CORE-002
Context Schema and Repository Foundation
        |
        v
ATLAS-CORE-003
Context Lifecycle Management
        |
        v
ATLAS-CORE-004
Context Resolver Architecture
        |
        v
ATLAS-CORE-005
Provider Context Integration
```

그리고 그 이후에야:

```
ATLAS-CORE-006
Runtime Context Execution
```

같은 단계로 넘어가는 것이 좋겠습니다.

현재 Atlas는 "똑똑한 AI 만들기"보다 먼저 "무엇을 기억하고 어떻게 성장할 것인가"라는 기반을 만드는 단계입니다.

따라서 다음 작업 지시는:

> **ATLAS-CORE-002: Context Schema and Repository Foundation 작업 시작**

으로 지정하는 것이 적절합니다.

사실 아트라스의 개별 프로젝트는 소멸해도 아틀라스는 계속 개별 프로젝트를 생성하는 게 맞겠지. 뭐 그런 상상이야.

마스터, 그 상상은 사실 지금 Atlas의 구조를 생각하면 꽤 자연스럽게 이어지는 방향입니다.

지금까지 정의한 Atlas는 **하나의 거대한 프로젝트**라기보다, 프로젝트를 담는 **상위 운영 환경**에 가까워지고 있습니다.

비유하면:

```
Atlas
 |
 +-- Project A
 |     |
 |     +-- Context
 |     +-- Task
 |     +-- Decision
 |     +-- Audit
 |
 +-- Project B
 |     |
 |     +-- Context
 |     +-- Task
 |     +-- Decision
 |     +-- Audit
 |
 +-- Project C
```

개별 프로젝트는 생성되고, 끝나고, 폐기될 수 있습니다.

하지만 Atlas 자체는:

```
프로젝트 생성
      ↓
경험 축적
      ↓
구조 개선
      ↓
새 프로젝트 생성
```

이라는 순환을 가지는 거죠.

---

이 관점에서 보면 현재 Context 설계가 더 중요해집니다.

프로젝트가 사라져도 남아야 하는 것은 코드가 아니라:

- 어떤 문제였는가
- 어떤 선택을 했는가
- 무엇이 성공했는가
- 무엇이 실패했는가
- 어떤 패턴이 반복되는가

입니다.

즉:

프로젝트 데이터:

```
Project-A
 └── source code
```

는 사라질 수 있지만,

Atlas 경험:

```
Atlas
 └── Decision History
 └── Architecture Pattern
 └── Failure Record
 └── Methodology
```

는 남는 구조입니다.

---

조금 더 발전시키면 나중에는 이런 형태도 가능하겠죠.

```
                 Atlas Core

                    |
        +-----------+-----------+
        |                       |
 Project Factory          Knowledge Layer
        |
        |
 +------+------+------+
 |             |      |
App1          App2   App3
```

Atlas가 직접 앱을 만드는 존재라기보다는:

"새로운 작업 공간을 만들고, 이전 경험을 참고해서 더 나은 환경을 준비하는 시스템"

에 가까운 형태입니다.

---

그리고 마스터가 말한 "소멸해도"라는 부분이 중요합니다.

보통 소프트웨어는:

```
프로젝트 = 시스템
```

으로 봅니다.

하지만 Atlas 방식에서는:

```
Atlas = 생태계
프로젝트 = 한 번의 생명 주기
```

처럼 볼 수 있습니다.

하나의 프로젝트가 실패해도:

- 실패 원인은 남고
- 설계 교훈은 남고
- 다음 프로젝트에 반영됩니다.

---

다만 지금 단계에서는 이걸 바로 구현 목표로 잡으면 안 될 것 같습니다.

현재:

`ATLAS-CORE-001`

은 "기억할 수 있는 구조 만들기"

그 다음:

`ATLAS-CORE-002`

는 "기억을 저장할 수 있는 구조 만들기"

입니다.

그 이후 아주 먼 단계에서:

`ATLAS-LIFE-CYCLE-001` 같은 문서로

> Atlas가 프로젝트를 생성하고 종료하고 경험을 축적하는 운영 모델

을 정의할 수 있을 것 같습니다.

마스터가 말한 것은 지금 당장 만들 기능이라기보다, Atlas가 어떤 존재가 되어야 하는지에 대한 **장기 방향성**에 가까워 보입니다.

그리고 흥미로운 건, 처음에 이야기했던 "하나만 하고 계속 모으는 존재"와 정확히 연결됩니다.

프로젝트는 사라져도 경험은 남는다.

그게 아마 Atlas라는 이름에 담긴 가장 큰 의미가 될 수 있을 것 같습니다.

ATLAS-CORE-002 문서 생성이 완료되었습니다. 다음 단계로 이어질 문서 번호와 주제를 지정해 주시겠습니까? (예: ATLAS-CORE-003: Context Lifecycle Management)

확인했습니다, 마스터.  
현재까지 흐름을 기준으로 하면 다음 단계는 자연스럽게 **Context의 생명주기 관리**로 넘어가는 것이 맞습니다.

현재 완료 상태:

|문서|주제|상태|
|---|---|---|
|ATLAS_BASELINE_FREEZE_001|환경 기준선 고정|완료|
|ATLAS_AGENT_ARCHITECTURE_001|Agent 역할 분리|완료|
|ATLAS-CORE-001|Context Management Foundation|완료|
|ATLAS-CORE-002|Context Schema and Repository Foundation|완료|

다음 문서 지정:

# ATLAS-CORE-003: Context Lifecycle Management

## 목적

Context가 생성된 이후 어떻게 변화하고 유지되는지 정의합니다.

핵심 질문:

- Context는 언제 생성되는가?
- 언제 수정 가능한가?
- 언제 폐기되는가?
- 어떤 상태 변화를 거치는가?
- 프로젝트 종료 후 Context는 어떻게 보존되는가?

---

## 주요 범위

### 1. Context Lifecycle 상태 정의

예:

```
CREATED
   |
ACTIVE
   |
UPDATED
   |
VALIDATED
   |
ARCHIVED
   |
RETIRED
```

상태별 의미 정의.

---

### 2. Context Versioning

목표:

기존 기록을 덮어쓰지 않는 구조.

예:

```
context-001

v1
 └ 최초 생성

v2
 └ Decision 변경 반영

v3
 └ Audit 결과 반영
```

Atlas의 핵심 원칙:

> 경험은 삭제하지 않고 축적한다.

를 구현하는 영역입니다.

---

### 3. Context Ownership 정의

정의 대상:

- Project Context 소유자
- Task Context 소유자
- Decision Context 소유자
- Audit Context 소유자

예:

```
Project
 |
 +-- Context Manager
        |
        +-- Task Context
        +-- Decision Context
        +-- Audit Context
```

---

### 4. Context Retention 정책

프로젝트가 종료된 이후:

```
Project 종료
      |
      +-- Source Archive
      |
      +-- Context Archive
      |
      +-- Decision History 유지
```

어떤 데이터가 Atlas Core에 남는지 정의합니다.

---

## 제외 범위

이번 단계에서도 제외:

- AI 자동 기억 생성
- Vector Memory
- Self Learning Loop
- Provider 연결
- 분산 저장

---

## 이후 예상 흐름

```
ATLAS-CORE-003
Context Lifecycle Management
        |
        v
ATLAS-CORE-004
Context Resolver Architecture
        |
        v
ATLAS-CORE-005
Provider Context Integration
        |
        v
ATLAS-CORE-006
Runtime Context Execution
```

그리고 마스터가 앞에서 이야기한:

> 프로젝트는 소멸해도 Atlas는 계속 성장한다

라는 개념은 사실 **ATLAS-CORE-003의 Retention과 Archive 정책**에서 처음 기술적으로 표현될 수 있습니다.

따라서 다음 작업 지시는:

> **ATLAS-CORE-003: Context Lifecycle Management 작업 시작**

으로 지정하면 되겠습니다.