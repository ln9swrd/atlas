# MENOS Robot 위치 전략성 및 Wave 4 Runtime 검증

상태: `CONFIRMED` Runtime 검증 결과 기록
프로젝트: `MENOS`
Engine: Godot `4.7.2`
Branch: `main`
최종 확인 기준 HEAD: `40cc67411418c1d4b912c7521647e7bd8d889ab5`

이 문서는 Wave 4 전투 압력과 Robot `LEFT / CENTER / RIGHT` 위치 전략성을 확인한 Runtime 실험의 과정과 결과를 기록한다. Runtime에서 직접 관찰한 사실, 코드와 좌표에서 추론한 설명, 아직 검증되지 않은 항목을 구분한다.

## 1. 실험 경계와 Git 기준선

판정: `CONFIRMED`

- 프로젝트 파일은 실험 과정에서 수정하지 않았다.
- 실험은 프로젝트 외부의 일회성 Runtime Harness로 수행했다.
- `main.tscn`을 인스턴스화하고 기존 게임 흐름을 호출하는 방식으로 검증했다.
- 임시 Harness와 로그는 실행 후 삭제했다.
- Commit과 Push는 수행하지 않았다.
- 실험 과정의 Git 상태에는 다음 staged deletion이 존재했다.

```text
D menos_center_capture.txt
D menos_wave4_experiment.gd
```

위 삭제는 실험 과정의 Git 상태로만 기록한다. 해당 삭제 자체를 MENOS 게임 로직의 변경으로 해석하지 않으며, 임의로 복구하지 않았다.

이번 문서는 문서화만 수행한다. 프로젝트 코드, 데이터, UI, Asset, Git 상태는 변경하지 않는다.

## 2. Wave 4 직행 Runtime 검증

### 2.1 목적

Wave 1~3을 기다리지 않고 Wave 4를 직접 실행해 위치 실험 시간을 줄일 수 있는지 확인했다.

### 2.2 방법

프로젝트 외부 임시 GDScript Harness에서 다음 순서로 실행했다.

```text
main.tscn 인스턴스화
    -> reset_game()
    -> wave = 4
    -> 기존 Tower 4기 배치
    -> launch_robot()
    -> move_robot("LEFT")
    -> start_wave()
```

### 2.3 확인된 Runtime 상태

```text
WAVE=4
WAVE_RUNNING=true
ROBOT_ACTIVE=true
ROBOT_SPOT=LEFT
TOWERS=4
GOLD=0
SPAWN_QUEUE=22
FEED=WAVE 4 STARTED: ALL TYPES / GIANT / BOTH LANES
```

### 2.4 판정

**Wave 4 직접 실행 가능 - Runtime VERIFIED**

이 결과는 영구적인 프로젝트 코드 수정 없이 Wave 4 직행 경로를 실행할 수 있음을 증명한다. 이는 실험 경로의 검증이며 Production 기능이 아니다.

## 3. 기본 Wave 4 위치 비교

동일한 조건에서 다음 위치를 각각 독립 Runtime으로 실행했다.

```text
LEFT
CENTER
RIGHT
```

### 3.1 결과

| Position | Result | Base HP | Robot HP | Giant/Heavy | Base reached |
| --- | --- | ---: | ---: | --- | ---: |
| LEFT | Victory | 100 | 220 | 없음 | 0 |
| CENTER | Victory | 100 | 220 | 없음 | 0 |
| RIGHT | Victory | 100 | 220 | 없음 | 0 |

### 3.2 판정

기본 Wave 4 조건에서는 세 위치의 결과 차이가 나타나지 않았다.

따라서 기본 Wave 4 결과만으로 Robot 위치의 전략적 차이가 존재한다고 판단하지 않는다. 위치 전략성은 별도의 압력 조건에서 검증해야 한다.

## 4. Spawn 2배 압력 실험

### 4.1 목적과 통제 변수

기본 조건에서 위치 차이가 나타나지 않은 원인을 확인하기 위해 Spawn 수만 2배로 증가시켰다.

기존 Spawn:

```text
Normal 8
Rusher 8
Heavy 6
Giant 1
```

실험 Spawn:

```text
Normal 16
Rusher 16
Heavy 12
Giant 2
```

