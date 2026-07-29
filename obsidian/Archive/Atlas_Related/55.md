Atlas 메인 저장소에서 관리할 예정입니다. 프로젝트별 docs 폴더에 들어갈 수 있는 구조로 작성해 주세요.

마스터, Atlas 메인 저장소 기준이면 **프로젝트별 `docs/` 폴더는 프로젝트 문서의 표준 진입점**으로 잡는 게 좋겠습니다.

구조는 Atlas가 여러 프로젝트(Exelion, Coin-S, Exelion Forge 등)를 관리하는 **DevOS 역할**이므로, 각 프로젝트는 동일한 문서 규칙을 가져가고 Atlas는 전체 상태와 규칙만 관리하는 방향이 맞습니다.

추천 구조입니다.

```
Atlas/
├── README.md
├── ARCHITECTURE.md
├── ATLAS_CONSTITUTION.md
├── PROJECT_REGISTRY.md
├── AGENT_REGISTRY.md
├── ENVIRONMENT_REGISTRY.md
│
├── docs/
│   ├── atlas/
│   │   ├── VISION.md
│   │   ├── ROADMAP.md
│   │   ├── SYSTEM_DESIGN.md
│   │   ├── AGENT_SYSTEM.md
│   │   ├── STATE_MODEL.md
│   │   ├── EVENT_SYSTEM.md
│   │   └── ADR/
│   │       ├── ADR-001.md
│   │       └── ADR-002.md
│   │
│   └── projects/
│       ├── excelion/
│       │   ├── README.md
│       │   ├── VISION.md
│       │   ├── PROJECT_CHARTER.md
│       │   ├── GAME_DESIGN.md
│       │   ├── STORY.md
│       │   ├── WORLD_SETTING.md
│       │   ├── SYSTEM_DESIGN.md
│       │   ├── ART_DIRECTION.md
│       │   ├── TECH_DESIGN.md
│       │   ├── ROADMAP.md
│       │   ├── TASKS.md
│       │   └── CHANGELOG.md
│       │
│       ├── excelion-forge/
│       │   ├── README.md
│       │   ├── PURPOSE.md
│       │   ├── PIPELINE.md
│       │   ├── TOOL_DESIGN.md
│       │   ├── AUTOMATION.md
│       │   ├── ROADMAP.md
│       │   └── CHANGELOG.md
│       │
│       └── coin-s/
│           ├── README.md
│           ├── VISION.md
│           ├── ARCHITECTURE.md
│           ├── DATA_MODEL.md
│           ├── STRATEGY.md
│           ├── ANALYSIS_ENGINE.md
│           ├── ROADMAP.md
│           ├── CODING_RULES.md
│           └── CHANGELOG.md
│
├── projects/
│   ├── excelion/
│   ├── excelion-forge/
│   └── coin-s/
│
├── agents/
│   ├── marie/
│   ├── sera/
│   └── forge/
│
├── runtime/
│   ├── ATLAS_STATE.json
│   ├── atlas_events.jsonl
│   └── context/
│
└── scripts/
    ├── atlas_runner.py
    ├── state_manager.py
    └── registry_manager.py
```

그리고 각 프로젝트 내부는 실제 저장소에서는 이렇게 연결합니다.

```
projects/excelion/
│
├── src/
├── assets/
├── blender/
├── tests/
├── docs/
│   ├── README.md
│   ├── DESIGN.md
│   ├── DEVELOPMENT.md
│   └── NOTES.md
└── ...
```

즉:

