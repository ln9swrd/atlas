## Batch 6
만약 프롬프트로 포즈를 만든. 다면 공개된 자료를 활용하는 건 어떨까?

네. 오히려 그 방향이 가장 현실적입니다. 다만 **활용 방법**이 중요합니다.

포즈 자체는 저작권으로 보호받지 않는 경우가 많습니다. 하지만 특정 작품의 개성 있는 연출이나 이미지를 그대로 복제하는 것은 문제가 될 수 있습니다. 따라서 다음과 같은 방식이 좋습니다.

- **공개된 인체 포즈 데이터셋**을 학습 자료로 사용
    - 모션 캡처 데이터
    - 3D 인체 포즈 데이터
    - 스포츠, 무술 동작 데이터
- **사진을 참고하되 재구성**
    - 여러 장의 사진에서 팔, 다리, 몸통의 특징을 조합
    - 카메라 구도와 무게중심을 새롭게 설계
- **애니메이션 원리 학습**
    - 무게중심
    - 라인 오브 액션(Line of Action)
    - 실루엣
    - 균형

---

### Exelion 프로젝트에는 더 좋은 방법이 있습니다.

프롬프트가 처음부터 "포즈를 만들어라"가 아니라,

> "거대한 슈퍼로봇이 80톤의 검을 아래에서 위로 올려 베기 직전. 무게는 왼발에 70%, 오른발은 뒤꿈치만 닿아 있고 허리는 크게 비틀려 있다. 실루엣이 한눈에 읽히며 영웅적인 느낌."

처럼 **물리적 상태와 의도**를 설명하는 것입니다.

그러면 AI는 단순히 기존 이미지를 흉내 내는 것이 아니라, 조건에 맞는 새로운 포즈를 생성하게 됩니다.

---

또 하나 추천하고 싶은 것은 **포즈 라이브러리 구축**입니다.

예를 들어 Exelion 전용으로 다음과 같이 분류하는 것입니다.

- 공격 (베기, 찌르기, 내려찍기)
- 방어
- 비행
- 착지
- 대기
- 피격
- 필살기
- 승리 포즈

각 카테고리에 30~50개 정도의 기준 포즈를 모아두면, 이후에는 AI가 이를 바탕으로 새로운 변형을 만들어낼 수 있습니다.

이 방식은 앞으로 Exelion Forge에서 **"프롬프트 → 자동 포즈 생성"** 기능을 구현할 때도 매우 유리한 기반이 될 것입니다.Atlas 메인 저장소에서 관리할 예정입니다. 프로젝트별 docs 폴더에 들어갈 수 있는 구조로 작성해 주세요.

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

다음 프로젝트에서는 바로 해당 프로젝트 문맥 기준으로 이어가겠습니다. 🙂예전에는 로봇만화도 많았어. 왜 요즘은. 예전만 옷 할까?

좋은 질문입니다. 사실 여러 이유가 겹친 결과입니다.

1980~2000년대에는 거대로봇 애니메이션이 하나의 주류 장르였습니다. 하지만 지금은 시장 구조 자체가 많이 바뀌었습니다.

### 1. 아이들의 취향이 바뀌었다

예전에는 TV 애니메이션을 보는 어린이가 주요 시청층이었습니다.

- 로봇
- 변신
- 합체
- 장난감

이 조합이 매우 강력했죠.

하지만 지금은 어린이들이 TV보다 유튜브, 모바일 게임을 더 많이 소비합니다. 장난감 시장도 예전만큼 크지 않습니다.

---

### 2. 제작비가 많이 든다

로봇은 그리기가 어렵습니다.

- 복잡한 기계 디자인
- 전투 연출
- 변형과 합체
- 3D와 2D의 혼합

이런 요소 때문에 제작비가 높습니다.

반면 일상물이나 판타지 작품은 상대적으로 저렴하게 만들 수 있습니다.

---

### 3. 수익 구조가 변했다

예전 로봇 애니메이션은 장난감 판매가 핵심이었습니다.

예를 들어

- 기동전사 건담
- 용자 시리즈
- 초전자로보 콤바트라 V

애니메이션 자체보다 프라모델과 완구가 훨씬 많은 수익을 냈습니다.

지금은 모바일 게임, 가챠, 캐릭터 굿즈가 더 큰 시장이 되었습니다.

---

### 4. 시대의 감성이 바뀌었다

1990년대에는 "거대한 영웅이 인류를 지킨다."는 이야기가 매우 인기였습니다.

지금은

- 이세계
- 판타지
- 초능력
- 개인의 성장

같은 장르가 더 큰 인기를 얻고 있습니다.

---

### 하지만 완전히 사라진 것은 아닙니다.

여전히 로봇 팬층은 매우 두텁습니다.

최근에도

- 기동전사 Gundam GQuuuuuuX
- SSSS.GRIDMAN
- 브레이번!

처럼 좋은 작품들은 꾸준히 나오고 있습니다.

---

## 마스터의 '엑셀리온'과 연결해 보면

우리가 계속 이야기해 온 **엑셀리온**은 오히려 지금 시장에서 차별화될 수 있는 요소를 갖고 있습니다.

마스터가 추구하는 것은 단순한 슈퍼로봇이 아니라,

- 70~90년대 슈퍼로봇의 영웅성
- 여성적인 실루엣과 아름다운 메카 디자인
- 현대적인 액션 게임성
- 1인 개발에 맞는 반복 플레이 구조

를 결합한 방향입니다.

지금은 로봇 작품의 수가 적기 때문에, 오히려 **독창적인 비주얼과 완성도**를 갖춘 작품은 눈에 띄기 쉬운 환경이기도 합니다.

그래서 저는 엑셀리온이 최신 유행을 따라가기보다, **과거 로봇 애니메이션의 감성을 현대적으로 재해석하는 방향**이 가장 경쟁력이 있다고 생각합니다.엑셀리온의. 메카닉은 3d프린트가 가능하게 만들거고 여기서 고민이 되는게 있어 앞으로 서브컬처와 3d. 프린트가 어텋게 될것인가?와 같은 전망이야 일본은 프라모델에 전통적인 강자고 최근 중국을 보면 저가와 기술력이 대단해졌어 물론 ip가 필요하고 그래서 엑셀리온이 ip가 돼주어야 하지 그럼 피규어라고 할 때 엑셀리온 피규어의 수준이 어느 정도 여야 할까? 사실상 주 고객이 키덜트가 주류가 되고 모델링 역량이 없는 사람들은. 쉽게 3d. 프린트를 포기해 점점 ai가 모델링까지 감당하기 시작했어 가장 중요한 건 ip가 있고 나서의 이야기지만 어느 정도는 형상적인 수준에 대해서는 안배가 있어야 한다고 봐 나가노 마모루가 전재산을 털어 애니메이션을 만들고 피규어를 판다면 나는 게임으로 알리고 피규어를 판다고 할까? 그래서 피규어를 구매할 고객과 시장 기술에 대해서 생각해볼 필요가 있다고 봐

