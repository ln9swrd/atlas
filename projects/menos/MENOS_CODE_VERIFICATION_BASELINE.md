# MENOS 코드 검증 기준선

상태: `CONFIRMED` 코드 READ-ONLY 분석 결과
범위: Godot PoC의 전투, 경제, 타워 슬롯, Robot 공격, Wave/RunState 상태 전이

이 문서는 이번 대화에서 수행된 Godot 코드 READ-ONLY 검증 결과를 기록한다. 실제 Runtime/PIE 플레이 결과가 아니며, 아래 판정은 코드 구조를 직접 확인한 결과다.

## 1. 판정 표기

- `CONFIRMED`: 코드에서 직접 확인됨
- `ACCEPT`: 현재 동작이 검증 결과와 일치하며 결함이 확인되지 않음
- `INFERENCE`: 코드에서 논리적으로 추론한 동작
- `UNVERIFIED`: Runtime/PIE 등으로 아직 확인하지 않음
- `HOLD`: 결함 또는 추가 확인이 필요한 상태

특히 다음을 구분한다.

```text
Runtime/PIE = NOT VERIFIED
```

이번 문서는 확인된 현재 상태만 기록하며, 수정안이나 향후 구현을 현재 동작 사실과 섞지 않는다.

## 2. Enemy 검증

### 2.1 Armor 시스템

판정: `CONFIRMED / ACCEPT`

모든 Enemy Type에 `armor`가 정의되어 있다.

| Enemy Type | Armor |
| --- | ---: |
| normal | `0.0` |
| rusher | `0.0` |
| heavy | `8.0` |
| giant | `18.0` |

Tower와 Robot의 공격은 모두 `damage_enemy()`를 통과한다. 실제 피해 계산은 다음과 같다.

```text
enemy.hp -= max(1.0, amount - data.armor)
```

Armor 적용은 `damage_enemy()`에서 단일하게 수행된다. 공격 호출부에서 Armor를 사전 차감하는 별도 경로는 확인되지 않았다.

### 2.2 Reward와 Gold

판정: `CONFIRMED / ACCEPT`

Enemy Reward는 다음과 같다.

| Enemy Type | Reward |
| --- | ---: |
| normal | `12` |
| rusher | `10` |
| heavy | `28` |
| giant | `90` |

처치 시 다음 경로로 Gold가 증가한다.

```text
gold += data.reward
```

`damage_enemy()` 진입부의 다음 guard가 이미 사망한 Enemy의 중복 Reward 지급을 차단한다.

```text
if enemy == null or enemy.hp <= 0.0:
    return
```

Base 도달 경로는 다음과 같다.

```text
base_hp -= data.base_damage
enemy.hp = 0.0
```

Base 도달 시에는 `damage_enemy()`를 호출하지 않으므로 Reward가 지급되지 않는다.

## 3. Tower 검증

### 3.1 Gold 경제 연결

판정: `CONFIRMED / ACCEPT`

Tower 비용은 다음과 같다.

```text
Cannon = 55
Gatling = 35
```

건설 흐름은 다음과 같다.

```text
Enemy 처치
    -> gold += reward
    -> build_tower()
    -> gold < data.cost 검사
    -> 충분하면 gold -= data.cost
    -> towers.append()
```

Gold가 부족하면 다음 동작을 한다.

```text
gold < cost
    -> return
    -> Tower 생성 없음
    -> Gold 차감 없음
```

현재 확인 범위에서 Tower 건설 외 별도의 Gold 감소 경로는 없다.

### 3.2 Slot 점유

판정: `CONFIRMED / ACCEPT`

현재 Slot은 6개다.

```text
L1, L2, L3, R1, R2, R3
```

Tower 객체에는 Slot ID가 다음과 같이 저장된다.

```text
"id": selected_slot
```

선택 단계와 `build_tower()` 양쪽에서 기존 Tower의 동일 ID를 검사한다. 동일 Slot을 재건설하면 다음 흐름이 발생한다.

```text
tower.id == selected_slot
    -> return
    -> Tower 추가 없음
    -> Gold 차감 없음
```

### 3.3 Cooldown

판정: `CONFIRMED / ACCEPT`

