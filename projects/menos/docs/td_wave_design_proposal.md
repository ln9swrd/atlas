# MENOS — TD Wave Design Proposal

STATUS — PROPOSAL / NOT CANON

## 1. 목적

싱글플레이 Tower Defense 미션에서 Wave를 단순한 적 생성 목록이 아니라 하나의 전술적 개성을 가진 콘텐츠 단위로 정의한다.

기본 게임 구조:

```text
20분 방어
→ Wave 생존
→ Robot 전투
→ Gold 획득
→ Tower 건설 / Upgrade
→ Robot Level Up / 재출격
→ 후반 Enemy Robot 등장
→ 최종 승부
```

Wave는 플레이어가 매번 다른 방어 판단을 하도록 구성한다.

## 2. Wave와 Unit의 책임 분리

Unit은 개별 전투 유닛의 능력과 특성을 정의한다.

Wave는 어떤 Unit을 어떤 구성과 전술로 투입할지를 정의한다.

```text
Unit
 ├─ Ground / Air
 ├─ Light / Heavy / Ranged 등 역할
 ├─ HP
 ├─ Attack
 ├─ Defense
 └─ Base Movement Speed

Wave
 ├─ Unit Composition
 ├─ Group
 ├─ Formation
 ├─ Spawn Pattern
 ├─ Spawn Interval
 ├─ Movement Speed Policy
 └─ Special Rule
```

## 3. Wave 기본 구성

Wave는 최소 다음 요소를 가질 수 있도록 설계한다.

- ODB PK
- Name / Title
- Wave Type
- Unit Composition
- Group
- Formation
- Spawn Pattern
- Spawn Interval
- Movement Speed Policy
- Speed Synchronization
- Group Delay
- Special Rule

Name / Title은 변경 가능한 표시 속성이며 식별자로 사용하지 않는다.

## 4. Wave 개성

같은 Unit을 사용하더라도 Wave의 구성과 전술에 따라 서로 다른 플레이 경험을 만들어야 한다.

### 4.1 경량 개떼

```text
Light × 다수
짧은 Spawn Interval
빠른 진입
```

목적:
- 기본 방어선을 물량으로 압박
- Tower의 처리 능력 시험
- Robot의 적극적인 전투 유도

### 4.2 공중 습격

```text
Air × 다수
Ground = 0 또는 극소수
```

목적:
- 대공 방어 준비 여부 시험
- 지상 전용 Tower만 구축한 플레이어 압박

### 4.3 중장 돌파

```text
Heavy + Light
```

Heavy가 전방에서 버티고 Light가 후속 진군하는 형태.

목적:
- Heavy의 생존력을 이용해 방어선을 압박
- 단일 Target Type Tower의 한계 유도

### 4.4 원거리 지원

```text
Heavy + Ranged + Light
```

Heavy가 전선을 형성하고 Ranged가 후방에서 지원한다.

목적:
- 단순한 전방 집중 공격으로 해결하기 어려운 진형 제공
- Robot의 우선 Target 선택을 요구

### 4.5 혼성 진군

```text
Heavy + Light + Ranged + Air
```

지상과 공중, 근거리와 원거리 역할을 동시에 사용한다.

목적:
- Ground / Air 방어의 균형 시험
- Tower 조합과 Robot 개입을 동시에 요구

## 5. 이동 속도 정책

Wave의 중요한 특징으로 Unit의 기본 이동속도와 Wave의 진군 속도를 분리한다.

### INDIVIDUAL

각 Unit이 자신의 기본 이동속도로 이동한다.

```text
Light    180
Ranged   120
Heavy     70
```

결과적으로 Light가 먼저 도착하고 Heavy가 후속한다.

### SYNCHRONIZED

Wave가 지정한 속도로 모든 Unit의 진군 속도를 맞춘다.

```text
Light    → 70
Ranged   → 70
Heavy    → 70
```

### ANCHOR

특정 Unit을 기준으로 다른 Unit의 속도를 맞춘다.

예:

```text
Anchor = Heavy
Light  → Heavy 속도
Ranged → Heavy 속도
Heavy  → 기본 속도
```

### FORMATION

