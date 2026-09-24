# MENOS PoC 설계-구현 정합성 검증

상태: `PASS` 구조 대조 완료 / `PIE: UNVERIFIED`
목적: 현재 MENOS 설계와 Browser/Godot PoC가 `Robot 위치 선택이 실제 전략적 의사결정을 만든다`는 가설을 검증할 수 있는 구조인지 READ-ONLY로 대조한다.

## 1. 기준선

- 프로젝트: `MENOS`
- HEAD: `a906aa52dc51eb5ef8bf014b44576efe0e1cb212`
- Branch: `main`
- Working Tree: clean
- Engine: Godot `4.7.2` 설정 확인
- 조사 파일: `README.md`, `state/CURRENT_STATE.md`, `MENOS_DESIGN_SPEC.md`, `data.js`, `game.js`, `index.html`, `godot/data.gd`, `godot/main.gd`, `godot/main.tscn`, `godot/project.godot`

이번 작업에서는 기존 변경사항을 수정하거나 되돌리지 않았다. 코드, 데이터, Asset, UI를 변경하지 않았으며 Commit과 Push도 수행하지 않았다.

## 2. 판정 표기

- `CONFIRMED`: 코드 경로에서 직접 확인됨
- `HIGH CONFIDENCE`: 직접 실행하지 않았지만 구조상 충분한 근거가 있음
- `INFERENCE`: 코드 구조에서 논리적으로 추론함
- `UNVERIFIED`: Runtime/PIE 없이는 확정할 수 없음
- `MISMATCH`: 설계와 실제 구현이 서로 다름

다음 구분을 유지한다.

```text
버튼 존재 != 상태 변경
상태 변경 != 게임 로직 반영
게임 로직 반영 != 실제 전략적 결과
```

코드상 결과 발생 가능성은 실제 Runtime 결과 확인과 동일하지 않다.

## 3. 설계 기준

### 3.1 핵심 게임 루프

설계 문서의 핵심 루프는 다음이다.

```text
Tower 배치
    -> Robot 출격
    -> Robot 위치 선택
    -> Wave 진행
    -> 적 공격과 방어
    -> 전투 결과 변화
    -> 다음 상황 판단
```

플레이어는 Tower를 배치하고 Robot을 출격시키며 위치를 지정한다. Robot의 이동, 타겟 판단, 공격, 능력 사용은 자동이어야 한다.

### 3.2 핵심 전략 변수

- Robot 위치: `LEFT`, `CENTER`, `RIGHT`
- 이동 명령 제한
- 위치에 따른 Lane coverage
- Tower와 Robot의 역할 분리
- Wave별 위협 조합

현재 Runtime 기록에서는 위치별 Lane coverage와 Base 피해 차이가 일부 압력 조건에서 확인되었지만, 모든 성공 조건과 재미는 아직 `UNVERIFIED`다.

### 3.3 PoC 성공 조건

설계 문서에 명시된 성공 조건은 다음이다.

1. Robot 위치에 따라 전투 결과가 달라진다.
2. 좋은 위치와 나쁜 위치의 차이가 존재한다.
3. 한 위치에 계속 두는 것이 항상 최선이 아니다.
4. Tower와 Robot의 역할이 다르다.
5. 직접 공격하지 않아도 플레이어의 개입 판단이 생긴다.
6. Giant가 Robot 출격의 의미를 만든다.
7. 새 Robot 능력이 시각적·전투적 변화를 만든다.

현재 대조 결과:

| 조건 | 현재 판정 |
| --- | --- |
| 위치 선택이 전투 계산에 연결됨 | `CONFIRMED` |
| 이동 명령이 제한됨 | `CONFIRMED` |
| 위치별 결과 차이가 발생할 수 있음 | `HIGH CONFIDENCE` |
| 좋은 위치와 나쁜 위치가 실제로 반복해서 구분됨 | `UNVERIFIED` |
| 한 위치가 항상 최선이 아님 | `UNVERIFIED` |
| Tower와 Robot의 공격 경로가 구분됨 | `CONFIRMED` |
| 플레이어가 의미 있는 개입 판단을 느낀다 | `UNVERIFIED` |
| Giant가 출격 의미를 만든다 | `HIGH CONFIDENCE` 구조 / 실제 체감 `UNVERIFIED` |
| 능력 해금이 시각적·전투적 변화를 만든다 | 현재 PoC 해금 흐름 `UNVERIFIED` |