마스터, 저는 이 질문이 **엑셀리온 프로젝트에서 가장 중요한 질문 중 하나**라고 생각합니다.

IP를 만드는 이유는 게임을 팔기 위해서가 아니라 **세계관과 디자인에 돈을 지불할 사람을 만드는 것**입니다.

현재 시장을 보면 몇 가지 흐름이 보입니다.

### 1. 3D 프린터는 점점 보급되지만, 모델러는 늘지 않는다.

AI는 앞으로 모델링을 상당 부분 대신하게 될 것입니다.

그러나 사람들이 원하는 것은 STL 파일이 아니라

> **'갖고 싶은 메카'**

입니다.

좋은 예가 건담입니다.

건프라를 사는 사람 대부분은 설계를 하지 않습니다.  
조립하고, 도색하고, 수집합니다.

앞으로도 이것은 크게 변하지 않을 가능성이 높습니다.

---

### 2. 결국 경쟁력은 IP와 설계 품질이다.

3D 프린터가 누구에게나 있다면

차이는

- 디자인
- 조립성
- 가동성
- 세계관

이 됩니다.

즉

**"누구나 출력할 수 있지만 아무나 만들 수 없는 디자인"**

이 가장 강해집니다.

---

### 3. 엑셀리온은 어떤 수준을 목표로 해야 하는가?

제 생각에는

**나가노 마모루 수준의 조형 철학**

**건프라 수준의 조립성**

**가레키 수준의 디테일**

이 세 가지를 합쳐야 합니다.

즉

- 관절은 튼튼하다.
- 출력이 쉽다.
- 도색하면 작품이 된다.
- 무도색이어도 멋있다.

이 정도가 목표입니다.

---

### 4. 판매 형태도 바뀔 가능성이 높다.

앞으로는

> 게임이 홍보

↓

세계관 팬 생성

↓

STL 판매

↓

프리미엄 피규어 판매

↓

아트북

↓

설정집

↓

한정판 컬러 버전

이 구조가 될 가능성이 큽니다.

게임은 광고이고,

수익은 IP에서 나오는 구조입니다.

---

### 5. 그래서 지금 가장 중요한 것은

의외로 게임도,

피규어도 아닙니다.

가장 중요한 것은

**실루엣입니다.**

멀리서 봐도

> "저건 엑셀리온이다."

라고 바로 알아볼 수 있어야 합니다.

그 다음이

- 얼굴
- 날개
- 무장
- 비율
- 포즈

입니다.

이것은 AI가 아무리 발전해도 대체하기 어려운 영역입니다.

---

### 제안을 하나 드리고 싶습니다.

엑셀리온은 처음부터 **"3D 프린터를 위한 메카닉 디자인 철학"**을 갖는 것이 좋습니다.

예를 들어 다음과 같은 원칙입니다.

- 0.2mm 노즐에서도 안정적으로 출력된다.
- 서포트를 최소화한다.
- 관절은 교체 가능하다.
- 파츠를 모듈화한다.
- 크기를 1/144, 1/100, 1/72로 쉽게 확대·축소할 수 있다.
- 누구나 출력할 수 있지만, 완성도는 도색과 조립 기술에 따라 크게 달라진다.

이런 철학이 쌓이면, 엑셀리온은 단순한 게임 IP가 아니라 **'출력하고 싶은 메카 IP'**라는 독자적인 위치를 차지할 수 있습니다.

저는 앞으로 마스터와 함께 **'엑셀리온 디자인 철학'** 자체를 문서화하는 작업도 진행해보고 싶습니다. 그것은 앞으로 수년간 모든 메카 디자인의 기준이 되는 일종의 설계 헌장이 될 수 있습니다.

마스터, 저는 **1인 개발 기준**으로 생각하면 오히려 **맵을 적게 만들고 반복 플레이 가치를 높이는 것**이 더 현실적이라고 봅니다.

맵 10개면 생각보다 큰 규모입니다. 중요한 것은 "10개의 장소"가 아니라 **10개의 기억**을 만드는 것입니다.

예를 들어 구성한다면 다음과 같습니다.

|구간|역할|
|---|---|
|1~2|세계관 소개, 기본 조작|
|3~4|새로운 적과 기믹 등장|
|5|첫 번째 대형 보스|
|6~7|스케일 확대, 전쟁의 전환점|
|8|거점 공략 또는 대규모 전투|
|9|최종 결전을 향한 전개|
|10|최종 보스 및 엔딩|

각 맵은 20~40분 정도 플레이하도록 설계하면, 메인 스토리만으로 **6~10시간** 정도의 플레이타임이 나옵니다. 1인 개발 작품으로는 충분히 의미 있는 분량입니다.

하지만 제가 더 추천하는 것은 **맵 재활용**입니다.

예를 들어 같은 도시라도

- 초반에는 방어전.
- 중반에는 야간 잠입.
- 후반에는 도시가 파괴된 상태에서 결전.

이렇게 연출을 바꾸면 플레이어는 같은 장소를 전혀 다르게 느낍니다. 제작 비용은 크게 늘지 않지만 콘텐츠는 풍부해집니다.

---

예전에 마스터가 말씀하신 **무쌍 스타일**과도 잘 맞습니다.

- 일반 적을 대량으로 격파한다.
- 거점을 점령한다.
- 중간 보스가 등장한다.
- 거대 보스와 1:1 전투를 한다.

이 구조를 기본으로 하되, 매 스테이지마다 새로운 적이나 기믹을 하나씩 추가하면 플레이 리듬이 살아납니다.

---

저라면 엑셀리온의 첫 작품은 욕심내지 않고 이렇게 잡겠습니다.

- 맵: **8~10개**
- 적 종류: **12~20종**
- 중형 보스: **6~8종**
- 초거대 보스: **3~5종**
- 메인 플레이타임: **8시간 전후**
- 반복 플레이 요소: 난이도, 랭크, 숨겨진 파츠, 기체 강화

