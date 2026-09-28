# MENOS 화면 및 기능 구조 설계

> 상태: PROPOSAL
> 목적: MENOS의 플레이어 화면, 개발용 에디터 화면, 게임 시스템의 책임을 분리하기 위한 상위 설계 문서.
> 주의: 본 문서는 구현 지시가 아니며, Master 승인 전까지 Canon으로 취급하지 않는다.

## 1. 기본 방향

MENOS는 슈퍼로봇의 전투 액션을 게임으로 구현한다.

따라서 게임의 중심은 전투이지만, 전투를 구성하기 위한 스테이지 데이터와 맵 제작 도구가 필요하다.

핵심 원칙:

**Stage는 무엇을 할지 정의하고, System은 그것을 어떻게 실행할지 담당한다.**

또한 화면(Screen)과 시스템(System)을 구분한다.

- Screen: 사용자가 특정 작업을 수행하는 독립적인 화면/작업 공간
- System: 화면과 무관하게 게임 규칙과 동작을 실행하는 기능
- Data: Screen 또는 System이 사용하는 콘텐츠 정의

## 2. 전체 구조

```
MENOS
├─ Player Game
│  ├─ Title
│  ├─ Stage Select
│  ├─ Stage Briefing
│  ├─ Robot / Loadout
│  ├─ Combat
│  └─ Result
│
├─ Development Tools
│  └─ Content Editor
│     ├─ Map Editor
│     └─ Stage Editor
│
└─ Game Systems
   ├─ Stage
   ├─ Map
   ├─ Robot
   ├─ Enemy
   ├─ Spawn
   ├─ Wave
   ├─ Tower
   └─ Combat
```
## 3. 플레이어용 화면

### 3.1 Title

게임 시작 및 주요 메뉴 진입점.

### 3.2 Stage Select

플레이할 스테이지를 선택한다.

관리 대상 예:
- Stage ID
- Stage 이름
- 클리어 상태
- 잠금 상태
- 기본 정보

### 3.3 Stage Briefing

전투 시작 전에 스테이지의 목표와 전투 조건을 확인한다.

관리 대상 예:
- 맵 미리보기
- 목표
- 적 구성
- 예상 웨이브
- 특수 규칙
- 출격 정보

### 3.4 Robot / Loadout

해당 스테이지에 출격할 슈퍼로봇과 무장/장비를 선택한다.

관리 대상 예:
- 출격 로봇
- 무장
- 스킬
- 장비/파츠
- 초기 상태

### 3.5 Combat

MENOS의 핵심 플레이 화면.

전투 화면 자체는 별도의 시스템을 실행하는 공간이며, 다음 시스템이 결합된다.

- Robot System
- Enemy System
- Spawn System
- Wave System
- Tower System
- Combat System
- Stage Runtime
- HUD / Event UI

### 3.6 Result

전투 종료 후 결과를 표시한다.

관리 대상 예:
- Victory / Defeat
- 클리어 조건
- 보상
- 기록
- 다음 스테이지 진입
## 4. 개발용 화면

### 4.1 Map Editor

맵 자체를 제작한다.

Map Editor의 질문:

> "전투가 어디에서 벌어지는가?"

주요 데이터 후보:
- Terrain / Tile
- Road
- Boundary
- Obstacle
- Decoration
- Spawn Area
- Tower Placement Area
- Base Position
- Robot Start Position
- 기타 맵 오브젝트

Map Editor의 결과는 **Map Data**가 된다.

### 4.2 Stage Editor

특정 맵에서 어떤 전투가 벌어지는지 정의한다.

현재 구현 상태:
- Stage Editor Scene/Script 구현 완료
- 기존 Stage JSON / StageLoader / StageManager 구조 재사용
- Stage 기본 정보, Wave, Group 편집 및 JSON Load/Save MVP 구현
- 실제 Runtime에서 Content Editor 전환, Stage Load, Save 자동화 검증 완료
- Master의 직접 GUI PIE 확인은 아직 미실시

Stage Editor의 질문:

> "이 맵에서 어떤 전투가 벌어지는가?"

주요 데이터 후보:
- Enemy
- Wave
- Spawn Rule
- Boss
- Victory Condition
- Defeat Condition
- Event
- Reward
- Stage Rule
- 출격 조건

Stage Editor의 결과는 **Stage Data**가 된다.

## 5. Map Data와 Stage Data의 경계

Map Data는 공간을 정의한다.

Stage Data는 전투 시나리오를 정의한다.

```
Map Editor
    ↓
Map Data
    ↓
Stage Runtime ← Stage Data ← Stage Editor
    ↓
Game Runtime
```

예:

- Map Data: "Spawn Area 3이 이 위치에 있다."
- Stage Data: "Wave 4에서 Heavy 5기를 Spawn Area 3에서 출현시킨다."

이 경계를 유지하면 하나의 맵을 여러 스테이지에서 재사용할 수 있다.
## 6. 별도 화면이 필요하지 않은 기능

다음 기능은 독립적인 화면보다는 게임 시스템으로 관리하는 것이 적절하다.

