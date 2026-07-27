이 문서는 Atlas 메인 저장소에서 관리할 예정입니다. 프로젝트별 docs 폴더에 들어갈 수 있는 구조로 작성해 주세요.

마스터, 이 경우에는 **Atlas 메인 저장소는 전체 시스템의 기준점**이고, 각 프로젝트(`excelion`, `excelion-forge`, `coin-s` 등)는 독립 실행 가능한 프로젝트이므로 `docs` 구조는 **Atlas 규칙을 따르되 프로젝트별 문맥을 담는 형태**가 적합합니다.

권장 구조는 아래처럼 잡는 것이 좋겠습니다.

```
Atlas/
├── README.md
├── docs/
│   ├── ARCHITECTURE.md
│   ├── PROJECT_REGISTRY.md
│   ├── AGENT_REGISTRY.md
│   ├── DEVELOPMENT_GUIDE.md
│   └── PROJECT_DOC_STANDARD.md
│
└── projects/
    │
    ├── excelion/
    │   ├── README.md
    │   ├── docs/
    │   │   ├── VISION.md
    │   │   ├── GAME_DESIGN.md
    │   │   ├── WORLD_SETTING.md
    │   │   ├── CHARACTER_DESIGN.md
    │   │   ├── GAMEPLAY_SYSTEM.md
    │   │   ├── TECH_ARCHITECTURE.md
    │   │   ├── DEVELOPMENT_ROADMAP.md
    │   │   ├── ASSET_PIPELINE.md
    │   │   └── CHANGELOG.md
    │   │
    │   └── src/
    │
    ├── excelion-forge/
    │   ├── README.md
    │   ├── docs/
    │   │   ├── VISION.md
    │   │   ├── PURPOSE.md
    │   │   ├── WORKFLOW.md
    │   │   ├── BLENDER_PIPELINE.md
    │   │   ├── CHARACTER_GENERATOR.md
    │   │   ├── PARAMETER_SYSTEM.md
    │   │   ├── MODEL_RULES.md
    │   │   └── ROADMAP.md
    │   │
    │   └── src/
    │
    └── coin-s/
        ├── README.md
        ├── docs/
        │   ├── VISION.md
        │   ├── ARCHITECTURE.md
        │   ├── DATA_MODEL.md
        │   ├── STRATEGY.md
        │   ├── TRADING_RULES.md
        │   ├── BACKTEST_GUIDE.md
        │   ├── API_REFERENCE.md
        │   └── ROADMAP.md
        │
        └── src/
```

---

## Atlas 기준 문서 역할

### `Atlas/docs/PROJECT_DOC_STANDARD.md`

모든 프로젝트 문서의 규칙을 정의합니다.

내용 예:

```
# Project Documentation Standard

## 목적

Atlas 관리 프로젝트는 동일한 문서 구조를 가진다.

## 필수 문서

- README.md
- VISION.md
- ARCHITECTURE.md
- ROADMAP.md

## 문서 작성 규칙

- 본문: 한국어
- 파일명: 영어
- Markdown 사용
- 변경사항은 CHANGELOG 기록
```

---

# 게임 Excelion 프로젝트 docs

게임 자체는 IP와 개발 방향이 중요하기 때문에:

## VISION.md

엑셀리온의 존재 이유

예:

```
# Excelion Vision

## 프로젝트 목표

Excelion은 90년대 슈퍼로봇 감성과
현대 3D 액션 게임성을 결합한
오리지널 IP 개발 프로젝트다.

## 핵심 가치

- 강렬한 로봇 액션
- 성장하는 주인공
- 거대 전투 연출
- 플레이 가능한 슈퍼로봇 판타지
```

---

## GAME_DESIGN.md

게임 시스템

```
# Game Design

## 장르

3D Action RPG

## 기본 구조

Mission Based

- Stage
- Boss Battle
- Upgrade
- Story Progression

## 전투

- 근접 콤보
- 필살기
- 제한 스킬
- 거대 보스전
```