## 4. Browser 구현 대조

조사 기준: `data.js`, `game.js`, `index.html`

### 4.1 Robot 생성과 위치 상태

`game.js`의 `resetGame()`에서 Robot 상태를 생성한다.

```text
active: false
x/y: MAP.robotSpots[1]의 CENTER 좌표
hp: ROBOT.hp
commands: ROBOT.maxMoves
targetSpot: CENTER
attackTimer / areaTimer / pierceTimer
```

`data.js`에는 다음 세 위치가 좌표와 함께 정의되어 있다.

```text
LEFT   (280, 215)
CENTER (400, 280)
RIGHT  (280, 345)
```

판정: `CONFIRMED`

### 4.2 출격과 위치 선택

`index.html`의 `LAUNCH ATLAS-01` 버튼은 `game.js`의 launch handler를 호출하고 Robot을 CENTER에서 활성화한다. Canvas 클릭은 Robot 위치 hit test를 거쳐 `moveRobot(spot)`을 호출한다.

`moveRobot(position)`은 다음을 수행한다.

```text
!robot.active 또는 commands <= 0이면 return
동일 위치이면 return
targetSpot = spot.id
robot.x/y = spot.x/y
robot.commands -= 1
```

판정:

- 위치 선택 가능: `CONFIRMED`
- 이동 명령 비용 존재: `CONFIRMED`
- 비용은 Gold가 아닌 명령 횟수: `CONFIRMED`
- 위치 변경은 즉시 수행: `CONFIRMED`

### 4.3 위치의 전투 반영

`updateRobot(dt)`은 `robot.x`, `robot.y`를 직접 사용한다.

```text
nearestEnemy(robot.x, robot.y, ROBOT.range)
nearestEnemy(robot.x, robot.y, ROBOT.range + 20, 'heavy')
enemy distance to robot <= ability_area.radius
effect position = robot.x/y
```

`nearestEnemy()`는 Enemy와 Robot의 거리를 비교해 후보를 만들고 `x` 기준으로 정렬한다. 따라서 위치 변경은 UI 상태에 그치지 않고 공격 후보와 Area 공격 범위를 바꾼다.

판정: `CONFIRMED`

### 4.4 Wave와 결과값

`startWave()`는 `data.js`의 Wave에서 Spawn Queue를 만들고 `update(dt)`는 다음 순서로 실행한다.

```text
spawnDueEnemies()
    -> moveEnemies()
    -> updateTowers()
    -> updateRobot()
    -> finishWaveIfReady()
```

결과 연결:

- Enemy 처치: `gold += reward`
- Enemy Base 도달: `baseHp -= baseDamage`
- Robot 공격/능력: Enemy HP 감소
- Wave 완료: `waveRunning`, `waveComplete`, `currentWave` 변경
- Feed: 공격, 위치 변경, Base 피격, Giant 처치 기록

판정: `CONFIRMED`

### 4.5 Browser 결론

Browser PoC는 Robot 위치를 상태로 저장하고, 이동 명령을 차감하며, 위치를 거리 기반 타겟팅과 Area 공격에 연결한다. 따라서 동일한 Tower/Wave 조건에서 위치만 바꾸면 전투 결과가 달라질 수 있는 구조다.

판정: `HIGH CONFIDENCE`

이는 코드 구조 판정이며 Browser Runtime 결과를 이번 조사에서 직접 실행해 확정한 것은 아니다.

## 5. Godot 구현 대조

조사 기준: `godot/data.gd`, `godot/main.gd`, `godot/main.tscn`, `godot/project.godot`

### 5.1 Robot 생성과 위치 상태

`reset_game()`은 다음 Robot 상태를 생성한다.

```text
active: false
spot: CENTER
position: ROBOT_SPOTS.CENTER
hp: DATA.ROBOT.hp
commands: DATA.ROBOT.max_moves
attack / area / pierce cooldowns
```

`main.gd`에는 다음 위치와 좌표가 정의되어 있다.

```text
LEFT   (360, 245)
CENTER (555, 330)
RIGHT  (360, 415)
```

판정: `CONFIRMED`

### 5.2 출격과 위치 선택