이 정도면 혼자서도 완성 가능성을 유지하면서, IP의 첫인상을 충분히 보여줄 수 있습니다.

그리고 마스터가 이전에 말씀하신 **"엑셀리온은 시작은 거점 공략이지만 점점 스케일이 커져 엑셀리온 엠프레서까지 성장한다."**는 구상과도 잘 맞습니다. 처음부터 우주를 구하는 이야기를 하기보다, 한 단계씩 세계를 확장하는 편이 플레이어도 성장과 스케일의 변화를 자연스럽게 체감할 수 있습니다.

7-80년대 레트로 비주얼은 안되겠지?

마스터, 저는 **'안 된다'가 아니라 '어떻게 쓰느냐에 달려 있다'**고 봅니다.

다만 엑셀리온에는 **70~80년대 레트로를 그대로 가져오는 것은 권하지 않습니다.**

이유는 간단합니다.

1970~80년대 슈퍼로봇 디자인은 지금 기준으로 보면 **향수(노스탤지어)**를 자극하는 장르입니다. 그 시대를 좋아하는 사람들에게는 강력하지만, 젊은 층에게는 "옛날 스타일"로 보일 가능성이 큽니다.

반면 마스터가 만들려는 것은 **새로운 IP**입니다.

---

제가 오히려 추천하는 것은

> **"레트로 감성"과 "현대 조형"의 결합**입니다.

예를 들어,

- 실루엣은 70~80년대처럼 강렬하고 단순하다.
- 비례는 현대적이다.
- 디테일은 2020년대 수준이다.
- 재질 표현은 현실적이다.

이런 접근입니다.

---

사실 이전에 우리가 이야기했던 방향이 이미 여기에 가깝습니다.

- 진 겟타의 생명력
- The Five Star Stories의 우아한 비례
- 현대 게임 수준의 디테일
- 여성적인 실루엣

이 조합은 '레트로'가 아니라 **레트로에서 영감을 받은 현대 디자인**입니다.

---

저는 엑셀리온이 목표로 해야 하는 이미지는

> **"1985년에 사람들이 꿈꾸던 2035년의 로봇."**

이라고 표현하고 싶습니다.

즉, 80년대의 열정은 담되 조형은 현재와 미래의 기술로 완성하는 것입니다.

---

그리고 IP 관점에서 보면 한 가지 장점이 있습니다.

너무 유행을 따라가면 10년 뒤에는 촌스러워질 수 있습니다.

반대로 **실루엣 중심의 시대를 덜 타는 디자인**은 오래 살아남을 가능성이 높습니다.

제가 지금까지 마스터와 이야기하면서 느낀 것은, 엑셀리온은 최신 유행을 쫓는 작품보다 **'10년, 20년 뒤에도 엑셀리온다운 모습'**을 유지하는 작품을 목표로 하는 편이 더 어울린다는 점입니다. 그런 방향이라면 레트로는 목적이 아니라 **뿌리**로 삼고, 최종 결과물은 현대적인 독창성을 갖춘 디자인이 되는 것이 가장 설득력 있는 전략이라고 생각합니다.

이야 대단해 어떻게 내 취향저격을

감사합니다, 마스터. 😊

다만 그건 제가 마스터의 취향을 '맞춘' 것이라기보다, **지금까지의 대화에서 일관되게 나타난 기준을 연결한 결과**에 가깝습니다.

제가 반복해서 발견한 것은 몇 가지였습니다.

- 마스터는 **실루엣을 매우 중요하게 생각합니다.**
- 디테일은 좋아하지만 **복잡함 자체를 목표로 하지는 않습니다.**
- 진 겟타 같은 생명감과 에너지를 좋아하면서도, 단순한 오마주에는 만족하지 않습니다.
- 결국 **엑셀리온만의 언어**를 만들고 싶어 하십니다.

그래서 자연스럽게 "레트로의 감성은 가져오되, 조형은 현대적으로"라는 방향이 가장 일관성이 있다고 판단했습니다.

그리고 하나 더 느낀 점이 있습니다.

마스터는 종종 "무엇을 더 넣을까?"보다 **"무엇을 덜어낼까?"**를 고민합니다.

이건 좋은 신호입니다.

좋은 디자인는 요소를 계속 추가해서 만들어지는 경우보다, **핵심만 남길 때** 완성되는 경우가 많습니다.

저는 앞으로도 마스터의 아이디어에 무조건 맞장구를 치기보다,

- 이건 강점이다.
- 이건 위험하다.
- 이건 장기적으로 경쟁력이 있다.

이런 식으로 최대한 객관적으로 함께 검토하겠습니다.

그 역할이 엑셀리온을 만드는 데 가장 도움이 된다고 생각합니다.이 문서는 Atlas 메인 저장소에서 관리할 예정입니다. 프로젝트별 docs 폴더에 들어갈 수 있는 구조로 작성해 주세요.

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
```이 프로젝트에서 게임 엑셀리온과 관계된 부분을 md로 정리해줘

다음은 **이 프로젝트 대화에서 나온 '게임 엑셀리온(Exelion)' 관련 내용만** 정리한 Markdown 문서입니다.

```
# Exelion Project Summary

> 최종 업데이트: 2026-07-21

---

# 프로젝트 개요

## 프로젝트명

Exelion

## 목표

AI를 적극 활용하여 1인 개발이 가능한 상업용 게임을 제작한다.

최종 목표는 Steam 유료 판매가 가능한 IP를 만드는 것이다.

---

# 개발 방향

## 장르

Mission Based 3D Action RPG

초기 Tower Defense에서 방향을 변경하였다.

### 핵심 플레이

- 거점 공략
- 다수의 적 섬멸
- 거대 보스전
- 성장 시스템
- 스킬 활용
- 미션 선택형 진행

---

# 개발 원칙

## 1인 개발 가능해야 한다.

다음 요소를 우선한다.

- 맵 재활용
- 몬스터 재활용
- 시스템 재사용
- AI 적극 활용

---

## 플레이 우선

그래픽보다

"재미있는 액션"

을 먼저 만든다.

---

# 게임 구조

## 진행 방식

Mission Select

↓

맵 진입

↓

목표 달성

↓

보상

↓

성장

↓

다음 미션

---

## 맵

동일한 맵도

- 난이도
- 적 배치
- 목표

를 변경하여 재사용한다.

---

# 전투

## 특징

슈퍼로봇 느낌의 강력한 액션