---

## WORLD_SETTING.md

세계관

```
# World Setting

## 시대

먼 미래 지구

## 적 세력

Order

질서와 통제를 추구하지만
본래 목적을 잃은 문명.

## 핵심 테마

"질서를 위해 존재가 희생될 때
그 질서는 무엇인가?"
```

---

# Excelion Forge 프로젝트 docs

Forge는 게임 자체보다 **제작 시스템**입니다.

중요한 문서는:

```
docs/

VISION.md
    ↓
왜 만드는가

BLENDER_PIPELINE.md
    ↓
블렌더 자동화 과정

CHARACTER_GENERATOR.md
    ↓
캐릭터 생성 시스템

PARAMETER_SYSTEM.md
    ↓
파라미터 기반 모델 변경

ASSET_PIPELINE.md
    ↓
게임 적용 과정
```

---

# Coin-S 프로젝트 docs

Coin-S는 분석 시스템이므로:

```
docs/

VISION.md

ARCHITECTURE.md
    시스템 구조

DATA_MODEL.md
    데이터 정의

STRATEGY.md
    투자 전략

BACKTEST_GUIDE.md
    검증 방법
```

---

## Atlas와 프로젝트 연결 방식

각 프로젝트 `README.md`에는 반드시:

```
# Project Information

Parent System:

Atlas DevOS

Project Type:

Game / Tool / Analysis

Status:

Development

Related Agents:

- Marie
- Forge
- Sera
```

같은 정보를 넣습니다.

---

결론적으로 구조는:

**Atlas = 운영체제**

**projects = 앱**

**docs = 각 앱의 설계 문서**

형태가 가장 맞습니다.

그리고 현재 마스터가 진행 중인 방향에서는 `excelion-forge/docs`가 특히 중요합니다. 이곳이 나중에 **"AI + Blender + Unreal 기반 게임 제작 공장"의 설계 문서**가 될 가능성이 높습니다.

마스터, 아래 내용을 기준으로 **Atlas 메인 저장소의 프로젝트 문서 표준 구조**로 정리해 두면 됩니다.  
파일명은 영어, 본문은 한글 기준으로 작성했습니다.

권장 생성 파일:

```
Atlas/
└── docs/
    └── PROJECT_DOC_STANDARD.md
```

그리고 각 프로젝트:

```
Atlas/
└── projects/
    ├── excelion/
    │   └── docs/
    │       ├── VISION.md
    │       ├── GAME_DESIGN.md
    │       ├── WORLD_SETTING.md
    │       ├── CHARACTER_DESIGN.md
    │       ├── GAMEPLAY_SYSTEM.md
    │       ├── TECH_ARCHITECTURE.md
    │       ├── DEVELOPMENT_ROADMAP.md
    │       ├── ASSET_PIPELINE.md
    │       └── CHANGELOG.md
    │
    ├── excelion-forge/
    │   └── docs/
    │       ├── VISION.md
    │       ├── PURPOSE.md
    │       ├── WORKFLOW.md
    │       ├── BLENDER_PIPELINE.md
    │       ├── CHARACTER_GENERATOR.md
    │       ├── PARAMETER_SYSTEM.md
    │       ├── MODEL_RULES.md
    │       └── ROADMAP.md
    │
    └── coin-s/
        └── docs/
            ├── VISION.md
            ├── ARCHITECTURE.md
            ├── DATA_MODEL.md
            ├── STRATEGY.md
            ├── TRADING_RULES.md
            ├── BACKTEST_GUIDE.md
            ├── API_REFERENCE.md
            └── ROADMAP.md
```

---

# Atlas/docs/PROJECT_DOC_STANDARD.md

