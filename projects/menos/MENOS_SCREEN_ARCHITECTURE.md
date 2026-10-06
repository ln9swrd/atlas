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
- 향후 사용자용 Workshop Map Editor
  - Map
  - Stage
  - Mission
  - Wave
  - 기존 Catalog 선택
  - Preview
  - Validate
  - Publish

현재 구현된 Content Editor는 기존 Map Editor와 Stage Editor를 호스팅하는 얇은 Shell이다.

사용자용 Workshop Editor는 내부 Authoring Editor와 기능 범위를 동일하게 두지 않는 방향을 제안한다. 사용자 콘텐츠는 기존 Catalog의 안정적인 ID를 참조하고, 게임 규칙과 Definition을 임의로 재정의하지 않는 구조를 우선한다.

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


## 2026-10-06 Gameplay Settings / Content Editor 화면 경계

STATUS — PROPOSAL / NOT CANON

Content Editor는 개별 콘텐츠 정의를 편집하고, Gameplay/Settings Editor는 게임 전체에 적용되는 전역 규칙과 기능 활성화 정책을 편집한다.

### Gameplay / Settings Editor 후보

- Game Rules
- Combat Rules
- Player Control
- Camera
- HUD
- Progression
- Economy
- Shop / Marketplace
- Steam / Workshop / 결제
- Save
- Audio
- Accessibility
- Debug

### Content Editor 후보

- Robot
- Enemy
- Tower
- Faction
- Skill / Ability
- Item
- Mission
- Campaign
- Map
- Stage
- Wave / Encounter
- Reward
- Shop Product
- Audio / VFX Reference

원칙: Content Definition은 무엇이 존재하는가, Gameplay Rule은 그것들이 어떤 규칙으로 작동하는가를 정의한다. 개별 콘텐츠의 능력치와 Stage 구성은 Gameplay/Settings 화면에서 직접 편집하지 않는다.


## 2026-10-06 Content Editor / Runtime UI 다국어 경계

STATUS — CANON / Master 결정 반영

MENOS의 다국어 지원은 게임 Runtime뿐 아니라 Content Editor UI에도 적용한다. 기본 언어는 English이며, 사용자의 언어 선택에 따라 Editor UI와 콘텐츠 텍스트가 대응한다.

### 화면 책임

Gameplay / Settings:
- Language 선택
- Default Language
- Fallback 정책

Content Editor:
- 현재 선택 언어에 맞는 UI 표시
- 콘텐츠 이름/설명/미션/스킬 등의 번역 표시
- 번역 문자열을 직접 소유하지 않고 Localization String ID를 사용

Localization:
- 실제 언어별 문자열을 별도 데이터로 관리

### 원칙

Content Editor의 영어 UI를 단순히 코드에서 다른 언어 문자열로 교체하는 방식으로 관리하지 않는다. UI 문자열을 Localization String ID로 분리하여 동일한 언어 설정 체계를 사용한다.

예:
editor.save / editor.cancel / editor.validate / editor.field.hp

Runtime 콘텐츠 역시 동일한 방식으로 String ID를 참조한다. Editor와 Runtime에서 동일한 콘텐츠 문구를 중복 관리하지 않는다.

## 2026-10-06 Settings 화면 반영

STATUS — PROPOSAL / 현재 구현 반영

메인 화면 Settings는 전역 설정 화면으로 취급한다.

현재 대상:
- BGM Volume
- SFX Volume
- Language

언어 설정은 기존 Localization 책임 경계를 따른다. Audio 설정은 Settings가 소유하고 Runtime Audio Bus에 적용한다.

## 2026-10-06 Content Editor 메뉴 전환 성능 조사

STATUS — HOLD / READ-ONLY 조사 결과

Content Editor 상단 메뉴는 선택된 Editor Scene을 매번 새로 로드하고 기존 Editor를 제거하는 구조다.

전환 흐름:
```
Menu Click
  ↓
_load_editor()
  ↓
queue_free(previous editor)
  ↓
load(PackedScene)
  ↓
instantiate()
  ↓
add_child()
  ↓
child _ready()
  ↓
Catalog / File / Image load + UI build
```

CONFIRMED — 위 구조와 일부 Editor의 동기 초기화 작업은 코드에서 확인되었다.

HIGH CONFIDENCE — 이 재생성 구조가 메뉴 클릭 지연의 주요 원인일 가능성이 높다.

UNVERIFIED — Editor별 실제 지연 시간과 개별 작업의 비용은 아직 계측하지 않았다.

따라서 다음 구조 변경은 계측 후 결정한다. 우선 검증은 메뉴별 전환 시간을 측정하는 최소 계측으로 제한한다. 목적 달성 전까지 자동으로 캐시 구조나 비동기 로딩을 도입하지 않는다.


