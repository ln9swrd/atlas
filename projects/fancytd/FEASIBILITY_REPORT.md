# TD Commercial Prototype Feasibility Report

## STATUS

PASS

이번 문서는 구현 타당성 조사만 수행한 결과다. 코드, 씬, Resource, 에셋, 프로젝트 구조는 수정하지 않았다.

## 목적

현재 `fancytd` PoC를 버리지 않고, 다음 가설을 최소 구현으로 검증할 수 있는지 조사한다.

`TD + 로그라이크 선택 + 타워 시너지`

검증 대상은 웨이브 사이의 보상 선택이 빌드를 변화시키고, 서로 다른 타워 조합이 실제 전투 전략의 차이를 만드는 반복 플레이가 성립하는지다.

## 기준선

- HEAD: `ccc7cdf6f4de37b4a3aefc1b069f34364abdb47c`
- Branch: `main`
- Working Tree: 기존 변경사항 있음. `game_settings.tres`, `main.tscn`, `projectile.gd`, `enemy.gd`, `enemy_spawner.gd`, `admin_settings_panel.gd` 및 관리자 패널 씬 변경이 선행되어 있다. 본 조사에서는 보존했다.
- Project: `fancytd`
- Godot: `project.godot`에 Godot 4.7 계열(`config/features`의 `4.7`)로 기록됨. 실행 파일과 Editor는 확인하지 못했다.
- Main Scene: `res://fancytd/scenes/main.tscn`
- 주요 씬: `main.tscn`, `tower.tscn`, `enemy.tscn`, `projectile.tscn`, `admin_settings_panel.tscn`
- 주요 스크립트: `GameManager`, `EnemySpawner`, `Enemy`, `EnemyData`, `Tower`, `TowerData`, `Projectile`, `WaveData`, `GameSettings`
- 외부 플러그인: `addons/godot-mcp`가 Editor plugin으로 활성화되어 있다. 게임 규칙을 제공하는 외부 런타임 라이브러리는 확인되지 않았다.
- 외부 에셋: 이미지·오디오·폰트 등 외부 미디어 파일은 확인되지 않았고, 현재 시각 요소는 `Polygon2D`와 기본 UI 노드 중심이다.
- Runtime/PIE: 이번 조사에서 실행하지 않았으므로 `NOT VERIFIED`

## 현재 구조 분석

### 재사용 가능한 부분

- `TowerData` 배열은 3종 타워를 보관할 수 있다. 비용, 공격력, 사거리, 공격 간격은 이미 데이터화되어 있다.
- `EnemyData` 배열과 `enemy_data_by_id`는 Basic/Fast/Heavy/Boss 데이터를 식별자로 보관할 수 있다.
- `WaveData.entries`는 `enemy_id`, `spawn_count`, `spawn_interval` Dictionary를 사용하므로 웨이브별 적 조합과 수량을 표현할 수 있다.
- `GameSettings.waves`는 여러 `WaveData`를 담을 수 있어 5~8개 웨이브 목록을 저장할 수 있다.
- 기존 `Enemy` 씬은 `EnemyData`의 HP와 속도를 적용하므로 Basic/Fast/Heavy의 기본 차이는 같은 씬 재사용으로 가능하다.
- 기존 `Tower` 씬은 데이터 기반 공격 타이머와 타겟 선택을 제공하므로 Fire/Ice/Lightning도 같은 기본 씬에서 시작할 수 있다.
- 기존 `GameManager`는 Gold/Life와 타워 구매를 소유하므로 런 초기화와 전투 중 자원 흐름의 기반으로 재사용할 수 있다.

### 현재 구조의 직접적인 제약

