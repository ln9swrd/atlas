게임 엑셀리온을 만드는 과정에 해야 할 일들이 여러 개 있겠지만, 지금 해야 할 일 중에 하나가 게임 캐릭터 생성기가 아닐가 해. 스크립트를 이용해 블랜더에서 모델을 생성하고 내가 디테일을 구현하고 파라미터로 모델을 수정하는 거지. 이거 프로젝트로 하자. 프로젝트 명이 뭐가 좋을까?

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

지금 시점에서 이걸 **Exelion Forge의 첫 번째 핵심 기능**으로 잡는 건 충분히 우선순위가 높다고 생각해. Atlas가 개발을 관리하고, Forge가 에셋을 만들어내는 구조도 깔끔하게 맞아.