### Enemy System
- 적 생성
- 이동
- 공격
- 피격
- 사망
- AI

### Spawn System
- 스폰 위치 결정
- 스폰 영역 선택
- 분산/순차 스폰
- 스폰 규칙 실행

### Wave System
- 웨이브 시작
- 그룹 진행
- 시간 간격
- 웨이브 종료

### Robot System
- 이동
- 공격
- 스킬
- 피격
- 상태

### Tower System
- 배치
- 타겟 선택
- 공격
- 업그레이드

### Combat System
- 공격 판정
- 피해 계산
- 충돌
- 사망 처리
- 전투 이벤트

이 기능들은 Combat Screen에서 사용되지만, Combat Screen 자체에 구현되어야 한다는 의미는 아니다.

## 7. Stage 중심의 실행 흐름

```
Stage Select
    ↓
Stage Briefing
    ↓
Loadout
    ↓
Stage Runtime Start
    ↓
Map Data Load
    ↓
Stage Data Load
    ↓
Spawn / Wave / Robot / Tower 초기화
    ↓
Combat
    ↓
Victory / Defeat
    ↓
Result
```

Stage Runtime은 Stage Data와 Map Data를 받아 실제 전투를 시작시키는 조정 계층으로 보는 것이 현재 제안이다.
## 8. main.gd의 장기적 역할

현재 main.gd는 맵, 스테이지, 웨이브, 스폰, 적, 로봇, 타워, 전투, 입력, UI 등의 역할이 집중되어 있다.

장기 목표는 main.gd를 모든 기능의 구현 장소가 아니라 **게임 실행 진입점 및 화면 전환/런타임 조정의 얇은 계층**으로 만드는 것이다.

목표 형태의 개념 예:

```
main.gd
  ↓
Game Flow / Stage Runtime
  ↓
┌────────┬────────┬────────┐
Robot   Enemy    Combat   ...
System  System   System
```

단, 이것은 현재 구조를 즉시 리팩터링하라는 의미가 아니다.

기존 StageManager, StageLoader, MapLoader 등의 역할을 먼저 확인하고 최소 단위로 이전해야 한다.

## 9. 설계 원칙

1. Stage를 콘텐츠의 핵심 단위로 본다.
2. Map과 Stage를 분리한다.
3. Screen과 System을 분리한다.
4. Stage Data는 전투의 WHAT을 정의한다.
5. Game System은 전투의 HOW를 실행한다.
6. main.gd에는 기능 구현을 계속 누적하지 않는다.
7. 기존 구조를 확인한 후 최소 단위로 분리한다.
8. 화면이 필요하다는 이유만으로 모든 기능을 별도 Scene으로 만들지 않는다.

## 10. 현재 제안되는 화면 목록

플레이어용:
- Title
- Stage Select
- Stage Briefing
- Robot / Loadout
- Combat
- Result

개발용:
- Content Editor
  - Map Editor
  - Stage Editor

현재 구현된 Content Editor는 기존 Map Editor와 Stage Editor를 호스팅하는 얇은 Shell이다.

선택적 화면:
- Robot Upgrade / Customization
- Enemy / Unit Encyclopedia
- Settings
- Save / Load

선택적 화면은 게임의 실제 요구사항이 확정된 후 결정한다.
## 11. 현재 설계에서 우선 확정해야 할 것

구현보다 먼저 다음 경계를 확정한다.

1. Stage의 정의
2. Stage Data의 항목
3. Map Data의 항목
4. Global Game Data의 항목
5. Stage Runtime의 책임
6. Screen의 책임
7. 기존 코드와 각 책임의 대응 관계

특히 **Map Editor → Map Data**와 **Stage Editor → Stage Data**의 경계를 먼저 확정하는 것이 중요하다.

## 12. 상태

### STATUS
PROPOSAL — 상위 화면/기능 구조 설계 초안.

### 기준선
현재 MENOS 프로젝트의 기존 StageManager, StageLoader, MapLoader 및 main.gd 구조를 기준으로 작성했다.

### 변경 사항
본 문서만 추가한다. 게임 코드, Scene, Asset, Map Data, Stage Data는 변경하지 않는다.

### 검증 상태
문서 구조: CODE/BUILD/PIE 검증 대상 아님.
기존 프로젝트 상태: 별도 변경사항이 존재하므로 이 문서 추가와 구분하여 관리해야 한다.

### 미확인 사항
- 최종 플레이어 화면 목록
- Content Editor의 최종 UI/통합 범위
- Stage Data의 최종 스키마
- 화면 전환을 담당할 최종 Runtime 구조
- Content Editor의 Master 직접 GUI PIE 검증

### OUT OF SCOPE
- main.gd 리팩터링
- 신규 Screen 구현
- Map Editor 구현
- Content Editor의 추가 기능 확장
- Stage Editor의 추가 기능 확장
- Stage Data 스키마 구현
- 기존 코드 수정
- Asset/Blueprint/Scene 변경
- Git Commit / Push

이 문서는 이후 설계 논의를 위한 기준점이며, Master의 명시적 확정 전까지 Canon이 아니다.