- `EnemySpawner`가 현재 메인 컨트롤러로서 첫 번째 wave만 시작하고, 스폰·완료·승리 표시·타워 배치까지 함께 관리한다. 다중 웨이브와 보상 선택을 넣으려면 wave 인덱스와 선택 대기 상태를 추가해야 한다.
- `ENEMY_SCENES`는 현재 `default` 하나만 등록되어 있다. 새 EnemyData만 추가해도 새 ID가 자동으로 스폰되지는 않는다.
- `Tower`는 현재 모든 타워에 동일한 단일 투사체 행동을 사용한다. Ice 감속과 Lightning 연쇄는 Tower/Projectile 쪽의 행동 분기가 필요하다.
- `EnemyData.armor`와 `movement_type` 필드는 존재하지만 현재 피해 계산과 이동 행동에 실제로 사용되지 않는다. Heavy의 피해 감소는 별도 계산 연결이 필요하다.
- `TowerData.projectile` 필드는 존재하지만 실제 투사체 종류 선택에는 연결되지 않는다.
- 관리자 설정 패널은 첫 번째 타워·적·웨이브만 편집한다. Prototype 데이터는 Resource 파일에 직접 작성하거나 별도 Prototype UI를 추가해야 한다.
- 현재 main 씬에는 씬 내부 wave/tower/enemy subresource와 `GameSettings`가 함께 있으며, `EnemySpawner._ready()`에서 설정 Resource의 첫 원소로 덮어쓴다. Prototype의 기준 데이터는 `GameSettings`로 단일화해야 한다.
- 현재 `GameManager`에는 새 Run 초기화, 현재 빌드, 선택한 타워 목록, 시너지 상태가 없다.

## 기능별 구현 타당성

| 기능 | 재사용 | 변경 필요 | 난이도 | 비고 |
|---|---|---|---|---|
| 3종 Tower 데이터 | `TowerData`, `GameSettings.towers`, `tower.tscn` | 타워 행동 식별 필드와 3개 Resource 인스턴스 | LOW | Fire/Ice/Lightning의 기본 수치와 ID는 데이터화 가능하다. |
| Fire 타워 | `Tower`, `Projectile` | 단일 고화력 수치와 표시 식별 | LOW | 기존 단일 타겟 공격을 그대로 사용할 수 있다. |
| Ice 타워 | `TowerData`, `Tower`, `Enemy` | 적 감속 상태와 지속시간, 공격 시 효과 적용 | MEDIUM | `speed`를 일시 변경하거나 상태 효과를 별도로 관리해야 한다. |
| Lightning 타워 | `Tower`, `Projectile`, `Enemy` | 2차 타겟 탐색, 연쇄 횟수/피해 감소, 중복 타격 방지 | MEDIUM | 단일 투사체 코드만으로는 부족하지만 기존 적 컨테이너를 재사용할 수 있다. |
| 3종 Enemy 데이터 | `EnemyData`, `GameSettings.enemies`, `enemy.tscn` | ID별 씬 등록 또는 공통 씬 매핑 | LOW | Fast는 speed, Heavy는 HP로 최소 검증 가능하다. |
| Heavy 피해 감소 | 기존 `EnemyData.armor` | `Enemy.apply_damage()`에서 armor 적용 | LOW | 필드는 이미 있으나 현재 계산되지 않는다. |
| Boss 1종 | `EnemyData`, `Enemy` | boss 식별/최종 웨이브 배치, 최소 특수 능력 | LOW-MEDIUM | 복잡한 AI 없이 높은 HP, armor, 이동 속도 또는 단순 주기 능력으로 검증 가능하다. |
| 5~8 Wave | `WaveData`, `GameSettings.waves` | 현재 wave 인덱스, 순차 시작, 완료 후 선택 대기 | LOW-MEDIUM | 데이터 저장은 가능하나 현재 자동 진행은 구현되어 있지 않다. |
| 웨이브 적 조합 | `WaveData.entries`, `enemy_data_by_id` | ID 등록과 invalid entry 처리 | LOW | Dictionary 구조를 그대로 재사용할 수 있다. |
| 보상 3개 제시 | 일부 `GameSettings` 재사용 | Reward 데이터, 선택 상태, 3버튼 UI, 적용 로직 | MEDIUM | 보상은 기존 Tower/Stat Resource를 직접 변형할지 런 전용 modifier로 둘지 결정해야 한다. |
| 신규 타워 보상 | `TowerData`, 구매 시스템 | 보상으로 tower pool 해금/추가 | MEDIUM | 현재 구매 버튼은 단일 `purchase_tower_data`만 사용한다. |
| 공격력 강화 보상 | `TowerData`, `GameManager` | 런 modifier와 적용 시점 | MEDIUM | Resource 원본을 영구 변경하지 않는 런 상태가 필요하다. |
| 특정 타워 강화 | `TowerData`, `Tower` | 타워 ID별 modifier 적용 | MEDIUM | Fire/Ice/Lightning별 보너스 판정이 필요하다. |
| 시너지 2~3개 | 타워 ID와 적 컨테이너 재사용 | `Synergy` 판정/상태/효과 처리 | MEDIUM | `Fire+Ice`, `Ice+Lightning` 같은 조합은 별도 관계 데이터 또는 코드 규칙이 필요하다. |
| 시너지 표시 | 기존 UI CanvasLayer | 시너지 상태 Label/간단 패널 | LOW | 전략 차이를 검증하려면 활성 시너지와 효과를 표시해야 한다. |
| Victory/Game Over | `GameManager`, 기존 라벨 | 최종 보스 완료와 새 Run 초기화 연결 | LOW-MEDIUM | 현재 단일 wave 완료를 Victory로 만드는 흐름을 최종 wave 기준으로 바꿔야 한다. |
| 새 Run | `GameManager` 일부 | 골드/Life/wave/build 초기화와 재시작 UI | MEDIUM | 현재 `set_settings()`는 초기 자원만 설정하고 런 상태를 초기화하지 않는다. |

