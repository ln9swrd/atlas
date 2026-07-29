# 000. Project Atlas 초기정의 – DevOS

> **핵심 문장**  
> Build the system that builds the game.

---

## 1. 프로젝트 정의

Project Atlas는 엑셀리온을 포함한 모든 개인 프로젝트를 효율적으로 개발하기 위한 **AI 기반 개발 시스템(Development Operating System)** 이다.

목표는 게임을 만드는 것이 아니라, **게임을 만드는 시스템**을 구축하는 것이다.

### 현재 개발 환경
- 하루 실제 개발 가능 시간 ≈ 3시간
- 주 개발자: 1명
- 활용 가능한 AI: 마리, Antigravity
- 향후 추가 예정: 세라(디자인), 포지(Blender) 등
- 중심 도구: Blender + Unreal Engine

---

## 2. 핵심 원칙

1. 사람이 직접 하는 반복 작업을 최대한 줄인다.
2. AI는 생성보다 **검토(Review)**와 **조언(Coaching)**을 우선한다.
3. 기존 도구를 최대한 활용하고, 부족한 부분만 새로운 도구/애드온으로 만든다.
4. 모든 기능은 실제 1인 개발자의 작업 시간을 줄이는 것을 최우선 목표로 한다.
5. 감각·경험에 의존하는 작업은 규칙(Rules), 체크리스트(Checklists), 워크플로우(Workflows)로 구조화한다.

---

## 3. Atlas 최상위 구조 (7계층)

```
Project Atlas
└── Atlas Core
    ├── Workflow
    ├── Rules
    ├── Checklists
    ├── Review
    ├── Automation
    ├── AI Team
    └── Tools
```

### 3.1 Workflow
프로젝트가 어떻게 흐르는지를 정의한다.

```
기획 → 컨셉 → 3D 제작 → 애니메이션 → 언리얼 → 테스트 → 피드백 → 수정 → 빌드 → 배포
```

### 3.2 Rules
반복되는 판단을 규칙으로 고정한다.
- Blender: Modifier 순서, Collection, 파일명, Pivot, Export 규칙
- Unreal: 폴더, Blueprint, Naming 규칙
- Git: Commit / Branch 규칙

### 3.3 Checklists
실무 검증용 체크리스트.
예) 메시 제작 완료 시:
- 노멀 / UV / Scale Apply / Origin / Material 이름 / Collision / Export 테스트

### 3.4 Review System
AI의 핵심 역할. 생성보다 검토를 우선한다.

예시 평가:
- Topology ★★★★★
- Naming ★★★★☆
- Animation ★★★☆☆
- Performance ★★★★★
- Printability ★★★★☆

+ 개선점 1·2·3

### 3.5 Automation
반복 작업 제거.
- Blender: Export, FBX, Collider, LOD, UV/Naming 검사
- Unreal: Import, Material/Skeleton 연결, Data Validation
- Git: 자동 Commit, Change Log

### 3.6 AI Team
역할 분담된 전문 AI.
- 마리 → 기술 설계
- Antigravity → 대규모 코드 생성
- 세라 → 컨셉아트 / 디자인 / 세계관
- 포지 → Blender (모델링·리깅·출력)
- 향후: 빌더(언리얼), 테스터(QA), 도큐(문서)

### 3.7 Tools
도구 제작 우선순위:

```
기존 기능 → 기존 애드온 → 오픈소스 → 간단한 스크립트 → Blender Addon → UE Plugin → 새 프로그램
```

**새로 만드는 것은 항상 마지막 선택.**

---

## 4. 첫 번째 과제 – 병목 분석

작업 흐름에서 시간이 가장 많이 드는 구간을 찾는다.

| 단계 | 질문 |
|------|------|
| 설계 | 무엇을 만들지 결정하는 데 오래 걸리는가? |
| Blender | 모델링 / UV / 리깅 / 출력 준비 중 어디가 병목인가? |
| Unreal | 임포트 / 블루프린트 / 디버깅 중 병목은? |
| 반복 | 수정이 반복되는 이유는? |
| 검증 | 어떤 실수를 계속 반복하는가? |

→ 자동화할 것 / 체크리스트로 막을 것 / AI 리뷰로 해결할 것을 구분하는 것이 첫 설계 산출물.

---

## 5. 핵심 철학

> AI는 사람을 대신해서 만드는 존재가 아니라,  
> 사람이 더 적은 시행착오로 더 좋은 결과를 만들도록 돕는 존재다.

따라서 Atlas에서는 **생성보다 검토·검증·우선순위 제안·품질 관리**를 더 중요하게 둔다.

---

## 6. 환경 분리 (회사 PC / 집 PC)

### 회사 PC = Production
- 역할: 설계 및 생산
- 가능: Atlas, Sera, Exelion 기획, Blender(모델링·리깅·UV), Python, 문서
- 불가능: Unreal Engine, GPU AI

### 집 PC = Integration
- 역할: 검증 및 통합
- 가능: Unreal, FBX Import, 애니메이션 확인, 플레이 테스트, 렌더링, GPU AI

### 권장 일반화 구조
특정 PC가 아니라 **Environment**로 정의한다.

```
Environment ID : DEV_WORK
Role           : Production
Capabilities   : Blender, Python, VS Code, Atlas
Limitations    : Unreal Engine unavailable, GPU AI unavailable

Environment ID : DEV_HOME
Role           : Integration
Capabilities   : Unreal Engine, GPU, Blender
Assigned Tasks : FBX Import, Play Test, Rendering, Packaging
```

장기적으로는 `ENVIRONMENT_REGISTRY`를 두고 `ATLAS_STATE`와 연동하여 현재 환경에 맞는 작업만 추천하도록 한다.

---

## 7. 당시 상태 요약 (이 대화 시점)

- ✅ Atlas DevOS v1.0 Foundation 완료
- ✅ Sera v1.0 아키텍처 완료
- ✅ Exelion Goal → Sprint → Task 체계 구축
- ✅ State / Agent / Goal Registry 구축
- ✅ Project Charter / Lifecycle / Playbooks 구축
- ✅ 회사 PC / 집 PC 역할 분리 반영

### 다음 목표 (당시)
**Atlas v1.1 : Environment-Aware DevOS**
1. ENVIRONMENT_REGISTRY 설계
2. ATLAS_STATE와 환경 연동
3. atlas_runner가 현재 환경에 맞는 작업만 추천
4. Priority Engine이 환경 제약을 고려
5. 회사 ↔ 집 PC 전환 자동 지원 구조