Tower 생성 시 Cooldown 초기값은 다음과 같다.

```text
"cooldown": 0.0
```

`update_towers(delta)`에서 매 업데이트마다 감소한다.

```text
tower.cooldown -= delta
```

Cooldown이 남아 있으면 공격하지 않는다. 공격 후에는 다음과 같이 해당 데이터의 Cooldown을 재설정한다.

```text
tower.cooldown = tower.data.cooldown
```

| Tower | Cooldown |
| --- | ---: |
| Cannon | `1.35` |
| Gatling | `0.23` |

따라서 첫 공격은 초기 `0.0` 상태에서 가능하고, 이후 공격은 데이터 Cooldown에 의해 제한된다.

### 3.4 Target Preference

판정: `CONFIRMED / ACCEPT`

Tower별 우선 대상은 다음과 같다.

```text
Cannon  -> preference = "heavy"
Gatling -> preference = "fast"
```

Cannon은 사거리 내 Heavy/Giant를 우선하고, Gatling은 사거리 내 Normal/Rusher를 우선한다. 우선 대상이 없으면 전체 후보로 fallback한다.

최종 선택 기준은 다음 정렬이다.

```text
candidates.sort_custom(
    func(a, b): return a.position.x > b.position.x
)
```

즉 `position.x`가 큰 Enemy가 최종적으로 우선 선택된다.

## 4. Robot 전투 검증

### 4.1 Cooldown

판정: `CONFIRMED / ACCEPT`

초기값은 다음과 같다.

```text
attack = 0.0
area = 0.0
pierce = 0.0
```

매 업데이트마다 각각 감소한다.

```text
robot.attack -= delta
robot.area -= delta
robot.pierce -= delta
```

| 공격 | Cooldown |
| --- | ---: |
| General Attack | `0.65` |
| Pierce | `7.0` |
| Area | `6.0` |

각 공격 후에는 자신의 Cooldown만 재설정된다. 세 Cooldown은 독립적으로 관리된다.

### 4.2 사거리

판정: `CONFIRMED / ACCEPT`

General의 기본 사거리는 다음과 같다.

```text
DATA.ROBOT.range = 110.0
```

Pierce는 기본 사거리에 20을 더한다.

```text
DATA.ROBOT.range + 20.0
```

따라서 현재 Pierce의 실제 판정 범위는 `130.0`이다. Area의 범위는 다음과 같다.

```text
DATA.ROBOT.ability_area.radius = 72.0
```

모든 거리 판정은 현재 Robot 위치를 기준으로 한다.

### 4.3 Area 공격

판정: `CONFIRMED / ACCEPT`

Area 대상은 다음 조건으로 수집된다.

```text
enemy.hp > 0.0
and enemy.position.distance_to(robot.position)
    <= DATA.ROBOT.ability_area.radius
```

Threshold는 `3`이다. 범위 내 Enemy가 3명 이상이면 발동한다.

발동 시 범위 내 각 Enemy에 대해 한 번씩 `damage_enemy()`가 호출된다.

```text
for enemy in nearby:
    damage_enemy(enemy, DATA.ROBOT.ability_area.damage, "area")
```

이후 Robot Area Cooldown을 재설정한다.

```text
robot.area = DATA.ROBOT.ability_area.cooldown
```

### 4.4 General과 Pierce의 상호배타성

판정: `CONFIRMED / ACCEPT`

General과 Pierce는 다음 `if`/`elif` 구조에 있다.

```text
if robot.pierce <= 0.0 and not heavy.is_empty():
    ...
elif robot.attack <= 0.0 and not target.is_empty():
    ...
```

따라서 동일한 `update_robot()` 호출에서 General과 Pierce가 동시에 실행되지는 않는다. Pierce가 Cooldown 중이거나 Heavy/Giant Target이 없으면 General 조건으로 fallback할 수 있다. 두 공격의 Cooldown은 서로 독립적으로 관리된다.

### 4.5 Area와 General/Pierce의 관계

판정: `CONFIRMED / ACCEPT`

Area는 General/Pierce 분기보다 먼저 별도의 `if`로 실행된다. Area 블록 뒤에 `return`이 없다.

따라서 한 번의 `update_robot()` 호출에서 다음 조합이 가능하다.

