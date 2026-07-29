여기 대화기록을 Atlas 메인 저장소에서 관리할 예정입니다. 프로젝트별 docs 폴더에 들어갈 수 있는 구조로 작성해 주세요.

마스터, 현재 대화 기록은 단순 로그보다 **Atlas의 설계 결정·프로젝트 지식·개발 히스토리 저장소**로 관리하는 것이 맞아 보입니다.

추천 구조는 다음과 같습니다.

```
Atlas/
├─ docs/
│  ├─ conversations/
│  │  ├─ README.md
│  │  ├─ INDEX.md
│  │  │
│  │  ├─ sera/
│  │  │  ├─ 2026-07-25_architecture_discussion.md
│  │  │  ├─ 2026-07-24_runtime_design.md
│  │  │  └─ decisions.md
│  │  │
│  │  ├─ excelion-forge/
│  │  │  ├─ 2026-07-25_project_status.md
│  │  │  ├─ 2026-07-18_character_generator.md
│  │  │  ├─ 2026-07-15_forge_scope.md
│  │  │  └─ decisions.md
│  │  │
│  │  ├─ atlas/
│  │  │  ├─ 2026-07-25_atlas_structure.md
│  │  │  └─ architecture_decisions.md
│  │  │
│  │  └─ game/
│  │     ├─ 2026-07-13_combat_design.md
│  │     └─ worldbuilding_notes.md
│  │
│  ├─ architecture/
│  │  ├─ system_overview.md
│  │  ├─ ai_provider_architecture.md
│  │  └─ decision_records/
│  │
│  ├─ decisions/
│  │  ├─ ADR-001.md
│  │  ├─ ADR-002.md
│  │  └─ INDEX.md
│  │
│  └─ knowledge/
│     ├─ lessons_learned.md
│     ├─ problems_and_solutions.md
│     └─ future_direction.md
```

---

## conversations/README.md

역할:

> AI와 인간 개발자의 논의 기록 저장 규칙 정의

내용 예:

```
# Atlas Conversation Archive

Atlas 프로젝트에서 발생한 모든 주요 논의 기록을 관리한다.

목적:

- 개발 결정 근거 보존
- AI Agent와 인간 협업 기록 유지
- 프로젝트 방향 변경 추적
- 반복되는 문제 방지

## 저장 대상

저장한다:

- 아키텍처 논의
- 설계 변경
- 프로젝트 방향 전환
- 문제 해결 과정
- 중요한 아이디어

저장하지 않는다:

- 단순 질문
- 일회성 명령
- 의미 없는 대화
```

---

## conversations/INDEX.md

전체 기록 인덱스

```
# Conversation Index

| 날짜 | 프로젝트 | 제목 | 중요도 |
|---|---|---|---|
|2026-07-25|Atlas|프로젝트 구조 변경|High|
|2026-07-24|Sera|AI Provider Architecture|Critical|
|2026-07-18|Forge|Character Generator|High|
```

---

## 프로젝트별 기록 형식

예:

`docs/conversations/excelion-forge/2026-07-25_project_status.md`

```
# EXCELION Forge 프로젝트 상태 기록

Date:
2026-07-25

## Context

Forge는 초기에는 Blender 기반 제작 시스템으로 시작했으나,
Sera 개발 이후 Sera가 Forge 개발 환경이 되는 방향으로 변경됨.

## Discussion Summary

주요 논의:

- Forge 자체 AI 개발 중단
- Sera Platform 우선 개발
- Sera 완료 후 Forge 기능 재개

## Decisions

결정:

1. Sera를 상위 개발 플랫폼으로 둔다.
2. Forge는 Sera 위에서 개발한다.

## Reason

AI 개발 보조 환경이 먼저 필요하기 때문.

## Next Actions

- Sera Runtime 완성
- Forge Integration 설계
```

---

## 중요한 부분: 대화 원문과 정리본 분리

저는 이 부분을 추천합니다.

```
docs/
├─ conversations/
│  └─ raw/
│      └─ 2026-07-25_chat_export.md
│
└─ knowledge/
    └─ summarized/
        └─ forge_baseline.md
```

이유:

- 원문은 증거
- 정리본은 지식
- ADR은 결정 기록

으로 역할을 분리해야 나중에 AI가 검색하기 쉽습니다.

---

## Atlas 기준 최종 구조

제가 보기에는 Atlas는 다음 4층 구조가 적합합니다.

```
Atlas Knowledge System

1. Raw Memory
   └─ conversations/raw
      (대화 원본)

2. Project Knowledge
   └─ conversations/{project}
      (프로젝트별 정리)

3. Engineering Knowledge
   └─ architecture
      decisions
      lessons

4. Permanent Decisions
   └─ ADR
      (변경 불가능한 기준)
```