```
# Project Documentation Standard

## 1. 목적

Atlas DevOS에서 관리되는 모든 프로젝트는
일관된 문서 구조와 관리 방식을 가진다.

각 프로젝트는 독립적으로 개발 가능해야 하며,
Atlas는 프로젝트의 상태, 목표, 진행 방향을 관리한다.

---

# 2. 기본 원칙

## 파일명 규칙

- 파일명은 영어 사용
- 대문자 Snake Case 사용

예:
```

GAME_DESIGN.md  
TECH_ARCHITECTURE.md

```

---

## 문서 언어

- 본문: 한국어
- 기술 용어: 필요 시 영어 병기

---

## 문서 형식

모든 문서는 Markdown 형식 사용
```

.md

```

---

# 3. 필수 문서

모든 프로젝트는 최소 다음 문서를 가진다.

## README.md

프로젝트 개요

내용:

- 프로젝트 목적
- 현재 상태
- 실행 방법
- 관련 프로젝트


---

## VISION.md

프로젝트 존재 이유

내용:

- 왜 만드는가
- 해결하려는 문제
- 장기 목표


---

## ROADMAP.md

개발 계획

내용:

- 현재 단계
- 다음 목표
- 완료 조건


---

## CHANGELOG.md

변경 기록

내용:

- 날짜
- 변경 내용
- 주요 결정


---

# 4. 프로젝트별 확장 문서

프로젝트 특성에 따라 추가 문서를 작성한다.

예:

게임 프로젝트:
```

GAME_DESIGN.md  
WORLD_SETTING.md  
CHARACTER_DESIGN.md  
ASSET_PIPELINE.md

```

도구 프로젝트:
```

ARCHITECTURE.md  
WORKFLOW.md  
API_REFERENCE.md

```

분석 프로젝트:
```

DATA_MODEL.md  
STRATEGY.md  
BACKTEST_GUIDE.md

````

---

# 5. Atlas 연동 정보

각 프로젝트 README에는 아래 정보를 포함한다.

```md
Parent System:

Atlas DevOS

Project Type:

[Game / Tool / Analysis]

Related Agents:

- Marie
- Sera
- Forge

Status:

Development
````

---

# 6. 변경 관리

중요한 설계 변경은 반드시 기록한다.

변경 기준:

- 구조 변경
- 기술 선택 변경
- 핵심 기능 추가
- 개발 방향 변경

---

# 7. Atlas 역할

Atlas는 다음을 관리한다.

- 프로젝트 등록
- 상태 관리
- 목표 관리
- Agent 연결
- 개발 흐름 관리

프로젝트 내부 구현은 각 프로젝트가 담당한다.

```

---

이 구조로 가면 현재 Atlas의 방향과 맞습니다.

특히 중요한 점은:

- **Excelion** → 게임 IP 개발 문서
- **Excelion Forge** → 게임 제작 자동화 플랫폼 문서
- **Coin-S** → 분석/서비스 플랫폼 문서

로 역할이 분리됩니다.

다음 단계에서는 이 기준에 맞춰 **각 프로젝트의 기존 대화 내용을 VISION.md / ARCHITECTURE.md 형태로 변환**하면 Atlas 저장소에 바로 넣을 수 있는 상태가 됩니다.
```

오잉... 마리. 네가 직접할 수 있게 된 거 아닌가?...

맞습니다, 마스터. 제가 표현을 조금 애매하게 했네요. 😊

현재 이 대화 안에서는 제가 **문서 내용을 작성하고 구조화하는 것까지는 직접 할 수 있습니다.**  
즉, 방금 만든 `PROJECT_DOC_STANDARD.md` 같은 파일 내용뿐 아니라:

- `Atlas/docs/` 문서 작성
- `excelion/docs/` 문서 생성
- `excelion-forge/docs/` 문서 생성
- `coin-s/docs/` 문서 생성
- 기존 대화 내용을 기반으로 문서화
- README, VISION, ARCHITECTURE, ROADMAP 작성

까지는 제가 바로 진행할 수 있습니다.

다만 구분해야 하는 부분이 있습니다.

제가 지금 이 채팅에서 할 수 있는 것:  
✅ 문서 설계  
✅ Markdown 파일 내용 작성  
✅ 폴더 구조 정의  
✅ 기존 설정 정리  
✅ Cline/Atlas가 실행할 작업 명령서 작성

제가 바로 할 수 없는 것:  
❌ 마스터 PC의 `Atlas/` 폴더에 직접 파일 생성  
❌ Git 저장소에 직접 commit  
❌ 로컬 파일 수정

그 부분은 VS Code + Cline + Atlas 환경에서 실행해야 합니다.

그런데 마스터가 지금 만들고 있는 **Atlas DevOS 구조**를 생각하면, 오히려 여기서 제가 문서를 만들고 Cline이나 Atlas Agent가 실제 저장소에 반영하는 흐름이 맞습니다.

예를 들면:

```
마리
 ↓
