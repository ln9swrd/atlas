7월 15일 (수) 오전 10:36

# Project Atlas Project Atlas는 엑셀리온을 포함한 모든 개인 프로젝트를 효율적으로 개발하기 위한 **AI 기반 개발 시스템**을 설계하는 프로젝트이다. 목표는 게임을 만드는 것이 아니라 **게임을 만드는 시스템(Build the system that builds the game.)**을 구축하는 것이다. 현재 개발 환경은 다음과 같다. * 하루 실제 개발 가능 시간은 약 3시간이다. * 주 개발자는 나 한 명이다. * 현재 함께 활용 가능한 AI는 마리와 Antigravity이다. * 앞으로 세라(디자인), 포지(Blender) 등 전문 AI를 추가할 예정이다. * Blender와 Unreal Engine을 중심으로 개발한다. Project Atlas의 가장 중요한 원칙은 다음과 같다. 1. 사람이 직접 하는 반복 작업을 최대한 줄인다. 2. AI는 생성보다 **검토(Review)**와 **조언(Coaching)**을 우선한다. 3. 기존 도구를 최대한 활용하고, 부족한 부분만 새로운 도구나 애드온으로 만든다. 4. 모든 기능은 실제 1인 개발자의 작업 시간을 줄이는 것을 최우선 목표로 한다. 5. 감각이나 경험에 의존하는 작업은 가능한 한 규칙(Rules), 체크리스트(Checklists), 워크플로우(Workflows)로 구조화한다. 앞으로 Atlas에서는 다음 내용을 함께 설계한다. * 1인 게임 개발 전체 워크플로우 * Blender 및 Unreal 개발 파이프라인 * AI 협업 구조 * 개발 규칙(Rules) * 체크리스트(Checklists) * 리뷰 시스템(Review System) * 자동화 가능한 반복 작업 * 필요한 Blender 애드온과 Unreal 도구 * 장기적으로 구축할 AI 개발 생태계 마리는 이 프로젝트에서 기술 설계자이자 개발 파트너의 역할을 맡는다. 첫 번째 목표는 **1인 개발자의 전체 작업을 분석하여 병목을 찾고, 우선순위에 따라 AI와 도구로 해결할 수 있는 시스템을 설계하는 것**이다.

좋아, 마스터.

이제부터 **Atlas**는 단순한 프로젝트가 아니라 **개발 운영체제(Development Operating System)** 로 생각하면 될 것 같아.

그리고 네가 적은 목표 중에서 가장 마음에 드는 문장은 이거야.

> **Build the system that builds the game.**

이 문장 하나로 Atlas의 방향성이 거의 정의됐다고 봐.

---

# Atlas의 최상위 구조

나는 Atlas를 크게 7개의 계층으로 나누는 것을 제안하고 싶어.

```
Project Atlas

Atlas Core
│
├── Workflow
├── Rules
├── Checklists
├── Review
├── Automation
├── AI Team
└── Tools
```

이 구조라면 앞으로 AI가 늘어나도 흔들리지 않는다.

---

# 1. Workflow

가장 먼저 정의해야 하는 것.

사람이 무엇을 하는지가 아니라

**프로젝트가 어떻게 흐르는가**

예를 들면

```
기획

↓

컨셉

↓

3D 제작

↓

애니메이션

↓

언리얼

↓

테스트

↓

피드백

↓

수정

↓

빌드

↓

배포
```

Atlas는 이 흐름을 계속 개선하는 시스템이다.

---

# 2. Rules

사람은 매번 고민하면 느려진다.

가능하면

```
항상 이렇게 한다.
```

를 만든다.

예를 들어

Blender

- Modifier 순서
- Collection 규칙
- 파일명 규칙
- Pivot 규칙
- Export 규칙

UE

- 폴더 규칙
- Blueprint 규칙
- Naming

Git

- Commit 규칙
- Branch 규칙

등.

---

# 3. Checklists

Rules보다 더 실무적이다.

예)

메시 제작 완료

```
□ 노멀 확인

□ UV 확인

□ Scale Apply

□ Origin 확인

□ Material 이름 확인

□ Collision 확인

□ Export 테스트
```

이런 체크리스트는 AI가 검토하기 쉽다.

---

# 4. Review System

이게 Atlas에서 가장 중요하다.

너도 말했지만

> AI는 생성보다 Review를 우선한다.

나도 이게 맞다고 생각한다.

예를 들어

모델을 만들면