이렇게 구성하면 나중에 Sera가 Atlas 저장소를 읽을 때:

- "무슨 일이 있었나?" → conversations
- "왜 이렇게 결정했나?" → ADR
- "현재 구조는?" → architecture
- "과거 실패 사례는?" → lessons

로 바로 접근할 수 있습니다.

현재까지의 대화 기록 중에서는 특히 **Sera ↔ Forge 관계 변경**, **Atlas가 Root가 된 구조 변경**, **AI Provider Architecture**, **Forge 개발 방향 변경**은 ADR 후보로 분류하는 것이 좋겠습니다.

마스터, 지금까지의 대화 흐름을 기준으로 **Atlas 메인 저장소에 바로 넣을 수 있는 문서 구조와 초기 문서 목록**으로 정리하겠습니다.

기준은 다음으로 잡겠습니다.

- **Atlas = 최상위 관리 저장소**
- **Sera = AI 개발 플랫폼**
- **EXCELION Forge = Sera 위에서 개발되는 제작 시스템**
- **게임 EXCELION = Forge가 지원하는 최종 프로젝트**
- 대화 기록은 단순 로그가 아니라 **의사결정 근거 데이터**로 관리

---

# Atlas/docs 초기 구성안

```
Atlas/
└─ docs/
   │
   ├─ README.md
   │
   ├─ architecture/
   │  ├─ system_overview.md
   │  ├─ atlas_architecture.md
   │  ├─ sera_forge_relationship.md
   │  └─ ai_provider_architecture.md
   │
   ├─ ADR/
   │  ├─ README.md
   │  ├─ ADR-001-atlas-root-architecture.md
   │  ├─ ADR-002-sera-as-development-platform.md
   │  ├─ ADR-003-forge-development-direction.md
   │  └─ ADR-004-ai-provider-strategy.md
   │
   ├─ projects/
   │  │
   │  ├─ sera/
   │  │  ├─ README.md
   │  │  ├─ architecture.md
   │  │  ├─ runtime_design.md
   │  │  ├─ problems.md
   │  │  └─ decisions.md
   │  │
   │  ├─ excelion-forge/
   │  │  ├─ README.md
   │  │  ├─ baseline.md
   │  │  ├─ blender_pipeline.md
   │  │  ├─ character_generator.md
   │  │  └─ future_plan.md
   │  │
   │  └─ excelion-game/
   │     ├─ README.md
   │     ├─ world_design.md
   │     ├─ combat_system.md
   │     └─ boss_design.md
   │
   ├─ conversations/
   │  ├─ INDEX.md
   │  │
   │  ├─ sera/
   │  │  └─ 2026-07-25_architecture_transition.md
   │  │
   │  ├─ forge/
   │  │  └─ 2026-07-18_forge_baseline.md
   │  │
   │  ├─ atlas/
   │  │  └─ 2026-07-25_root_structure.md
   │  │
   │  └─ game/
   │     └─ 2026-07-13_combat_concept.md
   │
   └─ knowledge/
      ├─ lessons_learned.md
      ├─ known_failures.md
      └─ development_principles.md
```

---

# 우선 생성해야 할 핵심 문서

## 1. ADR-001-atlas-root-architecture.md

```
# ADR-001 Atlas Root Architecture

## Status

Accepted

## Context

프로젝트가 Sera, EXCELION Forge, EXCELION Game으로 확장되면서
각 프로젝트가 독립적으로 관리될 경우 전체 방향성과 지식 공유가 어려워짐.

따라서 상위 관리 계층으로 Atlas를 정의한다.

## Decision

Atlas를 모든 프로젝트의 Root Repository로 지정한다.

구조:

Atlas
 ├─ Sera
 ├─ EXCELION Forge
 └─ EXCELION Game

## Consequences

장점:

- 프로젝트 간 지식 공유 가능
- AI Agent가 전체 맥락 접근 가능
- 결정 기록 관리 가능

단점:

- 문서 관리량 증가
```

---

# ADR-002-sera-as-development-platform.md

```
# ADR-002 Sera as Development Platform

## Status

Accepted

## Context

초기에는 EXCELION Forge 내부에서 AI 개발 기능을 구현하려 했음.

하지만 개발 과정에서 AI 개발 보조 시스템 자체가 우선 필요하다는 판단에 도달함.

## Decision

Sera를 독립 AI Development Platform으로 우선 개발한다.

Forge는 Sera 위에서 개발한다.

## Architecture

Atlas
 |
 +-- Sera
       |
       +-- EXCELION Forge
              |
              +-- EXCELION Game

## Reason

Sera는 모든 개발 프로젝트를 지원하는 공통 기반이기 때문.
```