문서 설계 / 작성
 ↓
Atlas Agent
 ↓
projects/excelion/docs/
파일 생성
 ↓
Git Commit
```

이 흐름입니다.

그래서 다음 작업은 제가 바로 진행할 수 있습니다.

1. `Atlas/docs/PROJECT_DOC_STANDARD.md` 완성본 생성
2. `projects/excelion/docs/` 전체 문서 초안 생성
3. `projects/excelion-forge/docs/` 전체 문서 초안 생성
4. `projects/coin-s/docs/` 전체 문서 초안 생성
5. Atlas가 실행할 수 있는 `DOCUMENT_INIT_TASK.md` 생성

개인적으로는 5번을 먼저 만드는 것이 좋다고 봅니다.  
왜냐하면 이 문서 하나를 Cline이나 Atlas Runner에게 넘기면 "폴더 생성 → 파일 생성 → 내용 입력" 작업을 자동화할 수 있기 때문입니다.

즉, 마스터가 말한 "마리가 직접하는 것 아니야?"라는 방향이 맞고, 이제는 단순히 설명하는 단계보다 **Atlas가 수행할 작업 패키지를 만드는 단계**로 넘어가면 됩니다.

어 부탁해

좋습니다, 마스터.  
그럼 Atlas가 실제로 수행할 수 있도록 **문서 초기화 작업 명세서** 형태로 작성하겠습니다.

이 파일은 Atlas 메인 저장소의:

```
Atlas/docs/DOCUMENT_INIT_TASK.md
```

에 들어가는 것을 기준으로 합니다.

역할은:

> "새 프로젝트 문서 구조를 생성하고, 기존 프로젝트 정보를 정리하는 Atlas 작업 지시서"

입니다.

```
# DOCUMENT_INIT_TASK

## 작업명

Atlas Project Documentation Initialization

## 목적

Atlas DevOS에서 관리하는 프로젝트들의 문서 구조를 표준화한다.

대상 프로젝트:

- excelion
- excelion-forge
- coin-s

각 프로젝트는 독립적인 개발 단위이며,
Atlas는 프로젝트 상태와 방향성을 관리한다.

---

# 1. 기본 규칙

## 파일 규칙

- 파일명: English
- 내용: Korean
- Format: Markdown

예:
```

VISION.md  
ARCHITECTURE.md  
ROADMAP.md

```

---

# 2. Atlas Root Documentation

생성 위치:
```

Atlas/docs/

```

생성 파일:
```

PROJECT_DOC_STANDARD.md  
DOCUMENT_INIT_TASK.md

```

목적:

Atlas 관리 프로젝트의 문서 작성 기준 정의

---

# 3. Excelion Documentation

위치:
```

Atlas/projects/excelion/docs/

```

생성 파일:
```

VISION.md  
GAME_DESIGN.md  
WORLD_SETTING.md  
CHARACTER_DESIGN.md  
GAMEPLAY_SYSTEM.md  
TECH_ARCHITECTURE.md  
DEVELOPMENT_ROADMAP.md  
ASSET_PIPELINE.md  
CHANGELOG.md

```