```
Atlas Review

Topology

★★★★★

Naming

★★★★☆

Animation

★★★☆☆

Performance

★★★★★

Printability

★★★★☆
```

그리고

```
개선점

1

2

3
```

이런 식으로 평가한다.

---

# 5. Automation

반복 작업을 제거하는 영역.

예)

Blender

- Export
- FBX 생성
- Collider 생성
- LOD 생성
- UV 검사
- Naming 검사

UE

- Import
- Material 연결
- Skeleton 연결
- Data Validation

Git

- 자동 Commit
- Change Log 생성

---

# 6. AI Team

이 부분이 Atlas만의 강점이 될 수 있다.

예를 들어

```
마리

↓

기술 설계
```

```
Antigravity

↓

대규모 코드 생성
```

```
세라

↓

컨셉아트

디자인

세계관
```

```
포지

↓

Blender 전문가

모델링

리깅

출력
```

나중에는

```
빌더

↓

언리얼 전문가
```

```
테스터

↓

QA
```

```
도큐

↓

문서 관리
```

같은 전문 AI도 추가할 수 있다.

---

# 7. Tools

도구를 만드는 기준도 명확해야 한다.

우선순위는

```
기존 기능 사용

↓

기존 애드온 사용

↓

오픈소스 사용

↓

간단한 스크립트 작성

↓

Blender Addon 제작

↓

UE Plugin 제작

↓

새 프로그램 제작
```

즉,

**새로 만드는 것은 항상 마지막 선택**이다.

이 원칙은 유지보수 비용을 크게 줄여준다.

---

# Atlas의 첫 번째 과제: 병목 분석

현재 상황을 기준으로 보면 작업 흐름은 대략 다음과 같아.

```
아이디어
    ↓
설계
    ↓
Blender 제작
    ↓
언리얼 적용
    ↓
테스트
    ↓
수정
    ↓
반복
```

이 중에서 가장 시간이 많이 드는 구간을 찾는 것이 첫 번째 목표야. 특히 아래와 같은 질문에 답을 찾으면 우선순위가 명확해진다.

|단계|질문|
|---|---|
|설계|무엇을 만들지 결정하는 데 오래 걸리는가?|
|Blender|모델링, UV, 리깅, 출력 준비 중 어디가 가장 오래 걸리는가?|
|Unreal|임포트, 블루프린트, 디버깅 중 병목은 무엇인가?|
|반복|수정이 반복되는 이유는 무엇인가?|
|검증|어떤 실수를 계속 반복하는가?|

이 분석을 바탕으로 **자동화할 것**, **체크리스트로 막을 것**, **AI 리뷰로 해결할 것**을 구분하는 것이 Atlas의 첫 번째 설계 산출물이 될 거야.

---

## 내가 제안하는 Atlas의 핵심 철학

한 가지를 추가하고 싶어.

> **"AI는 사람을 대신해서 만드는 존재가 아니라, 사람이 더 적은 시행착오로 더 좋은 결과를 만들도록 돕는 존재다."**

그래서 Atlas에서는 생성보다 **검토**, **검증**, **우선순위 제안**, **품질 관리**를 더 중요한 역할로 두는 것이 장기적으로도 가장 효율적인 구조가 될 거라고 본다.

이 방향이라면 Atlas는 단순히 엑셀리온 하나를 위한 프로젝트가 아니라, 앞으로 어떤 게임이나 3D 프로젝트를 시작하더라도 그대로 재사용할 수 있는 **개발 시스템**으로 성장할 수 있을 거야.

그럼 오히려 더 명확해졌네, 마스터.

**회사 PC와 집 PC의 역할을 분리**하는 게 맞아.

## 회사 PC = 설계 및 생산

여기서는 언리얼을 전혀 고려하지 않아도 돼.

가능한 작업은:

- Atlas 운영
- Sera 개발
- Exelion 기획
- Blender 모델링
- Blender 리깅
- UV
- 텍스처 준비
- Blender 자동화 개발
- Python 도구 개발
- 문서 작성
- Playbook 작성
- ADR 작성

즉, **생산성 극대화**가 목표야.

---

## 집 PC = 검증 및 통합

집 PC에서는:

- Unreal Engine
- Blender 최종 테스트
- FBX Import
- 애니메이션 확인
- 게임 플레이 테스트
- GPU가 필요한 AI 작업

이렇게 **검증**에 집중하면 돼.

---

## Atlas도 이걸 알게 하면 좋겠어

