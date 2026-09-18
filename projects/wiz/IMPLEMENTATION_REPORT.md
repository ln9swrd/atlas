# Godot TD PoC Implementation Report

## STATUS

PASS

정적 코드·씬·리소스 조사는 완료했다. Godot 실행 파일을 확인하지 못해 실제 PIE/runtime은 검증하지 않았다.

## 1. 프로젝트 기준선

- Godot version: Godot 4.7 계열로 프로젝트 설정에 기록됨 (`config/features=PackedStringArray("4.7", "GL Compatibility")`). 설계 문서에는 4.7.2로 기재되어 있으나 실행 파일로 확인하지 못함.
- Project: `fancytd`
- Main Scene: `res://fancytd/scenes/main.tscn`
- 조사 기준 시점: 2026-09-18
- 주요 구조:
  - `fancytd/scenes`: main, tower, enemy, projectile, admin settings scenes
  - `fancytd/scripts/core`: `GameManager`
  - `fancytd/scripts/enemy`: `Enemy`, `EnemySpawner`, `EnemyData`
  - `fancytd/scripts/tower`: `Tower`, `TowerData`
  - `fancytd/scripts/combat`: `Projectile`
  - `fancytd/scripts/wave`: `WaveData`
  - `fancytd/scripts/settings`: `GameSettings`
  - `fancytd/scripts/ui`: purchase button and admin settings panel
  - `fancytd/data`: `game_settings.tres`
- 주요 사용 시스템: `GameManager` autoload, `EnemySpawner` 기반 메인 컨트롤러, Resource 기반 Tower/Enemy/Wave/GameSettings 데이터, `Timer` 기반 스폰·공격, `Line2D` 경로

## 2. 실제 구현 현황

| 기능 | 상태 | 근거 |
|---|---|---|
| 적 스폰 | IMPLEMENTED | `EnemySpawner`가 `EnemyData`/`WaveData` 엔트리를 읽고 `Enemy` 씬을 인스턴스화한다. 현재 `default` ID만 등록되어 있다. |
| 웨이브 시스템 | PARTIAL | 엔트리별 스폰 수·간격·완료 판정과 다음 웨이브 API는 있으나 현재 설정된 웨이브는 1개이고 다음 웨이브 UI/자동 진행은 없다. |
| 적 이동 | IMPLEMENTED | `Enemy`가 경로 점을 따라 `move_toward`로 이동한다. |
| 경로(Path) | IMPLEMENTED | `main.tscn`의 `Map/Path` `Line2D`와 Spawn/Goal 마커가 연결되어 있다. |
| 적 HP | IMPLEMENTED | `Enemy.current_hp`, `max_hp`, `apply_damage`가 존재한다. |
| 적 사망 | IMPLEMENTED | HP 0에서 `_die()`가 호출되고 적이 제거되며 보상이 지급된다. |
| 기지/목표 HP | PARTIAL | 별도 기지 HP 노드는 없고, 목표 도달 시 `GameManager.life`를 1 감소시키는 생명 수치로 처리된다. |
| 게임 오버 | IMPLEMENTED | life가 0 이하가 되면 `GAME_OVER` 상태가 되고 `GameOverLabel`이 표시된다. |
| 타워 설치 | IMPLEMENTED | 구매 버튼 후 맵 클릭으로 `Towers` 컨테이너에 타워를 생성한다. 우클릭/Escape 취소도 코드상 존재한다. |
| 타워 종류 | PARTIAL | `TowerData` 배열 및 ID 구조는 있으나 현재 등록·플레이 가능한 타워는 1종이다. |
| 타워 공격 | IMPLEMENTED | 공격 타이머가 범위 내 적을 찾고 투사체를 생성한다. |
| 공격 범위 | IMPLEMENTED | 타워와 적의 거리와 `TowerData.range`를 비교한다. |
| 타겟 선택 | IMPLEMENTED | 경로의 `next_point_index`가 가장 큰 적을 선택한다. |
| 공격 쿨다운 | IMPLEMENTED | `AttackTimer`와 `TowerData.attack_interval`을 사용한다. |
| 데미지 | IMPLEMENTED | 투사체가 목표의 `apply_damage`를 호출한다. |
| 투사체 | IMPLEMENTED | `projectile.tscn`과 추적·충돌 거리·피해 처리가 있다. |
| 범위 공격 | NOT IMPLEMENTED | 단일 타겟 투사체만 확인된다. |
| 적 방어/저항 | NOT IMPLEMENTED | 방어력·저항 데이터 및 계산을 확인하지 못했다. |
| 골드/자원 | IMPLEMENTED | `GameManager.gold`, 초기 골드, 처치 보상, 구매 차감이 있다. |
| 타워 구매 | IMPLEMENTED | 비용 확인 후 골드를 차감하고 타워를 생성한다. |
| 타워 업그레이드 | NOT IMPLEMENTED | 업그레이드 데이터·처리·UI를 확인하지 못했다. |
| 판매 | NOT IMPLEMENTED | 판매 데이터·처리·UI를 확인하지 못했다. |
| 웨이브 보상 | NOT IMPLEMENTED | 웨이브 완료 자체의 별도 보상은 없고 적 처치 보상만 있다. |
| 승리 조건 | IMPLEMENTED | 모든 엔트리 스폰 및 살아 있는 적 소멸 후 `VICTORY` 상태가 된다. 현재 1개 웨이브 완료가 승리 조건이다. |
| 패배 조건 | IMPLEMENTED | 목표 도달로 life가 0이 되면 `GAME_OVER`가 된다. |
| 일시정지 | NOT IMPLEMENTED | 일시정지 입력·UI·처리를 확인하지 못했다. |
| 배속 | NOT IMPLEMENTED | 배속 입력 또는 시간 배율 처리를 확인하지 못했다. |
| UI | PARTIAL | 골드/생명 HUD, 구매 버튼, 구매 상태, GAME OVER/VICTORY 라벨, 관리자 설정 패널이 있다. 웨이브 선택·업그레이드·판매 UI는 없다. |
| 사운드 | NOT IMPLEMENTED | 오디오 씬, 오디오 리소스, 재생 코드를 확인하지 못했다. |
| 이펙트 | NOT IMPLEMENTED | Polygon2D 기반 정적 표시와 투사체 이동은 있으나 피격·사망·설치 등의 별도 이펙트는 확인하지 못했다. |

