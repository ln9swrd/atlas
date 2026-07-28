좋습니다. 그러면 Atlas 저장소 기준으로 바로 넣을 수 있는 **초기 문서 세트** 형태로 정리하겠습니다.

추천 루트:

```
Atlas/
└── projects/
    └── excelion/
        └── docs/
```

초기 생성 파일:

```
docs/
├── README.md
│
├── 00_project_overview.md
├── 01_world_setting.md
├── 02_game_concept.md
│
├── robot/
│   ├── README.md
│   ├── 01_main_robot_design.md
│   ├── 02_internal_frame.md
│   ├── 03_weapon_system.md
│   └── 04_enemy_mecha.md
│
├── design/
│   ├── design_philosophy.md
│   ├── silhouette_guidelines.md
│   ├── parametric_modeling.md
│   └── 3d_printing_notes.md
│
├── development/
│   ├── modeling_pipeline.md
│   ├── blender_workflow.md
│   └── script_generation.md
│
├── decisions/
│   ├── DEC-001_scale_25m.md
│   ├── DEC-002_super_robot_direction.md
│   └── DEC-003_mechanical_organic_style.md
│
└── conversation_log/
    ├── 2026-07-21_excelion_summary.md
    ├── 2026-07-17_super_robot_vs_real_robot.md
    ├── 2026-05-26_gelgoog_design.md
    └── 2026-06-21_getter_design.md
```

그리고 문서 작성 규칙은 이렇게 가져가면 좋겠습니다.

---

## 프로젝트 핵심 문서

### `00_project_overview.md`

```
# EXCELION Project Overview

## Concept

엑셀리온은 고전 슈퍼로봇의 영웅성과 현대적인 메카닉 디자인을 결합한
게임 프로젝트이다.

## Core Keywords

- Super Robot
- Modern Mechanical Design
- Parametric Modeling
- 3D Printing
- Cinematic Combat

## Scale

Main Robot:
- Height: 25m

## Design Direction

"생명체 같은 곡선과 기계 구조의 융합"

Organic:
- 생물적인 흐름
- 근육 같은 구조
- 존재감 있는 실루엣

Mechanical:
- 내부 프레임
- 구동부
- 장갑 패널
```

---

## 디자인 철학

### `design/design_philosophy.md`

```
# Design Philosophy

## Super Robot Evolution

기존 슈퍼로봇:
- 강한 상징성
- 거대한 실루엣
- 단순하지만 기억되는 형태

현대적 재해석:
- 실제 기계처럼 움직이는 구조
- 내부 프레임 표현
- 변형 가능한 파츠

## Avoid

- 지나친 밀리터리화
- 서양식 SF 느낌
- 장식만 많은 복잡성

## Maintain

- 영웅적인 자세
- 강한 얼굴 디자인
- 거대한 존재감
```

---

## 파라메트릭 모델링 기준

### `design/parametric_modeling.md`

```
# Parametric Modeling Rules

## Goal

스크립트로 기본 메쉬 생성 후
수동 수정 가능한 구조 확보.

## Parameters

Robot:
- Height
- Shoulder width
- Limb ratio
- Armor thickness

Armor:
- Curvature
- Panel spacing
- Mechanical detail density

Wing:
- Angle
- Length
- Spread
```

---

## 현재까지 결정된 디자인 데이터

### `decisions/DEC-001_scale_25m.md`

```
# DEC-001

## Decision

메인 로봇 크기는 25m급으로 설정.

## Reason

- 슈퍼로봇 특유의 압도감
- 전투 연출 가능
- 3D 출력 시 존재감 확보
```

---

이 구조로 시작하면 이후 대화에서:

- "엑셀리온 보스 디자인"
- "잡몹 메카"
- "진 겟타 계열 발전형"
- "3D 프린트용 내부 프레임"
- "Blender 생성 스크립트"

같은 내용도 자연스럽게 하위 문서로 확장 가능합니다.