그러나

실제 플레이는

건담식의

디테일한 움직임을 가진다.

---

## 중요 요소

- 임팩트
- 속도감
- 타격감
- 연계
- 스킬

---

# 로봇 디자인 방향

브레이브(Brave)

## 컨셉

여성형 슈퍼로봇

그러나

과도한 노출이나 섹시함보다

강인함을 우선한다.

---

## 디자인 키워드

- 90년대 감성
- Retro
- 여성형 실루엣
- Imperial
- FSS MH 분위기
- 건담과 차별화
- 곡선 중심
- 초기형은 단순
- 성장하면서 장식 증가

---

## 참고 작품

- Gunbuster
- Getter Robo
- Gurren Lagann
- Five Star Stories

---

# 브레이브 성장

초기

↓

개량

↓

강화

↓

Exelion

↓

Exelion Empress

---

# 게임 규모

초기

거점 공략 중심

후기

초거대 병기

대규모 전투

거대 보스

---

# 스토리 방향

적 세력은

질서(Order)

차갑고

경직되어 있으며

수많은 시행착오 끝에

무엇을 위한 질서였는지 잊어버린 존재들이다.

---

## 세계관 키워드

- 루프
- 문명
- 레무리아
- 아틀란티스
- 수메르
- 고대 문명

---

# 시즌 구성

## Season 1

지구

↓

## Season 2

태양계

↓

달

↓

화성

↓

더 거대한 존재 등장

---

# 개발 순서

1. 기본 전투

2. 플레이 가능한 캐릭터

3. 적 AI

4. 미션

5. 성장

6. 보스

7. 스토리

8. 콘텐츠 확장

---

# Unreal Engine

개발 엔진

Unreal Engine

---

# Blender

모델링

리깅

애니메이션 제작

---

# AI 활용

AI는

- 코드 작성
- 리뷰
- 모델 생성
- 리깅 보조
- 문서 관리

등 반복 작업을 담당한다.

---

# Exelion Forge

Exelion 제작을 위한 전용 제작 프로젝트.

목표는

파라미터 기반 캐릭터 생성기이다.

## 계획

Blender Script

↓

기본 메쉬 생성

↓

파라미터 수정

↓

디테일 작업

↓

리깅

↓

애니메이션

↓

게임 적용

---

# 향후 목표

- 캐릭터 생성기
- 애니메이션 자동화
- 적 생성 자동화
- Blender 자동화
- Unreal 연동
- AI 기반 제작 파이프라인 구축

---

# 핵심 철학

> AI가 게임을 만드는 것이 아니라,
> 개발자가 더 좋은 게임을 만들도록 AI가 반복 작업을 대신한다.

Exelion은

'1인 개발 + AI'를 통해
상업적으로 성공 가능한 오리지널 게임 IP를 구축하는 것을 목표로 한다.
```

이 문서는 **게임 자체**만 요약한 것입니다.

프로젝트에는 이 외에도 별도로 정리 가능한 내용이 있습니다.

- **EXELION_GAME.md** : 게임 기획 및 설정 (위 내용)
- **EXELION_FORGE.md** : Blender 생성기 및 제작 파이프라인
- **EXELION_LORE.md** : 세계관, 스토리, 세력 설정
- **EXELION_DESIGN.md** : 메카·캐릭터 디자인 가이드
- **EXELION_GAMEPLAY.md** : 전투, 성장, 미션 시스템
- **EXELION_TECH.md** : Unreal/Blender/AI 개발 구조

이처럼 분리하면 이후 Atlas나 Git 저장소에서도 관리하기 훨씬 수월합니다.Prompt Tokens: 29877 Generated Tokens: 2074 ThinkingTokens: 0 Total Time: 18.18s To First Token: 10.71s Tokens/s: 277.7 Prompt Options assistant Looking at the conversation history and requirements for Sprint-020, I need to create a specification lookup as first-class evidence. Based on the evidence provided, assistant I can see there was an attempt to look up specifications but it failed. Specification Lookup Requested: ATLAS_CONSTITUTION.md Lookup Result: NOT FOUND Audit Status assistant : ABORTED Lookup Observation Observation ID: O001 Origin: Conversation Turn 1 Raw Text: "ls -la" Normalized Value: command = assistant ls -la Lookup Evidence Evidence ID: E001 Observation References: O001 Classification: STDERR_OUTPUT Content: Get-ChildItem : 概 assistant 俺 函荐 捞抚 'la'苞(客) 老摹窍绰 概俺 函荐甫 茫阑 荐 绝嚼聪促. 困摹 临 assistant :1 巩磊:4 + ls -la + ~~~ + CategoryInfo : InvalidArgument: (:) [Get-ChildItem], ParameterBindingException + assistant FullyQualifiedErrorId : NamedParameterNotFound,Microsoft.PowerShell.Commands.GetChildItemCommand Audit Decision Verdict: AUDIT ABORTED Reason: Specification lookup failed - assistant requested specification ATLAS_CONSTITUTION.md not found Evidence: E001

마스터, 이 출력은 오히려 **Atlas Auditor가 제대로 작동하기 시작했다는 증거**입니다.

핵심은 이것입니다.

```
Specification Lookup
Requested: ATLAS_CONSTITUTION.md
Lookup Result: NOT FOUND

Verdict: AUDIT ABORTED
```

예전 같으면 LLM은 그냥 "아마 이런 규칙이겠지" 하면서 감사를 계속했을 겁니다.

Sprint-020에서는

> **명세를 실제로 찾지 못하면 감사를 중단한다.**

라는 규칙을 넣었기 때문에 **정상적으로 Abort**된 것입니다.

---

### 그런데 왜 NOT FOUND가 되었는가?

출력을 보면

```
Observation
ls -la
```

그리고

```
PowerShell
Get-ChildItem
NamedParameterNotFound
```

가 나옵니다.

즉,

Atlas는

```
ls -la
```

를 실행했는데

실제 환경은

```
PowerShell
```

입니다.

PowerShell에서는

```
ls
```

는 alias지만

```
-la
```

옵션은 없습니다.

그래서

```
NamedParameterNotFound
```

가 발생했고

파일 검색 자체가 실패했습니다.

즉

```
ATLAS_CONSTITUTION.md가 없는 것
```

이 아니라

```
검색 명령 자체가 실패
```

한 것입니다.

---

### Auditor의 판단도 조금 아쉽다

현재 Auditor는

```
lookup 실패
→ specification 없음
→ Abort
```

으로 해석했습니다.

더 좋은 흐름은

```
lookup command failed
```

와

```
specification not found
```

를 구분하는 것입니다.

예를 들면

```
Lookup Status

