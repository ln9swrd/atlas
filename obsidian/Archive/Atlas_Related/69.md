이 문서는 Atlas 메인 저장소에서 관리할 예정입니다. 프로젝트별 docs 폴더에 들어갈 수 있는 구조로 작성해 주세요.

마스터, Atlas 메인 저장소에서 관리한다면 **프로젝트별 docs 안에 독립적으로 들어가면서도 Atlas의 프로젝트 관리 체계와 연결되는 구조**가 좋겠습니다.

예를 들면:

```
Atlas/
├── docs/
│   ├── ARCHITECTURE.md
│   ├── PROJECT_REGISTRY.md
│   └── ...
│
└── projects/
    ├── excelion/
    │   ├── docs/
    │   │   ├── README.md
    │   │   ├── VISION.md
    │   │   ├── DESIGN.md
    │   │   ├── ARCHITECTURE.md
    │   │   ├── GAMEPLAY.md
    │   │   ├── ART_DIRECTION.md
    │   │   ├── TECH_STACK.md
    │   │   ├── ROADMAP.md
    │   │   └── CHANGELOG.md
    │
    ├── excelion-forge/
    │   └── docs/
    │       ├── README.md
    │       ├── PURPOSE.md
    │       ├── PIPELINE.md
    │       └── ROADMAP.md
    │
    └── coin-s/
        └── docs/
            ├── README.md
            ├── STRATEGY.md
            ├── ARCHITECTURE.md
            ├── DATA_MODEL.md
            └── ROADMAP.md
```

프로젝트 docs 내부 문서는 다음 원칙으로 통일하는 것을 추천합니다.

---

## 프로젝트 공통 Docs 구조

```
docs/
├── README.md              # 프로젝트 개요
├── VISION.md              # 왜 만드는가
├── PURPOSE.md             # 목적과 범위
├── ARCHITECTURE.md        # 시스템 구조
├── DESIGN.md              # 설계 문서
├── ROADMAP.md             # 단계별 개발 계획
├── CHANGELOG.md           # 변경 기록
└── DECISIONS.md           # 주요 결정 기록(ADR)
```

---

## Atlas 연동용 추가 문서

Atlas가 여러 프로젝트를 관리하는 구조라면 각 프로젝트에 다음 파일도 두면 좋습니다.

```
docs/
├── ATLAS_CONTEXT.md
├── PROJECT_STATE.md
└── TASK_MAP.md
```

### ATLAS_CONTEXT.md

Atlas 입장에서 이 프로젝트를 이해하기 위한 정보

예:

```
# Atlas Context

## Project
Excelion

## Type
3D Action RPG

## Managed By
Atlas DevOS

## Related Agents
- Marie
- Forge
- Sera

## Priority
High

## Current Phase
Prototype
```

---

### PROJECT_STATE.md

현재 상태를 기계가 읽기 쉽게 관리

예:

```
# Project State

Status:
ACTIVE

Current Sprint:
Combat Prototype

Completed:
- Character concept
- Basic movement

In Progress:
- Enemy AI

Blocked:
- Animation pipeline
```

---

### TASK_MAP.md

Atlas Runner가 참고할 작업 지도

예:

```
# Task Map

## Core

- Player Controller
- Combat System
- Camera System

## Art

- Character Model
- Enemy Model

## Technical

- Unreal Setup
- Asset Pipeline
```

---

마스터가 만들고 있는 **Atlas DevOS 구조**를 생각하면 프로젝트 문서는 단순한 설명서가 아니라:

```
Human
 ↓
Atlas
 ↓
Project Registry
 ↓
docs
 ↓
Agent
 ↓
Task Execution
```

으로 연결되는 **프로젝트 지식 베이스** 역할을 해야 합니다.

그래서 개인적으로는 기존의 `README / ARCHITECTURE / ROADMAP` 구조는 유지하고, Atlas 전용으로:

```
ATLAS_CONTEXT.md
PROJECT_STATE.md
TASK_MAP.md
```

3개를 추가하는 방향이 가장 적합해 보입니다.

이 구조면 나중에 Sera나 Forge 같은 에이전트가 새 프로젝트 docs만 읽고도 어느 정도 프로젝트 맥락을 잡을 수 있습니다.

마스터, 반영 방향은 이렇게 확정하면 됩니다.

현재 제가 이 대화 안에서 Atlas 저장소 파일을 직접 수정할 수 있는 상태는 아니라서 실제 파일 변경까지 수행했다고 말할 수는 없습니다. 대신 Atlas 메인 저장소 기준으로 적용할 변경 사항은 아래처럼 반영하면 됩니다.