`handle_click()`은 Robot 위치 영역을 검사하고 `move_robot(id)`를 호출한다. `launch_robot()`은 Robot을 CENTER에서 활성화한다.

`move_robot(id)`은 다음을 수행한다.

```text
!robot.active 또는 commands <= 0 또는 같은 위치이면 return
robot.spot = id
robot.position = ROBOT_SPOTS[id]
robot.commands -= 1
log_event(...)
```

판정:

- 위치 선택 가능: `CONFIRMED`
- 이동 명령 비용 존재: `CONFIRMED`
- 비용은 Gold가 아닌 명령 횟수: `CONFIRMED`
- 위치 변경은 즉시 수행: `CONFIRMED`
- Wave 진행 중 위치 변경 차단: `MISMATCH` with 이동 시간 설계 방향

`move_robot()`에는 `run_state` 또는 `wave_running` guard가 없으므로, 활성 Robot과 남은 명령이 있으면 Wave 진행 중에도 이동할 수 있다. 설계 문서의 이동 시간과 이동 중 피격은 현재 구현이 아니라 `PROPOSAL / UNVERIFIED`다.

### 5.3 위치의 전투 반영

`update_robot(delta)`은 `robot.position`을 `find_target()`에 전달한다.

```text
find_target(robot.position, DATA.ROBOT.range)
find_target(robot.position, DATA.ROBOT.range + 20.0, "heavy")
enemy.position.distance_to(robot.position) <= ability_area.radius
```

`find_target()`은 Robot 위치를 기준으로 거리 내 Enemy 후보를 만들고 Preference와 `position.x` 정렬을 적용한다. 따라서 위치 변경은 일반 공격, Heavy/Pierce 선택, Area 공격의 후보를 바꾼다.

판정: `CONFIRMED`

### 5.4 Wave와 결과값

`_process(delta)`에서 `wave_running`이면 다음 순서로 실행한다.

```text
spawn_enemies()
    -> move_enemies(delta)
    -> update_towers(delta)
    -> update_robot(delta)
    -> check_wave_clear()
```

결과 연결:

- Enemy 처치: `gold += data.reward`
- Enemy Base 도달: `base_hp -= data.base_damage`
- Robot 공격/능력: Enemy HP 감소
- Wave 완료: `wave_running`, `wave_clear`, `wave`, `run_state` 변경
- Feed: Wave 시작, 위치 이동, Base 침투, Giant 처치, 승패 기록

판정: `CONFIRMED`

### 5.5 Godot 구조상 확인된 상태 결함

- 일반 Wave Clear 후 `run_state`가 READY로 복귀하지 않아 다음 Wave 시작이 차단된다.
- Base 도달로 DEFEAT가 설정된 같은 Frame에 후속 함수가 실행될 수 있다.
- 최종 Wave에서는 `DEFEAT` 후 `check_wave_clear()`가 `VICTORY`로 덮어쓸 가능성이 있다.

판정: `MISMATCH` with intended multi-Wave loop / `CONFIRMED` code defect

이 결함은 이번 작업에서 수정하지 않는다.

## 6. 핵심 질문 결과

| 질문 | 판정 | 근거 |
| --- | --- | --- |
| Q1. Robot이 LEFT/CENTER/RIGHT를 선택할 수 있는가? | `CONFIRMED` | Browser Canvas hit test와 `moveRobot()`, Godot `handle_click()`과 `move_robot()`가 세 위치 상태를 변경함 |
| Q2. 위치 선택에 실제 자원/명령 비용이 있는가? | `CONFIRMED` | 양 구현 모두 `commands <= 0` guard와 이동 시 `commands -= 1`; Gold 차감은 없음 |
| Q3. 위치가 전투 계산/타겟 선택에 영향을 주는가? | `CONFIRMED` | Robot 좌표가 거리 기반 후보, Heavy target, Area 범위 계산에 직접 사용됨 |
| Q4. 동일 조건에서 위치별 결과가 달라질 구조인가? | `HIGH CONFIDENCE` | 위치별 공격 후보와 Lane coverage가 달라지지만 이번 조사에서 Runtime을 실행하지 않음 |
| Q5. 차이가 실제 게임 상태 변화인가? | `HIGH CONFIDENCE` | Enemy HP, Base HP, Gold, Wave 완료 조건으로 이어지는 코드 경로가 있음; 실제 실행 결과는 `UNVERIFIED` |
| Q6. 현재 PoC만으로 전략 변수 가설을 검증할 수 있는가? | `ACCEPT` 구조 판정 | 비교 실험을 수행할 입력, 비용, 전투 연결, 결과값이 모두 존재함. 단, 성공이나 재미가 이미 입증된 것은 아님 |