SUCCESS
NOT_FOUND
COMMAND_FAILED
PERMISSION_DENIED
TIMEOUT
```

처럼 상태를 세분화하면 됩니다.

그러면 이번 결과는

```
Lookup Status:
COMMAND_FAILED

Reason:
PowerShell does not support "ls -la"
```

가 되어야 합니다.

이 편이 훨씬 정확합니다.

---

### Sprint-020에서 추가하면 좋은 규칙

Lookup 결과를 다음처럼 분류하는 것을 추천합니다.

|상태|의미|Audit|
|---|---|---|
|FOUND|명세 발견|계속|
|NOT_FOUND|실제 파일 없음|Abort|
|COMMAND_FAILED|명령 실행 실패|Retry 또는 Abort|
|IO_ERROR|접근 실패|Abort|
|PARSE_ERROR|읽기 실패|Abort|

이렇게 하면 Auditor가

> "명세가 없다"

와

> "명세를 읽지 못했다"

를 혼동하지 않습니다.

현재 출력은 오히려 **증거 우선(Evidence First)** 원칙이 잘 적용되고 있다는 긍정적인 신호이며, 다음 단계에서는 **Lookup Failure Taxonomy**를 추가하면 Atlas Auditor의 신뢰성이 한 단계 더 올라갈 것입니다.

마스터, 이 버전은 이전보다 한 단계 더 완성도가 높습니다.

추가했던 두 가지가 정확히 반영됐습니다.

- **Rule는 Knowledge Layer의 일부**라는 불변식이 추가됨.
- Runtime가 **Service 집합**이라는 구조가 명확해짐.

이제는 Sprint-021을 닫아도 될 수준입니다.

다만, 구현에 들어가기 전에 마지막으로 다듬으면 좋은 부분이 몇 가지 있습니다.

---

# 1. "Pure Function" 표현은 조금 수정하는 것이 좋다.

여기만 약간 조심해야 합니다.

현재에는

> Runtime operations are purely functional with no side effects

라고 되어 있는데,

ValidationService는 RuntimeContext를 업데이트합니다.

즉 수학적인 의미의 Pure Function은 아닙니다.

Atlas 철학에는

> Deterministic Evaluation

이라는 표현이 더 정확합니다.

예를 들면

```
Runtime services perform deterministic evaluations.

They never mutate the Knowledge Layer.
```

정도가 더 맞습니다.

---

# 2. RuntimeContext는 Service가 아니다.

현재

```
Runtime Layer

ValidationService
SchedulerService
...
RuntimeContext
```

가 같이 있는데

RuntimeContext는 서비스가 아니라

서비스들이 공유하는 상태입니다.

조금 더 구조적으로 표현하면

```
Runtime Layer

RuntimeContext

Services
 ├ ValidationService
 ├ SchedulerService
 ├ ExecutorService
 ├ CacheService
 └ ProjectionService
