# AXION Motion Specification

> 문서 상태: **PROPOSAL / 설계 기록**  
> 목적: AXION에 필요한 액션게임형 모션의 범위, 구조, 연결성 기록  
> 적용 명칭: AXION (구 BRAVE)  
> 실제 Animation Asset, Rig, Unreal 구현을 의미하지 않음

## 1. 문서 목적과 판정 규칙

이 문서는 AXION을 단순한 메카 보행 캐릭터가 아니라, 빠르고 명확한 액션게임 주인공으로 설계하기 위한 모션 목록과 구조를 정의한다. 목표 방향은 유려한 액션 모션, 화려하고 읽기 쉬운 전투 동작, 강한 실루엣 변화, 그리고 다양한 노출 방향이다.

이 문서에서 사용하는 상태 표기는 다음과 같다.

| 표기 | 의미 |
|---|---|
| **CONFIRMED** | 기존 Excelion 문서에서 확인한 설정 또는 설계 기준 |
| **PROPOSAL** | 이번 문서에서 제안하는 액션게임형 모션 구조 |
| **UNVERIFIED** | 실제 구현, Asset, Rig 호환성 또는 최종 수치가 확인되지 않은 항목 |

PROPOSAL은 Canon 승격이나 Production 완료를 의미하지 않는다.

### 1.1 기존 자료와의 관계

- **CONFIRMED:** 신규 문서와 Unreal 구현 명칭은 AXION을 사용한다. BRAVE는 기존 문서·폴더·소설에 남을 수 있는 구 명칭이다. (`docs/NAMING_STATUS.md`)
- **CONFIRMED:** 기본 이동은 카메라 기준이며, WASD 방향 이동과 약한 가속/감속을 사용하도록 설계되어 있다. (`state/AXION_MOVEMENT_V0_1.md`)
- **CONFIRMED:** 기존 전투 루프는 접근 → 콤보 → 밀기 → 필살 → 다음 무리이며, 썬더 블레이드·S-Core·Heat가 전투 축이다. (`docs/02_COMBAT.md`, `docs/08_PLAY_BRAVE.md`)
- **CONFIRMED:** 별도 회피 입력과 짧은 대시가 설계되어 있다. 대시 중 방향 전환은 불가로 기록되어 있다. (`state/AXION_MOVEMENT_V0_1.md`)
- **UNVERIFIED:** 이 문서의 모션 목록이 실제 Animation Blueprint, Montage, Animation Asset 또는 최종 Rig에 연결되었는지 여부.
- **UNVERIFIED:** 대시 거리·시간·쿨다운·무적시간·공중 대시의 최종값. 기존 문서에도 미정 또는 초안으로 남아 있다.

## 2. Motion Design Principles

### 2.1 Action Character 우선

AXION은 걷고 공격하는 거대한 로봇이 아니라, 액션게임의 주인공처럼 움직이는 슈퍼로봇을 목표로 한다.

- 빠른 방향 전환과 명확한 체중 이동
- 공격 전 anticipation, 타격 순간의 명료한 pose, 공격 후 recovery
- 회전, 몸통 twisting, 순간적인 가속과 감속
- 공격과 이동, 회피와 반격의 연결
- 공중 이동과 공중 공격
- 모션마다 읽히는 강한 실루엣 변화
- 크고 무거운 기체의 질량감과 주인공다운 속도감의 병존

### 2.2 후면 편중 방지

모션 설계 단계에서 후면만 반복적으로 노출되는 구성을 피한다. 전투와 회피에서는 몸 전체의 방향 전환을 적극적으로 사용하며, 아래 방향을 주요 검토 기준으로 삼는다.

- **Front**
- **Front 3/4**
- **Side**
- **Rear 3/4**
- **Diagonal**
- **Aerial**

각 모션의 최종 연출 카메라와 플레이 카메라는 별도 검토 대상이다. 이 문서는 카메라 시스템을 구현하지 않으며, 방향과 실루엣 노출 요구만 기록한다.

### 2.3 모션 개수보다 연결성 우선

Animation Asset 수를 늘리는 것보다 상태 간 연결성과 플레이 리듬을 우선한다.