```text
Area + Pierce
Area + General
```

Area, General, Pierce의 Cooldown은 독립적이다.

### 4.6 Robot 상태 Guard

판정:

- 상태별 공격 차단: `CONFIRMED`
- Robot 사망 상태 진입 경로: `UNVERIFIED` / 현재 코드상 해당 경로 없음

`update_robot()` 시작부에는 다음 guard가 있다.

```text
if not robot.active or robot.hp <= 0.0:
    return
```

따라서 다음 상태에서는 공격이 실행되지 않는다.

- `active == false`
- `hp <= 0.0`

그러나 현재 `damage_enemy()`는 Enemy HP만 감소시키며 Robot HP를 감소시키지 않는다. 따라서 현재 코드에서 Robot이 전투 피해로 사망 상태에 도달하는 경로는 확인되지 않았다.

## 5. Wave와 RunState 검증

### 5.1 `_process()` 실행 순서

`wave_running == true`일 때 실행 순서는 다음과 같다.

```text
spawn_enemies()
    -> move_enemies()
    -> update_towers()
    -> update_robot()
    -> check_wave_clear()
```

### 5.2 DEFEAT 동일 프레임 후속 처리

판정: `CONFIRMED / HOLD`

Enemy가 Base에 도달하고 Base HP가 0 이하가 되면 `move_enemies()`에서 다음 상태를 설정한다.

```text
base_hp = 0.0
wave_running = false
run_state = RunState.DEFEAT
return
```

그러나 이 `return`은 `move_enemies()`만 종료한다. 같은 `_process()` 프레임에서 이후 함수가 계속 실행될 수 있다.

```text
update_towers()
    -> update_robot()
    -> check_wave_clear()
```

`update_robot()` 자체에는 `run_state` 검사가 없다. 따라서 DEFEAT가 발생한 동일 프레임에 Robot 공격이 실행될 가능성이 코드상 존재한다.

### 5.3 DEFEAT에서 VICTORY로 덮어쓰기

판정: `CONFIRMED / HOLD`

`check_wave_clear()`는 다음 조건만 확인한다.

```text
if not spawn_queue.is_empty() \\
or enemies.any(func(enemy): return enemy.hp > 0.0):
    return
```

즉 다음 조건을 만족하면 Clear 처리가 진행된다.

```text
spawn_queue empty
+ 살아있는 Enemy 없음
```

DEFEAT 상태 또는 `base_hp <= 0`에 대한 guard는 없다. Base 도달 Enemy는 다음과 같이 처리된다.

```text
enemy.hp = 0.0
```

따라서 최종 Wave에서 DEFEAT를 발생시킨 마지막 Enemy가 제거되고 Spawn Queue도 비어 있다면, 같은 `_process()`에서 다음 경로가 코드상 존재한다.

```text
DEFEAT
    -> check_wave_clear()
    -> Final Wave Clear
    -> run_state = VICTORY
```

이는 기존 상태 전이 결함으로 기록한다. 이번 작업에서는 수정하지 않는다.

## 6. 일반 Wave 진행 결함

판정: `CONFIRMED / HOLD`

`check_wave_clear()`의 일반 Wave 분기는 다음 동작을 한다.

```text
wave_running = false
wave_clear = true

if wave < DATA.WAVES.size():
    wave += 1
```

일반 Wave에서는 `run_state`가 READY로 변경되지 않는다. Clear 직후 상태는 다음과 같다.

```text
run_state = RUNNING
wave_running = false
wave_clear = true
wave = next wave
```

`start_wave()`는 다음 조건을 요구한다.

```text
if run_state != RunState.READY \\
or wave_running \\
or base_hp <= 0.0 \\
or wave > DATA.WAVES.size():
    return
```

따라서 `run_state == RUNNING` 상태 때문에 다음 Wave 시작이 차단된다. 직접 원인은 `wave_clear`가 아니라 일반 Wave Clear 이후 `run_state`가 READY로 복귀하지 않는 것이다.

## 7. `wave_clear`의 실제 역할

판정: `CONFIRMED / ACCEPT`

현재 `main.gd`에서 확인된 대입은 다음과 같다.