다음 요소는 변경하지 않았다.

- 적 종류
- HP
- 속도
- 공격력
- Tower
- Robot
- Map
- 전투 로직

### 4.2 결과

| Position | Result | Base HP | Robot HP | Base reached |
| --- | --- | ---: | ---: | ---: |
| LEFT | Victory | 19 | 220 | 3 |
| CENTER | Victory | 100 | 220 | 0 |
| RIGHT | Victory | 46 | 220 | 2 |

Giant와 Heavy는 세 위치 모두 생존하지 않았다.

### 4.3 판정

Spawn 압력을 2배로 올리자 Robot 위치에 따른 Base 피해 차이가 명확하게 나타났다.

- CENTER: Base 피해 없음
- RIGHT: Base HP 46
- LEFT: Base HP 19

따라서 다음은 Runtime 실험으로 확인된 가능성이다.

> 기존 Wave 4에서 위치 차이가 나타나지 않은 원인 중 하나는 전투 압력이 충분하지 않았기 때문일 가능성이 있다.

이를 위치 차이의 유일한 원인이라고 단정하지 않는다.

## 5. Robot 교전 이벤트 진단

동일한 Spawn 2배 조건에서 외부 Harness로 관찰 가능한 Robot 공격 이벤트를 추가 집계했다.

### 5.1 결과

| Position | Robot engagement events | Robot direct kills | Base HP | Base reached |
| --- | ---: | ---: | ---: | ---: |
| LEFT | 219 | 19 | 19 | 3 |
| CENTER | 427 | 100 | 100 | 0 |
| RIGHT | 679 | 46 | 46 | 2 |

Robot HP는 세 위치 모두 `220`이었다.

### 5.2 해석상의 제한

`Robot engagement events`는 고유 Enemy 처치 수가 아니다. 기존 전투 효과에서 관찰 가능한 Robot 공격 이벤트 수이며 실제 성능 지표와 동일하게 취급하지 않는다.

`Robot direct kills`도 직접 공격 효과와 같은 Tick에 Enemy HP가 0이 된 경우만 보수적으로 집계한 값이다.

따라서 이 데이터를 근거로 다음을 확정하지 않는다.

- Robot DPS 우열
- 실제 총 피해량
- 정확한 처치 기여율

## 6. Lane Geometry 검증

### 6.1 확인된 좌표

Runtime 결과가 실제 Map geometry와 일치하는지 코드와 좌표를 이용해 별도로 검증했다.

```text
Base:
(790, 330)

Robot:
LEFT   (360, 245)
CENTER (555, 330)
RIGHT  (360, 415)

Left Entry:
(70, 180)

Right Entry:
(70, 480)
```

Robot 일반 공격 Range는 `110`이다.

고정 Tower 좌표와 Range는 다음과 같다.

```text
Cannon L1  (250,110) Range 155
Gatling R1 (250,550) Range 145
Gatling L2 (430,190) Range 145
Cannon R2  (430,470) Range 155
```

Entry에서 Base로 이어지는 직선 Lane을 가정하고, Robot Range 원과 Lane의 교차 구간을 계산했다. 여기서 `t=0`은 Entry, `t=1`은 Base다.

### 6.2 Robot Coverage

| Robot 위치 | Left Lane coverage | Right Lane coverage |
| --- | --- | --- |
| LEFT | `t=0.255 ~ 0.553` | 없음 |
| CENTER | `t=0.553 ~ 0.822` | `t=0.553 ~ 0.822` |
| RIGHT | 없음 | `t=0.255 ~ 0.553` |

### 6.3 Geometry 해석

- LEFT는 Left Lane을 집중 지원한다.
- RIGHT는 Right Lane을 집중 지원한다.
- CENTER는 양쪽 Lane의 후반부를 동시에 지원한다.
- 고정 Tower는 각 Lane의 초반부터 중반을 담당한다.
- Robot은 위치에 따라 후반부의 추가 커버리지를 제공한다.

### 6.4 Runtime과 Geometry의 일치

관찰된 결과는 다음과 같다.

```text
LEFT   -> Right lane에서 Base 피해
RIGHT  -> Left lane에서 Base 피해
CENTER -> Base 피해 없음
```