```text
Run → Dash → Attack → Recovery → Combat Idle
Combat Idle → Dodge → Counter → Attack
Run → Jump → Air Dash → Air Attack → Landing
Guard → Parry → Counter → Recovery
```

## 3. Motion Metadata Convention

개별 모션은 제작 단계에서 다음 정보를 갖는 것을 목표로 한다. 현재 확정되지 않은 값은 임의로 채우지 않는다.

| 항목 | 기록 내용 |
|---|---|
| Motion Name | 모션 이름 |
| Category | Basic State, Locomotion, Melee 등 상위 분류 |
| Direction | Front, Front 3/4, Side, Rear 3/4, Diagonal, Aerial 등 |
| Ground/Air | 지상 또는 공중 |
| Combat/Non-combat | 전투 또는 비전투 |
| Primary Purpose | 모션의 주 목적 |
| Transition In | 들어올 수 있는 대표 상태 |
| Transition Out | 나갈 수 있는 대표 상태 |
| Viewpoint | 주요 노출 방향 |
| Priority | CORE, COMBAT CORE, PRESENTATION |

아래 목록은 전체 범위와 설계 의도를 기록한 것이며, 각 Asset의 제작 명세나 구현 완료 목록이 아니다.

## 4. Motion List

### A. Basic State

| Motion Name | Direction | Ground/Air | Combat | Primary Purpose | Viewpoint | Priority |
|---|---|---|---|---|---|---|
| Idle | Front / 3/4 | Ground | Non-combat | 기본 대기 | Front 3/4 | CORE |
| Combat Idle | Front / 3/4 | Ground | Combat | 전투 준비와 입력 대기 | Front, Front 3/4 | CORE |
| Alert Idle | 방향 전환 | Ground | Combat | 위협 인지와 긴장 유지 | Side, Rear 3/4 포함 | CORE |
| Weapon Ready | Front 3/4 | Ground | Combat | 무장 준비 | Front 3/4, Side | CORE |
| Low Combat Stance | Front 3/4 / Diagonal | Ground | Combat | 낮은 중심과 회피 준비 | Front 3/4, Diagonal | COMBAT CORE |
| Recovery / Relax | Front / Side | Ground | Non-combat | 전투 후 긴장 완화 | Side, Rear 3/4 | PRESENTATION |

### B. Locomotion

#### 기본 이동

- Forward Walk
- Forward Run
- Backward Walk
- Backward Run
- Strafe Left
- Strafe Right

#### 대각선 이동

- Forward Left
- Forward Right
- Backward Left
- Backward Right

#### 방향 전환과 속도 변화

- 45° Turn
- 90° Turn
- 180° Turn
- Running Turn
- Combat Pivot
- Sudden Stop
- Sprint Start

**설계 메모:** 기본 이동은 기존 기준선의 카메라 기준 이동을 따른다. 대각선과 pivot은 후면 반복을 줄이고, 몸통 twisting과 발의 재배치를 읽히게 하는 방향으로 제안한다. 최종 속도, blend time, root motion 정책은 별도 확정이 필요하다.

### C. Dash

- Forward Dash
- Backward Dash
- Left Dash
- Right Dash
- Forward-Left Dash
- Forward-Right Dash
- Backward-Left Dash
- Backward-Right Dash
- Dash Brake
- Dash Turn
- Dash Cancel
- Dash Through Enemy

**CONFIRMED 연결 제약:** 기존 AXION 이동 기준선은 입력 방향 대시, 입력이 없을 때 캐릭터 정면 대시, 대시 중 방향 전환 불가를 기록한다. 위 목록 중 대각선, Brake, Turn, Cancel, Through Enemy는 이 문서의 **PROPOSAL**이다.

### D. Evade

- Side Step Left
- Side Step Right
- Back Step
- Forward Slip
- Side Slip
- Low Evade
- Body Twist Evade
- Spin Evade
- Emergency Evade
- Perfect Dodge

회피는 짧고 명료한 이동, 공격선 회피, 몸 전체의 방향 전환을 우선한다. Perfect Dodge의 판정 창, 무적시간, 후속 보정은 **UNVERIFIED**다.

### E. Melee

#### 기본 공격

- Quick Slash Right
- Quick Slash Left
- Horizontal Slash
- Vertical Slash
- Rising Slash
- Downward Slash
- Thrust
- Spinning Slash