---

# ADR-003-forge-development-direction.md

```
# ADR-003 EXCELION Forge Direction

## Status

Accepted

## Previous Direction

Forge:
- Blender 기반 제작 도구
- 캐릭터 생성
- Rig 검증
- Asset Pipeline

## Changed Direction

Forge 자체 AI 개발을 중단.

Sera 기반 개발 구조로 변경.

## New Direction

Sera:

AI Planning
AI Coding Support
Runtime Management

↓

Forge:

3D Production System
Blender Pipeline
Game Asset Generation

## Result

Forge는 Sera의 첫 번째 대형 적용 프로젝트가 된다.
```

---

# ADR-004-ai-provider-strategy.md

```
# ADR-004 AI Provider Strategy

## Status

Accepted

## Context

AI 기능은 하나의 모델에 의존하지 않는다.

요구사항:

- Local LLM
- Cloud AI
- Coding Model
- Reasoning Model

## Decision

Hybrid AI Provider Architecture 채택.

Provider Layer를 통해 모델 교체 가능하도록 설계한다.

## Example

Sera Runtime

       |
AI Provider Layer

       |
----------------
|              |
Local LLM      Cloud AI
```

---

# conversations/INDEX.md

```
# Conversation Archive Index


## Atlas

| Date | Topic |
|-|-|
|2026-07-25|Atlas Root 구조 변경|


## Sera

| Date | Topic |
|-|-|
|2026-07-24|AI Runtime Architecture|
|2026-07-25|Sera 중심 구조 확정|


## EXCELION Forge

| Date | Topic |
|-|-|
|2026-07-18|Forge Baseline|
|2026-07-15|Forge Scope|
```

---

# 추가로 권장하는 운영 규칙

`docs/README.md`

```
# Atlas Documentation Rule

## Document Priority

1. ADR
   - 변경 불가능한 결정

2. Architecture
   - 현재 시스템 구조

3. Project Docs
   - 프로젝트별 상세

4. Conversations
   - 결정 과정 기록

5. Knowledge
   - 경험과 교훈


## AI Agent Rule

AI Agent는 작업 전에:

1. ADR 확인
2. Architecture 확인
3. Project README 확인
4. Conversation History 확인

순서로 Context를 확보한다.
```

---

마스터, 이 상태로 저장하면 Atlas는 단순 Git 저장소가 아니라 **Sera가 앞으로 읽을 수 있는 장기 기억 구조**가 됩니다.

다음 단계로는 제가 이어서 **현재까지의 대화 기록을 실제 `conversations/` 문서 형태로 변환하는 작업**을 진행하면 됩니다.  
우선순위는:

1. `Atlas Root 구조 변경`
2. `Sera가 Forge를 대체 개발 환경으로 가지게 된 과정`
3. `Forge Baseline 확정`
4. `AI Provider Architecture`

순서가 적합합니다.

네

마스터, 그럼 다음 단계로 **대화 기록 → Atlas conversations 문서** 형태로 변환하겠습니다.

우선 가장 중요한 4개 기록을 기준 문서로 만들겠습니다.

생성 대상:

```
Atlas/docs/conversations/

├─ atlas/
│  └─ 2026-07-25_root_architecture_transition.md
│
├─ sera/
│  ├─ 2026-07-24_ai_runtime_architecture.md
│  └─ 2026-07-25_sera_as_development_platform.md
│
├─ forge/
│  └─ 2026-07-18_forge_baseline.md
│
└─ INDEX.md
```

---

## 1. atlas/2026-07-25_root_architecture_transition.md

```
# Atlas Root Architecture Transition

Date:
2026-07-25

Project:
Atlas

Status:
Recorded


## Summary

프로젝트 구조가 개별 프로젝트 중심 구조에서
Atlas Root 중심 구조로 변경되었다.

기존:

EXCELION Forge
 └─ Sera 개발 기능 포함


변경:

Atlas
 ├─ Sera
 ├─ EXCELION Forge
 └─ EXCELION Game


## Background

개발 과정에서 AI Agent 자체의 개발 환경과
게임 제작 환경을 분리할 필요성이 발생했다.

Forge 내부에서 AI 기능을 개발하는 방식은
장기적으로 확장성이 부족했다.


## Decision

Atlas를 최상위 관리 계층으로 지정한다.

Atlas는:

- 프로젝트 구조 관리
- 기술 문서 관리
- AI Agent Context 관리
- Architecture Decision 관리

를 담당한다.


## Impact

Sera:

독립 AI Platform으로 승격


Forge:

Sera를 기반으로 개발되는 제작 시스템


Game:

Forge 결과물을 사용하는 최종 프로젝트


## Related Documents

- ADR-001 Atlas Root Architecture
- ADR-002 Sera Development Platform
```