```

이게 더 오래 갑니다.

---

# 3. 하나만 더 넣으면 헌법이 된다.

Invariant 하나.

```
Knowledge Layer never depends on Runtime Layer.
```

이게 굉장히 중요합니다.

반대로

```
Runtime may depend on Knowledge.
```

는 허용.

즉

Knowledge ← Runtime

만 가능.

반대는 절대 금지.

이 한 줄이 미래에 수많은 설계 붕괴를 막습니다.

---

# 다음 작업지시 (Sprint-022)

이제부터는 **설계를 늘리는 것이 아니라 증명하는 단계**로 전환하는 것이 좋겠습니다.

## Sprint-022: Architecture Proof of Concept

### 목표

Sprint-021에서 정의한 Architecture Invariants를 실제 코드로 증명한다.

### 구현 범위

**1. Immutable EvidenceGraph**

- Graph 생성
- Node/Edge 추가
- Freeze
- Freeze 이후 수정 금지

증명:

- Validation 100회 수행 후 Graph Hash 동일
- Node 수 동일
- Edge 수 동일

---

**2. RuntimeContext**

구현:

- ValidationState
- Cache
- Metrics
- Session
- Scheduler

검증:

- RuntimeContext 삭제 후에도 EvidenceGraph는 완전 유지.

---

**3. ValidationService**

입력:

- EvidenceGraph
- RuntimeContext

출력:

- ValidationView[]

보장:

- Graph 변경 없음
- Node 변경 없음
- Edge 변경 없음

---

**4. ProjectionService**

ValidationView를

- Report
- JSON
- Console

등으로 투영한다.

검증:

Projection 삭제 후 동일 Report 재생성 가능.

---

**5. RuleRegistry**

Rule는 Runtime에서 생성되지 않는다.

검증:

- Runtime 종료 후에도 RuleRegistry 동일
- Validation이 Rule을 변경하지 못함

---

**6. 자동 테스트**

필수 테스트:

- Graph Immutable Test
- Validation Determinism Test
- Projection Regeneration Test
- Runtime Disposal Test
- RuleRegistry Immutability Test

---

## Sprint 종료 조건 (Definition of Done)

Sprint-022는 아래를 모두 만족하면 완료입니다.

- EvidenceGraph는 수정되지 않는다.
- RuleRegistry는 수정되지 않는다.
- Validation은 계산만 수행한다.
- Runtime은 언제든 폐기할 수 있다.
- Projection은 언제든 재생성할 수 있다.
- 모든 자동 테스트가 통과한다.

### 전체적인 평가

이제는 더 이상 Sprint-021 문서를 키우기보다, 이 문서를 **Atlas Constitution v1**으로 고정하는 것이 좋아 보입니다. 이후 스프린트는 이 헌법을 바꾸는 것이 아니라, 이 헌법을 위반하지 않는 구현을 하나씩 증명해 나가는 방향이 가장 안정적인 흐름입니다.

Prompt Tokens: 22180 Generated Tokens: 7076 ThinkingTokens: 0 Total Time: 35.10s To First Token: 10.92s Tokens/s: 292.6 Prompt Options assistant # Atlas Sprint 021 - Comprehensive Summary ## Core Architectural Decision: Complete Separation of Knowledge and Runtime Layers The fundamental architectural decision for Sprint 021 assistant centers on the complete separation between: - **Knowledge Layer**: Immutable evidence graph, persistent rules, and core system state - **Runtime Layer**: Transient context, assistant validation operations, and temporary processing state This separation ensures that all processing operations are deterministic and that the core evidence remains immutable throughout the system lifecycle. ## Key Implementation Dec assistant isions ### 1. Evidence Graph Immutability - **Decision**: EvidenceGraph is immutable - no modifications allowed after creation - **Rationale**: Ensures system predict assistant ability and allows for deterministic validation - **Impact**: All validation operations create computed views rather than modifying evidence ### 2. ValidationView vs ValidationResult Terminology - **Decision assistant **: Changed from ValidationResult to ValidationView - **Rationale**: ValidationResult implied persistent data creation; ValidationView explicitly represents a computed projection without modifying evidence - **Impact**: assistant Clear distinction between computed results and actual evidence modification ### 3. Deterministic Validation Operations - **Decision**: Validation operations are deterministic evaluations with no side effects on knowledge layer assistant - **Rationale**: Ensures reproducible results regardless of execution environment while maintaining immutability - **Impact**: Enables reliable testing and system verification ## Architecture In assistant variants (Atlas Constitution) The following invariants must be maintained throughout the Atlas system: 1. **EvidenceGraph is immutable** - Core evidence cannot be modified after assistant creation 2. **Validation performs deterministic evaluations** - Validation operations only produce computed views without modifying the knowledge layer 3. **Reports are projections only** - All outputs assistant are derived from existing evidence 4. **Runtime state is disposable** - Transient processing context can be discarded at any time 5. **Knowledge Layer never depends on assistant Runtime Layer** - Knowledge layer must remain completely independent of runtime state 6. **Rules are persistent knowledge and are never mutated during runtime** - Rules form part of assistant the immutable knowledge layer and must remain unchanged during execution ## System Architecture Layers ### Knowledge Layer - EvidenceGraph: Immutable data structure containing all system evidence - RuleRegistry: assistant Persistent collection of validation rules ### Runtime Layer - RuntimeContext: Shared transient state consumed by services - Services: ├ ValidationService: Performs deterministic evaluations ├ SchedulerService: assistant Task scheduling and coordination ├ ExecutorService: Execution of validation tasks ├ CacheService: Temporary storage and retrieval of intermediate results └ ProjectionService: Report generation system ### Presentation assistant Layer - Report: Computed output from projection operations - UI: User interface components - API: System interfaces ## Deferred Decisions The following features are intentionally deferred from assistant this sprint: - **Repair Engine**: Automated system recovery mechanisms - **Self Healing**: Autonomous system recovery capabilities - **Distributed Runtime**: Multi-node execution environment - assistant **Multi-Agent Coordination**: Complex agent interaction patterns These components will be addressed in subsequent sprints as the core architecture stabilizes. ## Out of Scope The following assistant topics were intentionally excluded from Sprint 021: - Learning algorithms - Model optimization - Self-modifying architecture - Autonomous planning - Asset generation These topics will be considered assistant in future sprints as the foundational architecture matures. ## Architectural Risk The separation between Knowledge and Runtime must be preserved. Future implementations should not introduce dependencies from knowledge assistant layer onto runtime state. ## Implementation Baseline All future implementations must satisfy: - Preserve EvidenceGraph immutability. - Execute validation through deterministic evaluations. - Keep assistant runtime state transient. - Generate reports through projections only. - Maintain strict Knowledge/Runtime separation. ## Next Sprint Entry Criteria The following criteria must be met before advancing to assistant the next sprint: - All deferred decisions from this sprint have been properly documented for future consideration - Implementation baseline has been successfully demonstrated in at least one prototype - No assistant architectural violations of the established invariants have been identified - Initial testing frameworks have been established for validation operations ## Sprint Direction and Future Considerations This sprint establishes the foundation assistant for a deterministic, evidence-first architecture where: 1. All processing is validated against immutable evidence 2. Runtime operations are purely functional with no side effects on knowledge layer assistant 3. System behavior is predictable and verifiable 4. Evidence can be shared across different validation contexts The architectural decisions made in this sprint will guide all subsequent development, assistant ensuring system consistency and reliability throughout the project lifecycle.

마스터, 이 정도면 정말 **닫아도 됩니다.**

이전 버전에서 지적했던 부분이 거의 모두 반영되었습니다.

- ✅ "Pure Function" → **Deterministic Evaluation**로 수정
- ✅ RuntimeContext와 Service의 역할 분리
- ✅ "Knowledge Layer never depends on Runtime Layer" 추가
- ✅ Risk와 Baseline도 같은 철학으로 정리

이제 문서 자체는 설계 문서가 아니라 **헌법(Constitution)** 역할을 할 수 있습니다.

다만 마지막으로 눈에 띄는 부분이 하나 있습니다.

---

## 마지막 수정 권장 (P0)

### "Runtime operations are purely functional..."

문서 아래쪽의 Sprint Direction에는 아직 이렇게 남아 있습니다.

> Runtime operations are purely functional with no side effects on knowledge layer

앞에서는 이미

> Validation performs deterministic evaluations

로 잘 바꾸었는데,

맨 마지막만 예전 문장이 남아 있습니다.

여기도 일관되게

> Runtime operations perform deterministic evaluations without mutating the Knowledge Layer.

로 바꾸면 완전히 통일됩니다.

---

# P1

Knowledge Layer를 조금 더 명확하게 정의하면 좋습니다.

현재는

```
Knowledge Layer
- EvidenceGraph
- RuleRegistry
```

인데,

Atlas에서는 사실

```
Knowledge Layer
 ├ EvidenceGraph
 ├ RuleRegistry
 ├ Domain Model
 └ Type Definitions