#### 방향성 공격

- Forward Attack
- Backward Attack
- Left Attack
- Right Attack
- Diagonal Attack

#### 이동 공격

- Dash Attack
- Dash Slash
- Running Slash
- Step Attack
- Backstep Attack

기본 공격은 anticipation → strike → follow-through → recovery의 읽기 쉬운 구조를 기본 제안으로 한다. 세부 무장별 동작, 타격 수, 판정, 프레임은 이 문서에서 확정하지 않는다.

### F. Combo

- Light Combo
- Heavy Combo
- Slash Combo
- Rising Combo
- Spin Combo
- Combo Finisher
- Launcher
- Air Combo 1
- Air Combo 2
- Air Combo 3
- Air Finisher
- Ground Slam

콤보는 접근, 방향 전환, 타격, 띄우기, 마무리의 리듬을 구성한다. 콤보 단계 수와 입력 윈도우는 **UNVERIFIED**다.

### G. Defense / Counter

- Guard
- High Guard
- Low Guard
- Perfect Guard
- Parry
- Parry Counter
- Counter Slash
- Counter Thrust
- Guard Break
- Guard Recovery

Guard → Parry → Counter의 연결을 핵심 방어 루프로 제안한다. Perfect Guard와 Parry의 판정, 반격 무적, 적 공격별 대응 가능 여부는 **UNVERIFIED**다.

### H. Skill / Special Attack

- Skill Ready
- Power Charge
- Burst
- Spin Attack
- Piercing Attack
- Wide Slash
- Heavy Impact
- Rush Attack
- Counter Burst
- Finisher

S-Core와 필살 연출은 기존 전투 설계의 축을 참조하되, 이 문서는 스킬 판정이나 S-Core 수치를 새로 결정하지 않는다. Power Charge, Burst, Counter Burst의 최종 역할은 **PROPOSAL / UNVERIFIED**다.

### I. Air Combat

- Jump
- High Jump
- Air Dash
- Air Brake
- Air Turn
- Air Attack
- Air Slash
- Air Combo
- Air Dodge
- Dive Attack
- Ground Impact
- Air Recovery

공중 모션은 Aerial 방향성을 독립된 노출 축으로 취급한다. 공중 대시는 기존 기준선에서 미정이며, 이 목록은 구현 완료를 뜻하지 않는다.

### J. Hit Reaction

#### 방향별 피격

- Light Hit Front
- Light Hit Back
- Light Hit Side
- Medium Hit
- Heavy Hit

#### 상태별 피격

- Stagger
- Knockback
- Knockdown
- Air Hit
- Air Knockback
- Recovery

피격은 전투 상태와 방향을 읽히게 해야 하며, Light / Medium / Heavy의 분류와 실제 경직 시간은 **UNVERIFIED**다.

### K. Finisher / Cinematic Action

- Enemy Finisher
- Dash Finisher
- Air Finisher
- Counter Finisher
- Heavy Finisher
- Boss Finisher
- Victory Pose
- Combat Victory

Finisher는 주인공의 실루엣과 공격 방향을 크게 보여주는 연출 후보이다. 실제 시네마틱, 카메라, 시퀀서, Montage 구현은 **OUT OF SCOPE**다.

### L. Character / Presentation

전투 외 모션은 AXION의 캐릭터성과 실루엣을 보여주기 위한 별도 축이다.

- Look Around
- Head Turn
- Look Up
- Look Down
- Weapon Inspect
- Damage Check
- Ready Pose
- Determined Pose
- Relaxed Pose
- Hero Pose

## 5. Transition Structure

아래는 모션 상태 간 대표 연결을 정의한 **PROPOSAL**이다. 단방향 재생 규칙, blend time, interrupt priority, notify, 실제 State Machine 구현은 포함하지 않는다.

### 5.1 Locomotion

```text
Idle → Walk
Walk → Run
Run → Sprint
Run → Stop
Run → Turn
```

### 5.2 Combat

```text
Combat Idle → Attack
Attack → Attack
Attack → Dodge
Attack → Recovery
Dodge → Counter
Guard → Parry
Parry → Counter Attack
```

### 5.3 Dash