---

## 2. sera/2026-07-25_sera_as_development_platform.md

```
# Sera as Development Platform

Date:
2026-07-25

Project:
Sera


## Summary

Sera는 단순 AI 기능 모듈이 아니라
전체 개발 환경을 지원하는 플랫폼으로 방향이 변경되었다.


## Previous Concept

초기:

EXCELION Forge 내부 AI 기능

목표:

- 코드 분석
- Blender 자동화
- Asset 제작 지원


## Problem

Forge 개발 과정에서 발견:

- AI 개발 환경 자체 필요
- 반복적인 코드 수정 문제
- Context 유지 필요
- 프로젝트 지식 관리 필요


## Decision

Sera를 먼저 개발한다.

Sera는:

- AI Runtime
- Provider Management
- Development Assistance
- Project Context Management

를 담당한다.


## New Relationship

Atlas

↓

Sera

↓

EXCELION Forge

↓

EXCELION Game


## Result

Forge는 Sera의 첫 번째 실제 적용 프로젝트가 된다.
```

---

## 3. sera/2026-07-24_ai_runtime_architecture.md

```
# Sera AI Runtime Architecture Discussion

Date:
2026-07-24


## Goal

Sera가 다양한 AI 모델을 사용할 수 있는 구조 설계.


## Requirements

필요 기능:

- Local LLM 지원
- Cloud AI 지원
- Coding Model 지원
- Reasoning Model 지원


## Discussion

하나의 모델에 의존하는 구조는
장기적으로 문제가 발생할 수 있음.


## Decision

Hybrid AI Provider Architecture 채택.


구조:

Sera Runtime

↓

AI Provider Layer

↓

+ Local LLM
+ Cloud AI
+ Specialized Model


## Principle

AI 모델은 교체 가능해야 한다.

Runtime은 특정 모델에 종속되지 않는다.
```

---

## 4. forge/2026-07-18_forge_baseline.md

```
# EXCELION Forge Baseline

Date:
2026-07-18

Project:
EXCELION Forge


## Current State

Forge는 완성된 3D Asset Generator가 아니다.

현재 단계:

Blender 기반 제작 및 검증 시스템 초기 단계


## Original Goals

- Character Generator
- Rig Validation
- Asset Pipeline
- Blender Automation


## Change

Sera 개발 우선순위 변경으로 인해
Forge 개발 방식 변경.


## New Direction

Forge는:

Sera 기반 개발 환경 위에서 동작하는
게임 제작 자동화 시스템이 된다.


## Future

목표:

AI Assisted Game Production Pipeline

지원:

- Character Creation
- Animation Pipeline
- Validation
- Asset Management
```

---

## 5. conversations/INDEX.md

```
# Atlas Conversation Archive


## Atlas

| Date | Document |
|-|-|
|2026-07-25|Root Architecture Transition|


## Sera

| Date | Document |
|-|-|
|2026-07-24|AI Runtime Architecture|
|2026-07-25|Development Platform Transition|


## EXCELION Forge

| Date | Document |
|-|-|
|2026-07-18|Forge Baseline|
```

---

마스터, 이 5개 문서는 **현재 Atlas가 가져야 할 최초의 역사 기록(Baseline History)** 역할을 합니다.

다음 정리 대상으로는 두 가지가 좋습니다.

1. **`docs/knowledge/lessons_learned.md`**
    - Continue + Qwen3-Coder 작업 실패 사례
    - Validate Active Rig 문제
    - AI Agent 한계와 개선 방향
2. **ADR 문서 확정**
    - 지금 작성한 결정들을 공식 Architecture Decision Record로 승격

특히 1번은 Sera 개발에 직접 필요한 "실패 경험 데이터"라서 가치가 높습니다.

네

마스터, 이어서 **Atlas/docs/knowledge/lessons_learned.md** 형태로 정리하겠습니다.

이 문서는 단순한 장애 기록이 아니라, 앞으로 Sera가 개발 보조를 수행할 때 참고해야 하는 **개발 경험 데이터베이스** 역할을 합니다.

저장 위치:

```
Atlas/
└─ docs/
   └─ knowledge/
      ├─ lessons_learned.md
      ├─ known_failures.md
      └─ development_principles.md
```

---