- **Atlas/docs/projects/excelion/**
    - "프로젝트 관리 문서"
    - 기획, 방향성, 의사결정 기록
- **projects/excelion/docs/**
    - "개발자가 보는 실제 개발 문서"
    - 코드, 에셋, 구현 방법

으로 분리합니다.

---

제가 보기에는 Atlas 철학상 핵심은 이 부분입니다.

```
Atlas
 └─ 프로젝트를 관리한다
      └─ 프로젝트는 자기 문서를 가진다
            └─ AI Agent가 문서를 기준으로 작업한다
```

그래서 각 프로젝트마다 최소 필수 문서는 통일하는 것이 좋습니다.

### 프로젝트 공통 문서 템플릿

```
docs/

README.md
        프로젝트 소개

VISION.md
        왜 만드는가

PROJECT_CHARTER.md
        목표/범위/제약조건

ARCHITECTURE.md
        시스템 구조

ROADMAP.md
        단계별 개발 계획

TASKS.md
        현재 작업 목록

DECISION_LOG.md
        중요한 결정 기록

CHANGELOG.md
        변경 기록
```

이 구조면 Cline, Qwen3-Coder, Sera 같은 Agent가 문서를 읽고 "현재 프로젝트 상태"를 파악하기 쉬워집니다.

특히 마스터가 만들고 있는 **Atlas DevOS** 방향에서는 `PROJECT_CHARTER.md`, `TASKS.md`, `DECISION_LOG.md`가 매우 중요합니다.  
AI가 코드를 보는 것보다 먼저 "왜 이렇게 만들었는지"를 알아야 하기 때문입니다.

좋습니다, 마스터. 그러면 Atlas 메인 저장소 기준으로 **프로젝트 문서 템플릿 표준화** 방향으로 잡으면 됩니다.

다음 단계는 각 프로젝트의 `docs/` 폴더에 바로 넣을 수 있는 **공통 문서 템플릿 세트**를 만드는 것입니다.

추천 위치:

```
Atlas/
└── docs/
    └── templates/
        └── project/
            ├── README.md
            ├── VISION.md
            ├── PROJECT_CHARTER.md
            ├── ARCHITECTURE.md
            ├── ROADMAP.md
            ├── TASKS.md
            ├── DECISION_LOG.md
            ├── CHANGELOG.md
            └── AGENT_CONTEXT.md
```

각 프로젝트 생성 시:

```
projects/new-project/
└── docs/
    ├── README.md
    ├── VISION.md
    ├── PROJECT_CHARTER.md
    ├── ARCHITECTURE.md
    ├── ROADMAP.md
    ├── TASKS.md
    ├── DECISION_LOG.md
    ├── CHANGELOG.md
    └── AGENT_CONTEXT.md
```

형태로 복사합니다.

---

특히 `AGENT_CONTEXT.md`를 추가하는 것이 Atlas에는 중요합니다.

예:

```
# Agent Context

## Project Identity

프로젝트명:
목적:

## Current State

현재 버전:
완료된 기능:

## Development Rules

반드시 유지해야 하는 규칙:

## Known Issues

현재 문제:

## Next Priority

1.
2.
3.

## Forbidden Changes

변경하면 안 되는 부분:
```

이 문서는 Cline, Qwen3-Coder, Sera 같은 Agent가 작업 시작 전에 읽는 "작업 기억" 역할을 합니다.

---

Atlas 구조에서는:

- `VISION.md` → 인간의 방향성
- `PROJECT_CHARTER.md` → 프로젝트 계약서
- `ARCHITECTURE.md` → 기술 구조
- `TASKS.md` → 현재 행동
- `AGENT_CONTEXT.md` → AI 작업 기억
- `DECISION_LOG.md` → 과거 판단 근거

이렇게 역할을 나누면 됩니다.

다음 작업으로는 이 템플릿들을 실제 **Atlas 저장소용 Markdown 파일 형태**로 만들어 두면 됩니다.  
그대로 `Atlas/docs/templates/project/`에 넣을 수 있는 형태로 작성하면 됩니다.

-_-;; 아까 한 말 또 하네... 프로젝트가 달라져서 그러가바

아… 맞습니다, 마스터. 😅  
제가 방금 **이전 단계의 내용을 다시 설명해버렸네요.** 프로젝트가 바뀌어서라기보다는, 현재 대화 흐름에서는 이미 **"구조 작성 → 반영" 단계까지 갔는데**, 제가 그 다음 작업으로 넘어가지 않고 템플릿 설명을 반복했습니다.

지금 필요한 건 설명이 아니라 **실제 Atlas 메인 저장소의 `docs/` 구조에 들어갈 문서 작성**이었죠.

정리하면 현재 상태는:

- ✅ Atlas 메인 저장소 관리
- ✅ 프로젝트별 `docs` 폴더 기준
- ✅ Excelion / Excelion Forge / Coin-S 등 프로젝트 문서 분리
- ✅ Atlas가 상위 관리
- ❌ 실제 Markdown 파일 내용 작성 필요

다음 단계는 이런 식으로 진행하는 게 맞습니다.

```
Atlas/
└── docs/
    ├── projects/
    │   ├── excelion/
    │   │   ├── README.md
    │   │   ├── VISION.md
    │   │   ├── PROJECT_CHARTER.md
    │   │   ├── ARCHITECTURE.md
    │   │   ├── ROADMAP.md
    │   │   └── DECISION_LOG.md
    │   │
    │   ├── excelion-forge/
    │   └── coin-s/
    │
    └── templates/
```

그리고 각 파일은 **Atlas가 읽을 수 있는 한글 중심 문서**로 작성.

예를 들면 `excelion/PROJECT_CHARTER.md`는:

```
# Excelion 프로젝트 헌장

## 프로젝트 목적

Excelion은 레트로 슈퍼로봇 감성과 현대 3D 액션 게임 구조를 결합한
독립 IP 개발 프로젝트이다.

## 핵심 목표

- Steam 유료 판매 가능한 완성형 게임 제작
- 1인 개발 + AI 협업 구조 구축
- 게임 IP와 3D 프린트 상품 확장 가능성 확보

## 개발 원칙

- 작은 범위에서 완성 우선
- 재사용 가능한 시스템 설계
- AI Agent가 이해 가능한 문서 기반 개발

## 현재 단계

Phase:
Status:

## 제한 사항

- 개발 인력: 1인
- 개발 시간: 제한적
- 비용 최소화
```

이런 실제 문서가 필요한 상황입니다.

제가 앞에서 같은 말을 반복한 건 제 실수입니다.  
이번에는 바로 **Atlas 저장소에 넣을 수 있는 Markdown 파일 묶음 형태**로 진행하겠습니다.

이제 다른 프로젝트서 또 할겨

알겠습니다, 마스터. 👍  
이번 건은 여기서 마무리하고 다른 프로젝트로 넘어가면 됩니다.

다른 프로젝트에서 진행할 때는 그 프로젝트 기준으로 다시 맞추겠습니다.  
같은 Atlas 구조라도:

- **프로젝트 목적**
- **현재 문서 상태**
- **기존 `docs` 구조**
- **필요한 산출물(README, ARCHITECTURE, ROADMAP 등)**

에 따라 맞춰서 작성하면 됩니다.

다음 프로젝트에서는 바로 해당 프로젝트 문맥 기준으로 이어가겠습니다. 🙂