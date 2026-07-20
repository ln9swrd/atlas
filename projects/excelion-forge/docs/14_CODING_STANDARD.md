# CODING STANDARD (코딩 표준)

> Status : Draft
> Version : 0.1
> Last Updated : 2026-07-01

---

# 문서의 목적

이 문서는 EXCELION 프로젝트의 C++, Blueprint 및 데이터 작성 규칙을 정의한다.

모든 코드는 가독성, 유지보수성, 확장성을 우선한다.

---

# 기본 원칙

프로젝트는 다음 원칙을 따른다.

* 읽기 쉬운 코드
* 중복 제거(DRY)
* 단일 책임 원칙(SRP)
* 데이터 중심 설계(Data Driven)
* 조합(Composition) 우선

---

# C++ 클래스 네이밍

Unreal Engine 표준을 따른다.

예시

```text
AExcelionCharacter
AEnemyBase
ABossGuardian
UHealthComponent
UWeaponComponent
UResonanceComponent
UExcelionGameInstance
```

---

# Blueprint 네이밍

모든 Blueprint는 접두사를 사용한다.

| 접두사  | 의미                  | 예시              |
| ---- | ------------------- | --------------- |
| BP_  | Blueprint           | BP_Excelion     |
| ABP_ | Animation Blueprint | ABP_Excelion    |
| WBP_ | Widget Blueprint    | WBP_HUD         |
| BPI_ | Blueprint Interface | BPI_Damageable  |
| BT_  | Behavior Tree       | BT_BossGuardian |
| BB_  | Blackboard          | BB_BossGuardian |

---

# Asset 네이밍

| 종류                | 예시                |
| ----------------- | ----------------- |
| Skeletal Mesh     | SK_Excelion_Proto |
| Static Mesh       | SM_HangarWall     |
| Material          | M_Armor           |
| Material Instance | MI_Armor_Blue     |
| Texture           | T_Armor_BaseColor |
| Niagara           | NS_Boost          |
| Sound             | SFX_MegaCannon    |
| Animation         | AN_Run            |
| Montage           | AM_Attack01       |

---

# 변수 규칙

변수명은 의미를 명확히 표현한다.

좋은 예

```cpp
CurrentHealth
MaxHealth
CurrentHeat
LockOnTarget
```

좋지 않은 예

```cpp
hp
value
temp
test
data1
```

Boolean은 다음 접두사를 사용한다.

```cpp
bIsBoosting
bIsLockedOn
bCanFire
bMissionCleared
```

---

# 함수 규칙

함수는 동사로 시작한다.

예시

```cpp
FireMegaCannon()
StartBoost()
StopBoost()
ApplyDamage()
UpdateHeat()
LockTarget()
```

Getter

```cpp
GetCurrentHeat()
GetTarget()
```

Setter

```cpp
SetTarget()
SetHeat()
```

---

# Blueprint 작성 규칙

Blueprint는 시각적으로 읽기 쉬워야 한다.

원칙

* Event Graph 최소화
* Function 적극 활용
* Macro 남용 금지
* Comment Box 사용
* Node 정렬 유지

하나의 Blueprint는 하나의 역할만 가진다.

---

# Event Dispatcher

직접 참조보다 Event Dispatcher를 우선한다.

예시

* 체력 변경
* 보스 등장
* 미션 종료

---

# Interface

다음 기능은 Interface를 사용한다.

* Damage
* Target
* Interact

Cast 사용을 최소화한다.

---

# Gameplay Tag

문자열 비교를 하지 않는다.

Gameplay Tag를 사용한다.

예시

```text
State.Boost
State.Overdrive
State.Stunned

Weapon.MegaCannon
Weapon.Beam

Enemy.Boss
Enemy.Drone
```

---

# Data Asset

수치는 코드에 작성하지 않는다.

다음 정보는 Data Asset으로 관리한다.

* HP
* 공격력
* 이동 속도
* Heat
* Resonance
* 무기 성능

---

# 주석 규칙

주석은 "무엇"이 아니라 "왜"를 설명한다.

좋은 예

```cpp
// Mega Cannon은 발사 후 강제 냉각 시간을 가진다.
// 연속 사용을 방지하기 위한 설계이다.
```

좋지 않은 예

```cpp
// HP를 감소시킨다.
CurrentHealth -= Damage;
```

---

# 로그 출력

로그는 카테고리를 사용한다.

예시

```cpp
LogExcelion
LogCombat
LogMission
LogAI
```

불필요한 로그는 출시 전에 제거한다.

---

# TODO 규칙

임시 코드는 반드시 TODO를 남긴다.

예시

```cpp
// TODO : Resonance 시스템 적용 예정
```

TODO가 없는 임시 구현은 금지한다.

---

# 리팩터링 원칙

새로운 기능을 추가하기 전에 다음을 확인한다.

* 중복 코드가 있는가?
* Component로 분리 가능한가?
* Data Asset으로 이동 가능한가?

---

# 금지 사항

다음을 지양한다.

* 하드코딩
* 매직 넘버
* 순환 참조
* 과도한 Blueprint Cast
* 거대한 Event Graph
* God Class

---

# 최종 원칙

좋은 코드는

짧은 코드가 아니라,

나중의 내가 이해할 수 있는 코드이다.