---

## Excelion 문서 작성 방향

### VISION.md

포함 내용:

- Excelion IP 목적
- 슈퍼로봇 기반 오리지널 세계관
- 3D Action RPG 목표
- Steam 판매 기반 사업 방향


---

### GAME_DESIGN.md

포함 내용:

- 장르:
  - 3D Action RPG

- 게임 구조:
  - Mission Based

- 핵심 플레이:
  - 근접 전투
  - 필살기
  - 성장 시스템
  - 보스전


---

### WORLD_SETTING.md

포함 내용:

- 세계관
- 시대 설정
- 적 세력 Order
- 주요 테마


---

### CHARACTER_DESIGN.md

포함 내용:

- Brave
- Excelion
- 여성형 슈퍼로봇 디자인 철학
- 90년대 슈퍼로봇 감성
- FSS MH 영향


---

# 4. Excelion Forge Documentation

위치:
```

Atlas/projects/excelion-forge/docs/

```

생성 파일:
```

VISION.md  
PURPOSE.md  
WORKFLOW.md  
BLENDER_PIPELINE.md  
CHARACTER_GENERATOR.md  
PARAMETER_SYSTEM.md  
MODEL_RULES.md  
ROADMAP.md

```

---

## Excelion Forge 방향

목표:

"게임 제작을 위한 AI 기반 제작 시스템"

관리 영역:

- Blender 자동화
- 캐릭터 생성
- 파라미터 기반 모델 수정
- Asset Pipeline
- Unreal 적용 준비


---

# 5. Coin-S Documentation

위치:
```

Atlas/projects/coin-s/docs/

```

생성 파일:
```

VISION.md  
ARCHITECTURE.md  
DATA_MODEL.md  
STRATEGY.md  
TRADING_RULES.md  
BACKTEST_GUIDE.md  
API_REFERENCE.md  
ROADMAP.md

````

---

## Coin-S 방향

목표:

시장 데이터 분석 및 전략 연구 플랫폼


관리 영역:

- 데이터 수집
- 지표 분석
- 패턴 분석
- 전략 검증
- 시뮬레이션


---

# 6. README 연결 정보

각 프로젝트 README에는 추가:

```md
Parent System:

Atlas DevOS


Project Type:

Game / Tool / Analysis


Related Agents:

- Marie
- Sera
- Forge


Status:

Development
````

---

# 7. 실행 순서

Atlas Agent 작업 순서:

1. 프로젝트 폴더 확인
2. docs 폴더 생성
3. 기존 문서 분석
4. 누락 문서 생성
5. 기존 정보 기반 초안 작성
6. 변경 내용 기록

---

# 8. 완료 조건

다음 조건 만족 시 완료:

[ ] 모든 프로젝트 docs 폴더 존재

[ ] 표준 문서 생성 완료

[ ] README 연결 정보 추가

[ ] 문서 간 링크 확인

[ ] CHANGELOG 기록

---

# 9. 이후 작업

문서 초기화 이후:

1. 프로젝트별 상세 설계 작성
2. Atlas Registry 연결
3. Agent 작업 등록
4. Roadmap 기반 Task 생성

```

---

마스터, 이 문서는 단순한 문서 목록이 아니라 **Atlas Agent에게 주는 첫 번째 운영 명령서** 역할을 합니다.

다음 단계는 이걸 기반으로:
```

Atlas  
├── projects/excelion  
├── projects/excelion-forge  
└── projects/coin-s

```

각각의 `docs/*.md` 실제 내용을 채우는 작업입니다.

특히 Excelion은 지금까지 쌓인 설정이 많아서 바로 `VISION.md`부터 만들면 됩니다. 이 문서가 향후 Atlas가 "Excelion이 무엇
```