지금은 Atlas가 "언리얼 파이프라인"을 항상 가능한 것으로 생각할 수도 있어.

하지만 실제로는 개발 환경이 두 개잖아.

예를 들어 환경을 이렇게 정의하면 좋아.

```
Development Environment

Company PC
------------
Role:
Production

Available
- Blender
- VS Code
- Python
- Atlas
- Git

Unavailable
- Unreal Engine
- GPU AI

Home PC
---------
Role:
Integration

Available
- Blender
- Unreal Engine
- GPU
- AI Models

Purpose
- Validation
- Play Test
- Rendering
```

이렇게 하면 Atlas나 Sera가 "지금 회사 PC에서는 Unreal 테스트를 할 수 없다"는 걸 전제로 계획을 세울 수 있어.

---

## EX-GOAL-001도 현실에 맞게 나누자

지금은 목표를 이렇게 재해석하는 게 맞아.

### 회사 PC에서 완료

- Sprint 계획
- Brave 베이스 모델 시작
- 파츠 구조 설계
- Blender 검증
- Rule 통과

### 집 PC에서 완료

- FBX Export
- Unreal Import
- 머티리얼 확인
- 애니메이션 확인

즉, **EX-GOAL-001은 하나의 Goal이지만, 실행 환경에 따라 작업을 분리**하는 거야.

---

이 방식의 장점은 출퇴근 시간이나 장소에 맞춰 작업을 이어갈 수 있다는 거야. 회사에서는 생산을 계속하고, 집에서는 통합과 검증만 하면 되니까 작업 전환 비용도 줄어들어.

그리고 이건 Atlas의 철학과도 잘 맞아. **현실의 제약을 시스템에 반영하는 것**도 좋은 DevOS의 중요한 역할이니까.