```text
선언: false
reset_game(): false
start_wave(): false
check_wave_clear(): true
```

현재 코드에서 `wave_clear`는 정상적인 Wave 종료를 기록하는 상태 플래그로 사용된다. 다만 실제 Wave 진행 제어는 `run_state`와 `wave_running` 조건이 담당하며, `wave_clear` 자체는 일반적인 상태 전이 제어를 막는 근본 원인은 아니다.

즉 현재 코드 기준으로 `wave_clear`는 다음 상태다.

- 정상 Wave 종료를 기록하는 값
- `run_state`와 함께 상태 전이의 결과를 나타냄
- 다음 Wave 시작 시 새 cycle에서 다시 `false`로 리셋됨
- 게임 진행 제어의 직접적인 gate는 아니며, `run_state`과 `wave_running`이 이를 담당함

## 8. 상태 전이 요약 (현재 코드 기준)

### 과거 결함 1: 일반 Wave Clear 후 READY 복귀 누락

상태: `HISTORICAL / FIXED`

```text
기존 서술:
RUNNING
    -> Wave Clear
    -> wave_running = false
    -> wave_clear = true
    -> wave += 1
    -> run_state는 RUNNING 유지
    -> start_wave()의 READY guard
    -> 다음 Wave 시작 차단
```

현재 코드에서는 위 경로가 수정되었다. 정상 Wave Clear는 다음처럼 동작한다.

```text
RUNNING
    -> Wave Clear
    -> wave_running = false
    -> wave_clear = true
    -> run_state = READY
    -> wave += 1
    -> 다음 Wave 시작 허용
```

### 과거 결함 2: DEFEAT 우선순위와 동일 프레임 후속 처리

상태: `HISTORICAL / FIXED`

```text
기존 서술:
move_enemies()
    -> DEFEAT 설정
    -> move_enemies() return
    -> update_towers()
    -> update_robot()
    -> check_wave_clear()
    -> VICTORY overwrite 가능
```

현재 코드에서는 `check_wave_clear()`에 다음 guard가 추가되어 위 경로를 차단한다.

```text
if run_state == RunState.DEFEAT or run_state == RunState.VICTORY or not wave_running:
    return
```

즉, Base Reach → DEFEAT 상태가 이미 결정되면 최종 Wave의 `VICTORY` 덮어쓰기가 수행되지 않는다.

## 9. 검증 요약표

| 항목 | 판정 |
| --- | --- |
| Enemy Armor | `CONFIRMED / ACCEPT` |
| Enemy Reward | `CONFIRMED / ACCEPT` |
| Gold -> Tower Cost | `CONFIRMED / ACCEPT` |
| Tower Slot Occupancy | `CONFIRMED / ACCEPT` |
| Tower Cooldown | `CONFIRMED / ACCEPT` |
| Tower Target Preference | `CONFIRMED / ACCEPT` |
| Robot Cooldown | `CONFIRMED / ACCEPT` |
| Robot Range | `CONFIRMED / ACCEPT` |
| Robot Area | `CONFIRMED / ACCEPT` |
| Robot General/Pierce | `CONFIRMED / ACCEPT` |
| Robot State Guard | `CONFIRMED` / 사망 경로 `UNVERIFIED` |
| Normal Wave Transition | `CONFIRMED / FIXED` |
| DEFEAT Same-frame Flow | `CONFIRMED / FIXED` |
| DEFEAT -> VICTORY Path | `CONFIRMED / BLOCKED_BY_GUARD` |
| `wave_clear` Role | `CONFIRMED / ACCEPT` |

## 10. 작업 제한과 미수행 항목

이번 문서화 작업에서는 다음을 수행하지 않았다.

- 코드 수정
- Blueprint 수정
- Asset 수정
- Runtime/PIE 실행
- 밸런스 조정
- DPS 평가
- Robot 사망 시스템 구현
- Wave 진행 결함 수정
- Victory/Defeat 로직 수정
- `wave_clear` 활용 로직 추가
- Git commit 또는 push

이 문서는 MENOS의 현재 전투, 경제, 상태 전이에 대한 검증 기준선이다. 문서화 완료 후 추가 구현이나 수정 작업으로 자동 확장하지 않는다.