### 최소 Prototype에서의 구현 선택

가장 작은 검증안은 다음과 같다.

- 타워는 별도 씬 3개가 아니라 기존 `tower.tscn` 하나와 `TowerData.id`/행동 타입을 사용한다.
- 적은 별도 씬 4개가 아니라 기존 `enemy.tscn` 하나와 `EnemyData` 수치/타입을 사용한다. Boss는 마지막 wave의 `boss` 데이터로 표현한다.
- Wave는 `GameSettings.waves`에 5~8개의 `WaveData`를 넣고, 각 entry의 `enemy_id`와 수량을 다르게 한다.
- Reward는 3개 선택지를 매 wave 완료 때 생성하고, 선택 결과를 현재 Run의 modifier/해금 목록에만 적용한다.
- Synergy는 우선 두 조합만 고정 규칙으로 판정한다. 예를 들어 Fire와 Ice가 하나 이상 활성화되어 있으면 Thermal Shock, Ice와 Lightning이 하나 이상 활성화되어 있으면 Conductive를 활성화한다.
- 시너지 효과는 복잡한 조합 탐색 대신 피해 보정, 감속 강화, 연쇄 추가 타격 중 1개씩만 사용한다.
- 보상 UI는 기존 CanvasLayer에 3개 Button과 설명 Label을 추가하는 정도로 제한한다.

## 필요한 신규 시스템

### 1. Run State / Wave Flow

필요한 상태는 최소한 `current_wave_index`, `unlocked_tower_ids`, `run_modifiers`, `active_synergy_ids`, `awaiting_reward_choice`다.

현재 `EnemySpawner`에 모두 넣을 수도 있지만, 타당성 관점에서는 `RunController` 또는 `RunState`를 별도 스크립트로 두고 `EnemySpawner`는 한 wave의 스폰/완료만 담당하는 구성이 더 현실적이다. 이는 대규모 리팩터링이 아니라 Prototype용으로 상태와 진행을 분리하는 최소 신규 경계다.

### 2. Reward Choice

최소 구조는 `RewardData` Resource 또는 Dictionary 3개다. 추천 필드는 `id`, `title`, `description`, `reward_type`, `target_tower_id`, `value`다.

다만 보상 선택이 반복 플레이의 핵심이므로 Dictionary를 여러 곳에서 직접 해석하기보다 작은 `RewardData` Resource가 더 안전하다. 보상 풀에서 3개를 선택하고, 선택 후 Run State modifier 또는 해금 목록에 적용하면 된다.

### 3. Tower Behavior / Status Effect

Fire는 기존 공격 경로를 재사용할 수 있다. Ice와 Lightning은 행동 차이가 있으므로 `Tower` 또는 별도 전투 행동 스크립트에 최소 분기가 필요하다.

- Ice: 적에 `slow_multiplier`, `slow_remaining` 같은 런타임 상태를 적용한다.
- Lightning: 현재 타겟 주변에서 추가 적을 찾아 순차적으로 피해를 적용한다.
- Heavy/Boss: `Enemy.apply_damage()`에서 armor 또는 damage reduction을 반영한다.

### 4. Synergy Resolver

활성 타워 ID 또는 해금 타워 ID를 읽고 고정된 2~3개 조합을 판정하는 시스템이 필요하다. 조합이 실제 전략 차이를 만들려면 “조합 보유 여부”만 표시하지 말고, 실제 공격·감속·연쇄 계산에서 효과를 읽어야 한다.

### 5. Reward UI

기존 UI를 전면 개편할 필요는 없다. wave 완료 시 게임 입력을 보상 선택 상태로 제한하고, 세 개의 버튼을 표시한 뒤 하나를 적용하고 다음 wave를 시작하는 작은 패널이면 된다.