## 2026-10-06 VFX Editor 화면 / Runtime 경계

STATUS — PROPOSAL / NOT CANON

VFX는 Content Editor의 독립 콘텐츠 유형으로 관리하는 방향을 제안한다.

```text
Content Editor
  └─ VFX Editor
       ↓
   VFX Catalog
       ↓
 Runtime VFX System
```

VFX Editor는 VFX의 ODB PK, 변경 가능한 이름/제목, 분류, 지속시간, Sprite/Texture 참조, Particle, Shader, Animation, Light, Sound 참조 및 Runtime 재생 조건 등을 정의·관리한다.

실제 VFX Asset 제작과 VFX 데이터 정의는 분리한다. Godot의 GPUParticles2D/CPUParticles2D, Shader, AnimationPlayer, AnimatedSprite2D 등의 시스템을 사용하여 효과를 구성할 수 있지만, 완성된 VFX Asset Library가 기본 제공되는 것은 아니다.

PROPOSAL — VFX 데이터는 JSON/SQLite 등으로 정의하고 Runtime VFX System이 해당 정의를 실행하는 데이터 기반 구조를 우선 검토한다. Robot/Skill/Building 등은 VFX ODB PK를 참조하는 방식으로 연결하는 것을 권장한다.

현재 상태에서는 VFX Schema와 Runtime 소비 경로를 먼저 조사한다. VFX Editor 구현이나 기존 콘텐츠에 VFX 필드를 추가하는 작업은 Schema 확정 전까지 수행하지 않는다.


## 2026-10-06 SFX Editor 화면 / Runtime 경계

STATUS — PROPOSAL / NOT CANON

SFX는 Content Editor의 독립 콘텐츠 유형으로 관리하는 방향을 제안한다.

```text
Content Editor
  └─ SFX Editor
       ↓
   SFX Catalog
       ↓
 Runtime Audio System
       ↓
      SFX Bus
```

SFX Editor는 SFX의 ODB PK, 변경 가능한 이름/제목, 분류, Audio Asset 참조, 볼륨, 피치, 루프, 2D/3D 재생 유형, 거리 감쇠, 우선순위 및 동시 재생 제한 등을 정의·관리한다.

역할을 다음과 같이 분리한다.
- Gameplay / Settings: 전역 SFX Volume 및 SFX Bus 정책
- SFX Content: 개별 소리의 정의와 Asset 참조
- Gameplay Runtime: 게임 이벤트와 SFX ODB PK의 연결 및 재생 요청

Robot/Enemy/Tower/Building/Skill 등의 Content는 Audio 파일명을 직접 참조하지 않고 SFX ODB PK를 참조하는 방향을 권장한다.

PROPOSAL — SFX 데이터는 JSON/SQLite 등의 데이터 정의로 관리하고 Runtime Audio System이 이를 실행하는 데이터 기반 구조를 우선 검토한다.

현재 상태에서는 SFX Schema와 기존 Audio 재생 경로를 먼저 조사한다. SFX Editor 구현이나 기존 Content에 SFX 필드를 추가하는 작업은 Schema 확정 전까지 수행하지 않는다.


## 2026-10-06 BGM Editor 화면 / Runtime 경계

STATUS — PROPOSAL / NOT CANON

BGM은 Content Editor의 독립 콘텐츠 유형으로 관리하는 방향을 제안한다.

```text
Content Editor
  └─ BGM Editor
       ↓
   BGM Catalog
       ↓
 Runtime Audio System
       ↓
      BGM Bus
```

BGM Editor는 BGM의 ODB PK, 변경 가능한 이름/제목, 분류, Audio Asset 참조, 볼륨, 피치, Loop, Fade In/Out, 우선순위 및 Transition 방식을 정의·관리한다.

역할을 다음과 같이 분리한다.
- Gameplay / Settings: 전역 BGM Volume 및 BGM Bus 정책
- BGM Content: 개별 음악의 정의와 Asset 참조
- Gameplay Runtime: 현재 상황과 BGM ODB PK의 연결 및 재생 요청
- Runtime Audio System: 실제 재생, Loop, Fade 및 Transition 처리

Mission/Campaign/Battle 등의 Content는 Audio 파일명을 직접 참조하지 않고 BGM ODB PK를 참조하는 방향을 권장한다.

PROPOSAL — BGM 데이터는 JSON/SQLite 등의 데이터 정의로 관리하고 Runtime Audio System이 이를 실행하는 데이터 기반 구조를 우선 검토한다.

현재 상태에서는 BGM Schema와 기존 Audio 재생 경로를 먼저 조사한다. BGM Editor 구현이나 기존 Content에 BGM 필드를 추가하는 작업은 Schema 확정 전까지 수행하지 않는다.