## 3. 현재 플레이 루프

코드와 씬에서 확인되는 흐름은 다음과 같다.

`메인 씬 진입 → GameManager가 초기 Gold/Life 설정 → 기존 타워 1개와 맵/경로 준비 → wave 1의 default 적 60마리 스폰 → 적이 Line2D 경로 이동 → 타워가 범위 내 가장 앞선 적을 타겟팅 → 투사체 생성 및 데미지 → 적 사망 시 Gold +10 → 모든 적 처리 시 VICTORY`

적이 경로 끝에 도달하면 `Life -1`이 되며, Life가 0이 되면 `GAME_OVER`가 된다. 구매 버튼을 누른 뒤 맵을 클릭하면 추가 타워를 설치할 수 있다. 현재 다음 웨이브로 이어지는 실제 UI/자동 흐름은 확인되지 않았다.

## 4. 콘텐츠 현황

| 콘텐츠 | 수량 | 상태 |
|---|---:|---|
| Tower | 1 | `Basic Tower`; `TowerData` 1개 |
| Enemy | 1 | `Basic Enemy`; `EnemyData` 1개, ID `default` |
| Map/Stage | 1 | `main.tscn`의 단일 맵과 단일 경로 |
| Wave | 1 | `wave_number=1`, `spawn_count=60`, `spawn_interval=0.25` |
| Upgrade | 0 | 업그레이드 데이터/씬/처리 없음 |
| Boss | 0 | 보스 데이터/씬/등록 없음 |
| Special Enemy | 0 | 현재 특수 적 데이터/씬/등록 없음 |
| 기타 플레이 가능 콘텐츠 | 1세트 | 단일 맵 전투, 타워 구매/배치, 처치 보상, 관리자 설정 패널 |

`main.tscn` 내부에도 wave 엔트리(`spawn_count=30`)와 타워/적 리소스가 있으나, 런타임 `_ready()`에서 연결된 `GameSettings`의 첫 번째 wave/tower/enemy로 덮어쓴다. 따라서 현재 설정 리소스 기준 유효한 웨이브 수량은 60마리다.

## 5. 확장 구조