## 데이터 기반 확장성

### Resource 추가만으로 가능한 부분

- Tower의 비용, 피해, 사거리, 공격 간격, 표시 이름, 기본 ID
- Enemy의 ID, HP, 속도, 보상, 기본 armor
- Wave의 번호, enemy ID, 수량, 스폰 간격
- GameSettings의 tower/enemy/wave 목록

단, 현재 코드에는 신규 ID를 자동으로 씬·행동에 연결하는 등록 계층이 없으므로 “Resource만 추가하면 즉시 실행”되는 상태는 아니다.

### 코드 수정이 필요한 부분

- Ice 감속, Lightning 연쇄, Boss 특수 능력
- 신규 타워 행동 타입과 투사체 행동
- Heavy armor 계산과 상태 효과 처리
- 다중 wave 진행과 보상 선택 대기
- Reward 적용과 Run modifier
- 타워 조합 판정과 시너지 효과
- 새 Run 초기화와 최종 Boss/Victory 연결
- 보상 선택 UI와 시너지 표시

## 예상 변경 파일

아래는 실제 구현을 시작할 경우의 예상 범위다. 이번 조사에서 수정하지 않았다.

### 기존 파일 수정 예상

- `fancytd/scripts/tower/tower_data.gd`: 행동 타입 또는 최소 특수 능력 파라미터
- `fancytd/scripts/tower/tower.gd`: Ice/Lightning 행동과 Run modifier 적용
- `fancytd/scripts/combat/projectile.gd`: 필요 시 연쇄 또는 효과 전달
- `fancytd/scripts/enemy/enemy_data.gd`: Boss/특수 타입 필드가 필요할 때만 추가. `armor`는 이미 존재한다.
- `fancytd/scripts/enemy/enemy.gd`: 감속 상태, armor 피해 계산, Boss 상태
- `fancytd/scripts/enemy/enemy_spawner.gd`: wave 단위 완료 신호와 ID 기반 스폰 연결
- `fancytd/scripts/wave/wave_data.gd`: 현재 구조로 충분할 가능성이 높으며, Boss 플래그가 entry로 표현되지 않을 때만 수정
- `fancytd/scripts/settings/game_settings.gd`: 보상 풀을 설정 Resource로 둘 경우 배열 추가
- `fancytd/scripts/core/game_manager.gd`: Run State 또는 새 Run API를 이곳에 둘 경우 수정
- `fancytd/scenes/main.tscn`: 3종 데이터, 5~8개 wave, 최종 Boss, reward UI 연결
- `fancytd/data/game_settings.tres`: 실제 Prototype 데이터 인스턴스 추가

### 신규 파일 예상

- `fancytd/scripts/run/run_state.gd` 또는 `fancytd/scripts/core/run_controller.gd`
- `fancytd/scripts/reward/reward_data.gd`
- `fancytd/scripts/reward/reward_manager.gd`가 필요할 수 있으나, 최소안에서는 Run Controller에 통합 가능
- `fancytd/scripts/synergy/synergy_resolver.gd` 또는 Run Controller 내부의 소형 resolver
- `fancytd/scenes/ui/reward_choice_panel.tscn`
- `fancytd/scripts/ui/reward_choice_panel.gd`

### 신규 씬/에셋이 필수는 아닌 부분

3종 타워와 3종 적은 최소 검증 목적이라면 기존 공통 씬을 재사용할 수 있다. 그래픽 교체, 애니메이션, 사운드, 이펙트는 가설 검증에 필요하지 않다.

## 위험 요소

- 현재 wave 완료 시 곧바로 `VICTORY` 상태가 되는 흐름이 있으므로, 다중 wave에서는 최종 wave인지 판단하는 진행 상태가 반드시 필요하다.
- 현재 `EnemySpawner`의 `ENEMY_SCENES` 등록이 `default` 하나뿐이어서 EnemyData 추가만으로 Fast/Heavy/Boss가 스폰되지 않는다.
- 현재 `GameManager`의 Gold/Life는 전역 값이지만 타워 해금·modifier·시너지 상태는 없다. Resource 원본을 직접 변경하면 새 Run과 영구 데이터가 섞일 위험이 있다.
- 관리자 패널의 첫 번째 Resource만 편집하는 구조는 다중 타워/적/웨이브 Prototype의 운영 데이터 편집기로 사용할 수 없다.
- Lightning 연쇄와 Ice 감속은 현재 단일 타겟·단순 HP 차감 모델을 넘어서는 전투 상태를 요구한다.
- `EnemyData.armor`가 선언되어 있어도 현재 피해 계산에 사용되지 않으므로 Heavy를 정의하는 것만으로 피해 감소가 생기지 않는다.
- 현재 정적 조사만 수행했고 Godot Editor/PIE를 실행하지 않았으므로, 실제 연결 오류나 입력·UI 동작은 확인되지 않았다.