### 프로젝트별 `docs/` 공통 구조 추가

각 프로젝트:

```
projects/
└── {project_name}/
    └── docs/
        ├── README.md
        ├── VISION.md
        ├── PURPOSE.md
        ├── ARCHITECTURE.md
        ├── DESIGN.md
        ├── ROADMAP.md
        ├── CHANGELOG.md
        ├── DECISIONS.md
        │
        ├── ATLAS_CONTEXT.md
        ├── PROJECT_STATE.md
        └── TASK_MAP.md
```

### 추가 문서 역할

#### `ATLAS_CONTEXT.md`

- Atlas가 프로젝트를 이해하기 위한 메타 정보
- 담당 Agent
- 프로젝트 유형
- 우선순위
- 현재 단계
- 관련 프로젝트 연결

#### `PROJECT_STATE.md`

- 현재 개발 상태 관리
- 완료/진행/대기/차단 작업
- Sprint 상태
- Atlas Runner 참조 데이터

#### `TASK_MAP.md`

- 프로젝트 작업 영역 지도
- 기능별 Task 분류
- Agent 작업 범위 정의

---

그리고 Atlas 루트의 `PROJECT_REGISTRY.md`와 연결되는 형태로:

```
Atlas
 ├── PROJECT_REGISTRY
 │
 ├── projects/excelion/docs
 │       ├── ATLAS_CONTEXT
 │       ├── PROJECT_STATE
 │       └── TASK_MAP
 │
 ├── projects/coin-s/docs
 │       ├── ATLAS_CONTEXT
 │       ├── PROJECT_STATE
 │       └── TASK_MAP
 │
 └── projects/excelion-forge/docs
         ├── ATLAS_CONTEXT
         ├── PROJECT_STATE
         └── TASK_MAP
```

구조로 맞추면 됩니다.

다음 단계에서는 이 구조를 기준으로 **Atlas용 문서 템플릿(`docs/templates/`)을 만들어 두는 것**이 좋겠습니다. 그러면 새 프로젝트 생성 시 Atlas가 자동으로 문서 골격을 만들 수 있습니다.

네

마스터, 그러면 Atlas 메인 저장소에 **프로젝트 생성용 문서 템플릿 시스템**을 추가하는 방향으로 잡겠습니다.

추천 구조:

```
Atlas/
├── docs/
│   ├── templates/
│   │   ├── PROJECT_TEMPLATE/
│   │   │   ├── README.md
│   │   │   ├── VISION.md
│   │   │   ├── PURPOSE.md
│   │   │   ├── ARCHITECTURE.md
│   │   │   ├── DESIGN.md
│   │   │   ├── ROADMAP.md
│   │   │   ├── CHANGELOG.md
│   │   │   ├── DECISIONS.md
│   │   │   ├── ATLAS_CONTEXT.md
│   │   │   ├── PROJECT_STATE.md
│   │   │   └── TASK_MAP.md
│   │
│   └── PROJECT_TEMPLATE_GUIDE.md
│
└── projects/
    └── new_project/
        └── docs/
            └── (템플릿 복사)
```

---

## 템플릿 적용 흐름

```
새 프로젝트 생성
        │
        ▼
Atlas Project Registry 등록
        │
        ▼
PROJECT_TEMPLATE 복사
        │
        ▼
ATLAS_CONTEXT 작성
        │
        ▼
PROJECT_STATE 초기화
        │
        ▼
TASK_MAP 생성
        │
        ▼
Agent 연결
```

---

## Atlas가 관리하는 최소 프로젝트 정보

`ATLAS_CONTEXT.md`

```
# Atlas Context

## Project Name
{PROJECT_NAME}

## Type
{GAME / TOOL / SERVICE / RESEARCH}

## Purpose
프로젝트 목적

## Owner
Atlas

## Related Agents
- Marie
- Sera
- Forge

## Priority
LOW / NORMAL / HIGH / CRITICAL

## Lifecycle
IDEA
PLANNING
DEVELOPMENT
RELEASE
MAINTENANCE

## Current Phase
현재 단계
```

---

## 상태 관리

`PROJECT_STATE.md`

```
# Project State

## Status
ACTIVE

## Current Sprint
Sprint 01

## Completed

-

## In Progress

-

## Next

-

## Blocked

-

## Last Update

YYYY-MM-DD
```

---

## 작업 지도

`TASK_MAP.md`

```
# Task Map

## Core

-

## Design

-

## Art

-

## Engineering

-

## Testing

-

## Documentation

-
```