- 재플레이 구조: 현재는 1개 웨이브를 완료하거나 패배하는 단일 런이다. 무한 웨이브, 랜덤화, 기록, 메타 진행은 확인되지 않았다.
- 성장 구조: 전투 중 골드와 타워 설치는 있으나 영구 성장, 업그레이드, 해금 구조는 없다.
- 빌드 다양성: 여러 `TowerData`를 담을 수 있는 배열 구조는 있으나 현재 타워 1종과 단일 공격 방식만 제공한다.
- 콘텐츠 확장 방식: `TowerData`, `EnemyData`, `WaveData`, `GameSettings` Resource와 ID/Dictionary 기반으로 기본 파라미터를 추가할 수 있는 형태다. 다만 `EnemySpawner.ENEMY_SCENES` 등록과 씬 연결은 새 적 종류마다 코드/씬 수정이 필요하다.
- 예상되는 반복 제작 요소: 새 타워는 데이터 추가 외에 씬/투사체/행동 차이가 필요할 수 있고, 새 적은 `ENEMY_SCENES` 등록과 데이터 연결이 필요하다. 새 맵은 main 씬의 Ground/Path/Spawn/Goal 및 배치/UI 연결을 반복 수정해야 한다. 이는 구조 관찰이며 리팩터링 제안이 아니다.

## 6. 미구현 기능

- 다중 웨이브의 실제 진행 및 웨이브 시작/다음 웨이브 UI
- 범위 공격
- 적 방어/저항
- 타워 업그레이드
- 타워 판매
- 웨이브 완료 보상
- 일시정지
- 배속
- 사운드
- 전투/설치/사망 이펙트
- 보스 및 특수 적
- 영구 성장 및 장기 메타 진행

## 7. 오류 / 문제

- 조사 환경에서 `godot`, `godot4` 명령 및 일반적인 Windows 설치 경로의 Godot 실행 파일을 찾지 못했다. 따라서 실행 오류 자체는 확인하지 못했다.
- 실제 PIE 실행, 메인 씬 진입, 입력 동작, 장시간 웨이브 완료는 확인하지 못했다.
- 코드/씬 정적 조사만으로는 보고되지 않은 런타임 오류를 배제할 수 없다.

위 항목은 확인된 검증 한계이며, 새 오류를 추측해 기록한 것이 아니다.

## 8. 검증 상태

- CODE: VERIFIED (스크립트, 씬, Resource, project.godot 정적 확인)
- BUILD: NOT VERIFIED (Godot 실행 파일 부재로 프로젝트 import/build 명령 미실행)
- EDITOR: NOT VERIFIED (Godot Editor 직접 확인 미실행)
- PIE: NOT VERIFIED (실제 Runtime/Play 실행 미실행)

## 9. 핵심 결론

현재 PoC는 Godot 4.7 계열의 2D 단일 맵 TD 골격을 갖고 있다.
적 스폰, 경로 이동, HP/사망, 타워 공격, 범위 판정, 타겟 선택, 쿨다운, 투사체, 데미지, 골드, 구매/배치, Life, 승리/패배 상태가 코드로 연결되어 있다.
플레이 콘텐츠는 기본 타워 1종, 기본 적 1종, 웨이브 1개, 맵 1개다.
현재의 반복 플레이와 장기 성장 구조는 사실상 없다.
타워 업그레이드/판매, 범위 공격, 적 저항, 일시정지/배속, 사운드/이펙트는 구현되지 않았다.
Resource 기반 데이터 구조는 일부 확장을 지원하지만, 새 적과 맵은 코드·씬 연결 작업을 함께 요구한다.
상업성이나 지속 매출 가능성에 대한 판단은 이번 조사 범위에서 수행하지 않았다.
실제 실행 가능 범위는 Godot/PIE 검증 후 확정해야 한다.

## 10. OUT OF SCOPE

이번 조사에서는 다음을 수행하지 않았다.

- 코드 수정
- 리팩터링
- 게임 밸런스 수정
- 신규 기능 구현
- 신규 에셋 제작
- 게임 디자인 변경
- 수익화 시스템 구현
- DLC 구현
- 마케팅 작업
- Git commit/push

기존 작업 트리의 사용자 변경사항은 보존했으며, 본 보고서 파일만 추가했다.