다음 단계로는 `excelion/docs/README.md`와 `00_project_overview.md`를 기준 문서로 만들고, 지금까지의 대화 내용을 실제 Markdown 데이터로 변환하면 됩니다.

네

좋습니다. 그러면 다음 단계는 **Atlas에 바로 커밋 가능한 Markdown 문서화 작업**으로 진행하면 됩니다.

우선 현재까지의 대화를 기반으로 아래 파일들을 작성하는 순서가 좋겠습니다.

```
projects/excelion/docs/
```

### 1단계: 프로젝트 기준 문서

생성:

```
README.md
00_project_overview.md
01_world_setting.md
02_game_concept.md
```

역할:

- 프로젝트 정체성 고정
- 이후 AI가 읽을 기준점 확보
- 새로운 아이디어가 들어올 때 방향 판단 기준

---

### 2단계: 메카 디자인 데이터베이스

생성:

```
robot/
├── README.md
├── 01_main_robot_design.md
├── 02_internal_frame.md
├── 03_weapon_system.md
└── 04_enemy_mecha.md
```

현재 확보된 내용:

**메인 로봇**

- 25m급
- 현대적 슈퍼로봇
- 생물적 곡선 + 기계 구조
- 내부 프레임 표현
- 3D 프린트 가능 구조

**디자인 방향**

- 지나친 서양 SF 느낌 배제
- 장식 과잉보다 실루엣 중시
- 어깨는 유선형
- 핀 판넬/드론 전개 구조
- 배틀윙은 등 연결형
- 박쥐 날개에서 영감
- 전개 시 수평 기반, 끝부분 약 30도 상승

---

### 3단계: 제작 파이프라인

생성:

```
development/
├── modeling_pipeline.md
├── blender_workflow.md
└── script_generation.md
```

핵심:

```
컨셉
 ↓
파라미터 정의
 ↓
스크립트 기본 메쉬 생성
 ↓
수동 모델링 수정
 ↓
디테일 추가
 ↓
3D 출력 검증
```

---

### 4단계: 의사결정 기록

생성:

```
decisions/
```

예:

```
DEC-001_scale_25m.md
DEC-002_modern_super_robot.md
DEC-003_organic_mechanical_style.md
DEC-004_parametric_workflow.md
```

이 부분이 중요합니다.

나중에 "왜 이렇게 설계했지?"라는 문제가 생겼을 때 단순 이미지보다 **설계 의도**가 남습니다.

---

최종적으로 Atlas에서는:

```
Excelion
 ├─ 세계관
 ├─ 게임 시스템
 ├─ 메카 디자인
 ├─ 모델링 기술
 ├─ 결정 기록
 └─ 대화 아카이브
```

형태의 하나의 개발 문서가 됩니다.

다음 작업은 바로 **`README.md` + `00_project_overview.md` 실제 Markdown 완성본 작성**으로 진행하면 됩니다.

네

좋습니다. Atlas의 `projects/excelion/docs/` 첫 문서로 사용할 수 있도록 **프로젝트 기준 문서 2개**를 작성하겠습니다.

저장 위치:

```
Atlas/projects/excelion/docs/
├── README.md
└── 00_project_overview.md
```

---

### `README.md`

```
# EXCELION PROJECT

## Overview

EXCELION은 고전 슈퍼로봇의 상징성과 현대적인 메카 디자인,
게임 플레이 요소를 결합하는 창작 프로젝트이다.

이 프로젝트는 다음 목표를 가진다.

- 기억에 남는 강력한 로봇 실루엣 제작
- 생물적인 곡선과 기계 구조의 융합
- 파라메트릭 기반 3D 모델링
- 3D 프린팅 가능한 메카 구조 개발
- 게임용 세계관 및 전투 시스템 구축


---

# Project Structure

## docs/

프로젝트 기획 및 설계 문서
```