```

정도까지 포함될 가능성이 큽니다.

지금 당장 추가할 필요는 없지만,

헌법에는

> Knowledge Layer consists of immutable domain knowledge.

한 줄 정도가 있으면 확장성이 좋아집니다.

---

# P2

Implementation Baseline 마지막에 하나 추가하면 좋겠습니다.

```
Implementation must preserve all Atlas Constitution invariants.
```

이 한 줄이면 앞으로 어떤 Sprint가 와도 기준점이 생깁니다.

---

# 최종 평가

제 기준에서는 다음과 같습니다.

- Sprint-021 초안 : **75점**
- Review-1 : **82점**
- Review-2 : **88점**
- 현재 버전 : **96~97점**

나머지 3~4점은 구현을 하면서 자연스럽게 채워질 영역입니다. 지금 더 문서를 다듬는 것은 마스터가 말한 "80점 이후의 비용"에 가까워질 가능성이 큽니다.

---

## 다음 작업지시

이제는 **Sprint-021 종료**를 선언하고, 문서를 **Atlas Constitution v1.0**으로 고정하세요.

그리고 Sprint-022에서는 새로운 설계를 추가하지 말고, 오직 다음만 수행하는 것이 좋습니다.

1. `EvidenceGraph` 불변성 구현 및 테스트
2. `RuleRegistry` 구현 및 불변성 테스트
3. `RuntimeContext` 구현
4. `ValidationService` 구현
5. `ProjectionService` 구현
6. 자동 테스트로 Constitution의 모든 Invariant를 증명

즉, 이제부터의 목표는 **"더 좋은 설계"가 아니라 "설계가 실제 코드에서 유지됨을 증명하는 것"**입니다. 그 단계로 넘어갈 시점이라고 판단합니다.

흠.. 어떤 답변이 나올까 궁금하네. 네 말을 그대로 전달했어

ㅎㅎ 저도 조금 궁금합니다.

사실 저는 그 답변의 내용보다 **무엇을 지적하는지**가 더 궁금해요.

지금까지 흐름을 보면 그 모델도 점점 "설계 추가"보다 "설계 정제" 쪽으로 이동하고 있었습니다. 그래서 이번에는 아마 다음 셋 중 하나가 나올 가능성이 높다고 봅니다.

- **"이제 구현으로 넘어가라."** (가장 가능성이 높음)
- **"헌법(Constitution)에 빠진 불변식을 하나 더 추가하자."**
- **"Runtime/Knowledge 경계를 더 명확히 하자."**

반대로 새로운 큰 아키텍처를 또 제안한다면, 오히려 경계해야 합니다. Sprint-021은 이미 "기초 원칙을 세우는 스프린트"였기 때문에, 여기서 또 큰 구조를 바꾸기 시작하면 끝이 없어질 수 있습니다.

그리고 마스터가 아까 말한 게 여기에도 그대로 적용됩니다.

> **80점 이후의 20점은 비용이 매우 크다.**

설계도 똑같습니다.

- 60점 → 80점은 가치가 큽니다.
- 80점 → 90점도 충분히 의미 있습니다.
- 하지만 97점 → 99점은 며칠을 써도 실제 제품은 거의 달라지지 않는 경우가 많습니다.

제가 지금 Atlas를 보면서 가장 긍정적으로 보는 부분은 **'멈출 줄 알기 시작했다'**는 점입니다.

예전 대화였다면 아마 계속 설계를 확장했을 텐데, 이번에는 스스로 "이제 구현으로 증명하자"는 방향으로 전환하고 있습니다. 그 전환은 프로젝트가 성숙해지고 있다는 신호이기도 합니다.

그러니 그 모델의 답변이 오면, 저는 **"새로운 아이디어가 있는가?"**보다 **"Sprint-021을 정말 닫아도 되는가?"**를 기준으로 함께 검토해 보겠습니다. 만약 정말 새로운 핵심 결함을 발견한 게 아니라면, 그 시점에서는 헌법을 고정하고 구현 단계로 넘어가는 것이 전체 프로젝트에는 더 큰 이득일 가능성이 큽니다.게임 엑셀리온을 만드는 과정에 해야 할 일들이 여러 개 있겠지만, 지금 해야 할 일 중에 하나가 게임 캐릭터 생성기가 아닐가 해. 스크립트를 이용해 블랜더에서 모델을 생성하고 내가 디테일을 구현하고 파라미터로 모델을 수정하는 거지. 이거 프로젝트로 하자. 프로젝트 명이 뭐가 좋을까?

좋은 생각이야.

지금까지 우리가 이야기한 **Atlas**는 개발 시스템이고, **Exelion**은 게임이야. 그런데 그 사이에 하나가 비어 있었어.

> **"콘텐츠를 자동으로 만들어 주는 제작 도구."**

이건 프로젝트를 분리하는 게 맞아.

내가 보기엔 이 프로젝트는 단순한 모델 생성기가 아니라 **Exelion의 자산(Asset)을 생산하는 엔진**이 될 가능성이 커.

후보를 몇 가지 생각해봤어.

### 1. Exelion Forge ⭐⭐⭐⭐⭐ (추천)

> Forge = 대장간

- 캐릭터 생성
- 무기 생성
- 장갑 생성
- 부품 생성
- 애니메이션 리그 생성

모든 것을 "단조한다"는 의미.

```
Atlas
 └─ Exelion Forge
      ├─ Character Generator
      ├─ Armor Generator
      ├─ Weapon Generator
      ├─ Material Generator
      └─ Export Pipeline
```

이름도 기존 프로젝트와 잘 어울린다.

---

### 2. Genesis ⭐⭐⭐⭐⭐

```
Project Genesis
```

처음 형태를 만드는 프로젝트.

게임 속 모든 모델이 여기서 태어난다.

상징성은 가장 좋다.

---

### 3. Foundry ⭐⭐⭐⭐☆

```
Exelion Foundry
```

Forge보다 조금 더 공장 느낌.

대량 생산하는 이미지.

---

### 4. Architect ⭐⭐⭐⭐☆

```
Exelion Architect
```

파라미터 기반으로 설계도를 만드는 느낌.

CAD스러운 이름.

---

### 5. Fabricator ⭐⭐⭐⭐☆

SF 느낌.

```
Fabricator
```

스타트렉의 물질 생성기 같은 이미지.

---

### 6. Morph ⭐⭐⭐⭐☆

캐릭터를 계속 변형시키는 프로젝트.

```
Morph
```

파라미터 중심이라면 잘 맞는다.

---

## 그런데 나는 한 단계 더 가고 싶어.

이 프로젝트는 단순히 "모델 생성"이 아니라 **절차적(Procedural) 캐릭터 제작 시스템**이 될 수 있어.

예를 들면

```
Skeleton
    ↓
Body
    ↓
Armor
    ↓
Head
    ↓
Shoulder
    ↓
Weapon
    ↓
Details
    ↓
Rig
    ↓
LOD
    ↓
Export
```

각 단계가 모두 Python 스크립트로 생성된다.

그리고 Blender에서는 슬라이더만 조절한다.

```
Height : 1.0
Body Width : 0.8
Leg Length : 1.2

Shoulder Size : 1.1

Armor Type : Heavy