```text
Run → Dash
Dash → Attack
Dash → Dodge
Dash → Stop
```

### 5.4 Air

```text
Jump → Air Dash
Air Dash → Air Attack
Air Attack → Air Combo
Air Combo → Air Finisher
Air → Landing
Landing → Combat Idle
```

### 5.5 대표 플레이 루프

```text
Run → Dash → Attack → Recovery → Combat Idle
Combat Idle → Dodge → Counter → Attack
Run → Jump → Air Dash → Air Attack → Landing
Guard → Parry → Counter → Recovery
```

### 5.6 Transition 설계 기준

- **방향성:** 전이 전후의 facing과 실루엣이 자연스럽게 이어져야 한다.
- **질량감:** 빠른 액션에서도 발, 골반, 몸통이 체중을 전달해야 한다.
- **명료성:** anticipation, hit pose, recovery가 서로 묻히지 않아야 한다.
- **연결성:** 이동 중 공격, 공격 후 회피, 회피 후 반격, 공중 공격 후 착지를 우선 검토한다.
- **후면 편중 방지:** 전이 결과가 지속적으로 rear view에 머물지 않도록 Front 3/4, Side, Diagonal, Aerial 노출을 배분한다.
- **중단 규칙:** 어떤 모션이 어떤 시점에 취소·연결되는지는 구현 단계에서 별도로 확정한다.

## 6. Production Priority Classification

이 분류는 제작 순서 후보를 정리하는 것이며, 완료 목록이나 실제 제작 승인 목록이 아니다.

### CORE

- Idle
- Combat Idle
- Walk
- Run
- Strafe
- Turn
- Dash
- Dodge
- Basic Attack
- Guard
- Hit
- Jump
- Landing

### COMBAT CORE

- Attack Combo
- Launcher
- Air Attack
- Parry
- Counter
- Recovery
- Finisher

### PRESENTATION

- Hero Pose
- Dramatic Pose
- Weapon Inspect
- Character-specific idle
- 기타 연출 모션

## 7. Validation Boundaries

### 확인된 사항

- AXION은 신규 문서와 Unreal 구현에서 사용할 주역 메카 명칭이다.
- 기존 이동 기준은 카메라 기준 WASD 이동과 약한 가속/감속이다.
- 기존 전투 설계에는 콤보, 대시, 근접 무장, S-Core, 필살 루프가 있다.
- 본 문서는 모션 범위와 구조를 기록하며 코드·Asset을 수정하지 않는다.

### 이번 문서의 제안

- 액션게임형 AXION을 위한 13개 모션 카테고리.
- Front, Front 3/4, Side, Rear 3/4, Diagonal, Aerial을 활용하는 방향성 기준.
- 이동·전투·대시·공중·방어·반격을 잇는 대표 Transition.
- CORE / COMBAT CORE / PRESENTATION 분류.

### 미확인 사항

- 실제 Animation Asset, Animation Blueprint, Montage, Notify 존재 여부.
- 최종 Rig 호환성, Retarget 가능 여부, 본 구조.
- 최종 프레임, FPS, blend time, root motion 정책의 이 문서 적용 여부.
- 대시·회피·공중 이동의 최종 거리, 시간, 쿨다운, 무적, 판정.
- 전투 카메라가 각 Viewpoint 요구를 실제로 충족하는지 여부.

## 8. OUT OF SCOPE

- Blender 애니메이션 제작
- Python 스크립트 작성
- Rigify 수정
- IK/FK 구현
- Unreal Animation Blueprint 구현
- Montage 제작
- Retarget 작업
- 실제 Animation Asset 생성
- 전투 시스템 구현
- 카메라 시스템 구현
- 기존 프로젝트 Asset 수정

## 9. Document Verification Checklist

- [x] AXION 전체 모션 카테고리 기록
- [x] 주요 모션 목록 정리
- [x] Transition 구조 기록
- [x] 후면 편중 방지 원칙 기록
- [x] CONFIRMED / PROPOSAL / UNVERIFIED 구분
- [x] 기존 Asset과 코드 미수정
- [x] 실제 구현 완료로 오해할 표현 배제
- [x] CORE / COMBAT CORE / PRESENTATION을 완료 목록으로 해석하지 않도록 명시