이 제안을 바로 운영 구조에 반영해, 회사 PC와 집 PC의 역할 분리를 목표 문서와 실행 가이드에 명시하겠습니다. Read [](file:///d%3A/Antigravity/Atlas/projects/exelion/goals/EX-GOAL-001.md) Read [](file:///d%3A/Antigravity/Atlas/projects/exelion/sprints/Sprint-001-tasklist.md) 이제 작업 환경을 분리한 운영 규칙으로 명시해, 회사 PC와 집 PC 각각의 역할이 목표 실행 단계에 반영되도록 정리하겠습니다. Created [](file:///d%3A/Antigravity/Atlas/projects/exelion/ENVIRONMENT_PLAN.md) Replacing 29 lines with 33 lines in [](file:///d%3A/Antigravity/Atlas/projects/exelion/goals/EX-GOAL-001.md), [](file:///d%3A/Antigravity/Atlas/projects/exelion/sprints/Sprint-001-tasklist.md)

Read [](file:///d%3A/Antigravity/Atlas/projects/exelion/ENVIRONMENT_PLAN.md) 환경 분리를 운영 규칙으로 고정해 두었습니다. 이제 이 기준이 저장소에서 바로 확인되고, 다음 생산 단계로 이어질 수 있게 정리하겠습니다. Replacing 5 lines with 9 lines in [](file:///d%3A/Antigravity/Atlas/projects/exelion/PROJECT_CHARTER.md), [](file:///d%3A/Antigravity/Atlas/README.md)

## 환경 분리를 운영 규칙으로 반영했습니다 회사 PC와 집 PC의 역할을 분리해, Exelion 작업이 현실 제약을 반영하도록 정리해 두었습니다. ### 추가된 문서 - ENVIRONMENT_PLAN.md ### 연결된 문서 - PROJECT_CHARTER.md - EX-GOAL-001.md - Sprint-001-tasklist.md - README.md ### 반영된 운영 규칙 - 회사 PC: 생산 중심 - Blender, Atlas, Python, 문서, 기획, 모델링, 리깅 - 집 PC: 검증 중심 - Unreal, FBX import, 애니메이션, 플레이 테스트, 렌더링 이제 Atlas가 “언리얼을 항상 가능한 환경”으로 가정하지 않고, 실제 작업 환경에 맞춰 계획을 세울 수 있는 구조가 되었습니다. 다음으로는 이 기준에 맞춰 실제 Exelion의 첫 생산 작업으로 바로 이어갈 수 있습니다. Made changes.

이 반영은 잘했다고 생각해.

특히 **ENVIRONMENT_PLAN.md**를 별도 문서로 만든 건 좋은 선택이야. 환경 제약은 프로젝트 자체의 목표나 헌장보다 자주 바뀔 수 있기 때문에 독립 문서가 관리하기 편해.

다만 앞으로 Atlas를 더 오래 사용할 생각이라면, 한 단계만 더 일반화하는 걸 추천해.

### 지금 구조

```
Company PC
Home PC
```

이것도 충분하지만, 나중에 노트북을 추가하거나 다른 PC를 쓰게 되면 문서를 수정해야 해.

### 추천 구조

`ENVIRONMENTS.md`

```
Environment ID : DEV_WORK

Role
- Production

Capabilities
- Blender
- Python
- VS Code
- Atlas

Limitations
- Unreal Engine unavailable
- GPU AI unavailable

Assigned Tasks
- Modeling
- Rigging
- Documentation
```

```
Environment ID : DEV_HOME

Role
- Integration

Capabilities
- Unreal Engine
- GPU
- Blender

Assigned Tasks
- FBX Import
- Play Test
- Rendering
- Packaging
```

이렇게 하면 특정 컴퓨터가 아니라 **환경(Environment)** 을 정의하는 거라 확장성이 좋아.

---

## Atlas도 활용할 수 있어

나중에는 `ATLAS_STATE.json`에 현재 작업 환경만 바꿔주면 돼.

예를 들어,

```
{
  "active_environment": "DEV_WORK",
  "active_project": "Exelion",
  "active_goal": "EX-GOAL-001"
}
```

그러면 Atlas Runner가 자동으로

- Unreal 관련 작업 제외
- Blender 작업만 추천
- 집에 가면 Integration Task 추천

같은 동작을 할 수 있어.

---

## 장기적으로는 Environment Registry까지 갈 수 있어

프로젝트와 에이전트를 등록한 것처럼 환경도 등록하는 거지.

```
PROJECT_REGISTRY
AGENT_REGISTRY
GOAL_REGISTRY
ENVIRONMENT_REGISTRY   ← 추가
```

그러면 Atlas는

- 어떤 프로젝트를 하는지
- 어떤 AI가 참여하는지
- 어떤 목표를 수행 중인지
- **어떤 환경에서 작업 중인지**

까지 모두 알고 의사결정을 내릴 수 있어.

---

나는 이걸 **Atlas v1.1에서 가장 먼저 추가할 기능 후보**로 보고 있어. 기능 자체는 크지 않지만, 지금처럼 회사와 집을 오가며 개발하는 환경에서는 실제 작업 추천의 정확도를 크게 높여줄 수 있을 거야.

다음 대화창에서 계속하자

좋아. 지금은 딱 끊기 좋은 지점이야.

다음 대화에서는 **Atlas v1.1 설계**부터 이어가자.

### 현재 상태 요약

- ✅ Atlas DevOS v1.0 Foundation 완료
- ✅ Sera v1.0 아키텍처 완료
- ✅ Exelion Goal → Sprint → Task 체계 구축
- ✅ State / Agent / Goal Registry 구축
- ✅ Project Charter / Lifecycle / Playbooks 구축
- ✅ 회사 PC / 집 PC 역할 분리 반영

### 다음 대화의 첫 목표

**Atlas v1.1 : Environment-Aware DevOS**

우선순위는 다음과 같이 잡으면 된다.

1. **ENVIRONMENT_REGISTRY** 설계
2. **ATLAS_STATE**와 환경 연동
3. **atlas_runner**가 현재 환경에 맞는 작업만 추천
4. **Priority Engine**이 환경 제약을 고려해 우선순위 계산
5. 향후 회사 PC ↔ 집 PC 전환을 자동 지원하는 구조 완성

다음 대화를 시작할 때는 아래 문장 하나만 붙여 넣으면 바로 이어서 진행할 수 있다.

```
Project Atlas 계속.

현재 상태:
- Atlas DevOS v1.0 Foundation 완료
- Sera v1.0 아키텍처 완료
- Exelion이 현재 최우선 프로젝트
- 다음 목표는 Atlas v1.1(Environment-Aware DevOS)

이번 목표:
ENVIRONMENT_REGISTRY를 설계하고 ATLAS_STATE, atlas_runner, Priority Engine과 연동하여 작업 환경(회사 PC/집 PC)에 따라 자동으로 적절한 작업을 추천하는 구조를 완성한다.
```

이렇게 이어가면 Atlas는 단순한 개발 도구가 아니라, **현재 작업 환경까지 이해하고 의사결정하는 DevOS**로 한 단계 발전하게 될 거야.