이는 Robot Range geometry와 일치한다.

### 6.5 판정

**현재 위치별 전투 차이는 Robot 공격력 차이보다는 Lane 공간 커버리지 차이로 설명하는 것이 타당하다.**

다만 타겟 선택 순서와 개별 Enemy의 정확한 프레임별 이동 경로는 별도로 검증하지 않았다. 해당 부분은 `UNVERIFIED`로 기록한다.

## 7. Lane 집중 실험

한쪽 Lane에 압력을 집중시키고 Robot 위치별 결과를 추가 비교했다.

### 7.1 조건 A - Left Focus

Spawn:

```text
Normal 8
Rusher 8
Heavy 6
```

결과:

| Position | Base HP | Base reached | Engagement |
| --- | ---: | ---: | ---: |
| LEFT | 100 | 0 | 21 |
| CENTER | 100 | 0 | 10 |
| RIGHT | 46 | 3 | 0 |

### 7.2 조건 B - Right Focus

Spawn:

```text
Normal 8
Rusher 8
Heavy 6
Giant 2
```

결과:

| Position | Base HP | Base reached | Engagement |
| --- | ---: | ---: | ---: |
| LEFT | 19 | 3 | 0 |
| CENTER | 100 | 0 | 33 |
| RIGHT | 100 | 0 | 68 |

### 7.3 판정

이 실험에서는 활성 Lane에 대응하는 측면 위치와 CENTER가 동일한 Base 결과를 냈다. 반대 측면 위치만 Base 피해를 받았다.

따라서 다음을 확정하지 않는다.

> 측면 위치가 CENTER보다 항상 우월하다는 증거는 확보되지 않았다.

동시에 다음도 확정하지 않는다.

> CENTER가 모든 상황에서 엄격하게 우월하다.

현재까지 확인되는 설계적 의미는 다음과 같다.

- CENTER: 양쪽 대응 가능한 범용 위치
- LEFT: Left 위협 집중 위치
- RIGHT: Right 위협 집중 위치

## 8. Robot 이동 시스템 코드 검증

Runtime 재실행 없이 코드와 데이터를 확인한 결과다.

### 8.1 이동

- Robot은 기본적으로 CENTER에서 출격한다.
- 플레이어가 `LEFT`, `CENTER`, `RIGHT` 마커를 클릭하면 `move_robot()`이 호출된다.
- 위치는 즉시 변경된다.

### 8.2 이동 제한

```text
이동 1회마다: commands -= 1
초기 이동 명령: 5
Gold 비용: 없음
동일 위치 클릭: 이동하지 않음
```

### 8.3 Wave 진행 중 이동

`move_robot()`에는 다음 조건이 없다.

```text
run_state
wave_running
```

따라서 Robot이 출격되어 있고 이동 명령이 남아 있다면 Wave 진행 중에도 위치 변경이 가능하다. 이는 코드 구조에서 확인된 사실이며, 이 동작이 플레이어에게 최적의 전략으로 인식되는지는 `UNVERIFIED`다.

### 8.4 위치 역할의 데이터 표현

`data.gd`에는 다음 값이 존재한다.

- Robot HP
- 공격력
- Range
- 이동 횟수
- 능력 수치

그러나 다음과 같은 명시적 역할 metadata는 없다.

```text
CENTER = versatile
LEFT = left_lane_defense
RIGHT = right_lane_defense
```

현재 역할은 좌표와 Range에서 암묵적으로 발생한다.

## 9. 현재 검증 결과의 분류

### 9.1 CONFIRMED

- Wave 4를 직접 실행할 수 있다.
- 기본 Wave 4에서는 위치 차이가 관찰되지 않았다.
- Spawn 2배에서 위치별 Base 피해 차이가 발생했다.
- `LEFT / CENTER / RIGHT`는 서로 다른 공격 영역을 가진다.
- CENTER는 양쪽 Lane 후반부를 동시에 커버한다.
- LEFT와 RIGHT는 각각 한쪽 Lane에 집중한다.
- 반대 Lane에서 Base 피해가 발생하는 Runtime 현상이 geometry와 일치한다.
- Robot 이동 명령은 제한 자원이다.
- Wave 진행 중 Robot 이동이 코드상 가능하다.
- 위치 역할은 명시적인 metadata가 아니라 좌표와 Range에서 파생된다.