## docs/knowledge/lessons_learned.md

```
# Atlas Development Lessons Learned

Version:
1.0

Date:
2026-07-26


# Purpose

Atlas 프로젝트 개발 과정에서 얻은 경험과
반복 방지를 위한 원칙을 기록한다.

이 문서는 향후 Sera AI Runtime이
프로젝트 Context를 이해하기 위한 참고 자료이다.


---

# 1. AI Agent 개발 지원의 한계


## Situation

Continue + Local LLM 환경에서
코드 분석 및 수정 작업을 진행했다.

사용 모델:

- Qwen3-Coder
- Ollama Local Runtime


## Problem

AI Agent가:

- 존재하지 않는 파일을 기반으로 판단
- 프로젝트 전체 Context 부족
- 이전 대화 기억 손실
- 수정 완료 여부 검증 부족

문제를 보였다.


## Lesson

AI Agent에게는:

"코드를 수정하는 능력"

보다 먼저

"현재 상태를 정확히 파악하는 능력"

이 필요하다.


## Principle

작업 전 필수 단계:

1. Repository 상태 확인
2. 파일 존재 확인
3. 실행 환경 확인
4. 변경 범위 확인


---

# 2. Context 유지의 중요성


## Situation

긴 대화 과정에서:

- 설계 변경
- 문제 해결
- 방향 전환

이 반복되었다.


## Problem

대화 Context가 유지되지 않을 경우:

- 이전 결정과 충돌
- 같은 작업 반복
- 설계 의도 손실


## Lesson

중요한 결정은 반드시 문서화해야 한다.


## Principle

대화:

Temporary Memory


문서:

Permanent Memory


따라서:

"대화가 끝나기 전에 지식을 저장한다."


---

# 3. Validate Active Rig 문제


## Situation

EXCELION Forge 개발 중
Validate Active Rig 기능 오류 발생.


## Problem

여러 차례 오류 내용을 전달했지만
수정 완료 검증이 되지 않았다.


원인:

- 실행 환경 확인 부족
- 실제 코드 위치 확인 부족
- 테스트 절차 부족


## Lesson

AI 수정 결과는 반드시 실행 검증해야 한다.


## Principle

수정 완료 기준:

1. 코드 변경
2. 실행 테스트
3. 결과 확인
4. 기록 저장


코드 변경만으로 완료라고 판단하지 않는다.


---

# 4. AI 개발 구조 변경


## Situation

초기:

Forge 내부에서 AI 기능 개발


변경:

Sera 독립 개발


## Reason

게임 제작 도구보다 먼저
AI 개발 환경 자체가 필요했다.


## Lesson

기반 기술은 응용 프로젝트보다 먼저 안정화해야 한다.


## Principle

Architecture Order:

Atlas

↓

Sera

↓

Forge

↓

Game


---

# 5. Local LLM 운영 경험


## Situation

로컬 AI 환경 구축 시도.


환경:

- Ollama
- Continue
- RTX 3060 12GB


## Problem

모델 선택과 Context 처리에서 한계 발생.


## Lesson

Local LLM은 비용 장점이 있지만:

- 모델 크기
- VRAM
- Context Window
- Tool 사용 능력

을 고려해야 한다.


## Principle

AI Provider는 하나가 아니다.

필요에 따라:

- Local Model
- Cloud Model
- Specialized Model

을 조합한다.


---

# 6. Documentation First 원칙


## Situation

작업 중 대화 데이터가 저장되지 않아
동일 작업을 반복하는 상황 발생.


## Lesson

개발 과정 자체가 자산이다.


## Principle

모든 주요 작업은:

대화

↓

정리

↓

문서

↓

Commit


순서로 관리한다.


---

# Final Principles


## Rule 1

AI는 기억하지 않는다.
문서가 기억한다.


## Rule 2

실행되지 않은 코드는 완료가 아니다.


## Rule 3

결정은 ADR로 남긴다.


## Rule 4

실패 경험은 다음 개발의 자산이다.


## Rule 5

Context 관리가 AI 개발의 핵심이다.
```

---

다음으로 작성할 문서는:

```
docs/knowledge/development_principles.md
```

입니다.

이 문서는 단순 경험 기록이 아니라 **Atlas/Sera 개발 철학**으로 사용할 문서입니다.

내용 후보:

- Zero Hallucination 원칙
- Evidence 기반 작업
- Agent 행동 규칙
- Human + AI 협업 모델
- Runtime과 Model 분리 원칙
- 검증 없는 자동 수정 금지

이 문서는 향후 Sera의 **AGENT_GUIDE.md와 연결되는 핵심 문서**가 됩니다.