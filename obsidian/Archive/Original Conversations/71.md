프로젝트에서 게임 엑셀리온 포지와 관계된 부분을 md로 정리해줘

# Exelion Forge 프로젝트 정리 (Markdown)

```
# Exelion Forge

## 프로젝트 개요

Exelion Forge는 **게임 Exelion을 제작하기 위한 캐릭터/메카 생성 시스템**이다.

최종 목표는 블렌더(Blender)에서 스크립트 기반으로 모델을 자동 생성하고,
사용자는 디테일만 수정하여 다양한 캐릭터와 메카를 빠르게 제작하는 것이다.

Forge는 단순 모델링 툴이 아니라 Exelion 개발을 위한 콘텐츠 제작 파이프라인의 핵심 프로젝트이다.

---

# 목표

- 캐릭터 제작 시간 단축
- 반복 작업 자동화
- 다양한 파라미터 기반 모델 생성
- 게임에서 사용할 수 있는 품질 확보
- 향후 NPC 및 적 캐릭터 제작에도 활용

---

# 개발 방식

## 1단계

Blender Python을 이용한 자동 생성

- 메쉬 생성
- 파츠 조립
- 비율 조정
- 미러 처리
- 기본 UV

---

## 2단계

파라미터 기반 생성

예)

- 키
- 어깨 폭
- 허리
- 다리 길이
- 팔 길이
- 갑옷 두께
- 메카 스타일

슬라이더만 변경하면 새로운 모델 생성.

---

## 3단계

모듈화

부품 단위 관리

- 머리
- 몸통
- 팔
- 다리
- 무기
- 백팩
- 날개

조합만으로 새로운 기체 생성.

---

## 작업 흐름
```

파라미터  
↓

Blender Script

↓

Base Mesh 생성

↓

Armor 생성

↓

Detail 추가

↓

수동 수정

↓

게임 Export(FBX)

```

---

# 주요 기능

## Procedural Generation

스크립트 기반 생성

- Base Body
- Armor
- Joint
- Weapon Mount

---

## Parametric Editing

모델을 직접 수정하지 않고
파라미터만 변경하여 형태 변경.

---

## Reusable Parts

모든 부품은 재사용 가능하도록 설계.

예)

- Shoulder A
- Shoulder B
- Leg Heavy
- Leg Light

---

## Blender Add-on

장기적으로는 Blender Add-on 형태로 발전.

예상 기능

- Generate
- Randomize
- Mirror
- Export
- Preset 저장

---

# Exelion과의 관계

Forge는 Exelion 개발을 위한 콘텐츠 제작 도구이다.
```

Atlas  
├── 개발 관리  
├── 작업 추천  
└── 프로젝트 관리

Forge  
├── 캐릭터 생성  
├── 메카 생성  
├── 파츠 생성  
└── Blender 자동화

Exelion  
├── 게임  
├── 플레이  
└── 콘텐츠 사용

```

---

# 향후 확장

- 적 캐릭터 자동 생성
- NPC 생성
- 장비 생성
- 무기 생성
- 랜덤 생성
- AI 기반 디자인 제안

---

# 개발 철학

"모델링을 자동화하는 것이 아니라,

창작자가 재미있는 부분에만 집중하도록 만드는 것."

즉,

반복 작업은 Forge가 담당하고,
디자인과 감성은 개발자가 담당한다.
```

현재 대화 내용을 기준으로 보면 **Exelion Forge는 별도의 독립 프로젝트라기보다 Exelion 프로젝트의 하위 시스템**으로 보는 것이 더 적합합니다. 게임 개발에 필요한 **캐릭터 생성기, 메카 생성기, Blender 자동화 도구**를 담당하는 제작 파이프라인으로 자리 잡고 있습니다.