### 9.2 INFERENCE

- Robot 위치 선택의 핵심 전략 요소는 Lane coverage다.
- CENTER는 범용 대응 위치로 해석할 수 있다.
- LEFT와 RIGHT는 상황별 Lane 집중 대응 위치로 해석할 수 있다.
- 측면 위치에는 반대 Lane 대응력을 포기하는 trade-off가 존재할 가능성이 높다.
- 기본 Wave 4에서 차이가 없었던 원인 중 하나는 전투 압력 부족일 가능성이 있다.

### 9.3 UNVERIFIED

- 실제 플레이에서 이동 명령을 언제 사용하는 것이 최적인지
- 이동 횟수 5회의 적정성
- 타겟 선택 순서가 위치 전략에 미치는 세부 효과
- 플레이어가 위치 차이를 재미있는 전략 선택으로 인식하는지
- 혼합 Lane 압력에서 LEFT, CENTER, RIGHT의 trade-off가 명확하게 발생하는지
- 개별 Enemy의 정확한 프레임별 이동 경로가 결과에 미치는 영향
- Robot engagement events가 실제 총 피해량 또는 처치 기여율을 대표하는지

## 10. 다음 검증 예정 지점

상태: `PROPOSAL` / 자동 실행하지 않음

다음 검증 후보는 혼합 Lane 압력에서 실제 trade-off가 발생하는지 확인하는 것이다.

동일한 혼합 Lane 조건에서 다음 세 위치를 독립 실행한다.

```text
LEFT
CENTER
RIGHT
```

비교할 항목:

- Base HP
- Base reached
- Base reached Lane
- Robot HP
- Robot engagement

핵심 질문:

> 측면 위치가 한쪽 Lane 대응력을 확보하는 대신 반대 Lane 대응력을 잃는가?

명확한 trade-off가 확인되면 해당 검증을 `ACCEPT / STOP`으로 종료하며, 추가 밸런스 작업으로 자동 확대하지 않는다.

## 11. 문서화 주의사항

다음 표현은 확정적으로 사용하지 않는다.

- CENTER가 최고의 위치다.
- LEFT가 최고의 위치다.
- RIGHT가 최고의 위치다.
- Robot 위치가 밸런스를 해결한다.
- 현재 밸런스가 완성됐다.
- 플레이어에게 반드시 재미있는 전략이다.

현재 데이터는 구조적 역할과 Runtime 차이의 존재를 보여주는 것이지, 최종 게임 밸런스나 재미를 검증한 것이 아니다.

Runtime 결과와 geometry 계산 결과는 하나의 직접 관찰 결과처럼 섞지 않는다.

```text
Runtime Observation
+ Code / Geometry Analysis
= 설명 가능한 구조적 관계
```

## 12. 작업 제한

이번 작업은 구현 지시가 아니다. 다음 작업은 수행하지 않았다.

- 프로젝트 코드 수정
- 데이터 수정
- UI 수정
- Asset 수정
- Runtime Harness를 프로젝트에 편입
- 추가 Runtime 검증 자동 실행
- 밸런스 조정
- Git 상태 변경
- Git Commit 또는 Push

`CENTER / LEFT / RIGHT`의 역할은 현재 코드 구조에서 발생하는 관찰된 설계 특성으로만 기록한다. 별도의 역할 metadata나 디자인 문구를 프로젝트 코드에 추가하지 않는다.

## 13. 최종 상태

현재 단계의 결론은 다음과 같다.

> Robot 위치 시스템은 단순한 장식적 이동이 아니라 제한된 이동 명령과 Lane coverage를 결합한 전략 요소로 기능할 수 있는 구조가 확인되었다. 다만 혼합 Lane 상황에서의 명확한 trade-off는 아직 검증되지 않았다.

이 문서는 확인된 Runtime 결과와 코드/geometry 분석을 기록하는 기준선이다. 문서화 완료 후 프로젝트 구현, 밸런스 조정, 추가 실험으로 자동 확장하지 않는다.