위 항목은 코드에서 확인된 구조적 위험이며, 성능·밸런스·시장성에 대한 추측은 포함하지 않았다.

## 구현 범위

가설 검증에 필요한 최소 범위는 다음과 같다.

1. 한 맵과 기존 경로 유지
2. Fire/Ice/Lightning 3종을 공통 Tower 씬으로 구현
3. Basic/Fast/Heavy 3종과 Boss 1종을 공통 Enemy 씬으로 구현
4. 5~8개 wave를 Resource로 정의하고 순차 진행
5. 각 wave 완료 후 Reward 3개 중 하나 선택
6. 보상으로 타워 해금 또는 타워/공격력 modifier 적용
7. Fire+Ice, Ice+Lightning 중 최소 2개 시너지의 실제 전투 효과
8. 마지막 wave Boss와 Victory/Game Over
9. 현재 빌드와 활성 시너지를 확인할 수 있는 최소 텍스트 UI
10. 새 Run에서 Gold, Life, wave, 해금, modifier, synergy 초기화

이 범위면 콘텐츠 양을 크게 늘리지 않고도 “선택이 빌드를 바꾸는가”, “타워 조합이 전략 차이를 만드는가”, “다음 wave에서도 그 차이가 유지되는가”를 관찰할 수 있다.

## OUT OF SCOPE

- 대규모 리팩터링
- 파일 이동 및 이름 변경
- 기존 시스템 삭제
- 기존 Asset 교체
- 프로젝트 구조 전면 변경
- UI 전면 개편
- 그래픽 개선
- 사운드 및 이펙트 제작
- 메타 성장 구현
- 상점, DLC, 광고, 인앱결제, Steam 기능
- 외부 Asset 다운로드
- 밸런스 최적화
- 시장성 또는 수익성 판단
- Git commit/push

## 최종 판정

### TECHNICALLY POSSIBLE

가능하다. 현재 Resource 배열과 공통 Tower/Enemy 씬을 재사용해 3종 타워, 3종 적, 5~8개 wave의 데이터 기반 골격을 만들 수 있다.

### PRACTICALLY FEASIBLE

가능하다. 최소 구현의 핵심 작업은 새 콘텐츠 제작보다 wave 진행 상태, Reward 선택, Run modifier, 시너지 판정, Ice/Lightning/Boss의 제한된 행동을 추가하는 것이다. 예상 난이도는 전체적으로 MEDIUM이며, Lightning 연쇄와 선택 상태 연결이 가장 큰 작업 단위다.

### CHANGE METHOD

현재 프로젝트를 폐기하거나 다른 엔진/구조로 전환할 필요는 없다. 다만 `EnemySpawner`에 모든 새 기능을 계속 누적하는 방식은 적절하지 않다. 최소한 Run State/Controller, Reward Data/Panel, Synergy Resolver를 작은 신규 경계로 추가하는 방식이 현실적이다. 이는 전면 리팩터링이 아니라 Prototype 진행 상태를 분리하기 위한 국소적 확장이다.

### HOLD

구현 자체를 막는 코드 구조상의 BLOCKER는 확인되지 않았다. 단, 실제 구현 착수 전 다음 두 가지는 결정되어야 한다.

- 보상으로 얻은 공격력 강화가 해당 Run에만 적용되는지, Resource 원본에 저장되는지. 최소 Prototype은 Run 전용 적용이 필요하다.
- “신규 타워” 보상이 타워를 즉시 배치하는지, 구매 가능한 타워 풀에 해금하는지. 최소 Prototype은 구매 풀 해금이 기존 Gold/배치 흐름과 충돌이 적다.

## 조사 결론

최종 권고는 **CONTINUE**다. 현재 `fancytd` PoC는 폐기 대상이 아니며, 한 맵·공통 씬·Resource 데이터 구조를 유지한 채 소규모 런 상태와 선택/시너지 계층을 추가하면 목표 Prototype을 검증할 수 있다. 이번 단계에서는 타당성 확인만 완료했으며, 별도 승인 없이 구현으로 넘어가지 않는다.