# UNREAL ARCHITECTURE (Unreal 프로젝트 아키텍처)

> Status : Draft
> Version : 0.1
> Last Updated : 2026-07-01

---

# 문서의 목적

이 문서는 EXCELION의 Unreal Engine 프로젝트 구조를 정의한다.

모든 시스템은 유지보수성과 확장성을 고려하여 설계한다.

---

# 설계 원칙

프로젝트는 다음 원칙을 따른다.

* Component 기반 설계
* Data Driven 설계
* Blueprint는 조립
* C++는 기능 구현
* 상속보다 조합(Composition)을 우선한다.

---

# 프로젝트 구조

```text
Content/

├── Core/
├── Characters/
├── Enemies/
├── Weapons/
├── Components/
├── Animation/
├── Effects/
├── UI/
├── Maps/
├── Audio/
├── Data/
└── Developer/
```

---

# Core

프로젝트의 핵심 시스템을 저장한다.

예시

* GameInstance
* GameMode
* PlayerController
* HUD
* SaveGame
* Subsystem

Core는 게임 규칙을 담당한다.

---

# Characters

플레이 가능한 기체를 관리한다.

예시

```text
Characters/

├── Excelion/
│
├── Meshes/
├── Animations/
├── Blueprints/
└── Data/
```

---

# Enemies

적 기체를 관리한다.

Enemy Base를 기준으로 모든 적을 제작한다.

---

# Weapons

모든 무장을 관리한다.

예시

* Mega Cannon
* Missile
* Beam
* Sword

---

# Components

재사용 가능한 기능을 관리한다.

예시

* LockOnComponent
* HealthComponent
* HeatComponent
* ResonanceComponent
* WeaponComponent
* TargetComponent

Component는 프로젝트의 핵심이다.

---

# Animation

Animation Blueprint

Montage

Blend Space

Control Rig

등을 관리한다.

---

# Effects

Niagara

Material

Impact

Explosion

등을 관리한다.

---

# UI

모든 Widget을 관리한다.

예시

* HUD
* LockOn
* Boss HP
* Mission Result

---

# Maps

레벨을 저장한다.

예시

```text
Maps/

MainMenu

Hangar

Mission01

Mission02

TestMap
```

---

# Data

게임 데이터를 저장한다.

예시

* Data Table
* Primary Data Asset
* Curve
* Gameplay Tag

가능한 많은 데이터를 코드가 아니라 Data Asset으로 관리한다.

---

# Developer

실험용 맵과 테스트용 Blueprint를 저장한다.

출시 빌드에는 포함하지 않는다.

---

# C++ 역할

C++는 다음을 담당한다.

* 시스템
* Component
* AI
* Save
* 네트워크 대응 기반
* 성능이 중요한 기능

---

# Blueprint 역할

Blueprint는 다음을 담당한다.

* 연출
* UI 연결
* 데이터 연결
* Animation Event
* Prototype 제작

Blueprint에는 복잡한 알고리즘을 작성하지 않는다.

---

# GameInstance

게임 전체 데이터를 관리한다.

예시

* Save Load
* 설정
* 플레이어 진행도

---

# GameMode

현재 게임의 규칙을 관리한다.

예시

* 미션 시작
* 미션 종료
* 승리
* 실패

---

# PlayerController

입력을 담당한다.

* Enhanced Input
* Lock-On
* Camera 입력

---

# Pawn / Character

EXCELION 자체를 의미한다.

담당 기능

* 이동
* 애니메이션
* Component 연결

---

# Component 구조

예시

```text
ExcelionCharacter

├── HealthComponent
├── WeaponComponent
├── HeatComponent
├── ResonanceComponent
├── LockOnComponent
├── TargetComponent
└── AnimationComponent
```

가능한 기능은 Component로 분리한다.

---

# Data Driven

수치는 Blueprint에 작성하지 않는다.

예시

무기 공격력

Heat 증가량

보스 HP

이동 속도

모두 Data Asset에서 관리한다.

---

# 의존성 원칙

UI는 Character를 직접 제어하지 않는다.

Character는 Widget을 직접 생성하지 않는다.

가능한 Event와 Interface를 사용한다.

---

# Prototype 원칙

Prototype에서는

"작동하는 구조"

를 먼저 만든다.

최적화는 Vertical Slice 이후 진행한다.

---

# 프로젝트 목표

모든 시스템은

"새로운 기능을 쉽게 추가할 수 있는가?"

를 기준으로 설계한다.

기능을 하나 추가할 때

기존 코드를 수정하는 일이 최소화되어야 한다.