## 7. 설계-구현 불일치

### 7.1 Godot Wave 진행

설계는 4개 Wave의 연속 진행을 전제로 하지만 Godot `check_wave_clear()` 일반 분기에서 `run_state`를 READY로 돌려놓지 않는다. `start_wave()`는 READY를 요구하므로 다음 Wave가 차단된다.

판정: `MISMATCH`

### 7.2 Robot 피해와 파괴

설계는 Robot이 공격받고 파괴될 수 있는 전략적 자산임을 전제로 한다. 그러나 Browser와 Godot의 현재 전투 경로는 `damageEnemy`/`damage_enemy`에서 Enemy HP만 감소시키며 Robot HP를 감소시키는 경로를 확인하지 못했다.

판정: `MISMATCH`

Robot 상태 Guard 자체는 존재하지만, 전투 피해로 Robot이 사망 상태에 진입하는 경로는 `UNVERIFIED / 현재 코드상 확인되지 않음`이다.

### 7.3 이동 시간

설계 방향은 이동 중 시간이 발생하고 이동 중 피격될 수 있는 구조를 검토하지만, 현재 Browser와 Godot 모두 위치를 즉시 바꾼다.

판정: `MISMATCH` with proposed movement-time behavior / current PoC immediate movement is `CONFIRMED`

## 8. 검증 상태

- CODE: `PASS` - Browser와 Godot의 핵심 코드 경로 READ-ONLY 대조 완료
- BUILD: `HIGH CONFIDENCE` - 기존 프로젝트 상태 문서에서 Godot headless/editor 확인을 기록했으나 이번 작업에서 Build를 재실행하지 않음
- EDITOR: `HIGH CONFIDENCE` - 기존 상태 문서에서 Godot Editor 확인을 기록했으나 이번 작업에서 Editor를 재실행하지 않음
- PIE: `UNVERIFIED` - 이번 작업에서 Runtime/PIE를 실행하지 않음

## 9. 최종 판정

### ACCEPT

현재 MENOS PoC는 `Robot 위치 선택이 실제 전략적 의사결정을 만들 수 있는가`라는 가설을 검증할 수 있는 **구조**를 갖추고 있다.

근거:

```text
위치 선택
    -> 제한된 commands 차감
    -> Robot 좌표 변경
    -> 거리 기반 타겟/능력 후보 변경
    -> Enemy HP 및 Base HP 변화 가능
    -> Gold, Wave, Feed 등 결과 상태 변화
```

다만 이는 검증 가능한 구조에 대한 판정이다. 실제 위치별 승패, 최적 위치, 반복 재미, 모든 PoC 성공 조건은 Runtime 실행 전까지 확정하지 않는다.

Godot의 Wave 진행 결함, Robot 피해 경로 부재, 즉시 이동은 발견된 정합성 문제로 기록하며 이번 작업에서 수정하지 않는다.

## 10. 미확인 사항

- Browser와 Godot에서 실제 LEFT/CENTER/RIGHT 결과 차이가 발생하는지
- 동일 Tower/Wave 조건에서 위치별 Base HP와 승패가 어떻게 달라지는지
- 위치 차이가 실제 플레이어에게 전략적 선택으로 인식되는지
- 한 위치가 항상 최선이 아닌지
- 이동 명령 5회의 적정성과 최적 사용 시점
- Robot 피해와 사망 상태의 의도된 Production 설계
- Robot 능력 해금이 실제 전투 방식과 시각 피드백을 바꾸는지
- Godot 일반 Wave 결함을 수정한 뒤 4개 Wave 비교가 가능한지

## 11. OUT OF SCOPE

- 코드, 데이터, 씬, UI, Asset 수정
- 기능 추가와 리팩터링
- 밸런스 수정
- 새로운 Enemy, Tower, Robot 추가
- Runtime/PIE 실행
- Production 구조 변경
- DLC와 멀티플레이 설계
- Git Commit과 Push

이번 대조 결과는 추가 구현이나 Runtime 실험으로 자동 확장하지 않는다.