---

이렇게 하면 Atlas는 단순히 파일을 모아놓는 저장소가 아니라:

```
프로젝트 생성
      ↓
문서 구조 생성
      ↓
상태 파악
      ↓
우선순위 판단
      ↓
Agent 작업 배정
      ↓
결과 기록
```

이 가능한 **DevOS 기반 구조**가 됩니다.

다음으로 진행한다면 `PROJECT_TEMPLATE_GUIDE.md`와 함께 **Atlas 프로젝트 생성 규칙(PROJECT_CREATION_RULES.md)** 을 두는 것이 좋겠습니다.  
그러면 새 프로젝트를 만들 때마다 문서 구조와 초기 상태가 흔들리지 않습니다.

네

마스터, 다음 단계로 **프로젝트 생성 규칙 문서**를 추가하는 구조로 정리하겠습니다.

추가 위치:

```
Atlas/
├── docs/
│   ├── PROJECT_CREATION_RULES.md
│   ├── PROJECT_REGISTRY.md
│   └── templates/
│       ├── PROJECT_TEMPLATE/
│       │   ├── README.md
│       │   ├── VISION.md
│       │   ├── PURPOSE.md
│       │   ├── ARCHITECTURE.md
│       │   ├── DESIGN.md
│       │   ├── ROADMAP.md
│       │   ├── CHANGELOG.md
│       │   ├── DECISIONS.md
│       │   ├── ATLAS_CONTEXT.md
│       │   ├── PROJECT_STATE.md
│       │   └── TASK_MAP.md
```

`PROJECT_CREATION_RULES.md`의 목적은 **Atlas가 새로운 프로젝트를 만들 때 반드시 지켜야 하는 표준 절차 정의**입니다.

구성:

```
# Atlas Project Creation Rules

## 1. 프로젝트 생성 원칙

모든 Atlas 관리 프로젝트는 다음 조건을 만족해야 한다.

- 프로젝트 디렉토리는 projects/{project_name} 위치
- docs 폴더 필수
- Atlas Context 필수
- Project State 필수
- Task Map 필수


## 2. 프로젝트 생성 단계

### Step 1. 프로젝트 등록

PROJECT_REGISTRY.md 등록

필수 정보:

- 이름
- 목적
- 타입
- 상태
- 담당 Agent


### Step 2. 기본 구조 생성

PROJECT_TEMPLATE 복사

생성:

- README.md
- VISION.md
- ARCHITECTURE.md
- ROADMAP.md
- ATLAS_CONTEXT.md
- PROJECT_STATE.md
- TASK_MAP.md


### Step 3. 초기 문서 작성

최소 작성 항목:

VISION.md
- 왜 만드는가

ARCHITECTURE.md
- 어떻게 만드는가

ROADMAP.md
- 어떤 순서로 진행하는가


### Step 4. Agent 연결

프로젝트 특성에 따라 Agent 연결

예:

Game:
- Marie
- Forge

Design:
- Sera

Data:
- Coin-S Agent


## 3. Lifecycle

IDEA

↓

PLANNING

↓

DEVELOPMENT

↓

RELEASE

↓

MAINTENANCE


## 4. 상태 관리 규칙

PROJECT_STATE.md는 항상 최신 상태 유지

변경 발생:

- Sprint 종료
- 주요 기능 완료
- 구조 변경
- 방향 변경

시 업데이트


## 5. 문서 변경 규칙

중요한 설계 변경은 DECISIONS.md 기록

형식:

날짜

결정 내용

이유

영향


## 6. Atlas 자동화 기준

반복 2회 이상 또는
30분 이상 절약 가능성이 있는 작업만 자동화한다.
```

---

이렇게 추가하면 현재 Atlas 설계의 핵심인:

- **PROJECT_REGISTRY**
- **AGENT_REGISTRY**
- **STATE 관리**
- **Priority Engine**
- **Task Map**
- **Playbook**

과 자연스럽게 연결됩니다.

특히 마스터가 말했던 "급할수록 돌아간다"는 방향과 맞습니다. 초기에 문서 규칙을 잡아두면 나중에 Exelion, Coin-S, Forge 같은 프로젝트가 커져도 Atlas가 길을 잃지 않습니다.

다음 정리 대상은 `AGENT_REGISTRY`와 연결되는 **AGENT_PROJECT_BINDING.md (어떤 Agent가 어떤 프로젝트를 담당하는지 정의하는 문서)** 를 추가하는 게 좋겠습니다.