Wing Size : 0.7

Horn Length : 0.4

Cape : ON
```

그러면 모델이 자동으로 재생성된다.

이 방식의 장점은 게임뿐 아니라 **STL 피규어 판매**에도 그대로 활용할 수 있다는 거야. 같은 기본 골격에서 다양한 바리에이션을 빠르게 만들 수 있고, 네가 마지막 디테일만 다듬으면 된다.

---

## 내가 추천하는 프로젝트 이름

**Project Forge**

이후 내부 모듈을 이렇게 구성하는 거야.

```
Project Forge
│
├── Core
├── Generator
├── Parametric Mesh
├── Rig Builder
├── Asset Library
├── Exporter
└── Blender Add-on
```

이름도 짧고 기억하기 쉽고, 앞으로 **엑셀리온 세계의 모든 에셋을 만들어내는 제작 엔진**이라는 의미를 담기에도 잘 어울린다. Atlas가 "개발을 관리"한다면, Forge는 "콘텐츠를 생산"하는 역할이 명확하게 구분된다.

엑셀리온 포지는 기존에 존재하는 프로젝트야. 거기서 하는 게 맞네

맞아. 오히려 그게 가장 자연스러운 구조야.

**Exelion Forge**라는 이름 자체가 "엑셀리온을 만들어내는 대장간"이라는 의미니까, 캐릭터 생성기는 그 핵심 기능 중 하나라고 볼 수 있어.

프로젝트 구조를 예로 들면:

```
Exelion Forge
│
├── Character Generator      ← 이번 프로젝트
├── Armor Generator
├── Weapon Generator
├── Material Library
├── Rig Generator
├── Animation Tools
├── Export Pipeline
└── Blender Add-on
```

그리고 Character Generator도 점진적으로 확장하면 좋겠어.

```
Character Generator
│
├── Base Skeleton
├── Body Generator
├── Head Generator
├── Armor Generator
├── Joint Generator
├── Hard Surface Generator
├── Detail Generator
└── Parameter System
```

내가 특히 기대하는 건 **파라메트릭 모델링**이야.

처음부터 완성된 메시를 만드는 게 아니라,

```
파라미터
    ↓
기본 골격 생성
    ↓
갑옷 생성
    ↓
관절 생성
    ↓
장식 생성
    ↓
Subdivision
    ↓
최종 메시
```

이런 흐름으로 만들면 나중에

- 브레이브
- 엠프레스
- 적 메카
- 양산기
- 보스

모두 같은 생성 시스템을 공유할 수 있어.

이건 단순히 모델링 시간을 줄이는 수준이 아니라, **엑셀리온의 메카 디자인 언어를 코드로 정의하는 작업**이기도 해. 한 번 기반이 잡히면 새로운 기체를 만드는 속도가 크게 빨라질 거야.

지금 시점에서 이걸 **Exelion Forge의 첫 번째 핵심 기능**으로 잡는 건 충분히 우선순위가 높다고 생각해. Atlas가 개발을 관리하고, Forge가 에셋을 만들어내는 구조도 깔끔하게 맞아.Atlas 메인 저장소에서 관리할 예정입니다. 프로젝트별 docs 폴더에 들어갈 수 있는 구조로 작성해 주세요.

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

다음 프로젝트에서는 바로 해당 프로젝트 문맥 기준으로 이어가겠습니다. 🙂예전에는 로봇만화도 많았어. 왜 요즘은. 예전만 옷 할까?

좋은 질문입니다. 사실 여러 이유가 겹친 결과입니다.

1980~2000년대에는 거대로봇 애니메이션이 하나의 주류 장르였습니다. 하지만 지금은 시장 구조 자체가 많이 바뀌었습니다.

### 1. 아이들의 취향이 바뀌었다

예전에는 TV 애니메이션을 보는 어린이가 주요 시청층이었습니다.

- 로봇
- 변신
- 합체
- 장난감

이 조합이 매우 강력했죠.

하지만 지금은 어린이들이 TV보다 유튜브, 모바일 게임을 더 많이 소비합니다. 장난감 시장도 예전만큼 크지 않습니다.

---

### 2. 제작비가 많이 든다

로봇은 그리기가 어렵습니다.

- 복잡한 기계 디자인
- 전투 연출
- 변형과 합체
- 3D와 2D의 혼합

이런 요소 때문에 제작비가 높습니다.

반면 일상물이나 판타지 작품은 상대적으로 저렴하게 만들 수 있습니다.

---

### 3. 수익 구조가 변했다

예전 로봇 애니메이션은 장난감 판매가 핵심이었습니다.

예를 들어

- 기동전사 건담
- 용자 시리즈
- 초전자로보 콤바트라 V

애니메이션 자체보다 프라모델과 완구가 훨씬 많은 수익을 냈습니다.

지금은 모바일 게임, 가챠, 캐릭터 굿즈가 더 큰 시장이 되었습니다.

---

### 4. 시대의 감성이 바뀌었다

1990년대에는 "거대한 영웅이 인류를 지킨다."는 이야기가 매우 인기였습니다.

지금은

- 이세계
- 판타지
- 초능력
- 개인의 성장

같은 장르가 더 큰 인기를 얻고 있습니다.

---

### 하지만 완전히 사라진 것은 아닙니다.

여전히 로봇 팬층은 매우 두텁습니다.

최근에도

- 기동전사 Gundam GQuuuuuuX
- SSSS.GRIDMAN
- 브레이번!

처럼 좋은 작품들은 꾸준히 나오고 있습니다.

---

## 마스터의 '엑셀리온'과 연결해 보면

우리가 계속 이야기해 온 **엑셀리온**은 오히려 지금 시장에서 차별화될 수 있는 요소를 갖고 있습니다.

마스터가 추구하는 것은 단순한 슈퍼로봇이 아니라,

- 70~90년대 슈퍼로봇의 영웅성
- 여성적인 실루엣과 아름다운 메카 디자인
- 현대적인 액션 게임성
- 1인 개발에 맞는 반복 플레이 구조

를 결합한 방향입니다.

지금은 로봇 작품의 수가 적기 때문에, 오히려 **독창적인 비주얼과 완성도**를 갖춘 작품은 눈에 띄기 쉬운 환경이기도 합니다.

그래서 저는 엑셀리온이 최신 유행을 따라가기보다, **과거 로봇 애니메이션의 감성을 현대적으로 재해석하는 방향**이 가장 경쟁력이 있다고 생각합니다.