docs/  
├── 00_project_overview.md  
├── 01_world_setting.md  
├── 02_game_concept.md  
│  
├── robot/  
│ ├── main_robot_design.md  
│ ├── internal_frame.md  
│ ├── weapon_system.md  
│ └── enemy_mecha.md  
│  
├── design/  
│ ├── design_philosophy.md  
│ ├── parametric_modeling.md  
│ └── 3d_printing_notes.md  
│  
├── development/  
│ ├── blender_workflow.md  
│ └── script_generation.md  
│  
├── decisions/  
│  
└── conversation_log/

```


---

# Design Principle

EXCELION의 핵심 방향은 다음 문장으로 정의한다.

> "고전 슈퍼로봇의 영혼을 현대적인 기계 생명체로 재해석한다."


---

# Development Status

## Current Phase

Concept Development

## Completed

- 프로젝트 방향 설정
- 메카 디자인 철학 정의
- 25m급 로봇 스케일 결정
- 파라메트릭 모델링 방향 설정

## Next Steps

- 메인 로봇 상세 설계
- 내부 프레임 구조 개발
- 무장 시스템 설계
- 적 메카 디자인
- Blender 기반 생성 스크립트 개발
```

---

### `00_project_overview.md`

```
# EXCELION Project Overview


## 1. Project Identity

EXCELION은 슈퍼로봇 장르의 상징성과 현대적인 메카닉 디자인을 결합한
게임 기반 메카 프로젝트이다.


단순히 현실적인 로봇을 만드는 것이 아니라,
"보는 순간 기억되는 존재"를 목표로 한다.


---

# 2. Core Concept


## Theme

Mechanical Lifeform


기계이지만 생명체와 같은 흐름을 가진다.


### Organic Elements

- 근육 같은 구조
- 생물적인 곡선
- 유기적인 장갑 연결
- 생명체 같은 움직임


### Mechanical Elements

- 내부 프레임
- 구동 시스템
- 장갑 패널
- 기계적 디테일


---

# 3. Design Direction


## Super Robot Evolution


기존 슈퍼로봇:

- 강렬한 얼굴
- 거대한 실루엣
- 상징적인 무장
- 영웅적인 존재감


EXCELION 방향:

- 현대적인 구조 해석
- 실제 움직일 것 같은 관절 구조
- 내부와 외부가 연결된 설계
- 3D 모델링 가능한 구조


---

# 4. Main Robot Specification


## Scale

Height:
```

25m class

```


## Design Keywords

- Heroic
- Powerful
- Organic Mechanical
- Modern Super Robot
- Parametric Design


---

# 5. Modeling Philosophy


## Workflow

```

Concept  
↓  
Parameter Definition  
↓  
Base Mesh Generation  
↓  
Manual Refinement  
↓  
Mechanical Detail  
↓  
3D Print Validation

```


목표는 AI 또는 스크립트로 기본 구조를 생성하고,
인간 디자이너가 세부 조형을 발전시키는 방식이다.


---

# 6. Visual Identity


## Avoid

- 지나친 밀리터리 메카 느낌
- 서양 SF 로봇 스타일
- 의미 없는 장식 증가


## Maintain

- 슈퍼로봇 특유의 강한 실루엣
- 얼굴의 상징성
- 거대한 존재감
- 전투에서 느껴지는 무게감


---

# 7. Future Expansion


EXCELION 프로젝트는 다음 영역으로 확장한다.


## Game

- 전투 시스템
- 보스 메카
- 잡몹 유닛
- 파일럿 설정


## Design

- 메인 로봇
- 적 로봇
- 변형 시스템
- 무장 시스템


## Production

- Blender 모델링
- Python 생성 스크립트
- 3D 프린팅
- 렌더링
```

---

이 두 파일이 들어가면 Atlas가 이후 대화에서 **"엑셀리온은 어떤 프로젝트인가?"**를 판단하는 기준점 역할을 하게 됩니다.

다음 문서는 연결성이 가장 높은 순서로:

1. `robot/main_robot_design.md`
2. `design/design_philosophy.md`
3. `development/parametric_modeling.md`

순으로 작성하는 것이 좋겠습니다.