그룹의 상대적인 이동 관계를 유지하면서 진군한다.

## 6. 속도 동기화 Wave

속도 동기화는 단순한 수치 변경이 아니라 전술적 진형을 만드는 용도로 사용한다.

예:

```text
        Light
          ↓
Ranged → Heavy ← Ranged
          ↓
         Base
```

Heavy를 중심으로 Light와 Ranged가 동시에 도착하도록 구성할 수 있다.

반대로 개별 속도를 유지하는 Wave에서는 다음과 같은 시간차 공격이 가능하다.

```text
Light  →→→→→
Ranged →→→
Heavy  →→
```

즉, 선행 공격 → 중간 지원 → 후속 중장이라는 전술을 만들 수 있다.

## 7. Wave의 전략적 역할

20분 미션의 시간 진행에 따라 Wave의 개성을 단계적으로 증가시키는 방향을 권장한다.

```text
초반
경량 물량
↓
지상 기본 방어 요구

중반
공중 Wave
↓
대공 방어 요구

중반 이후
Heavy + Ranged
↓
전술적 방어 요구

후반
혼성 + 속도 동기화
↓
Tower와 Robot의 협동 요구

최종
Enemy Robot
↓
사실상 승부 결정
```

## 8. Tower와 Wave의 관계

Tower는 크게 세 가지 방어 유형을 가진다.

```text
Ground Tower
Air Tower
Universal Tower
```

Wave는 이 세 가지 방어 유형을 직접 시험하도록 설계할 수 있다.

예:

```text
Ground Wave
→ Ground Tower 효과적

Air Wave
→ Ground Tower만으로 대응 불가

Mixed Wave
→ Ground + Air Tower 조합 필요

Pressure Wave
→ Universal Tower의 EMP 지연 효과 중요
```

Universal Tower의 EMP는 긴 재사용 시간을 가진 진군 지연 수단으로 사용하여, 밀려오는 적의 도착 시간을 늦추고 Robot이 전투에 개입할 시간을 확보하는 방향을 제안한다.

## 9. Wave 설계 원칙

1. Wave마다 전술적 개성이 있어야 한다.
2. 단순히 적 수량만 증가시키는 방식은 피한다.
3. Unit과 Wave의 책임을 분리한다.
4. Ground / Air / Light / Heavy / Ranged 조합으로 전술적 변화를 만든다.
5. 이동속도 차이를 의도적으로 활용한다.
6. 필요한 Wave에서는 Heavy를 기준으로 전체 진군 속도를 동기화한다.
7. Tower의 약점을 Wave가 의도적으로 시험할 수 있어야 한다.
8. Robot의 직접 전투가 Tower만으로 해결되지 않는 상황을 보완해야 한다.
9. 후반으로 갈수록 Wave 구성과 전술 복합도를 높인다.
10. Enemy Robot은 최종적인 승부 결정 요소로 남긴다.

## 10. Content Editor 방향

Wave Editor는 단순히 Enemy 목록을 입력하는 화면이 아니라 다음을 조합할 수 있는 콘텐츠 편집기로 설계하는 방향을 제안한다.

```text
Wave
 ├─ Composition
 │   ├─ Light
 │   ├─ Heavy
 │   ├─ Ranged
 │   └─ Air
 │
 ├─ Group
 ├─ Formation
 ├─ Spawn Pattern
 ├─ Spawn Interval
 ├─ Movement Speed Policy
 ├─ Speed Synchronization
 ├─ Group Delay
 └─ Special Rule
```

구체적인 Schema와 Runtime 구현은 기존 Unit / Stage / Mission / Map 데이터 구조와 ODB PK 할당 체계를 READ-ONLY로 대조한 뒤 확정한다.

## 11. 범위 제한

본 문서는 Wave 설계 방향을 정의하는 제안 문서다.

다음은 본 문서에서 확정하지 않는다.

- 실제 Wave Schema
- ODB PK 할당 방식
- Runtime 구현 방식
- 구체적인 20분 Wave 수
- 실제 Unit 수치
- 난이도 곡선
- Enemy Robot의 구체적 능력

PROPOSAL은 CANON이 아니며 Master 승인 없이 Canon을 변경하지 않는다.
